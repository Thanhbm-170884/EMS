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

    /** Kiểm tra username đã tồn tại chưa */
    public boolean isUsernameExists(String username) {
        if (username == null || username.trim().isEmpty()) return false;
        return userDAO.isUsernameExists(username.trim());
    }

    /** Kiểm tra email có trùng với tài khoản khác không */
    public boolean isEmailExistsForOther(String email, int accountId) {
        if (email == null || email.trim().isEmpty()) return false;
        return userDAO.isEmailExistsForOther(email.trim(), accountId);
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
     * Cập nhật thông tin cơ bản tài khoản (Họ tên, Email @hrms.vn, Vai trò)
     */
    public boolean updateAccountBasic(int accountId, String fullName, String email, String roleName) {
        if (accountId <= 0 || fullName == null || fullName.trim().isEmpty() || email == null || email.trim().isEmpty()) {
            return false;
        }

        String emailTrimmed = email.trim().toLowerCase();
        if (!emailTrimmed.endsWith("@hrms.vn")) {
            return false;
        }

        if (userDAO.isEmailExistsForOther(emailTrimmed, accountId)) {
            return false;
        }

        return userDAO.updateAccountBasic(accountId, fullName.trim(), emailTrimmed, roleName != null ? roleName.trim() : "Employee");
    }

    /**
     * Cập nhật vai trò người dùng
     */
    public boolean updateAccountRole(int accountId, String roleName) {
        if (accountId <= 0 || roleName == null || roleName.trim().isEmpty()) return false;
        userDAO.updateAccountRole(accountId, roleName.trim());
        return true;
    }

    /**
     * Khóa / Mở khóa tài khoản (Toggle Status)
     */
    public boolean toggleAccountStatus(int accountId, boolean currentStatus) {
        if (accountId <= 0) return false;
        userDAO.updateAccountStatus(accountId, !currentStatus);
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
                     "SELECT u.FullName, d.Name as DeptName " +
                     "FROM accounts a " +
                     "JOIN users u ON a.UserId = u.Id " +
                     "LEFT JOIN departments d ON u.DepartmentId = d.Id " +
                     "WHERE a.Username = ?")) {
            ps.setString(1, username.trim());
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String fn = rs.getString("FullName");
                    String dn = rs.getString("DeptName");
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
