package com.ems.dao;

import com.ems.dto.AttendanceHistoryDTO;
import com.ems.model.AttendanceRecord;
import com.ems.util.DBConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

public class AttendanceDAO {

    // =========================================================
    // CONSTANT
    // =========================================================

    private static final LocalTime STANDARD_CHECKIN =
            LocalTime.of(8, 0);


    // =========================================================
    // FIND USER ID BY EMPLOYEE CODE
    // =========================================================

    private static final String FIND_USER_ID_SQL =
            "SELECT Id " +
                    "FROM users " +
                    "WHERE EmployeeCode = ?";


    // =========================================================
    // UPSERT ATTENDANCE
    // =========================================================

    private static final String UPSERT_SQL =
            "INSERT INTO attendance " +
                    "(EmployeeId, AttendanceDate, CheckInTime, CheckOutTime) " +
                    "VALUES (?, ?, ?, ?) " +
                    "ON DUPLICATE KEY UPDATE " +
                    "CheckInTime = VALUES(CheckInTime), " +
                    "CheckOutTime = VALUES(CheckOutTime)";


    // =========================================================
    // FIND EMPLOYEE ATTENDANCE HISTORY
    // =========================================================

    private static final String FIND_HISTORY_SQL =
            "SELECT " +
                    "a.AttendanceDate, " +
                    "a.CheckInTime, " +
                    "a.CheckOutTime, " +
                    "u.EmployeeCode, " +
                    "u.FullName " +
                    "FROM attendance a " +
                    "JOIN users u ON a.EmployeeId = u.Id " +
                    "WHERE a.EmployeeId = ? " +
                    "AND a.AttendanceDate BETWEEN ? AND ? " +
                    "ORDER BY a.AttendanceDate DESC";


    // =========================================================
    // FIND USER ID BY EMPLOYEE CODE
    // =========================================================

