package com.ems.controller;

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
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "HomeServlet", urlPatterns = {"/home"})
public class HomeServlet extends HttpServlet {

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

        String username = (String) session.getAttribute("username");
        String role = (String) session.getAttribute("role");
        if (role == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        role = role.trim().toLowerCase();

        try (Connection conn = DBConnection.getConnection()) {
            
            // 1. Fetch common account & user data
            int accountId = -1;
            int userId = -1;
            String fullName = "";
            int departmentId = -1;
            String deptName = "";

            String userQuery = "SELECT a.Id as AccountId, u.Id as UserId, u.FullName, u.DepartmentId, d.Name as DeptName " +
                               "FROM accounts a " +
                               "JOIN users u ON a.UserId = u.Id " +
                               "LEFT JOIN departments d ON u.DepartmentId = d.Id " +
                               "WHERE a.Username = ?";
            try (PreparedStatement ps = conn.prepareStatement(userQuery)) {
                ps.setString(1, username);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        accountId = rs.getInt("AccountId");
                        userId = rs.getInt("UserId");
                        fullName = rs.getString("FullName");
                        departmentId = rs.getInt("DepartmentId");
                        deptName = rs.getString("DeptName");
                    }
                }
            }

            request.setAttribute("fullName", fullName);
            request.setAttribute("deptName", deptName);

