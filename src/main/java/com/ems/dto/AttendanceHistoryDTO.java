package com.ems.dto;

import java.time.LocalDate;
import java.time.LocalTime;

public class AttendanceHistoryDTO {

    private LocalDate date;
    private LocalTime checkIn;
    private LocalTime checkOut;
    private long lateMinutes;

    public AttendanceHistoryDTO(LocalDate date, LocalTime checkIn, LocalTime checkOut, long lateMinutes) {
        this.date = date;
        this.checkIn = checkIn;
        this.checkOut = checkOut;
        this.lateMinutes = lateMinutes;
    }

    public LocalDate getDate() { return date; }
    public LocalTime getCheckIn() { return checkIn; }
    public LocalTime getCheckOut() { return checkOut; }
    public long getLateMinutes() { return lateMinutes; }

    /** Trạng thái để hiển thị badge trên giao diện */
    public String getStatus() {
        if (checkIn == null) return "ABSENT";
        if (checkOut == null) return "MISSING_CHECKOUT";
        if (lateMinutes > 0) return "LATE";
        return "ON_TIME";
    }
}