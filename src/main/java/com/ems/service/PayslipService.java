package com.ems.service;

import com.ems.dao.BaseSalaryDAO;
import com.ems.dao.PayslipDAO;
import com.ems.dto.ManagerPayslipDTO;
import com.ems.dto.PayslipDTO;
import com.ems.model.Departments;
import com.ems.model.Timesheetperiods;

import java.util.List;

public class PayslipService {

    private final PayslipDAO payslipDAO;
    private final BaseSalaryDAO baseSalaryDAO;

    public PayslipService() {
        this.payslipDAO = new PayslipDAO();
        this.baseSalaryDAO = new BaseSalaryDAO();
    }

    public PayslipService(PayslipDAO payslipDAO, BaseSalaryDAO baseSalaryDAO) {
        this.payslipDAO = payslipDAO;
        this.baseSalaryDAO = baseSalaryDAO;
    }

    public List<Timesheetperiods> getAllTimesheetPeriods() {
        return payslipDAO.getAllTimesheetPeriods();
    }

    public List<ManagerPayslipDTO> getPayslipsByPeriod(Integer periodId, String search, Integer departmentId) {
        return payslipDAO.getPayslipsByPeriod(periodId, search, departmentId);
    }

    public List<Departments> getAllDepartments() {
        return baseSalaryDAO.getAllDepartments();
    }

    public List<PayslipDTO> getPayslipsByUserId(int userId) {
        return payslipDAO.getPayslipsByUserId(userId);
    }
}

