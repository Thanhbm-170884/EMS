package com.ems.controller;

import com.ems.model.Shifts;
import com.ems.service.ShiftManagementService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalTime;

@WebServlet("/shift-management")
public class ShiftManagementServlet extends HttpServlet {

    private final ShiftManagementService service = new ShiftManagementService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("edit".equals(action)) {
            int id = Integer.parseInt(req.getParameter("id"));
            req.setAttribute("shift", service.getById(id));
        }
        req.setAttribute("shifts", service.getAllShifts());
        req.getRequestDispatcher("/shift-management.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        try {
            if ("delete".equals(action)) {
                service.delete(Integer.parseInt(req.getParameter("id")));
                resp.sendRedirect(req.getContextPath() + "/shift-management?success=3");
            } else {
                Shifts s = new Shifts();
                String idParam = req.getParameter("id");
                if (idParam != null && !idParam.isBlank()) s.setId(Integer.parseInt(idParam));
                s.setName(req.getParameter("name").trim());
                s.setStarttime(LocalTime.parse(req.getParameter("startTime")));
                s.setEndtime(LocalTime.parse(req.getParameter("endTime")));
                String bs = req.getParameter("breakStart");
                String be = req.getParameter("breakEnd");
                s.setBreakstart(bs != null && !bs.isBlank() ? LocalTime.parse(bs) : null);
                s.setBreakend(be != null && !be.isBlank() ? LocalTime.parse(be) : null);
                boolean isNew = (s.getId() == null);
                service.save(s);
                resp.sendRedirect(req.getContextPath() + "/shift-management?success=" + (isNew ? "1" : "2"));
            }
        } catch (IllegalArgumentException | IllegalStateException ex) {
            req.setAttribute("error", ex.getMessage());
            req.setAttribute("shifts", service.getAllShifts());
            req.getRequestDispatcher("/shift-management.jsp").forward(req, resp);
        }
    }
}