<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    if (request.getAttribute("usersList") == null) {
        response.sendRedirect(request.getContextPath() + "/users");
        return;
    }
    List<Map<String, Object>> usersList = (List<Map<String, Object>>) request.getAttribute("usersList");
    Integer totalCount = (Integer) request.getAttribute("totalCount");
    Integer activeCount = (Integer) request.getAttribute("activeCount");
    Integer lockedCount = (Integer) request.getAttribute("lockedCount");
    List<String> rolesList = (List<String>) request.getAttribute("rolesList");
    List<Map<String, Object>> deptsList = (List<Map<String, Object>>) request.getAttribute("deptsList");
    List<Map<String, Object>> positionsList = (List<Map<String, Object>>) request.getAttribute("positionsList");
    List<Map<String, Object>> employeesWithoutAccount = (List<Map<String, Object>>) request.getAttribute("employeesWithoutAccount");
    String fullName = (String) request.getAttribute("fullName");
    String deptName = (String) request.getAttribute("deptName");
    String successMessage = (String) request.getAttribute("successMessage");
    String errorMessage = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>EMS – Quản lý Tài khoản</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="css/ems.css?v=3.0"/>
  <link rel="stylesheet" href="css/users.css?v=3.0"/>
  <style>
    .page-nav-btn, .page-num-btn {
      padding: 6px 12px;
      border: 1px solid #e5e7eb;
      border-radius: 6px;
      background: #ffffff;
      color: #374151;
      font-size: 13px;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.15s ease;
      outline: none;
      font-family: inherit;
    }
    .page-nav-btn:hover:not(:disabled), .page-num-btn:hover:not(.active) {
      background: #f3f4f6;
      border-color: #d1d5db;
    }
    .page-nav-btn:disabled {
      opacity: 0.4;
      cursor: not-allowed;
    }
    .page-num-btn.active {
      background: #0d9488;
      color: #ffffff;
      border-color: #0d9488;
      font-weight: 600;
    }
  </style>
</head>
<body>

<aside class="sidebar">
  <a href="<%= request.getContextPath() %>/home" class="sidebar-brand">
    <div class="brand-dot">E</div>
    <span class="brand-name">EMS</span>
  </a>
  <nav class="nav-group">
    <div class="nav-section-label">Tổng quan</div>
    <a href="<%= request.getContextPath() %>/home" class="nav-link">Trang chủ</a>
    <div class="nav-section-label">Quản trị</div>
    <a href="<%= request.getContextPath() %>/users"       class="nav-link active">Tài khoản</a>
    <a href="<%= request.getContextPath() %>/employees"   class="nav-link">Nhân viên</a>
    <a href="<%= request.getContextPath() %>/departments" class="nav-link">Phòng ban</a>
    <a href="<%= request.getContextPath() %>/positions"   class="nav-link">Chức vụ</a>
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
    <button class="btn-logout" onclick="window.location='<%= request.getContextPath() %>/logout'">Đăng xuất</button>
  </div>
</aside>

