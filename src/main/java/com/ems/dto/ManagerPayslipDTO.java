package com.ems.dto;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.time.LocalDateTime;

public class ManagerPayslipDTO {

    private Integer id;
    private Integer userId;
    private String employeeCode;
    private String fullName;
    private String departmentName;
    private String positionName;

    private Integer periodId;
    private String periodName;

    private BigDecimal baseSalary;
    private BigDecimal otSalary;
    private BigDecimal allowances;
    private BigDecimal insuranceDeduction;
    private BigDecimal dependentDeduction;
    private BigDecimal taxDeduction;
    private BigDecimal otherDeductions;

    private BigDecimal employerBhxhAmount;
    private BigDecimal employerBhtnldAmount;
    private BigDecimal employerBhytAmount;
    private BigDecimal employerBhtnAmount;
    private BigDecimal totalEmployerCost;

    private BigDecimal grossAmount;
    private BigDecimal netAmount;
    private String status;
    private String note;
    private LocalDateTime createdAt;

    // Formatting helper
    private String formatCurrency(BigDecimal amount) {
        if (amount == null)
            return "0";
        DecimalFormat formatter = new DecimalFormat("#,###");
        return formatter.format(amount).replace(',', '.');
    }

    public String getFormattedBaseSalary() {
        return formatCurrency(baseSalary);
    }

    public String getFormattedOtSalary() {
        return formatCurrency(otSalary);
    }

    public String getFormattedAllowances() {
        return formatCurrency(allowances);
    }

    public String getFormattedInsuranceDeduction() {
        return formatCurrency(insuranceDeduction);
    }

    public String getFormattedDependentDeduction() {
        return formatCurrency(dependentDeduction);
    }

    public String getFormattedTaxDeduction() {
        return formatCurrency(taxDeduction);
    }

    public String getFormattedOtherDeductions() {
        return formatCurrency(otherDeductions);
    }

    public String getFormattedGrossAmount() {
        return formatCurrency(grossAmount);
    }

    public String getFormattedNetAmount() {
        return formatCurrency(netAmount);
    }

    public BigDecimal getTotalDeductions() {
        BigDecimal total = BigDecimal.ZERO;
        if (insuranceDeduction != null)
            total = total.add(insuranceDeduction);
        if (taxDeduction != null)
            total = total.add(taxDeduction);
        if (otherDeductions != null)
            total = total.add(otherDeductions);
        return total;
    }

    public String getFormattedTotalDeductions() {
        return formatCurrency(getTotalDeductions());
    }

    public BigDecimal getTotalAdditions() {
        BigDecimal total = BigDecimal.ZERO;
        if (otSalary != null)
            total = total.add(otSalary);
        if (allowances != null)
            total = total.add(allowances);
        return total;
    }

    public String getFormattedTotalAdditions() {
        return formatCurrency(getTotalAdditions());
    }

    // Getters and Setters
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getEmployeeCode() {
        return employeeCode;
    }

    public void setEmployeeCode(String employeeCode) {
        this.employeeCode = employeeCode;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getDepartmentName() {
        return departmentName;
    }

    public void setDepartmentName(String departmentName) {
        this.departmentName = departmentName;
    }

    public String getPositionName() {
        return positionName;
    }

    public void setPositionName(String positionName) {
        this.positionName = positionName;
    }

    public Integer getPeriodId() {
        return periodId;
    }

    public void setPeriodId(Integer periodId) {
        this.periodId = periodId;
    }

    public String getPeriodName() {
        return periodName;
    }

    public void setPeriodName(String periodName) {
        this.periodName = periodName;
    }

    public BigDecimal getBaseSalary() {
        return baseSalary;
    }

    public void setBaseSalary(BigDecimal baseSalary) {
        this.baseSalary = baseSalary;
    }

    public BigDecimal getOtSalary() {
        return otSalary;
    }

    public void setOtSalary(BigDecimal otSalary) {
        this.otSalary = otSalary;
    }

    public BigDecimal getAllowances() {
        return allowances;
    }

    public void setAllowances(BigDecimal allowances) {
        this.allowances = allowances;
    }

    public BigDecimal getInsuranceDeduction() {
        return insuranceDeduction;
    }

    public void setInsuranceDeduction(BigDecimal insuranceDeduction) {
        this.insuranceDeduction = insuranceDeduction;
    }

    public BigDecimal getDependentDeduction() {
        return dependentDeduction;
    }

    public void setDependentDeduction(BigDecimal dependentDeduction) {
        this.dependentDeduction = dependentDeduction;
    }

    public BigDecimal getTaxDeduction() {
        return taxDeduction;
    }

    public void setTaxDeduction(BigDecimal taxDeduction) {
        this.taxDeduction = taxDeduction;
    }

    public BigDecimal getOtherDeductions() {
        return otherDeductions;
    }

    public void setOtherDeductions(BigDecimal otherDeductions) {
        this.otherDeductions = otherDeductions;
    }

    public BigDecimal getEmployerBhxhAmount() { return employerBhxhAmount; }
    public void setEmployerBhxhAmount(BigDecimal employerBhxhAmount) { this.employerBhxhAmount = employerBhxhAmount; }
    public BigDecimal getEmployerBhtnldAmount() { return employerBhtnldAmount; }
    public void setEmployerBhtnldAmount(BigDecimal employerBhtnldAmount) { this.employerBhtnldAmount = employerBhtnldAmount; }
    public BigDecimal getEmployerBhytAmount() { return employerBhytAmount; }
    public void setEmployerBhytAmount(BigDecimal employerBhytAmount) { this.employerBhytAmount = employerBhytAmount; }
    public BigDecimal getEmployerBhtnAmount() { return employerBhtnAmount; }
    public void setEmployerBhtnAmount(BigDecimal employerBhtnAmount) { this.employerBhtnAmount = employerBhtnAmount; }
    public BigDecimal getTotalEmployerCost() { return totalEmployerCost; }
    public void setTotalEmployerCost(BigDecimal totalEmployerCost) { this.totalEmployerCost = totalEmployerCost; }

    public BigDecimal getGrossAmount() {
        return grossAmount;
    }

    public void setGrossAmount(BigDecimal grossAmount) {
        this.grossAmount = grossAmount;
    }

    public BigDecimal getNetAmount() {
        return netAmount;
    }

    public void setNetAmount(BigDecimal netAmount) {
        this.netAmount = netAmount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
