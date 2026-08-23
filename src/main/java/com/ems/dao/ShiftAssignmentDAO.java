package com.ems.dao;

import com.ems.dto.ShiftAssignmentBatchDTO;
import com.ems.dto.EmployeeDTO;
import com.ems.dto.DepartmentDTO;
import com.ems.model.Shiftassignmentbatches;
import com.ems.util.DBConnection;

import java.sql.*;
import java.sql.Date;
import java.util.*;

public class ShiftAssignmentDAO {

    // ─────────────────────────────────────────────
    //  READ
    // ─────────────────────────────────────────────

    /**
     * Lấy tất cả batch phân ca (JOIN shifts, accounts)
     */
    public static List<ShiftAssignmentBatchDTO> getAllBatches() {
        List<ShiftAssignmentBatchDTO> list = new ArrayList<>();
        String sql =
                "SELECT b.Id, b.Name, b.ShiftId, s.Name AS ShiftName, " +
                        "   s.StartTime, s.EndTime, " +
                        "   b.StartDate, b.EndDate, b.RecurType, b.RecurInterval, " +
                        "   b.MonthlyType, b.MonthlyWeekday, b.MonthlyOccurrence, b.MonthlyDay, " +
                        "   b.CreatedBy, b.CreatedAt, a.Username AS CreatedByName, " +
                        "   (SELECT COUNT(*) FROM shiftassignmentbatch_employees e WHERE e.BatchId = b.Id) AS EmpCount " +
                        "FROM shiftassignmentbatches b " +
                        "JOIN shifts s ON b.ShiftId = s.Id " +
                        "LEFT JOIN accounts a ON b.CreatedBy = a.Id " +
                        "ORDER BY b.CreatedAt DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ShiftAssignmentBatchDTO dto = mapBatch(rs);
                dto.setEmployeeCount(rs.getInt("EmpCount"));
                list.add(dto);
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        // Load weekdays cho mỗi batch
        for (ShiftAssignmentBatchDTO dto : list) {
            dto.setWeekdays(getWeekdays(dto.getId()));
            dto.setEmployeeIds(getEmployeeIds(dto.getId()));
            dto.setEmployeeNames(getEmployeeNames(dto.getId()));
        }
        return list;
    }

    /**
     * Lấy 1 batch theo id (dùng cho trang sửa)
     */
    public static ShiftAssignmentBatchDTO getBatchById(int id) {
        String sql =
                "SELECT b.Id, b.Name, b.ShiftId, s.Name AS ShiftName, " +
                        "   s.StartTime, s.EndTime, " +
                        "   b.StartDate, b.EndDate, b.RecurType, b.RecurInterval, " +
                        "   b.MonthlyType, b.MonthlyWeekday, b.MonthlyOccurrence, b.MonthlyDay, " +
                        "   b.CreatedBy, b.CreatedAt, a.Username AS CreatedByName, 0 AS EmpCount " +
                        "FROM shiftassignmentbatches b " +
                        "JOIN shifts s ON b.ShiftId = s.Id " +
                        "LEFT JOIN accounts a ON b.CreatedBy = a.Id " +
                        "WHERE b.Id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ShiftAssignmentBatchDTO dto = mapBatch(rs);
                    dto.setWeekdays(getWeekdays(id));
                    dto.setEmployeeIds(getEmployeeIds(id));
                    dto.setEmployeeNames(getEmployeeNames(id));
                    dto.setEmployeeCount(dto.getEmployeeIds() != null ? dto.getEmployeeIds().size() : 0);
                    return dto;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return null;
    }

