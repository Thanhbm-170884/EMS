package com.ems.service;

import com.ems.model.*;

import com.ems.dao.PayrollconfigsDAO;
import com.ems.dao.AllowanceTypeDAO;
import com.ems.dao.UserDAO;
import com.ems.dao.BaseSalaryDAO;
import com.ems.dao.PayslipDAO;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

public class PayrollService {

    private PayrollconfigsDAO configDAO = new PayrollconfigsDAO();
    private AllowanceTypeDAO allowanceDAO = new AllowanceTypeDAO();
    private UserDAO userDAO = new UserDAO(); // Chứa thông tin số người phụ thuộc
    private BaseSalaryDAO salaryDAO = new BaseSalaryDAO(); // Chứa lương cơ bản
    private PayslipDAO payslipDAO = new PayslipDAO();

    // Tính toán phiếu lương
    public Payslips calculatePayslip(int userId, int periodId, BigDecimal actualWorkDays, BigDecimal otHours,
            BigDecimal bonus, BigDecimal penalty, BigDecimal advance) {

        // Lấy dữ liệu cấu hình ĐANG ÁP DỤNG
        Payrollconfigs config = configDAO.getActiveConfig();
        if (config == null)
            throw new RuntimeException("Lỗi: Chưa có Cấu hình lương nào được kích hoạt!");

        // Lấy thông tin nhân viên & Lương cơ bản
        Users user = userDAO.getById(userId);
        Employmentbasesalarys baseSalaryInfo = salaryDAO.getByUserId(userId);
        BigDecimal baseSalary = baseSalaryInfo != null ? baseSalaryInfo.getBasesalary() : BigDecimal.ZERO;

        // Khởi tạo Phiếu lương
        Payslips payslip = new Payslips();
        payslip.setUserid(userId);
        payslip.setPeriodid(periodId);
        payslip.setStandardworkdays(config.getStandardworkingdays());
        payslip.setActualworkdays(actualWorkDays);
        payslip.setOthours(otHours);
        payslip.setBasesalary(baseSalary);
        payslip.setBonusamount(bonus != null ? bonus : BigDecimal.ZERO);
        payslip.setPenaltyamount(penalty != null ? penalty : BigDecimal.ZERO);
        payslip.setAdvanceamount(advance != null ? advance : BigDecimal.ZERO);
        payslip.setOtherdeductions(BigDecimal.ZERO);

        // --- TÍNH LƯONG THỰC TẾ ---
        BigDecimal actualBaseSalary = baseSalary
                .multiply(actualWorkDays)
                .divide(new BigDecimal(config.getStandardworkingdays()), 2, RoundingMode.HALF_UP);
        payslip.setActualbasesalary(actualBaseSalary);

        // --- TÍNH TIỀN OT ---
        // Tiền 1 giờ = (Lương cơ bản / Ngày chuẩn / 8 tiếng)
        BigDecimal hourlyRate = baseSalary
                .divide(new BigDecimal(config.getStandardworkingdays()), 2, RoundingMode.HALF_UP)
                .divide(new BigDecimal("8"), 2, RoundingMode.HALF_UP);
        BigDecimal otSalary = hourlyRate.multiply(otHours).multiply(config.getOtweekdayrate());
        payslip.setOtsalary(otSalary);

        // --- TÍNH PHỤ CẤP ---
        List<Allowancetypes> allowances = allowanceDAO.getAllActive(); // Lấy các phụ cấp đang bật
        BigDecimal totalAllowance = BigDecimal.ZERO;
        BigDecimal totalTaxExemptAllowance = BigDecimal.ZERO; // Phụ cấp miễn thuế
        BigDecimal totalInsuranceAllowance = BigDecimal.ZERO; // Phụ cấp đóng BH

        for (Allowancetypes alw : allowances) {
            BigDecimal amt = alw.getDefaultamount(); // Tính theo Fixed
            if ("ByWorkDay".equals(alw.getCalculationmethod())) {
                amt = amt.multiply(actualWorkDays).divide(new BigDecimal(config.getStandardworkingdays()), 2,
                        RoundingMode.HALF_UP);
            }
            totalAllowance = totalAllowance.add(amt);

            // Kiểm tra miễn thuế TNCN
            if (!alw.getIstaxable()) {
                totalTaxExemptAllowance = totalTaxExemptAllowance.add(amt);
            } else if (alw.getTaxexemptlimit().compareTo(BigDecimal.ZERO) > 0) {
                // Có hạn mức miễn thuế
                BigDecimal exemptAmt = amt.min(alw.getTaxexemptlimit());
                totalTaxExemptAllowance = totalTaxExemptAllowance.add(exemptAmt);
            }

            // Kiểm tra đóng BHXH
            if (alw.getIsinsurancesalary()) {
                totalInsuranceAllowance = totalInsuranceAllowance.add(amt);
            }
        }
        payslip.setTotalallowanceamount(totalAllowance);

        // --- TÍNH TỔNG THU NHẬP (GROSS) ---
        BigDecimal grossAmount = actualBaseSalary.add(otSalary).add(totalAllowance).add(payslip.getBonusamount());
        payslip.setGrossamount(grossAmount);

        // --- TÍNH BẢO HIỂM ---
        // Nền đóng bảo hiểm (bị giới hạn bởi MaxInsuranceSalary)
        BigDecimal insuranceBase = actualBaseSalary.add(totalInsuranceAllowance);
        if (insuranceBase.compareTo(config.getMaxinsurancesalary()) > 0) {
            insuranceBase = config.getMaxinsurancesalary();
        }

        BigDecimal bhxh = insuranceBase.multiply(config.getBhxhpercent()).divide(new BigDecimal("100"), 2,
                RoundingMode.HALF_UP);
        BigDecimal bhyt = insuranceBase.multiply(config.getBhytpercent()).divide(new BigDecimal("100"), 2,
                RoundingMode.HALF_UP);
        BigDecimal bhtn = insuranceBase.multiply(config.getBhtnpercent()).divide(new BigDecimal("100"), 2,
                RoundingMode.HALF_UP);
        BigDecimal totalInsurance = bhxh.add(bhyt).add(bhtn);

        payslip.setBhxhamount(bhxh);
        payslip.setBhytamount(bhyt);
        payslip.setBhtnamount(bhtn);
        payslip.setTotalinsurancededuction(totalInsurance);

        // --- TÍNH THUẾ TNCN (Bậc Thang) ---
        payslip.setDependentscount(user.getDependentscount());
        BigDecimal dependentDeduction = config.getDependenttaxdeduction()
                .multiply(new BigDecimal(user.getDependentscount()));
        payslip.setDependentdeduction(dependentDeduction);

        // Thu nhập tính thuế = Gross - Phụ cấp miễn thuế - Bảo hiểm - Giảm trừ bản thân
        // - Giảm trừ NPT
        BigDecimal assessableIncome = grossAmount
                .subtract(totalTaxExemptAllowance)
                .subtract(totalInsurance)
                .subtract(config.getPersonaltaxdeduction())
                .subtract(dependentDeduction);

        if (assessableIncome.compareTo(BigDecimal.ZERO) < 0) {
            assessableIncome = BigDecimal.ZERO;
        }
        payslip.setTaxableincome(assessableIncome);
        payslip.setTaxdeduction(calculatePIT(assessableIncome)); // Gọi hàm tính thuế 5 bậc

        // --- TÍNH THỰC LĨNH (NET) ---
        BigDecimal netAmount = grossAmount
                .subtract(totalInsurance)
                .subtract(payslip.getTaxdeduction())
                .subtract(payslip.getPenaltyamount())
                .subtract(payslip.getAdvanceamount());

        payslip.setNetamount(netAmount);
        payslip.setStatus("Draft");

        return payslip;
    }

