package com.ems.controller;

import com.ems.dto.HolidayYearViewDTO;
import com.ems.model.HolidayTemplate;
import com.ems.service.HolidayService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.Year;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "HolidayServlet", urlPatterns = { "/holiday" })
@MultipartConfig
public class HolidayServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(HolidayServlet.class.getName());

    private HolidayService holidayService;

    @Override
    public void init() {
        holidayService = new HolidayService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int year = Year.now().getValue();
        try {
            year = Integer.parseInt(request.getParameter("year"));
        } catch (NumberFormatException ignored) { }

        List<HolidayYearViewDTO> holidays = holidayService.getHolidaysForYear(year);

        request.setAttribute("holidays", holidays);
        request.setAttribute("year", year);
        request.getRequestDispatcher("/holiday.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        boolean isAjax = "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));

        String action = request.getParameter("action");
        int year;
        try {
            year = Integer.parseInt(request.getParameter("year"));
        } catch (NumberFormatException e) {
            failRequest(request, response, isAjax, "Thiếu hoặc sai tham số năm (year).", null);
            return;
        }
        Integer accountId = (Integer) request.getSession().getAttribute("accountId");

        try {
            if ("saveDates".equals(action)) {
                int templateId = Integer.parseInt(request.getParameter("templateId"));
                holidayService.saveInstanceDates(
                        templateId, year,
                        request.getParameter("startDate"),
                        request.getParameter("endDate"),
                        accountId);
            } else if ("saveCoefficient".equals(action)) {
                int templateId = Integer.parseInt(request.getParameter("templateId"));
                double coefficient = Double.parseDouble(request.getParameter("coefficient"));
                boolean locked = "on".equals(request.getParameter("locked"));
                holidayService.saveCoefficient(templateId, year, coefficient, locked, accountId);
            } else if ("createTemplate".equals(action)) {
                HolidayTemplate t = new HolidayTemplate();
                t.setHolidayName(request.getParameter("name"));
                t.setRecurType(request.getParameter("recurType"));
                String month = request.getParameter("fixedMonth");
                String day = request.getParameter("fixedDay");
                if (month != null && !month.isBlank()) t.setFixedMonth(Integer.parseInt(month));
                if (day != null && !day.isBlank()) t.setFixedDay(Integer.parseInt(day));
                t.setFixedDurationDays(1);
                t.setDefaultCoefficient(1.0);
                t.setCoefficientLocked(false);
                t.setCreatedBy(accountId);
                holidayService.createTemplate(t);
            } else {
                failRequest(request, response, isAjax, "Hành động không hợp lệ.", null);
                return;
            }
        } catch (NumberFormatException e) {
            failRequest(request, response, isAjax, "Dữ liệu số không hợp lệ (templateId/hệ số/tháng/ngày).", e);
            return;
        } catch (IllegalArgumentException | IllegalStateException e) {
            // Lỗi nghiệp vụ đã biết (validate thất bại phía service) -> hiển thị message gốc cho người dùng
            failRequest(request, response, isAjax, e.getMessage(), null);
            return;
        } catch (Exception e) {
            // THAY ĐỔI: bắt luôn các exception không lường trước (NPE, lỗi DB...) để KHÔNG trả về
            // HTTP 500 trần trụi (mất hết ngữ cảnh) -> log đầy đủ ở server, trả message chung cho client.
            failRequest(request, response, isAjax, "Có lỗi hệ thống xảy ra, vui lòng thử lại hoặc liên hệ quản trị viên.", e);
            return;
        }

        // Thành công
        if (isAjax) {
            writeJson(response, 200, true, "Đã lưu thành công.");
        } else {
            response.sendRedirect(request.getContextPath() + "/holiday?year=" + year);
        }
    }

    /**
     * Xử lý khi request thất bại: log lỗi thật ở server, trả JSON (nếu AJAX) hoặc
     * forward lại trang kèm errorMsg (nếu request thường / không có JS).
     * THAY ĐỔI: trước đây dùng response.sendRedirect() sau khi set errorMsg -> errorMsg
     * bị mất vì redirect tạo request mới. Giờ dùng forward để giữ được errorMsg khi cần.
     */
    private void failRequest(HttpServletRequest request, HttpServletResponse response,
                             boolean isAjax, String message, Exception logCause) throws ServletException, IOException {
        String safeMessage = (message == null || message.isBlank())
                ? "Yêu cầu không hợp lệ, vui lòng kiểm tra lại dữ liệu."
                : message;

        if (logCause != null) {
            LOGGER.log(Level.SEVERE, "Holiday servlet action failed: " + safeMessage, logCause);
        } else {
            LOGGER.log(Level.WARNING, "Holiday servlet action failed: " + safeMessage);
        }

        if (isAjax) {
            writeJson(response, 400, false, safeMessage);
        } else {
            request.setAttribute("errorMsg", safeMessage);
            int year = Year.now().getValue();
            try {
                year = Integer.parseInt(request.getParameter("year"));
            } catch (NumberFormatException ignored) { }
            List<HolidayYearViewDTO> holidays = holidayService.getHolidaysForYear(year);
            request.setAttribute("holidays", holidays);
            request.setAttribute("year", year);
            request.getRequestDispatcher("/holiday.jsp").forward(request, response);
        }
    }

    private void writeJson(HttpServletResponse response, int status, boolean success, String message) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.write("{\"success\":" + success + ",\"message\":\"" + escapeJson(message) + "\"}");
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "");
    }
}