package com.ems.controller;

import com.ems.dao.DepartmentDAO;
import com.ems.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;
import java.util.Map;

@WebServlet(name = "DepartmentServlet", urlPatterns = {"/departments"})
public class DepartmentServlet extends HttpServlet {

    private final DepartmentDAO departmentDAO = new DepartmentDAO();

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

        // Lấy thông tin Admin đang đăng nhập để hiển thị trên Topbar / Sidebar
        String username = (String) session.getAttribute("username");
        String adminFullName = "";
        String adminDeptName = "";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT u.FullName, d.Name as deptName FROM accounts a " +
                 "JOIN users u ON a.UserId = u.Id " +
                 "LEFT JOIN departments d ON u.DepartmentId = d.Id " +
                 "WHERE a.Username = ?")) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    adminFullName = rs.getString("FullName");
                    adminDeptName = rs.getString("deptName");
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        request.setAttribute("fullName", adminFullName);
        request.setAttribute("deptName", adminDeptName);

        // Lấy danh sách phòng ban và danh sách nhân sự ứng viên làm Trưởng phòng
        List<Map<String, Object>> departmentsList = departmentDAO.getAllDepartmentsWithStats();
        List<Map<String, Object>> headCandidatesList = departmentDAO.getActiveEmployeesForHead();
        Map<Integer, List<Map<String, Object>>> deptEmployeesMap = departmentDAO.getAllEmployeesGroupedByDepartment();

        int totalDepts = departmentsList != null ? departmentsList.size() : 0;
        int assignedHeadCount = 0;
        if (departmentsList != null) {
            for (Map<String, Object> d : departmentsList) {
                if (d.get("headAccountId") != null) {
                    assignedHeadCount++;
                }
            }
        }

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

                    code = code.trim().toUpperCase();
                    name = name.trim();

                    if (departmentDAO.isCodeExists(code, null)) {
                        session.setAttribute("errorMsg", "Mã phòng ban '" + code + "' đã tồn tại trong hệ thống!");
                        break;
                    }

                    if (departmentDAO.isNameExists(name, null)) {
                        session.setAttribute("errorMsg", "Tên phòng ban '" + name + "' đã tồn tại trong hệ thống!");
                        break;
                    }

                    Integer headAccountId = null;
                    if (headStr != null && !headStr.trim().isEmpty()) {
                        headAccountId = Integer.parseInt(headStr);
                    }

                    boolean ok = departmentDAO.addDepartment(code, name, headAccountId);
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

                    if (departmentDAO.isNameExists(name, id)) {
                        session.setAttribute("errorMsg", "Tên phòng ban '" + name + "' đã tồn tại trong hệ thống!");
                        break;
                    }

                    Integer headAccountId = null;
                    if (headStr != null && !headStr.trim().isEmpty()) {
                        headAccountId = Integer.parseInt(headStr);
                    }

                    boolean ok = departmentDAO.updateDepartment(id, name, headAccountId);
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
                        int count = departmentDAO.countEmployees(id);
                        if (count > 0) {
                            session.setAttribute("errorMsg", "Không thể xóa! Phòng ban này hiện đang có " + count + " nhân sự làm việc.");
                        } else {
                            boolean ok = departmentDAO.deleteDepartment(id);
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
