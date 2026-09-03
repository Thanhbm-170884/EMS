package com.ems.dao;

import com.ems.model.Shifts;
import com.ems.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO quản lý Ca làm việc có tên (IsDefault = 0).
 * Tách biệt với WorkScheduleDAO vốn chỉ quản lý ca mặc định (IsDefault = 1).
 */
public class ShiftManagementDAO {

    /** Lấy tất cả ca có tên (IsDefault = 0), kèm số batch đang dùng */
    public static List<Shifts> getAllCustomShifts() {
        List<Shifts> list = new ArrayList<>();
        String sql = "SELECT * FROM shifts WHERE IsDefault = 0 ORDER BY Name ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return list;
    }

    /** Lấy ca theo Id */
    public static Shifts getShiftById(int id) {
        String sql = "SELECT * FROM shifts WHERE Id = ? AND IsDefault = 0";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return null;
    }

    /** Đếm số batch đang dùng ca này (để validate khi xóa) */
    public static int countBatchesByShift(int shiftId) {
        String sql = "SELECT COUNT(*) FROM shiftassignmentbatches WHERE ShiftId = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shiftId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return 0;
    }

    /**
     * Kiểm tra tên ca đã tồn tại chưa (case-insensitive).
     * @param name  tên cần kiểm tra
     * @param excludeId  id ca cần loại trừ (khi update); null khi tạo mới
     */
    public static boolean isNameExists(String name, Integer excludeId) {
        String sql = excludeId == null
                ? "SELECT COUNT(*) FROM shifts WHERE LOWER(Name) = LOWER(?) AND IsDefault = 0"
                : "SELECT COUNT(*) FROM shifts WHERE LOWER(Name) = LOWER(?) AND IsDefault = 0 AND Id <> ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            if (excludeId != null) ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return false;
    }

    /** Tạo ca mới (IsDefault = 0) */
    public static void createShift(Shifts s) {
        String sql = "INSERT INTO shifts (Name, StartTime, EndTime, BreakStart, BreakEnd, IsActive, IsDefault, DayOfWeek) " +
                     "VALUES (?, ?, ?, ?, ?, 1, 0, NULL)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, s.getName());
            ps.setObject(2, s.getStarttime());
            ps.setObject(3, s.getEndtime());
            ps.setObject(4, s.getBreakstart());
            ps.setObject(5, s.getBreakend());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    /** Cập nhật ca */
    public static void updateShift(Shifts s) {
        String sql = "UPDATE shifts SET Name = ?, StartTime = ?, EndTime = ?, BreakStart = ?, BreakEnd = ? " +
                     "WHERE Id = ? AND IsDefault = 0";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, s.getName());
            ps.setObject(2, s.getStarttime());
            ps.setObject(3, s.getEndtime());
            ps.setObject(4, s.getBreakstart());
            ps.setObject(5, s.getBreakend());
            ps.setInt(6, s.getId());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    /** Xóa ca (Service phải kiểm tra countBatchesByShift > 0 trước khi gọi hàm này) */
    public static void deleteShift(int id) {
        String sql = "DELETE FROM shifts WHERE Id = ? AND IsDefault = 0";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    // ── Private mapper ──
    private static Shifts map(ResultSet rs) throws SQLException {
        Shifts s = new Shifts();
        s.setId(rs.getInt("Id"));
        s.setName(rs.getString("Name"));
        Time st = rs.getTime("StartTime");
        Time et = rs.getTime("EndTime");
        Time bs = rs.getTime("BreakStart");
        Time be = rs.getTime("BreakEnd");
        s.setStarttime(st != null ? st.toLocalTime() : null);
        s.setEndtime(et != null ? et.toLocalTime() : null);
        s.setBreakstart(bs != null ? bs.toLocalTime() : null);
        s.setBreakend(be != null ? be.toLocalTime() : null);
        s.setIsactive(rs.getBoolean("IsActive"));
        return s;
    }
}
