<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    List<Map<String, Object>> departmentsList = (List<Map<String, Object>>) request.getAttribute("departmentsList");
    List<Map<String, Object>> headCandidatesList = (List<Map<String, Object>>) request.getAttribute("headCandidatesList");
    Map<Integer, List<Map<String, Object>>> deptEmployeesMap = (Map<Integer, List<Map<String, Object>>>) request.getAttribute("deptEmployeesMap");
    String fullName = (String) request.getAttribute("fullName");
    String deptName = (String) request.getAttribute("deptName");
    Integer totalDepts = (Integer) request.getAttribute("totalDepts");
    Integer assignedHeadCount = (Integer) request.getAttribute("assignedHeadCount");
    if (totalDepts == null) totalDepts = departmentsList != null ? departmentsList.size() : 0;
    if (assignedHeadCount == null) assignedHeadCount = 0;
    String successMsg = (String) request.getAttribute("successMsg");
    String errorMsg = (String) request.getAttribute("errorMsg");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>EMS – Quản lý phòng ban</title>
  <link rel="stylesheet" href="css/ems.css"/>
  <link rel="stylesheet" href="css/users.css"/>
  <link rel="stylesheet" href="css/departments.css"/>
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
    <a href="home" class="nav-link">Trang chủ</a>
    <div class="nav-section-label">Quản trị</div>
    <a href="users"       class="nav-link">Tài khoản</a>
    <a href="employees"   class="nav-link">Nhân viên</a>
    <a href="departments" class="nav-link active">Phòng ban</a>
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
    <span class="topbar-left">Quản lý phòng ban</span>
    <span class="topbar-right" id="topbar-date"></span>
  </div>

  <div class="page-body">
    <% if (successMsg != null && !successMsg.isEmpty()) { %>
      <div class="flash-alert" style="background: #ecfdf5; border: 1px solid #a7f3d0; color: #065f46; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; font-size: 13.5px; display: flex; align-items: center; gap: 8px;">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#059669" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        <span><%= successMsg %></span>
      </div>
    <% } %>
    <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
      <div class="flash-alert" style="background: #fef2f2; border: 1px solid #fecaca; color: #991b1b; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; font-size: 13.5px; display: flex; align-items: center; gap: 8px;">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#dc2626" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
        <span><%= errorMsg %></span>
      </div>
    <% } %>

    <!-- Page Header -->
    <div class="page-header" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
      <div>
        <h1 style="font-size: 24px; font-weight: 700; color: #111827; margin-bottom: 4px;">Quản lý phòng ban</h1>
        <p style="font-size: 14px; color: #4b5563;">Danh sách các phòng ban và cơ cấu nhân sự trong công ty</p>
      </div>
      <button class="btn-add-acc" onclick="openAddModal()">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
        Thêm phòng ban
      </button>
    </div>

    <!-- Stats Section -->
    <div class="stats-row" style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; margin-bottom: 24px;">
      <div class="stat-card" style="border-left: 4px solid #3b82f6;">
        <div class="stat-label">TỔNG PHÒNG BAN</div>
        <div class="stat-value"><%= totalDepts %></div>
      </div>
      <div class="stat-card" style="border-left: 4px solid #10b981;">
        <div class="stat-label">ĐÃ CÓ TRƯỞNG PHÒNG</div>
        <div class="stat-value"><%= assignedHeadCount %></div>
      </div>
    </div>

    <!-- Main Card -->
    <div class="card">
      <div class="card-header">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#0d9488" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="2" width="16" height="20" rx="2" ry="2"></rect><line x1="9" y1="22" x2="9" y2="22.01"></line><line x1="15" y1="22" x2="15" y2="22.01"></line><line x1="9" y1="6" x2="9" y2="6.01"></line><line x1="15" y1="6" x2="15" y2="6.01"></line><line x1="9" y1="10" x2="9" y2="10.01"></line><line x1="15" y1="10" x2="15" y2="10.01"></line><line x1="9" y1="14" x2="9" y2="14.01"></line><line x1="15" y1="14" x2="15" y2="14.01"></line><line x1="9" y1="18" x2="9" y2="18.01"></line><line x1="15" y1="18" x2="15" y2="18.01"></line></svg>
        <span>Danh sách phòng ban</span>
      </div>

      <!-- Filter / Search Bar -->
      <div class="filter-bar">
        <input type="text" id="searchInput" placeholder="Tìm kiếm theo mã, tên phòng hoặc trưởng phòng..." oninput="filterTable()"/>
      </div>

      <!-- Table -->
      <div style="overflow-x: auto;">
        <table style="width: 100%; border-collapse: collapse; text-align: left; font-size: 13.5px;" id="deptTable">
          <thead>
            <tr style="border-bottom: 1.5px solid #f3f4f6; color: #6b7280; text-transform: uppercase; font-size: 11px; font-weight: 700; letter-spacing: 0.5px;">
              <th style="padding: 14px 16px;">Mã phòng</th>
              <th style="padding: 14px 16px;">Tên phòng ban</th>
              <th style="padding: 14px 16px;">Trưởng phòng</th>
              <th style="padding: 14px 16px;">Số nhân sự</th>
              <th style="padding: 14px 16px;">Thao tác</th>
            </tr>
          </thead>
          <tbody>
            <%
              if (departmentsList != null && !departmentsList.isEmpty()) {
                for (Map<String, Object> dept : departmentsList) {
                  int id = (Integer) dept.get("id");
                  String code = (String) dept.get("code");
                  String name = (String) dept.get("name");
                  Integer headId = (Integer) dept.get("headAccountId");
                  String headName = (String) dept.get("headName");
                  int totalEmp = (Integer) dept.get("totalEmployees");
            %>
            <tr class="dept-row" data-code="<%= code != null ? code.toLowerCase() : "" %>" data-name="<%= name != null ? name.toLowerCase() : "" %>" data-head="<%= headName != null ? headName.toLowerCase() : "" %>" style="border-bottom: 1px solid #f3f4f6; transition: background 0.1s;" onmouseover="this.style.background='#f9fafb'" onmouseout="this.style.background='transparent'">
              <td style="padding: 12px 16px;">
                <span class="dept-code-tag"><%= code != null ? code : "" %></span>
              </td>
              <td style="padding: 12px 16px; font-weight: 600; color: #111827;">
                <%= name != null ? name : "" %>
              </td>
              <td style="padding: 12px 16px;">
                <% if (headName != null && !headName.isEmpty()) { %>
                  <span style="font-weight: 500; color: #111827;"><%= headName %></span>
                <% } else { %>
                  <span class="badge-unassigned">Chưa bổ nhiệm</span>
                <% } %>
              </td>
              <td style="padding: 12px 16px;">
                <a href="employees?dept=<%= java.net.URLEncoder.encode(name != null ? name : "", "UTF-8") %>" style="text-decoration: none;" title="Xem danh sách nhân viên phòng <%= name %>">
                  <span class="badge-headcount <%= totalEmp == 0 ? "empty" : "" %>" style="cursor: pointer;">
                    <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                    <%= totalEmp %> nhân sự
                  </span>
                </a>
              </td>
              <td style="padding: 12px 16px;">
                <a href="javascript:void(0)" onclick="openEditModal(<%= id %>, '<%= code %>', '<%= name %>', <%= headId != null ? headId : "''" %>)" style="color: #0d9488; text-decoration: none; font-weight: 600; margin-right: 12px;">Sửa</a>
                <a href="javascript:void(0)" onclick="openDeleteModal(<%= id %>, '<%= name %>', <%= totalEmp %>)" style="color: #dc2626; text-decoration: none; font-weight: 600;">Xóa</a>
              </td>
            </tr>
            <%
                }
              } else {
            %>
            <tr>
              <td colspan="5" style="text-align: center; color: #9ca3af; padding: 40px;">
                Chưa có phòng ban nào trong hệ thống
              </td>
            </tr>
            <% } %>
          </tbody>
        </table>
      </div>
    </div>

  </div>
