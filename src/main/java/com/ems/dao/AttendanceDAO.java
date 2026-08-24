package com.ems.dao;

import com.ems.model.AttendanceRecord;
import com.ems.util.DBConnection;


import java.sql.*;
import java.util.List;
import com.ems.dto.AttendanceHistoryDTO;
import java.time.Duration;
 import java.time.LocalDate;
 import java.time.LocalTime;
 import java.util.ArrayList;
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
    private static final LocalTime STANDARD_CHECKIN = LocalTime.of(8, 0);

    private static final String FIND_HISTORY_SQL =
            "SELECT AttendanceDate, CheckInTime, CheckOutTime FROM attendance " +
                    "WHERE EmployeeId = ? AND AttendanceDate BETWEEN ? AND ? " +
                    "ORDER BY AttendanceDate DESC";

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
    public List<AttendanceHistoryDTO> findByEmployeeAndDateRange(
            int employeeId, LocalDate fromDate, LocalDate toDate) throws Exception {

        List<AttendanceHistoryDTO> result = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(FIND_HISTORY_SQL)) {
            ps.setInt(1, employeeId);
            ps.setDate(2, java.sql.Date.valueOf(fromDate));
            ps.setDate(3, java.sql.Date.valueOf(toDate));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LocalDate date = rs.getDate("AttendanceDate").toLocalDate();
                    Time ciTime = rs.getTime("CheckInTime");
                    Time coTime = rs.getTime("CheckOutTime");

                    LocalTime checkIn = ciTime != null ? ciTime.toLocalTime() : null;
                    LocalTime checkOut = coTime != null ? coTime.toLocalTime() : null;

                    long lateMinutes = 0;
                    if (checkIn != null && checkIn.isAfter(STANDARD_CHECKIN)) {
                        lateMinutes = Duration.between(STANDARD_CHECKIN, checkIn).toMinutes();
                    }

                    result.add(new AttendanceHistoryDTO(date, checkIn, checkOut, lateMinutes));
                }
            }
        }

        return result;
    }
    /**
     * Tra Id thật trong bảng users (= EmployeeId dùng trong bảng attendance)
     * từ accountId đang lưu trong session.
     */
    public Integer findUserIdByAccountId(int accountId) throws Exception {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT UserId FROM accounts WHERE Id = ?")) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("UserId") : null;
            }
        }
    }
}