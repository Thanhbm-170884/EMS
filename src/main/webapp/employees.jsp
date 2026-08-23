<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    List<Map<String, Object>> employeeList = (List<Map<String, Object>>) request.getAttribute("employeeList");
    Integer totalEmp   = (Integer) request.getAttribute("totalEmp");
    Integer activeEmp  = (Integer) request.getAttribute("activeEmp");
    List<Map<String, Object>> deptsList = (List<Map<String, Object>>) request.getAttribute("deptsList");
    List<Map<String, Object>> positionsList = (List<Map<String, Object>>) request.getAttribute("positionsList");
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
  <title>EMS – Quản lý nhân viên</title>
  <link rel="stylesheet" href="css/ems.css"/>
  <link rel="stylesheet" href="css/users.css"/>
  <link rel="stylesheet" href="css/employees.css"/>
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
  <a href="home" class="sidebar-brand">
    <div class="brand-dot">E</div>
    <span class="brand-name">EMS</span>
  </a>
  <nav class="nav-group">
    <div class="nav-section-label">Tổng quan</div>
    <a href="home" class="nav-link">Trang chủ</a>
    <div class="nav-section-label">Quản trị</div>
    <a href="users"       class="nav-link">Tài khoản</a>
    <a href="employees"   class="nav-link active">Nhân viên</a>
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

<div class="main-content">
  <div class="topbar">
    <span class="topbar-left">Quản trị / Thông tin nhân viên</span>
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

    <!-- Page Header -->
    <div class="emp-page-header" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
      <div>
        <h1 class="emp-page-title">Thông tin nhân viên</h1>
        <p class="emp-page-subtitle">Danh sách hồ sơ nhân viên trong hệ thống</p>
      </div>
      <div>
        <button type="button" onclick="openAddEmpModal()"
                style="background: #0d9488; color: #fff; border: none; padding: 10px 18px; border-radius: 8px; font-weight: 600; font-size: 13.5px; cursor: pointer; display: flex; align-items: center; gap: 6px; box-shadow: 0 2px 4px rgba(13,148,136,0.2);">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
          Thêm nhân viên
        </button>
      </div>
    </div>

    <!-- Stats -->
    <div class="emp-stats-row">
      <div class="stat-card" style="border-left: 4px solid #3b82f6;">
        <div class="stat-label">TỔNG NHÂN VIÊN</div>
        <div class="stat-value"><%= totalEmp %></div>
      </div>
      <div class="stat-card" style="border-left: 4px solid #10b981;">
        <div class="stat-label">ĐANG HOẠT ĐỘNG</div>
        <div class="stat-value"><%= activeEmp %></div>
      </div>
    </div>

    <!-- Main Card -->
    <div class="card">
      <div class="card-header" style="display:flex; align-items:center; gap:8px; font-weight:700; font-size:15px; color:#111827; border-bottom:1px solid #f3f4f6; padding:14px 18px;">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#0d9488" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
        Danh sách nhân viên
      </div>

      <!-- Filter bar -->
      <div class="filter-bar">
        <input type="text" id="searchInput" placeholder="Tìm kiếm tên / mã nhân viên..." oninput="filterTable()"/>
        <select id="filterDept" onchange="filterTable()">
          <option value="">Tất cả phòng ban</option>
          <% if (deptsList != null) { for (Map<String,Object> d : deptsList) { %>
            <option value="<%= d.get("name") %>"><%= d.get("name") %></option>
          <% }} %>
        </select>
        <select id="filterStatus" onchange="filterTable()">
          <option value="">Tất cả trạng thái</option>
          <option value="active">Đang làm</option>
          <option value="locked">Nghỉ</option>
        </select>
      </div>

      <!-- Table -->
      <div class="emp-table-wrap">
        <table class="emp-table" id="empTable">
          <thead>
            <tr>
              <th>Mã NV</th>
              <th>Họ và tên</th>
              <th>Phòng ban</th>
              <th>Chức vụ</th>
              <th>Email</th>
              <th>Số điện thoại</th>
              <th>Trạng thái</th>
              <th>Thao tác</th>
            </tr>
          </thead>
          <tbody id="empTableBody">
          <%
            if (employeeList != null && !employeeList.isEmpty()) {
              for (Map<String, Object> emp : employeeList) {
                Boolean status = (Boolean) emp.get("userStatus");
                boolean isActive = (status != null && status);
                String phone = (String) emp.get("phone");
                if (phone == null || phone.isEmpty()) phone = "—";

                // Format giới tính
                Object genderObj = emp.get("gender");
                String genderStr = "—";
                if (genderObj != null) {
                    genderStr = ((Boolean) genderObj) ? "Nam" : "Nữ";
                }
                // Format ngày sinh
                java.sql.Date dob = (java.sql.Date) emp.get("dateOfBirth");
                String dobStr = "—";
                if (dob != null) {
                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                    dobStr = sdf.format(dob);
                }
                String deptStr = emp.get("departmentName") != null ? (String) emp.get("departmentName") : "—";
                String posStr  = emp.get("positionName")   != null ? (String) emp.get("positionName")   : "—";
          %>
            <tr class="emp-row"
                data-user-id="<%= emp.get("userId") %>"
                data-name="<%= emp.get("fullName") %>"
                data-code="<%= emp.get("employeeCode") %>"
                data-email="<%= emp.get("emailCompany") %>"
                data-dept="<%= deptStr %>"
                data-status="<%= isActive ? "active" : "locked" %>"
                data-dob="<%= dobStr %>"
                data-dob-raw="<%= dob != null ? dob.toString() : "" %>"
                data-gender="<%= genderStr %>"
                data-gender-raw="<%= genderObj != null ? genderObj.toString() : "" %>"
                data-phone="<%= phone.equals("—") ? "" : phone %>"
                data-pos="<%= posStr %>"
                data-dept-id="<%= emp.get("departmentId") != null ? emp.get("departmentId") : "" %>"
                data-pos-id="<%= emp.get("positionId") != null ? emp.get("positionId") : "" %>">
              <td><span class="emp-code"><%= emp.get("employeeCode") %></span></td>
              <td>
                <div class="emp-name"><%= emp.get("fullName") %></div>
              </td>
              <td><%= deptStr %></td>
              <td><%= posStr %></td>
              <td><%= emp.get("emailCompany") %></td>
              <td><%= phone %></td>
              <td>
                <span class="<%= isActive ? "badge-active" : "badge-locked" %>">
                  <%= isActive ? "Đang làm" : "Nghỉ" %>
                </span>
              </td>
              <td>
                <a href="javascript:void(0)" onclick="openViewEmpModal(this)"
                   style="color:#6366f1; text-decoration:none; font-weight:600; margin-right:12px;">Xem</a>
                <a href="javascript:void(0)" onclick="openEditEmpModal(this)"
                   style="color:#0d9488; text-decoration:none; font-weight:600; margin-right:12px;">Sửa</a>
                <form action="employees" method="post" style="display:inline;">
                  <input type="hidden" name="action" value="toggleStatus"/>
                  <input type="hidden" name="userId" value="<%= emp.get("userId") %>"/>
                  <input type="hidden" name="currentStatus" value="<%= isActive %>"/>
                  <button type="submit" style="background:none; border:none; color:#dc2626; cursor:pointer; font-size:13.5px; font-weight:600; padding:0; font-family:inherit;">
                    <%= isActive ? "Dừng" : "Hiện" %>
                  </button>
                </form>
              </td>
            </tr>
          <%
                }
              }
          %>
            <tr id="empEmptyRow" style="display:none;">
              <td colspan="8" class="emp-empty" style="padding: 30px; text-align: center; color: #9ca3af;">Không tìm thấy nhân viên nào phù hợp.</td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination Container -->
      <div class="pagination-container" style="display: flex; justify-content: space-between; align-items: center; padding: 14px 18px; border-top: 1px solid #f3f4f6; font-size: 13px; color: #6b7280; flex-wrap: wrap; gap: 10px;">
        <div id="empPaginationInfo">Hiển thị 0 - 0 / 0 nhân viên</div>
        <div id="empPaginationControls" style="display: flex; gap: 6px; align-items: center;"></div>
      </div>
    </div>

  </div>
