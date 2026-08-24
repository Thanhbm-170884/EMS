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

        List<AttendanceHistoryDTO> results = null;

        // Chỉ tìm kiếm khi người dùng thực sự nhập điều kiện
        if ((employeeName != null && !employeeName.trim().isEmpty())
                || (employeeCode != null && !employeeCode.trim().isEmpty())
                || (date != null && !date.trim().isEmpty())) {

            try {

                results = attendanceDAO.searchAttendance(
                        employeeName,
                        employeeCode,
                        date
                );

                request.setAttribute("results", results);

            } catch (Exception e) {

                request.setAttribute(
                        "error",
                        "Lỗi khi tìm kiếm dữ liệu: " + e.getMessage()
                );
            }
        }

        request.setAttribute("employeeName", employeeName);
        request.setAttribute("employeeCode", employeeCode);
        request.setAttribute("date", date);

        request.getRequestDispatcher(
                "/Attendance/search-attendance.jsp"
        ).forward(request, response);
    }
}
