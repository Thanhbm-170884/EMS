package com.ems.dto;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class PayslipDTO {

    private int id;
    private int periodId;
    private String status;

    private String employeeCode;
    private String fullName;
    private String departmentName;
    private String positionName;

    private int standardWorkDays;
    private BigDecimal actualWorkDays;

    private BigDecimal baseSalary;
    private BigDecimal actualBaseSalary;
    private BigDecimal bonusAmount;
    
    private Integer dependentsCount;
    private BigDecimal dependentDeduction;
    private BigDecimal taxableIncome;
    
    private BigDecimal bhxh;
    private BigDecimal bhyt;
    private BigDecimal bhtn;

    private BigDecimal grossAmount;
    private BigDecimal totalInsurance;
    private BigDecimal taxDeduction;
    private BigDecimal netAmount;

    private BigDecimal employerBhxhAmount;
    private BigDecimal employerBhtnldAmount;
    private BigDecimal employerBhytAmount;
    private BigDecimal employerBhtnAmount;
    private BigDecimal totalEmployerCost;

    private List<AllowanceDetailDTO> allowanceDetails = new ArrayList<>();

    public PayslipDTO() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getPeriodId() { return periodId; }
    public void setPeriodId(int periodId) { this.periodId = periodId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getEmployeeCode() { return employeeCode; }
    public void setEmployeeCode(String employeeCode) { this.employeeCode = employeeCode; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getDepartmentName() { return departmentName; }
    public void setDepartmentName(String departmentName) { this.departmentName = departmentName; }
    public String getPositionName() { return positionName; }
    public void setPositionName(String positionName) { this.positionName = positionName; }

    public int getStandardWorkDays() { return standardWorkDays; }
    public void setStandardWorkDays(int standardWorkDays) { this.standardWorkDays = standardWorkDays; }
    public BigDecimal getActualWorkDays() { return actualWorkDays; }
    public void setActualWorkDays(BigDecimal actualWorkDays) { this.actualWorkDays = actualWorkDays; }

    public BigDecimal getBaseSalary() { return baseSalary; }
    public void setBaseSalary(BigDecimal baseSalary) { this.baseSalary = baseSalary; }
    public BigDecimal getActualBaseSalary() { return actualBaseSalary; }
    public void setActualBaseSalary(BigDecimal actualBaseSalary) { this.actualBaseSalary = actualBaseSalary; }
    public BigDecimal getBonusAmount() { return bonusAmount; }
    public void setBonusAmount(BigDecimal bonusAmount) { this.bonusAmount = bonusAmount; }

    public Integer getDependentsCount() { return dependentsCount; }
    public void setDependentsCount(Integer dependentsCount) { this.dependentsCount = dependentsCount; }
    public BigDecimal getDependentDeduction() { return dependentDeduction; }
    public void setDependentDeduction(BigDecimal dependentDeduction) { this.dependentDeduction = dependentDeduction; }
    public BigDecimal getTaxableIncome() { return taxableIncome; }
    public void setTaxableIncome(BigDecimal taxableIncome) { this.taxableIncome = taxableIncome; }

    public BigDecimal getBhxh() { return bhxh; }
    public void setBhxh(BigDecimal bhxh) { this.bhxh = bhxh; }
    public BigDecimal getBhyt() { return bhyt; }
    public void setBhyt(BigDecimal bhyt) { this.bhyt = bhyt; }
    public BigDecimal getBhtn() { return bhtn; }
    public void setBhtn(BigDecimal bhtn) { this.bhtn = bhtn; }

    public BigDecimal getGrossAmount() { return grossAmount; }
    public void setGrossAmount(BigDecimal grossAmount) { this.grossAmount = grossAmount; }
    public BigDecimal getTotalInsurance() { return totalInsurance; }
    public void setTotalInsurance(BigDecimal totalInsurance) { this.totalInsurance = totalInsurance; }
    public BigDecimal getTaxDeduction() { return taxDeduction; }
    public void setTaxDeduction(BigDecimal taxDeduction) { this.taxDeduction = taxDeduction; }
    public BigDecimal getNetAmount() { return netAmount; }
    public void setNetAmount(BigDecimal netAmount) { this.netAmount = netAmount; }

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

    public List<AllowanceDetailDTO> getAllowanceDetails() { return allowanceDetails; }
    public void setAllowanceDetails(List<AllowanceDetailDTO> allowanceDetails) { this.allowanceDetails = allowanceDetails; }

    public void addAllowanceDetail(AllowanceDetailDTO detail) {
        this.allowanceDetails.add(detail);
    }
    
    private String note;
    public String getNote() {
        return note;
    }
    public void setNote(String note) {
        this.note = note;
    }

    private String periodName;
    public String getPeriodName() {
        return periodName;
    }
    public void setPeriodName(String periodName) {
        this.periodName = periodName;
    }

}

