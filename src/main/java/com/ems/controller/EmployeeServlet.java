package com.ems.controller;

import com.ems.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/employees")
public class EmployeeServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

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

        // Lấy danh sách nhân viên đầy đủ
        List<Map<String, Object>> employeeList = userDAO.getAllEmployees();

        // Thống kê
        int totalEmp = employeeList.size();
        int activeEmp = 0;
        for (Map<String, Object> e : employeeList) {
            Boolean status = (Boolean) e.get("userStatus");
            if (status != null && status) activeEmp++;
        }

        // Lấy thông tin Admin đang đăng nhập
        String username = (String) session.getAttribute("username");
        String adminFullName = "";
        String adminDeptName = "";
        try (java.sql.Connection conn = com.ems.util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(
                 "SELECT u.FullName, d.Name as deptName FROM accounts a " +
                 "JOIN users u ON a.UserId = u.Id " +
                 "LEFT JOIN departments d ON u.DepartmentId = d.Id " +
                 "WHERE a.Username = ?")) {
            ps.setString(1, username);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    adminFullName = rs.getString("FullName");
                    adminDeptName = rs.getString("deptName");
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        // Lấy danh sách phòng ban để lọc
        List<Map<String, Object>> deptsList = userDAO.getDepartments();
        // Lấy danh sách chức vụ để sửa
        List<Map<String, Object>> positionsList = userDAO.getPositions();

        // Flash messages
        String successMsg = (String) session.getAttribute("successMessage");
        String errorMsg = (String) session.getAttribute("errorMessage");
        if (successMsg != null) {
            request.setAttribute("successMessage", successMsg);
            session.removeAttribute("successMessage");
        }
        if (errorMsg != null) {
            request.setAttribute("errorMessage", errorMsg);
            session.removeAttribute("errorMessage");
        }

        request.setAttribute("employeeList", employeeList);
        request.setAttribute("totalEmp", totalEmp);
        request.setAttribute("activeEmp", activeEmp);
        request.setAttribute("deptsList", deptsList);
        request.setAttribute("positionsList", positionsList);
        request.setAttribute("fullName", adminFullName);
        request.setAttribute("deptName", adminDeptName);

        request.getRequestDispatcher("/employees.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("update".equals(action)) {
            try {
                int userId       = Integer.parseInt(request.getParameter("userId"));
                String fullName  = request.getParameter("fullName");
                String email     = request.getParameter("email");
                String phone     = request.getParameter("phone");

                fullName = fullName != null ? fullName.trim() : "";
                email = email != null ? email.trim() : "";
                phone = phone != null ? phone.trim() : "";

                // Validate
                String error = null;
                if (fullName.isEmpty() || email.isEmpty()) {
                    error = "Vui lòng điền đầy đủ họ và tên và email!";
                } else if (userDAO.isEmailExistsForOtherUserId(email, userId)) {
                    error = "Email công ty '" + email + "' đã được sử dụng bởi nhân viên khác!";
                } else if (!phone.isEmpty() && userDAO.isPhoneExistsForOtherUserId(phone, userId)) {
                    error = "Số điện thoại '" + phone + "' đã được sử dụng bởi nhân viên khác!";
                }

                if (error != null) {
                    session.setAttribute("errorMessage", error);
                    response.sendRedirect(request.getContextPath() + "/employees");
                    return;
                }
                
                Boolean genderVal = null;
                String genderParam = request.getParameter("gender");
                if (genderParam != null && !genderParam.trim().isEmpty()) {
                    genderVal = Boolean.parseBoolean(genderParam);
                }

                java.sql.Date dobDate = null;
                String dobParam = request.getParameter("dob");
                if (dobParam != null && !dobParam.trim().isEmpty()) {
                    dobParam = dobParam.trim();
                    try {
                        if (dobParam.contains("/")) {
                            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                            java.util.Date parsed = sdf.parse(dobParam);
                            dobDate = new java.sql.Date(parsed.getTime());
                        } else if (dobParam.contains("-")) {
                            dobDate = java.sql.Date.valueOf(dobParam);
                        }
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }

                int departmentId = Integer.parseInt(request.getParameter("departmentId"));
                int positionId   = Integer.parseInt(request.getParameter("positionId"));

                boolean success = userDAO.updateEmployeeInfo(userId, fullName, email, phone, genderVal, dobDate, departmentId, positionId);
                if (success) {
                    session.setAttribute("successMessage", "Cập nhật thông tin nhân viên thành công!");
                } else {
                    session.setAttribute("errorMessage", "Không thể cập nhật thông tin nhân viên!");
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Đã xảy ra lỗi khi cập nhật nhân viên!");
            }

        } else if ("toggleStatus".equals(action)) {
            try {
                int userId         = Integer.parseInt(request.getParameter("userId"));
                boolean currStatus = Boolean.parseBoolean(request.getParameter("currentStatus"));
                userDAO.updateEmployeeStatus(userId, !currStatus);
                session.setAttribute("successMessage", "Cập nhật trạng thái nhân viên thành công!");
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Lỗi khi cập nhật trạng thái!");
            }
        }

        response.sendRedirect(request.getContextPath() + "/employees");
    }
}
