package com.ems.servlet;



import com.ems.dao.AttendanceDAO;
import com.ems.dto.AttendanceHistoryDTO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/Attendance/search-attendance")
public class SearchAttendanceServlet extends HttpServlet {

    private final AttendanceDAO attendanceDAO = new AttendanceDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String employeeName = request.getParameter("employeeName");
        String employeeCode = request.getParameter("employeeCode");
        String date = request.getParameter("date");

        // =========================
        // PHÂN TRANG
        // =========================

        int pageSize = 8;
        int currentPage = 1;

        String pageParam = request.getParameter("page");

        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                currentPage = Integer.parseInt(pageParam);
            } catch (NumberFormatException e) {
                currentPage = 1;
            }
        }

        if (currentPage < 1) {
            currentPage = 1;
        }

        int offset = (currentPage - 1) * pageSize;

        List<AttendanceHistoryDTO> results = null;

        int totalRecords = 0;
        int totalPages = 0;

        // =========================
        // TÌM KIẾM
        // =========================

        boolean hasSearchCondition =
                (employeeName != null && !employeeName.trim().isEmpty())
                        || (employeeCode != null && !employeeCode.trim().isEmpty())
                        || (date != null && !date.trim().isEmpty());

        if (hasSearchCondition) {

            try {

                // Lấy dữ liệu của trang hiện tại
                results = attendanceDAO.searchAttendance(
                        employeeName,
                        employeeCode,
                        date,
                        pageSize,
                        offset
                );

                // Đếm tổng số bản ghi
                totalRecords = attendanceDAO.countAttendance(
                        employeeName,
                        employeeCode,
                        date
                );

                // Tính tổng số trang
                totalPages = (int) Math.ceil(
                        (double) totalRecords / pageSize
                );

                // Nếu page vượt quá số trang
                if (totalPages > 0 && currentPage > totalPages) {
                    currentPage = totalPages;

                    offset = (currentPage - 1) * pageSize;

                    results = attendanceDAO.searchAttendance(
                            employeeName,
                            employeeCode,
                            date,
                            pageSize,
                            offset
                    );
                }

                request.setAttribute("results", results);

            } catch (Exception e) {

                request.setAttribute(
                        "error",
                        "Lỗi khi tìm kiếm dữ liệu: " + e.getMessage()
                );
            }
        }

        // =========================
        // GỬI DỮ LIỆU SANG JSP
        // =========================

        request.setAttribute("employeeName", employeeName);
        request.setAttribute("employeeCode", employeeCode);
        request.setAttribute("date", date);

        request.setAttribute("currentPage", currentPage);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("totalPages", totalPages);

        request.getRequestDispatcher(
                "/Attendance/search-attendance.jsp"
        ).forward(request, response);
    }
}