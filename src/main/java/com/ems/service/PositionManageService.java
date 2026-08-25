package com.ems.service;

import com.ems.dao.PositionDAO;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * PositionManageService
 * ---------------------
 * Xử lý toàn bộ nghiệp vụ cho Quản lý chức vụ (Position Management).
 */
public class PositionManageService {

    private final PositionDAO positionDAO = new PositionDAO();

    /** Lấy danh sách tất cả chức vụ kèm ca làm việc và số lượng nhân sự */
    public List<Map<String, Object>> getAllPositionsWithStats() {
        return positionDAO.getAllPositionsWithStats();
    }

    /** Tính toán thống kê chức vụ (Tổng số chức vụ, Số chức vụ đang có nhân sự) */
    public Map<String, Integer> getPositionStats(List<Map<String, Object>> list) {
        Map<String, Integer> stats = new HashMap<>();
        int total = (list != null) ? list.size() : 0;
        int activeAssigned = 0;

        if (list != null) {
            for (Map<String, Object> p : list) {
                int count = (Integer) p.get("totalEmployees");
                if (count > 0) {
                    activeAssigned++;
                }
            }
        }

        stats.put("total", total);
        stats.put("activeAssigned", activeAssigned);
        return stats;
    }

    /** Lấy danh sách các ca làm việc hoạt động */
    public List<Map<String, Object>> getAllShifts() {
        return positionDAO.getAllShifts();
    }

    /** Kiểm tra mã chức vụ tồn tại */
    public boolean isCodeExists(String code, int excludeId) {
        if (code == null || code.trim().isEmpty()) return false;
        return positionDAO.isCodeExists(code.trim().toUpperCase(), excludeId);
    }

    /** Kiểm tra tên chức vụ tồn tại */
    public boolean isNameExists(String name, int excludeId) {
        if (name == null || name.trim().isEmpty()) return false;
        return positionDAO.isNameExists(name.trim(), excludeId);
    }

    /** Đếm số lượng nhân viên giữ chức vụ */
    public int countEmployees(int positionId) {
        if (positionId <= 0) return 0;
        return positionDAO.countEmployees(positionId);
    }

    /**
     * Tạo mới chức vụ
     */
    public boolean createPosition(String code, String name, int jobLevel, Integer defaultShiftId) {
        if (code == null || code.trim().isEmpty() || name == null || name.trim().isEmpty()) {
            return false;
        }

        String codeTrimmed = code.trim().toUpperCase();
        String nameTrimmed = name.trim();

        // Kiểm tra mã chức vụ trùng lặp
        if (positionDAO.isCodeExists(codeTrimmed, 0)) {
            return false;
        }

        return positionDAO.addPosition(codeTrimmed, nameTrimmed, jobLevel, defaultShiftId);
    }

    /**
     * Cập nhật thông tin chức vụ (Tên chức vụ, Cấp bậc, Ca làm việc)
     */
    public boolean updatePosition(int id, String name, int jobLevel, Integer defaultShiftId) {
        if (id <= 0 || name == null || name.trim().isEmpty()) {
            return false;
        }

        return positionDAO.updatePosition(id, name.trim(), jobLevel, defaultShiftId);
    }

    /**
     * Xóa chức vụ (Kiểm tra xem có nhân sự đang giữ chức vụ không)
     */
    public boolean deletePosition(int id) {
        if (id <= 0) return false;

        int employeeCount = positionDAO.countEmployees(id);
        if (employeeCount > 0) {
            return false;
        }

        return positionDAO.deletePosition(id);
    }

    /** Lấy danh sách nhân sự gom nhóm theo chức vụ */
    public Map<Integer, List<Map<String, Object>>> getAllEmployeesGroupedByPosition() {
        return positionDAO.getAllEmployeesGroupedByPosition();
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
                     "SELECT u.FullName, d.Name AS deptName FROM accounts a " +
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
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return info;
    }
}
