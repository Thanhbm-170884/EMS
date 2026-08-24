package com.ems.servlet;

import com.ems.Validate.AttendanceValidator;
import com.ems.model.AttendanceRecord;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@WebServlet("/Attendance/edit")
public class EditServlet extends HttpServlet {

    // =========================
    // GIỜ CHUẨN
    // =========================

    private static final LocalTime STANDARD_CHECKIN =
            LocalTime.of(8, 0);

    private static final LocalTime STANDARD_CHECKOUT =
            LocalTime.of(17, 0);


    // =========================================================
    // GET
    // =========================================================
    //
    // Hiện tại bạn dùng MODAL nên GET này không cần mở edit.jsp.
    //
    // Modal được mở bằng JavaScript trong attendance.jsp.
    //
    // Vì vậy nếu ai truy cập trực tiếp:
    // /Attendance/edit?code=...&date=...
    //
    // thì quay về trang attendance.
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(
                request.getContextPath()
                        + "/Attendance/attendance.jsp"
        );
    }


    // =========================================================
    // POST
    // =========================================================
    //
    // Nhận dữ liệu từ FORM trong Modal:
    //
    // originalCode
    // originalDate
    // checkIn
    // checkOut
    //
    // Sau đó cập nhật trực tiếp AttendanceRecord
    // trong session.previewList.
    // =========================================================

    @Override
    @SuppressWarnings("unchecked")
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        // =========================
        // LẤY DANH SÁCH PREVIEW
        // =========================

        List<AttendanceRecord> previewList =
                (List<AttendanceRecord>) session.getAttribute("previewList");


        // =========================
        // LẤY THÔNG TIN BẢN GHI GỐC
        // =========================

        String originalCode =
                request.getParameter("originalCode");

        String originalDate =
                request.getParameter("originalDate");


        // =========================
        // TÌM RECORD
        // =========================

        AttendanceRecord target =
                findRecord(
                        previewList,
                        originalCode,
                        originalDate
                );


        // =========================
        // KHÔNG TÌM THẤY
        // =========================

        if (target == null) {

            session.setAttribute(
                    "editError",
                    "Không tìm thấy dòng dữ liệu cần sửa. Vui lòng upload lại file."
            );

            response.sendRedirect(
                    request.getContextPath()
                            + "/Attendance/upload.jsp"
            );

            return;
        }


        // =====================================================
        // CHỈ CẬP NHẬT CHECK-IN VÀ CHECK-OUT
        // =====================================================

        LocalTime newCheckIn =
                parseTimeSafe(
                        request.getParameter("checkIn")
                );

        LocalTime newCheckOut =
                parseTimeSafe(
                        request.getParameter("checkOut")
                );


        target.setCheckIn(newCheckIn);

        target.setCheckOut(newCheckOut);


        // =====================================================
        // TÍNH LẠI CHECK-IN MUỘN
        // =====================================================

        long lateMinutes =
                calculateLateMinutes(newCheckIn);

        target.setLateMinutes(lateMinutes);


        // =====================================================
        // TÍNH LẠI CHECK-OUT SỚM
        // =====================================================

        long earlyLeaveMinutes =
                calculateEarlyLeaveMinutes(newCheckOut);

        target  .setEarlyLeaveMinutes(
                earlyLeaveMinutes
        );


        // =====================================================
        // DEBUG
        // =====================================================

        System.out.println(
                "========================================"
        );

        System.out.println(
                "DEBUG EDIT ATTENDANCE"
        );

        System.out.println(
                "Employee Code = "
                        + target.getEmployeeCode()
        );

        System.out.println(
                "Date = "
                        + target.getDate()
        );

        System.out.println(
                "Full Name = "
                        + target.getFullName()
        );

        System.out.println(
                "Department = "
                        + target.getDepartment()
        );

        System.out.println(
                "Check-in = "
                        + target.getCheckIn()
        );

        System.out.println(
                "Late Minutes = "
                        + target.getLateMinutes()
        );

        System.out.println(
                "Check-out = "
                        + target.getCheckOut()
        );

        System.out.println(
                "Early Leave Minutes = "
                        + target.getEarlyLeaveMinutes()
        );

        System.out.println(
                "========================================"
        );


        // =====================================================
        // VALIDATE
        // =====================================================

        target.clearErrors();

        AttendanceValidator.validate(target);


        // =====================================================
        // NẾU KHÔNG HỢP LỆ
        // =====================================================

        if (!target.isValid()) {

            session.setAttribute(
                    "editError",
                    "Dữ liệu chưa hợp lệ, vui lòng kiểm tra lại."
            );

            response.sendRedirect(
                    request.getContextPath()
                            + "/Attendance/attendance.jsp"
            );

            return;
        }


        // =====================================================
        // THÀNH CÔNG
        // =====================================================

        session.setAttribute(
                "editSuccess",
                "Đã cập nhật dữ liệu chấm công thành công."
        );


        // =========================
        // QUAY LẠI TRANG PREVIEW
        // =========================

        response.sendRedirect(
                request.getContextPath()
                        + "/Attendance/attendance.jsp"
        );
    }


    // =========================================================
    // TÌM RECORD
    // =========================================================

    private AttendanceRecord findRecord(
            List<AttendanceRecord> list,
            String code,
            String dateStr) {

        if (list == null
                || code == null
                || dateStr == null) {

            return null;
        }


        for (AttendanceRecord r : list) {

            if (code.equals(r.getEmployeeCode())
                    && dateStr.equals(
                    String.valueOf(r.getDate()))) {

                return r;
            }
        }

        return null;
    }


    // =========================================================
    // TÍNH CHECK-IN MUỘN
    // =========================================================

    private long calculateLateMinutes(
            LocalTime checkIn) {

        if (checkIn == null) {
            return 0;
        }


        if (checkIn.isAfter(
                STANDARD_CHECKIN)) {

            return Duration.between(
                    STANDARD_CHECKIN,
                    checkIn
            ).toMinutes();
        }


        return 0;
    }


    // =========================================================
    // TÍNH CHECK-OUT SỚM
    // =========================================================

    private long calculateEarlyLeaveMinutes(
            LocalTime checkOut) {

        if (checkOut == null) {
            return 0;
        }


        if (checkOut.isBefore(
                STANDARD_CHECKOUT)) {

            return Duration.between(
                    checkOut,
                    STANDARD_CHECKOUT
            ).toMinutes();
        }


        return 0;
    }


    // =========================================================
    // TRIM STRING
    // =========================================================

    private String trim(String value) {

        return value == null
                ? ""
                : value.trim();
    }


    // =========================================================
    // PARSE DATE
    // =========================================================

    private LocalDate parseDateSafe(
            String value) {

        if (value == null
                || value.trim().isEmpty()) {

            return null;
        }


        try {

            return LocalDate.parse(
                    value.trim()
            );

        } catch (Exception e) {

            return null;
        }
    }


    // =========================================================
    // PARSE TIME
    // =========================================================

    private LocalTime parseTimeSafe(
            String value) {

        if (value == null
                || value.trim().isEmpty()) {

            return null;
        }


        try {

            return LocalTime.parse(
                    value.trim()
            );

        } catch (Exception e) {

            return null;
        }
    }
}