/*
 * (c) 2016 Abil'I.T. http://abilit.eu/
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
package org.scada_lts.dao;

import com.serotonin.mango.vo.event.MaintenanceEventVO;
import org.junit.Test;
import org.springframework.dao.EmptyResultDataAccessException;

import java.util.List;

import static org.junit.Assert.assertTrue;


/**
 * Test MaintenanceEventDAO
 *
 * @author Mateusz Kaproń Abil'I.T. development team, sdt@abilit.eu
 */
public class MaintenanceEventDaoTest extends TestDAO {

	private static final String XID = "maintE xid";
	private static final int DATA_SOURCE_ID = 1;
	private static final String ALIAS = "maintE alias";
	private static final int ALARM_LEVEL = 2;
	private static final int SCHEDULE_TYPE = 1;
	private static final boolean DISABLED = false;
	private static final int ACTIVE_YEAR = 2000;
	private static final int ACTIVE_MONTH = 10;
	private static final int ACTIVE_DAY = 5;
	private static final int ACTIVE_HOUR = 7;
	private static final int ACTIVE_MINUTE = 12;
	private static final int ACTIVE_SECOND = 15;
	private static final String ACTIVE_CRON = "maintE activeCron";
	private static final int INACTIVE_YEAR = 1500;
	private static final int INACTIVE_MONTH = 1;
	private static final int INACTIVE_DAY = 4;
	private static final int INACTIVE_HOUR = 8;
	private static final int INACTIVE_MINUTE = 45;
	private static final int INACTIVE_SECOND = 3;
	private static final String INACTIVE_CRON = "maintE inactiveCron";

	private static final String SECOND_XID = "second  xid";
	private static final int SECOND_DATA_SOURCE_ID = 1;
	private static final String SECOND_ALIAS = "second alias";
	private static final int SECOND_ALARM_LEVEL = 1;
	private static final int SECOND_SCHEDULE_TYPE = 3;
	private static final boolean SECOND_DISABLED = true;
	private static final int SECOND_ACTIVE_YEAR = 1457;
	private static final int SECOND_ACTIVE_MONTH = 8;
	private static final int SECOND_ACTIVE_DAY = 1;
	private static final int SECOND_ACTIVE_HOUR = 4;
	private static final int SECOND_ACTIVE_MINUTE = 2;
	private static final int SECOND_ACTIVE_SECOND = 6;
	private static final String SECOND_ACTIVE_CRON = "second activeCron";
	private static final int SECOND_INACTIVE_YEAR = 1647;
	private static final int SECOND_INACTIVE_MONTH = 6;
	private static final int SECOND_INACTIVE_DAY = 3;
	private static final int SECOND_INACTIVE_HOUR = 5;
	private static final int SECOND_INACTIVE_MINUTE = 34;
	private static final int SECOND_INACTIVE_SECOND = 21;
	private static final String SECOND_INACTIVE_CRON = "second inactiveCron";

	private static final String UPDATE_XID = "update xid";
	private static final int UPDATE_DATA_SOURCE_ID = 1;
	private static final String UPDATE_ALIAS = "update alias";
	private static final int UPDATE_ALARM_LEVEL = 1;
	private static final int UPDATE_SCHEDULE_TYPE = 3;
	private static final boolean UPDATE_DISABLED = true;
	private static final int UPDATE_ACTIVE_YEAR = 200;
	private static final int UPDATE_ACTIVE_MONTH = 2;
	private static final int UPDATE_ACTIVE_DAY = 6;
	private static final int UPDATE_ACTIVE_HOUR = 4;
	private static final int UPDATE_ACTIVE_MINUTE = 1;
	private static final int UPDATE_ACTIVE_SECOND = 1;
	private static final String UPDATE_ACTIVE_CRON = "update activeCron";
	private static final int UPDATE_INACTIVE_YEAR = 1554;
	private static final int UPDATE_INACTIVE_MONTH = 3;
	private static final int UPDATE_INACTIVE_DAY = 2;
	private static final int UPDATE_INACTIVE_HOUR = 1;
	private static final int UPDATE_INACTIVE_MINUTE = 4;
	private static final int UPDATE_INACTIVE_SECOND = 4;
	private static final String UPDATE_INACTIVE_CRON = "update inactiveCron";

