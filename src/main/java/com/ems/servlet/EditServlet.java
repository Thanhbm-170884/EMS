package com.ems.servlet;



import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.ems.model.AttendanceRecord;
import com.ems.Validate.AttendanceValidator;

import java.io.IOException;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

/**
 * GET  /Attendance/edit?code=...&date=...  -> hiển thị form sửa 1 dòng
 * POST /Attendance/edit                    -> lưu thay đổi TRỰC TIẾP vào object
 *      đang nằm trong session.previewList (vì List lưu reference, sửa field
 *      trên object là đủ, không cần set lại session)
 */
@WebServlet("/Attendance/edit")
public class EditServlet extends HttpServlet {

    private static final LocalTime STANDARD_CHECKIN = LocalTime.of(8, 0);

    @Override
    @SuppressWarnings("unchecked")
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        List<AttendanceRecord> previewList = (List<AttendanceRecord>) session.getAttribute("previewList");

        AttendanceRecord target = findRecord(previewList,
                request.getParameter("code"), request.getParameter("date"));

        if (target == null) {
            request.setAttribute("error", "Không tìm thấy dòng dữ liệu cần sửa (có thể phiên làm việc đã hết hạn).");
            request.getRequestDispatcher("/Attendance/attendance.jsp").forward(request, response);
            return;
        }

        request.setAttribute("record", target);
        request.getRequestDispatcher("/Attendance/edit.jsp").forward(request, response);
    }

    @Override
    @SuppressWarnings("unchecked")
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        List<AttendanceRecord> previewList = (List<AttendanceRecord>) session.getAttribute("previewList");

        AttendanceRecord target = findRecord(previewList,
                request.getParameter("originalCode"), request.getParameter("originalDate"));

        if (target == null) {
            request.setAttribute("error", "Không tìm thấy dòng dữ liệu cần sửa. Vui lòng upload lại file.");
            request.getRequestDispatcher("/Attendance/upload.jsp").forward(request, response);
            return;
        }

        target.setDate(parseDateSafe(request.getParameter("date")));
        target.setEmployeeCode(trim(request.getParameter("employeeCode")));
        target.setFullName(trim(request.getParameter("fullName")));
        target.setDepartment(trim(request.getParameter("department")));
        target.setCheckIn(parseTimeSafe(request.getParameter("checkIn")));
        target.setCheckOut(parseTimeSafe(request.getParameter("checkOut")));

        long lateMinutes = 0;
        if (target.getCheckIn() != null && target.getCheckIn().isAfter(STANDARD_CHECKIN)) {
            lateMinutes = Duration.between(STANDARD_CHECKIN, target.getCheckIn()).toMinutes();
        }
        target.setLateMinutes(lateMinutes);

        AttendanceValidator.validate(target);

        if (!target.isValid()) {
            // còn lỗi -> quay lại chính trang edit để sửa tiếp, không cho thoát
            request.setAttribute("record", target);
            request.setAttribute("error", "Dữ liệu chưa hợp lệ, vui lòng kiểm tra lại.");
            request.getRequestDispatcher("/Attendance/edit.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/Attendance/attendance.jsp");
    }

    private AttendanceRecord findRecord(List<AttendanceRecord> list, String code, String dateStr) {
        if (list == null || code == null || dateStr == null) return null;
        for (AttendanceRecord r : list) {
            if (code.equals(r.getEmployeeCode()) && dateStr.equals(String.valueOf(r.getDate()))) {
                return r;
            }
        }
        return null;
    }

    private String trim(String s) { return s == null ? "" : s.trim(); }

    private LocalDate parseDateSafe(String s) {
        try { return LocalDate.parse(s); } catch (Exception e) { return null; }
    }

    private LocalTime parseTimeSafe(String s) {
        try { return LocalTime.parse(s); } catch (Exception e) { return null; }
    }
}