    // Tính thuế TNCN theo 5 bậc lũy tiến
    private BigDecimal calculatePIT(BigDecimal assessableIncome) {
        double income = assessableIncome.doubleValue();
        double tax = 0;

        if (income <= 0)
            return BigDecimal.ZERO;

        if (income <= 10000000) {
            tax = income * 0.05;
        } else if (income <= 30000000) {
            tax = (income * 0.10) - 500000;
        } else if (income <= 60000000) {
            tax = (income * 0.20) - 2000000;
        } else if (income <= 100000000) {
            tax = (income * 0.30) - 6000000;
        } else {
            tax = (income * 0.35) - 12000000;
        }

        return BigDecimal.valueOf(tax).setScale(2, RoundingMode.HALF_UP);
    }

    // Chay tinh luong cho ca cong ty
    public String generatePayrollMonth(int periodId, int managerId) {

        // Kiem tra trung lap
        if (payslipDAO.checkPayrollExists(periodId)) {
            return "Kỳ lương này đã được tính toán rồi. Không thể chạy trùng!";
        }

        // Lay cau hinh luong
        Payrollconfigs config = configDAO.getActiveConfig();
        if (config == null)
            return "Error: Không tìm thấy Cấu hình lương nào đang Active!";

        // Lay danh sach phu cap
        List<Allowancetypes> activeAllowances = allowanceDAO.getAllActive();

        // Lay danh sach nhan vien active
        List<Users> users = userDAO.getAllActiveUsers();
        if (users == null || users.isEmpty())
            return "Error: Không có nhân viên nào trong hệ thống!";

        int successCount = 0;

        // Vong lap tinh luong
        for (Users u : users) {
            // So ngay di lam thuc te
            int actualDaysInt = payslipDAO.countActualWorkDays(u.getId(), periodId);
            BigDecimal actualDays = new BigDecimal(actualDaysInt);

            if (actualDaysInt <= 0) {
                continue;
            }

            // Set cac gia tri khac bang 0
            BigDecimal otHours = BigDecimal.ZERO;
            BigDecimal bonus = BigDecimal.ZERO;
            BigDecimal penalty = BigDecimal.ZERO;
            BigDecimal advance = BigDecimal.ZERO;

            Payslips p = calculatePayslip(u.getId(), periodId, actualDays, otHours, bonus, penalty, advance);
            p.setStatus("Draft");
            p.setAdjustedbyaccountid(managerId);

            // insert phieu luong
            int newPayslipId = payslipDAO.insertPayslip(p);

            // insert phu cap
            if (newPayslipId > 0) {
                successCount++;
                for (Allowancetypes alw : activeAllowances) {
                    BigDecimal amt = alw.getDefaultamount();
                    // Tinh lai neu set ByWorkDay
                    if ("ByWorkDay".equals(alw.getCalculationmethod())) {
                        amt = amt.multiply(actualDays)
                                .divide(new BigDecimal(config.getStandardworkingdays()), 2, RoundingMode.HALF_UP);
                    }
                    payslipDAO.insertPayslipAllowance(newPayslipId, alw.getId(), amt);
                }
            }
        }
        return "SUCCESS:" + successCount;
    }