</div>

<!-- ==========================================
     MODAL 1: THÊM PHÒNG BAN MỚI
     ========================================== -->
<div class="modal-backdrop" id="addModal">
  <div class="modal-content">
    <div class="modal-header">
      <div class="modal-title">Thêm phòng ban mới</div>
      <button class="modal-close" onclick="closeAddModal()">&times;</button>
    </div>
    <form action="departments" method="post">
      <input type="hidden" name="action" value="create"/>
      <div class="modal-body">
        <div class="form-group">
          <label class="form-label">Mã phòng ban <span style="color:red;">*</span></label>
          <input type="text" name="code" id="addDeptCode" class="form-input" placeholder="Ví dụ: MKT, IT, HR, ACC..." required oninput="validateAddDeptForm()"/>
          <div id="addDeptCodeMsg" style="font-size: 12px; margin-top: 4px;"></div>
        </div>
        <div class="form-group">
          <label class="form-label">Tên phòng ban <span style="color:red;">*</span></label>
          <input type="text" name="name" id="addDeptName" class="form-input" placeholder="Ví dụ: Phòng Marketing, Phòng Kỹ thuật..." required oninput="validateAddDeptForm()"/>
          <div id="addDeptNameMsg" style="font-size: 12px; margin-top: 4px;"></div>
        </div>
        <div class="form-group">
          <label class="form-label">Bổ nhiệm Trưởng phòng</label>
          <select name="headAccountId" class="form-input" disabled style="background:#f3f4f6; color:#6b7280; cursor:not-allowed;">
            <option value="">-- Chưa bổ nhiệm (Phòng ban mới chưa có nhân viên) --</option>
          </select>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn-secondary" onclick="closeAddModal()">Hủy</button>
        <button type="submit" id="addDeptSubmitBtn" class="btn-primary">Thêm phòng ban</button>
      </div>
    </form>
  </div>
