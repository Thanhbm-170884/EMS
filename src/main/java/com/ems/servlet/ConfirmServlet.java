package com.ems.servlet;

import com.ems.dao.AttendanceDAO;
import com.ems.model.AttendanceRecord;
import com.ems.Validate.AttendanceValidator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/Attendance/confirm")
public class ConfirmServlet extends HttpServlet {

    private final AttendanceDAO dao = new AttendanceDAO();

    @Override
    @SuppressWarnings("unchecked")
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        List<AttendanceRecord> records = (List<AttendanceRecord>) session.getAttribute("previewList");

        if (records == null || records.isEmpty()) {
            request.setAttribute("error", "Không có dữ liệu để lưu. Vui lòng upload lại file.");
            request.getRequestDispatcher("/Attendance/upload.jsp").forward(request, response);
            return;
        }

        // Tra cứu EmployeeId thật (khóa ngoại bảng users) từ EmployeeCode cho từng dòng hợp lệ
        try {
            for (AttendanceRecord r : records) {
                if (r.isValid()) {
                    Integer employeeId = dao.findUserIdByEmployeeCode(r.getEmployeeCode());
                    if (employeeId == null) {
                        r.addError("Dòng " + r.getRowNumber()
                                + ": Mã nhân viên \"" + r.getEmployeeCode() + "\" không tồn tại trong hệ thống");
                    } else {
                        r.setEmployeeId(employeeId);
                    }
                }
            }
        } catch (Exception e) {
            request.setAttribute("error", "Lỗi khi tra cứu nhân viên: " + e.getMessage());
            request.getRequestDispatcher("/Attendance/preview.jsp").forward(request, response);
            return;
        }

        long invalidCount = records.stream().filter(r -> !r.isValid()).count();
        if (invalidCount > 0) {
            request.setAttribute("error",
                    "Còn " + invalidCount + " dòng chưa hợp lệ. Vui lòng bấm \"Sửa\" để chỉnh lại trước khi lưu.");
            request.getRequestDispatcher("/Attendance/preview.jsp").forward(request, response);
            return;
        }

        try {
            dao.saveAll(records);
            session.removeAttribute("previewList");
            request.setAttribute("savedCount", records.size());
            request.getRequestDispatcher("/Attendance/success.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Lỗi khi lưu vào database: " + e.getMessage());
            request.getRequestDispatcher("/Attendance/preview.jsp").forward(request, response);
        }
    }
}