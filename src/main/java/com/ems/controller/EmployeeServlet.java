package com.ems.controller;

import com.ems.service.EmployeeManageService;
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

    private final EmployeeManageService employeeService = new EmployeeManageService();

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

        // Lấy danh sách nhân viên đầy đủ via Service
        List<Map<String, Object>> employeeList = employeeService.getAllEmployees();

        // Thống kê via Service
        Map<String, Integer> stats = employeeService.getEmployeeStats(employeeList);
        int totalEmp = stats.getOrDefault("total", 0);
        int activeEmp = stats.getOrDefault("active", 0);

        // Lấy thông tin Admin đang đăng nhập via Service
        String username = (String) session.getAttribute("username");
        Map<String, String> adminInfo = employeeService.getAdminHeaderInfo(username);

        // Lấy danh sách phòng ban và chức vụ via Service
        List<Map<String, Object>> deptsList = employeeService.getDepartments();
        List<Map<String, Object>> positionsList = employeeService.getPositions();

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
        request.setAttribute("fullName", adminInfo.get("fullName"));
        request.setAttribute("deptName", adminInfo.get("deptName"));

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
                } else if (fullName.contains("  ")) {
                        error = "Họ và tên không được chứa khoảng trắng liên tiếp!";
                } else if (!email.toLowerCase().endsWith("@hrms.vn") || !email.matches("^[a-zA-Z0-9._%+-]+@hrms\\.vn$")) {
                    error = "Email công ty phải có định dạng @hrms.vn (ví dụ: nhanvien@hrms.vn)!";
                } else if (rawPhone != null && rawPhone.contains(" ")) {
                    error = "Số điện thoại phải viết liền, không được chứa khoảng trắng!";
                } else if (!phone.matches("^0[0-9]{9}$")) {
                    error = "Số điện thoại không hợp lệ (Phải là 10 chữ số, bắt đầu bằng 0)!";
                } else if (employeeService.isEmailExists(email)) {
                    error = "Email công ty '" + email + "' đã tồn tại trong hệ thống!";
                } else if (employeeService.isPhoneExists(phone)) {
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
                        String cleanSalary = salaryStr.trim().replaceAll("[^0-9]", "");
                        if (!cleanSalary.isEmpty()) {
                            baseSalary = new java.math.BigDecimal(cleanSalary);
                        }
                    } catch (Exception ignored) {}
                }

                boolean success = employeeService.createEmployee(fullName, email, phone, gender, dob, departmentId, positionId, dependentsCount, baseSalary);
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
                } else if (!email.toLowerCase().endsWith("@hrms.vn") || !email.matches("^[a-zA-Z0-9._%+-]+@hrms\\.vn$")) {
                    error = "Email công ty phải có định dạng @hrms.vn (ví dụ: nhanvien@hrms.vn)!";
                } else if (rawPhone != null && rawPhone.contains(" ")) {
                    error = "Số điện thoại phải viết liền, không được chứa khoảng trắng!";
                } else if (!phone.matches("^0[0-9]{9}$")) {
                    error = "Số điện thoại phải gồm đúng 10 chữ số và bắt đầu bằng số 0 (ví dụ: 0912345678)!";
                } else if (employeeService.isEmailExistsForOtherUserId(email, userId)) {
                    error = "Email công ty '" + email + "' đã được sử dụng bởi nhân viên khác!";
                } else if (employeeService.isPhoneExistsForOtherUserId(phone, userId)) {
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
                        String cleanSalary = salaryStr.trim().replaceAll("[^0-9]", "");
                        if (!cleanSalary.isEmpty()) {
                            baseSalary = new java.math.BigDecimal(cleanSalary);
                        }
                    } catch (Exception ignored) {}
                }

                boolean success = employeeService.updateEmployee(userId, fullName, email, phone, gender, dob, departmentId, positionId, dependentsCount, baseSalary);
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
                employeeService.toggleEmployeeStatus(userId, currStatus);
                session.setAttribute("successMessage", "Cập nhật trạng thái nhân viên thành công!");
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Lỗi khi cập nhật trạng thái!");
            }
        }

        response.sendRedirect(request.getContextPath() + "/employees");
    }
}
