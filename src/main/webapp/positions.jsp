<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    List<Map<String, Object>> positionsList = (List<Map<String, Object>>) request.getAttribute("positionsList");
    Map<Integer, List<Map<String, Object>>> posEmployeesMap = (Map<Integer, List<Map<String, Object>>>) request.getAttribute("posEmployeesMap");
    String fullName = (String) request.getAttribute("fullName");
    String deptName = (String) request.getAttribute("deptName");
    Integer totalPositions = (Integer) request.getAttribute("totalPositions");
    Integer assignedPositions = (Integer) request.getAttribute("assignedPositions");
    String successMsg = (String) request.getAttribute("successMsg");
    String errorMsg = (String) request.getAttribute("errorMsg");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>EMS – Quản lý chức vụ</title>
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
    <a href="departments" class="nav-link">Phòng ban</a>
    <a href="positions"   class="nav-link active">Chức vụ</a>
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
    <span class="topbar-left">Quản lý chức vụ</span>
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
        <h1 style="font-size: 24px; font-weight: 700; color: #111827; margin-bottom: 4px;">Quản lý chức vụ</h1>
        <p style="font-size: 14px; color: #4b5563;">Danh sách các chức danh nghề nghiệp và phân cấp chuyên môn trong công ty</p>
      </div>
      <button class="btn-add-acc" onclick="openAddModal()">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
        Thêm chức vụ
      </button>
    </div>

    <!-- Stats Section -->
    <div class="stats-row" style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; margin-bottom: 24px;">
      <div class="stat-card" style="border-left: 4px solid #3b82f6;">
        <div class="stat-label">TỔNG CHỨC VỤ</div>
        <div class="stat-value"><%= totalPositions %></div>
      </div>
      <div class="stat-card" style="border-left: 4px solid #10b981;">
        <div class="stat-label">ĐÃ CÓ NHÂN SỰ</div>
        <div class="stat-value"><%= assignedPositions %></div>
      </div>
    </div>

    <!-- Level Guide / Chú thích Cấp bậc -->
    <div style="background: #fff; border: 1px solid #e5e7eb; border-radius: 10px; padding: 14px 18px; margin-bottom: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.04);">
      <div style="font-size: 13px; font-weight: 700; color: #374151; margin-bottom: 10px; display: flex; align-items: center; gap: 6px;">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#0d9488" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
        Cấp bậc chức vụ (Job Level):
      </div>
      <div style="display: flex; gap: 10px; flex-wrap: wrap; font-size: 12.5px;">
        <span style="background: #f0fdf4; border: 1px solid #bbf7d0; color: #166534; padding: 4px 10px; border-radius: 6px; font-weight: 500;">
          <strong>Level 1:</strong> Thực tập / Junior
        </span>
        <span style="background: #ecfeff; border: 1px solid #a5f3fc; color: #155e75; padding: 4px 10px; border-radius: 6px; font-weight: 500;">
          <strong>Level 2:</strong> Nhân viên chính thức / Middle
        </span>
        <span style="background: #fefce8; border: 1px solid #fef08a; color: #854d0e; padding: 4px 10px; border-radius: 6px; font-weight: 500;">
          <strong>Level 3:</strong> Chuyên viên / Senior
        </span>
        <span style="background: #faf5ff; border: 1px solid #e9d5ff; color: #6b21a8; padding: 4px 10px; border-radius: 6px; font-weight: 500;">
          <strong>Level 4:</strong> Trưởng nhóm / Quản lý / Lead
        </span>
        <span style="background: #fef2f2; border: 1px solid #fecaca; color: #991b1b; padding: 4px 10px; border-radius: 6px; font-weight: 500;">
          <strong>Level 5:</strong> Ban Giám đốc / Tổng giám đốc
        </span>
      </div>
    </div>

    <!-- Main Card -->
    <div class="card">
      <div class="card-header">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#0d9488" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path></svg>
        <span>Danh sách chức vụ</span>
      </div>

      <!-- Filter / Search Bar -->
      <div class="filter-bar">
        <input type="text" id="searchInput" placeholder="Tìm kiếm theo mã hoặc tên chức vụ..." oninput="filterTable()"/>
      </div>

      <!-- Table -->
      <div style="overflow-x: auto;">
        <table style="width: 100%; border-collapse: collapse; text-align: left; font-size: 13.5px;" id="posTable">
          <thead>
            <tr style="border-bottom: 1.5px solid #f3f4f6; color: #6b7280; text-transform: uppercase; font-size: 11px; font-weight: 700; letter-spacing: 0.5px;">
              <th style="padding: 14px 16px;">Mã CV</th>
              <th style="padding: 14px 16px;">Tên chức vụ</th>
              <th style="padding: 14px 16px;">Cấp bậc</th>
              <th style="padding: 14px 16px;">Số nhân sự</th>
              <th style="padding: 14px 16px;">Thao tác</th>
            </tr>
          </thead>
          <tbody>
            <%
              if (positionsList != null && !positionsList.isEmpty()) {
                for (Map<String, Object> pos : positionsList) {
                  int id = (Integer) pos.get("id");
                  String code = (String) pos.get("code");
                  String name = (String) pos.get("name");
                  int jobLevel = (Integer) pos.get("jobLevel");
                  int totalEmp = (Integer) pos.get("totalEmployees");

            %>
            <tr class="pos-row" data-code="<%= code != null ? code.toLowerCase() : "" %>" data-name="<%= name != null ? name.toLowerCase() : "" %>" style="border-bottom: 1px solid #f3f4f6; transition: background 0.1s;" onmouseover="this.style.background='#f9fafb'" onmouseout="this.style.background='transparent'">
              <td style="padding: 12px 16px;">
                <span class="dept-code-tag"><%= code != null ? code : "" %></span>
              </td>
              <td style="padding: 12px 16px; font-weight: 600; color: #111827;">
                <%= name != null ? name : "" %>
              </td>
              <td style="padding: 12px 16px;">
                <span class="badge-role">Level <%= jobLevel %></span>
              </td>
              <td style="padding: 12px 16px;">
                <a href="employees?pos=<%= java.net.URLEncoder.encode(name != null ? name : "", "UTF-8") %>" style="text-decoration: none;" title="Xem danh sách nhân viên giữ chức vụ <%= name %>">
                  <span class="badge-headcount <%= totalEmp == 0 ? "empty" : "" %>" style="cursor: pointer;">
                    <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                    <%= totalEmp %> nhân sự
                  </span>
                </a>
              </td>
              <td style="padding: 12px 16px;">
                <a href="javascript:void(0)" onclick="openEditModal(<%= id %>, '<%= code %>', '<%= name %>', <%= jobLevel %>)" style="color: #0d9488; text-decoration: none; font-weight: 600;">Sửa</a>
              </td>
            </tr>
            <%
                }
              } else {
            %>
            <tr>
              <td colspan="5" style="text-align: center; color: #9ca3af; padding: 40px;">
                Chưa có chức vụ nào trong hệ thống
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
     MODAL 1: THÊM CHỨC VỤ MỚI
     ========================================== -->
<div class="modal-backdrop" id="addModal">
  <div class="modal-content">
    <div class="modal-header">
      <div class="modal-title">Thêm chức vụ mới</div>
      <button class="modal-close" onclick="closeAddModal()">&times;</button>
    </div>
    <form action="positions" method="post">
      <input type="hidden" name="action" value="create"/>
      <div class="modal-body">
        <div class="form-group">
          <label class="form-label">Mã chức vụ <span style="color:red;">*</span></label>
          <input type="text" name="code" id="addPosCode" class="form-input" placeholder="Ví dụ: DEV, TEST, ACC, HR_SPEC..." required oninput="validateAddPosForm()"/>
          <div id="addPosCodeMsg" style="font-size: 12px; margin-top: 4px;"></div>
        </div>
        <div class="form-group">
          <label class="form-label">Tên chức vụ <span style="color:red;">*</span></label>
          <input type="text" name="name" id="addPosName" class="form-input" placeholder="Ví dụ: Lập trình viên, Kế toán viên..." required oninput="validateAddPosForm()"/>
          <div id="addPosNameMsg" style="font-size: 12px; margin-top: 4px;"></div>
        </div>
        <div class="form-group">
          <label class="form-label">Cấp bậc (Job Level) <span style="color:red;">*</span></label>
          <select name="jobLevel" class="form-input" required>
            <option value="1">Level 1 - Thực tập / Junior</option>
            <option value="2" selected>Level 2 - Nhân viên chính thức / Middle</option>
            <option value="3">Level 3 - Chuyên viên / Senior</option>
            <option value="4">Level 4 - Trưởng nhóm / Quản lý / Lead</option>
            <option value="5">Level 5 - Ban Giám đốc / Tổng giám đốc</option>
          </select>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn-secondary" onclick="closeAddModal()">Hủy</button>
        <button type="submit" id="addPosSubmitBtn" class="btn-primary">Thêm mới</button>
      </div>
    </form>
  </div>
</div>

<!-- ==========================================
     MODAL 2: SỬA CHỨC VỤ
     ========================================== -->
<div class="modal-backdrop" id="editModal">
  <div class="modal-content">
    <div class="modal-header">
      <div class="modal-title">Chỉnh sửa chức vụ</div>
      <button class="modal-close" onclick="closeEditModal()">&times;</button>
    </div>
    <form action="positions" method="post">
      <input type="hidden" name="action" value="update"/>
      <input type="hidden" name="id" id="editPosId"/>
      <div class="modal-body">
        <div class="form-group">
          <label class="form-label">Mã chức vụ</label>
          <input type="text" id="editPosCode" class="form-input" readonly style="background:#f3f4f6; color:#6b7280; cursor:not-allowed;"/>
        </div>
        <div class="form-group">
          <label class="form-label">Tên chức vụ <span style="color:red;">*</span></label>
          <input type="text" name="name" id="editPosName" class="form-input" required oninput="validateEditPosForm()"/>
          <div id="editPosNameMsg" style="font-size: 12px; margin-top: 4px;"></div>
        </div>
        <div class="form-group">
          <label class="form-label">Cấp bậc (Job Level) <span style="color:red;">*</span></label>
          <select name="jobLevel" id="editPosLevel" class="form-input" required>
            <option value="1">Level 1 - Thực tập / Junior</option>
            <option value="2">Level 2 - Nhân viên chính thức / Middle</option>
            <option value="3">Level 3 - Chuyên viên / Senior</option>
            <option value="4">Level 4 - Trưởng nhóm / Quản lý / Lead</option>
            <option value="5">Level 5 - Ban Giám đốc / Tổng giám đốc</option>
          </select>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn-secondary" onclick="closeEditModal()">Hủy</button>
        <button type="submit" id="editPosSubmitBtn" class="btn-primary">Lưu thay đổi</button>
      </div>
    </form>
  </div>
</div>

<script>
  // Dữ liệu chức vụ để kiểm tra thời gian thực
  const EXISTING_POSITIONS = [
    <%
      if (positionsList != null) {
        boolean firstP = true;
        for (Map<String, Object> p : positionsList) {
          if (!firstP) out.print(",");
          firstP = false;
          Integer pId = (Integer) p.get("id");
          String pCode = (String) p.get("code");
          String pName = (String) p.get("name");
          out.print("{id:" + pId + ",code:'" + (pCode != null ? pCode.replace("'", "\\'") : "") + "',name:'" + (pName != null ? pName.replace("'", "\\'") : "") + "'}");
        }
      }
    %>
  ];

  // Cập nhật ngày tháng trên Topbar
  (function updateDate() {
    const d = new Date();
    const str = String(d.getDate()).padStart(2,'0') + '/' +
                String(d.getMonth()+1).padStart(2,'0') + '/' +
                d.getFullYear();
    const el = document.getElementById('topbar-date');
    if (el) el.textContent = str;
  })();

  function setPosFieldStatus(inputEl, msgEl, isValid, message) {
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

  function validateAddPosForm() {
    const code = (document.getElementById('addPosCode').value || '').trim().toUpperCase();
    const name = (document.getElementById('addPosName').value || '').trim().toLowerCase();

    const codeInput = document.getElementById('addPosCode');
    const codeMsg   = document.getElementById('addPosCodeMsg');
    const nameInput = document.getElementById('addPosName');
    const nameMsg   = document.getElementById('addPosNameMsg');
    const submitBtn = document.getElementById('addPosSubmitBtn');

    let hasError = false;

    // 1. Check Code
    if (code.length > 0) {
      const isCodeDup = EXISTING_POSITIONS.some(p => p.code.toUpperCase() === code);
      if (isCodeDup) {
        setPosFieldStatus(codeInput, codeMsg, false, 'Mã chức vụ này đã tồn tại!');
        hasError = true;
      } else {
        setPosFieldStatus(codeInput, codeMsg, true, 'Mã chức vụ hợp lệ');
      }
    } else {
      setPosFieldStatus(codeInput, codeMsg, null, '');
    }

    // 2. Check Name
    if (name.length > 0) {
      const isNameDup = EXISTING_POSITIONS.some(p => p.name.toLowerCase() === name);
      if (isNameDup) {
        setPosFieldStatus(nameInput, nameMsg, false, 'Tên chức vụ này đã tồn tại!');
        hasError = true;
      } else {
        setPosFieldStatus(nameInput, nameMsg, true, 'Tên chức vụ hợp lệ');
      }
    } else {
      setPosFieldStatus(nameInput, nameMsg, null, '');
    }

    submitBtn.disabled = hasError;
    submitBtn.style.opacity = hasError ? '0.5' : '1';
    submitBtn.style.cursor = hasError ? 'not-allowed' : 'pointer';
  }

  function validateEditPosForm() {
    const currId = parseInt(document.getElementById('editPosId').value);
    const name = (document.getElementById('editPosName').value || '').trim().toLowerCase();

    const nameInput = document.getElementById('editPosName');
    const nameMsg   = document.getElementById('editPosNameMsg');
    const submitBtn = document.getElementById('editPosSubmitBtn');

    let hasError = false;

    if (name.length > 0) {
      const isNameDup = EXISTING_POSITIONS.some(p => p.id !== currId && p.name.toLowerCase() === name);
      if (isNameDup) {
        setPosFieldStatus(nameInput, nameMsg, false, 'Tên chức vụ này đã tồn tại!');
        hasError = true;
      } else {
        setPosFieldStatus(nameInput, nameMsg, true, 'Tên chức vụ hợp lệ');
      }
    } else {
      setPosFieldStatus(nameInput, nameMsg, null, '');
    }

    submitBtn.disabled = hasError;
    submitBtn.style.opacity = hasError ? '0.5' : '1';
    submitBtn.style.cursor = hasError ? 'not-allowed' : 'pointer';
  }

  // Lọc tìm kiếm theo Mã hoặc Tên chức vụ
  function filterTable() {
    const term = document.getElementById('searchInput').value.toLowerCase().trim();
    const rows = document.querySelectorAll('.pos-row');
    rows.forEach(r => {
      const code = r.getAttribute('data-code') || '';
      const name = r.getAttribute('data-name') || '';
      if (!term || code.includes(term) || name.includes(term)) {
        r.style.display = '';
      } else {
        r.style.display = 'none';
      }
    });
  }

  // Modal Thêm
  function openAddModal() {
    document.getElementById('addPosCode').value = '';
    document.getElementById('addPosName').value = '';
    setPosFieldStatus(document.getElementById('addPosCode'), document.getElementById('addPosCodeMsg'), null, '');
    setPosFieldStatus(document.getElementById('addPosName'), document.getElementById('addPosNameMsg'), null, '');
    document.getElementById('addPosSubmitBtn').disabled = false;
    document.getElementById('addPosSubmitBtn').style.opacity = '1';
    document.getElementById('addPosSubmitBtn').style.cursor = 'pointer';
    document.getElementById('addModal').style.display = 'flex';
  }
  function closeAddModal() {
    document.getElementById('addModal').style.display = 'none';
  }

  // Modal Sửa
  function openEditModal(id, code, name, level) {
    document.getElementById('editPosId').value = id;
    document.getElementById('editPosCode').value = code;
    document.getElementById('editPosName').value = name;
    document.getElementById('editPosLevel').value = level;

    setPosFieldStatus(document.getElementById('editPosName'), document.getElementById('editPosNameMsg'), null, '');
    document.getElementById('editPosSubmitBtn').disabled = false;
    document.getElementById('editPosSubmitBtn').style.opacity = '1';
    document.getElementById('editPosSubmitBtn').style.cursor = 'pointer';

    document.getElementById('editModal').style.display = 'flex';
  }
  function closeEditModal() {
    document.getElementById('editModal').style.display = 'none';
  }

  // Đóng Modal khi bấm ngoài vùng backdrop
  window.onclick = function(e) {
    if (e.target.classList.contains('modal-backdrop')) {
      e.target.style.display = 'none';
    }
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