</div>

<!-- Modal Xem hồ sơ nhân viên -->
<div id="viewEmpModal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.4); backdrop-filter:blur(4px); z-index:1000; align-items:center; justify-content:center;">
  <div style="background:#fff; border-radius:12px; width:420px; max-width:94vw; box-shadow:0 20px 60px rgba(0,0,0,0.15);">
    <!-- Header -->
    <div style="padding:18px 22px; border-bottom:1px solid #f3f4f6; display:flex; justify-content:space-between; align-items:center;">
      <span style="font-weight:700; font-size:16px; color:#111827;">Hồ sơ nhân viên</span>
      <button onclick="closeViewEmpModal()" style="background:none; border:none; font-size:20px; cursor:pointer; color:#6b7280; line-height:1;">&times;</button>
    </div>
    <!-- Body -->
    <div style="padding:22px;">
      <!-- Mã NV + Tên -->
      <div style="display:flex; align-items:center; gap:14px; margin-bottom:22px;">
        <div>
          <div style="font-size:12px; color:#9ca3af; font-weight:500;" id="viewEmpCode">EMP001</div>
          <div style="font-size:16px; font-weight:700; color:#111827;" id="viewEmpName">Nguyễn Văn An</div>
        </div>
      </div>

      <!-- Thông tin cá nhân -->
      <div style="font-size:12px; font-weight:700; color:#6b7280; text-transform:uppercase; letter-spacing:0.5px; margin-bottom:10px;">— Thông tin cá nhân —</div>
      <div style="display:flex; flex-direction:column; gap:8px; margin-bottom:20px;">
        <div style="display:flex; justify-content:space-between; font-size:13.5px;">
          <span style="color:#6b7280;">Ngày sinh:</span>
          <span style="color:#111827; font-weight:500;" id="viewEmpDob">—</span>
        </div>
        <div style="display:flex; justify-content:space-between; font-size:13.5px;">
          <span style="color:#6b7280;">Giới tính:</span>
          <span style="color:#111827; font-weight:500;" id="viewEmpGender">—</span>
        </div>
        <div style="display:flex; justify-content:space-between; font-size:13.5px;">
          <span style="color:#6b7280;">SĐT:</span>
          <span style="color:#111827; font-weight:500;" id="viewEmpPhone">—</span>
        </div>
      </div>

      <!-- Thông tin công việc -->
      <div style="font-size:12px; font-weight:700; color:#6b7280; text-transform:uppercase; letter-spacing:0.5px; margin-bottom:10px;">— Thông tin công việc —</div>
      <div style="display:flex; flex-direction:column; gap:8px;">
        <div style="display:flex; justify-content:space-between; font-size:13.5px;">
          <span style="color:#6b7280;">Email công ty:</span>
          <span style="color:#111827; font-weight:500;" id="viewEmpEmail">—</span>
        </div>
        <div style="display:flex; justify-content:space-between; font-size:13.5px;">
          <span style="color:#6b7280;">Phòng ban:</span>
          <span style="color:#111827; font-weight:500;" id="viewEmpDept">—</span>
        </div>
        <div style="display:flex; justify-content:space-between; font-size:13.5px;">
          <span style="color:#6b7280;">Chức vụ:</span>
          <span style="color:#111827; font-weight:500;" id="viewEmpPos">—</span>
        </div>
      </div>
    </div>
    <!-- Footer -->
    <div style="padding:14px 22px; border-top:1px solid #f3f4f6; display:flex; justify-content:flex-end;">
      <button onclick="closeViewEmpModal()" style="padding:9px 20px; border:1px solid #e5e7eb; border-radius:8px; background:#fff; font-size:13.5px; cursor:pointer; color:#374151;">Đóng</button>
    </div>
  </div>
