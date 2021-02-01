package org.scada_lts.workdomain.datasource.amqp;

import br.org.scadabr.api.constants.DataType;
import com.rabbitmq.client.*;
import com.serotonin.mango.Common;
import com.serotonin.mango.DataTypes;
import com.serotonin.mango.rt.dataImage.DataPointRT;
import com.serotonin.mango.rt.dataImage.PointValueTime;
import com.serotonin.mango.rt.dataImage.SetPointSource;
import com.serotonin.mango.rt.dataImage.types.AlphanumericValue;
import com.serotonin.mango.rt.dataImage.types.BinaryValue;
import com.serotonin.mango.rt.dataImage.types.NumericValue;
import com.serotonin.mango.rt.dataSource.PollingDataSource;
import com.serotonin.web.i18n.LocalizableMessage;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.TimeoutException;

/**
 * Real Time Behaviour of AMQP Receiver DataSource
 * Receive messages from RabbitMQ Queue by AMQP protocol datapoints.
 * AMQP Receiver extends PollingDataSource to check the connection to RabbitMQ server
 * with interval set in update period time. While polling it checks the amqpBindEstablished
 * flag to not duplicate connections within data points and Rabbit server.
 * RabbitMQ AMQP version = 0.9.1 (default)
 *
 * @author Radek Jajko
 * @version 1.0
 * @since 2018-09-11
 */
public class AmqpDataSourceRT extends PollingDataSource {
    public static final int DATA_SOURCE_EXCEPTION_EVENT = 1;
    public static final int DATA_POINT_EXCEPTION_EVENT = 2;

    private final Log log = LogFactory.getLog(AmqpDataSourceRT.class);

    private final AmqpDataSourceVO vo;
    private Connection connection;
    private Channel channel;
    private boolean amqpBindEstablished = false;

    public AmqpDataSourceRT(AmqpDataSourceVO vo) {
        super(vo);
        this.vo = vo;
        setPollingPeriod(vo.getUpdatePeriodType(), vo.getUpdatePeriods(), false);
        log.debug("DataSourceRT:AMQP - Created!");
    }

