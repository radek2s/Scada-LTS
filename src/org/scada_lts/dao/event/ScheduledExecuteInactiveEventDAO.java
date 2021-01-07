package org.scada_lts.dao.event;

import org.springframework.jdbc.core.JdbcTemplate;

import java.util.List;

public interface ScheduledExecuteInactiveEventDAO {

    List<ScheduledExecuteInactiveEvent> select();
    List<ScheduledExecuteInactiveEvent> select(int mailingListId);
    ScheduledExecuteInactiveEvent insert(ScheduledExecuteInactiveEvent scheduledInactiveCommunicationEvent);
    void delete(ScheduledExecuteInactiveEvent scheduledInactiveCommunicationEvent);

    static ScheduledExecuteInactiveEventDAO getInstance() {
        return ScheduledExecuteInactiveEventDAOimpl.getInstance();
    }

    static ScheduledExecuteInactiveEventDAO newInstance(JdbcTemplate jdbcTemplate) {
        return new ScheduledExecuteInactiveEventDAOimpl(jdbcTemplate);
    }

}