<div class="main-content">
  <div class="topbar">
    <span class="topbar-left">Quản trị / Tài khoản</span>
    <span class="topbar-right" id="topbar-date"></span>
  </div>

  <div class="page-body">
    <% if (successMessage != null && !successMessage.isEmpty()) { %>
      <div class="flash-alert" style="background: #ecfdf5; border: 1px solid #a7f3d0; color: #065f46; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; font-size: 13.5px; display: flex; align-items: center; gap: 8px;">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#059669" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        <span><%= successMessage %></span>
      </div>
    <% } %>
    <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
      <div class="flash-alert" style="background: #fef2f2; border: 1px solid #fecaca; color: #991b1b; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; font-size: 13.5px; display: flex; align-items: center; gap: 8px;">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#dc2626" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
        <span><%= errorMessage %></span>
      </div>
    <% } %>
    <div class="page-header" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
      <div>
        <h1 style="font-size: 24px; font-weight: 700; color: #111827; margin-bottom: 4px;">Quản lý người dùng</h1>
        <p style="font-size: 14px; color: #4b5563;">Xem và phân quyền người dùng trong hệ thống</p>
      </div>
      <button class="btn-add-acc" type="button" onclick="openAddModal()">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
        Thêm tài khoản
      </button>
    </div>

    <!-- Stats Section -->
    <div class="stats-row" style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; margin-bottom: 24px;">
      <div class="stat-card" style="border-left: 4px solid #3b82f6;">
        <div class="stat-label">
          TỔNG NGƯỜI DÙNG
        </div>
        <div class="stat-value"><%= totalCount %></div>
      </div>
      <div class="stat-card" style="border-left: 4px solid #10b981;">
        <div class="stat-label">
          HOẠT ĐỘNG
        </div>
        <div class="stat-value"><%= activeCount %></div>
      </div>
    </div>

    <!-- Main Card User List -->
    <div class="card">
      <div class="card-header" style="display: flex; align-items: center; gap: 8px; font-weight: 700; font-size: 15px; color: #111827; border-bottom: 1px solid #f3f4f6; padding: 14px 18px;">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#0d9488" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
        Danh sách người dùng
      </div>
      
      <!-- Filter / Search bar -->
      <div class="filter-bar" style="display: flex; gap: 12px; padding: 14px 18px; border-bottom: 1px solid #f3f4f6; flex-wrap: wrap; background: #fafafa;">
        <input type="text" id="userSearchInput" placeholder="Tìm kiếm họ tên, @username, email..." oninput="filterUsers()" style="flex: 1; min-width: 200px; padding: 8px 14px; border: 1px solid #e5e7eb; border-radius: 8px; font-size: 13.5px; outline: none; background: #fff;"/>
        <select id="userRoleFilter" onchange="filterUsers()" style="padding: 8px 14px; border: 1px solid #e5e7eb; border-radius: 8px; font-size: 13.5px; outline: none; height: 38px; color: #374151; background: #fff;">
          <option value="">Tất cả vai trò</option>
          <% if (rolesList != null) { for (String r : rolesList) { 
               if (!"Admin".equalsIgnoreCase(r)) {
          %>
            <option value="<%= r.toLowerCase() %>"><%= r %></option>
          <% }}} %>
        </select>
        <select id="userStatusFilter" onchange="filterUsers()" style="padding: 8px 14px; border: 1px solid #e5e7eb; border-radius: 8px; font-size: 13.5px; outline: none; height: 38px; color: #374151; background: #fff;">
          <option value="">Tất cả trạng thái</option>
          <option value="active">Hoạt động</option>
          <option value="locked">Bị khóa</option>
        </select>
      </div>

      <div style="overflow-x: auto;">
        <table style="width: 100%; border-collapse: collapse; text-align: left; font-size: 13.5px;" id="userTable">
          <thead>
            <tr style="border-bottom: 1.5px solid #f3f4f6; color: #6b7280; text-transform: uppercase; font-size: 11px; font-weight: 700; letter-spacing: 0.5px;">
              <th style="padding: 14px 16px;">Người dùng</th>
              <th style="padding: 14px 16px;">Email</th>
              <th style="padding: 14px 16px;">Vai trò</th>
              <th style="padding: 14px 16px;">Trạng thái</th>
              <th style="padding: 14px 16px;">Thao tác</th>
            </tr>
          </thead>
          <tbody id="userTableBody">
            <%
              if (usersList != null && !usersList.isEmpty()) {
                for (Map<String, Object> u : usersList) {
                  String name = (String) u.get("fullName");
                  String username = (String) u.get("username");
                  String email = (String) u.get("emailCompany");
                  String roleName = (String) u.get("roleName");
                  
                  Boolean status = (Boolean) u.get("accountStatus");
                  boolean isCurrentStatus = (status != null && status);
            %>
                  <tr class="user-row"
                      data-name="<%= name != null ? name.toLowerCase() : "" %>"
                      data-username="<%= username != null ? username.toLowerCase() : "" %>"
                      data-email="<%= email != null ? email.toLowerCase() : "" %>"
                      data-role="<%= roleName != null ? roleName.toLowerCase() : "" %>"
                      data-status="<%= isCurrentStatus ? "active" : "locked" %>"
                      style="border-bottom: 1px solid #f3f4f6; transition: background 0.1s;" onmouseover="this.style.background='#f9fafb'" onmouseout="this.style.background='transparent'">
                    <td style="padding: 12px 16px;">
                      <div style="font-weight: 600; color: #111827;"><%= name %></div>
                      <div style="font-size: 12px; color: #6b7280;">@<%= username %></div>
                    </td>
                    <td style="padding: 12px 16px; color: #4b5563;"><%= email %></td>
                    <td style="padding: 12px 16px;">
                      <span class="badge-role">
                        <%= (roleName != null ? roleName : "employee").toLowerCase() %>
                      </span>
                    </td>
                    <td style="padding: 12px 16px;">
                      <span class="<%= isCurrentStatus ? "badge-active" : "badge-locked" %>">
                        <%= isCurrentStatus ? "Hoạt động" : "Bị khóa" %>
                      </span>
                    </td>
                    <td style="padding: 12px 16px; white-space: nowrap;">
                      <div style="display: flex; gap: 8px; align-items: center;">
                        <a href="javascript:void(0)" onclick="openEditModal(<%= u.get("accountId") %>, '<%= username %>', '<%= name != null ? name.replace("'", "\\'") : "" %>', '<%= email != null ? email.replace("'", "\\'") : "" %>', '<%= roleName != null ? roleName : "" %>')" class="btn-action-edit">Sửa</a>
                        <form action="users" method="post" style="display:inline; margin:0;">
                          <input type="hidden" name="action" value="toggleStatus"/>
                          <input type="hidden" name="accountId" value="<%= u.get("accountId") %>"/>
                          <input type="hidden" name="currentStatus" value="<%= isCurrentStatus %>"/>
                          <button type="submit" class="<%= isCurrentStatus ? "btn-action-lock" : "btn-action-unlock" %>">
                            <%= isCurrentStatus ? "Khóa" : "Hiện" %>
                          </button>
                        </form>
                      </div>
                    </td>
                  </tr>
            <%
                }
              }
            %>
              <tr id="userEmptyRow" style="<%= (usersList == null || usersList.isEmpty()) ? "" : "display:none;" %>">
                <td colspan="5" style="padding: 30px; text-align: center; color: #9ca3af;">Không có người dùng nào được tìm thấy.</td>
              </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination Container -->
      <div class="pagination-container" style="display: flex; justify-content: space-between; align-items: center; padding: 14px 18px; border-top: 1px solid #f3f4f6; font-size: 13px; color: #6b7280; flex-wrap: wrap; gap: 10px;">
        <div id="userPaginationInfo">Hiển thị 0 - 0 / 0 người dùng</div>
        <div id="userPaginationControls" style="display: flex; gap: 6px; align-items: center;"></div>
      </div>
    </div>
  </div>
