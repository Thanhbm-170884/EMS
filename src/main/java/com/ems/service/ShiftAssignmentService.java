package com.ems.service;

import com.ems.dao.NotificationDAO;
import com.ems.dao.ShiftAssignmentDAO;
import com.ems.dto.ShiftAssignmentBatchDTO;
import com.ems.model.Shiftassignmentbatches;

import java.util.List;

public class ShiftAssignmentService {

    public List<ShiftAssignmentBatchDTO> getAllBatches() {
        return ShiftAssignmentDAO.getAllBatches();
    }

    public ShiftAssignmentBatchDTO getById(int id) {
        return ShiftAssignmentDAO.getBatchById(id);
    }

    public void create(Shiftassignmentbatches b, List<Integer> weekdays, List<Integer> empIds, String scope) {
        validate(b, weekdays, empIds, null); // null = batch mới, chưa có id
        ShiftAssignmentDAO.createBatch(b, weekdays, empIds);
        sendNotification("Ca làm việc","Ca làm việc vừa được cập nhật. Vui lòng kiểm tra", empIds, scope);
    }

    public void update(Shiftassignmentbatches b, List<Integer> weekdays, List<Integer> empIds,  String scope) {
        validate(b, weekdays, empIds, b.getId()); // truyền id để loại trừ chính mình khi check
        ShiftAssignmentDAO.updateBatch(b, weekdays, empIds);
        sendNotification("Cập nhật ca làm việc", "Ca làm việc vừa được chỉnh sửa lại. Vui lòng kiểm tra", empIds, scope);
    }

    public void delete(int id) {
        ShiftAssignmentDAO.deleteBatch(id);
    }

    private void sendNotification(String title, String message, List<Integer> empIds, String scope){
        if("all".equals(scope)){
            NotificationDAO.notifyAllEmployee(title, message);
        }else{
            NotificationDAO.notifyEmployees(title, message, empIds);
        }
    }

    /**
     * Validate batch trước khi lưu.
     * @param excludeBatchId id batch đang sửa (null khi tạo mới) — dùng để bỏ qua chính nó khi check conflict
     */
    private void validate(Shiftassignmentbatches b, List<Integer> weekdays,
                          List<Integer> empIds, Integer excludeBatchId) {
        // ── Validate cơ bản ──
        if (b.getName() == null || b.getName().isBlank())
            throw new IllegalArgumentException("Tên bảng phân ca không được để trống.");
        if (b.getShiftId() == null)
            throw new IllegalArgumentException("Phải chọn ca làm việc.");
        if (b.getStartDate() == null)
            throw new IllegalArgumentException("Phải nhập ngày bắt đầu.");
        if (b.getEndDate() != null && b.getEndDate().isBefore(b.getStartDate()))
            throw new IllegalArgumentException("Ngày kết thúc phải sau ngày bắt đầu.");
        if (empIds == null || empIds.isEmpty())
            throw new IllegalArgumentException("Phải chọn ít nhất 1 nhân viên áp dụng.");

        if ("WEEKLY".equals(b.getRecurType()) && (weekdays == null || weekdays.isEmpty()))
            throw new IllegalArgumentException("Lặp hàng tuần phải chọn ít nhất 1 ngày trong tuần.");

        if ("MONTHLY".equals(b.getRecurType())) {
            if (b.getMonthlyType() == null)
                throw new IllegalArgumentException("Phải chọn kiểu lặp hàng tháng.");
            if ("WEEKDAY".equals(b.getMonthlyType())
                    && (b.getMonthlyWeekday() == null || b.getMonthlyOccurrence() == null))
                throw new IllegalArgumentException("Thiếu thông tin thứ/lần lặp trong tháng.");
            if ("DATE".equals(b.getMonthlyType()) && b.getMonthlyDay() == null)
                throw new IllegalArgumentException("Thiếu ngày lặp trong tháng.");
        }

        // ── Validate conflict chồng ca ──
        List<String> conflicts = ShiftAssignmentDAO.findConflictingEmployees(b, weekdays, empIds, excludeBatchId);
        if (!conflicts.isEmpty()) {
            StringBuilder sb = new StringBuilder(
                    "Một số nhân viên đã có ca làm việc chồng giờ trong khoảng thời gian này:\n");
            for (String c : conflicts) {
                sb.append("  • ").append(c).append("\n");
            }
            sb.append("Vui lòng điều chỉnh lại ca hoặc danh sách nhân viên.");
            throw new IllegalArgumentException(sb.toString());
        }
    }
}