	private static final int LIST_SIZE = 2;

	@Test
	public void test() {

		//TODO It is necessary to insert DataSource object before insert MaintenanceEvent object
		DAO.getInstance().getJdbcTemp().update("INSERT INTO datasources (xid, name, dataSourceType, data) values ('x1', 'dataName', 1, 0);");

		MaintenanceEventVO maintenanceEventVO = new MaintenanceEventVO();
		maintenanceEventVO.setXid(XID);
		maintenanceEventVO.setDataSourceId(DATA_SOURCE_ID);
		maintenanceEventVO.setAlias(ALIAS);
		maintenanceEventVO.setAlarmLevel(ALARM_LEVEL);
		maintenanceEventVO.setScheduleType(SCHEDULE_TYPE);
		maintenanceEventVO.setDisabled(DISABLED);
		maintenanceEventVO.setActiveYear(ACTIVE_YEAR);
		maintenanceEventVO.setActiveMonth(ACTIVE_MONTH);
		maintenanceEventVO.setActiveDay(ACTIVE_DAY);
		maintenanceEventVO.setActiveHour(ACTIVE_HOUR);
		maintenanceEventVO.setActiveMinute(ACTIVE_MINUTE);
		maintenanceEventVO.setActiveSecond(ACTIVE_SECOND);
		maintenanceEventVO.setActiveCron(ACTIVE_CRON);
		maintenanceEventVO.setInactiveYear(INACTIVE_YEAR);
		maintenanceEventVO.setInactiveMonth(INACTIVE_MONTH);
		maintenanceEventVO.setInactiveDay(INACTIVE_DAY);
		maintenanceEventVO.setInactiveHour(INACTIVE_HOUR);
		maintenanceEventVO.setInactiveMinute(INACTIVE_MINUTE);
		maintenanceEventVO.setInactiveSecond(INACTIVE_SECOND);
		maintenanceEventVO.setInactiveCron(INACTIVE_CRON);

		MaintenanceEventVO secondMaintenanceEventVO = new MaintenanceEventVO();
		secondMaintenanceEventVO.setXid(SECOND_XID);
		secondMaintenanceEventVO.setDataSourceId(SECOND_DATA_SOURCE_ID);
		secondMaintenanceEventVO.setAlias(SECOND_ALIAS);
		secondMaintenanceEventVO.setAlarmLevel(SECOND_ALARM_LEVEL);
		secondMaintenanceEventVO.setScheduleType(SECOND_SCHEDULE_TYPE);
		secondMaintenanceEventVO.setDisabled(SECOND_DISABLED);
		secondMaintenanceEventVO.setActiveYear(SECOND_ACTIVE_YEAR);
		secondMaintenanceEventVO.setActiveMonth(SECOND_ACTIVE_MONTH);
		secondMaintenanceEventVO.setActiveDay(SECOND_ACTIVE_DAY);
		secondMaintenanceEventVO.setActiveHour(SECOND_ACTIVE_HOUR);
		secondMaintenanceEventVO.setActiveMinute(SECOND_ACTIVE_MINUTE);
		secondMaintenanceEventVO.setActiveSecond(SECOND_ACTIVE_SECOND);
		secondMaintenanceEventVO.setActiveCron(SECOND_ACTIVE_CRON);
		secondMaintenanceEventVO.setInactiveYear(SECOND_INACTIVE_YEAR);
		secondMaintenanceEventVO.setInactiveMonth(SECOND_INACTIVE_MONTH);
		secondMaintenanceEventVO.setInactiveDay(SECOND_INACTIVE_DAY);
		secondMaintenanceEventVO.setInactiveHour(SECOND_INACTIVE_HOUR);
		secondMaintenanceEventVO.setInactiveMinute(SECOND_INACTIVE_MINUTE);
		secondMaintenanceEventVO.setInactiveSecond(SECOND_INACTIVE_SECOND);
		secondMaintenanceEventVO.setInactiveCron(SECOND_INACTIVE_CRON);

		//Insert
		MaintenanceEventDAO maintenanceEventDAO = new MaintenanceEventDAO();
		int firstId = maintenanceEventDAO.insert(maintenanceEventVO);
		int secondId = maintenanceEventDAO.insert(secondMaintenanceEventVO);

		//Select single object by ID
		MaintenanceEventVO maintenanceEventSelectID = maintenanceEventDAO.getMaintenanceEvent(firstId);
		Assert.assertTrue(maintenanceEventSelectID.getId() == firstId);
		Assert.assertTrue(maintenanceEventSelectID.getXid().equals(XID));
		Assert.assertTrue(maintenanceEventSelectID.getDataSourceId() == DATA_SOURCE_ID);
		Assert.assertTrue(maintenanceEventSelectID.getAlias().equals(ALIAS));
		Assert.assertTrue(maintenanceEventSelectID.getAlarmLevel() == ALARM_LEVEL);
		Assert.assertTrue(maintenanceEventSelectID.getScheduleType() == SCHEDULE_TYPE);
		Assert.assertTrue(maintenanceEventSelectID.isDisabled() == DISABLED);
		Assert.assertTrue(maintenanceEventSelectID.getActiveYear() == ACTIVE_YEAR);
		Assert.assertTrue(maintenanceEventSelectID.getActiveMonth() == ACTIVE_MONTH);
		Assert.assertTrue(maintenanceEventSelectID.getActiveDay() == ACTIVE_DAY);
		Assert.assertTrue(maintenanceEventSelectID.getActiveHour() == ACTIVE_HOUR);
		Assert.assertTrue(maintenanceEventSelectID.getActiveMinute() == ACTIVE_MINUTE);
		Assert.assertTrue(maintenanceEventSelectID.getActiveSecond() == ACTIVE_SECOND);
		Assert.assertTrue(maintenanceEventSelectID.getActiveCron().equals(ACTIVE_CRON));
		Assert.assertTrue(maintenanceEventSelectID.getInactiveYear() == INACTIVE_YEAR);
		Assert.assertTrue(maintenanceEventSelectID.getInactiveMonth() == INACTIVE_MONTH);
		Assert.assertTrue(maintenanceEventSelectID.getInactiveDay() == INACTIVE_DAY);
		Assert.assertTrue(maintenanceEventSelectID.getInactiveHour() == INACTIVE_HOUR);
		Assert.assertTrue(maintenanceEventSelectID.getInactiveMinute() == INACTIVE_MINUTE);
		Assert.assertTrue(maintenanceEventSelectID.getInactiveSecond() == INACTIVE_SECOND);
		Assert.assertTrue(maintenanceEventSelectID.getInactiveCron().equals(INACTIVE_CRON));

		//Select single object by XID
		MaintenanceEventVO maintenanceEventSelectXID = maintenanceEventDAO.getMaintenanceEvent(secondMaintenanceEventVO.getXid());
		Assert.assertTrue(maintenanceEventSelectXID.getId() == secondId);
		Assert.assertTrue(maintenanceEventSelectXID.getXid().equals(SECOND_XID));
		Assert.assertTrue(maintenanceEventSelectXID.getDataSourceId() == SECOND_DATA_SOURCE_ID);
		Assert.assertTrue(maintenanceEventSelectXID.getAlias().equals(SECOND_ALIAS));
		Assert.assertTrue(maintenanceEventSelectXID.getAlarmLevel() == SECOND_ALARM_LEVEL);
		Assert.assertTrue(maintenanceEventSelectXID.getScheduleType() == SECOND_SCHEDULE_TYPE);
//		assertTrue(maintenanceEventSelectXID.isDisabled() == SECOND_DISABLED);
		Assert.assertTrue(maintenanceEventSelectXID.getActiveYear() == SECOND_ACTIVE_YEAR);
		Assert.assertTrue(maintenanceEventSelectXID.getActiveMonth() == SECOND_ACTIVE_MONTH);
		Assert.assertTrue(maintenanceEventSelectXID.getActiveDay() == SECOND_ACTIVE_DAY);
		Assert.assertTrue(maintenanceEventSelectXID.getActiveHour() == SECOND_ACTIVE_HOUR);
		Assert.assertTrue(maintenanceEventSelectXID.getActiveMinute() == SECOND_ACTIVE_MINUTE);
		Assert.assertTrue(maintenanceEventSelectXID.getActiveSecond() == SECOND_ACTIVE_SECOND);
		Assert.assertTrue(maintenanceEventSelectXID.getActiveCron().equals(SECOND_ACTIVE_CRON));
		Assert.assertTrue(maintenanceEventSelectXID.getInactiveYear() == SECOND_INACTIVE_YEAR);
		Assert.assertTrue(maintenanceEventSelectXID.getInactiveMonth() == SECOND_INACTIVE_MONTH);
		Assert.assertTrue(maintenanceEventSelectXID.getInactiveDay() == SECOND_INACTIVE_DAY);
		Assert.assertTrue(maintenanceEventSelectXID.getInactiveHour() == SECOND_INACTIVE_HOUR);
		Assert.assertTrue(maintenanceEventSelectXID.getInactiveMinute() == SECOND_INACTIVE_MINUTE);
		Assert.assertTrue(maintenanceEventSelectXID.getInactiveSecond() == SECOND_INACTIVE_SECOND);
		Assert.assertTrue(maintenanceEventSelectXID.getInactiveCron().equals(SECOND_INACTIVE_CRON));

		//Select all objects
		List<MaintenanceEventVO> maintenanceEventVOList = maintenanceEventDAO.getMaintenanceEvents();
		//Check list size
		Assert.assertTrue(maintenanceEventVOList.size() == LIST_SIZE);
		//Check IDs
		Assert.assertTrue(maintenanceEventVOList.get(0).getId() == firstId);
		Assert.assertTrue(maintenanceEventVOList.get(1).getId() == secondId);

		//Update
		MaintenanceEventVO maintenanceEventUpdate = new MaintenanceEventVO();
		maintenanceEventUpdate.setId(firstId);
		maintenanceEventUpdate.setXid(UPDATE_XID);
		maintenanceEventUpdate.setDataSourceId(UPDATE_DATA_SOURCE_ID);
		maintenanceEventUpdate.setAlias(UPDATE_ALIAS);
		maintenanceEventUpdate.setAlarmLevel(UPDATE_ALARM_LEVEL);
		maintenanceEventUpdate.setScheduleType(UPDATE_SCHEDULE_TYPE);
		maintenanceEventUpdate.setDisabled(UPDATE_DISABLED);
		maintenanceEventUpdate.setActiveYear(UPDATE_ACTIVE_YEAR);
		maintenanceEventUpdate.setActiveMonth(UPDATE_ACTIVE_MONTH);
		maintenanceEventUpdate.setActiveDay(UPDATE_ACTIVE_DAY);
		maintenanceEventUpdate.setActiveHour(UPDATE_ACTIVE_HOUR);
		maintenanceEventUpdate.setActiveMinute(UPDATE_ACTIVE_MINUTE);
		maintenanceEventUpdate.setActiveSecond(UPDATE_ACTIVE_SECOND);
		maintenanceEventUpdate.setActiveCron(UPDATE_ACTIVE_CRON);
		maintenanceEventUpdate.setInactiveYear(UPDATE_INACTIVE_YEAR);
		maintenanceEventUpdate.setInactiveMonth(UPDATE_INACTIVE_MONTH);
		maintenanceEventUpdate.setInactiveDay(UPDATE_INACTIVE_DAY);
		maintenanceEventUpdate.setInactiveHour(UPDATE_INACTIVE_HOUR);
		maintenanceEventUpdate.setInactiveMinute(UPDATE_INACTIVE_MINUTE);
		maintenanceEventUpdate.setInactiveSecond(UPDATE_INACTIVE_SECOND);
		maintenanceEventUpdate.setInactiveCron(UPDATE_INACTIVE_CRON);

		maintenanceEventDAO.update(maintenanceEventUpdate);

		//Delete
		maintenanceEventDAO.delete(firstId);
		try{
			maintenanceEventDAO.getMaintenanceEvent(firstId);
		} catch(Exception e){
			Assert.assertTrue(e.getClass().equals(EmptyResultDataAccessException.class));
			Assert.assertTrue(e.getMessage().equals("Incorrect result size: expected 1, actual 0"));
		}
	}
}
