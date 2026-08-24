package com.ems.service;

import com.ems.dao.UserDAO;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * UserManageService
 * -----------------
 * Xử lý toàn bộ nghiệp vụ cho Quản lý tài khoản (Account Management).
 */
public class UserManageService {

    private final UserDAO userDAO = new UserDAO();

    /** Lấy danh sách tất cả tài khoản người dùng */
    public List<Map<String, Object>> getAllUsers() {
        return userDAO.getAllUsers();
    }

    /** Tính toán số lượng thống kê tài khoản (Tổng số, Đang hoạt động, Bị khóa) */
    public Map<String, Integer> getAccountStats(List<Map<String, Object>> usersList) {
        Map<String, Integer> stats = new HashMap<>();
        int total = (usersList != null) ? usersList.size() : 0;
        int active = 0;
        int locked = 0;

        if (usersList != null) {
            for (Map<String, Object> u : usersList) {
                Boolean status = (Boolean) u.get("accountStatus");
                if (status != null && status) {
                    active++;
                } else {
                    locked++;
                }
            }
        }

        stats.put("total", total);
        stats.put("active", active);
        stats.put("locked", locked);
        return stats;
    }

    /** Lấy danh sách các vai trò trong hệ thống */
    public List<String> getAllRoles() {
        return userDAO.getAllRoles();
    }

    /** Lấy danh sách phòng ban */
    public List<Map<String, Object>> getDepartments() {
        return userDAO.getDepartments();
    }

    /** Lấy danh sách chức vụ */
    public List<Map<String, Object>> getPositions() {
        return userDAO.getPositions();
    }

    /** Lấy danh sách nhân viên chưa được cấp tài khoản */
    public List<Map<String, Object>> getEmployeesWithoutAccount() {
        return userDAO.getEmployeesWithoutAccount();
    }

    /**
     * Cấp tài khoản mới cho nhân viên đã có hồ sơ
     */
    public boolean createAccountForEmployee(int userId, String username, String password, String roleName) {
        if (userId <= 0 || username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            return false;
        }

        if (userDAO.isUsernameExists(username.trim())) {
            return false;
        }

        return userDAO.createAccountForUser(userId, username.trim(), password.trim(), roleName != null ? roleName.trim() : "Employee");
    }

    /**
     * Cập nhật thông tin cơ bản tài khoản (Họ tên, Email @techcorp.vn, Vai trò)
     */
    public boolean updateAccountBasic(int accountId, String fullName, String email, String roleName) {
        if (accountId <= 0 || fullName == null || fullName.trim().isEmpty() || email == null || email.trim().isEmpty()) {
            return false;
        }

        String emailTrimmed = email.trim().toLowerCase();
        if (!emailTrimmed.endsWith("@techcorp.vn")) {
            return false;
        }

        if (userDAO.isEmailExistsForOther(emailTrimmed, accountId)) {
            return false;
        }

        return userDAO.updateAccountBasic(accountId, fullName.trim(), emailTrimmed, roleName != null ? roleName.trim() : "Employee");
    }

    /**
     * Khóa / Mở khóa tài khoản (Toggle Status)
     */
    public boolean toggleAccountStatus(int accountId, boolean currentStatus) {
        if (accountId <= 0) return false;
        userDAO.updateAccountStatus(accountId, !currentStatus);
        return true;
    }
}