</div>

<!-- Modal Thêm nhân viên mới -->
<div class="modal-backdrop" id="addEmpModal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.4); backdrop-filter:blur(4px); z-index:1000; align-items:center; justify-content:center;">
  <div class="modal-content" style="background:#fff; border-radius:12px; width:540px; max-width:94vw; max-height:92vh; display:flex; flex-direction:column; box-shadow:0 20px 60px rgba(0,0,0,0.15);">
    <div class="modal-header" style="padding:16px 22px; border-bottom:1px solid #f3f4f6; display:flex; justify-content:space-between; align-items:center;">
      <span class="modal-title" style="font-weight:700; font-size:16px; color:#111827;">Thêm hồ sơ nhân viên mới</span>
      <button onclick="closeAddEmpModal()" style="background:none; border:none; font-size:20px; cursor:pointer; color:#6b7280; line-height:1;">&times;</button>
    </div>
    <form action="employees" method="post" style="display:flex; flex-direction:column; overflow:hidden;">
      <input type="hidden" name="action" value="create"/>
      <div class="modal-body" style="padding:20px 22px; display:flex; flex-direction:column; gap:14px; overflow-y:auto; max-height:66vh;">
        
        <div class="form-group">
          <label class="form-label" style="font-size:13px; font-weight:600; color:#374151; margin-bottom:5px; display:block;">Họ và tên <span style="color:red;">*</span></label>
          <input type="text" name="fullName" id="addEmpFullName" class="form-input" required placeholder="Nguyễn Văn A" oninput="validateAddEmpForm()"
                 style="width:100%; padding:9px 12px; border:1px solid #e5e7eb; border-radius:8px; font-size:13.5px; outline:none; box-sizing:border-box;"/>
          <div id="addEmpFullNameMsg" style="font-size: 12px; margin-top: 4px;"></div>
        </div>

        <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
          <div class="form-group">
            <label class="form-label" style="font-size:13px; font-weight:600; color:#374151; margin-bottom:5px; display:block;">Email công ty <span style="color:red;">*</span></label>
            <input type="email" name="email" id="addEmpEmail" class="form-input" required placeholder="nhanvien@techcorp.vn" oninput="validateAddEmpForm()"
                   style="width:100%; padding:9px 12px; border:1px solid #e5e7eb; border-radius:8px; font-size:13.5px; outline:none; box-sizing:border-box;"/>
            <div id="addEmpEmailMsg" style="font-size: 12px; margin-top: 4px;"></div>
          </div>
          <div class="form-group">
            <label class="form-label" style="font-size:13px; font-weight:600; color:#374151; margin-bottom:5px; display:block;">Số điện thoại <span style="color:red;">*</span></label>
            <input type="tel" name="phone" id="addEmpPhone" class="form-input" required placeholder="0912345678" oninput="validateAddEmpForm()"
                   style="width:100%; padding:9px 12px; border:1px solid #e5e7eb; border-radius:8px; font-size:13.5px; outline:none; box-sizing:border-box;"/>
            <div id="addEmpPhoneMsg" style="font-size: 12px; margin-top: 4px;"></div>
          </div>
        </div>

        <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
          <div class="form-group">
            <label class="form-label" style="font-size:13px; font-weight:600; color:#374151; margin-bottom:5px; display:block;">Giới tính <span style="color:red;">*</span></label>
            <select name="gender" id="addEmpGender" class="form-input" style="width:100%; padding:9px 12px; border:1px solid #e5e7eb; border-radius:8px; font-size:13.5px; outline:none; box-sizing:border-box; height:38px;">
              <option value="true">Nam</option>
              <option value="false">Nữ</option>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label" style="font-size:13px; font-weight:600; color:#374151; margin-bottom:5px; display:block;">Ngày sinh <span style="color:red;">*</span></label>
            <input type="date" name="dob" id="addEmpDob" class="form-input" required oninput="validateAddEmpForm()"
                   style="width:100%; padding:8px 12px; border:1px solid #e5e7eb; border-radius:8px; font-size:13.5px; outline:none; box-sizing:border-box; height:38px;"/>
            <div id="addEmpDobMsg" style="font-size: 12px; margin-top: 4px;"></div>
          </div>
        </div>

        <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
          <div class="form-group">
            <label class="form-label" style="font-size:13px; font-weight:600; color:#374151; margin-bottom:5px; display:block;">Phòng ban <span style="color:red;">*</span></label>
            <select name="departmentId" id="addEmpDept" class="form-input" style="width:100%; padding:9px 12px; border:1px solid #e5e7eb; border-radius:8px; font-size:13.5px; outline:none; box-sizing:border-box; height:38px;">
              <% if (deptsList != null) { for (Map<String, Object> d : deptsList) { %>
                <option value="<%= d.get("id") %>"><%= d.get("name") %></option>
              <% }} %>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label" style="font-size:13px; font-weight:600; color:#374151; margin-bottom:5px; display:block;">Chức vụ <span style="color:red;">*</span></label>
            <select name="positionId" id="addEmpPos" class="form-input" style="width:100%; padding:9px 12px; border:1px solid #e5e7eb; border-radius:8px; font-size:13.5px; outline:none; box-sizing:border-box; height:38px;">
              <% if (positionsList != null) { for (Map<String, Object> p : positionsList) { %>
                <option value="<%= p.get("id") %>"><%= p.get("name") %></option>
              <% }} %>
            </select>
          </div>
        </div>

        <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
          <div class="form-group">
            <label class="form-label" style="font-size:13px; font-weight:600; color:#374151; margin-bottom:5px; display:block;">Số người phụ thuộc</label>
            <input type="number" name="dependentsCount" id="addEmpDependents" min="0" value="0" class="form-input"
                   style="width:100%; padding:9px 12px; border:1px solid #e5e7eb; border-radius:8px; font-size:13.5px; outline:none; box-sizing:border-box;"/>
          </div>
          <div class="form-group">
            <label class="form-label" style="font-size:13px; font-weight:600; color:#374151; margin-bottom:5px; display:block;">Lương cơ bản (VNĐ)</label>
            <input type="number" name="baseSalary" id="addEmpSalary" min="0" step="100000" value="5000000" class="form-input"
                   style="width:100%; padding:9px 12px; border:1px solid #e5e7eb; border-radius:8px; font-size:13.5px; outline:none; box-sizing:border-box;"/>
          </div>
        </div>

      </div>
      <div style="padding:14px 22px; border-top:1px solid #f3f4f6; display:flex; justify-content:flex-end; gap:10px; background:#fafafa; border-radius:0 0 12px 12px;">
        <button type="button" onclick="closeAddEmpModal()"
                style="padding:9px 18px; border:1px solid #e5e7eb; border-radius:8px; background:#fff; font-size:13.5px; cursor:pointer; color:#374151;">Hủy</button>
        <button type="submit" id="addEmpSubmitBtn"
                style="padding:9px 18px; border:none; border-radius:8px; background:#0d9488; color:#fff; font-size:13.5px; font-weight:600; cursor:pointer;">Thêm nhân viên</button>
      </div>
    </form>
  </div>
