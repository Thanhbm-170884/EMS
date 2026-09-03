<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Quản Lý Ca Làm Việc | EMS</title>
  <meta name="description" content="Tạo và quản lý danh sách ca làm việc có tên để phân ca cho nhân viên">
  <link rel="stylesheet" href="css/ems.css"/>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>

<%@ include file="/WEB-INF/jspf/sidebar.jsp" %>

<div class="main-content">
  <div class="topbar">
    <span class="topbar-left">Quản lý ca làm việc</span>
    <span class="topbar-right" id="topbar-date"></span>
  </div>

  <div class="page-body">
    <!-- Page header -->
    <div class="hol-page-header">
      <div class="hol-page-header-text">
        <h1>
          <i class="fa-regular fa-clock" style="color:var(--primary);"></i>
          Danh sách ca làm việc
        </h1>
        <p>Tạo các ca có tên để tái sử dụng khi phân ca cho nhân viên.</p>
      </div>
      <button id="btnOpenModal" class="btn btn-primary" onclick="openModal('add')">
        <i class="fa-solid fa-plus"></i> Thêm ca mới
      </button>
    </div>

    <!-- Alert error -->
    <c:if test="${not empty error}">
      <div class="alert-error">
        <i class="fa-solid fa-circle-exclamation"></i>
        <span>${fn:escapeXml(error)}</span>
      </div>
    </c:if>

    <%-- Re-populate form data when server returns an error --%>
    <c:set var="errName"       value="${param.name}"/>
    <c:set var="errStart"      value="${param.startTime}"/>
    <c:set var="errEnd"        value="${param.endTime}"/>
    <c:set var="errBreakStart" value="${param.breakStart}"/>
    <c:set var="errBreakEnd"   value="${param.breakEnd}"/>
    <c:set var="errAction"     value="${param.action}"/>
    <c:set var="errId"         value="${param.id}"/>

    <%-- Toast success --%>
    <c:if test="${not empty param.success}">
      <script>window.__autoToast = true;</script>
    </c:if>

    <!-- Table -->
    <c:choose>
      <c:when test="${empty shifts}">
        <div class="empty-card" id="emptyState">
          <div class="empty-icon"><i class="fa-regular fa-clock"></i></div>
          <h2>Chưa có ca làm việc</h2>
          <p>Nhấn "Thêm ca mới" để tạo ca đầu tiên (VD: Ca hành chính, Ca sáng, Ca chiều làm bù…)</p>
          <button class="btn btn-primary" onclick="openModal('add')">
            <i class="fa-solid fa-plus"></i> Thêm ca mới
          </button>
        </div>
      </c:when>
      <c:otherwise>
        <div class="schedule-card">
          <div style="overflow-x:auto;">
            <table class="schedule-table">
              <thead>
                <tr>
                  <th>Tên ca</th>
                  <th>Giờ bắt đầu</th>
                  <th>Giờ kết thúc</th>
                  <th>Nghỉ trưa</th>
                  <th style="text-align:center;">Hành động</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="s" items="${shifts}">
                  <tr>
                    <td><strong>${fn:escapeXml(s.name)}</strong></td>
                    <td>
                      <c:choose>
                        <c:when test="${s.starttime != null}">
                          <span class="time-chip"><i class="fa-regular fa-clock"></i> ${s.starttime}</span>
                        </c:when>
                        <c:otherwise><span class="dash-text">—</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${s.endtime != null}">
                          <span class="time-chip"><i class="fa-regular fa-clock"></i> ${s.endtime}</span>
                        </c:when>
                        <c:otherwise><span class="dash-text">—</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${s.breakstart != null}">
                          <div class="time-range">
                            <span class="time-chip"><i class="fa-regular fa-clock"></i> ${s.breakstart}</span>
                            <span>–</span>
                            <span class="time-chip"><i class="fa-regular fa-clock"></i> ${s.breakend}</span>
                          </div>
                        </c:when>
                        <c:otherwise><span class="dash-text">—</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td style="text-align:center;">
                      <button class="btn btn-sm btn-secondary"
                              onclick="openModal('edit',${s.id},'${fn:escapeXml(s.name)}','${s.starttime}','${s.endtime}','${s.breakstart}','${s.breakend}')">
                        <i class="fa-solid fa-pen-to-square"></i> Sửa
                      </button>
<%--                      <button class="btn btn-sm btn-danger"--%>
<%--                              onclick="confirmDelete(${s.id},'${fn:escapeXml(s.name)}')">--%>
<%--                        <i class="fa-solid fa-trash"></i> Xóa--%>
<%--                      </button>--%>
                    </td>
                  </tr>
                </c:forEach>
              </tbody>
            </table>
          </div>
        </div>
      </c:otherwise>
    </c:choose>
  </div>

  <footer>© 2026 Hệ thống Quản lý Nhân sự (EMS) · FPT University SWP391</footer>
</div>

