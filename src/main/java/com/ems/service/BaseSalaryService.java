package com.ems.service;

import com.ems.dao.BaseSalaryDAO;
import com.ems.dto.BaseSalaryDTO;
import com.ems.dto.SalarySummaryDTO;
import com.ems.model.Departments;
import com.ems.model.Positions;

import java.util.List;

public class BaseSalaryService {

    private final BaseSalaryDAO baseSalaryDAO;

    public BaseSalaryService() {
        this.baseSalaryDAO = new BaseSalaryDAO();
    }

    public BaseSalaryService(BaseSalaryDAO baseSalaryDAO) {
        this.baseSalaryDAO = baseSalaryDAO;
    }

    public List<BaseSalaryDTO> getBaseSalaries(String search, Integer departmentId, Integer positionId, String sortBy, String sortOrder) {
        if (sortBy == null || sortBy.trim().isEmpty()) {
            sortBy = "code";
        }
        if (sortOrder == null || sortOrder.trim().isEmpty()) {
            sortOrder = "ASC";
        }
        return baseSalaryDAO.getBaseSalaries(search, departmentId, positionId, sortBy, sortOrder);
    }

    public SalarySummaryDTO getSalarySummary(String search, Integer departmentId, Integer positionId) {
        return baseSalaryDAO.getSalarySummary(search, departmentId, positionId);
    }

    public List<Departments> getAllDepartments() {
        return baseSalaryDAO.getAllDepartments();
    }

    public List<Positions> getAllPositions() {
        return baseSalaryDAO.getAllPositions();
    }

    public int getTotalEmployeeCount() {
        return baseSalaryDAO.getTotalEmployeeCount();
    }

    public boolean updateBaseSalary(int userId, java.math.BigDecimal baseSalary) {
        return baseSalaryDAO.updateBaseSalary(userId, baseSalary);
    }
}