</div>

<!-- Modal Sửa thông tin nhân viên -->
<div class="modal-backdrop" id="editEmpModal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.4); backdrop-filter:blur(4px); z-index:1000; align-items:center; justify-content:center;">
  <div class="modal-content" style="background:#fff; border-radius:12px; width:440px; max-width:94vw; box-shadow:0 20px 60px rgba(0,0,0,0.15);">
    <div class="modal-header" style="padding:18px 22px; border-bottom:1px solid #f3f4f6; display:flex; justify-content:space-between; align-items:center;">
      <span class="modal-title" style="font-weight:700; font-size:16px; color:#111827;">Chỉnh sửa thông tin nhân viên</span>
      <button onclick="closeEditEmpModal()" style="background:none; border:none; font-size:20px; cursor:pointer; color:#6b7280; line-height:1;">&times;</button>
    </div>
    <form action="employees" method="post">
      <input type="hidden" name="action" value="update"/>
      <input type="hidden" name="userId" id="editEmpUserId"/>
      <div class="modal-body" style="padding:20px 22px; display:flex; flex-direction:column; gap:14px;">
        
        <!-- Header tóm tắt nhân viên -->
        <div style="background:#f8fafc; border:1px solid #e2e8f0; border-radius:8px; padding:10px 14px; display:flex; align-items:center; gap:10px;">
          <div style="width:36px; height:36px; border-radius:8px; background:#0d9488; color:#fff; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:14px;" id="editEmpAvatar">E</div>
          <div>
            <div style="font-size:11px; color:#64748b; font-weight:600; text-transform:uppercase;" id="editEmpCodeBadge">EMP001</div>
            <div style="font-size:15px; font-weight:700; color:#0f172a;" id="editEmpNameDisplay">Nguyễn Văn An</div>
          </div>
        </div>

        <div class="form-group">
          <label class="form-label" style="font-size:13px; font-weight:600; color:#374151; margin-bottom:5px; display:block;">Email công ty <span style="color:red;">*</span></label>
          <input type="email" name="email" id="editEmpEmail" class="form-input" required placeholder="nhanvien@techcorp.vn" oninput="validateEditEmpForm()"
                 style="width:100%; padding:9px 12px; border:1px solid #e5e7eb; border-radius:8px; font-size:13.5px; outline:none; box-sizing:border-box;"/>
          <div id="editEmpEmailMsg" style="font-size: 12px; margin-top: 4px;"></div>
        </div>

        <div class="form-group">
          <label class="form-label" style="font-size:13px; font-weight:600; color:#374151; margin-bottom:5px; display:block;">Phòng ban <span style="color:red;">*</span></label>
          <select name="departmentId" id="editEmpDept" class="form-input" style="width:100%; padding:9px 12px; border:1px solid #e5e7eb; border-radius:8px; font-size:13.5px; outline:none; box-sizing:border-box; height: 38px;">
            <% if (deptsList != null) { for (Map<String, Object> d : deptsList) { %>
              <option value="<%= d.get("id") %>"><%= d.get("name") %></option>
            <% }} %>
          </select>
        </div>

        <div class="form-group">
          <label class="form-label" style="font-size:13px; font-weight:600; color:#374151; margin-bottom:5px; display:block;">Chức vụ <span style="color:red;">*</span></label>
          <select name="positionId" id="editEmpPos" class="form-input" style="width:100%; padding:9px 12px; border:1px solid #e5e7eb; border-radius:8px; font-size:13.5px; outline:none; box-sizing:border-box; height: 38px;">
            <% if (positionsList != null) { for (Map<String, Object> p : positionsList) { %>
              <option value="<%= p.get("id") %>"><%= p.get("name") %></option>
            <% }} %>
          </select>
        </div>
      </div>
      <div style="padding:14px 22px; border-top:1px solid #f3f4f6; display:flex; justify-content:flex-end; gap:10px;">
        <button type="button" onclick="closeEditEmpModal()"
                style="padding:9px 18px; border:1px solid #e5e7eb; border-radius:8px; background:#fff; font-size:13.5px; cursor:pointer; color:#374151;">Hủy</button>
        <button type="submit" id="editEmpSubmitBtn"
                style="padding:9px 18px; border:none; border-radius:8px; background:#0d9488; color:#fff; font-size:13.5px; font-weight:600; cursor:pointer;">Lưu thay đổi</button>
      </div>
    </form>
  </div>
