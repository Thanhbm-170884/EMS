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

public class DepartmentDAO {

    /**
     * Lấy danh sách tất cả các phòng ban kèm thông tin Trưởng phòng và Số lượng nhân viên
     */
    public List<Map<String, Object>> getAllDepartmentsWithStats() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT " +
                     "    d.Id, " +
                     "    d.Code, " +
                     "    d.Name, " +
                     "    d.HeadAccountId, " +
                     "    u_head.FullName AS HeadName, " +
                     "    u_head.EmployeeCode AS HeadEmployeeCode, " +
                     "    (SELECT COUNT(*) FROM users u WHERE u.DepartmentId = d.Id) AS TotalEmployees " +
                     "FROM departments d " +
                     "LEFT JOIN accounts a_head ON d.HeadAccountId = a_head.Id " +
                     "LEFT JOIN users u_head ON a_head.UserId = u_head.Id " +
                     "ORDER BY d.Id ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> dept = new HashMap<>();
                dept.put("id", rs.getInt("Id"));
                dept.put("code", rs.getString("Code"));
                dept.put("name", rs.getString("Name"));
                
                int headAccId = rs.getInt("HeadAccountId");
                if (rs.wasNull()) {
                    dept.put("headAccountId", null);
                    dept.put("headName", null);
                    dept.put("headEmployeeCode", null);
                } else {
                    dept.put("headAccountId", headAccId);
                    dept.put("headName", rs.getString("HeadName"));
                    dept.put("headEmployeeCode", rs.getString("HeadEmployeeCode"));
                }
                
                dept.put("totalEmployees", rs.getInt("TotalEmployees"));
                list.add(dept);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy danh sách tài khoản nhân viên đang hoạt động để chọn làm Trưởng phòng
     */
    public List<Map<String, Object>> getActiveEmployeesForHead() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT a.Id AS AccountId, u.FullName, u.EmployeeCode, u.DepartmentId, d.Name AS DeptName " +
                     "FROM accounts a " +
                     "JOIN users u ON a.UserId = u.Id " +
                     "LEFT JOIN departments d ON u.DepartmentId = d.Id " +
                     "WHERE a.Status = 1 " +
                     "ORDER BY u.FullName ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> emp = new HashMap<>();
                emp.put("accountId", rs.getInt("AccountId"));
                emp.put("fullName", rs.getString("FullName"));
                emp.put("employeeCode", rs.getString("EmployeeCode"));
                emp.put("departmentId", rs.getObject("DepartmentId"));
                emp.put("deptName", rs.getString("DeptName"));
                list.add(emp);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Kiểm tra xem Mã phòng ban (Code) đã tồn tại hay chưa
     */
    public boolean isCodeExists(String code, Integer excludeId) {
        String sql = "SELECT COUNT(*) AS cnt FROM departments WHERE UPPER(Code) = UPPER(?)";
        if (excludeId != null) {
            sql += " AND Id != ?";
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code.trim());
            if (excludeId != null) {
                ps.setInt(2, excludeId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cnt") > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Kiểm tra xem Tên phòng ban (Name) đã tồn tại hay chưa
     */
    public boolean isNameExists(String name, Integer excludeId) {
        if (name == null || name.trim().isEmpty()) return false;
        String sql = "SELECT COUNT(*) AS cnt FROM departments WHERE LOWER(Name) = LOWER(?)";
        if (excludeId != null) {
            sql += " AND Id != ?";
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name.trim());
            if (excludeId != null) {
                ps.setInt(2, excludeId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cnt") > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Thêm mới một phòng ban
     */
    public boolean addDepartment(String code, String name, Integer headAccountId) {
        String sql = "INSERT INTO departments (Code, Name, HeadAccountId) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code.trim().toUpperCase());
            ps.setString(2, name.trim());
            if (headAccountId == null || headAccountId <= 0) {
                ps.setNull(3, Types.INTEGER);
            } else {
                ps.setInt(3, headAccountId);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Cập nhật tên phòng ban và trưởng phòng
     */
    public boolean updateDepartment(int id, String name, Integer headAccountId) {
        String sql = "UPDATE departments SET Name = ?, HeadAccountId = ? WHERE Id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name.trim());
            if (headAccountId == null || headAccountId <= 0) {
                ps.setNull(2, Types.INTEGER);
            } else {
                ps.setInt(2, headAccountId);
            }
            ps.setInt(3, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Đếm số lượng nhân viên đang trực thuộc phòng ban
     */
    public int countEmployees(int deptId) {
        String sql = "SELECT COUNT(*) AS cnt FROM users WHERE DepartmentId = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, deptId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cnt");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Xóa phòng ban (chỉ xóa khi không còn nhân viên nào)
     */
    public boolean deleteDepartment(int deptId) {
        if (countEmployees(deptId) > 0) {
            return false; // Không cho xóa nếu đang có nhân viên
        }
        String sql = "DELETE FROM departments WHERE Id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, deptId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy danh sách nhân viên gom nhóm theo từng phòng ban
     */
    public Map<Integer, List<Map<String, Object>>> getAllEmployeesGroupedByDepartment() {
        Map<Integer, List<Map<String, Object>>> map = new HashMap<>();
        String sql = "SELECT u.Id, u.EmployeeCode, u.FullName, u.EmailCompany, u.Phone, u.Status, u.DepartmentId, " +
                     "       p.Name AS PositionName " +
                     "FROM users u " +
                     "LEFT JOIN positions p ON u.PositionId = p.Id " +
                     "ORDER BY u.EmployeeCode ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                int deptId = rs.getInt("DepartmentId");
                Map<String, Object> emp = new HashMap<>();
                emp.put("id", rs.getInt("Id"));
                emp.put("employeeCode", rs.getString("EmployeeCode"));
                emp.put("fullName", rs.getString("FullName"));
                emp.put("emailCompany", rs.getString("EmailCompany"));
                emp.put("phone", rs.getString("Phone"));
                emp.put("status", rs.getBoolean("Status"));
                emp.put("positionName", rs.getString("PositionName"));

                map.computeIfAbsent(deptId, k -> new ArrayList<>()).add(emp);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }
}
