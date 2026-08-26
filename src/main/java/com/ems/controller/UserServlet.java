package com.ems.controller;

import com.ems.service.UserManageService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/users")
public class UserServlet extends HttpServlet {

    private final UserManageService userService = new UserManageService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String loggedInUserRole = (String) session.getAttribute("role");
        if (!"Admin".equalsIgnoreCase(loggedInUserRole)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập chức năng này.");
            return;
        }

        // Fetch User list & stats via Service
        List<Map<String, Object>> usersList = userService.getAllUsers();
        Map<String, Integer> stats = userService.getAccountStats(usersList);
        int totalCount = stats.getOrDefault("total", 0);
        int activeCount = stats.getOrDefault("active", 0);
        int lockedCount = stats.getOrDefault("locked", 0);

        // Fetch list of roles, departments, positions via Service
        List<String> rolesList = userService.getAllRoles();
        List<Map<String, Object>> deptsList = userService.getDepartments();
        List<Map<String, Object>> positionsList = userService.getPositions();
        List<Map<String, Object>> employeesWithoutAccount = userService.getEmployeesWithoutAccount();

        // Fetch header info of logged in Admin
        String username = (String) session.getAttribute("username");
        Map<String, String> adminInfo = userService.getAdminHeaderInfo(username);

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

        request.setAttribute("usersList", usersList);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("activeCount", activeCount);
        request.setAttribute("lockedCount", lockedCount);
        request.setAttribute("rolesList", rolesList);
        request.setAttribute("deptsList", deptsList);
        request.setAttribute("positionsList", positionsList);
        request.setAttribute("employeesWithoutAccount", employeesWithoutAccount);
        request.setAttribute("adminUsername", username);
        request.setAttribute("fullName", adminInfo.get("fullName"));
        request.setAttribute("deptName", adminInfo.get("deptName"));

        request.getRequestDispatcher("/users.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String loggedInUserRole = (String) session.getAttribute("role");
        if (!"Admin".equalsIgnoreCase(loggedInUserRole)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập chức năng này.");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("toggleStatus".equalsIgnoreCase(action)) {
            try {
                int accountId = Integer.parseInt(request.getParameter("accountId"));
                boolean currentStatus = Boolean.parseBoolean(request.getParameter("currentStatus"));
                userService.toggleAccountStatus(accountId, currentStatus);
                session.setAttribute("successMessage", "Cập nhật trạng thái tài khoản thành công!");
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Lỗi khi cập nhật trạng thái tài khoản!");
            }
        } else if ("updateRole".equalsIgnoreCase(action)) {
            try {
                int accountId = Integer.parseInt(request.getParameter("accountId"));
                String roleName = request.getParameter("roleName");
                userService.updateAccountRole(accountId, roleName);
                session.setAttribute("successMessage", "Cập nhật vai trò thành công!");
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Lỗi khi cập nhật vai trò!");
            }
        } else if ("create".equalsIgnoreCase(action)) {
            try {
                String userIdStr = request.getParameter("userId");
                String username = request.getParameter("username");
                String password = request.getParameter("password");
                String role = request.getParameter("role");

                username = username != null ? username.trim() : "";
                String rawUsername = request.getParameter("username");

                if (!"Manager".equalsIgnoreCase(role) && !"Employee".equalsIgnoreCase(role)) {
                    role = "Employee";
                }

                String error = null;
                if (userIdStr == null || userIdStr.trim().isEmpty()) {
                    error = "Vui lòng chọn nhân viên cần cấp tài khoản!";
                } else if (username.isEmpty() || password == null || password.isEmpty()) {
                    error = "Vui lòng điền đầy đủ Tên tài khoản và Mật khẩu!";
                } else if (rawUsername != null && rawUsername.contains(" ")) {
                    error = "Tên tài khoản phải viết liền, không được chứa khoảng trắng!";
                } else if (username.length() < 3) {
                    error = "Tên tài khoản phải có ít nhất 3 ký tự!";
                } else if (password.length() < 6) {
                    error = "Mật khẩu phải có ít nhất 6 ký tự!";
                } else if (userService.isUsernameExists(username)) {
                    error = "Tên tài khoản (Username) '" + username + "' đã tồn tại! Vui lòng chọn tên khác.";
                }

                if (error != null) {
                    session.setAttribute("errorMessage", error);
                    response.sendRedirect(request.getContextPath() + "/users");
                    return;
                }

                int userId = Integer.parseInt(userIdStr.trim());
                boolean success = userService.createAccountForEmployee(userId, username, password, role);
                if (success) {
                    session.setAttribute("successMessage", "Cấp tài khoản đăng nhập thành công!");
                } else {
                    session.setAttribute("errorMessage", "Không thể cấp tài khoản, vui lòng thử lại!");
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Đã xảy ra lỗi khi tạo tài khoản!");
            }
        } else if ("update".equalsIgnoreCase(action)) {
            try {
                int accountId = Integer.parseInt(request.getParameter("accountId"));
                String fullName = request.getParameter("fullName");
                String email = request.getParameter("email");
                String role = request.getParameter("role");

                fullName = fullName != null ? fullName.trim() : "";
                email = email != null ? email.trim() : "";

                String rawEmail = request.getParameter("email");

                // Validate
                String error = null;
                if (fullName.isEmpty() || email.isEmpty()) {
                    error = "Vui lòng điền đầy đủ họ và tên và email!";
                } else if (!fullName.matches("^[a-zA-ZÀ-ỹ\\s]+$")) {
                    error = "Họ và tên chỉ được chứa chữ cái và khoảng trắng!";
                } else if (rawEmail != null && rawEmail.contains(" ")) {
                    error = "Email phải viết liền, không được chứa khoảng trắng!";
                } else if (!email.toLowerCase().endsWith("@techcorp.vn") || !email.matches("^[a-zA-Z0-9._%+-]+@techcorp\\.vn$")) {
                    error = "Email công ty phải có định dạng @techcorp.vn (ví dụ: nhanvien@techcorp.vn)!";
                } else if (userService.isEmailExistsForOther(email, accountId)) {
                    error = "Email công ty '" + email + "' đã được sử dụng bởi tài khoản khác!";
                }

                if (error != null) {
                    session.setAttribute("errorMessage", error);
                    response.sendRedirect(request.getContextPath() + "/users");
                    return;
                }

                boolean success = userService.updateAccountBasic(accountId, fullName, email, role);
                if (success) {
                    session.setAttribute("successMessage", "Lưu thay đổi tài khoản thành công!");
                } else {
                    session.setAttribute("errorMessage", "Không thể cập nhật tài khoản!");
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Đã xảy ra lỗi khi cập nhật tài khoản!");
            }
        }

        response.sendRedirect(request.getContextPath() + "/users");
    }
}