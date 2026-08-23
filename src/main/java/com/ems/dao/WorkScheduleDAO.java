package com.ems.dao;

import com.ems.model.Shifts;
import com.ems.util.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class WorkScheduleDAO {

    /**
     * Lấy bộ lịch mặc định đang có hiệu lực (EffectiveEndDate IS NULL).
     * Dùng cho màn hình setting /work-schedule để hiển thị cấu hình hiện tại.
     */
    public static List<Shifts> getWeekDefaultShift() {
        List<Shifts> list = new ArrayList<>();
        String sql = "SELECT * FROM shifts WHERE IsDefault = 1 AND EffectiveEndDate IS NULL ORDER BY CASE WHEN DayOfWeek = 1 THEN 8 ELSE DayOfWeek END ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToShift(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return list;
    }

    /**
     * Lấy tất cả ca mặc định (IsDefault=1) có giao cắt với khoảng [startDate, endDate].
     * Dùng cho EmployeeCalendarService để nội suy lịch làm việc trên RAM.
     * Query 1 lần duy nhất cho cả tháng, tránh N+1.
     */
    public static List<Shifts> getDefaultShiftsInRange(LocalDate startDate, LocalDate endDate) {
        List<Shifts> list = new ArrayList<>();
        // Lấy tất cả version luật có giao cắt với [startDate, endDate]:
        // version bắt đầu trước endDate VÀ (chưa kết thúc HOẶC kết thúc sau startDate)
        String sql = "SELECT * FROM shifts WHERE IsDefault = 1 " +
                     "AND EffectiveStartDate <= ? " +
                     "AND (EffectiveEndDate IS NULL OR EffectiveEndDate >= ?) " +
                     "ORDER BY CASE WHEN DayOfWeek = 1 THEN 8 ELSE DayOfWeek END ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, endDate);
            ps.setObject(2, startDate);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToShift(rs));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return list;
    }

    /**
     * Lưu bộ lịch mặc định mới với versioning dùng Transaction:
     * 1. Chốt ngày kết thúc cho bộ lịch cũ (đang active, EffectiveEndDate IS NULL)
     * 2. Insert bộ lịch mới với EffectiveStartDate = effectiveDate
     *
     * Nếu bảng trống (lần đầu tạo lịch), bước 1 không làm gì (0 rows updated) — an toàn.
     */
    public static void saveNewDefaultSchedule(List<Shifts> newShifts, LocalDate effectiveDate) {
        String updateOldSql = "UPDATE shifts SET EffectiveEndDate = ? " +
                              "WHERE IsDefault = 1 AND EffectiveEndDate IS NULL";
        String insertNewSql = "INSERT INTO shifts (Name, StartTime, EndTime, BreakStart, BreakEnd, " +
                              "IsActive, IsDefault, DayOfWeek, EffectiveStartDate, EffectiveEndDate) " +
                              "VALUES (?, ?, ?, ?, ?, ?, 1, ?, ?, NULL)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Bước 1: Chốt ngày kết thúc bộ cũ = effectiveDate - 1 ngày
                try (PreparedStatement psUpdate = conn.prepareStatement(updateOldSql)) {
                    psUpdate.setDate(1, java.sql.Date.valueOf(effectiveDate.minusDays(1)));
                    psUpdate.executeUpdate();
                }

                // Bước 2: Insert bộ mới theo batch
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

    private static Shifts mapResultSetToShift(ResultSet rs) throws SQLException {
        Shifts shift = new Shifts();
        shift.setId(rs.getInt("Id"));
        shift.setDayOfweek(rs.getInt("DayOfWeek"));
        shift.setName(rs.getString("Name"));

        Time start = rs.getTime("StartTime");
        Time end   = rs.getTime("EndTime");
        Time bs    = rs.getTime("BreakStart");
        Time be    = rs.getTime("BreakEnd");

        shift.setStarttime(start != null ? start.toLocalTime() : null);
        shift.setEndtime(end   != null ? end.toLocalTime()   : null);
        shift.setBreakstart(bs != null ? bs.toLocalTime()    : null);
        shift.setBreakend(be   != null ? be.toLocalTime()    : null);
        shift.setIsactive(rs.getBoolean("IsActive"));

        // Đọc 2 cột versioning mới
        java.sql.Date esd = rs.getDate("EffectiveStartDate");
        java.sql.Date eed = rs.getDate("EffectiveEndDate");
        shift.setEffectiveStartDate(esd != null ? esd.toLocalDate() : null);
        shift.setEffectiveEndDate(eed   != null ? eed.toLocalDate() : null);

        return shift;
    }
}