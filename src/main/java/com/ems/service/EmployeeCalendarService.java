package com.ems.service;

import com.ems.dao.HolidayYearInstanceDAO;
import com.ems.dao.ShiftAssignmentCalendarDAO;
import com.ems.dao.WorkScheduleDAO;
import com.ems.dto.EmployeeCalendarDayDTO;
import com.ems.dto.ShiftAssignmentDayDTO;
import com.ems.model.HolidayYearInstance;
import com.ems.model.Shifts;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Service render lịch làm việc theo tháng cho một nhân viên.
 *
 * Kiến trúc Fallback (ưu tiên giảm dần):
 *   1. HOLIDAY    – ngày lễ quốc gia / công ty
 *   2. OVERRIDE   – ca được gán riêng (ca bù, OT) qua shiftassignmentbatches
 *   3. DEFAULT    – lịch chuẩn công ty tra từ bảng shifts (versioned)
 *   4. OFF/WEEKEND – mặc định an toàn khi không có rule nào cover
 *
 * Hiệu năng: chỉ 3 DB call cho toàn bộ tháng, toàn bộ nội suy thực hiện trên RAM.
 */
public class EmployeeCalendarService {

    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("HH:mm");

    public List<EmployeeCalendarDayDTO> getMonthCalendar(int employeeId, int year, int month) {
        YearMonth ym    = YearMonth.of(year, month);
        LocalDate from  = ym.atDay(1);
        LocalDate to    = ym.atEndOfMonth();

        // ── DB Call 1: Ngày lễ ─────────────────────────────────────────────
        List<HolidayYearInstance> holidays = HolidayYearInstanceDAO.getInstanceInRange(from, to);

        // ── DB Call 2: Ca override (ca bù / OT) ───────────────────────────
        Map<LocalDate, ShiftAssignmentDayDTO> overrides =
                ShiftAssignmentCalendarDAO.getOverrideMap(employeeId, from, to);

        // ── DB Call 3: Tất cả version lịch mặc định giao với tháng ────────
        List<Shifts> defaultShifts = WorkScheduleDAO.getDefaultShiftsInRange(from, to);

        // ── Nội suy 30/31 ngày trên RAM ────────────────────────────────────
        List<EmployeeCalendarDayDTO> result = new ArrayList<>();

        for (LocalDate d = from; !d.isAfter(to); d = d.plusDays(1)) {
            EmployeeCalendarDayDTO dto = new EmployeeCalendarDayDTO();
            dto.setDate(d.toString());
            dto.setDayOfMonth(d.getDayOfMonth());

            // Ưu tiên 1: Ngày Lễ
            HolidayYearInstance holiday = findHolidayForDate(holidays, d);
            if (holiday != null) {
                dto.setDayType("HOLIDAY");
                dto.setHolidayName(holiday.getHolidayName());
                dto.setHolidayCoefficient(holiday.getCoefficient());
                result.add(dto);
                continue;
            }

            // Ưu tiên 2: Ca override (ca bù / OT) — tra O(1) qua Map
            ShiftAssignmentDayDTO override = overrides.get(d);
            if (override != null) {
                dto.setDayType("WORK");
                dto.setShiftName(override.getShiftName());
                dto.setShiftTime(formatTime(override.getStartTime(), override.getEndTime()));
                result.add(dto);
                continue;
            }

            // Ưu tiên 3: Lịch mặc định (Fallback versioned)
            // DayOfWeek DB convention: 1=Chủ Nhật, 2=Thứ Hai ... 7=Thứ Bảy
            // Java DayOfWeek: MONDAY=1 ... SUNDAY=7 → Cần map lại
            int dbDow = (d.getDayOfWeek().getValue() % 7) + 1;
            boolean found = false;
            for (Shifts s : defaultShifts) {
                // Kiểm tra cùng thứ VÀ ngày nằm trong hiệu lực của version luật này
                if (s.getDayOfweek() != dbDow) continue;

                LocalDate esd = s.getEffectiveStartDate();
                LocalDate eed = s.getEffectiveEndDate();
                boolean effective = (esd != null && !d.isBefore(esd))
                                 && (eed == null  || !d.isAfter(eed));
                if (!effective) continue;

                // Tìm thấy rule áp dụng cho ngày này
                if (Boolean.TRUE.equals(s.getIsactive())) {
                    dto.setDayType("WORK");
                    dto.setShiftName(s.getName());
                    dto.setShiftTime(formatTime(s.getStarttime(), s.getEndtime()));
                } else {
                    dto.setDayType("OFF"); // Luật ghi tường minh: ngày nghỉ
                }
                found = true;
                break;
            }

            // Ưu tiên 4: Fallback an toàn — chưa có rule nào
            if (!found) {
                dto.setDayType(d.getDayOfWeek() == DayOfWeek.SUNDAY ? "WEEKEND" : "OFF");
            }

            result.add(dto);
        }
        return result;
    }

    // ──────────────────────────────────────────────────────────────────────
    // Private helpers
    // ──────────────────────────────────────────────────────────────────────

    private HolidayYearInstance findHolidayForDate(List<HolidayYearInstance> holidays, LocalDate date) {
        for (HolidayYearInstance h : holidays) {
            if (!date.isBefore(h.getStartDate()) && !date.isAfter(h.getEndDate())) return h;
        }
        return null;
    }

    private String formatTime(LocalTime start, LocalTime end) {
        String s = (start != null) ? start.format(TIME_FMT) : "--:--";
        String e = (end   != null) ? end.format(TIME_FMT)   : "--:--";
        return s + " - " + e;
    }
}