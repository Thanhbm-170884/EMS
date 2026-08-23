package com.ems.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter(urlPatterns = {
        // ── Admin ──
        "/home_admin",
        "/home_admin.jsp",

        // ── Manager ──
        "/home_manager",
        "/home_manager.jsp",
        "/holiday",
        "/holiday.jsp",
        "/work-schedule",
        "/work-schedule.jsp",
        "/base-salaries",
        "/base-salary",
        "/base-salary-list.jsp",
        "/manager-payslips",
        "/manager-payslip",
        "/manager-payslip-list.jsp",
        "/request-manager.jsp",
        "/employee-balances.jsp",
        "/pay-periods",
        "/pay_periods",
        "/pay-period",
        "/pay_period",
        "/pay-period-list.jsp",
        "/salary-management",
        "/salary-management.jsp",

        // ── Employee (chỉ cần check đăng nhập) ──
        "/home",
        "/home.jsp",
        "/requests",
        "/request.jsp",
        "/requestList.jsp",
        "/attendance.jsp"
})
public class AutherFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        if (session == null || (session.getAttribute("user") == null && session.getAttribute("username") == null)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String role = (String) session.getAttribute("role");
        String uri = req.getRequestURI();
        String path = uri.substring(req.getContextPath().length());
        // admin
        boolean isAdminPage = path.equals("/home_admin") || path.equals("/home_admin.jsp");
        if (isAdminPage && !"admin".equalsIgnoreCase(role)) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // manager
        boolean isManagerPage = path.equals("/home_manager") || path.equals("/home_manager.jsp")
                || path.equals("/holiday") || path.equals("/holiday.jsp")
                || path.equals("/work-schedule") || path.equals("/work-schedule.jsp")
                || path.equals("/base-salaries") || path.equals("/base-salary")
                || path.equals("/base-salary-list.jsp")
                || path.equals("/manager-payslips") || path.equals("/manager-payslip")
                || path.equals("/manager-payslip-list.jsp")
                || path.equals("/request-manager.jsp")
                || path.equals("/employee-balances.jsp")
                || path.equals("/pay-periods") || path.equals("/pay_periods")
                || path.equals("/pay-period") || path.equals("/pay_period")
                || path.equals("/pay-period-list.jsp")
                || path.equals("/salary-management") || path.equals("/salary-management.jsp");
        if (isManagerPage && !"manager".equalsIgnoreCase(role)) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        chain.doFilter(request, response);
    }
}
