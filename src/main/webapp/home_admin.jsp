<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    if (request.getAttribute("isLoaded") == null) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    String fullName = (String) request.getAttribute("fullName");
    String deptName = (String) request.getAttribute("deptName");
    Integer totalAccounts = (Integer) request.getAttribute("totalAccounts");
    Integer totalEmployees = (Integer) request.getAttribute("totalEmployees");
    Integer totalDepartments = (Integer) request.getAttribute("totalDepartments");
    Integer totalPositions = (Integer) request.getAttribute("totalPositions");
    List<Map<String, Object>> recentEmployees = (List<Map<String, Object>>) request.getAttribute("recentEmployees");
    List<Map<String, Object>> deptDistribution = (List<Map<String, Object>>) request.getAttribute("deptDistribution");
    
    int totalEmpCount = totalEmployees != null ? totalEmployees : 0;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>EMS – Trang chủ Quản trị</title>
  <link rel="stylesheet" href="css/ems.css"/>
  <link rel="stylesheet" href="css/users.css"/>
  <link rel="stylesheet" href="css/departments.css"/>
  <link rel="stylesheet" href="css/home-admin.css?v=2.1"/>
</head>
<body>

<!-- Sidebar -->
<aside class="sidebar">
  <a href="home" class="sidebar-brand">
    <div class="brand-dot">E</div>
    <span class="brand-name">EMS</span>
  </a>
  <nav class="nav-group">
    <div class="nav-section-label">Tổng quan</div>
    <a href="home" class="nav-link active">Trang chủ</a>
    <div class="nav-section-label">Quản trị</div>
    <a href="users"       class="nav-link">Tài khoản</a>
    <a href="employees"   class="nav-link">Nhân viên</a>
    <a href="departments" class="nav-link">Phòng ban</a>
    <a href="positions"   class="nav-link">Chức vụ</a>
  </nav>
  <div class="sidebar-footer">
    <div class="user-block">
      <div class="user-avatar">
        <%= fullName != null && !fullName.isEmpty() ? fullName.substring(0,1).toUpperCase() : "A" %>
      </div>
      <div>
        <div class="user-name"><%= fullName != null ? fullName : "Admin" %></div>
        <div class="user-role"><%= deptName != null ? deptName : "Quản trị viên" %></div>
      </div>
    </div>
    <button class="btn-logout" onclick="window.location='logout'">Đăng xuất</button>
  </div>
</aside>

<!-- Main content -->
<div class="main-content">
  <div class="topbar">
    <span class="topbar-left">Trang chủ</span>
    <span class="topbar-right" id="topbar-date"></span>
  </div>

  <div class="page-body">
    <!-- Welcome Header -->
    <div class="dash-header">
      <h1 class="dash-title">
        Chào mừng, <%= fullName != null ? fullName : "Quản trị viên" %>
      </h1>
      <p class="dash-subtitle">Hệ thống đang hoạt động bình thường.</p>
    </div>

    <!-- 4 Stats Cards Grid -->
    <div class="dash-stats-grid">
      <div class="stat-card stat-blue">
        <div class="stat-label">TÀI KHOẢN</div>
        <div class="stat-value"><%= totalAccounts != null ? totalAccounts : 0 %></div>
      </div>
      <div class="stat-card stat-green">
        <div class="stat-label">NHÂN VIÊN</div>
        <div class="stat-value"><%= totalEmployees != null ? totalEmployees : 0 %></div>
      </div>
      <div class="stat-card stat-amber">
        <div class="stat-label">PHÒNG BAN</div>
        <div class="stat-value"><%= totalDepartments != null ? totalDepartments : 0 %></div>
      </div>
      <div class="stat-card stat-purple">
        <div class="stat-label">CHỨC VỤ</div>
        <div class="stat-value"><%= totalPositions != null ? totalPositions : 0 %></div>
      </div>
    </div>

    <!-- 2 Bottom Cards Grid -->
    <div class="dash-main-grid">
      
      <!-- Card Left: Nhân viên gần đây -->
      <div class="card dash-card">
        <div class="card-header">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#0d9488" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
          <span>Nhân viên gần đây</span>
        </div>
        
        <div class="dash-card-body">
          <table class="dash-table">
            <thead>
              <tr>
                <th>Họ và tên</th>
                <th class="emp-dept-cell">Phòng ban</th>
              </tr>
            </thead>
            <tbody>
              <%
                if (recentEmployees != null && !recentEmployees.isEmpty()) {
                  for (Map<String, Object> emp : recentEmployees) {
                    String name = (String) emp.get("fullName");
                    String dName = (String) emp.get("deptName");
              %>
                <tr>
                  <td class="emp-name-cell">
                    <%= name != null ? name : "" %>
                  </td>
                  <td class="emp-dept-cell">
                    <span class="dept-code-tag">
                      <%= dName != null && !dName.isEmpty() ? dName : "Chưa phân phòng" %>
                    </span>
                  </td>
                </tr>
              <%
                  }
                } else {
              %>
                <tr>
                  <td colspan="2" class="empty-state-text">Chưa có nhân viên nào</td>
                </tr>
              <% } %>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Card Right: Phân bổ nhân viên -->
      <div class="card dash-card">
        <div class="card-header">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#0d9488" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21.21 15.89A10 10 0 1 1 8 2.83"></path><path d="M22 12A10 10 0 0 0 12 2v10z"></path></svg>
          <span>Phân bổ nhân viên</span>
        </div>
        
        <div class="dash-card-body">
          <%
            if (deptDistribution != null && !deptDistribution.isEmpty()) {
              for (Map<String, Object> dist : deptDistribution) {
                String dName = (String) dist.get("deptName");
                int count = (Integer) dist.get("empCount");
          %>
            <div class="dist-row">
              <div class="dist-label"><%= dName != null ? dName : "" %></div>
              <div class="dist-count"><%= count %></div>
            </div>
          <%
              }
            } else {
          %>
            <div class="empty-state-text">Chưa có dữ liệu phân bổ phòng ban</div>
          <% } %>
        </div>

        <div class="dist-footer">
          <span>Tổng:</span>
          <span class="dist-footer-val"><%= totalEmpCount %> nhân viên</span>
        </div>
      </div>

    </div>
  </div>
</div>

<script>
  (function updateDate() {
    const d = new Date();
    const str = String(d.getDate()).padStart(2,'0') + '/' +
                String(d.getMonth()+1).padStart(2,'0') + '/' +
                d.getFullYear();
    const el = document.getElementById('topbar-date');
    if (el) el.textContent = str;
  })();
</script>
</body>
</html>