<!-- ── Modal Thêm / Sửa Ca ── -->
<div class="modal-overlay" id="shiftModal">
  <div class="modal schedule-modal" role="dialog" aria-modal="true" aria-labelledby="modalTitle">
    <div class="modal-header">
      <div class="modal-header-left">
        <div class="modal-header-icon">
          <i class="fa-regular fa-clock" id="modalIcon"></i>
        </div>
        <div>
          <div class="modal-title" id="modalTitle">Thêm ca làm việc</div>
          <div class="modal-subtitle">Đặt tên và cấu hình giờ giấc cho ca</div>
        </div>
      </div>
      <button class="modal-close" onclick="closeModal()" aria-label="Đóng">
        <i class="fa-solid fa-xmark"></i>
      </button>
    </div>

    <div class="modal-body">
      <form id="shiftForm" method="post" action="${pageContext.request.contextPath}/shift-management">
        <input type="hidden" name="action" id="formAction" value="create">
        <input type="hidden" name="id" id="formId" value="">

        <table class="form-table">
          <tbody>
            <tr>
              <td colspan="2">
                <label for="shiftName" style="display:block;margin-bottom:4px;font-weight:600;">Tên ca <span style="color:var(--danger)">*</span></label>
                <input type="text" id="shiftName" name="name" class="form-input" maxlength="100"
                       placeholder="VD: Ca hành chính, Ca sáng, Ca chiều làm bù…" required>
              </td>
            </tr>
            <tr>
              <td>
                <label style="display:block;margin-bottom:4px;font-weight:600;">Giờ bắt đầu <span style="color:var(--danger)">*</span></label>
                <div class="time-input-wrap">
                  <input type="time" name="startTime" id="startTime" value="08:00" required>
                </div>
              </td>
              <td>
                <label style="display:block;margin-bottom:4px;font-weight:600;">Giờ kết thúc <span style="color:var(--danger)">*</span></label>
                <div class="time-input-wrap">
                  <input type="time" name="endTime" id="endTime" value="17:30" required>
                </div>
              </td>
            </tr>
            <tr id="breakRow">
              <td colspan="2" style="padding-top:4px;">
                <label style="display:block;margin-bottom:6px;font-weight:600;">Nghỉ giữa ca <span style="color:var(--slate-400);font-weight:400;">(tùy chọn)</span></label>
                <div class="break-range">
                  <div class="time-input-wrap">
                    <input type="time" name="breakStart" id="breakStart" value="12:00">
                  </div>
                  <span class="break-sep">–</span>
                  <div class="time-input-wrap">
                    <input type="time" name="breakEnd" id="breakEnd" value="13:30">
                  </div>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </form>
    </div>

    <div class="modal-footer">
      <button type="button" class="btn btn-secondary" onclick="closeModal()">
        <i class="fa-solid fa-xmark"></i> Hủy bỏ
      </button>
      <button type="button" class="btn btn-success" onclick="submitForm()">
        <i class="fa-solid fa-floppy-disk"></i> Lưu ca làm việc
      </button>
    </div>
  </div>
</div>

<!-- ── Modal Xóa ── -->
<div class="modal-overlay" id="deleteModal">
  <div class="modal" role="dialog" style="max-width:420px;">
    <div class="modal-header">
      <div class="modal-header-left">
        <div class="modal-header-icon" style="background:rgba(239,68,68,0.1);">
          <i class="fa-solid fa-triangle-exclamation" style="color:#ef4444;"></i>
        </div>
        <div>
          <div class="modal-title">Xác nhận xóa</div>
          <div class="modal-subtitle">Hành động này không thể hoàn tác</div>
        </div>
      </div>
      <button class="modal-close" onclick="closeDeleteModal()"><i class="fa-solid fa-xmark"></i></button>
    </div>
    <div class="modal-body">
      <p>Bạn có chắc muốn xóa ca "<strong id="deleteShiftName"></strong>" không?</p>
    </div>
    <div class="modal-footer">
      <button type="button" class="btn btn-secondary" onclick="closeDeleteModal()">Hủy</button>
      <form id="deleteForm" method="post" action="${pageContext.request.contextPath}/shift-management" style="display:inline;">
        <input type="hidden" name="action" value="delete">
        <input type="hidden" name="id" id="deleteShiftId">
        <button type="submit" class="btn btn-danger"><i class="fa-solid fa-trash"></i> Xóa</button>
      </form>
    </div>
  </div>
</div>

<!-- Toast -->
<div class="toast" id="toast">
  <i class="fa-solid fa-circle-check"></i>
  <span id="toastMsg">Ca làm việc đã được lưu thành công!</span>
</div>