    /**
     * Lấy danh sách ngày trong tuần của batch
     */
    private static List<Integer> getWeekdays(int batchId) {
        List<Integer> days = new ArrayList<>();
        String sql = "SELECT DayOfWeek FROM shiftassignmentbatch_weekdays WHERE BatchId = ? ORDER BY DayOfWeek";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, batchId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) days.add(rs.getInt("DayOfWeek"));
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return days;
    }

    /**
     * Lấy danh sách EmployeeId của batch
     */
    private static List<Integer> getEmployeeIds(int batchId) {
        List<Integer> ids = new ArrayList<>();
        String sql = "SELECT EmployeeId FROM shiftassignmentbatch_employees WHERE BatchId = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, batchId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) ids.add(rs.getInt("EmployeeId"));
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return ids;
    }

    /**
     * Lấy đầy đủ thông tin nhân viên (mã NV, họ tên, phòng ban) của 1 batch.
     * Dùng cho ExportAttendanceServlet khi tạo file Excel template chấm công.
     */
    public static List<EmployeeDTO> getEmployeesOfBatch(int batchId) {
        List<EmployeeDTO> list = new ArrayList<>();
        String sql =
                "SELECT u.Id, u.EmployeeCode, u.FullName, d.Name AS DeptName " +
                "FROM shiftassignmentbatch_employees e " +
                "JOIN users u ON e.EmployeeId = u.Id " +
                "LEFT JOIN departments d ON u.DepartmentId = d.Id " +
                "WHERE e.BatchId = ? ORDER BY u.FullName";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, batchId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new EmployeeDTO(
                            rs.getInt("Id"),
                            rs.getString("EmployeeCode"),
                            rs.getString("FullName"),
                            rs.getString("DeptName")));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return list;
    }

    /**
     * Lấy danh sách tên nhân viên của batch
     */
    private static List<String> getEmployeeNames(int batchId) {
        List<String> names = new ArrayList<>();
        String sql =
                "SELECT u.FullName FROM shiftassignmentbatch_employees e " +
                        "JOIN users u ON e.EmployeeId = u.Id WHERE e.BatchId = ? ORDER BY u.FullName";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, batchId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) names.add(rs.getString("FullName"));
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return names;
    }

    // ─────────────────────────────────────────────
    //  WRITE
    // ─────────────────────────────────────────────

    /**
     * Tạo batch mới + weekdays + employees (transaction)
     */
    public static void createBatch(Shiftassignmentbatches b,
                                   List<Integer> weekdays,
                                   List<Integer> empIds) {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int batchId = insertBatch(conn, b);
                insertWeekdays(conn, batchId, weekdays);
                insertEmployees(conn, batchId, empIds);
                conn.commit();
            } catch (SQLException ex) {
                conn.rollback();
                throw new RuntimeException(ex);
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * Cập nhật batch (xóa weekdays + employees cũ rồi insert lại)
     */
    public static void updateBatch(Shiftassignmentbatches b,
                                   List<Integer> weekdays,
                                   List<Integer> empIds) {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                updateBatchRow(conn, b);
                // Xóa cũ (cascade đã xóa weekdays/employees nhưng ta xóa tường minh để chắc chắn)
                deleteChildren(conn, b.getId());
                insertWeekdays(conn, b.getId(), weekdays);
                insertEmployees(conn, b.getId(), empIds);
                conn.commit();
            } catch (SQLException ex) {
                conn.rollback();
                throw new RuntimeException(ex);
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * Xóa batch (cascade xóa weekdays + employees tự động)
     */
    public static void deleteBatch(int id) {
        String sql = "DELETE FROM shiftassignmentbatches WHERE Id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    // ─────────────────────────────────────────────
    //  EMPLOYEE / DEPARTMENT LOOKUP
    // ─────────────────────────────────────────────

    /**
     * Lấy tất cả nhân viên (để hiện trong dropdown/table chọn)
     */
    public static List<EmployeeDTO> getAllEmployees() {
        List<EmployeeDTO> list = new ArrayList<>();
        String sql =
                "SELECT u.Id, u.EmployeeCode, u.FullName, d.Name AS DepartmentName " +
                        "FROM users u " +
                        "JOIN departments d ON u.DepartmentId = d.Id " +
                        "WHERE u.Status = 1 " +
                        "ORDER BY u.FullName";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapEmployee(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return list;
    }

    /**
     * Lấy tất cả phòng ban
     */
    public static List<DepartmentDTO> getAllDepartments() {
        List<DepartmentDTO> list = new ArrayList<>();
        String sql = "SELECT Id, Name FROM departments ORDER BY Name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new DepartmentDTO(rs.getInt("Id"), rs.getString("Name")));
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return list;
    }

    /**
     * Lấy danh sách nhân viên theo phòng ban
     */
    public static List<EmployeeDTO> getEmployeesByDept(int deptId) {
        List<EmployeeDTO> list = new ArrayList<>();
        String sql =
                "SELECT u.Id, u.EmployeeCode, u.FullName, d.Name AS DepartmentName " +
                        "FROM users u " +
                        "JOIN departments d ON u.DepartmentId = d.Id " +
                        "WHERE u.Status = 1 AND u.DepartmentId = ? " +
                        "ORDER BY u.FullName";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, deptId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapEmployee(rs));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return list;
    }

    private static EmployeeDTO mapEmployee(ResultSet rs) throws SQLException {
        return new EmployeeDTO(
                rs.getInt("Id"),
                rs.getString("EmployeeCode"),
                rs.getString("FullName"),
                rs.getString("DepartmentName")
        );
    }

    // ─────────────────────────────────────────────
    //  Private helpers
    // ─────────────────────────────────────────────

    private static int insertBatch(Connection conn, Shiftassignmentbatches b) throws SQLException {
        String sql =
                "INSERT INTO shiftassignmentbatches " +
                        "(Name, ShiftId, StartDate, EndDate, RecurType, RecurInterval, " +
                        " MonthlyType, MonthlyWeekday, MonthlyOccurrence, MonthlyDay, CreatedBy) " +
                        "VALUES (?,?,?,?,?,?,?,?,?,?,?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, b.getName());
            ps.setInt(2, b.getShiftId());
            ps.setDate(3, Date.valueOf(b.getStartDate()));
            ps.setObject(4, b.getEndDate() != null ? Date.valueOf(b.getEndDate()) : null);
            ps.setString(5, b.getRecurType());
            ps.setInt(6, b.getRecurInterval() != null ? b.getRecurInterval() : 1);
            ps.setObject(7, b.getMonthlyType());
            ps.setObject(8, b.getMonthlyWeekday());
            ps.setObject(9, b.getMonthlyOccurrence());
            ps.setObject(10, b.getMonthlyDay());
            ps.setObject(11, b.getCreatedBy());
            ps.executeUpdate();
            try (ResultSet gk = ps.getGeneratedKeys()) {
                if (gk.next()) return gk.getInt(1);
            }
        }
        throw new SQLException("Không thể tạo batch");
    }

    private static void updateBatchRow(Connection conn, Shiftassignmentbatches b) throws SQLException {
        String sql =
                "UPDATE shiftassignmentbatches SET " +
                        "Name=?, ShiftId=?, StartDate=?, EndDate=?, RecurType=?, RecurInterval=?, " +
                        "MonthlyType=?, MonthlyWeekday=?, MonthlyOccurrence=?, MonthlyDay=? " +
                        "WHERE Id=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, b.getName());
            ps.setInt(2, b.getShiftId());
            ps.setDate(3, Date.valueOf(b.getStartDate()));
            ps.setObject(4, b.getEndDate() != null ? Date.valueOf(b.getEndDate()) : null);
            ps.setString(5, b.getRecurType());
            ps.setInt(6, b.getRecurInterval() != null ? b.getRecurInterval() : 1);
            ps.setObject(7, b.getMonthlyType());
            ps.setObject(8, b.getMonthlyWeekday());
            ps.setObject(9, b.getMonthlyOccurrence());
            ps.setObject(10, b.getMonthlyDay());
            ps.setInt(11, b.getId());
            ps.executeUpdate();
        }
    }

    private static void deleteChildren(Connection conn, int batchId) throws SQLException {
        for (String table : new String[]{"shiftassignmentbatch_weekdays", "shiftassignmentbatch_employees"}) {
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM " + table + " WHERE BatchId = ?")) {
                ps.setInt(1, batchId);
                ps.executeUpdate();
            }
        }
    }

    private static void insertWeekdays(Connection conn, int batchId, List<Integer> days) throws SQLException {
        if (days == null || days.isEmpty()) return;
        String sql = "INSERT INTO shiftassignmentbatch_weekdays (BatchId, DayOfWeek) VALUES (?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int d : days) {
                ps.setInt(1, batchId);
                ps.setInt(2, d);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    private static void insertEmployees(Connection conn, int batchId, List<Integer> empIds) throws SQLException {
        if (empIds == null || empIds.isEmpty()) return;
        String sql = "INSERT INTO shiftassignmentbatch_employees (BatchId, EmployeeId) VALUES (?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int empId : empIds) {
                ps.setInt(1, batchId);
                ps.setInt(2, empId);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    private static ShiftAssignmentBatchDTO mapBatch(ResultSet rs) throws SQLException {
        ShiftAssignmentBatchDTO dto = new ShiftAssignmentBatchDTO();
        dto.setId(rs.getInt("Id"));
        dto.setName(rs.getString("Name"));
        dto.setShiftId(rs.getInt("ShiftId"));
        dto.setShiftName(rs.getString("ShiftName"));

        // Build shiftTime string
        Time st = rs.getTime("StartTime");
        Time et = rs.getTime("EndTime");
        if (st != null && et != null) {
            dto.setShiftTime(st.toLocalTime().toString() + " - " + et.toLocalTime().toString());
        }

        Date sd = rs.getDate("StartDate");
        Date ed = rs.getDate("EndDate");
        dto.setStartDate(sd != null ? sd.toLocalDate() : null);
        dto.setEndDate(ed != null ? ed.toLocalDate() : null);
        dto.setRecurType(rs.getString("RecurType"));
        dto.setRecurInterval(rs.getInt("RecurInterval"));
        dto.setMonthlyType(rs.getString("MonthlyType"));

        int mw = rs.getInt("MonthlyWeekday");
        dto.setMonthlyWeekday(rs.wasNull() ? null : mw);
        int mo = rs.getInt("MonthlyOccurrence");
        dto.setMonthlyOccurrence(rs.wasNull() ? null : mo);
        int md = rs.getInt("MonthlyDay");
        dto.setMonthlyDay(rs.wasNull() ? null : md);

        dto.setCreatedByName(rs.getString("CreatedByName"));
        Timestamp ts = rs.getTimestamp("CreatedAt");
        if (ts != null) dto.setCreatedAt(ts.toLocalDateTime());
        return dto;
    }

    // ─────────────────────────────────────────────
    //  CONFLICT DETECTION
    // ─────────────────────────────────────────────

    /**
     * Tìm các nhân viên bị xung đột ca làm việc (Mức 1):
     *   1. Khoảng ngày áp dụng giao nhau (date range overlap)
     *   2. Cùng nhân viên
     *   3. Giờ làm của 2 ca chồng nhau (time overlap)
     *
     * @param newBatch       batch phân ca mới (chứa shiftId, startDate, endDate)
     * @param empIds         danh sách EmployeeId được chọn trong batch mới
     * @param excludeBatchId id của batch đang sửa (truyền null khi tạo mới) — tránh tự so sánh với chính mình
     * @return danh sách tên nhân viên bị conflict (rỗng = không có conflict)
     */
    public static List<String> findConflictingEmployees(
            Shiftassignmentbatches newBatch,
            List<Integer> weekdays,
            List<Integer> empIds,
            Integer excludeBatchId) {

        if (empIds == null || empIds.isEmpty()) return new ArrayList<>();

        // Build IN-clause placeholder for empIds: (?,?,?...)
        StringBuilder empInClause = new StringBuilder();
        for (int i = 0; i < empIds.size(); i++) {
            if (i > 0) empInClause.append(",");
            empInClause.append("?");
        }

        // Build IN-clause for weekdays if newBatch is WEEKLY
        boolean isWeekly = "WEEKLY".equals(newBatch.getRecurType()) && weekdays != null && !weekdays.isEmpty();
        StringBuilder weekdayInClause = new StringBuilder();
        if (isWeekly) {
            for (int i = 0; i < weekdays.size(); i++) {
                if (i > 0) weekdayInClause.append(",");
                weekdayInClause.append("?");
            }
        } else {
            // Default safe clause so SQL doesn't break. We won't bind anything to it since it's short-circuited.
            weekdayInClause.append("-1");
        }

        /*
         * Logic SQL:
         *  - Khoảng ngày giao nhau
         *  - Giờ làm chồng nhau
         *  - Nếu cả 2 đều là WEEKLY, bắt buộc phải có ngày trong tuần (Weekday) chung mới là conflict.
         */
        String sql =
            "SELECT DISTINCT u.FullName, s_old.Name AS OldShiftName, " +
            "       s_old.StartTime AS OldStart, s_old.EndTime AS OldEnd " +
            "FROM shiftassignmentbatch_employees be2 " +
            "JOIN shiftassignmentbatches b2    ON be2.BatchId = b2.Id " +
            "JOIN shifts s_new                 ON s_new.Id = ? " +
            "JOIN shifts s_old                 ON s_old.Id = b2.ShiftId " +
            "JOIN users u                      ON be2.EmployeeId = u.Id " +
            "WHERE be2.EmployeeId IN (" + empInClause + ") " +
            "  AND (? IS NULL OR b2.Id != ?) " +
            "  AND b2.StartDate <= COALESCE(?, '9999-12-31') " +
            "  AND COALESCE(b2.EndDate, '9999-12-31') >= ? " +
            "  AND s_old.StartTime < s_new.EndTime " +
            "  AND s_new.StartTime < s_old.EndTime " +
            "  AND (" +
            "    ? != 'WEEKLY' OR b2.RecurType != 'WEEKLY' " +
            "    OR EXISTS (" +
            "      SELECT 1 FROM shiftassignmentbatch_weekdays wd_old " +
            "      WHERE wd_old.BatchId = b2.Id " +
            "        AND wd_old.DayOfWeek IN (" + weekdayInClause + ")" +
            "    )" +
            "  ) " +
            "ORDER BY u.FullName";

        List<String> conflicts = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            int idx = 1;
            ps.setInt(idx++, newBatch.getShiftId());

            // Bind empIds
            for (Integer empId : empIds) {
                ps.setInt(idx++, empId);
            }

            // Bind excludeBatchId
            if (excludeBatchId != null) {
                ps.setInt(idx++, excludeBatchId);
                ps.setInt(idx++, excludeBatchId);
            } else {
                ps.setNull(idx++, java.sql.Types.INTEGER);
                ps.setNull(idx++, java.sql.Types.INTEGER);
            }

            // Bind endDate
            if (newBatch.getEndDate() != null) {
                ps.setDate(idx++, java.sql.Date.valueOf(newBatch.getEndDate()));
            } else {
                ps.setDate(idx++, java.sql.Date.valueOf(java.time.LocalDate.of(9999, 12, 31)));
            }

            // Bind startDate
            ps.setDate(idx++, java.sql.Date.valueOf(newBatch.getStartDate()));

            // Bind recurType (for ? != 'WEEKLY')
            ps.setString(idx++, newBatch.getRecurType() != null ? newBatch.getRecurType() : "NONE");

            // Bind weekdays if isWeekly
            if (isWeekly) {
                for (Integer wd : weekdays) {
                    ps.setInt(idx++, wd);
                }
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String name      = rs.getString("FullName");
                    String shiftName = rs.getString("OldShiftName");
                    java.sql.Time oStart = rs.getTime("OldStart");
                    java.sql.Time oEnd   = rs.getTime("OldEnd");
                    String timeRange = (oStart != null && oEnd != null)
                            ? " (" + oStart.toLocalTime() + " - " + oEnd.toLocalTime() + ")"
                            : "";
                    conflicts.add(name + " [ca: " + shiftName + timeRange + "]");
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi kiểm tra conflict phân ca: " + e.getMessage(), e);
        }
        return conflicts;
    }
}