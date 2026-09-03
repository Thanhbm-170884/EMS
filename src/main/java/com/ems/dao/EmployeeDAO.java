package com.ems.dao;

import com.ems.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * EmployeeDAO
 * -----------
 * Xử lý toàn bộ thao tác CSDL liên quan đến Hồ sơ Nhân viên (users & employmentbasesalarys).
 */
public class EmployeeDAO {

    /** Lấy danh sách nhân viên đầy đủ thông tin (kèm phòng ban, chức vụ, lương cơ bản) */
    public List<Map<String, Object>> getAllEmployees() {
        List<Map<String, Object>> list = new ArrayList<>();
        String query =
            "SELECT u.Id as userId, u.EmployeeCode, u.FullName, u.EmailCompany, u.Phone, " +
            "       u.Gender, u.DateOfBirth, u.Status as userStatus, u.DependentsCount, " +
            "       u.DepartmentId, u.PositionId, " +
            "       d.Name as departmentName, p.Name as positionName, p.JobLevel, " +
            "       ebs.BaseSalary, a.Username, r.Name as roleName " +
            "FROM users u " +
            "LEFT JOIN departments d ON u.DepartmentId = d.Id " +
            "LEFT JOIN positions p ON u.PositionId = p.Id " +
            "LEFT JOIN (SELECT UserId, MAX(BaseSalary) as BaseSalary FROM employmentbasesalarys GROUP BY UserId) ebs ON ebs.UserId = u.Id " +
            "LEFT JOIN accounts a ON a.UserId = u.Id " +
            "LEFT JOIN accountroles ar ON ar.AccountId = a.Id " +
            "LEFT JOIN roles r ON ar.RoleId = r.Id " +
            "ORDER BY LENGTH(u.EmployeeCode) ASC, u.EmployeeCode ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("userId",          rs.getInt("userId"));
                map.put("employeeCode",    rs.getString("EmployeeCode"));
                map.put("fullName",        rs.getString("FullName"));
                map.put("emailCompany",    rs.getString("EmailCompany"));
                map.put("phone",           rs.getString("Phone"));
                map.put("gender",          rs.getObject("Gender"));
                map.put("dateOfBirth",     rs.getDate("DateOfBirth"));
                map.put("userStatus",      rs.getBoolean("userStatus"));
                map.put("dependentsCount", rs.getInt("DependentsCount"));
                map.put("departmentId",    rs.getInt("DepartmentId"));
                map.put("positionId",      rs.getInt("PositionId"));
                map.put("departmentName",  rs.getString("departmentName"));
                map.put("positionName",    rs.getString("positionName"));
                map.put("jobLevel",        rs.getInt("JobLevel"));
                map.put("baseSalary",      rs.getBigDecimal("BaseSalary"));
                map.put("username",        rs.getString("Username"));
                map.put("roleName",        rs.getString("roleName"));
                list.add(map);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Map<String, Object>> getEmployeesByDepartmentId(int deptId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String query =
            "SELECT u.Id as userId, u.EmployeeCode, u.FullName, u.EmailCompany, u.Phone, " +
            "       u.Gender, u.DateOfBirth, u.Status as userStatus, u.DependentsCount, " +
            "       u.DepartmentId, u.PositionId, " +
            "       d.Name as departmentName, p.Name as positionName, p.JobLevel, " +
            "       ebs.BaseSalary, a.Username, r.Name as roleName " +
            "FROM users u " +
            "LEFT JOIN departments d ON u.DepartmentId = d.Id " +
            "LEFT JOIN positions p ON u.PositionId = p.Id " +
            "LEFT JOIN (SELECT UserId, MAX(BaseSalary) as BaseSalary FROM employmentbasesalarys GROUP BY UserId) ebs ON ebs.UserId = u.Id " +
            "LEFT JOIN accounts a ON a.UserId = u.Id " +
            "LEFT JOIN accountroles ar ON ar.AccountId = a.Id " +
            "LEFT JOIN roles r ON ar.RoleId = r.Id " +
            "WHERE u.DepartmentId = ? " +
            "ORDER BY LENGTH(u.EmployeeCode) ASC, u.EmployeeCode ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, deptId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("userId",          rs.getInt("userId"));
                    map.put("employeeCode",    rs.getString("EmployeeCode"));
                    map.put("fullName",        rs.getString("FullName"));
                    map.put("emailCompany",    rs.getString("EmailCompany"));
                    map.put("phone",           rs.getString("Phone"));
                    map.put("gender",          rs.getObject("Gender"));
                    map.put("dateOfBirth",     rs.getDate("DateOfBirth"));
                    map.put("userStatus",      rs.getBoolean("userStatus"));
                    map.put("dependentsCount", rs.getInt("DependentsCount"));
                    map.put("departmentId",    rs.getInt("DepartmentId"));
                    map.put("positionId",      rs.getInt("PositionId"));
                    map.put("departmentName",  rs.getString("departmentName"));
                    map.put("positionName",    rs.getString("positionName"));
                    map.put("jobLevel",        rs.getInt("JobLevel"));
                    map.put("baseSalary",      rs.getBigDecimal("BaseSalary"));
                    map.put("username",        rs.getString("Username"));
                    map.put("roleName",        rs.getString("roleName"));
                    list.add(map);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Tạo mới hồ sơ nhân viên đầy đủ thông tin kèm Lương cơ bản */
    public boolean createEmployee(String fullName, String email, String phone, Boolean gender, Date dob, int departmentId, int positionId, int dependentsCount, BigDecimal baseSalary) {
        String insertUser = "INSERT INTO users (EmployeeCode, FullName, EmailCompany, Phone, Gender, DateOfBirth, DepartmentId, PositionId, DependentsCount, Status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1)";
        String insertSalary = "INSERT INTO employmentbasesalarys (BaseSalary, UserId) VALUES (?, ?)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // 1. Lấy số lượng user để sinh EmployeeCode
                int nextId = 1;
                String countQuery = "SELECT COUNT(*) FROM users";
                try (PreparedStatement ps = conn.prepareStatement(countQuery);
                     ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        nextId = rs.getInt(1) + 1;
                    }
                }
                String empCode = "EMP" + String.format("%04d", nextId);

                // 2. Thêm mới User
                int userId = -1;
                try (PreparedStatement ps = conn.prepareStatement(insertUser, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, empCode);
                    ps.setString(2, fullName);
                    ps.setString(3, email);
                    ps.setString(4, (phone != null && !phone.trim().isEmpty()) ? phone.trim() : null);
                    if (gender != null) {
                        ps.setBoolean(5, gender);
                    } else {
                        ps.setNull(5, Types.BIT);
                    }
                    ps.setDate(6, dob);
                    ps.setInt(7, departmentId);
                    ps.setInt(8, positionId);
                    ps.setInt(9, Math.max(0, dependentsCount));
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            userId = rs.getInt(1);
                        }
                    }
                }