    public String updateManualPayslip(int payslipId, BigDecimal bonus, BigDecimal penalty, BigDecimal advance,
            String note, int managerId) {
        Payslips oldPayslip = payslipDAO.getPayslipById(payslipId);
        if (oldPayslip == null)
            return "Không tìm thấy phiếu lương này!";
        if (!"Draft".equals(oldPayslip.getStatus()))
            return "Error: Chỉ được phép chỉnh sửa Bản nháp!";

        Payslips updatedPayslip = calculatePayslip(
                oldPayslip.getUserid(),
                oldPayslip.getPeriodid(),
                oldPayslip.getActualworkdays(),
                oldPayslip.getOthours(),
                bonus, penalty, advance);

        updatedPayslip.setId(payslipId);
        updatedPayslip.setNote(note);
        updatedPayslip.setAdjustedbyaccountid(managerId);

        if (payslipDAO.updatePayslip(updatedPayslip)) {
            return "SUCCESS";
        }
        return "Lỗi khi lưu vào Database!";
    }

    public String confirmPayroll(int periodId) {
        int updatedCount = payslipDAO.updatePayslipStatusByPeriod(periodId, "Draft", "Confirmed");

        if (updatedCount > 0) {
            return "SUCCESS:" + updatedCount;
        } else {
            return "Không có phiếu lương bản nháp nào cần chốt trong kỳ này!";
        }
    }

}