</div>

<script>
  // Dữ liệu nhân viên hiện tại để kiểm tra thời gian thực
  const EXISTING_EMPLOYEES = [
    <%
      if (employeeList != null) {
        boolean firstE = true;
        for (Map<String, Object> emp : employeeList) {
          if (!firstE) out.print(",");
          firstE = false;
          Integer uId = (Integer) emp.get("userId");
          String em = (String) emp.get("emailCompany");
          String ph = (String) emp.get("phone");
          out.print("{id:" + uId + ",email:'" + (em != null ? em.replace("'", "\\'") : "") + "',phone:'" + (ph != null ? ph.replace("'", "\\'") : "") + "'}");
        }
      }
    %>
  ];

  (function() {
    var now = new Date();
    var p = function(n){ return String(n).padStart(2,'0'); };
    document.getElementById('topbar-date').textContent =
      p(now.getDate())+'/'+p(now.getMonth()+1)+'/'+now.getFullYear();
  })();

  function setEmpFieldStatus(inputEl, msgEl, isValid, message) {
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

  function openAddEmpModal() {
    document.getElementById('addEmpModal').style.display = 'flex';
  }

  function closeAddEmpModal() {
    document.getElementById('addEmpModal').style.display = 'none';
  }

  function validateAddEmpForm() {
    var rawName = document.getElementById('addEmpFullName') ? document.getElementById('addEmpFullName').value : '';
    var rawEm   = document.getElementById('addEmpEmail') ? document.getElementById('addEmpEmail').value : '';
    var rawPh   = document.getElementById('addEmpPhone') ? document.getElementById('addEmpPhone').value : '';
    var rawDob  = document.getElementById('addEmpDob') ? document.getElementById('addEmpDob').value : '';

    var nameInput = document.getElementById('addEmpFullName');
    var nameMsg   = document.getElementById('addEmpFullNameMsg');
    var emInput   = document.getElementById('addEmpEmail');
    var emMsg     = document.getElementById('addEmpEmailMsg');
    var phInput   = document.getElementById('addEmpPhone');
    var phMsg     = document.getElementById('addEmpPhoneMsg');
    var dobInput  = document.getElementById('addEmpDob');
    var dobMsg    = document.getElementById('addEmpDobMsg');
    var submitBtn = document.getElementById('addEmpSubmitBtn');

    var em = rawEm.trim().toLowerCase();
    var ph = rawPh.trim();
    var hasError = false;

    // 1. Check FullName
    if (rawName.trim().length > 0) {
      if (!/^[a-zA-ZÀ-ỹ\s]+$/.test(rawName.trim())) {
        setEmpFieldStatus(nameInput, nameMsg, false, 'Họ và tên chỉ được chứa chữ cái và khoảng trắng!');
        hasError = true;
      } else {
        setEmpFieldStatus(nameInput, nameMsg, true, 'Họ tên hợp lệ');
      }
    } else {
      setEmpFieldStatus(nameInput, nameMsg, null, '');
    }

    // 2. Check Email
    if (rawEm.length > 0) {
      if (/\s/.test(rawEm)) {
        setEmpFieldStatus(emInput, emMsg, false, 'Email phải viết liền, không được chứa khoảng trắng!');
        hasError = true;
      } else if (!/^[a-zA-Z0-9._%+-]+@techcorp\.vn$/.test(em)) {
        setEmpFieldStatus(emInput, emMsg, false, 'Email công ty phải có đuôi @techcorp.vn (VD: nhanvien@techcorp.vn)!');
        hasError = true;
      } else {
        var isEmDup = EXISTING_EMPLOYEES.some(function(e){ return e.email && e.email.toLowerCase() === em; });
        if (isEmDup) {
          setEmpFieldStatus(emInput, emMsg, false, 'Email công ty này đã tồn tại trong hệ thống!');
          hasError = true;
        } else {
          setEmpFieldStatus(emInput, emMsg, true, 'Email hợp lệ');
        }
      }
    } else {
      setEmpFieldStatus(emInput, emMsg, null, '');
    }

    // 3. Check Phone
    if (rawPh.length > 0) {
      if (/\s/.test(rawPh)) {
        setEmpFieldStatus(phInput, phMsg, false, 'Số điện thoại phải viết liền, không được chứa khoảng trắng!');
        hasError = true;
      } else if (!/^0[0-9]{9}$/.test(ph)) {
        setEmpFieldStatus(phInput, phMsg, false, 'Số điện thoại phải gồm đúng 10 chữ số và bắt đầu bằng số 0 (VD: 0912345678)!');
        hasError = true;
      } else {
        var isPhDup = EXISTING_EMPLOYEES.some(function(e){ return e.phone && e.phone === ph; });
        if (isPhDup) {
          setEmpFieldStatus(phInput, phMsg, false, 'Số điện thoại này đã được sử dụng!');
          hasError = true;
        } else {
          setEmpFieldStatus(phInput, phMsg, true, 'Số điện thoại hợp lệ');
        }
      }
    } else {
      setEmpFieldStatus(phInput, phMsg, null, '');
    }

    // 4. Check Date of Birth
    if (rawDob.length > 0) {
      var birth = new Date(rawDob);
      var today = new Date();
      var age = today.getFullYear() - birth.getFullYear();
      var m = today.getMonth() - birth.getMonth();
      if (m < 0 || (m === 0 && today.getDate() < birth.getDate())) {
        age--;
      }
      if (birth > today) {
        setEmpFieldStatus(dobInput, dobMsg, false, 'Ngày sinh không được là ngày trong tương lai!');
        hasError = true;
      } else if (age < 18) {
        setEmpFieldStatus(dobInput, dobMsg, false, 'Nhân viên phải từ đủ 18 tuổi trở lên (Hiện tại: ' + age + ' tuổi)!');
        hasError = true;
      } else {
        setEmpFieldStatus(dobInput, dobMsg, true, 'Ngày sinh hợp lệ (' + age + ' tuổi)');
      }
    } else {
      setEmpFieldStatus(dobInput, dobMsg, null, '');
    }

    if (submitBtn) {
      submitBtn.disabled = hasError;
      submitBtn.style.opacity = hasError ? '0.5' : '1';
      submitBtn.style.cursor = hasError ? 'not-allowed' : 'pointer';
    }
  }

  function validateEditEmpForm() {
    var currId = parseInt(document.getElementById('editEmpUserId').value);
    var rawEm = document.getElementById('editEmpEmail') ? document.getElementById('editEmpEmail').value : '';
    var em = rawEm.trim().toLowerCase();

    var emInput = document.getElementById('editEmpEmail');
    var emMsg   = document.getElementById('editEmpEmailMsg');
    var submitBtn = document.getElementById('editEmpSubmitBtn');

    var hasError = false;

    // Validate Email
    if (rawEm.length > 0) {
      if (/\s/.test(rawEm)) {
        setEmpFieldStatus(emInput, emMsg, false, 'Email phải viết liền, không được chứa khoảng trắng!');
        hasError = true;
      } else if (!/^[a-zA-Z0-9._%+-]+@techcorp\.vn$/.test(em)) {
        setEmpFieldStatus(emInput, emMsg, false, 'Email công ty phải có đuôi @techcorp.vn (VD: nhanvien@techcorp.vn)!');
        hasError = true;
      } else {
        var isEmDup = EXISTING_EMPLOYEES.some(function(e){ return e.id !== currId && e.email.toLowerCase() === em; });
        if (isEmDup) {
          setEmpFieldStatus(emInput, emMsg, false, 'Email công ty này đã được dùng bởi nhân viên khác!');
          hasError = true;
        } else {
          setEmpFieldStatus(emInput, emMsg, true, 'Email hợp lệ');
        }
      }
    } else {
      setEmpFieldStatus(emInput, emMsg, null, '');
    }

    if (submitBtn) {
      submitBtn.disabled = hasError;
      submitBtn.style.opacity = hasError ? '0.5' : '1';
      submitBtn.style.cursor = hasError ? 'not-allowed' : 'pointer';
    }
  }

  const EMP_PAGE_SIZE = 10;
  let currentEmpPage = 1;
  let filteredEmpRows = [];

  function filterTable() {
    var search  = (document.getElementById('searchInput').value || '').toLowerCase().trim();
    var dept    = (document.getElementById('filterDept').value || '').toLowerCase().trim();
    var status  = (document.getElementById('filterStatus').value || '').toLowerCase().trim();

    var allRows = Array.from(document.querySelectorAll('#empTableBody .emp-row'));
    filteredEmpRows = allRows.filter(function(row) {
      var name = (row.dataset.name || '').toLowerCase();
      var code = (row.dataset.code || '').toLowerCase();
      var pos  = (row.dataset.pos  || '').toLowerCase();
      var rowDept = (row.dataset.dept || '').toLowerCase();
      var rowStatus = row.dataset.status || '';

      var matchSearch = !search || name.includes(search) || code.includes(search) || pos.includes(search);
      var matchDept   = !dept   || rowDept === dept;
      var matchStatus = !status || rowStatus === status;

      return matchSearch && matchDept && matchStatus;
    });

    currentEmpPage = 1;
    renderEmpPagination();
  }

  function renderEmpPagination() {
    var allRows = document.querySelectorAll('#empTableBody .emp-row');
    allRows.forEach(function(r) { r.style.display = 'none'; });

    var emptyRow = document.getElementById('empEmptyRow');
    var total = filteredEmpRows.length;

    if (total === 0) {
      if (emptyRow) emptyRow.style.display = '';
    } else {
      if (emptyRow) emptyRow.style.display = 'none';
    }

    var totalPages = Math.ceil(total / EMP_PAGE_SIZE) || 1;
    if (currentEmpPage > totalPages) currentEmpPage = totalPages;
    if (currentEmpPage < 1) currentEmpPage = 1;

    var startIdx = (currentEmpPage - 1) * EMP_PAGE_SIZE;
    var endIdx   = Math.min(startIdx + EMP_PAGE_SIZE, total);

    for (var i = startIdx; i < endIdx; i++) {
      filteredEmpRows[i].style.display = '';
    }

    // Cập nhật thông tin phân trang
    var infoEl = document.getElementById('empPaginationInfo');
    if (infoEl) {
      if (total === 0) {
        infoEl.textContent = 'Không tìm thấy nhân viên nào phù hợp';
      } else {
        infoEl.textContent = 'Hiển thị ' + (startIdx + 1) + ' - ' + endIdx + ' trên tổng số ' + total + ' nhân viên';
      }
    }

    // Vẽ các nút phân trang
    var controlsEl = document.getElementById('empPaginationControls');
    if (!controlsEl) return;
    controlsEl.innerHTML = '';

    if (totalPages <= 1) {
      return;
    }

    // Nút Trước
    var prevBtn = document.createElement('button');
    prevBtn.innerHTML = '&laquo; Trước';
    prevBtn.className = 'page-nav-btn';
    prevBtn.type = 'button';
    prevBtn.disabled = currentEmpPage === 1;
    prevBtn.onclick = function() {
      if (currentEmpPage > 1) {
        currentEmpPage--;
        renderEmpPagination();
      }
    };
    controlsEl.appendChild(prevBtn);

    // Các trang số
    for (var p = 1; p <= totalPages; p++) {
      if (totalPages > 7) {
        if (p !== 1 && p !== totalPages && Math.abs(p - currentEmpPage) > 2) {
          if (p === 2 || p === totalPages - 1) {
            var dots = document.createElement('span');
            dots.textContent = '...';
            dots.style.padding = '0 4px';
            dots.style.color = '#9ca3af';
            controlsEl.appendChild(dots);
          }
          continue;
        }
      }
      var pageBtn = document.createElement('button');
      pageBtn.textContent = p;
      pageBtn.type = 'button';
      pageBtn.className = 'page-num-btn' + (p === currentEmpPage ? ' active' : '');
      pageBtn.onclick = (function(page) {
        return function() {
          currentEmpPage = page;
          renderEmpPagination();
        };
      })(p);
      controlsEl.appendChild(pageBtn);
    }

    // Nút Tiếp
    var nextBtn = document.createElement('button');
    nextBtn.innerHTML = 'Tiếp &raquo;';
    nextBtn.className = 'page-nav-btn';
    nextBtn.type = 'button';
    nextBtn.disabled = currentEmpPage === totalPages;
    nextBtn.onclick = function() {
      if (currentEmpPage < totalPages) {
        currentEmpPage++;
        renderEmpPagination();
      }
    };
    controlsEl.appendChild(nextBtn);
  }

  // Tự động nhận tham số từ URL khi chuyển trang từ màn Phòng ban / Chức vụ
  (function initFromUrl() {
    var params = new URLSearchParams(window.location.search);
    var dept = params.get('dept');
    var pos = params.get('pos');
    var search = params.get('search');

    if (dept) {
      var sel = document.getElementById('filterDept');
      if (sel) {
        for (var i = 0; i < sel.options.length; i++) {
          if (sel.options[i].value.toLowerCase() === dept.toLowerCase()) {
            sel.selectedIndex = i;
            break;
          }
        }
      }
    }
    if (pos) {
      document.getElementById('searchInput').value = pos;
    }
    if (search) {
      document.getElementById('searchInput').value = search;
    }
    filterTable();
  })();

  function openEditEmpModal(btn) {
    var row = btn.closest('tr');
    document.getElementById('editEmpUserId').value = row.dataset.userId;
    document.getElementById('editEmpCodeBadge').textContent = row.dataset.code || 'EMP';
    document.getElementById('editEmpNameDisplay').textContent = row.dataset.name || '';
    var initial = (row.dataset.name || 'E').trim().charAt(0).toUpperCase();
    var avatarEl = document.getElementById('editEmpAvatar');
    if (avatarEl) avatarEl.textContent = initial;

    document.getElementById('editEmpEmail').value = row.dataset.email;
    document.getElementById('editEmpDept').value  = row.dataset.deptId || '';
    document.getElementById('editEmpPos').value   = row.dataset.posId || '';

    setEmpFieldStatus(document.getElementById('editEmpEmail'), document.getElementById('editEmpEmailMsg'), null, '');
    document.getElementById('editEmpSubmitBtn').disabled = false;
    document.getElementById('editEmpSubmitBtn').style.opacity = '1';
    document.getElementById('editEmpSubmitBtn').style.cursor = 'pointer';

    var modal = document.getElementById('editEmpModal');
    modal.style.display = 'flex';
  }

  function closeEditEmpModal() {
    document.getElementById('editEmpModal').style.display = 'none';
  }

  // Đóng modal khi click ra ngoài
  document.getElementById('addEmpModal').addEventListener('click', function(e) {
    if (e.target === this) closeAddEmpModal();
  });
  document.getElementById('editEmpModal').addEventListener('click', function(e) {
    if (e.target === this) closeEditEmpModal();
  });
  document.getElementById('viewEmpModal').addEventListener('click', function(e) {
    if (e.target === this) closeViewEmpModal();
  });

  function openViewEmpModal(btn) {
    var row = btn.closest('tr');
    var name = row.dataset.name;
    document.getElementById('viewEmpCode').textContent   = row.dataset.code;
    document.getElementById('viewEmpName').textContent   = name;
    document.getElementById('viewEmpDob').textContent    = row.dataset.dob    || '—';
    document.getElementById('viewEmpGender').textContent = row.dataset.gender || '—';
    document.getElementById('viewEmpPhone').textContent  = row.dataset.phone  || '—';
    document.getElementById('viewEmpEmail').textContent  = row.dataset.email  || '—';
    document.getElementById('viewEmpDept').textContent   = row.dataset.dept   || '—';
    document.getElementById('viewEmpPos').textContent    = row.dataset.pos    || '—';
    document.getElementById('viewEmpModal').style.display = 'flex';
  }

  function closeViewEmpModal() {
    document.getElementById('viewEmpModal').style.display = 'none';
  }

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
