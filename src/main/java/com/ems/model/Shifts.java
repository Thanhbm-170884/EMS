package com.ems.model;

// Model được tự động sinh từ bảng 'shifts'
public class Shifts {

    private Integer id;
    private String name;
    private java.time.LocalTime starttime;
    private java.time.LocalTime endtime;
    private java.time.LocalTime breakstart;
    private java.time.LocalTime breakend;
    private Integer latetoleranceminute;
    private Integer earlycheckinminute;
    private Integer latecheckoutminute;
    private Boolean isactive;
    private Boolean isDefault;
    private java.time.LocalDate effectiveStartDate;
    private java.time.LocalDate effectiveEndDate;

    public Boolean getDefault() {
        return isDefault;
    }

    public void setDefault(Boolean aDefault) {
        isDefault = aDefault;
    }

    public java.time.LocalDate getEffectiveStartDate() {
        return effectiveStartDate;
    }

    public void setEffectiveStartDate(java.time.LocalDate effectiveStartDate) {
        this.effectiveStartDate = effectiveStartDate;
    }

    public java.time.LocalDate getEffectiveEndDate() {
        return effectiveEndDate;
    }

    public void setEffectiveEndDate(java.time.LocalDate effectiveEndDate) {
        this.effectiveEndDate = effectiveEndDate;
    }

    public int getDayOfweek() {
        return dayOfweek;
    }

    public void setDayOfweek(int dayOfweek) {
        this.dayOfweek = dayOfweek;
    }

    private int dayOfweek;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public java.time.LocalTime getStarttime() {
        return starttime;
    }

    public void setStarttime(java.time.LocalTime starttime) {
        this.starttime = starttime;
    }

    public java.time.LocalTime getEndtime() {
        return endtime;
    }

    public void setEndtime(java.time.LocalTime endtime) {
        this.endtime = endtime;
    }

    public java.time.LocalTime getBreakstart() {
        return breakstart;
    }

    public void setBreakstart(java.time.LocalTime breakstart) {
        this.breakstart = breakstart;
    }

    public java.time.LocalTime getBreakend() {
        return breakend;
    }

    public void setBreakend(java.time.LocalTime breakend) {
        this.breakend = breakend;
    }

    public Integer getLatetoleranceminute() {
        return latetoleranceminute;
    }

    public void setLatetoleranceminute(Integer latetoleranceminute) {
        this.latetoleranceminute = latetoleranceminute;
    }

    public Integer getEarlycheckinminute() {
        return earlycheckinminute;
    }

    public void setEarlycheckinminute(Integer earlycheckinminute) {
        this.earlycheckinminute = earlycheckinminute;
    }

    public Integer getLatecheckoutminute() {
        return latecheckoutminute;
    }

    public void setLatecheckoutminute(Integer latecheckoutminute) {
        this.latecheckoutminute = latecheckoutminute;
    }

    public Boolean getIsactive() {
        return isactive;
    }

    public void setIsactive(Boolean isactive) {
        this.isactive = isactive;
    }
}
