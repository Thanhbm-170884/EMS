package com.ems.servlet;



import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.ems.model.AttendanceRecord;
import com.ems.util.ExcelExporter;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

@WebServlet("/export")
public class ExportServlet extends HttpServlet {

    @Override
    @SuppressWarnings("unchecked")
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        List<AttendanceRecord> records =
                (List<AttendanceRecord>) session.getAttribute("previewList");

        if (records == null || records.isEmpty()) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Không có dữ liệu để export. Vui lòng upload file Excel trước."
            );
            return;
        }

        // Lấy tên file từ modal
        String fileName = request.getParameter("fileName");

        // Nếu người dùng không nhập tên
        if (fileName == null || fileName.trim().isEmpty()) {
            fileName = "ChamCong_Preview";
        }

        fileName = fileName.trim();

        // Loại bỏ phần .xlsx nếu người dùng đã nhập
        if (fileName.toLowerCase().endsWith(".xlsx")) {
            fileName = fileName.substring(0, fileName.length() - 5);
        }

        // Loại bỏ các ký tự không hợp lệ trong tên file Windows
        fileName = fileName.replaceAll("[\\\\/:*?\"<>|]", "_");

        // Thêm .xlsx
        fileName += ".xlsx";

        response.setContentType(
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        );

        response.setHeader(
                "Content-Disposition",
                "attachment; filename=\"" + fileName + "\""
        );

        try {
            ExcelExporter.export(
                    records,
                    response.getOutputStream()
            );
        } catch (Exception e) {
            throw new ServletException(
                    "Lỗi khi export Excel: " + e.getMessage(),
                    e
            );
        }
    }
}