</div>

<!-- ==========================================
     MODAL 2: CHỈNH SỬA PHÒNG BAN
     ========================================== -->
<div class="modal-backdrop" id="editModal">
  <div class="modal-content">
    <div class="modal-header">
      <div class="modal-title">Chỉnh sửa phòng ban</div>
      <button class="modal-close" onclick="closeEditModal()">&times;</button>
    </div>
    <form action="departments" method="post">
      <input type="hidden" name="action" value="update"/>
      <input type="hidden" name="id" id="editDeptId"/>
      <div class="modal-body">
        <div class="form-group">
          <label class="form-label">Mã phòng ban</label>
          <input type="text" id="editDeptCode" class="form-input" readonly style="background: #f3f4f6; cursor: not-allowed;"/>
        </div>
        <div class="form-group">
          <label class="form-label">Tên phòng ban <span style="color:red;">*</span></label>
          <input type="text" name="name" id="editDeptName" class="form-input" required oninput="validateEditDeptForm()"/>
          <div id="editDeptNameMsg" style="font-size: 12px; margin-top: 4px;"></div>
        </div>
        <div class="form-group">
          <label class="form-label">Trưởng phòng</label>
          <select name="headAccountId" id="editHeadAccountId" class="form-input">
            <option value="">-- Chưa bổ nhiệm --</option>
          </select>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn-secondary" onclick="closeEditModal()">Hủy</button>
        <button type="submit" id="editDeptSubmitBtn" class="btn-primary">Lưu thay đổi</button>
      </div>
    </form>
  </div>
</div>

<!-- ==========================================
     MODAL 3: XÁC NHẬN XÓA PHÒNG BAN
     ========================================== -->
<div class="modal-backdrop" id="deleteModal">
  <div class="modal-content">
    <div class="modal-header">
      <div class="modal-title">Xác nhận xóa phòng ban</div>
      <button class="modal-close" onclick="closeDeleteModal()">&times;</button>
    </div>
    <form action="departments" method="post" id="deleteForm">
      <input type="hidden" name="action" value="delete"/>
      <input type="hidden" name="id" id="deleteDeptId"/>
      <div class="modal-body">
        <p id="deleteMessage" style="font-size: 14px; color: #374151; line-height: 1.5;"></p>
        <div id="deleteWarning" style="display: none; background: #fef2f2; border: 1px solid #fecaca; color: #991b1b; padding: 12px; border-radius: 6px; font-size: 13px; margin-top: 12px;">
          <strong>Cảnh báo:</strong> Phòng ban này hiện đang có nhân viên trực thuộc. Bạn không thể xóa cho đến khi chuyển hết nhân sự sang phòng ban khác!
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn-secondary" onclick="closeDeleteModal()">Đóng</button>
        <button type="submit" class="btn-primary" id="btnConfirmDelete" style="background: #dc2626;">Xóa phòng ban</button>
      </div>
    </form>
  </div>
</div>