    /**
     * Tìm users.Id từ EmployeeCode.
     */
    public Integer findUserIdByEmployeeCode(
            String employeeCode) throws Exception {

        try (Connection conn =
                     DBConnection.getConnection();

             PreparedStatement ps =
                     conn.prepareStatement(FIND_USER_ID_SQL)) {

            ps.setString(1, employeeCode);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return rs.getInt("Id");
                }

                return null;
            }
        }
    }


    // =========================================================
    // SAVE ATTENDANCE
    // =========================================================

    /**
     * Lưu danh sách chấm công.
     *
     * Nếu EmployeeId + AttendanceDate đã tồn tại
     * thì cập nhật CheckInTime và CheckOutTime.
     */
    public void saveAll(
            List<AttendanceRecord> records) throws Exception {

        try (Connection conn =
                     DBConnection.getConnection()) {

            conn.setAutoCommit(false);

            try (PreparedStatement ps =
                         conn.prepareStatement(UPSERT_SQL)) {

                for (AttendanceRecord r : records) {

                    // EmployeeId
                    ps.setInt(
                            1,
                            r.getEmployeeId()
                    );

                    // AttendanceDate
                    ps.setDate(
                            2,
                            Date.valueOf(r.getDate())
                    );

                    // CheckIn
                    if (r.getCheckIn() != null) {

                        ps.setTime(
                                3,
                                Time.valueOf(
                                        r.getCheckIn()
                                )
                        );

                    } else {

                        ps.setNull(
                                3,
                                java.sql.Types.TIME
                        );
                    }

                    // CheckOut
                    if (r.getCheckOut() != null) {

                        ps.setTime(
                                4,
                                Time.valueOf(
                                        r.getCheckOut()
                                )
                        );

                    } else {

                        ps.setNull(
                                4,
                                java.sql.Types.TIME
                        );
                    }

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


    // =========================================================
    // EMPLOYEE ATTENDANCE HISTORY
    // =========================================================

    /**
     * Lấy lịch sử chấm công của một nhân viên
     * theo khoảng thời gian.
     *
     * EmployeeCode và FullName được lấy từ users.
     */
    public List<AttendanceHistoryDTO>
    findByEmployeeAndDateRange(
            int employeeId,
            LocalDate fromDate,
            LocalDate toDate) throws Exception {

        List<AttendanceHistoryDTO> result =
                new ArrayList<AttendanceHistoryDTO>();


        try (Connection conn =
                     DBConnection.getConnection();

             PreparedStatement ps =
                     conn.prepareStatement(
                             FIND_HISTORY_SQL
                     )) {

            // EmployeeId
            ps.setInt(
                    1,
                    employeeId
            );

            // From date
            ps.setDate(
                    2,
                    Date.valueOf(fromDate)
            );

            // To date
            ps.setDate(
                    3,
                    Date.valueOf(toDate)
            );


            try (ResultSet rs =
                         ps.executeQuery()) {

                while (rs.next()) {

                    // =========================================
                    // DATE
                    // =========================================

                    Date sqlDate =
                            rs.getDate(
                                    "AttendanceDate"
                            );

                    LocalDate date = null;

                    if (sqlDate != null) {

                        date =
                                sqlDate.toLocalDate();
                    }


                    // =========================================
                    // CHECK IN
                    // =========================================

                    Time checkInTime =
                            rs.getTime(
                                    "CheckInTime"
                            );

                    LocalTime checkIn = null;

                    if (checkInTime != null) {

                        checkIn =
                                checkInTime.toLocalTime();
                    }


                    // =========================================
                    // CHECK OUT
                    // =========================================

                    Time checkOutTime =
                            rs.getTime(
                                    "CheckOutTime"
                            );

                    LocalTime checkOut = null;

                    if (checkOutTime != null) {

                        checkOut =
                                checkOutTime.toLocalTime();
                    }


                    // =========================================
                    // EMPLOYEE CODE
                    // =========================================

                    String employeeCode =
                            rs.getString(
                                    "EmployeeCode"
                            );


                    // =========================================
                    // FULL NAME
                    // =========================================

                    String fullName =
                            rs.getString(
                                    "FullName"
                            );


                    // =========================================
                    // LATE MINUTES
                    // =========================================

                    long lateMinutes = 0;

                    if (checkIn != null
                            && checkIn.isAfter(
                            STANDARD_CHECKIN)) {

                        lateMinutes =
                                Duration.between(
                                        STANDARD_CHECKIN,
                                        checkIn
                                ).toMinutes();
                    }


                    // =========================================
                    // STATUS
                    // =========================================

                    String status;

                    if (checkIn == null) {

                        status = "ABSENT";

                    } else if (checkOut == null) {

                        status = "MISSING_CHECKOUT";

                    } else if (lateMinutes > 0) {

                        status = "LATE";

                    } else {

                        status = "ON_TIME";
                    }


                    // =========================================
                    // CREATE DTO
                    // =========================================

                    AttendanceHistoryDTO dto =
                            new AttendanceHistoryDTO(
                                    date,
                                    checkIn,
                                    checkOut,
                                    lateMinutes,
                                    employeeCode,
                                    fullName,
                                    status
                            );


                    result.add(dto);
                }
            }
        }


        return result;
    }


    // =========================================================
    // SEARCH ATTENDANCE - MANAGER
    // =========================================================

    /**
     * Tìm kiếm dữ liệu chấm công cho Manager.
     *
     * Có thể filter:
     *
     * 1. Tên nhân viên
     * 2. Mã nhân viên
     * 3. Ngày
     *
     * Các điều kiện có thể kết hợp.
     */
    public List<AttendanceHistoryDTO>
    searchAttendance(
            String employeeName,
            String employeeCode,
            String date) throws Exception {


        List<AttendanceHistoryDTO> results =
                new ArrayList<AttendanceHistoryDTO>();


        // =====================================================
        // BUILD SQL
        // =====================================================

        StringBuilder sql =
                new StringBuilder();


        sql.append(
                "SELECT " +
                        "a.AttendanceDate, " +
                        "a.CheckInTime, " +
                        "a.CheckOutTime, " +
                        "u.EmployeeCode, " +
                        "u.FullName " +
                        "FROM attendance a " +
                        "JOIN users u " +
                        "ON a.EmployeeId = u.Id " +
                        "WHERE 1 = 1 "
        );


        List<Object> params =
                new ArrayList<Object>();


        // =====================================================
        // FILTER EMPLOYEE NAME
        // =====================================================

        if (employeeName != null
                && !employeeName.trim().isEmpty()) {

            sql.append(
                    "AND u.FullName LIKE ? "
            );

            params.add(
                    "%" +
                            employeeName.trim() +
                            "%"
            );
        }


        // =====================================================
        // FILTER EMPLOYEE CODE
        // =====================================================

        if (employeeCode != null
                && !employeeCode.trim().isEmpty()) {

            sql.append(
                    "AND u.EmployeeCode LIKE ? "
            );

            params.add(
                    "%" +
                            employeeCode.trim() +
                            "%"
            );
        }


        // =====================================================
        // FILTER DATE
        // =====================================================

        if (date != null
                && !date.trim().isEmpty()) {

            sql.append(
                    "AND a.AttendanceDate = ? "
            );

            params.add(
                    Date.valueOf(date)
            );
        }


        // =====================================================
        // ORDER
        // =====================================================

        sql.append(
                "ORDER BY " +
                        "a.AttendanceDate DESC, " +
                        "u.EmployeeCode ASC"
        );


        // =====================================================
        // EXECUTE SQL
        // =====================================================

        try (Connection conn =
                     DBConnection.getConnection();

             PreparedStatement ps =
                     conn.prepareStatement(
                             sql.toString()
                     )) {


            // =================================================
            // SET PARAMETERS
            // =================================================

            for (int i = 0;
                 i < params.size();
                 i++) {

                ps.setObject(
                        i + 1,
                        params.get(i)
                );
            }


            // =================================================
            // RESULT
            // =================================================

            try (ResultSet rs =
                         ps.executeQuery()) {


                while (rs.next()) {

                    // =========================================
                    // DATE
                    // =========================================

                    Date sqlDate =
                            rs.getDate(
                                    "AttendanceDate"
                            );

                    LocalDate recordDate = null;

                    if (sqlDate != null) {

                        recordDate =
                                sqlDate.toLocalDate();
                    }


                    // =========================================
                    // CHECK IN
                    // =========================================

                    Time checkInTime =
                            rs.getTime(
                                    "CheckInTime"
                            );

                    LocalTime checkIn = null;

                    if (checkInTime != null) {

                        checkIn =
                                checkInTime.toLocalTime();
                    }


                    // =========================================
                    // CHECK OUT
                    // =========================================

                    Time checkOutTime =
                            rs.getTime(
                                    "CheckOutTime"
                            );

                    LocalTime checkOut = null;

                    if (checkOutTime != null) {

                        checkOut =
                                checkOutTime.toLocalTime();
                    }


                    // =========================================
                    // EMPLOYEE CODE
                    // =========================================

                    String code =
                            rs.getString(
                                    "EmployeeCode"
                            );


                    // =========================================
                    // FULL NAME
                    // =========================================

                    String name =
                            rs.getString(
                                    "FullName"
                            );


                    // =========================================
                    // LATE MINUTES
                    // =========================================

                    long lateMinutes = 0;

                    if (checkIn != null
                            && checkIn.isAfter(
                            STANDARD_CHECKIN)) {

                        lateMinutes =
                                Duration.between(
                                        STANDARD_CHECKIN,
                                        checkIn
                                ).toMinutes();
                    }


                    // =========================================
                    // STATUS
                    // =========================================

                    String status;

                    if (checkIn == null) {

                        status = "ABSENT";

                    } else if (checkOut == null) {

                        status = "MISSING_CHECKOUT";

                    } else if (lateMinutes > 0) {

                        status = "LATE";

                    } else {

                        status = "ON_TIME";
                    }


                    // =========================================
                    // CREATE DTO
                    // =========================================

                    AttendanceHistoryDTO dto =
                            new AttendanceHistoryDTO(
                                    recordDate,
                                    checkIn,
                                    checkOut,
                                    lateMinutes,
                                    code,
                                    name,
                                    status
                            );


                    results.add(dto);
                }
            }
        }


        return results;
    }


    // =========================================================
    // FIND USER ID BY ACCOUNT ID
    // =========================================================

    /**
     * accounts.Id -> accounts.UserId -> users.Id
     */
    public Integer findUserIdByAccountId(
            int accountId) throws Exception {


        String sql =
                "SELECT UserId " +
                        "FROM accounts " +
                        "WHERE Id = ?";


        try (Connection conn =
                     DBConnection.getConnection();

             PreparedStatement ps =
                     conn.prepareStatement(sql)) {


            ps.setInt(
                    1,
                    accountId
            );


            try (ResultSet rs =
                         ps.executeQuery()) {


                if (rs.next()) {

                    return rs.getInt(
                            "UserId"
                    );
                }


                return null;
            }
        }
    }
}