package com.ems.controller;

import com.ems.model.Payrollconfigs;
import com.ems.service.PayrollConfigService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/payroll-configs")
public class PayrollConfigServlet extends HttpServlet {

    private PayrollConfigService configService;

    @Override
    public void init() throws ServletException {
        configService = new PayrollConfigService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        List<Payrollconfigs> historyList = configService.getAllConfigs();
        Payrollconfigs activeConfig = configService.getActiveConfig();

        request.setAttribute("historyList", historyList);
        request.setAttribute("activeConfig", activeConfig);

        request.getRequestDispatcher("/payroll-config.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String message = "";

        try {
            Payrollconfigs item = new Payrollconfigs();

            //Default infor
            item.setConfigname(request.getParameter("configname"));
            item.setEffectivedate(LocalDate.parse(request.getParameter("effectivedate")));
            item.setStandardworkingdays(Integer.parseInt(request.getParameter("standardworkingdays")));

            //BH
            item.setBhxhpercent(new BigDecimal(request.getParameter("bhxhpercent")));
            item.setBhytpercent(new BigDecimal(request.getParameter("bhytpercent")));
            item.setBhtnpercent(new BigDecimal(request.getParameter("bhtnpercent")));

            // BH cong ty
            item.setEmployerbhxhpercent(new BigDecimal(request.getParameter("employerbhxhpercent")));
            item.setEmployerbhtnldpercent(new BigDecimal(request.getParameter("employerbhtnldpercent")));
            item.setEmployerbhytpercent(new BigDecimal(request.getParameter("employerbhytpercent")));
            item.setEmployerbhtnpercent(new BigDecimal(request.getParameter("employerbhtnpercent")));

            item.setMaxinsurancesalary(new BigDecimal(request.getParameter("maxinsurancesalary")));

            //TNCN
            item.setPersonaltaxdeduction(new BigDecimal(request.getParameter("personaltaxdeduction")));
            item.setDependenttaxdeduction(new BigDecimal(request.getParameter("dependenttaxdeduction")));


            //Status check = value null
            item.setIsactive(request.getParameter("isactive") != null);

            item.setCreatedbyaccountid(1);

            message = configService.createConfig(item);

        } catch (Exception e) {
            message = "Lỗi dữ liệu đầu vào: " + e.getMessage();
        }

        if ("Success".equals(message)) {
            response.sendRedirect(request.getContextPath() + "/payroll-configs");
        } else {
            request.getSession().setAttribute("errorMessage", message);
            response.sendRedirect(request.getContextPath() + "/payroll-configs");
        }
    }
}