<script>
  // Topbar date
  (function(){
    var n = new Date(), p = n => String(n).padStart(2,'0');
    document.getElementById('topbar-date').textContent =
      p(n.getDate())+'/'+p(n.getMonth()+1)+'/'+n.getFullYear();
  })();

  /* ── Break time visibility ── */
  function updateBreakVisibility() {
    var endVal   = document.getElementById('endTime').value;
    var bsVal    = document.getElementById('breakStart').value;
    var breakRow = document.getElementById('breakRow');
    if (!breakRow) return;
    // Ẩn giờ nghỉ nếu giờ kết thúc <= giờ bắt đầu nghỉ (hoặc nghỉ chưa nhập)
    if (endVal && bsVal && endVal <= bsVal) {
      breakRow.style.display = 'none';
      // Xóa giá trị để không gửi lên server
      document.getElementById('breakStart').value = '';
      document.getElementById('breakEnd').value   = '';
    } else if (endVal) {
      breakRow.style.display = '';
    }
  }

  function openModal(mode, id, name, startTime, endTime, breakStart, breakEnd) {
    var modal = document.getElementById('shiftModal');
    var title = document.getElementById('modalTitle');
    var icon  = document.getElementById('modalIcon');
    if (mode === 'edit') {
      title.textContent = 'Chỉnh sửa ca làm việc';
      icon.className    = 'fa-solid fa-pen-to-square';
      document.getElementById('formAction').value = 'update';
      document.getElementById('formId').value     = id;
      document.getElementById('shiftName').value  = name || '';
      document.getElementById('startTime').value  = startTime || '';
      document.getElementById('endTime').value    = endTime   || '';
      document.getElementById('breakStart').value = (breakStart && breakStart !== 'null') ? breakStart : '';
      document.getElementById('breakEnd').value   = (breakEnd   && breakEnd   !== 'null') ? breakEnd   : '';
    } else {
      title.textContent = 'Thêm ca làm việc';
      icon.className    = 'fa-regular fa-calendar-plus';
      document.getElementById('formAction').value = 'create';
      document.getElementById('formId').value     = '';
      document.getElementById('shiftName').value  = '';
      document.getElementById('startTime').value  = '08:00';
      document.getElementById('endTime').value    = '17:30';
      document.getElementById('breakStart').value = '12:00';
      document.getElementById('breakEnd').value   = '13:30';
    }
    updateBreakVisibility();
    modal.classList.add('open');
    document.body.style.overflow = 'hidden';
    document.getElementById('shiftName').focus();
  }

  function closeModal() {
    document.getElementById('shiftModal').classList.remove('open');
    document.body.style.overflow = '';
  }

  function submitForm() {
    var name = document.getElementById('shiftName').value.trim();
    if (!name) { alert('Vui lòng nhập tên ca làm việc.'); return; }
    document.getElementById('shiftForm').submit();
  }

  function confirmDelete(id, name) {
    document.getElementById('deleteShiftId').value = id;
    document.getElementById('deleteShiftName').textContent = name;
    document.getElementById('deleteModal').classList.add('open');
    document.body.style.overflow = 'hidden';
  }

  function closeDeleteModal() {
    document.getElementById('deleteModal').classList.remove('open');
    document.body.style.overflow = '';
  }

  // Close on overlay click
  ['shiftModal','deleteModal'].forEach(function(id){
    document.getElementById(id).addEventListener('click', function(e){
      if (e.target === this) {
        this.classList.remove('open');
        document.body.style.overflow = '';
      }
    });
  });

  document.addEventListener('keydown', function(e){
    if (e.key === 'Escape') { closeModal(); closeDeleteModal(); }
  });

  // Listen endTime & breakStart changes to toggle break row
  document.getElementById('endTime').addEventListener('change', updateBreakVisibility);
  document.getElementById('breakStart').addEventListener('change', updateBreakVisibility);

  // Auto toast (now reads directly from URL param, no need for __autoToast)
  function showToast(msg) {
    if (msg) document.getElementById('toastMsg').textContent = msg;
    var t = document.getElementById('toast');
    t.classList.add('show');
    setTimeout(function(){ t.classList.remove('show'); }, 3500);
  }

  (function(){
    var params = new URLSearchParams(window.location.search);
    var s = params.get('success');
    if (s) {
      var msg = s === '1' ? 'Thêm ca làm việc thành công!'
              : s === '2' ? 'Cập nhật ca làm việc thành công!'
              : s === '3' ? 'Xóa ca làm việc thành công!' : '';
      if (msg) {
        showToast(msg);
        window.history.replaceState({}, '', window.location.pathname);
      }
    }
  })();

  <%-- Nếu server trả về lỗi → tự động mở lại modal với dữ liệu đã nhập --%>
  <c:if test="${not empty error}">
  (function(){
    var mode   = '${fn:escapeXml(errAction)}' === 'update' ? 'edit' : 'add';
    var id     = '${fn:escapeXml(errId)}';
    var name   = '${fn:escapeXml(errName)}';
    var start  = '${fn:escapeXml(errStart)}';
    var end    = '${fn:escapeXml(errEnd)}';
    var bs     = '${fn:escapeXml(errBreakStart)}';
    var be     = '${fn:escapeXml(errBreakEnd)}';
    openModal(mode, id, name, start, end, bs, be);
  })();
  </c:if>
</script>
</body>
</html>