</div>

<!-- Modal Edit Account -->
<div class="modal-backdrop" id="editModal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.4); backdrop-filter:blur(4px); z-index:1000; align-items:center; justify-content:center;">
  <div class="modal-content" style="background:#fff; border-radius:12px; width:440px; max-width:94vw; box-shadow:0 20px 60px rgba(0,0,0,0.15);">
    <div class="modal-header" style="padding:18px 22px; border-bottom:1px solid #f3f4f6; display:flex; justify-content:space-between; align-items:center;">
      <span class="modal-title" style="font-weight:700; font-size:16px; color:#111827;">Chỉnh sửa tài khoản</span>
      <button class="modal-close" type="button" onclick="closeEditModal()" style="background:none; border:none; font-size:20px; cursor:pointer; color:#6b7280;">&times;</button>
    </div>
    <form action="users" method="post">
      <input type="hidden" name="action" value="update"/>
      <input type="hidden" name="accountId" id="editAccountId"/>
      <div class="modal-body" style="padding:20px 22px; display:flex; flex-direction:column; gap:14px;">
        <div class="form-group">
          <label class="form-label" style="font-size:13px; font-weight:600; color:#374151; margin-bottom:5px; display:block;">Tên tài khoản (Username)</label>
          <input type="text" id="editUsername" class="form-input" readonly style="width:100%; padding:9px 12px; border:1px solid #e5e7eb; border-radius:8px; font-size:13.5px; background: #f3f4f6; color: #6b7280; cursor: not-allowed; box-sizing:border-box;"/>
        </div>
        <div class="form-group">
          <label class="form-label" style="font-size:13px; font-weight:600; color:#374151; margin-bottom:5px; display:block;">Họ và tên <span style="color:red;">*</span></label>
          <input type="text" name="fullName" id="editFullName" class="form-input" required oninput="validateEditForm()" style="width:100%; padding:9px 12px; border:1px solid #e5e7eb; border-radius:8px; font-size:13.5px; box-sizing:border-box;"/>
          <div id="editFullNameMsg" style="font-size: 12px; margin-top: 4px;"></div>
        </div>
        <div class="form-group">
          <label class="form-label" style="font-size:13px; font-weight:600; color:#374151; margin-bottom:5px; display:block;">Email công ty <span style="color:red;">*</span></label>
          <input type="email" name="email" id="editEmail" class="form-input" required oninput="validateEditForm()" style="width:100%; padding:9px 12px; border:1px solid #e5e7eb; border-radius:8px; font-size:13.5px; box-sizing:border-box;"/>
          <div id="editEmailMsg" style="font-size: 12px; margin-top: 4px;"></div>
        </div>
        <div class="form-group">
          <label class="form-label" style="font-size:13px; font-weight:600; color:#374151; margin-bottom:5px; display:block;">Vai trò</label>
          <select name="role" id="editRole" class="form-input" style="width:100%; padding:9px 12px; border:1px solid #e5e7eb; border-radius:8px; font-size:13.5px; height: 38px; box-sizing:border-box;">
            <%
              if (rolesList != null) {
                for (String r : rolesList) {
                  if (!"Admin".equalsIgnoreCase(r)) {
            %>
                  <option value="<%= r %>"><%= r %></option>
            <%
                  }
                }
              }
            %>
          </select>
        </div>
      </div>
      <div class="modal-footer" style="padding:14px 22px; border-top:1px solid #f3f4f6; display:flex; justify-content:flex-end; gap:10px; background:#fafafa; border-radius:0 0 12px 12px;">
        <button type="button" class="btn-secondary" onclick="closeEditModal()" style="padding:9px 18px; border:1px solid #e5e7eb; border-radius:8px; background:#fff; font-size:13.5px; cursor:pointer; color:#374151;">Hủy</button>
        <button type="submit" id="editSubmitBtn" class="btn-primary" style="padding:9px 18px; border:none; border-radius:8px; background:#0d9488; color:#fff; font-size:13.5px; font-weight:600; cursor:pointer;">Lưu thay đổi</button>
      </div>
    </form>
  </div>