    @Override
    public void setPointValue(DataPointRT dataPoint, PointValueTime valueTime, SetPointSource source) {

        AmqpPointLocatorRT locator = dataPoint.getPointLocator();
        String message = "";
        if (locator.getVO().getDataTypeId()==DataTypes.ALPHANUMERIC) {
            message = valueTime.getStringValue();
        } else if (locator.getVO().getDataTypeId() == DataTypes.NUMERIC) {
            message = String.valueOf(valueTime.getDoubleValue());
        } else if (locator.getVO().getDataTypeId() == DataTypes.BINARY) {
            message = String.valueOf(valueTime.getBooleanValue());
        }
        try {
            switch (locator.getVO().getExchangeType()) {
                case AmqpPointLocatorVO.ExchangeType.A_DIRECT:
                case AmqpPointLocatorVO.ExchangeType.A_TOPIC:
                    channel.basicPublish(locator.getExchangeName(), locator.getRoutingKey(), null, message.getBytes());
                    break;
                case AmqpPointLocatorVO.ExchangeType.A_FANOUT:
                    channel.basicPublish(locator.getExchangeName(), "", null, message.getBytes());
                    break;
                default:
                    channel.basicPublish("", locator.getQueueName(), null, message.getBytes());
                    break;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }


    }

    // Enable DataSource //
    @Override
    public void initialize() {

        log.debug("AMQP Datasource initializing started");
        ConnectionFactory rabbitFactory = new ConnectionFactory();
        rabbitFactory.setHost(vo.getServerIpAddress());
        rabbitFactory.setPort(Integer.parseInt(vo.getServerPortNumber()));

        if (!vo.getServerUsername().isEmpty()) {
            rabbitFactory.setUsername(vo.getServerUsername());
        }

        if (!vo.getServerPassword().isEmpty()) {
            rabbitFactory.setPassword(vo.getServerPassword());
        }

        if (!vo.getServerVirtualHost().isEmpty()) {
            rabbitFactory.setVirtualHost(vo.getServerVirtualHost());
        }

        initializeChannel(rabbitFactory);

        super.initialize();

    }

    // Disable DataSource //
    @Override
    public void terminate() {
        try {
            channel.close();
            connection.close();
            amqpBindEstablished = false;
        } catch (IOException | TimeoutException | AlreadyClosedException e) {
            this.vo.setEnabled(false);
            amqpBindEstablished = false;
            raiseEvent(DATA_SOURCE_EXCEPTION_EVENT, System.currentTimeMillis(), true,
                    new LocalizableMessage("event.exception2", e.getClass().getName(), e.getMessage()));

        }
        super.terminate();

    }

    @Override
    protected void doPoll(long time) {

        //If not amqpBindEstablished initialize DataPoints
        if (channel != null) {
            if (channel.isOpen() && !amqpBindEstablished) {

                for (DataPointRT dp : dataPoints) {
                    try {
                        initDataPoint(dp, channel);
                        returnToNormal(DATA_POINT_EXCEPTION_EVENT, System.currentTimeMillis());
                    } catch (IOException e) {
                        raiseEvent(DATA_POINT_EXCEPTION_EVENT, System.currentTimeMillis(), false,
                                new LocalizableMessage("event.amqp.bindError", dp.getVO().getXid()));
                    }
                }
                amqpBindEstablished = true;
            }
        }
    }

    /**
     * Initialize Connection and Channel
     *
     * @param connectionFactory - RabbitMQ connector with prepared connection values
     */
    private void initializeChannel(ConnectionFactory connectionFactory) {

        try {
            connection = connectionFactory.newConnection();
            channel = connection.createChannel();
        } catch (IOException | TimeoutException e) {
            Reconnection reconnect = new Reconnection(connectionFactory, this);
            reconnect.start();
        }

    }

    /**
     * Initialize AMQP Data Point
     * Before initializing make sure you have got created exchange type,
     * exchange name, queue name and bindings between them.
     *
     * Any connection error breaks the connection between ScadaLTS
     * and RabbitMQ server
     *
     * @param dp      - single AMQP DataPoint
     * @param channel - RabbitMQ channel (with prepared connection)
     * @throws IOException - Errors
     */
    private void initDataPoint(DataPointRT dp, Channel channel) throws IOException {

        AmqpPointLocatorRT locator = dp.getPointLocator();
        String exchangeType = locator.getVO().getExchangeType();

        boolean durable = locator.getVO().getQueueDurability().equalsIgnoreCase("1");
        boolean noAck = locator.getVO().getMessageAck().equalsIgnoreCase("1");

        if (channel != null) {
            if (exchangeType.equalsIgnoreCase(AmqpPointLocatorVO.ExchangeType.A_FANOUT)) {
                channel.exchangeDeclare(locator.getExchangeName(), AmqpPointLocatorVO.ExchangeType.A_FANOUT, durable);
                locator.setQueueName(channel.queueDeclare().getQueue());
                channel.queueBind(locator.getQueueName(), locator.getExchangeName(), "");

                Consumer consumer = new ScadaConsumer(channel, dp);
                channel.basicConsume(locator.getQueueName(), noAck, consumer);

            } else if (exchangeType.equalsIgnoreCase(AmqpPointLocatorVO.ExchangeType.A_DIRECT)) {

                channel.exchangeDeclare(locator.getExchangeName(), AmqpPointLocatorVO.ExchangeType.A_DIRECT, durable);
                locator.setQueueName(channel.queueDeclare().getQueue());
                channel.queueBind(locator.getQueueName(), locator.getExchangeName(), locator.getRoutingKey());

                Consumer consumer = new ScadaConsumer(channel, dp);
                channel.basicConsume(locator.getQueueName(), noAck, consumer);

            } else if (exchangeType.equalsIgnoreCase(AmqpPointLocatorVO.ExchangeType.A_TOPIC)) {
                channel.exchangeDeclare(locator.getExchangeName(), AmqpPointLocatorVO.ExchangeType.A_TOPIC, durable);
                locator.setQueueName(channel.queueDeclare().getQueue());
                channel.queueBind(locator.getQueueName(), locator.getExchangeName(), locator.getRoutingKey());

                Consumer consumer = new ScadaConsumer(channel, dp);
                channel.basicConsume(locator.getQueueName(), noAck, consumer);


            } else if (exchangeType.isEmpty()) {

                channel.queueDeclare(locator.getQueueName(), durable, false, false, null);
                Consumer consumer = new ScadaConsumer(channel, dp);
                channel.basicConsume(locator.getQueueName(), noAck, consumer);

            }

        }

    }

    class ScadaConsumer extends DefaultConsumer {

        DataPointRT dataPoint;
        AmqpPointLocatorRT locator;

        ScadaConsumer(Channel channel, DataPointRT dataPoint) {
            super(channel);
            this.dataPoint = dataPoint;
            this.locator = dataPoint.getPointLocator();
        }

        @Override
        public void handleDelivery(String consumerTag, Envelope envelope, AMQP.BasicProperties properties, byte[] body) throws IOException {
            super.handleDelivery(consumerTag, envelope, properties, body);

            String message = new String(body, StandardCharsets.UTF_8);

            if (locator.getVO().isWritable()) {
                if (dataPoint.getDataTypeId() == DataTypes.ALPHANUMERIC) {
                    dataPoint.updatePointValue(new PointValueTime(
                            new AlphanumericValue(message), System.currentTimeMillis()
                    ));
                } else if (dataPoint.getDataTypeId() == DataTypes.NUMERIC) {
                    dataPoint.updatePointValue(new PointValueTime(
                            new NumericValue(Double.parseDouble(message)), System.currentTimeMillis()
                    ));
                } else if (dataPoint.getDataTypeId() == DataTypes.BINARY) {
                    dataPoint.updatePointValue(new PointValueTime(
                            new BinaryValue(Boolean.parseBoolean(message)), System.currentTimeMillis())
                    );
                }
            }
        }
    }

    /**
     * Reconnection Class
     * Tries to restore connection with RabbitMQ broker server
     */
    class Reconnection extends Thread {

        ConnectionFactory connectionFactory;
        AmqpDataSourceRT dataSourceRT;
        int multiplier;

        Reconnection(ConnectionFactory connectionFactory, AmqpDataSourceRT dataSourceRT) {
            this.connectionFactory = connectionFactory;
            this.dataSourceRT = dataSourceRT;
            this.setName("AMQP Reconnection");
        }

        @Override
        public void run() {
            switch (dataSourceRT.vo.getUpdatePeriodType()) {
                case Common.TimePeriods.SECONDS:
                    multiplier = 1000;
                    break;
                case Common.TimePeriods.MINUTES:
                    multiplier = 1000 * 60;
                    break;
                case Common.TimePeriods.HOURS:
                    multiplier = 1000 * 3600;
                    break;
            }
            for (int i = 1; i <= dataSourceRT.vo.getUpdateAttempts(); i++) {
                try {
                    sleep(dataSourceRT.vo.getUpdatePeriods() * multiplier);
                    log.debug(this.getName() + " :: Retry no." + i);
                    connection = connectionFactory.newConnection();
                    if (connection.isOpen()) {
                        channel = connection.createChannel();
                        if (channel.isOpen()) {
                            dataSourceRT.doPoll(System.currentTimeMillis());
                            terminate();
                            break;
                        }
                    }
                } catch (IOException | TimeoutException | InterruptedException exception) {
                    log.debug("AMQP_RECEIVER: Reconnect attempt failed");
                }
            }
        }
    }
}
