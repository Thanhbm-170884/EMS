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

        if ("create".equals(action)) {
            try {
                String fullName = request.getParameter("fullName");
                String email = request.getParameter("email");
                String phone = request.getParameter("phone");
                String genderStr = request.getParameter("gender");
                String dobStr = request.getParameter("dob");
                String deptStr = request.getParameter("departmentId");
                String posStr = request.getParameter("positionId");
                String dependentsStr = request.getParameter("dependentsCount");
                String salaryStr = request.getParameter("baseSalary");

                fullName = fullName != null ? fullName.trim() : "";
                email = email != null ? email.trim() : "";
                phone = phone != null ? phone.trim() : "";

                String rawEmail = request.getParameter("email");
                String rawPhone = request.getParameter("phone");

                String error = null;
                if (fullName.isEmpty() || email.isEmpty() || phone.isEmpty() || dobStr == null || dobStr.trim().isEmpty() || deptStr == null || posStr == null) {
                    error = "Vui lòng điền đầy đủ các thông tin bắt buộc (*)!";
                } else if (!fullName.matches("^[a-zA-ZÀ-ỹ\\s]+$")) {
                    error = "Họ và tên chỉ được chứa chữ cái và khoảng trắng!";
                } else if (rawEmail != null && rawEmail.contains(" ")) {
                    error = "Email phải viết liền, không được chứa khoảng trắng!";
                } else if (!email.toLowerCase().endsWith("@techcorp.vn") || !email.matches("^[a-zA-Z0-9._%+-]+@techcorp\\.vn$")) {
                    error = "Email công ty phải có định dạng @techcorp.vn (ví dụ: nhanvien@techcorp.vn)!";
                } else if (rawPhone != null && rawPhone.contains(" ")) {
                    error = "Số điện thoại phải viết liền, không được chứa khoảng trắng!";
                } else if (!phone.matches("^0[0-9]{9}$")) {
                    error = "Số điện thoại phải gồm đúng 10 chữ số và bắt đầu bằng số 0 (ví dụ: 0912345678)!";
                } else if (userDAO.isEmailExists(email)) {
                    error = "Email công ty '" + email + "' đã tồn tại trong hệ thống!";
                } else if (userDAO.isPhoneExists(phone)) {
                    error = "Số điện thoại '" + phone + "' đã tồn tại trong hệ thống!";
                }

                java.sql.Date dob = null;
                if (error == null) {
                    try {
                        java.time.LocalDate birthDate;
                        if (dobStr.contains("/")) {
                            java.time.format.DateTimeFormatter dtf = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy");
                            birthDate = java.time.LocalDate.parse(dobStr.trim(), dtf);
                        } else {
                            birthDate = java.time.LocalDate.parse(dobStr.trim());
                        }
                        dob = java.sql.Date.valueOf(birthDate);
                        java.time.LocalDate now = java.time.LocalDate.now();
                        if (birthDate.isAfter(now)) {
                            error = "Ngày sinh không được là ngày trong tương lai!";
                        } else if (java.time.Period.between(birthDate, now).getYears() < 18) {
                            error = "Nhân viên phải từ đủ 18 tuổi trở lên!";
                        }
                    } catch (Exception ex) {
                        error = "Định dạng ngày sinh không hợp lệ (dd/mm/yyyy)!";
                    }
                }

                if (error != null) {
                    session.setAttribute("errorMessage", error);
                    response.sendRedirect(request.getContextPath() + "/employees");
                    return;
                }

                Boolean gender = "true".equalsIgnoreCase(genderStr) || "1".equals(genderStr);
                int departmentId = Integer.parseInt(deptStr);
                int positionId = Integer.parseInt(posStr);
                int dependentsCount = 0;
                if (dependentsStr != null && !dependentsStr.trim().isEmpty()) {
                    try {
                        dependentsCount = Integer.parseInt(dependentsStr.trim());
                    } catch (NumberFormatException ignored) {}
                }

                java.math.BigDecimal baseSalary = new java.math.BigDecimal("5000000");
                if (salaryStr != null && !salaryStr.trim().isEmpty()) {
                    try {
                        baseSalary = new java.math.BigDecimal(salaryStr.trim().replace(",", ""));
                    } catch (Exception ignored) {}
                }

                boolean success = userDAO.createEmployee(fullName, email, phone, gender, dob, departmentId, positionId, dependentsCount, baseSalary);
                if (success) {
                    session.setAttribute("successMessage", "Thêm mới nhân viên thành công!");
                } else {
                    session.setAttribute("errorMessage", "Không thể thêm nhân viên, vui lòng thử lại!");
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Đã xảy ra lỗi khi thêm mới nhân viên!");
            }

        } else if ("update".equals(action)) {
            try {
                int userId       = Integer.parseInt(request.getParameter("userId"));
                String fullName  = request.getParameter("fullName");
                String email     = request.getParameter("email");
                String phone     = request.getParameter("phone");
                String genderStr = request.getParameter("gender");
                String dobStr    = request.getParameter("dob");
                String deptStr   = request.getParameter("departmentId");
                String posStr    = request.getParameter("positionId");
                String dependentsStr = request.getParameter("dependentsCount");
                String salaryStr = request.getParameter("baseSalary");

                fullName = fullName != null ? fullName.trim() : "";
                email = email != null ? email.trim() : "";
                phone = phone != null ? phone.trim() : "";

                String rawEmail = request.getParameter("email");
                String rawPhone = request.getParameter("phone");

                // Validate
                String error = null;
                if (fullName.isEmpty() || email.isEmpty() || phone.isEmpty() || dobStr == null || dobStr.trim().isEmpty() || deptStr == null || posStr == null) {
                    error = "Vui lòng điền đầy đủ các thông tin bắt buộc (*)!";
                } else if (!fullName.matches("^[a-zA-ZÀ-ỹ\\s]+$")) {
                    error = "Họ và tên chỉ được chứa chữ cái và khoảng trắng!";
                } else if (rawEmail != null && rawEmail.contains(" ")) {
                    error = "Email phải viết liền, không được chứa khoảng trắng!";
                } else if (!email.toLowerCase().endsWith("@techcorp.vn") || !email.matches("^[a-zA-Z0-9._%+-]+@techcorp\\.vn$")) {
                    error = "Email công ty phải có định dạng @techcorp.vn (ví dụ: nhanvien@techcorp.vn)!";
                } else if (rawPhone != null && rawPhone.contains(" ")) {
                    error = "Số điện thoại phải viết liền, không được chứa khoảng trắng!";
                } else if (!phone.matches("^0[0-9]{9}$")) {
                    error = "Số điện thoại phải gồm đúng 10 chữ số và bắt đầu bằng số 0 (ví dụ: 0912345678)!";
                } else if (userDAO.isEmailExistsForOtherUserId(email, userId)) {
                    error = "Email công ty '" + email + "' đã được sử dụng bởi nhân viên khác!";
                } else if (userDAO.isPhoneExistsForOtherUserId(phone, userId)) {
                    error = "Số điện thoại '" + phone + "' đã được sử dụng bởi nhân viên khác!";
                }

                java.sql.Date dob = null;
                if (error == null) {
                    try {
                        java.time.LocalDate birthDate;
                        if (dobStr.contains("/")) {
                            java.time.format.DateTimeFormatter dtf = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy");
                            birthDate = java.time.LocalDate.parse(dobStr.trim(), dtf);
                        } else {
                            birthDate = java.time.LocalDate.parse(dobStr.trim());
                        }
                        java.time.LocalDate today = java.time.LocalDate.now();
                        if (birthDate.isAfter(today)) {
                            error = "Ngày sinh không hợp lệ!";
                        } else {
                            int age = java.time.Period.between(birthDate, today).getYears();
                            if (age < 18) {
                                error = "Nhân viên phải từ đủ 18 tuổi trở lên!";
                            } else {
                                dob = java.sql.Date.valueOf(birthDate);
                            }
                        }
                    } catch (Exception ex) {
                        error = "Định dạng ngày sinh không hợp lệ (dd/mm/yyyy)!";
                    }
                }

                if (error != null) {
                    session.setAttribute("errorMessage", error);
                    response.sendRedirect(request.getContextPath() + "/employees");
                    return;
                }

                Boolean gender = null;
                if ("true".equalsIgnoreCase(genderStr) || "1".equals(genderStr)) {
                    gender = true;
                } else if ("false".equalsIgnoreCase(genderStr) || "0".equals(genderStr)) {
                    gender = false;
                }

                int departmentId = Integer.parseInt(deptStr);
                int positionId   = Integer.parseInt(posStr);
                int dependentsCount = 0;
                if (dependentsStr != null && !dependentsStr.trim().isEmpty()) {
                    try {
                        dependentsCount = Integer.parseInt(dependentsStr.trim());
                    } catch (NumberFormatException ignored) {}
                }

                java.math.BigDecimal baseSalary = new java.math.BigDecimal("5000000");
                if (salaryStr != null && !salaryStr.trim().isEmpty()) {
                    try {
                        baseSalary = new java.math.BigDecimal(salaryStr.trim().replace(",", ""));
                    } catch (Exception ignored) {}
                }

                boolean success = userDAO.updateEmployeeFull(userId, fullName, email, phone, gender, dob, departmentId, positionId, dependentsCount, baseSalary);
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
