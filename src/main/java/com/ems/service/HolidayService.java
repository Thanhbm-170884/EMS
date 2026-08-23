package com.ems.service;

import com.ems.dao.HolidayTemplateDAO;
import com.ems.dao.HolidayYearInstanceDAO;
import com.ems.dto.HolidayYearViewDTO;
import com.ems.model.HolidayTemplate;
import com.ems.model.HolidayYearInstance;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class HolidayService {

    private static final DateTimeFormatter VN_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    public List<HolidayYearViewDTO> getHolidaysForYear(int year) {
        List<HolidayTemplate> templates = HolidayTemplateDAO.getAllActiveTemplates();
        Map<Integer, HolidayYearInstance> instancesByTemplate = HolidayYearInstanceDAO.getInstanceByYear(year);

        List<HolidayYearViewDTO> result = new ArrayList<>();
        for (HolidayTemplate t : templates) {
            HolidayYearInstance instance = instancesByTemplate.get(t.getId());

            if (instance == null && "FIXED_SOLAR".equals(t.getRecurType())) {
                LocalDate start = LocalDate.of(year, t.getFixedMonth(), t.getFixedDay());
                LocalDate end = start.plusDays(Math.max(1, t.getFixedDurationDays()) - 1L);
                instance = new HolidayYearInstance();
                instance.setTemplateId(t.getId());
                instance.setYear(year);
                instance.setStartDate(start);
                instance.setEndDate(end);
                instance.setCoefficient(t.getDefaultCoefficient());
                HolidayYearInstanceDAO.upsertInstance(instance);
            }

            HolidayYearViewDTO dto = new HolidayYearViewDTO();
            dto.setTemplateId(t.getId());
            dto.setHolidayName(t.getHolidayName());
            dto.setRecurType(t.getRecurType());
            dto.setCoefficientLocked(t.getCoefficientLocked());

            if (instance != null) {
                dto.setInstanceId(instance.getId());
                dto.setStartDate(instance.getStartDate().format(VN_FORMAT));
                dto.setEndDate(instance.getEndDate().format(VN_FORMAT));
                dto.setStartDateIso(instance.getStartDate().toString());
                dto.setEndDateIso(instance.getEndDate().toString());
                dto.setCoefficient(t.getCoefficientLocked() ? t.getDefaultCoefficient() : instance.getCoefficient());
            } else {
                dto.setStartDate("");
                dto.setEndDate("");
                dto.setStartDateIso("");
                dto.setEndDateIso("");
                dto.setCoefficient(t.getDefaultCoefficient());
            }
            result.add(dto);
        }
        return result;
    }

    public void saveInstanceDates(int templateId, int year, String startDateStr, String endDateStr, Integer accountId) {
        LocalDate start = LocalDate.parse(startDateStr);
        LocalDate end = LocalDate.parse(endDateStr);
        if (start.isAfter(end)) {
            throw new IllegalArgumentException("Ngày bắt đầu không được sau ngày kết thúc");
        }

        // Giữ lại coefficient cũ nếu đã có instance, không ghi đè thành 1.0
        Map<Integer, HolidayYearInstance> existing = HolidayYearInstanceDAO.getInstanceByYear(year);
        HolidayYearInstance old = existing.get(templateId);
        double coefficient = (old != null) ? old.getCoefficient() : 1.0;

        HolidayYearInstance hi = new HolidayYearInstance();
        hi.setTemplateId(templateId);
        hi.setYear(year);
        hi.setStartDate(start);
        hi.setEndDate(end);
        hi.setCoefficient(coefficient);
        hi.setCreatedBy(accountId);
        HolidayYearInstanceDAO.upsertInstance(hi);
    }

    public void saveCoefficient(int templateId, int year, double coefficient, boolean locked, Integer accountId) {
        if (locked) {
            HolidayTemplateDAO.updateHolidayTemplate(templateId, coefficient, true);
        } else {
            HolidayTemplateDAO.updateHolidayTemplate(templateId, coefficient, false);
            Map<Integer, HolidayYearInstance> existing = HolidayYearInstanceDAO.getInstanceByYear(year);
            HolidayYearInstance hi = existing.get(templateId);
            if (hi == null) {
                throw new IllegalStateException("Chưa có ngày cụ thể cho năm này, vui lòng nhập ngày trước");
            }
            hi.setCoefficient(coefficient);
            hi.setCreatedBy(accountId);
            HolidayYearInstanceDAO.upsertInstance(hi);
        }
    }

    public void createTemplate(HolidayTemplate t) {
        if (t.getHolidayName() == null || t.getHolidayName().isBlank()) {
            throw new IllegalArgumentException("Tên ngày nghỉ lễ không được để trống");
        }
        if ("FIXED_SOLAR".equals(t.getRecurType())
                && (t.getFixedMonth() == null || t.getFixedDay() == null)) {
            throw new IllegalArgumentException("Lễ dương lịch cố định phải nhập ngày/tháng");
        }
        HolidayTemplateDAO.insertHolidayTemplate(t);
    }
}