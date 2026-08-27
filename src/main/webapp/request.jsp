<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="com.ems.dto.EmployeeBalanceDTO" %>
<%
    HttpSession currentSession = request.getSession(false);
    if (currentSession == null || currentSession.getAttribute("username") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String username = (String) currentSession.getAttribute("username");
    String role = (String) currentSession.getAttribute("role");
    String displayName = username != null ? username : "Nhân viên";
    String initial = displayName.isEmpty() ? "N" : displayName.substring(0, 1).toUpperCase();

    // Data injected by RequestEmployeeController.showForm()
    EmployeeBalanceDTO leaveBalance = (EmployeeBalanceDTO) request.getAttribute("leaveBalance");
    Boolean gender = (Boolean) request.getAttribute("gender");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String selectedTypeCode = (String) request.getAttribute("selectedTypeCode");

    // Tính các giá trị số ngày phép
    int totalDaysVal  = (leaveBalance != null) ? leaveBalance.getTotalDays()     : 12;
    int usedDaysVal   = (leaveBalance != null) ? leaveBalance.getUsedDays()      : 0;
    int remainingDays = (leaveBalance != null) ? leaveBalance.getRemainingDays() : totalDaysVal;
    boolean hasBalanceRecord = (leaveBalance != null);
    boolean annualLeaveExhausted = hasBalanceRecord && (usedDaysVal >= totalDaysVal);

    // genderStr: "male", "female", or "unknown"
    String genderStr = (gender == null) ? "unknown" : (gender ? "male" : "female");
%>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EMS – Gửi đơn nghỉ phép</title>
    <meta name="description" content="Tạo và gửi đơn xin nghỉ phép đến quản lý để phê duyệt.">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/ems.css">
    <style>
        /* ── Layout ── */
        .request-card { max-width: 960px; }
        .request-card-body { padding: 24px; }
        .request-form-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 18px;
        }
        .request-field {
            display: flex;
            flex-direction: column;
            gap: 7px;
        }
        .request-field.full { grid-column: 1 / -1; }
        .request-field label {
            color: #374151;
            font-size: 13px;
            font-weight: 600;
        }
        .required { color: #dc2626; }

        /* ── Inputs ── */
        .request-field input,
        .request-field select,
        .request-field textarea {
            width: 100%;
            padding: 10px 12px;
            border: 1.5px solid #d1d5db;
            border-radius: 8px;
            background: #fff;
            color: #111827;
            font: inherit;
            transition: border-color .18s, box-shadow .18s;
        }
        .request-field input:focus,
        .request-field select:focus,
        .request-field textarea:focus {
            outline: none;
            border-color: #2563eb;
            box-shadow: 0 0 0 3px rgba(37,99,235,.12);
        }
        .request-field input.field-error,
        .request-field select.field-error,
        .request-field textarea.field-error {
            border-color: #dc2626;
            box-shadow: 0 0 0 3px rgba(220,38,38,.1);
        }
        .request-field textarea { min-height: 110px; resize: vertical; }
        .request-field input[readonly] { background: #f9fafb; color: #6b7280; cursor: default; }

        /* ── Info panel ── */
        .type-info-panel {
            margin-top: 4px;
            padding: 10px 14px;
            border-radius: 8px;
            font-size: 12.5px;
            line-height: 1.6;
            display: none;
        }
        .type-info-panel.show { display: block; }
        .type-info-panel.info { background: #eff6ff; border: 1px solid #bfdbfe; color: #1e40af; }
        .type-info-panel.warning { background: #fffbeb; border: 1px solid #fde68a; color: #92400e; }
        .type-info-panel.success { background: #f0fdf4; border: 1px solid #bbf7d0; color: #166534; }

        /* ── Balance badge ── */
        .balance-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
        }
        .balance-badge.good { background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; }
        .balance-badge.warn { background: #fef3c7; color: #b45309; border: 1px solid #fde68a; }
        .balance-badge.none { background: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; }

        /* ── Overlay alerts ── */
        .server-error {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            padding: 14px 16px;
            border-radius: 8px;
            background: #fef2f2;
            border: 1px solid #fecaca;
            color: #991b1b;
            font-size: 13.5px;
            font-weight: 500;
            margin-bottom: 20px;
        }
        .server-error svg { flex-shrink: 0; margin-top: 1px; }

        .inline-error {
            font-size: 12px;
            color: #dc2626;
            font-weight: 500;
            display: none;
        }
        .inline-error.show { display: block; }

        .weekend-warning {
            font-size: 12px;
            color: #b45309;
            font-weight: 500;
            display: none;
        }
        .weekend-warning.show { display: block; }

        /* ── Notice ── */
        .request-notice {
            margin-top: 20px;
            padding: 12px 14px;
            border: 1px solid #bfdbfe;
            border-radius: 8px;
            background: #eff6ff;
            color: #1e40af;
            font-size: 13px;
        }

        /* ── Actions ── */
        .request-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 22px;
            padding-top: 18px;
            border-top: 1px solid #e5e7eb;
        }

        /* ── Disabled submit state ── */
        .btn-primary:disabled,
        .btn-primary[disabled] {
            background: #9ca3af;
            cursor: not-allowed;
            opacity: 0.65;
            box-shadow: none;
            pointer-events: none;
        }
        .submit-block-hint {
            font-size: 12px;
            color: #b91c1c;
            font-weight: 500;
            text-align: right;
            margin-top: 6px;
            display: none;
        }
        .submit-block-hint.show { display: block; }

        /* ── File input styling ── */
        .file-input-wrapper { position: relative; }
        .file-input-label {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 10px 14px;
            border: 1.5px dashed #d1d5db;
            border-radius: 8px;
            background: #f9fafb;
            cursor: pointer;
            font-size: 13px;
            color: #6b7280;
            transition: border-color .18s, background .18s;
        }
        .file-input-label:hover { border-color: #2563eb; background: #eff6ff; color: #2563eb; }
        .file-input-label.required-file { border-color: #fca5a5; background: #fff1f2; }
        input[type="file"] { display: none; }
        #file-chosen { font-size: 12px; color: #059669; margin-top: 4px; display: none; }
        #file-chosen.show { display: block; }

        /* ── Section divider ── */
        .section-divider {
            grid-column: 1 / -1;
            display: flex;
            align-items: center;
            gap: 12px;
            margin: 4px 0 2px;
        }
        .section-divider span {
            font-size: 11.5px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .06em;
            color: #9ca3af;
            white-space: nowrap;
        }
        .section-divider hr {
            flex: 1;
            border: none;
            border-top: 1px solid #e5e7eb;
        }

        /* ── Responsive ── */
        @media (max-width: 768px) {
            .sidebar { position: static; width: 100%; min-height: auto; }
            .main-content { margin-left: 0; }
            body { display: block; }
            .request-form-grid { grid-template-columns: 1fr; }
            .request-field.full { grid-column: auto; }
            .page-body { padding: 20px 16px; }
        }
    </style>
</head>

<body>
<%@include file="/WEB-INF/jspf/sidebar.jsp" %>

<div class="main-content">
    <div class="topbar">
        <span class="topbar-left">Gửi đơn nghỉ</span>
        <span class="topbar-right" id="topbar-date"></span>
    </div>

    <main class="page-body">
        <div class="page-header">
            <h1>Gửi đơn xin nghỉ</h1>
            <p>Chọn loại đơn, điền thông tin và gửi đến quản lý để phê duyệt.</p>
        </div>

        <section class="card request-card">
            <div class="card-header" style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:8px;">
                <span>Thông tin đơn nghỉ</span>

            </div>
            <div class="request-card-body">

                <%-- Server-side error banner --%>
                <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                <div class="server-error">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><circle cx="12" cy="16" r=".5" fill="currentColor"/>
                    </svg>
                    <%= errorMessage %>
                </div>
                <% } %>

                <form id="leaveForm" action="<%= request.getContextPath() %>/requests" method="post"
                      enctype="multipart/form-data" novalidate>
                    <input type="hidden" name="action" value="insert">
                    <input type="hidden" id="requestTypeCode" name="requestTypeCode" value="<%= selectedTypeCode != null ? selectedTypeCode : "" %>">

                    <div class="request-form-grid">

                        <%-- ── Loại đơn ── --%>
                        <div class="request-field">
                            <label for="leaveTypeSelect">Loại đơn <span class="required">*</span></label>
                            <select id="leaveTypeSelect" required>
                                <option value="">-- Chọn loại đơn --</option>
                                <option value="ANNUAL"          <%= "ANNUAL".equals(selectedTypeCode)          ? "selected" : "" %>>🏖️ Nghỉ phép năm</option>
                                <option value="UNPAID"          <%= "UNPAID".equals(selectedTypeCode)          ? "selected" : "" %>>💸 Nghỉ không lương</option>
                                <option value="SICK"            <%= "SICK".equals(selectedTypeCode)            ? "selected" : "" %>>🏥 Nghỉ ốm</option>
                                <option value="MARRIAGE"        <%= "MARRIAGE".equals(selectedTypeCode)        ? "selected" : "" %>>💒 Nghỉ kết hôn</option>
                                <option value="CHILD_MARRIAGE"  <%= "CHILD_MARRIAGE".equals(selectedTypeCode)  ? "selected" : "" %>>👨‍👧 Nghỉ con kết hôn</option>
                                <option value="FUNERAL"         <%= "FUNERAL".equals(selectedTypeCode)         ? "selected" : "" %>>🕊️ Nghỉ tang</option>
                                <option value="MATERNITY"       <%= "MATERNITY".equals(selectedTypeCode)       ? "selected" : "" %>>🍼 Nghỉ thai sản</option>
                            </select>
                            <span class="inline-error" id="typeError">Vui lòng chọn loại đơn.</span>
                        </div>

                        <%-- ── Tiêu đề ── --%>
                        <div class="request-field">
                            <label for="title">Tiêu đề <span class="required">*</span></label>
                            <input id="title" type="text" name="title" maxlength="100"
                                   placeholder="Nhập tiêu đề đơn" required>
                            <span class="inline-error" id="titleError">Vui lòng nhập tiêu đề.</span>
                        </div>

                        <%-- ── Info panel (thay đổi theo loại) ── --%>
                        <div class="request-field full" id="infoPanelWrapper" style="display:none;">
                            <div class="type-info-panel info show" id="typeInfoPanel"></div>
                        </div>

                        <%-- ── Section: Thời gian ── --%>
                        <div class="section-divider"><hr><span>Thời gian nghỉ</span><hr></div>

                        <%-- ── Từ ngày ── --%>
                        <div class="request-field" id="startDateField">
                            <label for="startDate">Từ ngày <span class="required">*</span></label>
                            <input id="startDate" type="date" name="startDate" required>
                            <span class="inline-error" id="startDateError">Vui lòng chọn ngày bắt đầu.</span>
                            <span class="weekend-warning" id="startWeekendWarn">⚠️ Ngày này là cuối tuần – sẽ không được tính là ngày nghỉ làm.</span>
                        </div>

                        <%-- ── Đến ngày ── --%>
                        <div class="request-field" id="endDateField">
                            <label for="endDate">Đến ngày <span class="required">*</span></label>
                            <input id="endDate" type="date" name="endDate" required>
                            <span class="inline-error" id="endDateError">Ngày kết thúc không được trước ngày bắt đầu.</span>
                            <span class="weekend-warning" id="endWeekendWarn">⚠️ Ngày này là cuối tuần.</span>
                        </div>

                        <%-- ── Số ngày (readonly auto-calc) ── --%>
                        <div class="request-field" id="valueField">
                            <label for="value" id="valueLabel">Số ngày nghỉ (tự động tính)</label>
                            <input id="value" type="number" name="value" step="0.5" min="0"
                                   placeholder="Chọn khoảng thời gian..." readonly
                                   style="background:#f3f4f6;color:#6b7280;">
                            <span class="inline-error" id="valueError"></span>
                        </div>

                        <%-- ── Section: Tài liệu & Lý do ── --%>
                        <div class="section-divider"><hr><span>Tài liệu & Lý do</span><hr></div>

                        <%-- ── File upload ── --%>
                        <div class="request-field" id="imageField">
                            <label id="imageLabel">Ảnh minh chứng</label>
                            <div class="file-input-wrapper">
                                <label class="file-input-label" id="fileLabel" for="image">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
                                        <polyline points="17 8 12 3 7 8"/>
                                        <line x1="12" y1="3" x2="12" y2="15"/>
                                    </svg>
                                    <span id="fileLabelText">Nhấn để chọn ảnh...</span>
                                </label>
                                <input id="image" type="file" name="image" accept="image/*">
                            </div>
                            <div id="file-chosen"></div>
                            <span class="inline-error" id="imageError">Vui lòng đính kèm ảnh minh chứng bắt buộc.</span>
                        </div>

                        <%-- ── Lý do ── --%>
                        <div class="request-field" id="reasonField">
                            <label for="reason">Lý do / Nội dung</label>
                            <textarea id="reason" name="reason" maxlength="255"
                                      placeholder="Nhập lý do hoặc nội dung chi tiết..."></textarea>
                        </div>

                    </div><%-- end grid --%>

                    <div class="request-notice">
                        Sau khi gửi, đơn sẽ ở trạng thái <strong>Chờ duyệt (Pending)</strong> và được chuyển đến quản lý phê duyệt.
                    </div>

                    <div class="request-actions" style="flex-direction:column;align-items:flex-end;">
                        <div style="display:flex;gap:10px;">
                            <a href="<%= request.getContextPath() %>/requests?action=myRequests"
                               class="btn btn-secondary">Danh sách đơn</a>
                            <button type="reset" class="btn btn-secondary" id="resetBtn">Nhập lại</button>
                            <button type="submit" class="btn btn-primary" id="submitBtn">Gửi đơn</button>
                        </div>
                        <div class="submit-block-hint" id="submitBlockHint"></div>
                    </div>
                </form>
            </div>
        </section>
    </main>
    <footer>© 2026 Hệ thống Quản lý Nhân sự (EMS) · FPT University SWP391</footer>
</div>

<script>
(function () {
    /* ── Constants from server ── */
    var REMAINING_DAYS = <%= remainingDays %>;
    var USED_DAYS      = <%= usedDaysVal %>;
    var TOTAL_DAYS     = <%= totalDaysVal %>;
    var HAS_BALANCE    = <%= hasBalanceRecord %>;
    var ANNUAL_EXHAUSTED = <%= annualLeaveExhausted %>;
    var GENDER = '<%= genderStr %>'; // "male" | "female" | "unknown"

    /* ── Leave type config ── */
    var TYPE_CONFIG = {
        ANNUAL: {
            maxDays: HAS_BALANCE ? REMAINING_DAYS : 9999,
            requireFile: false,
            fileRequired: false,
            infoClass: ANNUAL_EXHAUSTED ? 'warning' : 'good',
            info: ANNUAL_EXHAUSTED
                ? '⛔ Bạn đã sử dụng hết <strong>' + USED_DAYS + '/' + TOTAL_DAYS + ' ngày phép năm</strong>. Vui lòng chọn loại đơn khác.'
                : '📋 Nghỉ phép năm · Đã dùng <strong>' + USED_DAYS + '/' + TOTAL_DAYS + ' ngày</strong>. Còn lại: <strong>' + REMAINING_DAYS + ' ngày</strong>.'
        },
        UNPAID: {
            maxDays: 30,
            requireFile: false,
            fileRequired: false,
            infoClass: 'warning',
            info: '💸 Nghỉ không lương · Tối đa <strong>30 ngày/năm</strong>. Thường áp dụng sau khi đã sử dụng hết phép năm.'
        },
        SICK: {
            maxDays: 60,
            requireFile: false, // required only if > 3 days (checked at runtime)
            fileRequired: false,
            infoClass: 'info',
            info: '🏥 Nghỉ ốm · Tối đa <strong>60 ngày/năm</strong> hưởng BHXH. Nếu nghỉ trên <strong>3 ngày</strong> phải đính kèm giấy xác nhận y tế.'
        },
        MARRIAGE: {
            maxDays: 3,
            requireFile: true,
            fileRequired: true,
            infoClass: 'info',
            info: '💒 Nghỉ kết hôn · Được hưởng lương tối đa <strong>3 ngày</strong>. Phần vượt quá sẽ tính vào nghỉ không lương hoặc phép năm. <strong>Bắt buộc đính kèm giấy đăng ký kết hôn.</strong>'
        },
        CHILD_MARRIAGE: {
            maxDays: 1,
            requireFile: true,
            fileRequired: true,
            infoClass: 'info',
            info: '👨‍👧 Nghỉ con kết hôn · Được hưởng lương tối đa <strong>1 ngày</strong>. <strong>Bắt buộc đính kèm giấy tờ chứng minh.</strong>'
        },
        FUNERAL: {
            maxDays: 3,
            requireFile: true,
            fileRequired: true,
            infoClass: 'warning',
            info: '🕊️ Nghỉ tang · Cha/mẹ/vợ/chồng/con được hưởng lương tối đa <strong>3 ngày</strong>. <strong>Bắt buộc đính kèm giấy báo tử hoặc giấy tờ liên quan.</strong>'
        },
        MATERNITY: {
            maxDays: GENDER === 'male' ? 14 : 180,
            requireFile: true,
            fileRequired: true,
            infoClass: GENDER === 'male' ? 'info' : 'success',
            info: GENDER === 'male'
                ? '🍼 Nghỉ thai sản (Nam) · Tối đa <strong>5–14 ngày</strong> tùy trường hợp sinh thường/mổ/sinh đôi. <strong>Bắt buộc đính kèm giấy khai sinh/chứng sinh.</strong>'
                : '🍼 Nghỉ thai sản (Nữ) · Tối đa <strong>6 tháng (180 ngày)</strong> trước và sau sinh. <strong>Bắt buộc đính kèm giấy khai sinh/chứng sinh.</strong>'
        }
    };

    /* ── DOM refs ── */
    var typeSelect   = document.getElementById('leaveTypeSelect');
    var typeCodeInput = document.getElementById('requestTypeCode');
    var titleInput   = document.getElementById('title');
    var startInput   = document.getElementById('startDate');
    var endInput     = document.getElementById('endDate');
    var valueInput   = document.getElementById('value');
    var valueLabel   = document.getElementById('valueLabel');
    var imageInput   = document.getElementById('image');
    var imageLabel   = document.getElementById('imageLabel');
    var fileLabel    = document.getElementById('fileLabel');
    var fileLabelText = document.getElementById('fileLabelText');
    var fileChosen   = document.getElementById('file-chosen');
    var infoPanel    = document.getElementById('typeInfoPanel');
    var infoPanelWrapper = document.getElementById('infoPanelWrapper');
    var resetBtn     = document.getElementById('resetBtn');
    var form         = document.getElementById('leaveForm');

    /* ── Set today as min date ── */
    var now = new Date();
    document.getElementById('topbar-date').textContent =
        pad(now.getDate()) + '/' + pad(now.getMonth() + 1) + '/' + now.getFullYear();
    var todayStr = now.getFullYear() + '-' + pad(now.getMonth() + 1) + '-' + pad(now.getDate());
    startInput.min = todayStr;
    endInput.min   = todayStr;

    function pad(n) { return String(n).padStart(2, '0'); }

    function isWeekend(dateStr) {
        if (!dateStr) return false;
        var d = new Date(dateStr + 'T00:00:00');
        return d.getDay() === 0 || d.getDay() === 6;
    }

    /* ── Calculate working days (exclude weekends) ── */
    function calcWorkingDays(startStr, endStr) {
        if (!startStr || !endStr) return 0;
        var s = new Date(startStr + 'T00:00:00');
        var e = new Date(endStr + 'T00:00:00');
        if (s > e) return 0;
        var count = 0;
        var cur = new Date(s);
        while (cur <= e) {
            var day = cur.getDay();
            if (day !== 0 && day !== 6) count++;
            cur.setDate(cur.getDate() + 1);
        }
        return count;
    }

    /* ── Show/hide elements ── */
    function show(el) { if (el) el.style.display = ''; }
    function hide(el) { if (el) el.style.display = 'none'; }
    function showError(id, msg) {
        var el = document.getElementById(id);
        if (el) { el.textContent = msg || el.textContent; el.classList.add('show'); }
    }
    function hideError(id) {
        var el = document.getElementById(id);
        if (el) el.classList.remove('show');
    }
    function showWeekendWarn(id) {
        var el = document.getElementById(id);
        if (el) el.classList.add('show');
    }
    function hideWeekendWarn(id) {
        var el = document.getElementById(id);
        if (el) el.classList.remove('show');
    }

    /* ── Update UI based on selected leave type ── */
    function onTypeChange() {
        var code = typeSelect.value;
        typeCodeInput.value = code;

        hideError('typeError');
        hideError('valueError');
        hideError('imageError');

        if (!code) {
            hide(infoPanelWrapper);
            valueLabel.textContent = 'Số ngày nghỉ (tự động tính)';
            fileLabel.classList.remove('required-file');
            imageLabel.innerHTML = 'Ảnh minh chứng';
            unblockSubmit();
            return;
        }

        // Chặn ngay nếu chọn ANNUAL mà đã hết phép (dù chưa chọn ngày)
        if (code === 'ANNUAL' && ANNUAL_EXHAUSTED) {
            blockSubmit('⛔ Không thể gửi: đã sử dụng hết ' + TOTAL_DAYS + ' ngày phép năm.');
        } else {
            unblockSubmit(); // reset, calcAndSetDays sẽ block lại nếu cần
        }

        var cfg = TYPE_CONFIG[code];

        // Update info panel
        infoPanel.className = 'type-info-panel show ' + (cfg.infoClass === 'good' ? 'success' : cfg.infoClass === 'warning' ? 'warning' : 'info');
        infoPanel.innerHTML = cfg.info;
        show(infoPanelWrapper);

        // Update value label
        valueLabel.innerHTML = 'Số ngày nghỉ <span style="color:#6b7280;font-weight:400;">(tự động tính)</span>';

        // Update file requirement
        if (cfg.fileRequired) {
            fileLabel.classList.add('required-file');
            imageLabel.innerHTML = 'Ảnh minh chứng <span class="required">*</span>';
        } else {
            fileLabel.classList.remove('required-file');
            imageLabel.innerHTML = 'Ảnh minh chứng <span style="color:#6b7280;font-weight:400;">(nếu cần)</span>';
        }

        // Recalculate days when type changes
        calcAndSetDays();
    }

    /* ── Disable / enable submit button ── */
    var submitBtn  = document.getElementById('submitBtn');
    var submitHint = document.getElementById('submitBlockHint');

    function blockSubmit(msg) {
        submitBtn.disabled = true;
        submitHint.textContent = msg;
        submitHint.classList.add('show');
    }
    function unblockSubmit() {
        submitBtn.disabled = false;
        submitHint.textContent = '';
        submitHint.classList.remove('show');
    }

    /* ── Calculate and set days ── */
    function calcAndSetDays() {
        var code = typeSelect.value;
        if (!startInput.value || !endInput.value) {
            valueInput.value = '';
            unblockSubmit();
            return;
        }

        var days = calcWorkingDays(startInput.value, endInput.value);
        valueInput.value = days > 0 ? days : 0;

        // Per-type inline warnings
        hideError('valueError');
        if (!code || days === 0) {
            unblockSubmit();
            return;
        }

        var cfg = TYPE_CONFIG[code];

        // Special: sick leave file requirement depends on days
        if (code === 'SICK') {
            if (days > 3) {
                fileLabel.classList.add('required-file');
                imageLabel.innerHTML = 'Ảnh minh chứng <span class="required">* Bắt buộc nếu > 3 ngày</span>';
            } else {
                fileLabel.classList.remove('required-file');
                imageLabel.innerHTML = 'Ảnh minh chứng <span style="color:#6b7280;font-weight:400;">(nếu cần)</span>';
            }
        }

        // ── Hard-block: disable submit khi vượt giới hạn ──
        var isHardBlock = false;
        if (code === 'ANNUAL') {
            if (ANNUAL_EXHAUSTED) {
                showError('valueError', '⛔ Bạn đã sử dụng hết ' + USED_DAYS + '/' + TOTAL_DAYS + ' ngày phép năm. Không thể gửi đơn.');
                blockSubmit('⛔ Không thể gửi: đã hết ' + TOTAL_DAYS + ' ngày phép năm.');
                isHardBlock = true;
            } else if (days > REMAINING_DAYS) {
                // REMAINING_DAYS = TOTAL_DAYS (mặc định 12) nếu chưa có record
                showError('valueError', '⛔ Số ngày xin nghỉ (' + days + ' ngày) vượt quá phép năm còn lại (' + REMAINING_DAYS + ' ngày). Đã dùng: ' + USED_DAYS + '/' + TOTAL_DAYS + ' ngày.');
                blockSubmit('⛔ Không thể gửi: ' + days + ' ngày > phép còn lại (' + REMAINING_DAYS + ' ngày).');
                isHardBlock = true;
            }
        } else if (code === 'MATERNITY') {
            if (GENDER === 'male' && days > 14) {
                showError('valueError', '⚠️ Nam giới nghỉ thai sản tối đa 14 ngày theo quy định.');
                blockSubmit('⛔ Không thể gửi: vượt quá 14 ngày (nam giới).');
                isHardBlock = true;
            } else if (GENDER === 'female' && days > 180) {
                showError('valueError', '⚠️ Nghỉ thai sản tối đa 6 tháng (180 ngày) theo quy định.');
                blockSubmit('⛔ Không thể gửi: vượt quá 180 ngày.');
                isHardBlock = true;
            }
        } else if (code === 'UNPAID' && days > 30) {
            showError('valueError', '⚠️ Nghỉ không lương tối đa 30 ngày/năm.');
            blockSubmit('⛔ Không thể gửi: vượt quá 30 ngày không lương/năm.');
            isHardBlock = true;
        }

        if (!isHardBlock) {
            unblockSubmit();

            // Soft warnings (chỉ hiện cảnh báo, không chặn)
            if (days > cfg.maxDays) {
                var typeNames = {
                    ANNUAL:        'Nghỉ phép năm',
                    UNPAID:        'Nghỉ không lương',
                    SICK:          'Nghỉ ốm',
                    MARRIAGE:      'Nghỉ kết hôn',
                    CHILD_MARRIAGE:'Nghỉ con kết hôn',
                    FUNERAL:       'Nghỉ tang',
                    MATERNITY:     'Nghỉ thai sản'
                };
                var msg = '';
                if (code === 'MARRIAGE' || code === 'CHILD_MARRIAGE' || code === 'FUNERAL') {
                    msg = '⚠️ ' + typeNames[code] + ' được hưởng lương tối đa ' + cfg.maxDays + ' ngày. Phần còn lại (' + (days - cfg.maxDays) + ' ngày) sẽ tính vào nghỉ không lương hoặc phép năm.';
                    showError('valueError', msg);
                }
            }
        }
    }

    /* ── Date change handlers ── */
    startInput.addEventListener('change', function () {
        endInput.min = this.value;
        hideError('startDateError');

        // Weekend check
        if (isWeekend(this.value)) {
            showWeekendWarn('startWeekendWarn');
        } else {
            hideWeekendWarn('startWeekendWarn');
        }

        calcAndSetDays();
    });

    endInput.addEventListener('change', function () {
        hideError('endDateError');

        // End < Start check
        if (startInput.value && this.value < startInput.value) {
            showError('endDateError', 'Ngày kết thúc không được trước ngày bắt đầu.');
            this.classList.add('field-error');
        } else {
            this.classList.remove('field-error');
        }

        // Weekend check
        if (isWeekend(this.value)) {
            showWeekendWarn('endWeekendWarn');
        } else {
            hideWeekendWarn('endWeekendWarn');
        }

        calcAndSetDays();
    });

    typeSelect.addEventListener('change', onTypeChange);

    /* ── File change handler ── */
    imageInput.addEventListener('change', function () {
        hideError('imageError');
        if (this.files && this.files.length > 0) {
            var f = this.files[0];
            fileChosen.textContent = '✅ ' + f.name + ' (' + (f.size / 1024).toFixed(1) + ' KB)';
            fileChosen.classList.add('show');
            fileLabelText.textContent = 'Thay đổi ảnh...';
        } else {
            fileChosen.classList.remove('show');
            fileLabelText.textContent = 'Nhấn để chọn ảnh...';
        }
    });

    /* ── Reset handler ── */
    resetBtn.addEventListener('click', function () {
        typeCodeInput.value = '';
        hide(infoPanelWrapper);
        valueInput.value = '';
        fileChosen.classList.remove('show');
        fileLabelText.textContent = 'Nhấn để chọn ảnh...';
        fileLabel.classList.remove('required-file');
        imageLabel.innerHTML = 'Ảnh minh chứng';
        ['typeError','titleError','startDateError','endDateError','valueError','imageError']
            .forEach(hideError);
        ['startWeekendWarn','endWeekendWarn'].forEach(hideWeekendWarn);
        [startInput, endInput, valueInput].forEach(function(el) { el.classList.remove('field-error'); });
    });

    /* ── Form submit validation ── */
    form.addEventListener('submit', function (e) {
        var hasError = false;

        // Type
        if (!typeSelect.value) {
            showError('typeError', 'Vui lòng chọn loại đơn.');
            hasError = true;
        } else { hideError('typeError'); }

        // Title
        if (!titleInput.value.trim()) {
            showError('titleError', 'Vui lòng nhập tiêu đề.');
            titleInput.classList.add('field-error');
            hasError = true;
        } else { hideError('titleError'); titleInput.classList.remove('field-error'); }

        // Start date
        if (!startInput.value) {
            showError('startDateError', 'Vui lòng chọn ngày bắt đầu.');
            startInput.classList.add('field-error');
            hasError = true;
        } else {
            // Past check
            if (startInput.value < todayStr) {
                showError('startDateError', 'Ngày bắt đầu không được ở trong quá khứ.');
                startInput.classList.add('field-error');
                hasError = true;
            } else {
                hideError('startDateError');
                startInput.classList.remove('field-error');
            }
        }

        // End date
        if (!endInput.value) {
            showError('endDateError', 'Vui lòng chọn ngày kết thúc.');
            endInput.classList.add('field-error');
            hasError = true;
        } else if (startInput.value && endInput.value < startInput.value) {
            showError('endDateError', 'Ngày kết thúc không được trước ngày bắt đầu.');
            endInput.classList.add('field-error');
            hasError = true;
        } else {
            hideError('endDateError');
            endInput.classList.remove('field-error');
        }

        // Per-type validation
        var code = typeSelect.value;
        var days = parseFloat(valueInput.value) || 0;
        if (code && days > 0) {
            var cfg = TYPE_CONFIG[code];

            // Annual leave: chặn nếu đã dùng hết phép năm
            if (code === 'ANNUAL') {
                if (ANNUAL_EXHAUSTED) {
                    showError('valueError', '⛔ Bạn đã sử dụng hết ' + USED_DAYS + '/' + TOTAL_DAYS + ' ngày phép năm. Không thể gửi đơn.');
                    hasError = true;
                } else if (HAS_BALANCE && days > REMAINING_DAYS) {
                    showError('valueError', '⚠️ Số ngày xin nghỉ (' + days + ' ngày) vượt quá phép còn lại (' + REMAINING_DAYS + ' ngày). Đã dùng: ' + USED_DAYS + '/' + TOTAL_DAYS + ' ngày.');
                    hasError = true;
                }
            }

            // File required types
            var needFile = cfg.fileRequired || (code === 'SICK' && days > 3);
            if (needFile && (!imageInput.files || imageInput.files.length === 0)) {
                showError('imageError', 'Vui lòng đính kèm ảnh minh chứng bắt buộc cho loại đơn này.');
                fileLabel.classList.add('required-file');
                hasError = true;
            }

            // Maternity strict block
            if (code === 'MATERNITY') {
                if (GENDER === 'male' && days > 14) {
                    showError('valueError', '⚠️ Nam giới nghỉ thai sản tối đa 14 ngày. Không thể gửi đơn.');
                    hasError = true;
                } else if (GENDER === 'female' && days > 180) {
                    showError('valueError', '⚠️ Nghỉ thai sản tối đa 180 ngày (6 tháng). Không thể gửi đơn.');
                    hasError = true;
                }
            }

            // Unpaid leave: block if > 30
            if (code === 'UNPAID' && days > 30) {
                showError('valueError', '⚠️ Nghỉ không lương tối đa 30 ngày/năm. Vui lòng điều chỉnh số ngày.');
                hasError = true;
            }
        }

        if (hasError) {
            e.preventDefault();
            // Scroll to first error
            var firstErr = form.querySelector('.inline-error.show, .field-error, .server-error');
            if (firstErr) firstErr.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    });

    /* ── Init if type was pre-selected (after server validation error) ── */
    if (typeSelect.value) {
        onTypeChange();
    }

}());
</script>
</body>
</html>