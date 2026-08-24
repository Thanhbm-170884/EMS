package com.ems.dto;

import java.time.LocalDate;
import java.time.LocalTime;

public class AttendanceHistoryDTO {

    private LocalDate date;
    private LocalTime checkIn;
    private LocalTime checkOut;

    private int lateMinutes;

    private String employeeCode;
    private String fullName;
    private String status;


    // ==========================================
    // CONSTRUCTOR RỖNG
    // ==========================================

    public AttendanceHistoryDTO() {
    }


    // ==========================================
    // CONSTRUCTOR ĐẦY ĐỦ
    // ==========================================

    public AttendanceHistoryDTO(
            LocalDate date,
            LocalTime checkIn,
            LocalTime checkOut,
            long lateMinutes,
            String employeeCode,
            String fullName,
            String status) {

        this.date = date;
        this.checkIn = checkIn;
        this.checkOut = checkOut;
        this.lateMinutes = (int) lateMinutes;
        this.employeeCode = employeeCode;
        this.fullName = fullName;
        this.status = status;
    }


    // ==========================================
    // DATE
    // ==========================================

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }


    // ==========================================
    // CHECK IN
    // ==========================================

    public LocalTime getCheckIn() {
        return checkIn;
    }

    public void setCheckIn(LocalTime checkIn) {
        this.checkIn = checkIn;
    }


    // ==========================================
    // CHECK OUT
    // ==========================================

    public LocalTime getCheckOut() {
        return checkOut;
    }

    public void setCheckOut(LocalTime checkOut) {
        this.checkOut = checkOut;
    }


    // ==========================================
    // LATE MINUTES
    // ==========================================

    public int getLateMinutes() {
        return lateMinutes;
    }

    public void setLateMinutes(int lateMinutes) {
        this.lateMinutes = lateMinutes;
    }


    // ==========================================
    // EMPLOYEE CODE
    // ==========================================

    public String getEmployeeCode() {
        return employeeCode;
    }

    public void setEmployeeCode(String employeeCode) {
        this.employeeCode = employeeCode;
    }


    // ==========================================
    // FULL NAME
    // ==========================================

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }


    // ==========================================
    // STATUS
    // ==========================================

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}