<script>
  // Dữ liệu danh sách ứng viên Trưởng phòng (kèm mã phòng ban để lọc đúng phòng ban)
  const ALL_HEAD_CANDIDATES = [
    <%
      if (headCandidatesList != null) {
        boolean firstH = true;
        for (Map<String, Object> h : headCandidatesList) {
          if (!firstH) out.print(",");
          firstH = false;
          Integer accId = (Integer) h.get("accountId");
          String hName = (String) h.get("fullName");
          String hCode = (String) h.get("employeeCode");
          Object dIdObj = h.get("departmentId");
          Integer dId = dIdObj != null ? ((Number) dIdObj).intValue() : null;
          out.print("{accountId:" + accId + ",fullName:'" + (hName != null ? hName.replace("'", "\\'") : "") + "',employeeCode:'" + (hCode != null ? hCode.replace("'", "\\'") : "") + "',deptId:" + (dId != null ? dId : "null") + "}");
        }
      }
    %>
  ];

  // Dữ liệu phòng ban để kiểm tra thời gian thực
  const EXISTING_DEPTS = [
    <%
      if (departmentsList != null) {
        boolean firstD = true;
        for (Map<String, Object> d : departmentsList) {
          if (!firstD) out.print(",");
          firstD = false;
          Integer dId = (Integer) d.get("id");
          String dCode = (String) d.get("code");
          String dName = (String) d.get("name");
          out.print("{id:" + dId + ",code:'" + (dCode != null ? dCode.replace("'", "\\'") : "") + "',name:'" + (dName != null ? dName.replace("'", "\\'") : "") + "'}");
        }
      }
    %>
  ];

  // Topbar date
  (function() {
    var now = new Date();
    var p = function(n){ return String(n).padStart(2,'0'); };
    document.getElementById('topbar-date').textContent =
      p(now.getDate())+'/'+p(now.getMonth()+1)+'/'+now.getFullYear();
  })();

  function setDeptFieldStatus(inputEl, msgEl, isValid, message) {
    if (isValid === true) {
      inputEl.style.borderColor = "#10b981";
      msgEl.innerHTML = '<span style="color: #059669; font-weight: 500;">✓ ' + message + '</span>';
    } else if (isValid === false) {
      inputEl.style.borderColor = "#dc2626";
      msgEl.innerHTML = '<span style="color: #dc2626; font-weight: 500;">' + message + '</span>';
    } else {
      inputEl.style.borderColor = "";
      msgEl.innerHTML = "";
    }
  }

  function validateAddDeptForm() {
    var code = (document.getElementById('addDeptCode').value || '').trim().toUpperCase();
    var name = (document.getElementById('addDeptName').value || '').trim().toLowerCase();

    var codeInput = document.getElementById('addDeptCode');
    var codeMsg   = document.getElementById('addDeptCodeMsg');
    var nameInput = document.getElementById('addDeptName');
    var nameMsg   = document.getElementById('addDeptNameMsg');
    var submitBtn = document.getElementById('addDeptSubmitBtn');

    var hasError = false;

    // 1. Check Code
    if (code.length > 0) {
      var isCodeDup = EXISTING_DEPTS.some(function(d){ return d.code.toUpperCase() === code; });
      if (isCodeDup) {
        setDeptFieldStatus(codeInput, codeMsg, false, 'Mã phòng ban này đã tồn tại!');
        hasError = true;
      } else {
        setDeptFieldStatus(codeInput, codeMsg, true, 'Mã phòng ban hợp lệ');
      }
    } else {
      setDeptFieldStatus(codeInput, codeMsg, null, '');
    }

    // 2. Check Name
    if (name.length > 0) {
      var isNameDup = EXISTING_DEPTS.some(function(d){ return d.name.toLowerCase() === name; });
      if (isNameDup) {
        setDeptFieldStatus(nameInput, nameMsg, false, 'Tên phòng ban này đã tồn tại!');
        hasError = true;
      } else {
        setDeptFieldStatus(nameInput, nameMsg, true, 'Tên phòng ban hợp lệ');
      }
    } else {
      setDeptFieldStatus(nameInput, nameMsg, null, '');
    }

    submitBtn.disabled = hasError;
    submitBtn.style.opacity = hasError ? '0.5' : '1';
    submitBtn.style.cursor = hasError ? 'not-allowed' : 'pointer';
  }

  function validateEditDeptForm() {
    var currId = parseInt(document.getElementById('editDeptId').value);
    var name = (document.getElementById('editDeptName').value || '').trim().toLowerCase();

    var nameInput = document.getElementById('editDeptName');
    var nameMsg   = document.getElementById('editDeptNameMsg');
    var submitBtn = document.getElementById('editDeptSubmitBtn');

    var hasError = false;

    if (name.length > 0) {
      var isNameDup = EXISTING_DEPTS.some(function(d){ return d.id !== currId && d.name.toLowerCase() === name; });
      if (isNameDup) {
        setDeptFieldStatus(nameInput, nameMsg, false, 'Tên phòng ban này đã tồn tại!');
        hasError = true;
      } else {
        setDeptFieldStatus(nameInput, nameMsg, true, 'Tên phòng ban hợp lệ');
      }
    } else {
      setDeptFieldStatus(nameInput, nameMsg, null, '');
    }

    submitBtn.disabled = hasError;
    submitBtn.style.opacity = hasError ? '0.5' : '1';
    submitBtn.style.cursor = hasError ? 'not-allowed' : 'pointer';
  }

  // Filter Table Search
  function filterTable() {
    var query = document.getElementById('searchInput').value.toLowerCase().trim();
    var rows = document.querySelectorAll('#deptTable tbody tr.dept-row');
    rows.forEach(function(row) {
      var code = row.getAttribute('data-code') || '';
      var name = row.getAttribute('data-name') || '';
      var head = row.getAttribute('data-head') || '';
      if (code.indexOf(query) !== -1 || name.indexOf(query) !== -1 || head.indexOf(query) !== -1) {
        row.style.display = '';
      } else {
        row.style.display = 'none';
      }
    });
  }

  // Modal Add
  function openAddModal() {
    document.getElementById('addDeptCode').value = '';
    document.getElementById('addDeptName').value = '';
    setDeptFieldStatus(document.getElementById('addDeptCode'), document.getElementById('addDeptCodeMsg'), null, '');
    setDeptFieldStatus(document.getElementById('addDeptName'), document.getElementById('addDeptNameMsg'), null, '');
    document.getElementById('addDeptSubmitBtn').disabled = false;
    document.getElementById('addDeptSubmitBtn').style.opacity = '1';
    document.getElementById('addDeptSubmitBtn').style.cursor = 'pointer';
    document.getElementById('addModal').style.display = 'flex';
  }
  function closeAddModal() {
    document.getElementById('addModal').style.display = 'none';
  }

  // Modal Edit (Chỉ hiển thị nhân viên thuộc đúng phòng ban này vào dropdown Trưởng phòng)
  function openEditModal(id, code, name, headId) {
    document.getElementById('editDeptId').value = id;
    document.getElementById('editDeptCode').value = code;
    document.getElementById('editDeptName').value = name;

    // Lọc danh sách nhân viên chỉ thuộc đúng phòng ban đang sửa
    var selectHead = document.getElementById('editHeadAccountId');
    selectHead.innerHTML = '<option value="">-- Chưa bổ nhiệm --</option>';

    var matchingEmployees = ALL_HEAD_CANDIDATES.filter(function(emp) {
      return emp.deptId === id;
    });

    if (matchingEmployees.length === 0) {
      var opt = document.createElement('option');
      opt.value = "";
      opt.disabled = true;
      opt.textContent = "(Phòng ban này chưa có nhân sự trực thuộc)";
      selectHead.appendChild(opt);
    } else {
      matchingEmployees.forEach(function(emp) {
        var opt = document.createElement('option');
        opt.value = emp.accountId;
        opt.textContent = emp.fullName + ' (' + emp.employeeCode + ')';
        if (headId && String(emp.accountId) === String(headId)) {
          opt.selected = true;
        }
        selectHead.appendChild(opt);
      });
    }

    if (headId) {
      selectHead.value = headId;
    }

    setDeptFieldStatus(document.getElementById('editDeptName'), document.getElementById('editDeptNameMsg'), null, '');
    document.getElementById('editDeptSubmitBtn').disabled = false;
    document.getElementById('editDeptSubmitBtn').style.opacity = '1';
    document.getElementById('editDeptSubmitBtn').style.cursor = 'pointer';

    document.getElementById('editModal').style.display = 'flex';
  }
  function closeEditModal() {
    document.getElementById('editModal').style.display = 'none';
  }

  // Modal Delete
  function openDeleteModal(id, name, totalEmp) {
    document.getElementById('deleteDeptId').value = id;
    var msg = document.getElementById('deleteMessage');
    var warning = document.getElementById('deleteWarning');
    var btnDelete = document.getElementById('btnConfirmDelete');

    if (totalEmp > 0) {
      msg.innerHTML = 'Bạn đang muốn xóa phòng ban <strong>' + name + '</strong>.';
      warning.style.display = 'block';
      btnDelete.style.display = 'none';
    } else {
      msg.innerHTML = 'Bạn có chắc chắn muốn xóa phòng ban <strong>' + name + '</strong>? Thao tác này không thể hoàn tác.';
      warning.style.display = 'none';
      btnDelete.style.display = 'inline-block';
    }
    document.getElementById('deleteModal').style.display = 'flex';
  }
  function closeDeleteModal() {
    document.getElementById('deleteModal').style.display = 'none';
  }

  // Click outside to close modals
  window.onclick = function(event) {
    var addM = document.getElementById('addModal');
    var editM = document.getElementById('editModal');
    var delM = document.getElementById('deleteModal');
    if (event.target === addM) addM.style.display = 'none';
    if (event.target === editM) editM.style.display = 'none';
    if (event.target === delM) delM.style.display = 'none';
  };

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
