package com.ems.dao;

import com.ems.dto.ShiftAssignmentDayDTO;
import com.ems.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

public class ShiftAssignmentCalendarDAO {

    /** Rule nội bộ của 1 batch, dùng để expand ra từng ngày cụ thể trong khoảng cần xem */
    private static class BatchRule {
        int batchId;
        int shiftId;
        String shiftName;
        LocalTime shiftStart;
        LocalTime shiftEnd;
        LocalDate startDate;
        LocalDate endDate;          // null = vô hạn
        String recurType;           // NONE / WEEKLY / MONTHLY
        int recurInterval;
        String monthlyType;         // WEEKDAY / DATE
        Integer monthlyWeekday;     // 1=Mon..7=Sun
        Integer monthlyOccurrence;  // 1..4, hoặc -1 = lần cuối cùng trong tháng
        Integer monthlyDay;
        Set<Integer> weekdays = new HashSet<>(); // dùng cho WEEKLY, 1=Mon..7=Sun
    }

    /**
     * Lấy danh sách ngày làm việc cụ thể của 1 nhân viên trong [from, to],
     * expand trực tiếp từ shiftassignmentbatches (KHÔNG dùng bảng shiftassignments
     * vì luồng phân ca hiện tại không ghi vào bảng đó).
     */
    public static List<ShiftAssignmentDayDTO> getAssignmentsForEmployee(int employeeId, LocalDate from, LocalDate to) {
        List<BatchRule> rules = loadCandidateBatches(employeeId, from, to);
        Map<LocalDate, ShiftAssignmentDayDTO> byDate = new TreeMap<>();

        for (BatchRule r : rules) {
            LocalDate rangeStart = from.isAfter(r.startDate) ? from : r.startDate;
            LocalDate rangeEnd = (r.endDate != null && r.endDate.isBefore(to)) ? r.endDate : to;
            if (rangeStart.isAfter(rangeEnd)) continue;

            for (LocalDate d = rangeStart; !d.isAfter(rangeEnd); d = d.plusDays(1)) {
                if (!matches(r, d)) continue;

                ShiftAssignmentDayDTO dto = new ShiftAssignmentDayDTO();
                dto.setDate(d);
                dto.setShiftId(r.shiftId);
                dto.setShiftName(r.shiftName);
                dto.setStartTime(r.shiftStart);
                dto.setEndTime(r.shiftEnd);
                dto.setBatchId(r.batchId);

                // Nếu 2 batch trùng ngày (bình thường không xảy ra vì đã chặn conflict lúc tạo),
                // ưu tiên batch có Id lớn hơn (tạo/gán sau)
                ShiftAssignmentDayDTO existed = byDate.get(d);
                if (existed == null || dto.getBatchId() >= existed.getBatchId()) {
                    byDate.put(d, dto);
                }
            }
        }
        return new ArrayList<>(byDate.values());
    }

    /**
     * Trả về Map<LocalDate, ShiftAssignmentDayDTO> của các ca được gán riêng (override / ca bù / OT)
     * trong khoảng [from, to] cho nhân viên employeeId.
     * Tiện dụng cho EmployeeCalendarService để tra cứu O(1) thay vì O(n) list scan.
     */
    public static Map<LocalDate, ShiftAssignmentDayDTO> getOverrideMap(int employeeId, LocalDate from, LocalDate to) {
        List<ShiftAssignmentDayDTO> list = getAssignmentsForEmployee(employeeId, from, to);
        Map<LocalDate, ShiftAssignmentDayDTO> map = new java.util.HashMap<>();
        for (ShiftAssignmentDayDTO dto : list) {
            map.put(dto.getDate(), dto);
        }
        return map;
    }

    private static boolean matches(BatchRule r, LocalDate d) {
        switch (r.recurType) {
            case "NONE":    return true; // đã giới hạn theo range ở ngoài rồi
            case "WEEKLY":  return matchesWeekly(r, d);
            case "MONTHLY": return matchesMonthly(r, d);
            default:        return false;
        }
    }

    private static boolean matchesWeekly(BatchRule r, LocalDate d) {
        int javaDow = d.getDayOfWeek().getValue(); // 1=Mon..7=Sun
        int appDow  = (javaDow == 7) ? 1 : javaDow + 1; // 1=CN, 2=T2..7=T7
        if (!r.weekdays.contains(appDow)) return false;
        if (r.recurInterval <= 1) return true;

        LocalDate startMonday = r.startDate.minusDays(r.startDate.getDayOfWeek().getValue() - 1L);
        LocalDate dMonday = d.minusDays(d.getDayOfWeek().getValue() - 1L);
        long weeksBetween = ChronoUnit.WEEKS.between(startMonday, dMonday);
        return weeksBetween % r.recurInterval == 0;
    }

