package com.ems.model;

// Model được tự động sinh từ bảng 'payrollconfigs'
public class Payrollconfigs {

    private Integer id;
    private String configname;
    private java.time.LocalDate effectivedate;
    private java.math.BigDecimal bhxhpercent;
    private java.math.BigDecimal bhytpercent;
    private java.math.BigDecimal bhtnpercent;
    private java.math.BigDecimal employerbhxhpercent;
    private java.math.BigDecimal employerbhtnldpercent;
    private java.math.BigDecimal employerbhytpercent;
    private java.math.BigDecimal employerbhtnpercent;
    private java.math.BigDecimal maxinsurancesalary;
    private java.math.BigDecimal personaltaxdeduction;
    private java.math.BigDecimal dependenttaxdeduction;
    private Integer standardworkingdays;
    private Boolean isactive;
    private Integer createdbyaccountid;
    private java.time.LocalDateTime createdat;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getConfigname() {
        return configname;
    }

    public void setConfigname(String configname) {
        this.configname = configname;
    }

    public java.time.LocalDate getEffectivedate() {
        return effectivedate;
    }

    public void setEffectivedate(java.time.LocalDate effectivedate) {
        this.effectivedate = effectivedate;
    }

    public java.math.BigDecimal getBhxhpercent() {
        return bhxhpercent;
    }

    public void setBhxhpercent(java.math.BigDecimal bhxhpercent) {
        this.bhxhpercent = bhxhpercent;
    }

    public java.math.BigDecimal getBhytpercent() {
        return bhytpercent;
    }

    public void setBhytpercent(java.math.BigDecimal bhytpercent) {
        this.bhytpercent = bhytpercent;
    }

    public java.math.BigDecimal getBhtnpercent() {
        return bhtnpercent;
    }

    public void setBhtnpercent(java.math.BigDecimal bhtnpercent) {
        this.bhtnpercent = bhtnpercent;
    }

    public java.math.BigDecimal getEmployerbhxhpercent() { return employerbhxhpercent; }
    public void setEmployerbhxhpercent(java.math.BigDecimal employerbhxhpercent) { this.employerbhxhpercent = employerbhxhpercent; }

    public java.math.BigDecimal getEmployerbhtnldpercent() { return employerbhtnldpercent; }
    public void setEmployerbhtnldpercent(java.math.BigDecimal employerbhtnldpercent) { this.employerbhtnldpercent = employerbhtnldpercent; }

    public java.math.BigDecimal getEmployerbhytpercent() { return employerbhytpercent; }
    public void setEmployerbhytpercent(java.math.BigDecimal employerbhytpercent) { this.employerbhytpercent = employerbhytpercent; }

    public java.math.BigDecimal getEmployerbhtnpercent() { return employerbhtnpercent; }
    public void setEmployerbhtnpercent(java.math.BigDecimal employerbhtnpercent) { this.employerbhtnpercent = employerbhtnpercent; }

    public java.math.BigDecimal getMaxinsurancesalary() {
        return maxinsurancesalary;
    }

    public void setMaxinsurancesalary(java.math.BigDecimal maxinsurancesalary) {
        this.maxinsurancesalary = maxinsurancesalary;
    }

    public java.math.BigDecimal getPersonaltaxdeduction() {
        return personaltaxdeduction;
    }

    public void setPersonaltaxdeduction(java.math.BigDecimal personaltaxdeduction) {
        this.personaltaxdeduction = personaltaxdeduction;
    }

    public java.math.BigDecimal getDependenttaxdeduction() {
        return dependenttaxdeduction;
    }

    public void setDependenttaxdeduction(java.math.BigDecimal dependenttaxdeduction) {
        this.dependenttaxdeduction = dependenttaxdeduction;
    }

    public Integer getStandardworkingdays() {
        return standardworkingdays;
    }

    public void setStandardworkingdays(Integer standardworkingdays) {
        this.standardworkingdays = standardworkingdays;
    }
    
    public Boolean getIsactive() {
        return isactive;
    }

    public void setIsactive(Boolean isactive) {
        this.isactive = isactive;
    }

    public Integer getCreatedbyaccountid() {
        return createdbyaccountid;
    }

    public void setCreatedbyaccountid(Integer createdbyaccountid) {
        this.createdbyaccountid = createdbyaccountid;
    }

    public java.time.LocalDateTime getCreatedat() {
        return createdat;
    }

    public void setCreatedat(java.time.LocalDateTime createdat) {
        this.createdat = createdat;
    }
}
