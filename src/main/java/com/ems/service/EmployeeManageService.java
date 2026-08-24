package com.ems.service;

import com.ems.dao.UserDAO;

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

    private final UserDAO userDAO = new UserDAO();

    /** Lấy danh sách toàn bộ hồ sơ nhân viên */
    public List<Map<String, Object>> getAllEmployees() {
        return userDAO.getAllEmployees();
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
        return userDAO.getDepartments();
    }

    /** Lấy danh sách chức vụ */
    public List<Map<String, Object>> getPositions() {
        return userDAO.getPositions();
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
        if (userDAO.isEmailExists(emailTrimmed)) {
            return false;
        }
        if (!phoneTrimmed.isEmpty() && userDAO.isPhoneExists(phoneTrimmed)) {
            return false;
        }

        return userDAO.createEmployee(fullName.trim(), emailTrimmed, phoneTrimmed, gender, dob, deptId, posId, dependentsCount, baseSalary);
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
        if (userDAO.isEmailExistsForOtherUserId(emailTrimmed, userId)) {
            return false;
        }
        if (!phoneTrimmed.isEmpty() && userDAO.isPhoneExistsForOtherUserId(phoneTrimmed, userId)) {
            return false;
        }

        return userDAO.updateEmployeeFull(userId, fullName.trim(), emailTrimmed, phoneTrimmed, gender, dob, deptId, posId, dependentsCount, baseSalary);
    }

    /**
     * Thay đổi trạng thái làm việc của nhân viên (Đang làm <-> Nghỉ)
     */
    public boolean toggleEmployeeStatus(int userId, boolean currentStatus) {
        if (userId <= 0) return false;
        userDAO.updateEmployeeStatus(userId, !currentStatus);
        return true;
    }
}
