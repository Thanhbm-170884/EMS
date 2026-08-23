package com.ems.controller;

import com.ems.dao.UserDAO;
import com.ems.dto.PayslipDTO;
import com.ems.service.PayslipService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

@WebServlet(name = "MyPayslipServlet", urlPatterns = {"/my-payslip"})
public class MyPayslipServlet extends HttpServlet {

    private PayslipService payslipService;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        payslipService = new PayslipService();
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer accountId = (Integer) session.getAttribute("accountId");
        if (accountId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer userId = userDAO.getUserIdByAccountId(accountId);
        if (userId == null) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không tìm thấy thông tin nhân viên cho tài khoản này.");
            return;
        }

        List<PayslipDTO> payslips = payslipService.getPayslipsByUserId(userId);

        PayslipDTO currentPayslip = null;
        List<PayslipDTO> historyPayslips = Collections.emptyList();

        if (payslips != null && !payslips.isEmpty()) {
            currentPayslip = payslips.get(0);
            if (payslips.size() > 1) {
                historyPayslips = payslips.subList(1, payslips.size());
            }
        }

        request.setAttribute("currentPayslip", currentPayslip);
        request.setAttribute("historyPayslips", historyPayslips);

        request.getRequestDispatcher("/my-payslip.jsp").forward(request, response);
    }
}
