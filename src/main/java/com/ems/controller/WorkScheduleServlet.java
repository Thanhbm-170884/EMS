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
import java.time.LocalTime;
import java.time.format.DateTimeParseException;
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
        request.setAttribute("today", hasSchedule ? shifts.get(0).getEffectiveDate().toString() : "");
        request.getRequestDispatcher("/work-schedule.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

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
        List<ShiftDTO> submittedShifts = new ArrayList<>();
        String error = null;

        for (int i = 0; i < 7; i++) {
            String dayOfWeekParam = request.getParameter("dayOfWeek_" + i);
            if (dayOfWeekParam == null || dayOfWeekParam.isBlank())
                continue;

            int dayOfWeek = Integer.parseInt(dayOfWeekParam.trim());
            boolean working = "true".equals(request.getParameter("working_" + i));
            String startTime = request.getParameter("startTime_" + i);
            String endTime = request.getParameter("endTime_" + i);
            String breakStart = request.getParameter("breakStart_" + i);
            String breakEnd = request.getParameter("breakEnd_" + i);

            ShiftDTO raw = new ShiftDTO();
            raw.setDayOfWeek(dayOfWeek);
            raw.setWorking(working);
            if (working) {
                raw.setStartTime(startTime);
                raw.setEndTime(endTime);
                raw.setBreakStart(breakStart);
                raw.setBreakEnd(breakEnd);
            }
            submittedShifts.add(raw);

            if (error != null) {
                continue;
            }

            ShiftDTO dto = new ShiftDTO();
            dto.setDayOfWeek(dayOfWeek);
            dto.setWorking(working);

            if (working) {
                try {
                    LocalTime start = LocalTime.parse(startTime);
                    LocalTime end = LocalTime.parse(endTime);
                    if (!start.isBefore(end)) {
                        error = "Giờ bắt đầu phải trước giờ kết thúc";
                        continue;
                    }

                    if (breakStart != null && !breakStart.isBlank()
                            && breakEnd != null && !breakEnd.isBlank()) {
                        LocalTime bStart = LocalTime.parse(breakStart);
                        LocalTime bEnd = LocalTime.parse(breakEnd);
                        if (!bStart.isBefore(bEnd)) {
                            error = "Giờ bắt đầu nghỉ trưa phải trước giờ kết thúc nghỉ trưa";
                            continue;
                        }
                        if (bStart.isBefore(start) || bEnd.isAfter(end)) {
                            error = "Giờ nghỉ trưa phải nằm trong khung giờ làm việc";
                            continue;
                        }
                    }

                    dto.setStartTime(startTime.trim());
                    dto.setEndTime(endTime.trim());
                    dto.setBreakStart(breakStart != null ? breakStart.trim() : null);
                    dto.setBreakEnd(breakEnd != null ? breakEnd.trim() : null);
                } catch (DateTimeParseException e) {
                    error = "Định dạng giờ không hợp lệ";
                    continue;
                }
            }

            shiftDTOS.add(dto);
        }

        if (error != null) {
            forwardWithError(request, response, error, submittedShifts, effectiveDate);
            return;
        }

        workScheduleService.saveNewDefaultSchedule(shiftDTOS, effectiveDate);
        response.sendRedirect(request.getContextPath() + "/work-schedule?saved=1");
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response, String error,
                                  List<ShiftDTO> submittedShifts, LocalDate effectiveDate)
            throws ServletException, IOException {
        List<ShiftDTO> shifts = workScheduleService.getWorkSchedule();
        boolean hasSchedule = shifts != null && !shifts.isEmpty();
        request.setAttribute("shifts", shifts);
        request.setAttribute("hasSchedule", hasSchedule);
        request.setAttribute("formShifts", submittedShifts);
        // Giữ đúng ngày user vừa chọn trên date-picker, không lấy lại từ DB
        request.setAttribute("today", effectiveDate.toString());
        request.setAttribute("error", error);
        request.getRequestDispatcher("/work-schedule.jsp").forward(request, response);
    }
}