package com.ems.controller;

import com.ems.service.PositionManageService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "PositionServlet", urlPatterns = {"/positions"})
public class PositionServlet extends HttpServlet {

    private final PositionManageService positionService = new PositionManageService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("role");
        if (role == null || !role.equalsIgnoreCase("Admin")) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String username = (String) session.getAttribute("username");
        Map<String, String> adminInfo = positionService.getAdminHeaderInfo(username);

        request.setAttribute("fullName", adminInfo.get("fullName"));
        request.setAttribute("deptName", adminInfo.get("deptName"));

        List<Map<String, Object>> positionsList = positionService.getAllPositionsWithStats();
        Map<Integer, List<Map<String, Object>>> posEmployeesMap = positionService.getAllEmployeesGroupedByPosition();

        Map<String, Integer> stats = positionService.getPositionStats(positionsList);
        int totalPositions = stats.getOrDefault("total", 0);

        int assignedPositions = 0;
        if (positionsList != null) {
            for (Map<String, Object> p : positionsList) {
                int totalEmp = (Integer) p.get("totalEmployees");
                assignedPositions += totalEmp;
            }
        }

        request.setAttribute("totalPositions", totalPositions);
        // Flash messages
        String successMsg = (String) session.getAttribute("successMsg");
        String errorMsg = (String) session.getAttribute("errorMsg");
        if (successMsg != null) {
            request.setAttribute("successMsg", successMsg);
            session.removeAttribute("successMsg");
        }
        if (errorMsg != null) {
            request.setAttribute("errorMsg", errorMsg);
            session.removeAttribute("errorMsg");
        }

        request.setAttribute("assignedPositions", assignedPositions);
        request.setAttribute("positionsList", positionsList);
        request.setAttribute("posEmployeesMap", posEmployeesMap);

        request.getRequestDispatcher("/positions.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("role");
        if (role == null || !role.equalsIgnoreCase("Admin")) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/positions");
            return;
        }

        switch (action) {
            case "create":
                handleCreate(request, response);
                break;
            case "update":
                handleUpdate(request, response);
                break;
            case "delete":
                handleDelete(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/positions");
                break;
        }
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        String code = request.getParameter("code");
        String name = request.getParameter("name");
        String levelStr = request.getParameter("jobLevel");
        String shiftIdStr = request.getParameter("defaultShiftId");

        if (code == null || code.trim().isEmpty() || name == null || name.trim().isEmpty()) {
            session.setAttribute("errorMsg", "Vui lòng nhập đầy đủ Mã và Tên chức vụ!");
            response.sendRedirect(request.getContextPath() + "/positions");
            return;
        }

        String rawCode = request.getParameter("code");
        if (rawCode != null && rawCode.contains(" ")) {
            session.setAttribute("errorMsg", "Mã chức vụ phải viết liền, không được chứa khoảng trắng!");
            response.sendRedirect(request.getContextPath() + "/positions");
            return;
        }

        code = code.trim().toUpperCase();
        name = name.trim();

        if (positionService.isCodeExists(code, 0)) {
            session.setAttribute("errorMsg", "Mã chức vụ '" + code + "' đã tồn tại!");
            response.sendRedirect(request.getContextPath() + "/positions");
            return;
        }

        if (positionService.isNameExists(name, 0)) {
            session.setAttribute("errorMsg", "Tên chức vụ '" + name + "' đã tồn tại!");
            response.sendRedirect(request.getContextPath() + "/positions");
            return;
        }

        int jobLevel = 1;
        try {
            if (levelStr != null && !levelStr.trim().isEmpty()) {
                jobLevel = Integer.parseInt(levelStr.trim());
            }
        } catch (NumberFormatException ignored) {}

        Integer defaultShiftId = null;
        try {
            if (shiftIdStr != null && !shiftIdStr.trim().isEmpty()) {
                defaultShiftId = Integer.parseInt(shiftIdStr.trim());
            }
        } catch (NumberFormatException ignored) {}

        boolean ok = positionService.createPosition(code, name, jobLevel, defaultShiftId);
        if (ok) {
            session.setAttribute("successMsg", "Thêm mới chức vụ thành công!");
        } else {
            session.setAttribute("errorMsg", "Không thể thêm chức vụ, vui lòng thử lại!");
        }
        response.sendRedirect(request.getContextPath() + "/positions");
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        String idStr = request.getParameter("id");
        String name = request.getParameter("name");
        String levelStr = request.getParameter("jobLevel");
        String shiftIdStr = request.getParameter("defaultShiftId");

        int id = 0;
        try {
            id = Integer.parseInt(idStr);
        } catch (Exception e) {
            session.setAttribute("errorMsg", "Mã ID không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/positions");
            return;
        }

        if (name == null || name.trim().isEmpty()) {
            session.setAttribute("errorMsg", "Vui lòng nhập tên chức vụ!");
            response.sendRedirect(request.getContextPath() + "/positions");
            return;
        }

        name = name.trim();

        if (positionService.isNameExists(name, id)) {
            session.setAttribute("errorMsg", "Tên chức vụ '" + name + "' đã tồn tại!");
            response.sendRedirect(request.getContextPath() + "/positions");
            return;
        }

        int jobLevel = 1;
        try {
            if (levelStr != null && !levelStr.trim().isEmpty()) {
                jobLevel = Integer.parseInt(levelStr.trim());
            }
        } catch (NumberFormatException ignored) {}

        Integer defaultShiftId = null;
        try {
            if (shiftIdStr != null && !shiftIdStr.trim().isEmpty()) {
                defaultShiftId = Integer.parseInt(shiftIdStr.trim());
            }
        } catch (NumberFormatException ignored) {}

        boolean ok = positionService.updatePosition(id, name, jobLevel, defaultShiftId);
        if (ok) {
            session.setAttribute("successMsg", "Cập nhật chức vụ thành công!");
        } else {
            session.setAttribute("errorMsg", "Không thể cập nhật chức vụ!");
        }
        response.sendRedirect(request.getContextPath() + "/positions");
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        String idStr = request.getParameter("id");
        int id = 0;
        try {
            id = Integer.parseInt(idStr);
        } catch (Exception e) {
            session.setAttribute("errorMsg", "Mã ID không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/positions");
            return;
        }

        int count = positionService.countEmployees(id);
        if (count > 0) {
            session.setAttribute("errorMsg", "Không thể xóa! Đang có " + count + " nhân viên giữ chức vụ này.");
            response.sendRedirect(request.getContextPath() + "/positions");
            return;
        }

        boolean ok = positionService.deletePosition(id);
        if (ok) {
            session.setAttribute("successMsg", "Xóa chức vụ thành công!");
        } else {
            session.setAttribute("errorMsg", "Không thể xóa chức vụ này!");
        }
        response.sendRedirect(request.getContextPath() + "/positions");
    }
}
