package com.ems.controller;

import com.ems.dao.ShiftAssignmentDAO;
import com.ems.dto.EmployeeDTO;
import com.ems.util.ExcelAttendanceExporter;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.OutputStream;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * Servlet xử lý export file Excel template chấm công cho Lịch làm việc mặc định.
 *
 * URL: GET /work-schedule/export-attendance
 *
 * Sẽ xuất danh sách toàn bộ nhân viên (vì là lịch mặc định của toàn công ty)
 * để chấm công cho ngày hôm nay.
 */
@WebServlet("/work-schedule/export-attendance")
public class ExportWorkScheduleAttendanceServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
            
        // 1. Ngày xuất mặc định là hôm nay
        LocalDate today = LocalDate.now();

        // 2. Load danh sách toàn bộ nhân viên đang active
        List<EmployeeDTO> employees = ShiftAssignmentDAO.getAllEmployees();

        if (employees.isEmpty()) {
            req.getSession().setAttribute("exportError", "Không có nhân viên nào đang hoạt động để xuất file.");
            resp.sendRedirect(req.getContextPath() + "/work-schedule");
            return;
        }

        // 3. Setup Response để download file Excel
        String dateStr = today.format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String filename = "ChamCong_" + dateStr + ".xlsx";

        resp.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        // 4. Gọi util export Excel
        try (OutputStream out = resp.getOutputStream()) {
            ExcelAttendanceExporter.export(employees, today, out);
        } catch (Exception e) {
            e.printStackTrace();
            // Nếu stream đã mở / ghi, việc redirect lúc này có thể không hoạt động hoặc gây lỗi
            // Tốt nhất chỉ log lỗi ở console.
        }
    }
}
