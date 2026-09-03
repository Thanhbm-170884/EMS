package com.ems.service;

import com.ems.dao.ShiftManagementDAO;
import com.ems.model.Shifts;

import java.util.List;

public class ShiftManagementService {

    public List<Shifts> getAllShifts() {
        return ShiftManagementDAO.getAllCustomShifts();
    }

    public Shifts getById(int id) {
        return ShiftManagementDAO.getShiftById(id);
    }

    public void save(Shifts s) {
        validate(s);
        if (s.getId() == null) {
            ShiftManagementDAO.createShift(s);
        } else {
            ShiftManagementDAO.updateShift(s);
        }
    }

    public void delete(int id) {
        int used = ShiftManagementDAO.countBatchesByShift(id);
        if (used > 0) {
            throw new IllegalStateException(
                    "Không thể xóa ca này vì đang được sử dụng trong " + used + " bảng phân ca.");
        }
        ShiftManagementDAO.deleteShift(id);
    }

    private void validate(Shifts s) {
        if (s.getName() == null || s.getName().isBlank())
            throw new IllegalArgumentException("Tên ca không được để trống.");
        if (ShiftManagementDAO.isNameExists(s.getName().trim(), s.getId()))
            throw new IllegalArgumentException("Đã tồn tại ca làm việc có tên \"" + s.getName().trim() + "\". Vui lòng chọn tên khác.");
        if (s.getStarttime() == null || s.getEndtime() == null)
            throw new IllegalArgumentException("Phải nhập giờ bắt đầu và kết thúc.");
        if (!s.getStarttime().isBefore(s.getEndtime()))
            throw new IllegalArgumentException("Giờ kết thúc phải sau giờ bắt đầu.");
        if (s.getBreakstart() != null && s.getBreakend() != null) {
            if (!s.getBreakstart().isBefore(s.getBreakend()))
                throw new IllegalArgumentException("Giờ nghỉ không hợp lệ.");
            if (s.getBreakstart().isBefore(s.getStarttime()) || s.getBreakend().isAfter(s.getEndtime()))
                throw new IllegalArgumentException("Giờ nghỉ phải nằm trong khoảng ca làm việc.");
        }
    }
}