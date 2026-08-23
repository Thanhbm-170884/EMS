package com.ems.dao;

import com.ems.model.AttendanceRecord;
import com.ems.util.DBConnection;

import java.sql.*;
import java.util.List;

public class AttendanceDAO {

    private static final String FIND_USER_ID_SQL =
            "SELECT Id FROM users WHERE EmployeeCode = ?";

    // Dùng ON DUPLICATE KEY UPDATE vì bảng attendance có ràng buộc
    // UNIQUE (EmployeeId, AttendanceDate) -> nếu nhân viên đã có dữ liệu
    // chấm công ngày đó, upload lại sẽ CẬP NHẬT giờ check-in/out mới,
    // thay vì báo lỗi trùng khóa.
    private static final String UPSERT_SQL =
            "INSERT INTO attendance (EmployeeId, AttendanceDate, CheckInTime, CheckOutTime) " +
                    "VALUES (?, ?, ?, ?) " +
                    "ON DUPLICATE KEY UPDATE CheckInTime = VALUES(CheckInTime), CheckOutTime = VALUES(CheckOutTime)";

    /**
     * Tra cứu EmployeeId (khóa chính bảng users) từ Mã nhân viên (EmployeeCode) đọc từ Excel.
     * Trả về null nếu không tìm thấy nhân viên tương ứng trong hệ thống.
     */
    public Integer findUserIdByEmployeeCode(String employeeCode) throws Exception {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(FIND_USER_ID_SQL)) {
            ps.setString(1, employeeCode);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("Id") : null;
            }
        }
    }

    /**
     * Lưu danh sách chấm công. Mỗi record BẮT BUỘC đã có employeeId
     * (đã được tra cứu và gán trước đó ở ConfirmServlet).
     */
    public void saveAll(List<AttendanceRecord> records) throws Exception {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(UPSERT_SQL)) {
                for (AttendanceRecord r : records) {
                    ps.setInt(1, r.getEmployeeId());
                    ps.setDate(2, java.sql.Date.valueOf(r.getDate()));
                    ps.setTime(3, r.getCheckIn() != null ? Time.valueOf(r.getCheckIn()) : null);
                    ps.setTime(4, r.getCheckOut() != null ? Time.valueOf(r.getCheckOut()) : null);
                    ps.addBatch();
                }
                ps.executeBatch();
                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
    }
}