            // 2. Fetch specific data based on role
            if (role.equals("employee") || role.equals("nhân viên")) {
                loadEmployeeData(conn, userId, accountId, request);
                request.setAttribute("isLoaded", true);
                request.getRequestDispatcher("/home.jsp").forward(request, response);
            } 
            else if (role.equals("manager") || role.equals("quản lý")) {
                loadManagerData(conn, userId, accountId, departmentId, request);
                request.setAttribute("isLoaded", true);
                request.getRequestDispatcher("/home_manager.jsp").forward(request, response);
            } 
            else if (role.equals("admin") || role.equals("quản trị viên")) {
                loadAdminData(conn, request);
                request.setAttribute("isLoaded", true);
                request.getRequestDispatcher("/home_admin.jsp").forward(request, response);
            } 
            else {
                // Fallback to employee home
                loadEmployeeData(conn, userId, accountId, request);
                request.setAttribute("isLoaded", true);
                request.getRequestDispatcher("/home.jsp").forward(request, response);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Lỗi kết nối cơ sở dữ liệu khi tải trang chủ", e);
        }
    }

    private void loadEmployeeData(Connection conn, int userId, int accountId, HttpServletRequest request) throws SQLException {
        // A. Leave balance (remaining leave days)
        int totalLeave = 12;
        int usedLeave = 0;
        int remainingLeave = 12;
        String leaveQuery = "SELECT TotalDays, UsedDays, RemainingDays FROM leavebalances WHERE UserId = ? AND Year = 2026";
        try (PreparedStatement ps = conn.prepareStatement(leaveQuery)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalLeave = rs.getInt("TotalDays");
                    usedLeave = rs.getInt("UsedDays");
                    remainingLeave = rs.getInt("RemainingDays");
                }
            }
        }
        request.setAttribute("totalLeave", totalLeave);
        request.setAttribute("usedLeave", usedLeave);
        request.setAttribute("remainingLeave", remainingLeave);

        // B. Active timesheet period & actual working days count
        int periodId = -1;
        String periodName = "N/A";
        int actualWorkingDays = 0;
        
        // Find latest/active timesheet period
        String periodQuery = "SELECT Id, Name FROM timesheetperiods ORDER BY StartDate DESC LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(periodQuery);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                periodId = rs.getInt("Id");
                periodName = rs.getString("Name");
            }
        }
        
        if (periodId != -1) {
            String attCountQuery = "SELECT COUNT(*) as cnt FROM attendance WHERE EmployeeId = ? AND PeriodId = ? AND CheckInTime IS NOT NULL";
            try (PreparedStatement ps = conn.prepareStatement(attCountQuery)) {
                ps.setInt(1, userId);
                ps.setInt(2, periodId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        actualWorkingDays = rs.getInt("cnt");
                    }
                }
            }
        }
        request.setAttribute("periodName", periodName);
        request.setAttribute("actualWorkingDays", actualWorkingDays);

        // C. Today's attendance status
        String todayCheckIn = null;
        String todayCheckOut = null;
        String todayQuery = "SELECT CheckInTime, CheckOutTime FROM attendance WHERE EmployeeId = ? AND AttendanceDate = CURDATE()";
        try (PreparedStatement ps = conn.prepareStatement(todayQuery)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    todayCheckIn = rs.getString("CheckInTime");
                    todayCheckOut = rs.getString("CheckOutTime");
                }
            }
        }
        request.setAttribute("todayCheckIn", todayCheckIn != null ? todayCheckIn.substring(0, 5) : null);
        request.setAttribute("todayCheckOut", todayCheckOut != null ? todayCheckOut.substring(0, 5) : null);

        // D. Recent requests
        List<Map<String, Object>> requestsList = new ArrayList<>();
        String reqQuery = "SELECT r.Title, r.Reason, r.Status, r.StartDate, r.EndDate, r.Value FROM requests r " +
                          "WHERE r.CreatedByAccountId = ? ORDER BY r.CreatedAt DESC LIMIT 5";
        try (PreparedStatement ps = conn.prepareStatement(reqQuery)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> req = new HashMap<>();
                    req.put("title", rs.getString("Title"));
                    req.put("reason", rs.getString("Reason"));
                    req.put("status", rs.getString("Status"));
                    req.put("startDate", rs.getDate("StartDate"));
                    req.put("endDate", rs.getDate("EndDate"));
                    req.put("value", rs.getDouble("Value"));
                    requestsList.add(req);
                }
            }
        }
        request.setAttribute("requestsList", requestsList);

        // E. Notifications
        List<Map<String, Object>> notificationsList = new ArrayList<>();
        String notiQuery = "SELECT Title, Message, CreatedAt, IsRead FROM notifications WHERE UserId = ? ORDER BY CreatedAt DESC LIMIT 5";
        try (PreparedStatement ps = conn.prepareStatement(notiQuery)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> noti = new HashMap<>();
                    noti.put("title", rs.getString("Title"));
                    noti.put("message", rs.getString("Message"));
                    noti.put("createdAt", rs.getTimestamp("CreatedAt"));
                    noti.put("isRead", rs.getBoolean("IsRead"));
                    notificationsList.add(noti);
                }
            }
        }
        request.setAttribute("notificationsList", notificationsList);
    }

    private void loadManagerData(Connection conn, int userId, int accountId, int departmentId, HttpServletRequest request) throws SQLException {
        // A. Total employee count in department
        int deptEmployeeCount = 0;
        String deptCountQuery = "SELECT COUNT(*) as cnt FROM users WHERE DepartmentId = ?";
        try (PreparedStatement ps = conn.prepareStatement(deptCountQuery)) {
            ps.setInt(1, departmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    deptEmployeeCount = rs.getInt("cnt");
                }
            }
        }
        request.setAttribute("deptEmployeeCount", deptEmployeeCount);

        // B. Pending requests for the manager to approve
        List<Map<String, Object>> pendingRequests = new ArrayList<>();
        String pendingQuery = "SELECT r.Id, r.Title, r.Reason, r.Status, r.StartDate, r.EndDate, r.Value, u.FullName " +
                              "FROM requests r " +
                              "JOIN accounts a ON r.CreatedByAccountId = a.Id " +
                              "JOIN users u ON a.UserId = u.Id " +
                              "WHERE r.Status = 'Pending' " +
                              "ORDER BY r.CreatedAt DESC";
        try (PreparedStatement ps = conn.prepareStatement(pendingQuery)) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> req = new HashMap<>();
                    req.put("id", rs.getInt("Id"));
                    req.put("title", rs.getString("Title"));
                    req.put("reason", rs.getString("Reason"));
                    req.put("startDate", rs.getDate("StartDate"));
                    req.put("endDate", rs.getDate("EndDate"));
                    req.put("value", rs.getDouble("Value"));
                    req.put("fullName", rs.getString("FullName"));
                    pendingRequests.add(req);
                }
            }
        }
        request.setAttribute("pendingRequests", pendingRequests);
        request.setAttribute("pendingCount", pendingRequests.size());

        // C. Today's attendance list in the department
        List<Map<String, Object>> departmentAttendance = new ArrayList<>();
        String attQuery = "SELECT u.FullName, a.CheckInTime, a.CheckOutTime " +
                          "FROM users u " +
                          "LEFT JOIN attendance a ON u.Id = a.EmployeeId AND a.AttendanceDate = CURDATE() " +
                          "WHERE u.DepartmentId = ? AND u.Id != ? " +
                          "ORDER BY u.FullName ASC";
        try (PreparedStatement ps = conn.prepareStatement(attQuery)) {
            ps.setInt(1, departmentId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> att = new HashMap<>();
                    att.put("fullName", rs.getString("FullName"));
                    
                    String inTime = rs.getString("CheckInTime");
                    String outTime = rs.getString("CheckOutTime");
                    
                    att.put("checkIn", inTime != null ? inTime.substring(0, 5) : null);
                    att.put("checkOut", outTime != null ? outTime.substring(0, 5) : null);
                    departmentAttendance.add(att);
                }
            }
        }
        request.setAttribute("departmentAttendance", departmentAttendance);
        
        // Calculate attendance rate
        int presentCount = 0;
        for (Map<String, Object> att : departmentAttendance) {
            if (att.get("checkIn") != null) {
                presentCount++;
            }
        }
        int totalSubordinates = departmentAttendance.size();
        int attendanceRate = totalSubordinates > 0 ? (presentCount * 100 / totalSubordinates) : 100;
        request.setAttribute("attendanceRate", attendanceRate + "%");

        // D. Notifications for manager
        List<Map<String, Object>> notificationsList = new ArrayList<>();
        String notiQuery = "SELECT Title, Message, CreatedAt, IsRead FROM notifications WHERE UserId = ? ORDER BY CreatedAt DESC LIMIT 5";
        try (PreparedStatement ps = conn.prepareStatement(notiQuery)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> noti = new HashMap<>();
                    noti.put("title", rs.getString("Title"));
                    noti.put("message", rs.getString("Message"));
                    noti.put("createdAt", rs.getTimestamp("CreatedAt"));
                    noti.put("isRead", rs.getBoolean("IsRead"));
                    notificationsList.add(noti);
                }
            }
        }
        request.setAttribute("notificationsList", notificationsList);
    }

    private void loadAdminData(Connection conn, HttpServletRequest request) throws SQLException {
        // 1. Thống kê 4 thẻ (Tài khoản, Nhân viên, Phòng ban, Chức vụ)
        int totalAccounts = 0;
        String countAcc = "SELECT COUNT(*) as cnt FROM accounts";
        try (PreparedStatement ps = conn.prepareStatement(countAcc);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) totalAccounts = rs.getInt("cnt");
        }
        request.setAttribute("totalAccounts", totalAccounts);

        int totalEmployees = 0;
        String countEmp = "SELECT COUNT(*) as cnt FROM users";
        try (PreparedStatement ps = conn.prepareStatement(countEmp);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) totalEmployees = rs.getInt("cnt");
        }
        request.setAttribute("totalEmployees", totalEmployees);

        int totalDepartments = 0;
        String countDepts = "SELECT COUNT(*) as cnt FROM departments";
        try (PreparedStatement ps = conn.prepareStatement(countDepts);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) totalDepartments = rs.getInt("cnt");
        }
        request.setAttribute("totalDepartments", totalDepartments);

        int totalPositions = 0;
        String countPos = "SELECT COUNT(*) as cnt FROM positions";
        try (PreparedStatement ps = conn.prepareStatement(countPos);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) totalPositions = rs.getInt("cnt");
        }
        request.setAttribute("totalPositions", totalPositions);

        // 2. Danh sách Nhân viên gần đây (Recent Employees)
        List<Map<String, Object>> recentEmployees = new ArrayList<>();
        String empQuery = "SELECT u.FullName, d.Name as DeptName FROM users u " +
                          "LEFT JOIN departments d ON u.DepartmentId = d.Id " +
                          "ORDER BY u.Id DESC LIMIT 5";
        try (PreparedStatement ps = conn.prepareStatement(empQuery);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> emp = new HashMap<>();
                emp.put("fullName", rs.getString("FullName"));
                emp.put("deptName", rs.getString("DeptName"));
                recentEmployees.add(emp);
            }
        }
        request.setAttribute("recentEmployees", recentEmployees);

        int totalHolidays = 0;
        String countHolidays = "SELECT COUNT(*) as cnt FROM holidaytemplates";
        try (PreparedStatement ps = conn.prepareStatement(countHolidays);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> dist = new HashMap<>();
                dist.put("deptName", rs.getString("DeptName"));
                dist.put("empCount", rs.getInt("EmpCount"));
                deptDistribution.add(dist);
            }
        }
        request.setAttribute("deptDistribution", deptDistribution);
    }
}
