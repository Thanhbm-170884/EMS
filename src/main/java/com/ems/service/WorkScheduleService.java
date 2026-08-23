package com.ems.service;

import com.ems.dao.WorkScheduleDAO;
import com.ems.dto.ShiftDTO;
import com.ems.model.Shifts;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

public class WorkScheduleService {

    // ──────────────────────────────────────────────────────────────────────
    // Save
    // ──────────────────────────────────────────────────────────────────────

    /**
     * Lưu bộ lịch làm việc mới với versioning.
     * - Chốt EffectiveEndDate của bộ cũ = effectiveDate - 1 ngày.
     * - Insert bộ mới với EffectiveStartDate = effectiveDate.
     *
     * @param shiftDTOS    7 bản ghi đại diện Thứ 2 → Chủ nhật
     * @param effectiveDate ngày bắt đầu áp dụng bộ lịch mới (thường do HR chọn từ form)
     */
    public void saveNewDefaultSchedule(List<ShiftDTO> shiftDTOS, LocalDate effectiveDate) {
        List<Shifts> list = parseToModel(shiftDTOS);
        WorkScheduleDAO.saveNewDefaultSchedule(list, effectiveDate);
    }

    /**
     * Backward-compatible: nếu gọi không có effectiveDate → dùng ngày hôm nay.
     * Dùng khi đây là lần đầu tạo lịch (bảng shifts trống).
     */
    public void saveWorkSchedule(List<ShiftDTO> shiftDTOS) {
        saveNewDefaultSchedule(shiftDTOS, LocalDate.now());
    }

    // ──────────────────────────────────────────────────────────────────────
    // Read
    // ──────────────────────────────────────────────────────────────────────

    /**
     * Lấy bộ lịch đang active (EffectiveEndDate IS NULL) để hiển thị trang setting.
     */
    public List<ShiftDTO> getWorkSchedule() {
        List<Shifts> shifts = WorkScheduleDAO.getWeekDefaultShift();
        List<ShiftDTO> result = new ArrayList<>();
        for (Shifts s : shifts) {
            ShiftDTO dto = new ShiftDTO();
            dto.setDayOfWeek(s.getDayOfweek());
            dto.setWorking(Boolean.TRUE.equals(s.getIsactive()));
            dto.setStartTime(s.getStarttime() != null ? s.getStarttime().toString() : null);
            dto.setEndTime(s.getEndtime()     != null ? s.getEndtime().toString()   : null);
            dto.setBreakStart(s.getBreakstart() != null ? s.getBreakstart().toString() : null);
            dto.setBreakEnd(s.getBreakend()     != null ? s.getBreakend().toString()   : null);
            // effectiveDate dùng cho display nếu cần
            if (s.getEffectiveStartDate() != null) {
                dto.setEffectiveDate(s.getEffectiveStartDate().toString());
            }
            result.add(dto);
        }
        return result;
    }

    // ──────────────────────────────────────────────────────────────────────
    // Private helper
    // ──────────────────────────────────────────────────────────────────────

    private List<Shifts> parseToModel(List<ShiftDTO> dtos) {
        List<Shifts> list = new ArrayList<>();
        for (ShiftDTO dto : dtos) {
            Shifts shift = new Shifts();
            shift.setDayOfweek(dto.getDayOfWeek());
            boolean working = Boolean.TRUE.equals(dto.getWorking());
            shift.setIsactive(working);
            if (working) {
                shift.setStarttime(parseTimeSafe(dto.getStartTime()));
                shift.setEndtime(parseTimeSafe(dto.getEndTime()));
                shift.setBreakstart(parseTimeSafe(dto.getBreakStart()));
                shift.setBreakend(parseTimeSafe(dto.getBreakEnd()));
            } else {
                shift.setStarttime(null);
                shift.setEndtime(null);
                shift.setBreakstart(null);
                shift.setBreakend(null);
            }
            list.add(shift);
        }
        return list;
    }

    private static LocalTime parseTimeSafe(String value) {
        if (value == null || value.isBlank()) return null;
        return LocalTime.parse(value);
    }
}
