package com.ems.service;

import com.ems.dao.PayrollconfigsDAO;
import com.ems.model.Payrollconfigs;

import java.math.BigDecimal;
import java.util.List;

public class PayrollConfigService {

    private PayrollconfigsDAO configDAO;

    public PayrollConfigService() {
        this.configDAO = new PayrollconfigsDAO();
    }

    public List<Payrollconfigs> getAllConfigs() {
        return configDAO.getAll();
    }

    public Payrollconfigs getActiveConfig() {
        return configDAO.getActiveConfig();
    }

    public Payrollconfigs getConfigById(int id) {
        return configDAO.getById(id);
    }

    public String createConfig(Payrollconfigs item){
        //Validate
        if (item.getStandardworkingdays() <= 0 || item.getStandardworkingdays() > 31) {
            return "Lỗi: Số ngày công chuẩn phải từ 1 đến 31 ngày.";
        }
        if (isNegative(item.getEmployerbhxhpercent()) || isNegative(item.getEmployerbhtnldpercent()) ||
                isNegative(item.getEmployerbhytpercent()) || isNegative(item.getEmployerbhtnpercent())) {
            return "Lỗi: Tỷ lệ bảo hiểm phần công ty đóng không được là số âm.";
        }
        if (item.getEffectivedate() == null) {
            return "Lỗi: Ngày áp dụng không được để trống.";
        }

        //insert
        boolean isSuccess = configDAO.insert(item);

        if(isSuccess){
            if (item.getIsactive() != null && item.getIsactive()) {
                configDAO.deactivateAllExcept(item.getId());
            }
            return "Success";
        }
        return "Lỗi: Không thể lưu cấu hình vào hệ thống.";
    }

    private boolean isNegative(BigDecimal value) {
        return value != null && value.compareTo(BigDecimal.ZERO) < 0;
    }

}