</div>

<!-- Modal Background Add Account -->
<div class="modal-backdrop" id="addModal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.4); backdrop-filter:blur(4px); z-index:1000; align-items:center; justify-content:center;">
  <div class="modal-content" style="background:#fff; border-radius:12px; width:480px; max-width:94vw; box-shadow:0 20px 60px rgba(0,0,0,0.15);">
    <div class="modal-header" style="padding:18px 22px; border-bottom:1px solid #f3f4f6; display:flex; justify-content:space-between; align-items:center;">
      <span class="modal-title" style="font-weight:700; font-size:16px; color:#111827;">Cấp tài khoản đăng nhập</span>
      <button class="modal-close" type="button" onclick="closeAddModal()" style="background:none; border:none; font-size:20px; cursor:pointer; color:#6b7280;">&times;</button>
    </div>
    <form action="users" method="post">
      <input type="hidden" name="action" value="create"/>
      <div class="modal-body" style="padding:20px 22px; display:flex; flex-direction:column; gap: 14px;">
        
        <div class="form-group">
          <label class="form-label" style="font-size:13px; font-weight:600; color:#374151; margin-bottom:5px; display:block;">Chọn nhân viên cần cấp tài khoản <span style="color:red;">*</span></label>
          <select name="userId" id="addUserId" class="form-input" style="width:100%; padding:9px 12px; border:1px solid #e5e7eb; border-radius:8px; font-size:13.5px; height: 40px; box-sizing:border-box;" required>
            <%
              if (employeesWithoutAccount != null && !employeesWithoutAccount.isEmpty()) {
                for (Map<String, Object> emp : employeesWithoutAccount) {
            %>
                  <option value="<%= emp.get("userId") %>">
                    <%= emp.get("employeeCode") %> - <%= emp.get("fullName") %> (<%= emp.get("departmentName") %>)
                  </option>
            <%
                }
              } else {
            %>
                <option value="" disabled selected>-- Hiện không có nhân viên nào chưa có tài khoản --</option>
            <% } %>
          </select>
          <div style="font-size: 11.5px; color: #64748b; margin-top: 4px;">
            * Chỉ hiển thị những nhân viên đã có hồ sơ nhưng chưa được cấp tài khoản.
          </div>
        </div>

        <div class="form-group">
          <label class="form-label" style="font-size:13px; font-weight:600; color:#374151; margin-bottom:5px; display:block;">Tên tài khoản (Username) <span style="color:red;">*</span></label>
          <input type="text" name="username" id="addUsername" class="form-input" required placeholder="nhap_username" oninput="validateAddForm()" style="width:100%; padding:9px 12px; border:1px solid #e5e7eb; border-radius:8px; font-size:13.5px; box-sizing:border-box;"/>
          <div id="addUsernameMsg" style="font-size: 12px; margin-top: 4px;"></div>
        </div>

        <div class="form-group">
          <label class="form-label" style="font-size:13px; font-weight:600; color:#374151; margin-bottom:5px; display:block;">Mật khẩu <span style="color:red;">*</span></label>
          <input type="password" name="password" id="addPassword" class="form-input" required placeholder="Nhập mật khẩu khởi tạo" style="width:100%; padding:9px 12px; border:1px solid #e5e7eb; border-radius:8px; font-size:13.5px; box-sizing:border-box;"/>
        </div>

        <div class="form-group">
          <label class="form-label" style="font-size:13px; font-weight:600; color:#374151; margin-bottom:5px; display:block;">Vai trò hệ thống <span style="color:red;">*</span></label>
          <select name="role" class="form-input" style="width:100%; padding:9px 12px; border:1px solid #e5e7eb; border-radius:8px; font-size:13.5px; height: 38px; box-sizing:border-box;">
            <%
              if (rolesList != null) {
                for (String r : rolesList) {
                  if ("Manager".equalsIgnoreCase(r) || "Employee".equalsIgnoreCase(r)) {
            %>
                  <option value="<%= r %>" <%= "Employee".equalsIgnoreCase(r) ? "selected" : "" %>><%= r %></option>
            <%
                  }
                }
              } else {
            %>
                  <option value="Employee" selected>Employee</option>
                  <option value="Manager">Manager</option>
            <% } %>
          </select>
        </div>

      </div>
      <div class="modal-footer" style="padding:14px 22px; border-top:1px solid #f3f4f6; display:flex; justify-content:flex-end; gap:10px; background:#fafafa; border-radius:0 0 12px 12px;">
        <button type="button" class="btn-secondary" onclick="closeAddModal()" style="padding:9px 18px; border:1px solid #e5e7eb; border-radius:8px; background:#fff; font-size:13.5px; cursor:pointer; color:#374151;">Hủy</button>
        <button type="submit" id="addSubmitBtn" class="btn-primary" style="padding:9px 18px; border:none; border-radius:8px; background:#0d9488; color:#fff; font-size:13.5px; font-weight:600; cursor:pointer;" <%= (employeesWithoutAccount == null || employeesWithoutAccount.isEmpty()) ? "disabled style='padding:9px 18px; border:none; border-radius:8px; background:#0d9488; color:#fff; font-size:13.5px; font-weight:600; opacity:0.5; cursor:not-allowed;'" : "" %>>Cấp tài khoản</button>
      </div>
    </form>
  </div>
