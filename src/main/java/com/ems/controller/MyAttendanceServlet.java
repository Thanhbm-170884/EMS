package com.ems.controller;

import com.ems.dao.AttendanceDAO;
import com.ems.dto.AttendanceHistoryDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/Attendance/my-attendance")
public class MyAttendanceServlet extends HttpServlet {

    private final AttendanceDAO dao = new AttendanceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Object accountIdObj = session.getAttribute("accountId");

        if (accountIdObj == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        int accountId = (int) accountIdObj;

        Integer employeeId;
        try {
                    employeeId = dao.findUserIdByAccountId(accountId);
        } catch (Exception e) {
            request.setAttribute("error", "Lỗi khi xác định thông tin nhân viên: " + e.getMessage());
            request.getRequestDispatcher("/Attendance/my-attendance.jsp").forward(request, response);
            return;
        }

        if (employeeId == null) {
            request.setAttribute("error", "Không tìm thấy thông tin nhân viên liên kết với tài khoản này.");
            request.getRequestDispatcher("/Attendance/my-attendance.jsp").forward(request, response);
            return;
        }

        LocalDate fromDate = parseDateSafe(request.getParameter("fromDate"));
        LocalDate toDate = parseDateSafe(request.getParameter("toDate"));

        if (fromDate == null && toDate == null) {
            toDate = LocalDate.now();
            fromDate = toDate.minusDays(30);
        } else if (fromDate == null) {
            fromDate = toDate.minusDays(30);
        } else if (toDate == null) {
            toDate = LocalDate.now();
        }

        if (fromDate.isAfter(toDate)) {
            request.setAttribute("error", "Ngày bắt đầu không được sau ngày kết thúc.");
        } else {
            try {
                List<AttendanceHistoryDTO> history =
                        dao.findByEmployeeAndDateRange(employeeId, fromDate, toDate);
                request.setAttribute("history", history);
            } catch (Exception e) {
                request.setAttribute("error", "Lỗi khi tải dữ liệu: " + e.getMessage());
            }
        }

        request.setAttribute("fromDate", fromDate);
        request.setAttribute("toDate", toDate);

        request.getRequestDispatcher("/Attendance/my-attendance.jsp").forward(request, response);
    }

    private LocalDate parseDateSafe(String s) {
        try { return LocalDate.parse(s); } catch (Exception e) { return null; }
    }
}