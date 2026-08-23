package com.ems.Validate;



import com.ems.model.AttendanceRecord; // ĐỔI theo package thật chứa AttendanceRecord

import java.time.LocalDate;

public class AttendanceValidator {

    public static void validate(AttendanceRecord r) {
        r.clearErrors(); // cho phép gọi validate lại nhiều lần (sau khi user sửa)

        int row = r.getRowNumber();

        if (r.getDate() == null) {
            r.addError("Dòng " + row + ": Cột Ngày trống hoặc sai định dạng");
        } else if (r.getDate().isAfter(LocalDate.now())) {
            r.addError("Dòng " + row + ": Ngày chấm công không được là ngày trong tương lai");
        }

        if (isBlank(r.getEmployeeCode())) {
            r.addError("Dòng " + row + ": Thiếu Mã nhân viên");
        }

        if (isBlank(r.getFullName())) {
            r.addError("Dòng " + row + ": Thiếu Họ và Tên");
        }

        if (isBlank(r.getDepartment())) {
            r.addError("Dòng " + row + ": Thiếu Phòng ban");
        }

        if (r.getCheckIn() == null) {
            r.addError("Dòng " + row + ": Cột Check in trống hoặc sai định dạng giờ");
        }

        if (r.getCheckOut() == null) {
            r.addError("Dòng " + row + ": Cột Check out trống hoặc sai định dạng giờ");
        }

        if (r.getCheckIn() != null && r.getCheckOut() != null
                && !r.getCheckOut().isAfter(r.getCheckIn())) {
            r.addError("Dòng " + row + ": Giờ Check out phải sau giờ Check in");
        }
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
