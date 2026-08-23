<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Ngày lễ – EMS</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
        rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ems.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/holiday.css">
  <!-- Font Awesome for icons -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

  <!--
    GHI CHÚ CHO DEV: các style dưới đây là phần BỔ SUNG cho holiday.css hiện có.
    Nên chuyển toàn bộ khối này vào file holiday.css thật để tránh style trùng lặp
    và để các trang khác dùng chung component (btn-ghost, toast, badge-locked...) nếu cần.
    Mình giữ inline ở đây vì không có quyền truy cập file holiday.css gốc.
  -->
  <style>
    /* ===== Bỏ nút "Lưu" lặp lại ở từng hàng: chỉ còn input, không có button riêng ===== */
    .holiday-table .row-inline-hint {
      color: var(--slate-400, #94a3b8);
      font-size: 0.78rem;
      display: inline-flex;
      align-items: center;
      gap: 4px;
    }

    /* Hàng có thay đổi chưa lưu -> viền trái cảnh báo nhẹ, không dùng màu đỏ (không phải lỗi) */
    .holiday-table tbody tr.is-dirty {
      background: #fffaf0;
      box-shadow: inset 3px 0 0 0 #f59e0b;
    }
    .holiday-table tbody tr.is-dirty .stt-cell::after {
      content: '\f111';
      font-family: 'Font Awesome 6 Free';
      font-weight: 900;
      font-size: 6px;
      color: #f59e0b;
      vertical-align: super;
      margin-left: 4px;
    }

    /* ===== Thanh "Lưu thay đổi" toàn cục — thay thế toàn bộ nút Lưu từng hàng ===== */
    .unsaved-bar {
      position: sticky;
      bottom: 0;
      left: 0;
      right: 0;
      margin-top: 14px;
      background: #1e2330;
      color: #fff;
      border-radius: 12px;
      padding: 12px 18px;
      display: none;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
      box-shadow: 0 10px 30px rgba(0,0,0,0.25);
      z-index: 50;
      animation: unsaved-bar-in .18s ease;
    }
    .unsaved-bar.show { display: flex; }
    @keyframes unsaved-bar-in {
      from { opacity: 0; transform: translateY(10px); }
      to { opacity: 1; transform: translateY(0); }
    }
    .unsaved-bar-msg {
      display: flex;
      align-items: center;
      gap: 10px;
      font-size: 0.9rem;
    }
    .unsaved-bar-msg i { color: #f59e0b; }
    .unsaved-bar-actions {
      display: flex;
      gap: 8px;
    }
    .unsaved-bar-actions button {
      border-radius: 8px;
      padding: 8px 16px;
      font-size: 0.85rem;
      font-weight: 600;
      cursor: pointer;
      border: 1px solid transparent;
    }
    .btn-discard-all {
      background: transparent;
      border-color: rgba(255,255,255,0.3);
      color: #fff;
    }
    .btn-discard-all:hover { background: rgba(255,255,255,0.08); }
    .btn-save-all {
      background: var(--primary, #6d5bd0);
      color: #fff;
    }
    .btn-save-all:hover { filter: brightness(1.08); }
    .btn-save-all:disabled, .btn-discard-all:disabled {
      opacity: .5;
      cursor: not-allowed;
    }

    /* Đồng bộ chiều cao mọi dòng trong bảng, tránh lệch layout giữa các loại ngày lễ */
    .holiday-table td {
      vertical-align: middle;
      min-height: 52px;
    }
    .holiday-table .date-cell-inner,
    .holiday-table .date-fixed {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      min-height: 34px;
    }

    /* Nhãn "Cố định" cho hệ số dễ gây nhầm với badge "Dương lịch cố định" ở cột Tên
       -> đổi nhãn + thêm icon khóa + tooltip giải thích rõ nghĩa */
    .lock-label {
      display: inline-flex;
      align-items: center;
      gap: 4px;
      cursor: help;
    }

    /* Icon info cạnh tiêu đề cột, thay cho dòng chú thích bị chìm ở cuối bảng */
    .col-info-icon {
      margin-left: 4px;
      color: var(--slate-400, #94a3b8);
      cursor: help;
      font-size: 0.8rem;
    }

    /* Toast lưu thành công, thay thế việc reload cả trang mỗi lần bấm Lưu */
    #save-toast {
      position: fixed;
      bottom: 24px;
      right: 24px;
      background: #16a34a;
      color: #fff;
      padding: 10px 16px;
      border-radius: 8px;
      font-size: 0.85rem;
      font-weight: 500;
      box-shadow: 0 8px 20px rgba(0,0,0,0.15);
      display: flex;
      align-items: center;
      gap: 8px;
      opacity: 0;
      transform: translateY(8px);
      pointer-events: none;
      transition: opacity .2s ease, transform .2s ease;
      z-index: 999;
    }
    #save-toast.show {
      opacity: 1;
      transform: translateY(0);
    }
    #save-toast.error { background: #dc2626; }

    .add-panel-form .field-hint {
      font-size: 0.72rem;
      color: var(--slate-400, #94a3b8);
      margin-top: 4px;
      display: block;
    }

    /* ===== Thông báo lỗi ngay tại dòng bị lỗi (validate hoặc lưu thất bại) ===== */
    .row-error-msg {
      color: #dc2626;
      font-size: 0.75rem;
      margin-top: 4px;
      display: flex;
      align-items: center;
      gap: 4px;
    }
    .holiday-table tbody tr.has-error {
      box-shadow: inset 3px 0 0 0 #dc2626;
      background: #fef2f2;
    }
    .date-input-sm.field-invalid {
      border-color: #dc2626 !important;
      outline: none;
    }
  </style>
</head>

<body>

<%@include file="/WEB-INF/jspf/sidebar.jsp" %>

<div class="main-content">

  <!-- Topbar -->
  <div class="topbar">
    <div>
      <div class="topbar-title">🗓 Quản lý ngày lễ</div>
      <div class="topbar-breadcrumb">EMS &rsaquo; Quản lý &rsaquo; Ngày lễ</div>
    </div>
    <div class="topbar-right">Năm <strong>${year}</strong></div>
  </div>

  <!-- Page body -->
  <div class="page-body">

    <!-- Error alert -->
    <c:if test="${not empty errorMsg}">
      <div class="alert-error">
        <i class="fa-solid fa-circle-exclamation"></i>
        <c:out value="${errorMsg}" />
      </div>
    </c:if>

    <!-- Page header -->
    <div class="hol-page-header">
      <div class="hol-page-header-text">
        <h1><i class="fa-solid fa-calendar-day" style="color:var(--primary);font-size:1.2rem;"></i> Thiết
          lập hệ số công ngày lễ</h1>
        <p>Cấu hình các ngày nghỉ lễ và hệ số lương tương ứng cho năm <strong>${year}</strong></p>
      </div>

      <!-- Year navigator -->
      <div class="year-nav">
        <a class="year-nav-btn" href="${pageContext.request.contextPath}/holiday?year=${year - 1}"
           title="Năm trước">
          <i class="fa-solid fa-chevron-left"></i>
        </a>
        <div class="year-chip">
          <i class="fa-regular fa-calendar"></i>
          ${year}
        </div>
        <a class="year-nav-btn" href="${pageContext.request.contextPath}/holiday?year=${year + 1}"
           title="Năm sau">
          <i class="fa-solid fa-chevron-right"></i>
        </a>
      </div>
    </div>

    <!-- Holiday card -->
    <div class="holiday-card">

      <!-- Card header -->
      <div class="holiday-card-header">
        <div class="holiday-card-header-left">
          <div class="holiday-card-icon"><i class="fa-solid fa-umbrella-beach"></i></div>
          <div>
            <div class="holiday-card-title">Danh sách ngày nghỉ lễ</div>
            <div class="holiday-card-subtitle">
              <c:choose>
                <c:when test="${not empty holidays}">${fn:length(holidays)} ngày lễ được thiết lập</c:when>
                <c:otherwise>Chưa có ngày lễ nào</c:otherwise>
              </c:choose>
            </div>
          </div>
        </div>
      </div>

      <!-- Holiday table -->
      <table class="holiday-table">
        <thead>
        <tr>
          <th>#</th>
          <th>Tên ngày nghỉ</th>
          <th>Thời gian</th>
          <th>Đối tượng</th>
          <th>
            Hệ số lương
            <i class="fa-solid fa-circle-info col-info-icon"
               title="Hệ số 1.0 = lương bình thường, hệ số cao hơn = phụ cấp ngày lễ"></i>
          </th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="h" items="${holidays}" varStatus="st">
          <tr data-row-id="${h.templateId}">
            <!-- STT -->
            <td class="stt-cell">${st.index + 1}</td>

            <!-- Name: THAY ĐỔI - dùng c:out để escape, tránh XSS -->
            <td>
              <span class="holiday-name"><c:out value="${h.holidayName}" /></span>
              <c:if test="${h.recurType == 'FIXED_SOLAR'}">
                              <span class="hol-badge badge-passed" style="margin-left:6px;font-size:0.7rem;">
                                <i class="fa-solid fa-sun"></i> Dương lịch cố định
                              </span>
              </c:if>
              <c:if test="${h.recurType == 'LUNAR'}">
                              <span class="hol-badge badge-upcoming" style="margin-left:6px;font-size:0.7rem;">
                                <i class="fa-solid fa-moon"></i> Âm lịch
                              </span>
              </c:if>
            </td>

            <!-- Date range -->
            <td>
              <c:choose>
                <c:when test="${h.recurType == 'FIXED_SOLAR'}">
                                <span class="date-fixed date-cell-inner">
                                  <i class="fa-regular fa-calendar"></i>
                                  ${h.startDate}
                                  <c:if test="${h.startDate != h.endDate}">
                                    &rarr; ${h.endDate}
                                  </c:if>
                                </span>
                </c:when>
                <c:otherwise>
                  <form method="post" action="${pageContext.request.contextPath}/holiday"
                        class="js-ajax-form date-form" data-success-msg="ngày nghỉ" data-kind="dates">
                    <input type="hidden" name="action" value="saveDates">
                    <input type="hidden" name="year" value="${year}">
                    <input type="hidden" name="templateId" value="${h.templateId}">
                    <div class="date-form date-cell-inner">
                      <input type="date" class="date-input-sm js-track-dirty" name="startDate"
                             value="${h.startDateIso}" autocomplete="off" required>
                      <span style="color:var(--slate-400);font-size:0.8rem;">→</span>
                      <input type="date" class="date-input-sm js-track-dirty" name="endDate"
                             value="${h.endDateIso}" autocomplete="off" required>
                      <c:if test="${h.startDate == ''}">
                                      <span class="badge-missing">
                                        <i class="fa-solid fa-triangle-exclamation"></i>
                                        Chưa có dữ liệu ${year}
                                      </span>
                      </c:if>
                    </div>
                    <div class="row-error-msg" style="display:none;"></div>
                  </form>
                </c:otherwise>
              </c:choose>
            </td>

            <!-- Target -->
            <td>
                            <span class="hol-badge badge-ongoing">
                              <i class="fa-solid fa-users"></i> Toàn công ty
                            </span>
            </td>

            <!--
              Coefficient
              THAY ĐỔI:
              - Bỏ onchange auto-submit trên checkbox "Cố định" -> tránh lưu nhầm giá trị
                hệ số đang gõ dở khi người dùng chỉ định tick/bỏ tick khóa.
                Giờ mọi thay đổi (số + khóa) chỉ được ghi khi bấm "Lưu".
              - Đổi nhãn "Cố định" -> "Khóa hệ số" kèm tooltip giải thích, tránh nhầm với
                badge "Dương lịch cố định" ở cột Tên.
              - Thêm data-original để phát hiện "dirty" và tô viền cam cảnh báo chưa lưu.
            -->
            <td>
              <form method="post" action="${pageContext.request.contextPath}/holiday"
                    class="js-ajax-form coef-form-wrap" data-success-msg="hệ số lương" data-kind="coefficient">
                <input type="hidden" name="action" value="saveCoefficient">
                <input type="hidden" name="year" value="${year}">
                <input type="hidden" name="templateId" value="${h.templateId}">
                <div class="coef-form">
                  <input type="number" step="0.1" min="0" class="coef-input js-track-dirty"
                         name="coefficient" value="${h.coefficient}" autocomplete="off"
                    ${h.coefficientLocked ? 'readonly' : '' }>
                  <label class="lock-label" title="Khi bật, hệ số này sẽ không thể chỉnh sửa cho đến khi mở khóa lại">
                    <input type="checkbox" name="locked" class="js-track-dirty"
                      ${h.coefficientLocked ? 'checked' : '' }>
                    <i class="fa-solid fa-lock"></i> Khóa hệ số
                  </label>
                </div>
                <div class="row-error-msg" style="display:none;"></div>
              </form>
            </td>
          </tr>
        </c:forEach>

        <c:if test="${empty holidays}">
          <tr>
            <td colspan="5">
              <div class="no-results">
                <div class="no-results-icon"><i class="fa-regular fa-calendar-xmark"></i></div>
                <h3>Chưa có ngày lễ nào</h3>
                <p>Thêm ngày nghỉ lễ mới bằng biểu mẫu bên dưới.</p>
              </div>
            </td>
          </tr>
        </c:if>
        </tbody>
      </table>

      <!-- Card footer -->
      <div class="hol-card-footer">
                    <span>
                      Tổng cộng:
                      <strong>${not empty holidays ? fn:length(holidays) : 0}</strong> ngày lễ trong năm ${year}
                    </span>
      </div>

      <!-- THAY ĐỔI: 1 thanh Lưu duy nhất cho cả bảng, thay cho nút Lưu lặp lại mỗi hàng -->
      <div class="unsaved-bar" id="unsavedBar">
        <div class="unsaved-bar-msg">
          <i class="fa-solid fa-circle-exclamation"></i>
          <span id="unsavedBarText">Có thay đổi chưa lưu</span>
        </div>
        <div class="unsaved-bar-actions">
          <button type="button" class="btn-discard-all" id="btnDiscardAll">Hủy thay đổi</button>
          <button type="button" class="btn-save-all" id="btnSaveAll">
            <i class="fa-solid fa-floppy-disk"></i> Lưu thay đổi
          </button>
        </div>
      </div>

    </div><!-- /holiday-card -->

    <!-- Add new holiday panel -->
    <div class="add-panel">
      <div class="add-panel-title">
        <i class="fa-solid fa-plus-circle"></i>
        Thêm ngày nghỉ lễ mới
      </div>
      <form method="post" action="${pageContext.request.contextPath}/holiday" id="addHolidayForm">
        <input type="hidden" name="action" value="createTemplate">
        <input type="hidden" name="year" value="${year}">
        <div class="add-panel-form">
          <input type="text" name="name" placeholder="Tên ngày nghỉ lễ" required maxlength="100">

          <select name="recurType" id="recurTypeSelect" onchange="toggleFixedFields()">
            <option value="FIXED_SOLAR">📅 Cố định theo dương lịch</option>
            <option value="LUNAR">🌙 Theo âm lịch (nhập tay mỗi năm)</option>
          </select>

          <span id="fixedFields" class="fixed-field-label">
                        Tháng:
                        <input type="number" name="fixedMonth" id="fixedMonth" min="1" max="12" placeholder="MM">
                        Ngày:
                        <input type="number" name="fixedDay" id="fixedDay" min="1" max="31" placeholder="DD">
                      </span>

          <button type="submit" class="btn btn-primary">
            <i class="fa-solid fa-plus"></i> Thêm
          </button>
        </div>
        <span class="field-hint">Ngày lễ âm lịch sẽ cần cập nhật ngày dương lịch tương ứng mỗi năm ở bảng phía trên.</span>
      </form>
    </div>

  </div><!-- /page-body -->

  <!-- Footer -->
  <footer>EMS &copy; 2025 &mdash; Employee Management System</footer>

</div><!-- /main-content -->

<div id="save-toast" role="status" aria-live="polite">
  <i class="fa-solid fa-circle-check"></i>
  <span id="save-toast-msg">Đã lưu</span>
</div>

<script>
  function toggleFixedFields() {
    var type = document.getElementById('recurTypeSelect').value;
    document.getElementById('fixedFields').style.display =
            (type === 'FIXED_SOLAR') ? 'inline-flex' : 'none';
  }
  toggleFixedFields();

  // ===== Validate ngày/tháng cố định trước khi thêm mới =====
  var daysInMonth = { 1:31,2:29,3:31,4:30,5:31,6:30,7:31,8:31,9:30,10:31,11:30,12:31 };
  document.getElementById('addHolidayForm').addEventListener('submit', function (e) {
    var type = document.getElementById('recurTypeSelect').value;
    if (type !== 'FIXED_SOLAR') return;
    var m = parseInt(document.getElementById('fixedMonth').value, 10);
    var d = parseInt(document.getElementById('fixedDay').value, 10);
    if (!m || !d || d < 1 || d > (daysInMonth[m] || 31)) {
      e.preventDefault();
      showToast('Ngày/tháng không hợp lệ, vui lòng kiểm tra lại.', true);
    }
  });

  // ===== Toast helper =====
  var toastEl = document.getElementById('save-toast');
  var toastMsgEl = document.getElementById('save-toast-msg');
  var toastTimer = null;
  function showToast(msg, isError) {
    toastMsgEl.textContent = msg;
    toastEl.classList.toggle('error', !!isError);
    toastEl.classList.add('show');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(function () {
      toastEl.classList.remove('show');
    }, 2600);
  }

  /* ==========================================================
     THAY ĐỔI CHÍNH: bỏ nút "Lưu" ở từng hàng.
     Mọi input chỉnh sửa (ngày, hệ số, khóa) chỉ được đánh dấu
     "dirty" trên UI. Người dùng sửa xong bao nhiêu hàng tùy ý,
     rồi bấm 1 LẦN vào thanh "Lưu thay đổi" ở cuối bảng để lưu
     tất cả cùng lúc.
     ========================================================== */

  var unsavedBar = document.getElementById('unsavedBar');
  var unsavedBarText = document.getElementById('unsavedBarText');
  var btnSaveAll = document.getElementById('btnSaveAll');
  var btnDiscardAll = document.getElementById('btnDiscardAll');

  // Lưu lại giá trị gốc của từng input để có thể "Hủy thay đổi"
  document.querySelectorAll('.js-track-dirty').forEach(function (el) {
    el.dataset.originalValue = el.type === 'checkbox' ? el.checked : el.value;
  });

  function getDirtyForms() {
    return Array.prototype.slice.call(document.querySelectorAll('.js-ajax-form'))
            .filter(function (f) { return f.classList.contains('is-dirty'); });
  }

  function refreshUnsavedBar() {
    var count = getDirtyForms().length;
    if (count > 0) {
      unsavedBarText.textContent = 'Bạn có ' + count + ' thay đổi chưa lưu';
      unsavedBar.classList.add('show');
    } else {
      unsavedBar.classList.remove('show');
    }
  }

  function isFormDirty(form) {
    var inputs = form.querySelectorAll('.js-track-dirty');
    for (var i = 0; i < inputs.length; i++) {
      var el = inputs[i];
      var current = el.type === 'checkbox' ? el.checked : el.value;
      // So sánh dạng chuỗi để tránh lệch kiểu (true vs "true", "3.0" vs "3")
      if (String(current) !== String(el.dataset.originalValue)) return true;
    }
    return false;
  }

  function clearRowError(form) {
    var row = form.closest('tr');
    var errBox = form.querySelector('.row-error-msg');
    if (errBox) { errBox.style.display = 'none'; errBox.textContent = ''; }
    form.querySelectorAll('.date-input-sm').forEach(function (el) {
      el.classList.remove('field-invalid');
    });
    if (row) {
      var stillHasVisibleError = Array.prototype.slice
              .call(row.querySelectorAll('.row-error-msg'))
              .some(function (box) { return box.style.display === 'flex'; });
      if (!stillHasVisibleError) row.classList.remove('has-error');
    }
  }

  function showRowError(form, msg) {
    var row = form.closest('tr');
    var errBox = form.querySelector('.row-error-msg');
    if (errBox) {
      errBox.innerHTML = '<i class="fa-solid fa-circle-exclamation"></i> ' + msg;
      errBox.style.display = 'flex';
    }
    form.querySelectorAll('.date-input-sm').forEach(function (el) {
      el.classList.add('field-invalid');
    });
    if (row) row.classList.add('has-error');
  }

  // THAY ĐỔI: kiểm tra thứ tự ngày ngay trên trình duyệt trước khi gửi lên server,
  // tránh gửi request thất bại (ví dụ ngày bắt đầu sau ngày kết thúc do autofill/gõ nhầm)
  function validateDateForm(form) {
    if (form.dataset.kind !== 'dates') return true;
    var start = form.querySelector('[name="startDate"]').value;
    var end = form.querySelector('[name="endDate"]').value;
    if (start && end && start > end) {
      showRowError(form, 'Ngày bắt đầu phải trước hoặc bằng ngày kết thúc.');
      return false;
    }
    clearRowError(form);
    return true;
  }

  document.querySelectorAll('.js-track-dirty').forEach(function (el) {
    el.addEventListener('input', onFieldChange);
    el.addEventListener('change', onFieldChange);
  });

  function onFieldChange(e) {
    var el = e.target;
    var form = el.closest('form');
    var row = el.closest('tr');
    var dirty = isFormDirty(form);
    form.classList.toggle('is-dirty', dirty);
    if (dirty) validateDateForm(form); else clearRowError(form);
    if (row) {
      var rowHasDirtyForm = row.querySelector('form.is-dirty') !== null;
      row.classList.toggle('is-dirty', rowHasDirtyForm);
    }
    refreshUnsavedBar();
  }

  // ===== Bấm "Lưu thay đổi": gửi song song các form hợp lệ đã sửa =====
  btnSaveAll.addEventListener('click', function () {
    var allDirty = getDirtyForms();
    if (allDirty.length === 0) return;

    // Tách form hợp lệ / không hợp lệ trước khi gửi -> không gửi dữ liệu sai lên server
    var invalidForms = allDirty.filter(function (f) { return !validateDateForm(f); });
    var forms = allDirty.filter(function (f) { return invalidForms.indexOf(f) === -1; });

    if (invalidForms.length > 0) {
      showToast(invalidForms.length + ' dòng có dữ liệu chưa hợp lệ, đã đánh dấu để bạn kiểm tra.', true);
    }
    if (forms.length === 0) return;

    btnSaveAll.disabled = true;
    btnDiscardAll.disabled = true;
    var originalBtnHtml = btnSaveAll.innerHTML;
    btnSaveAll.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang lưu...';

    var requests = forms.map(function (form) {
      return fetch(form.getAttribute('action'), {
        method: 'POST',
        body: new FormData(form),
        credentials: 'same-origin',
        headers: { 'X-Requested-With': 'XMLHttpRequest' }
      }).then(function (res) {
        return res.json().catch(function () { return {}; }).then(function (data) {
          return { form: form, ok: res.ok && data.success !== false, message: data.message };
        });
      }).catch(function () {
        return { form: form, ok: false, message: null };
      });
    });

    Promise.all(requests).then(function (results) {
      var failed = results.filter(function (r) { return !r.ok; });

      results.forEach(function (r) {
        var form = r.form;
        if (!r.ok) {
          // THAY ĐỔI: hiển thị đúng lý do lỗi server trả về (nếu có), không còn câu chung chung
          showRowError(form, r.message || 'Lưu thất bại, vui lòng kiểm tra lại dữ liệu và thử lại.');
          return;
        }
        clearRowError(form);
        form.classList.remove('is-dirty');
        form.querySelectorAll('.js-track-dirty').forEach(function (el) {
          el.dataset.originalValue = el.type === 'checkbox' ? el.checked : el.value;
        });
        var row = form.closest('tr');
        if (row && !row.querySelector('form.is-dirty')) row.classList.remove('is-dirty');
      });

      if (failed.length === 0) {
        showToast('Đã lưu tất cả thay đổi (' + results.length + ')', false);
      } else {
        showToast(failed.length + '/' + results.length + ' thay đổi lưu thất bại — xem chi tiết tại các dòng được đánh dấu đỏ.', true);
      }
      refreshUnsavedBar();
    }).finally(function () {
      btnSaveAll.disabled = false;
      btnDiscardAll.disabled = false;
      btnSaveAll.innerHTML = originalBtnHtml;
    });
  });

  // ===== Bấm "Hủy thay đổi": khôi phục giá trị gốc cho toàn bộ input đang dirty =====
  btnDiscardAll.addEventListener('click', function () {
    getDirtyForms().forEach(function (form) {
      form.querySelectorAll('.js-track-dirty').forEach(function (el) {
        if (el.type === 'checkbox') el.checked = el.dataset.originalValue === 'true';
        else el.value = el.dataset.originalValue;
      });
      form.classList.remove('is-dirty');
      clearRowError(form);
      var row = form.closest('tr');
      if (row) { row.classList.remove('is-dirty'); row.classList.remove('has-error'); }
    });
    refreshUnsavedBar();
    showToast('Đã hủy các thay đổi chưa lưu', false);
  });

  // ===== Cảnh báo khi rời trang mà còn dữ liệu chưa lưu =====
  window.addEventListener('beforeunload', function (e) {
    if (getDirtyForms().length > 0) {
      e.preventDefault();
      e.returnValue = '';
    }
  });
</script>

</body>

</html>