    private static boolean matchesMonthly(BatchRule r, LocalDate d) {
        long monthsBetween = ChronoUnit.MONTHS.between(r.startDate.withDayOfMonth(1), d.withDayOfMonth(1));
        if (monthsBetween < 0) return false;
        if (r.recurInterval > 1 && monthsBetween % r.recurInterval != 0) return false;

        if ("DATE".equals(r.monthlyType)) {
            if (r.monthlyDay == null) return false;
            int targetDay = Math.min(r.monthlyDay, d.lengthOfMonth()); // clamp ngày 31 vào tháng thiếu ngày
            return d.getDayOfMonth() == targetDay;
        }
        if ("WEEKDAY".equals(r.monthlyType)) {
            if (r.monthlyWeekday == null || r.monthlyOccurrence == null) return false;
            int javaDow = d.getDayOfWeek().getValue();
            int appDow  = (javaDow == 7) ? 1 : javaDow + 1; // 1=CN, 2=T2..7=T7
            if (appDow != r.monthlyWeekday) return false;
            
            if (r.monthlyOccurrence == -1) {
                return d.plusDays(7).getMonthValue() != d.getMonthValue(); // lần cuối cùng của weekday trong tháng
            }
            int occurrence = (d.getDayOfMonth() - 1) / 7 + 1;
            return occurrence == r.monthlyOccurrence;
        }
        return false;
    }

    private static List<BatchRule> loadCandidateBatches(int employeeId, LocalDate from, LocalDate to) {
        Map<Integer, BatchRule> rules = new LinkedHashMap<>();
        String sql =
                "SELECT b.Id, b.ShiftId, s.Name AS ShiftName, s.StartTime, s.EndTime, " +
                        "       b.StartDate, b.EndDate, b.RecurType, b.RecurInterval, " +
                        "       b.MonthlyType, b.MonthlyWeekday, b.MonthlyOccurrence, b.MonthlyDay " +
                        "FROM shiftassignmentbatches b " +
                        "JOIN shiftassignmentbatch_employees be ON be.BatchId = b.Id " +
                        "JOIN shifts s ON s.Id = b.ShiftId " +
                        "WHERE be.EmployeeId = ? " +
                        "  AND b.StartDate <= ? " +
                        "  AND COALESCE(b.EndDate, '9999-12-31') >= ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            ps.setObject(2, to);
            ps.setObject(3, from);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BatchRule r = new BatchRule();
                    r.batchId = rs.getInt("Id");
                    r.shiftId = rs.getInt("ShiftId");
                    r.shiftName = rs.getString("ShiftName");
                    r.shiftStart = toLocalTime(rs.getTime("StartTime"));
                    r.shiftEnd = toLocalTime(rs.getTime("EndTime"));
                    r.startDate = rs.getDate("StartDate").toLocalDate();

                    java.sql.Date ed = rs.getDate("EndDate");
                    r.endDate = ed != null ? ed.toLocalDate() : null;

                    r.recurType = rs.getString("RecurType");
                    r.recurInterval = rs.getInt("RecurInterval");
                    r.monthlyType = rs.getString("MonthlyType");

                    int mw = rs.getInt("MonthlyWeekday"); r.monthlyWeekday = rs.wasNull() ? null : mw;
                    int mo = rs.getInt("MonthlyOccurrence"); r.monthlyOccurrence = rs.wasNull() ? null : mo;
                    int md = rs.getInt("MonthlyDay"); r.monthlyDay = rs.wasNull() ? null : md;

                    rules.put(r.batchId, r);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        if (!rules.isEmpty()) loadWeekdaysInto(rules);
        return new ArrayList<>(rules.values());
    }

    private static void loadWeekdaysInto(Map<Integer, BatchRule> rules) {
        StringBuilder inClause = new StringBuilder();
        for (int i = 0; i < rules.size(); i++) inClause.append(i > 0 ? ",?" : "?");
        String sql = "SELECT BatchId, DayOfWeek FROM shiftassignmentbatch_weekdays WHERE BatchId IN (" + inClause + ")";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            for (Integer batchId : rules.keySet()) ps.setInt(idx++, batchId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BatchRule r = rules.get(rs.getInt("BatchId"));
                    if (r != null) r.weekdays.add(rs.getInt("DayOfWeek"));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    private static LocalTime toLocalTime(Time t) { return t != null ? t.toLocalTime() : null; }
}