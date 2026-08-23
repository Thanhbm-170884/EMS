package com.ems.controller;

import com.ems.dao.ShiftAssignmentDAO;
import com.ems.dao.ShiftManagementDAO;
import com.ems.dto.EmployeeDTO;
import com.ems.model.Shiftassignmentbatches;
import com.ems.service.ShiftAssignmentService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.*;

@WebServlet("/shift-assignment")
public class ShiftAssignmentServlet extends HttpServlet {

    private final ShiftAssignmentService service = new ShiftAssignmentService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");

        // ── AJAX: tính preview lịch ──
        if ("preview".equals(action)) {
            handlePreview(req, resp);
            return;
        }

        // ── AJAX: lấy nhân viên theo phòng ban ──
        if ("dept-employees".equals(action)) {
            handleDeptEmployees(req, resp);
            return;
        }

        // ── Normal page load ──
        if ("edit".equals(action)) {
            int id = Integer.parseInt(req.getParameter("id"));
            req.setAttribute("batch", service.getById(id));
        }
        req.setAttribute("batches", service.getAllBatches());
        req.setAttribute("shiftOptions", ShiftManagementDAO.getAllCustomShifts());
        req.setAttribute("departments", ShiftAssignmentDAO.getAllDepartments());
        req.setAttribute("employees", ShiftAssignmentDAO.getAllEmployees());
        req.getRequestDispatcher("/shift-assignment.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        try {
            if ("delete".equals(action)) {
                service.delete(Integer.parseInt(req.getParameter("id")));
            } else {
                Shiftassignmentbatches b = new Shiftassignmentbatches();
                String idParam = req.getParameter("id");
                if (idParam != null && !idParam.isBlank()) b.setId(Integer.parseInt(idParam));
                b.setName(req.getParameter("name"));
                b.setShiftId(Integer.parseInt(req.getParameter("shiftId")));
                b.setStartDate(LocalDate.parse(req.getParameter("startDate")));
                String endDate = req.getParameter("endDate");
                b.setEndDate(endDate != null && !endDate.isBlank() ? LocalDate.parse(endDate) : null);
                b.setRecurType(req.getParameter("recurType"));
                b.setRecurInterval(Integer.parseInt(req.getParameter("recurInterval")));

                if ("MONTHLY".equals(b.getRecurType())) {
                    b.setMonthlyType(req.getParameter("monthlyType"));
                    if ("WEEKDAY".equals(b.getMonthlyType())) {
                        b.setMonthlyWeekday(Integer.parseInt(req.getParameter("monthlyWeekday")));
                        b.setMonthlyOccurrence(Integer.parseInt(req.getParameter("monthlyOccurrence")));
                    } else {
                        b.setMonthlyDay(Integer.parseInt(req.getParameter("monthlyDay")));
                    }
                }
                String scope = req.getParameter("scope");
                Integer accountId = (Integer) req.getSession().getAttribute("accountId");
                b.setCreatedBy(accountId);

                String[] weekdayParams = req.getParameterValues("weekdays");
                List<Integer> weekdays = new ArrayList<>();
                if (weekdayParams != null)
                    for (String d : weekdayParams) weekdays.add(Integer.parseInt(d));

                String[] empParams = req.getParameterValues("employeeIds");
                List<Integer> empIds = new ArrayList<>();
                if (empParams != null)
                    for (String e : empParams) empIds.add(Integer.parseInt(e));

                if (b.getId() == null) {
                    service.create(b, weekdays, empIds, scope);
                } else {
                    service.update(b, weekdays, empIds, scope);
                }
            }
            resp.sendRedirect(req.getContextPath() + "/shift-assignment");
        } catch (IllegalArgumentException | IllegalStateException ex) {
            req.setAttribute("error", ex.getMessage());
            req.setAttribute("batches", service.getAllBatches());
            req.setAttribute("shiftOptions", ShiftManagementDAO.getAllCustomShifts());
            req.setAttribute("departments", ShiftAssignmentDAO.getAllDepartments());
            req.setAttribute("employees", ShiftAssignmentDAO.getAllEmployees());
            // Giữ lại id nếu đang sửa (để form hiển thị đúng chế độ update)
            String idParam = req.getParameter("id");
            if (idParam != null && !idParam.isBlank()) {
                try {
                    req.setAttribute("batch", service.getById(Integer.parseInt(idParam)));
                } catch (Exception ignored) { }
            }
            req.getRequestDispatcher("/shift-assignment.jsp").forward(req, resp);
        }
    }

    // ─────────────────────────────────────────────
    //  Preview: tính danh sách ngày theo recurrence
    // ─────────────────────────────────────────────
    private void handlePreview(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        resp.setHeader("Cache-Control", "no-cache");
        PrintWriter out = resp.getWriter();

        String startDateStr = req.getParameter("startDate");
        if (startDateStr == null || startDateStr.isBlank()) {
            out.write("[]");
            return;
        }

        try {
            LocalDate startDate = LocalDate.parse(startDateStr);
            String endDateStr = req.getParameter("endDate");
            LocalDate endDate = (endDateStr != null && !endDateStr.isBlank())
                    ? LocalDate.parse(endDateStr)
                    : startDate.plusDays(180);
            // Giới hạn tối đa 180 ngày từ startDate để tránh response quá lớn
            LocalDate cap = startDate.plusDays(180);
            if (endDate.isAfter(cap)) endDate = cap;

            String recurType  = req.getParameter("recurType");
            int    interval   = parseIntOr(req.getParameter("recurInterval"), 1);

            List<String> dates = new ArrayList<>();

            if ("NONE".equals(recurType)) {
                // Chỉ ngày bắt đầu
                if (!startDate.isAfter(endDate)) dates.add(startDate.toString());

            } else if ("WEEKLY".equals(recurType)) {
                // weekdays: "2,3,4,5,6" — hệ quy ước của app: 1=CN, 2=T2…7=T7
                String wdStr = req.getParameter("weekdays");
                Set<Integer> weekdaySet = new HashSet<>();
                if (wdStr != null && !wdStr.isBlank()) {
                    for (String d : wdStr.split(",")) {
                        String t = d.trim();
                        if (!t.isEmpty()) weekdaySet.add(Integer.parseInt(t));
                    }
                }
                if (!weekdaySet.isEmpty()) {
                    LocalDate mondayOfStart = startDate.with(DayOfWeek.MONDAY);
                    LocalDate cur = startDate;
                    while (!cur.isAfter(endDate)) {
                        LocalDate mondayOfCur = cur.with(DayOfWeek.MONDAY);
                        long weekDiff = ChronoUnit.WEEKS.between(mondayOfStart, mondayOfCur);
                        if (weekDiff >= 0 && weekDiff % interval == 0) {
                            // Chuyển Java DayOfWeek (Mon=1..Sun=7) sang hệ app (1=CN, 2=T2…7=T7)
                            int javaDow = cur.getDayOfWeek().getValue();
                            int appDow  = (javaDow == 7) ? 1 : javaDow + 1;
                            if (weekdaySet.contains(appDow)) {
                                dates.add(cur.toString());
                            }
                        }
                        cur = cur.plusDays(1);
                    }
                }

            } else if ("MONTHLY".equals(recurType)) {
                String monthlyType = req.getParameter("monthlyType");
                LocalDate firstMonth = startDate.withDayOfMonth(1);

                if ("DATE".equals(monthlyType)) {
                    int day = parseIntOr(req.getParameter("monthlyDay"), 1);
                    LocalDate cursor = firstMonth;
                    while (!cursor.isAfter(endDate)) {
                        long mDiff = ChronoUnit.MONTHS.between(firstMonth, cursor);
                        if (mDiff >= 0 && mDiff % interval == 0) {
                            int realDay = Math.min(day, cursor.lengthOfMonth());
                            LocalDate candidate = cursor.withDayOfMonth(realDay);
                            if (!candidate.isBefore(startDate) && !candidate.isAfter(endDate)) {
                                dates.add(candidate.toString());
                            }
                        }
                        cursor = cursor.plusMonths(1);
                    }

                } else { // WEEKDAY
                    int appWeekday   = parseIntOr(req.getParameter("monthlyWeekday"),   2);
                    int occurrence   = parseIntOr(req.getParameter("monthlyOccurrence"), 1);
                    DayOfWeek target = appDowToJava(appWeekday);

                    LocalDate cursor = firstMonth;
                    while (!cursor.isAfter(endDate)) {
                        long mDiff = ChronoUnit.MONTHS.between(firstMonth, cursor);
                        if (mDiff >= 0 && mDiff % interval == 0) {
                            LocalDate candidate = nthWeekdayOfMonth(
                                    cursor.getYear(), cursor.getMonthValue(), target, occurrence);
                            if (candidate != null && !candidate.isBefore(startDate) && !candidate.isAfter(endDate)) {
                                dates.add(candidate.toString());
                            }
                        }
                        cursor = cursor.plusMonths(1);
                    }
                }
            }

            StringBuilder sb = new StringBuilder("[");
            for (int i = 0; i < dates.size(); i++) {
                if (i > 0) sb.append(",");
                sb.append("\"").append(dates.get(i)).append("\"");
            }
            sb.append("]");
            out.write(sb.toString());

        } catch (Exception e) {
            out.write("[]");
        }
    }

    // ─────────────────────────────────────────────
    //  Dept-employees: trả JSON danh sách nhân viên theo phòng ban
    // ─────────────────────────────────────────────
    private void handleDeptEmployees(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        resp.setHeader("Cache-Control", "no-cache");
        PrintWriter out = resp.getWriter();
        try {
            int deptId = Integer.parseInt(req.getParameter("deptId"));
            List<EmployeeDTO> emps = ShiftAssignmentDAO.getEmployeesByDept(deptId);
            StringBuilder sb = new StringBuilder("[");
            for (int i = 0; i < emps.size(); i++) {
                if (i > 0) sb.append(",");
                EmployeeDTO e = emps.get(i);
                sb.append("{\"id\":").append(e.getId())
                        .append(",\"employeeCode\":\"").append(escJson(e.getEmployeeCode())).append("\"")
                        .append(",\"fullName\":\"").append(escJson(e.getFullName())).append("\"")
                        .append(",\"departmentName\":\"").append(escJson(e.getDepartmentName())).append("\"")
                        .append("}");
            }
            sb.append("]");
            out.write(sb.toString());
        } catch (Exception e) {
            out.write("[]");
        }
    }

    // ── Helpers ──

    private static int parseIntOr(String s, int def) {
        if (s == null || s.isBlank()) return def;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return def; }
    }

    /** Chuyển hệ app (1=CN, 2=T2…7=T7) sang Java DayOfWeek */
    private static DayOfWeek appDowToJava(int appDow) {
        switch (appDow) {
            case 1: return DayOfWeek.SUNDAY;
            case 2: return DayOfWeek.MONDAY;
            case 3: return DayOfWeek.TUESDAY;
            case 4: return DayOfWeek.WEDNESDAY;
            case 5: return DayOfWeek.THURSDAY;
            case 6: return DayOfWeek.FRIDAY;
            case 7: return DayOfWeek.SATURDAY;
            default: return DayOfWeek.MONDAY;
        }
    }

    /** Lấy ngày của lần xuất hiện thứ N (hoặc cuối cùng nếu occurrence=-1) của weekday trong tháng */
    private static LocalDate nthWeekdayOfMonth(int year, int month, DayOfWeek dow, int occurrence) {
        if (occurrence == -1) {
            // Lần cuối cùng trong tháng
            LocalDate last = LocalDate.of(year, month, 1).plusMonths(1).minusDays(1);
            while (last.getDayOfWeek() != dow) last = last.minusDays(1);
            return last;
        }
        // Tìm lần đầu tiên rồi cộng thêm tuần
        LocalDate first = LocalDate.of(year, month, 1);
        while (first.getDayOfWeek() != dow) first = first.plusDays(1);
        LocalDate result = first.plusWeeks(occurrence - 1);
        return (result.getMonthValue() == month) ? result : null;
    }

    private static String escJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}