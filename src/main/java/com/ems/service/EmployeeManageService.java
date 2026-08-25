package com.ems.service;

import com.ems.dao.EmployeeDAO;

import java.math.BigDecimal;
import java.sql.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * EmployeeManageService
 * ---------------------
 * Xử lý toàn bộ nghiệp vụ cho Quản lý hồ sơ nhân viên (Employee Management).
 */
public class EmployeeManageService {

    private final EmployeeDAO employeeDAO = new EmployeeDAO();

    /** Lấy danh sách toàn bộ hồ sơ nhân viên */
    public List<Map<String, Object>> getAllEmployees() {
        return employeeDAO.getAllEmployees();
    }

    /** Tính toán thống kê nhân sự (Tổng số nhân viên, Đang làm việc) */
    public Map<String, Integer> getEmployeeStats(List<Map<String, Object>> employeeList) {
        Map<String, Integer> stats = new HashMap<>();
        int total = (employeeList != null) ? employeeList.size() : 0;
        int active = 0;

        if (employeeList != null) {
            for (Map<String, Object> e : employeeList) {
                Boolean status = (Boolean) e.get("userStatus");
                if (status != null && status) {
                    active++;
                }
            }
        }

        stats.put("total", total);
        stats.put("active", active);
        return stats;
    }

    /** Lấy danh sách phòng ban */
    public List<Map<String, Object>> getDepartments() {
        return employeeDAO.getDepartments();
    }

    /** Lấy danh sách chức vụ */
    public List<Map<String, Object>> getPositions() {
        return employeeDAO.getPositions();
    }

    /**
     * Thêm mới một hồ sơ nhân viên
     */
    public boolean createEmployee(String fullName, String email, String phone,
                                  Boolean gender, Date dob, int deptId,
                                  int posId, int dependentsCount, BigDecimal baseSalary) {
        if (fullName == null || fullName.trim().isEmpty() || email == null || email.trim().isEmpty()) {
            return false;
        }

        String emailTrimmed = email.trim().toLowerCase();
        String phoneTrimmed = (phone != null) ? phone.trim() : "";

        // Kiểm tra email công ty @techcorp.vn
        if (!emailTrimmed.endsWith("@techcorp.vn")) {
            return false;
        }

        // Kiểm tra trùng email hoặc số điện thoại
        if (employeeDAO.isEmailExists(emailTrimmed)) {
            return false;
        }
        if (!phoneTrimmed.isEmpty() && employeeDAO.isPhoneExists(phoneTrimmed)) {
            return false;
        }

        return employeeDAO.createEmployee(fullName.trim(), emailTrimmed, phoneTrimmed, gender, dob, deptId, posId, dependentsCount, baseSalary);
    }

    /**
     * Cập nhật thông tin hồ sơ nhân viên đầy đủ
     */
    public boolean updateEmployee(int userId, String fullName, String email, String phone,
                                  Boolean gender, Date dob, int deptId,
                                  int posId, int dependentsCount, BigDecimal baseSalary) {
        if (userId <= 0 || fullName == null || fullName.trim().isEmpty() || email == null || email.trim().isEmpty()) {
            return false;
        }

        String emailTrimmed = email.trim().toLowerCase();
        String phoneTrimmed = (phone != null) ? phone.trim() : "";

        // Kiểm tra định dạng email công ty
        if (!emailTrimmed.endsWith("@techcorp.vn")) {
            return false;
        }

        // Kiểm tra email/phone trùng với nhân viên khác
        if (employeeDAO.isEmailExistsForOtherUserId(emailTrimmed, userId)) {
            return false;
        }
        if (!phoneTrimmed.isEmpty() && employeeDAO.isPhoneExistsForOtherUserId(phoneTrimmed, userId)) {
            return false;
        }

        return employeeDAO.updateEmployeeFull(userId, fullName.trim(), emailTrimmed, phoneTrimmed, gender, dob, deptId, posId, dependentsCount, baseSalary);
    }

    /** Kiểm tra email đã tồn tại trong hệ thống chưa */
    public boolean isEmailExists(String email) {
        if (email == null || email.trim().isEmpty()) return false;
        return employeeDAO.isEmailExists(email.trim().toLowerCase());
    }

    /** Kiểm tra số điện thoại đã tồn tại trong hệ thống chưa */
    public boolean isPhoneExists(String phone) {
        if (phone == null || phone.trim().isEmpty()) return false;
        return employeeDAO.isPhoneExists(phone.trim());
    }

    /** Kiểm tra email có trùng với nhân viên khác không */
    public boolean isEmailExistsForOtherUserId(String email, int userId) {
        if (email == null || email.trim().isEmpty()) return false;
        return employeeDAO.isEmailExistsForOtherUserId(email.trim().toLowerCase(), userId);
    }

    /** Kiểm tra số điện thoại có trùng với nhân viên khác không */
    public boolean isPhoneExistsForOtherUserId(String phone, int userId) {
        if (phone == null || phone.trim().isEmpty()) return false;
        return employeeDAO.isPhoneExistsForOtherUserId(phone.trim(), userId);
    }

    /**
     * Thay đổi trạng thái làm việc của nhân viên (Đang làm <-> Nghỉ)
     */
    public boolean toggleEmployeeStatus(int userId, boolean currentStatus) {
        if (userId <= 0) return false;
        employeeDAO.updateEmployeeStatus(userId, !currentStatus);
        return true;
    }

    /**
     * Lấy thông tin Admin đăng nhập để hiển thị Topbar
     */
    public Map<String, String> getAdminHeaderInfo(String username) {
        Map<String, String> info = new HashMap<>();
        info.put("fullName", "Admin");
        info.put("deptName", "Quản trị viên");
        if (username == null || username.trim().isEmpty()) return info;

        try (java.sql.Connection conn = com.ems.util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(
                     "SELECT u.FullName, d.Name as deptName FROM accounts a " +
                     "JOIN users u ON a.UserId = u.Id " +
                     "LEFT JOIN departments d ON u.DepartmentId = d.Id " +
                     "WHERE a.Username = ?")) {
            ps.setString(1, username.trim());
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String fn = rs.getString("FullName");
                    String dn = rs.getString("deptName");
                    if (fn != null && !fn.isEmpty()) info.put("fullName", fn);
                    if (dn != null && !dn.isEmpty()) info.put("deptName", dn);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return info;
    }
}
