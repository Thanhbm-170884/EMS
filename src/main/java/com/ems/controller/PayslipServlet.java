package com.ems.controller;

import com.ems.dao.PayslipDAO;
import com.ems.dto.PayslipDTO;
import com.ems.model.Departments;
import com.ems.model.Timesheetperiods;
import com.ems.model.Users;
import com.ems.service.PayrollService;
import com.ems.service.PayslipService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.util.List;

@WebServlet("/payslips")
public class PayslipServlet extends HttpServlet {

    private PayslipDAO payslipDAO;
    private PayslipService payslipService;

    @Override
    public void init() throws ServletException {
        payslipDAO = new PayslipDAO();
        payslipService = new PayslipService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        String periodIdParam = request.getParameter("periodId");
        String searchParam = request.getParameter("search");
        String deptIdParam = request.getParameter("departmentId");

        int periodId = 0;
        if (periodIdParam != null && !periodIdParam.isEmpty()) {
            try {
                periodId = Integer.parseInt(periodIdParam);
            } catch (NumberFormatException e) {
            }
        }

        Integer departmentId = null;
        if (deptIdParam != null && !deptIdParam.isEmpty()) {
            try {
                departmentId = Integer.parseInt(deptIdParam);
            } catch (NumberFormatException e) {
            }
        }

        String searchStr = (searchParam != null) ? searchParam.trim() : "";

        // Get periods and default to latest if none requested
        // Nothing
        List<Timesheetperiods> periods = payslipService.getAllTimesheetPeriods();
        if (periodId == 0 && !periods.isEmpty()) {
            periodId = periods.get(0).getId();
        }

        boolean isCurrentPeriodLocked = false;
        for (Timesheetperiods p : periods) {
            if (p.getId() != null && p.getId() == periodId) {
                isCurrentPeriodLocked = (p.getIslocked() != null && p.getIslocked());
                break;
            }
        }

        List<PayslipDTO> payslips = payslipDAO.getPayslipsByPeriodForView(periodId, searchStr, departmentId);
        List<Departments> departments = payslipService.getAllDepartments();

        // Calculate stats
        int totalEmployees = payslips.size();
        BigDecimal totalGross = BigDecimal.ZERO;
        BigDecimal totalNet = BigDecimal.ZERO;
        BigDecimal totalDeductions = BigDecimal.ZERO;

        for (PayslipDTO p : payslips) {
            if (p.getGrossAmount() != null)
                totalGross = totalGross.add(p.getGrossAmount());
            if (p.getNetAmount() != null)
                totalNet = totalNet.add(p.getNetAmount());
            if (p.getTotalInsurance() != null)
                totalDeductions = totalDeductions.add(p.getTotalInsurance());
            if (p.getTaxDeduction() != null)
                totalDeductions = totalDeductions.add(p.getTaxDeduction());
        }

        DecimalFormat decimalFormat = new DecimalFormat("#,###");

        // Pagination handling
        int page = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
            } catch (NumberFormatException ignored) {
            }
        }
        if (page < 1)
            page = 1;

        int pageSize = 5;
        String pageSizeParam = request.getParameter("pageSize");
        if (pageSizeParam != null && !pageSizeParam.trim().isEmpty()) {
            try {
                pageSize = Integer.parseInt(pageSizeParam);
            } catch (NumberFormatException ignored) {
            }
        }
        if (pageSize < 1)
            pageSize = 5;

        int totalFilteredItems = payslips.size();
        int totalPages = (int) Math.ceil((double) totalFilteredItems / pageSize);
        if (totalPages < 1)
            totalPages = 1;
        if (page > totalPages)
            page = totalPages;

        int fromIndex = (page - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalFilteredItems);

        List<PayslipDTO> pagedPayslips = (fromIndex < totalFilteredItems)
                ? payslips.subList(fromIndex, toIndex)
                : java.util.Collections.emptyList();

        request.setAttribute("payslips", pagedPayslips);

        request.setAttribute("totalFilteredItems", totalFilteredItems);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);

        request.setAttribute("periods", periods);
        request.setAttribute("departments", departments);
        request.setAttribute("selectedPeriodId", periodId);
        request.setAttribute("selectedDepartmentId", departmentId);
        request.setAttribute("search", searchStr);
        request.setAttribute("isCurrentPeriodLocked", isCurrentPeriodLocked);
        request.setAttribute("totalEmployees", totalEmployees);
        request.setAttribute("formattedTotalGross", decimalFormat.format(totalGross).replace(',', '.'));
        request.setAttribute("formattedTotalNet", decimalFormat.format(totalNet).replace(',', '.'));
        request.setAttribute("formattedTotalDeductions", decimalFormat.format(totalDeductions).replace(',', '.'));

        request.getRequestDispatcher("/payslip-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer managerId = (Integer) session.getAttribute("accountId");

        if (managerId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("generate".equals(action)) {
            int periodId = Integer.parseInt(request.getParameter("periodId"));

            if (isPeriodLocked(periodId)) {
                request.getSession().setAttribute("msgError", "Kỳ lương đã bị khóa, không thể thực hiện thao tác!");
                response.sendRedirect(request.getContextPath() + "/payslips?periodId=" + periodId);
                return;
            }

            PayrollService payrollService = new PayrollService();
            String result = payrollService.generatePayrollMonth(periodId, managerId);

            if (result.startsWith("SUCCESS")) {
                String count = result.split(":")[1];
                request.getSession().setAttribute("msgSuccess",
                        "Đã tính lương thành công cho " + count + " nhân viên!");

            } else {
                request.getSession().setAttribute("msgError", result);
            }

            response.sendRedirect(request.getContextPath() + "/payslips?periodId=" + periodId);
        } else if ("edit".equals(action)) {
            // Lấy dữ liệu từ Form Edit gửi lên
            int payslipId = Integer.parseInt(request.getParameter("payslipId"));
            int periodId = Integer.parseInt(request.getParameter("periodId"));

            if (isPeriodLocked(periodId)) {
                request.getSession().setAttribute("msgError", "Kỳ lương đã bị khóa, không thể thực hiện thao tác!");
                response.sendRedirect(request.getContextPath() + "/payslips?periodId=" + periodId);
                return;
            }

            String note = request.getParameter("note");

            // Xử lý tiền tệ (Nếu rỗng thì cho = 0)
            BigDecimal bonus = request.getParameter("bonus").isEmpty() ? BigDecimal.ZERO
                    : new BigDecimal(request.getParameter("bonus"));
            BigDecimal penalty = request.getParameter("penalty").isEmpty() ? BigDecimal.ZERO
                    : new BigDecimal(request.getParameter("penalty"));
            BigDecimal advance = request.getParameter("advance").isEmpty() ? BigDecimal.ZERO
                    : new BigDecimal(request.getParameter("advance"));

            // Gọi Service tính lại và cập nhật
            com.ems.service.PayrollService payrollService = new com.ems.service.PayrollService();
            String result = payrollService.updateManualPayslip(payslipId, bonus, penalty, advance, note, managerId);

            if ("SUCCESS".equals(result)) {
                request.getSession().setAttribute("msgSuccess",
                        "Đã cập nhật phiếu lương thành công! Thuế và Thực lĩnh đã được tính toán lại.");
            } else {
                request.getSession().setAttribute("msgError", result);
            }
            response.sendRedirect(request.getContextPath() + "/payslips?periodId=" + periodId);
        } else if ("confirm".equals(action)) {
            int periodId = 0;
            try {
                periodId = Integer.parseInt(request.getParameter("periodId"));
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("msgError", "Kỳ lương không hợp lệ!");
                response.sendRedirect(request.getContextPath() + "/payslips");
                return;
            }

            if (isPeriodLocked(periodId)) {
                request.getSession().setAttribute("msgError", "Kỳ lương đã bị khóa, không thể thực hiện thao tác!");
                response.sendRedirect(request.getContextPath() + "/payslips?periodId=" + periodId);
                return;
            }

            PayrollService payrollService = new PayrollService();
            String result = payrollService.confirmPayroll(periodId);

            if (result.startsWith("SUCCESS")) {
                String count = result.split(":")[1];
                request.getSession().setAttribute("msgSuccess",
                        "Đã chốt thành công " + count + " phiếu lương! Dữ liệu đã được khóa.");
            } else {
                request.getSession().setAttribute("msgError", result);
            }

            response.sendRedirect(request.getContextPath() + "/payslips?periodId=" + periodId);
        }
    }

    private boolean isPeriodLocked(int periodId) {
        List<Timesheetperiods> allPeriods = payslipService.getAllTimesheetPeriods();
        for (Timesheetperiods p : allPeriods) {
            if (p.getId() != null && p.getId() == periodId) {
                return (p.getIslocked() != null && p.getIslocked());
            }
        }
        return false;
    }
}
