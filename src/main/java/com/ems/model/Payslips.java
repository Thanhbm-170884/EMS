package com.ems.model;

// Model được tự động sinh từ bảng 'payslips'
public class Payslips {

    private Integer id;
    private Integer userid;
    private Integer periodid;
    private Integer standardworkdays;
    private java.math.BigDecimal actualworkdays;
    private java.math.BigDecimal basesalary;
    private java.math.BigDecimal actualbasesalary;
    private java.math.BigDecimal totalallowanceamount;
    private java.math.BigDecimal bonusamount;
    private java.math.BigDecimal grossamount;
    private java.math.BigDecimal bhxhamount;
    private java.math.BigDecimal bhytamount;
    private java.math.BigDecimal bhtnamount;
    private java.math.BigDecimal totalinsurancededuction;
    private java.math.BigDecimal employerBhxhAmount;
    private java.math.BigDecimal employerBhtnldAmount;
    private java.math.BigDecimal employerBhytAmount;
    private java.math.BigDecimal employerBhtnAmount;
    private java.math.BigDecimal totalEmployerCost;
    private Integer dependentscount;
    private java.math.BigDecimal dependentdeduction;
    private java.math.BigDecimal taxableincome;
    private java.math.BigDecimal taxdeduction;
    private java.math.BigDecimal netamount;
    private String status;
    private String note;
    private Integer adjustedbyaccountid;
    private java.time.LocalDateTime createdat;
    private java.time.LocalDateTime updatedat;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    
    public Integer getUserid() { return userid; }
    public void setUserid(Integer userid) { this.userid = userid; }
    
    public Integer getPeriodid() { return periodid; }
    public void setPeriodid(Integer periodid) { this.periodid = periodid; }
    
    public Integer getStandardworkdays() { return standardworkdays; }
    public void setStandardworkdays(Integer standardworkdays) { this.standardworkdays = standardworkdays; }
    
    public java.math.BigDecimal getActualworkdays() { return actualworkdays; }
    public void setActualworkdays(java.math.BigDecimal actualworkdays) { this.actualworkdays = actualworkdays; }
    
    public java.math.BigDecimal getBasesalary() { return basesalary; }
    public void setBasesalary(java.math.BigDecimal basesalary) { this.basesalary = basesalary; }
    
    public java.math.BigDecimal getActualbasesalary() { return actualbasesalary; }
    public void setActualbasesalary(java.math.BigDecimal actualbasesalary) { this.actualbasesalary = actualbasesalary; }
    
    public java.math.BigDecimal getTotalallowanceamount() { return totalallowanceamount; }
    public void setTotalallowanceamount(java.math.BigDecimal totalallowanceamount) { this.totalallowanceamount = totalallowanceamount; }
    
    public java.math.BigDecimal getBonusamount() { return bonusamount; }
    public void setBonusamount(java.math.BigDecimal bonusamount) { this.bonusamount = bonusamount; }
    
    public java.math.BigDecimal getGrossamount() { return grossamount; }
    public void setGrossamount(java.math.BigDecimal grossamount) { this.grossamount = grossamount; }
    
    public java.math.BigDecimal getBhxhamount() { return bhxhamount; }
    public void setBhxhamount(java.math.BigDecimal bhxhamount) { this.bhxhamount = bhxhamount; }
    
    public java.math.BigDecimal getBhytamount() { return bhytamount; }
    public void setBhytamount(java.math.BigDecimal bhytamount) { this.bhytamount = bhytamount; }
    
    public java.math.BigDecimal getBhtnamount() { return bhtnamount; }
    public void setBhtnamount(java.math.BigDecimal bhtnamount) { this.bhtnamount = bhtnamount; }
    
    public java.math.BigDecimal getTotalinsurancededuction() { return totalinsurancededuction; }
    public void setTotalinsurancededuction(java.math.BigDecimal totalinsurancededuction) { this.totalinsurancededuction = totalinsurancededuction; }

    public java.math.BigDecimal getEmployerBhxhAmount() { return employerBhxhAmount; }
    public void setEmployerBhxhAmount(java.math.BigDecimal employerBhxhAmount) { this.employerBhxhAmount = employerBhxhAmount; }

    public java.math.BigDecimal getEmployerBhtnldAmount() { return employerBhtnldAmount; }
    public void setEmployerBhtnldAmount(java.math.BigDecimal employerBhtnldAmount) { this.employerBhtnldAmount = employerBhtnldAmount; }

    public java.math.BigDecimal getEmployerBhytAmount() { return employerBhytAmount; }
    public void setEmployerBhytAmount(java.math.BigDecimal employerBhytAmount) { this.employerBhytAmount = employerBhytAmount; }

    public java.math.BigDecimal getEmployerBhtnAmount() { return employerBhtnAmount; }
    public void setEmployerBhtnAmount(java.math.BigDecimal employerBhtnAmount) { this.employerBhtnAmount = employerBhtnAmount; }

    public java.math.BigDecimal getTotalEmployerCost() { return totalEmployerCost; }
    public void setTotalEmployerCost(java.math.BigDecimal totalEmployerCost) { this.totalEmployerCost = totalEmployerCost; }
    
    public Integer getDependentscount() { return dependentscount; }
    public void setDependentscount(Integer dependentscount) { this.dependentscount = dependentscount; }
    
    public java.math.BigDecimal getDependentdeduction() { return dependentdeduction; }
    public void setDependentdeduction(java.math.BigDecimal dependentdeduction) { this.dependentdeduction = dependentdeduction; }
    
    public java.math.BigDecimal getTaxableincome() { return taxableincome; }
    public void setTaxableincome(java.math.BigDecimal taxableincome) { this.taxableincome = taxableincome; }
    
    public java.math.BigDecimal getTaxdeduction() { return taxdeduction; }
    public void setTaxdeduction(java.math.BigDecimal taxdeduction) { this.taxdeduction = taxdeduction; }
    
    public java.math.BigDecimal getNetamount() { return netamount; }
    public void setNetamount(java.math.BigDecimal netamount) { this.netamount = netamount; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    
    public Integer getAdjustedbyaccountid() { return adjustedbyaccountid; }
    public void setAdjustedbyaccountid(Integer adjustedbyaccountid) { this.adjustedbyaccountid = adjustedbyaccountid; }
    
    public java.time.LocalDateTime getCreatedat() { return createdat; }
    public void setCreatedat(java.time.LocalDateTime createdat) { this.createdat = createdat; }
    
    public java.time.LocalDateTime getUpdatedat() { return updatedat; }
    public void setUpdatedat(java.time.LocalDateTime updatedat) { this.updatedat = updatedat; }
}