                if (userId == -1) {
                    conn.rollback();
                    return false;
                }

                // 3. Thêm lương cơ bản
                if (baseSalary != null && baseSalary.compareTo(BigDecimal.ZERO) >= 0) {
                    try (PreparedStatement ps = conn.prepareStatement(insertSalary)) {
                        ps.setBigDecimal(1, baseSalary);
                        ps.setInt(2, userId);
                        ps.executeUpdate();
                    }
                }

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Cập nhật toàn bộ thông tin chi tiết nhân viên (kèm Lương cơ bản) */
    public boolean updateEmployeeFull(int userId, String fullName, String email, String phone, Boolean gender, Date dateOfBirth, int departmentId, int positionId, int dependentsCount, BigDecimal baseSalary) {
        String updateUser = "UPDATE users SET FullName = ?, EmailCompany = ?, Phone = ?, Gender = ?, DateOfBirth = ?, DepartmentId = ?, PositionId = ?, DependentsCount = ? WHERE Id = ?";
        String updateSalary = "UPDATE employmentbasesalarys SET BaseSalary = ? WHERE UserId = ?";
        String insertSalary = "INSERT INTO employmentbasesalarys (BaseSalary, UserId) VALUES (?, ?)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // 1. Update users table
                try (PreparedStatement ps = conn.prepareStatement(updateUser)) {
                    ps.setString(1, fullName);
                    ps.setString(2, email);
                    ps.setString(3, (phone != null && !phone.trim().isEmpty()) ? phone.trim() : null);
                    if (gender != null) {
                        ps.setBoolean(4, gender);
                    } else {
                        ps.setNull(4, Types.BIT);
                    }
                    ps.setDate(5, dateOfBirth);
                    ps.setInt(6, departmentId);
                    ps.setInt(7, positionId);
                    ps.setInt(8, Math.max(0, dependentsCount));
                    ps.setInt(9, userId);
                    ps.executeUpdate();
                }

                // 2. Update or insert employmentbasesalarys
                if (baseSalary != null) {
                    int updatedRows = 0;
                    try (PreparedStatement ps = conn.prepareStatement(updateSalary)) {
                        ps.setBigDecimal(1, baseSalary);
                        ps.setInt(2, userId);
                        updatedRows = ps.executeUpdate();
                    }
                    if (updatedRows == 0) {
                        try (PreparedStatement ps = conn.prepareStatement(insertSalary)) {
                            ps.setBigDecimal(1, baseSalary);
                            ps.setInt(2, userId);
                            ps.executeUpdate();
                        }
                    }
                }

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Cập nhật trạng thái làm việc nhân viên */
    public void updateEmployeeStatus(int userId, boolean status) {
        String query = "UPDATE users SET Status = ? WHERE Id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setBoolean(1, status);
            ps.setInt(2, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /** Kiểm tra email đã tồn tại trong hệ thống */
    public boolean isEmailExists(String email) {
        if (email == null || email.trim().isEmpty()) return false;
        String query = "SELECT COUNT(*) FROM users WHERE LOWER(EmailCompany) = LOWER(?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Kiểm tra số điện thoại đã tồn tại trong hệ thống */
    public boolean isPhoneExists(String phone) {
        if (phone == null || phone.trim().isEmpty()) return false;
        String query = "SELECT COUNT(*) FROM users WHERE Phone = ? AND Phone IS NOT NULL AND Phone != ''";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, phone.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Kiểm tra email có trùng với nhân viên khác khi cập nhật */
    public boolean isEmailExistsForOtherUserId(String email, int userId) {
        if (email == null || email.trim().isEmpty()) return false;
        String query = "SELECT COUNT(*) FROM users WHERE LOWER(EmailCompany) = LOWER(?) AND Id != ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, email.trim());
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Kiểm tra số điện thoại có trùng với nhân viên khác khi cập nhật */
    public boolean isPhoneExistsForOtherUserId(String phone, int userId) {
        if (phone == null || phone.trim().isEmpty()) return false;
        String query = "SELECT COUNT(*) FROM users WHERE Phone = ? AND Phone IS NOT NULL AND Phone != '' AND Id != ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, phone.trim());
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Lấy danh sách phòng ban */
    public List<Map<String, Object>> getDepartments() {
        List<Map<String, Object>> list = new ArrayList<>();
        String query = "SELECT Id, Name FROM departments";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("id", rs.getInt("Id"));
                map.put("name", rs.getString("Name"));
                list.add(map);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Lấy danh sách chức vụ */
    public List<Map<String, Object>> getPositions() {
        List<Map<String, Object>> list = new ArrayList<>();
        String query = "SELECT Id, Name FROM positions";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("id", rs.getInt("Id"));
                map.put("name", rs.getString("Name"));
                list.add(map);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
