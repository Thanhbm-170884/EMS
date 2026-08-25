package com.ems.service;

import com.ems.dao.DepartmentDAO;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * DepartmentManageService
 * -----------------------
 * Xử lý toàn bộ nghiệp vụ cho Quản lý phòng ban (Department Management).
 */
public class DepartmentManageService {

    private final DepartmentDAO departmentDAO = new DepartmentDAO();

    /** Lấy danh sách tất cả phòng ban kèm thống kê số nhân sự và Trưởng phòng */
    public List<Map<String, Object>> getAllDepartmentsWithStats() {
        return departmentDAO.getAllDepartmentsWithStats();
    }

    /** Tính toán thống kê phòng ban (Tổng số phòng ban, Đã có trưởng phòng) */
    public Map<String, Integer> getDepartmentStats(List<Map<String, Object>> list) {
        Map<String, Integer> stats = new HashMap<>();
        int total = (list != null) ? list.size() : 0;
        int withHead = 0;

        if (list != null) {
            for (Map<String, Object> d : list) {
                if (d.get("headAccountId") != null) {
                    withHead++;
                }
            }
        }

        stats.put("total", total);
        stats.put("withHead", withHead);
        return stats;
    }

    /** Lấy danh sách nhân viên hoạt động để bổ nhiệm Trưởng phòng */
    public List<Map<String, Object>> getActiveEmployeesForHead() {
        return departmentDAO.getActiveEmployeesForHead();
    }

    /** Kiểm tra mã phòng ban tồn tại */
    public boolean isCodeExists(String code, Integer excludeId) {
        if (code == null || code.trim().isEmpty()) return false;
        return departmentDAO.isCodeExists(code.trim().toUpperCase(), excludeId);
    }

    /** Kiểm tra tên phòng ban tồn tại */
    public boolean isNameExists(String name, Integer excludeId) {
        if (name == null || name.trim().isEmpty()) return false;
        return departmentDAO.isNameExists(name.trim(), excludeId);
    }

    /** Đếm số lượng nhân viên trong phòng ban */
    public int countEmployees(int departmentId) {
        if (departmentId <= 0) return 0;
        return departmentDAO.countEmployees(departmentId);
    }

    /**
     * Tạo mới phòng ban
     */
    public boolean createDepartment(String code, String name, Integer headAccountId) {
        if (code == null || code.trim().isEmpty() || name == null || name.trim().isEmpty()) {
            return false;
        }

        String codeTrimmed = code.trim().toUpperCase();
        String nameTrimmed = name.trim();

        // Kiểm tra mã phòng ban đã tồn tại chưa
        if (departmentDAO.isCodeExists(codeTrimmed, null)) {
            return false;
        }

        return departmentDAO.addDepartment(codeTrimmed, nameTrimmed, headAccountId);
    }

    /**
     * Cập nhật thông tin phòng ban (Tên phòng ban & Bổ nhiệm Trưởng phòng)
     */
    public boolean updateDepartment(int id, String name, Integer headAccountId) {
        if (id <= 0 || name == null || name.trim().isEmpty()) {
            return false;
        }

        return departmentDAO.updateDepartment(id, name.trim(), headAccountId);
    }

    /**
     * Xóa phòng ban (Có Integrity Guard kiểm tra nhân viên)
     */
    public boolean deleteDepartment(int id) {
        if (id <= 0) return false;

        // Ràng buộc toàn vẹn: Không cho phép xóa nếu phòng ban đang có nhân viên
        int employeeCount = departmentDAO.countEmployees(id);
        if (employeeCount > 0) {
            return false;
        }

        return departmentDAO.deleteDepartment(id);
    }

    /** Lấy danh sách nhân viên nhóm theo phòng ban */
    public Map<Integer, List<Map<String, Object>>> getAllEmployeesGroupedByDepartment() {
        return departmentDAO.getAllEmployeesGroupedByDepartment();
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
