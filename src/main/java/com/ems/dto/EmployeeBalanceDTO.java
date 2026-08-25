package com.ems.dto;

import java.math.BigDecimal;

public class EmployeeBalanceDTO {
    private int userId;
    private String employeeName;
    private String departmentName;
    private int totalDays;
    private int usedDays;
    private int remainingDays;
    private double advancedThisMonth;
    private double baseSalary;

    public EmployeeBalanceDTO() {
    }

    public EmployeeBalanceDTO(int userId, String employeeName, String departmentName,
            int totalDays, int usedDays, int remainingDays, double advancedThisMonth, double baseSalary) {
        this.userId = userId;
        this.employeeName = employeeName;
        this.departmentName = departmentName;
        this.totalDays = totalDays;
        this.usedDays = usedDays;
        this.remainingDays = remainingDays;
        this.advancedThisMonth = advancedThisMonth;
        this.baseSalary = baseSalary;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getEmployeeName() {
        return employeeName;
    }

    public void setEmployeeName(String employeeName) {
        this.employeeName = employeeName;
    }

    public String getDepartmentName() {
        return departmentName;
    }

    public void setDepartmentName(String departmentName) {
        this.departmentName = departmentName;
    }

    public int getTotalDays() {
        return totalDays;
    }

    public void setTotalDays(int totalDays) {
        this.totalDays = totalDays;
    }

    public int getUsedDays() {
        return usedDays;
    }

    public void setUsedDays(int usedDays) {
        this.usedDays = usedDays;
    }

    public int getRemainingDays() {
        return remainingDays;
    }

    public void setRemainingDays(int remainingDays) {
        this.remainingDays = remainingDays;
    }

    public double getAdvancedThisMonth() {
        return advancedThisMonth;
    }

    public void setAdvancedThisMonth(double advancedThisMonth) {
        this.advancedThisMonth = advancedThisMonth;
    }

    public double getBaseSalary() {
        return baseSalary;
    }

    public void setBaseSalary(double baseSalary) {
        this.baseSalary = baseSalary;
    }
}
