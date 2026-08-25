package com.ems.controller;

import com.ems.service.DepartmentManageService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "DepartmentServlet", urlPatterns = {"/departments"})
public class DepartmentServlet extends HttpServlet {

    private final DepartmentManageService departmentService = new DepartmentManageService();

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
        if (!"Admin".equalsIgnoreCase(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập chức năng này.");
            return;
        }

        // Lấy thông tin Admin đang đăng nhập via Service
        String username = (String) session.getAttribute("username");
        Map<String, String> adminInfo = departmentService.getAdminHeaderInfo(username);

        request.setAttribute("fullName", adminInfo.get("fullName"));
        request.setAttribute("deptName", adminInfo.get("deptName"));

        // Lấy danh sách phòng ban và danh sách nhân sự ứng viên làm Trưởng phòng via Service
        List<Map<String, Object>> departmentsList = departmentService.getAllDepartmentsWithStats();
        List<Map<String, Object>> headCandidatesList = departmentService.getActiveEmployeesForHead();
        Map<Integer, List<Map<String, Object>>> deptEmployeesMap = departmentService.getAllEmployeesGroupedByDepartment();

        Map<String, Integer> stats = departmentService.getDepartmentStats(departmentsList);
        int totalDepts = stats.getOrDefault("total", 0);
        int assignedHeadCount = stats.getOrDefault("withHead", 0);

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

        request.setAttribute("totalDepts", totalDepts);
        request.setAttribute("assignedHeadCount", assignedHeadCount);
        request.setAttribute("departmentsList", departmentsList);
        request.setAttribute("headCandidatesList", headCandidatesList);
        request.setAttribute("deptEmployeesMap", deptEmployeesMap);

        request.getRequestDispatcher("/departments.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("role");
        if (!"Admin".equalsIgnoreCase(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thực hiện thao tác này.");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "";
        }

        try {
            switch (action) {
                case "create": {
                    String code = request.getParameter("code");
                    String name = request.getParameter("name");
                    String headStr = request.getParameter("headAccountId");

                    if (code == null || code.trim().isEmpty() || name == null || name.trim().isEmpty()) {
                        session.setAttribute("errorMsg", "Vui lòng nhập đầy đủ Mã và Tên phòng ban!");
                        break;
                    }

                    String rawCode = request.getParameter("code");
                    if (rawCode != null && rawCode.contains(" ")) {
                        session.setAttribute("errorMsg", "Mã phòng ban phải viết liền, không được chứa khoảng trắng!");
                        break;
                    }

                    code = code.trim().toUpperCase();
                    name = name.trim();

                    if (departmentService.isCodeExists(code, null)) {
                        session.setAttribute("errorMsg", "Mã phòng ban '" + code + "' đã tồn tại trong hệ thống!");
                        break;
                    }

                    if (departmentService.isNameExists(name, null)) {
                        session.setAttribute("errorMsg", "Tên phòng ban '" + name + "' đã tồn tại trong hệ thống!");
                        break;
                    }

                    Integer headAccountId = null;
                    if (headStr != null && !headStr.trim().isEmpty()) {
                        headAccountId = Integer.parseInt(headStr);
                    }

                    boolean ok = departmentService.createDepartment(code, name, headAccountId);
                    if (ok) {
                        session.setAttribute("successMsg", "Thêm mới phòng ban thành công!");
                    } else {
                        session.setAttribute("errorMsg", "Thêm phòng ban thất bại. Vui lòng thử lại!");
                    }
                    break;
                }

                case "update": {
                    String idStr = request.getParameter("id");
                    String name = request.getParameter("name");
                    String headStr = request.getParameter("headAccountId");

                    if (idStr == null || name == null || name.trim().isEmpty()) {
                        session.setAttribute("errorMsg", "Vui lòng nhập tên phòng ban!");
                        break;
                    }

                    int id = Integer.parseInt(idStr);
                    name = name.trim();

                    if (departmentService.isNameExists(name, id)) {
                        session.setAttribute("errorMsg", "Tên phòng ban '" + name + "' đã tồn tại trong hệ thống!");
                        break;
                    }

                    Integer headAccountId = null;
                    if (headStr != null && !headStr.trim().isEmpty()) {
                        headAccountId = Integer.parseInt(headStr);
                    }

                    boolean ok = departmentService.updateDepartment(id, name, headAccountId);
                    if (ok) {
                        session.setAttribute("successMsg", "Cập nhật thông tin phòng ban thành công!");
                    } else {
                        session.setAttribute("errorMsg", "Cập nhật phòng ban thất bại!");
                    }
                    break;
                }

                case "delete": {
                    String idStr = request.getParameter("id");
                    if (idStr != null && !idStr.trim().isEmpty()) {
                        int id = Integer.parseInt(idStr);
                        int count = departmentService.countEmployees(id);
                        if (count > 0) {
                            session.setAttribute("errorMsg", "Không thể xóa! Phòng ban này hiện đang có " + count + " nhân sự làm việc.");
                        } else {
                            boolean ok = departmentService.deleteDepartment(id);
                            if (ok) {
                                session.setAttribute("successMsg", "Đã xóa phòng ban thành công!");
                            } else {
                                session.setAttribute("errorMsg", "Xóa phòng ban thất bại!");
                            }
                        }
                    }
                    break;
                }

                default:
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Đã xảy ra lỗi: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/departments");
    }
}
