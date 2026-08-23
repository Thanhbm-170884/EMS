package com.ems.dao;

import com.ems.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PositionDAO {

    /**
     * Lấy danh sách tất cả chức vụ kèm ca làm việc mặc định và số lượng nhân sự
     */
    public List<Map<String, Object>> getAllPositionsWithStats() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT p.Id, p.Code, p.Name, p.JobLevel, p.DefaultShiftId, s.Name AS ShiftName, " +
                     "       (SELECT COUNT(*) FROM users u WHERE u.PositionId = p.Id) AS TotalEmployees " +
                     "FROM positions p " +
                     "LEFT JOIN shifts s ON p.DefaultShiftId = s.Id " +
                     "ORDER BY p.Id ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("id", rs.getInt("Id"));
                map.put("code", rs.getString("Code"));
                map.put("name", rs.getString("Name"));
                map.put("jobLevel", rs.getInt("JobLevel"));
                int shiftId = rs.getInt("DefaultShiftId");
                if (rs.wasNull()) {
                    map.put("defaultShiftId", null);
                } else {
                    map.put("defaultShiftId", shiftId);
                }
                map.put("shiftName", rs.getString("ShiftName"));
                map.put("totalEmployees", rs.getInt("TotalEmployees"));
                list.add(map);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy danh sách ca làm việc (shifts) đang hoạt động để chọn trong dropdown
     */
    public List<Map<String, Object>> getAllShifts() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT Id, Name, StartTime, EndTime FROM shifts WHERE IsActive = 1 ORDER BY Id ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("id", rs.getInt("Id"));
                map.put("name", rs.getString("Name"));
                map.put("startTime", rs.getTime("StartTime"));
                map.put("endTime", rs.getTime("EndTime"));
                list.add(map);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Kiểm tra trùng mã chức vụ (Code)
     */
    public boolean isCodeExists(String code, int excludeId) {
        String sql = "SELECT COUNT(*) FROM positions WHERE LOWER(Code) = LOWER(?) AND Id != ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code.trim());
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Kiểm tra trùng tên chức vụ (Name)
     */
    public boolean isNameExists(String name, int excludeId) {
        if (name == null || name.trim().isEmpty()) return false;
        String sql = "SELECT COUNT(*) FROM positions WHERE LOWER(Name) = LOWER(?) AND Id != ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name.trim());
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Thêm mới chức vụ
     */
    public boolean addPosition(String code, String name, int jobLevel, Integer defaultShiftId) {
        String sql = "INSERT INTO positions (Code, Name, JobLevel, DefaultShiftId) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, code.trim().toUpperCase());
            ps.setString(2, name.trim());
            ps.setInt(3, jobLevel);
            if (defaultShiftId != null && defaultShiftId > 0) {
                ps.setInt(4, defaultShiftId);
            } else {
                ps.setNull(4, Types.INTEGER);
            }

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Cập nhật thông tin chức vụ
     */
    public boolean updatePosition(int id, String name, int jobLevel, Integer defaultShiftId) {
        String sql = "UPDATE positions SET Name = ?, JobLevel = ?, DefaultShiftId = ? WHERE Id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, name.trim());
            ps.setInt(2, jobLevel);
            if (defaultShiftId != null && defaultShiftId > 0) {
                ps.setInt(3, defaultShiftId);
            } else {
                ps.setNull(3, Types.INTEGER);
            }
            ps.setInt(4, id);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Đếm số lượng nhân sự đang giữ chức vụ này
     */
    public int countEmployees(int positionId) {
        String sql = "SELECT COUNT(*) FROM users WHERE PositionId = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, positionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Xóa chức vụ (Chỉ xóa khi không có nhân sự nào giữ chức vụ này)
     */
    public boolean deletePosition(int positionId) {
        if (countEmployees(positionId) > 0) {
            return false;
        }
        String sql = "DELETE FROM positions WHERE Id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, positionId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy danh sách nhân sự gom nhóm theo từng chức vụ
     */
    public Map<Integer, List<Map<String, Object>>> getAllEmployeesGroupedByPosition() {
        Map<Integer, List<Map<String, Object>>> map = new HashMap<>();
        String sql = "SELECT u.Id, u.EmployeeCode, u.FullName, u.EmailCompany, u.Phone, u.Status, u.PositionId, " +
                     "       d.Name AS DepartmentName " +
                     "FROM users u " +
                     "LEFT JOIN departments d ON u.DepartmentId = d.Id " +
                     "ORDER BY u.EmployeeCode ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                int posId = rs.getInt("PositionId");
                Map<String, Object> emp = new HashMap<>();
                emp.put("id", rs.getInt("Id"));
                emp.put("employeeCode", rs.getString("EmployeeCode"));
                emp.put("fullName", rs.getString("FullName"));
                emp.put("emailCompany", rs.getString("EmailCompany"));
                emp.put("phone", rs.getString("Phone"));
                emp.put("status", rs.getBoolean("Status"));
                emp.put("departmentName", rs.getString("DepartmentName"));

                map.computeIfAbsent(posId, k -> new ArrayList<>()).add(emp);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }
}
