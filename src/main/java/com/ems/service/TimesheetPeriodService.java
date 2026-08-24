package com.ems.service;

import com.ems.dao.TimesheetPeriodDAO;
import com.ems.dto.TimesheetPeriodDTO;

import java.util.List;

public class TimesheetPeriodService {
    private final TimesheetPeriodDAO periodDAO = new TimesheetPeriodDAO();

    public List<TimesheetPeriodDTO> getAllPeriods() {
        return periodDAO.getAllPeriods();
    }

    public List<TimesheetPeriodDTO> getPeriods(String search, String statusFilter, String sortBy, String sortOrder) {
        return periodDAO.getPeriods(search, statusFilter, sortBy, sortOrder);
    }

    public TimesheetPeriodDTO getPeriodById(int id) {
        return periodDAO.getPeriodById(id);
    }

    public boolean createPeriod(TimesheetPeriodDTO period) {
        return periodDAO.createPeriod(period);
    }

    public boolean updatePeriod(TimesheetPeriodDTO period) {
        return periodDAO.updatePeriod(period);
    }

    public boolean deletePeriod(int id) {
        return periodDAO.deletePeriod(id);
    }

    public boolean hasAssociatedPayslips(int id) {
        return periodDAO.hasAssociatedPayslips(id);
    }

    public boolean toggleLockStatus(int id) {
        TimesheetPeriodDTO period = periodDAO.getPeriodById(id);
        if (period == null) return false;
        return periodDAO.updatePeriodLockStatus(id, !period.isLocked());
    }

    public boolean updatePeriodLockStatus(int id, boolean isLocked) {
        return periodDAO.updatePeriodLockStatus(id, isLocked);
    }

    public boolean isDuplicatePeriod(String name, java.sql.Date startDate, java.sql.Date endDate, Integer excludeId) {
        return periodDAO.isDuplicatePeriod(name, startDate, endDate, excludeId);
    }

    public int getTotalPeriodsCount() {
        return periodDAO.getTotalPeriodsCount();
    }

    public int getActivePeriodsCount() {
        return periodDAO.getActivePeriodsCount();
    }

    public int getLockedPeriodsCount() {
        return periodDAO.getLockedPeriodsCount();
    }
}

