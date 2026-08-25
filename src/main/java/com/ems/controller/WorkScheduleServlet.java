package com.ems.controller;

import com.ems.dto.ShiftDTO;
import com.ems.service.WorkScheduleService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "WorkScheduleServlet", urlPatterns = { "/work-schedule" })
public class WorkScheduleServlet extends HttpServlet {

    private WorkScheduleService workScheduleService;

    @Override
    public void init() {
        workScheduleService = new WorkScheduleService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<ShiftDTO> shifts = workScheduleService.getWorkSchedule();
        boolean hasSchedule = shifts != null && !shifts.isEmpty();
        request.setAttribute("shifts", shifts);
        request.setAttribute("hasSchedule", hasSchedule);
        // Gửi ngày hiện tại để form hiển thị effectiveDate mặc định
        request.setAttribute("today", shifts.get(0).getEffectiveDate().toString());
        request.getRequestDispatcher("/work-schedule.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // Đọc ngày áp dụng từ form (HR chọn), fallback về hôm nay nếu không có
        LocalDate effectiveDate;
        try {
            String effectiveDateParam = request.getParameter("effectiveDate");
            effectiveDate = (effectiveDateParam != null && !effectiveDateParam.isBlank())
                    ? LocalDate.parse(effectiveDateParam)
                    : LocalDate.now();
        } catch (Exception e) {
            effectiveDate = LocalDate.now();
        }

        List<ShiftDTO> shiftDTOS = new ArrayList<>();

        for (int i = 0; i < 7; i++) {
            String dayOfWeek = request.getParameter("dayOfWeek_" + i);
            if (dayOfWeek == null || dayOfWeek.isBlank())
                continue;

            String workingParam = request.getParameter("working_" + i);
            String startTime    = request.getParameter("startTime_" + i);
            String endTime      = request.getParameter("endTime_" + i);
            String breakStart   = request.getParameter("breakStart_" + i);
            String breakEnd     = request.getParameter("breakEnd_" + i);

            ShiftDTO dto = new ShiftDTO();
            dto.setDayOfWeek(Integer.parseInt(dayOfWeek.trim()));
            boolean working = "true".equals(workingParam);
            dto.setWorking(working);
            if (working) {
                dto.setStartTime(startTime  != null ? startTime.trim()  : null);
                dto.setEndTime(endTime      != null ? endTime.trim()    : null);
                dto.setBreakStart(breakStart != null ? breakStart.trim() : null);
                dto.setBreakEnd(breakEnd    != null ? breakEnd.trim()   : null);
            } else {
                dto.setStartTime(null);
                dto.setEndTime(null);
                dto.setBreakStart(null);
                dto.setBreakEnd(null);
            }
            shiftDTOS.add(dto);
        }

        // Gọi saveNewDefaultSchedule với effectiveDate để versioning đúng
        workScheduleService.saveNewDefaultSchedule(shiftDTOS, effectiveDate);
        response.sendRedirect(request.getContextPath() + "/work-schedule?saved=1");
    }
}