</div>

<script>
  // Dữ liệu tài khoản hiện có để kiểm tra trùng lặp thời gian thực (Real-time check)
  const EXISTING_USERS = [
    <%
      if (usersList != null) {
        boolean firstU = true;
        for (Map<String, Object> u : usersList) {
          if (!firstU) out.print(",");
          firstU = false;
          String un = (String) u.get("username");
          String em = (String) u.get("emailCompany");
          Integer accId = (Integer) u.get("accountId");
          out.print("{id:" + accId + ",username:'" + (un != null ? un.replace("'", "\\'") : "") + "',email:'" + (em != null ? em.replace("'", "\\'") : "") + "'}");
        }
      }
    %>
  ];

  // Date rendering
  (function() {
    const dateSpan = document.getElementById("topbar-date");
    if (dateSpan) {
      const now = new Date();
      const p = function(n){ return String(n).padStart(2,'0'); };
      dateSpan.textContent = p(now.getDate()) + '/' + p(now.getMonth()+1) + '/' + now.getFullYear();
    }
  })();

  // Helper hiển thị thông báo hợp lệ / lỗi
  function setFieldStatus(inputEl, msgEl, isValid, message) {
    if (!inputEl || !msgEl) return;
    if (isValid === true) {
      inputEl.style.borderColor = "#10b981";
      msgEl.innerHTML = '<span style="color: #059669; font-weight: 500;">✓ ' + message + '</span>';
    } else if (isValid === false) {
      inputEl.style.borderColor = "#dc2626";
      msgEl.innerHTML = '<span style="color: #dc2626; font-weight: 500;">' + message + '</span>';
    } else {
      inputEl.style.borderColor = "#e5e7eb";
      msgEl.innerHTML = "";
    }
  }

  // Kiểm tra thời gian thực khi CẤP tài khoản
  function validateAddForm() {
    const rawUn = document.getElementById("addUsername") ? document.getElementById("addUsername").value : "";
    const un = rawUn.trim().toLowerCase();

    const unInput = document.getElementById("addUsername");
    const unMsg = document.getElementById("addUsernameMsg");
    const submitBtn = document.getElementById("addSubmitBtn");

    let hasError = false;

    // Check Username
    if (rawUn.length > 0) {
      if (/\s/.test(rawUn)) {
        setFieldStatus(unInput, unMsg, false, "Tên tài khoản phải viết liền, không được chứa khoảng trắng!");
        hasError = true;
      } else if (un.length < 3) {
        setFieldStatus(unInput, unMsg, false, "Tên tài khoản phải có ít nhất 3 ký tự!");
        hasError = true;
      } else {
        const isUnDup = EXISTING_USERS.some(function(u){ return u.username && u.username.toLowerCase() === un; });
        if (isUnDup) {
          setFieldStatus(unInput, unMsg, false, "Tên tài khoản này đã tồn tại!");
          hasError = true;
        } else {
          setFieldStatus(unInput, unMsg, true, "Tên tài khoản hợp lệ");
        }
      }
    } else {
      setFieldStatus(unInput, unMsg, null, "");
    }

    if (submitBtn) {
      submitBtn.disabled = hasError;
      submitBtn.style.opacity = hasError ? "0.5" : "1";
      submitBtn.style.cursor = hasError ? "not-allowed" : "pointer";
    }
  }

  // Kiểm tra thời gian thực khi SỬA tài khoản
  function validateEditForm() {
    const currentId = parseInt(document.getElementById("editAccountId").value);
    const rawName = document.getElementById("editFullName") ? document.getElementById("editFullName").value : "";
    const rawEm = document.getElementById("editEmail") ? document.getElementById("editEmail").value : "";

    const nameInput = document.getElementById("editFullName");
    const nameMsg   = document.getElementById("editFullNameMsg");
    const emInput   = document.getElementById("editEmail");
    const emMsg     = document.getElementById("editEmailMsg");
    const submitBtn = document.getElementById("editSubmitBtn");

    const em = rawEm.trim().toLowerCase();
    let hasError = false;

    // 1. Check FullName
    if (rawName.trim().length > 0) {
      if (!/^[a-zA-ZÀ-ỹ\s]+$/.test(rawName.trim())) {
        setFieldStatus(nameInput, nameMsg, false, "Họ và tên chỉ được chứa chữ cái và khoảng trắng!");
        hasError = true;
      } else {
        setFieldStatus(nameInput, nameMsg, true, "Họ tên hợp lệ");
      }
    } else {
      setFieldStatus(nameInput, nameMsg, null, "");
    }

    // 2. Check Email (loại trừ tài khoản hiện tại)
    if (rawEm.length > 0) {
      if (/\s/.test(rawEm)) {
        setFieldStatus(emInput, emMsg, false, "Email phải viết liền, không được chứa khoảng trắng!");
        hasError = true;
      } else if (!/^[a-zA-Z0-9._%+-]+@hrms\.vn$/.test(em)) {
        setFieldStatus(emInput, emMsg, false, "Email công ty phải có đuôi @hrms.vn (VD: nhanvien@hrms.vn)!");
        hasError = true;
      } else {
        const isEmDup = EXISTING_USERS.some(function(u){ return u.id !== currentId && u.email && u.email.toLowerCase() === em; });
        if (isEmDup) {
          setFieldStatus(emInput, emMsg, false, "Email này đã được dùng bởi tài khoản khác!");
          hasError = true;
        } else {
          setFieldStatus(emInput, emMsg, true, "Email hợp lệ");
        }
      }
    } else {
      setFieldStatus(emInput, emMsg, null, "");
    }

    if (submitBtn) {
      submitBtn.disabled = hasError;
      submitBtn.style.opacity = hasError ? "0.5" : "1";
      submitBtn.style.cursor = hasError ? "not-allowed" : "pointer";
    }
  }

  // Modal actions
  function openAddModal() {
    if (document.getElementById("addUsername")) document.getElementById("addUsername").value = "";
    if (document.getElementById("addPassword")) document.getElementById("addPassword").value = "";
    setFieldStatus(document.getElementById("addUsername"), document.getElementById("addUsernameMsg"), null, "");
    
    const sel = document.getElementById("addUserId");
    const hasEmp = sel && sel.options.length > 0 && sel.value !== "";
    const submitBtn = document.getElementById("addSubmitBtn");
    if (submitBtn) {
      submitBtn.disabled = !hasEmp;
      submitBtn.style.opacity = hasEmp ? "1" : "0.5";
      submitBtn.style.cursor = hasEmp ? "pointer" : "not-allowed";
    }
    document.getElementById("addModal").style.display = "flex";
  }

  function closeAddModal() {
    document.getElementById("addModal").style.display = "none";
  }

  function openEditModal(accountId, username, fullName, email, role) {
    document.getElementById("editAccountId").value = accountId;
    document.getElementById("editUsername").value = username || '';
    document.getElementById("editFullName").value = fullName || '';
    document.getElementById("editEmail").value = email || '';
    if (role && document.getElementById("editRole")) {
      document.getElementById("editRole").value = role;
    }

    setFieldStatus(document.getElementById("editFullName"), document.getElementById("editFullNameMsg"), null, "");
    setFieldStatus(document.getElementById("editEmail"), document.getElementById("editEmailMsg"), null, "");
    const submitBtn = document.getElementById("editSubmitBtn");
    if (submitBtn) {
      submitBtn.disabled = false;
      submitBtn.style.opacity = "1";
      submitBtn.style.cursor = "pointer";
    }

    document.getElementById("editModal").style.display = "flex";
  }

  function closeEditModal() {
    document.getElementById("editModal").style.display = "none";
  }

  // Đóng modal khi click ra ngoài
  document.getElementById("addModal").addEventListener("click", function(e) {
    if (e.target === this) closeAddModal();
  });
  document.getElementById("editModal").addEventListener("click", function(e) {
    if (e.target === this) closeEditModal();
  });

  // Phân trang & Tìm kiếm tài khoản
  const USER_PAGE_SIZE = 10;
  let currentUserPage = 1;
  let filteredUserRows = [];

  function filterUsers() {
    const searchVal = (document.getElementById('userSearchInput') ? document.getElementById('userSearchInput').value : '').toLowerCase().trim();
    const roleVal   = (document.getElementById('userRoleFilter') ? document.getElementById('userRoleFilter').value : '').toLowerCase().trim();
    const statusVal = (document.getElementById('userStatusFilter') ? document.getElementById('userStatusFilter').value : '').toLowerCase().trim();

    const allRows = document.querySelectorAll('.user-row');
    filteredUserRows = [];

    allRows.forEach(function(row) {
      const name = (row.getAttribute('data-name') || '').toLowerCase();
      const un   = (row.getAttribute('data-username') || '').toLowerCase();
      const em   = (row.getAttribute('data-email') || '').toLowerCase();
      const role = (row.getAttribute('data-role') || '').toLowerCase();
      const st   = (row.getAttribute('data-status') || '').toLowerCase();

      const matchSearch = !searchVal || name.includes(searchVal) || un.includes(searchVal) || em.includes(searchVal);
      const matchRole   = !roleVal || role === roleVal;
      const matchStatus = !statusVal || st === statusVal;

      if (matchSearch && matchRole && matchStatus) {
        filteredUserRows.push(row);
      } else {
        row.style.display = 'none';
      }
    });

    currentUserPage = 1;
    renderUserPagination();
  }

  function renderUserPagination() {
    const allRows = document.querySelectorAll('.user-row');
    allRows.forEach(function(row) { row.style.display = 'none'; });

    const total = filteredUserRows.length;
    const emptyRow = document.getElementById('userEmptyRow');

    if (total === 0) {
      if (emptyRow) emptyRow.style.display = '';
    } else {
      if (emptyRow) emptyRow.style.display = 'none';
    }

    const totalPages = Math.ceil(total / USER_PAGE_SIZE) || 1;
    if (currentUserPage > totalPages) currentUserPage = totalPages;
    if (currentUserPage < 1) currentUserPage = 1;

    const startIdx = (currentUserPage - 1) * USER_PAGE_SIZE;
    const endIdx   = Math.min(startIdx + USER_PAGE_SIZE, total);

    for (let i = startIdx; i < endIdx; i++) {
      filteredUserRows[i].style.display = '';
    }

    // Cập nhật thông tin phân trang
    const infoEl = document.getElementById('userPaginationInfo');
    if (infoEl) {
      if (total === 0) {
        infoEl.textContent = 'Không tìm thấy người dùng nào phù hợp';
      } else {
        infoEl.textContent = 'Hiển thị ' + (startIdx + 1) + ' - ' + endIdx + ' trên tổng số ' + total + ' người dùng';
      }
    }

    // Vẽ các nút điều khiển phân trang
    const controlsEl = document.getElementById('userPaginationControls');
    if (!controlsEl) return;
    controlsEl.innerHTML = '';

    if (totalPages <= 1) return;

    // Nút Trước
    const prevBtn = document.createElement('button');
    prevBtn.innerHTML = '&laquo; Trước';
    prevBtn.className = 'page-nav-btn';
    prevBtn.type = 'button';
    prevBtn.disabled = currentUserPage === 1;
    prevBtn.onclick = function() {
      if (currentUserPage > 1) {
        currentUserPage--;
        renderUserPagination();
      }
    };
    controlsEl.appendChild(prevBtn);

    // Các nút số trang
    for (let p = 1; p <= totalPages; p++) {
      if (totalPages > 7) {
        if (p !== 1 && p !== totalPages && Math.abs(p - currentUserPage) > 2) {
          if (p === 2 || p === totalPages - 1) {
            const dots = document.createElement('span');
            dots.textContent = '...';
            dots.style.padding = '0 4px';
            dots.style.color = '#9ca3af';
            controlsEl.appendChild(dots);
          }
          continue;
        }
      }
      const pageBtn = document.createElement('button');
      pageBtn.textContent = p;
      pageBtn.type = 'button';
      pageBtn.className = 'page-num-btn' + (p === currentUserPage ? ' active' : '');
      pageBtn.onclick = (function(page) {
        return function() {
          currentUserPage = page;
          renderUserPagination();
        };
      })(p);
      controlsEl.appendChild(pageBtn);
    }

    // Nút Tiếp
    const nextBtn = document.createElement('button');
    nextBtn.innerHTML = 'Tiếp &raquo;';
    nextBtn.className = 'page-nav-btn';
    nextBtn.type = 'button';
    nextBtn.disabled = currentUserPage === totalPages;
    nextBtn.onclick = function() {
      if (currentUserPage < totalPages) {
        currentUserPage++;
        renderUserPagination();
      }
    };
    controlsEl.appendChild(nextBtn);
  }

  // Kích hoạt phân trang ngay khi tải xong DOM
  document.addEventListener('DOMContentLoaded', function() {
    filterUsers();
  });

  // Tự động ẩn thông báo sau đúng 2 giây
  setTimeout(function() {
    var alerts = document.querySelectorAll('.flash-alert');
    alerts.forEach(function(alert) {
      alert.style.transition = 'opacity 0.4s ease, transform 0.4s ease, max-height 0.4s ease, margin-bottom 0.4s ease';
      alert.style.opacity = '0';
      alert.style.transform = 'translateY(-8px)';
      alert.style.maxHeight = '0';
      alert.style.marginBottom = '0';
      alert.style.paddingTop = '0';
      alert.style.paddingBottom = '0';
      alert.style.overflow = 'hidden';
      setTimeout(function() {
        alert.remove();
      }, 400);
    });
  }, 2000);
</script>
</body>
</html>
