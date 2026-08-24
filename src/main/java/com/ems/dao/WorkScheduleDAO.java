package com.ems.dao;

import com.ems.model.Shifts;
import com.ems.util.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class WorkScheduleDAO {

    private static Boolean hasEffectiveCols = null;

    private static synchronized boolean checkHasEffectiveColumns(Connection conn) {
        if (hasEffectiveCols != null) return hasEffectiveCols;
        try {
            DatabaseMetaData md = conn.getMetaData();
            try (ResultSet rs = md.getColumns(null, null, "shifts", "EffectiveEndDate")) {
                if (rs.next()) {
                    hasEffectiveCols = true;
                    return true;
                }
            }
            try (ResultSet rs = md.getColumns(null, null, "SHIFTS", "EffectiveEndDate")) {
                if (rs.next()) {
                    hasEffectiveCols = true;
                    return true;
                }
            }
            hasEffectiveCols = false;
        } catch (Exception e) {
            hasEffectiveCols = false;
        }
        return hasEffectiveCols;
    }

    /**
     * Lấy bộ lịch mặc định đang có hiệu lực.
     * Tự động tương thích nếu DB chưa có cột EffectiveEndDate.
     */
    public static List<Shifts> getWeekDefaultShift() {
        List<Shifts> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection()) {
            boolean hasCols = checkHasEffectiveColumns(conn);
            String sql;
            if (hasCols) {
                sql = "SELECT * FROM shifts WHERE IsDefault = 1 AND EffectiveEndDate IS NULL ORDER BY CASE WHEN DayOfWeek = 1 THEN 8 ELSE DayOfWeek END ASC";
            } else {
                sql = "SELECT * FROM shifts WHERE IsDefault = 1 ORDER BY CASE WHEN DayOfWeek = 1 THEN 8 ELSE DayOfWeek END ASC";
            }
            try (PreparedStatement stmt = conn.prepareStatement(sql);
                 ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToShift(rs, hasCols));
                }
            }
        } catch (SQLException e) {
            // Fallback an toàn nếu query với EffectiveEndDate gặp lỗi trên DB
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement("SELECT * FROM shifts WHERE IsDefault = 1 ORDER BY CASE WHEN DayOfWeek = 1 THEN 8 ELSE DayOfWeek END ASC");
                 ResultSet rs = stmt.executeQuery()) {
                hasEffectiveCols = false;
                while (rs.next()) {
                    list.add(mapResultSetToShift(rs, false));
                }
            } catch (SQLException ex) {
                throw new RuntimeException(ex);
            }
        }
        return list;
    }

    /**
     * Lấy tất cả ca mặc định (IsDefault=1) có giao cắt với khoảng [startDate, endDate].
     */
    public static List<Shifts> getDefaultShiftsInRange(LocalDate startDate, LocalDate endDate) {
        List<Shifts> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection()) {
            boolean hasCols = checkHasEffectiveColumns(conn);
            if (hasCols) {
                String sql = "SELECT * FROM shifts WHERE IsDefault = 1 " +
                             "AND EffectiveStartDate <= ? " +
                             "AND (EffectiveEndDate IS NULL OR EffectiveEndDate >= ?) " +
                             "ORDER BY CASE WHEN DayOfWeek = 1 THEN 8 ELSE DayOfWeek END ASC";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setObject(1, endDate);
                    ps.setObject(2, startDate);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            list.add(mapResultSetToShift(rs, true));
                        }
                    }
                }
            } else {
                String sql = "SELECT * FROM shifts WHERE IsDefault = 1 ORDER BY CASE WHEN DayOfWeek = 1 THEN 8 ELSE DayOfWeek END ASC";
                try (PreparedStatement ps = conn.prepareStatement(sql);
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapResultSetToShift(rs, false));
                    }
                }
            }
        } catch (SQLException e) {
            // Fallback an toàn
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement("SELECT * FROM shifts WHERE IsDefault = 1 ORDER BY CASE WHEN DayOfWeek = 1 THEN 8 ELSE DayOfWeek END ASC");
                 ResultSet rs = ps.executeQuery()) {
                hasEffectiveCols = false;
                while (rs.next()) {
                    list.add(mapResultSetToShift(rs, false));
                }
            } catch (SQLException ex) {
                throw new RuntimeException(ex);
            }
        }
        return list;
    }

    /**
     * Lưu bộ lịch mặc định mới với versioning dùng Transaction.
     * Tự động fallback sang upsert nếu DB chưa có cột versioning.
     */
    public static void saveNewDefaultSchedule(List<Shifts> newShifts, LocalDate effectiveDate) {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                boolean hasCols = checkHasEffectiveColumns(conn);
                if (hasCols) {
                    String updateOldSql = "UPDATE shifts SET EffectiveEndDate = ? WHERE IsDefault = 1 AND EffectiveEndDate IS NULL";
                    String insertNewSql = "INSERT INTO shifts (Name, StartTime, EndTime, BreakStart, BreakEnd, " +
                                          "IsActive, IsDefault, DayOfWeek, EffectiveStartDate, EffectiveEndDate) " +
                                          "VALUES (?, ?, ?, ?, ?, ?, 1, ?, ?, NULL)";

                    try (PreparedStatement psUpdate = conn.prepareStatement(updateOldSql)) {
                        psUpdate.setDate(1, java.sql.Date.valueOf(effectiveDate.minusDays(1)));
                        psUpdate.executeUpdate();
                    }

                    try (PreparedStatement psInsert = conn.prepareStatement(insertNewSql)) {
                        for (Shifts s : newShifts) {
                            String name = s.getName() != null ? s.getName() : defaultShiftName(s.getDayOfweek());
                            psInsert.setString(1, name);
                            psInsert.setObject(2, s.getStarttime());
                            psInsert.setObject(3, s.getEndtime());
                            psInsert.setObject(4, s.getBreakstart());
                            psInsert.setObject(5, s.getBreakend());
                            psInsert.setBoolean(6, Boolean.TRUE.equals(s.getIsactive()));
                            psInsert.setInt(7, s.getDayOfweek());
                            psInsert.setDate(8, java.sql.Date.valueOf(effectiveDate));
                            psInsert.addBatch();
                        }
                        psInsert.executeBatch();
                    }
                } else {
                    for (Shifts s : newShifts) {
                        int existingId = checkExistDayOfWeek(conn, s.getDayOfweek());
                        if (existingId == -1) {
                            String insertSql = "INSERT INTO shifts (Name, StartTime, EndTime, BreakStart, BreakEnd, IsActive, IsDefault, DayOfWeek) " +
                                               "VALUES (?, ?, ?, ?, ?, ?, 1, ?)";
                            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                                String name = s.getName() != null ? s.getName() : defaultShiftName(s.getDayOfweek());
                                ps.setString(1, name);
                                ps.setObject(2, s.getStarttime());
                                ps.setObject(3, s.getEndtime());
                                ps.setObject(4, s.getBreakstart());
                                ps.setObject(5, s.getBreakend());
                                ps.setBoolean(6, Boolean.TRUE.equals(s.getIsactive()));
                                ps.setInt(7, s.getDayOfweek());
                                ps.executeUpdate();
                            }
                        } else {
                            String updateSql = "UPDATE shifts SET StartTime = ?, EndTime = ?, BreakStart = ?, BreakEnd = ?, IsActive = ? WHERE Id = ?";
                            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                                ps.setObject(1, s.getStarttime());
                                ps.setObject(2, s.getEndtime());
                                ps.setObject(3, s.getBreakstart());
                                ps.setObject(4, s.getBreakend());
                                ps.setBoolean(5, Boolean.TRUE.equals(s.getIsactive()));
                                ps.setInt(6, existingId);
                                ps.executeUpdate();
                            }
                        }
                    }
                }

                conn.commit();
            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi lưu lịch làm việc: " + e.getMessage(), e);
        }
    }

    private static int checkExistDayOfWeek(Connection conn, int dayOfWeek) throws SQLException {
        String sql = "SELECT Id FROM shifts WHERE DayOfWeek = ? AND IsDefault = 1";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, dayOfWeek);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("Id");
                }
            }
        }
        return -1;
    }

    // ──────────────────────────────────────────────────────────────────────
    // Private helpers
    // ──────────────────────────────────────────────────────────────────────

    private static String defaultShiftName(int dayOfWeek) {
        return switch (dayOfWeek) {
            case 2 -> "Thứ Hai";
            case 3 -> "Thứ Ba";
            case 4 -> "Thứ Tư";
            case 5 -> "Thứ Năm";
            case 6 -> "Thứ Sáu";
            case 7 -> "Thứ Bảy";
            case 1 -> "Chủ Nhật";
            default -> "Ngày " + dayOfWeek;
        };
    }

    private static Shifts mapResultSetToShift(ResultSet rs, boolean hasCols) throws SQLException {
        Shifts shift = new Shifts();
        shift.setId(rs.getInt("Id"));
        shift.setDayOfweek(rs.getInt("DayOfWeek"));
        try {
            shift.setName(rs.getString("Name"));
        } catch (Exception ignored) {}

        Time start = rs.getTime("StartTime");
        Time end   = rs.getTime("EndTime");
        Time bs    = rs.getTime("BreakStart");
        Time be    = rs.getTime("BreakEnd");

        shift.setStarttime(start != null ? start.toLocalTime() : null);
        shift.setEndtime(end   != null ? end.toLocalTime()   : null);
        shift.setBreakstart(bs != null ? bs.toLocalTime()    : null);
        shift.setBreakend(be   != null ? be.toLocalTime()    : null);
        shift.setIsactive(rs.getBoolean("IsActive"));

        if (hasCols) {
            try {
                java.sql.Date esd = rs.getDate("EffectiveStartDate");
                java.sql.Date eed = rs.getDate("EffectiveEndDate");
                shift.setEffectiveStartDate(esd != null ? esd.toLocalDate() : null);
                shift.setEffectiveEndDate(eed   != null ? eed.toLocalDate() : null);
            } catch (Exception ignored) {}
        }

        return shift;
    }
}