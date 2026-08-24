<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Lịch Làm Việc | EMS</title>
                <link rel="stylesheet" href="css/ems.css" />
                <link rel="preconnect" href="https://fonts.googleapis.com">
                <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
                <link
                    href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap"
                    rel="stylesheet">
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
                <link rel="stylesheet" href="css/work-schedule.css">
            </head>

            <body>

                <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>

                    <div class="main-content">
                        <div class="topbar">
                            <span class="topbar-left">Lịch Làm Việc</span>
                            <span class="topbar-right" id="topbar-date"></span>
                        </div>

                        <div class="page-body">
                            <div class="ws-page-header">
                                <div class="ws-page-header-text">
                                    <h1><i class="fa-regular fa-calendar-days icon-primary"></i> Lịch
                                        Làm Việc</h1>
                                    <p>Quản lý lịch làm việc mặc định theo tuần của công ty</p>
                                </div>
                                <div class="ws-page-header-actions">
                                    <a href="${pageContext.request.contextPath}/work-schedule/export-attendance"
                                        class="btn btn-secondary">
                                        <i class="fa-solid fa-file-excel"></i> Xuất Excel chấm công
                                    </a>
                                    <c:choose>
                                        <c:when test="${hasSchedule}">
                                            <button class="btn btn-primary" onclick="openModal('edit')">
                                                <i class="fa-solid fa-pen-to-square"></i> Chỉnh sửa lịch làm việc
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button class="btn btn-primary" onclick="openModal('add')">
                                                <i class="fa-solid fa-plus"></i> Thêm lịch làm việc
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <%-- ── Display card (read-only) ── --%>
                                <c:choose>
                                    <c:when test="${!hasSchedule}">
                                        <div class="empty-card">
                                            <div class="empty-icon"><i class="fa-regular fa-calendar-xmark"></i></div>
                                            <h2>Chưa có lịch làm việc</h2>
                                            <p>Công ty chưa thiết lập lịch làm việc mặc định theo tuần.</p>
                                            <button class="btn btn-primary" onclick="openModal('add')">
                                                <i class="fa-solid fa-plus"></i> Thêm lịch làm việc
                                            </button>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="schedule-card">
                                            <div class="schedule-card-header">
                                                <div class="schedule-card-header-left">
                                                    <span class="schedule-card-title">Lịch làm việc theo tuần</span>
                                                    <c:set var="workingCount" value="0" />
                                                    <c:forEach var="shift" items="${shifts}">
                                                        <c:if test="${shift.working}">
                                                            <c:set var="workingCount" value="${workingCount + 1}" />
                                                        </c:if>
                                                    </c:forEach>
                                                    <span class="active-days-badge"><i
                                                            class="fa-solid fa-check-circle"></i> ${workingCount} ngày
                                                        làm việc / tuần</span>
                                                </div>
                                                <span class="update-info"><i class="fa-regular fa-clock"></i> Cập nhật
                                                    bởi
                                                    Administrator</span>
                                            </div>
                                            <div class="table-responsive">
                                                <table class="schedule-table">
                                                    <thead>
                                                        <tr>
                                                            <th>Ngày</th>
                                                            <th>Bắt Đầu</th>
                                                            <th>Kết Thúc</th>
                                                            <th>Nghỉ Trưa</th>
                                                            <th class="col-working-center">Làm Việc</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:forEach var="shift" items="${shifts}">
                                                            <tr class="${!shift.working ? 'inactive-row' : ''}">
                                                                <td><span class="day-name">
                                                                        <c:choose>
                                                                            <c:when test="${shift.dayOfWeek==2}">Thứ Hai
                                                                            </c:when>
                                                                            <c:when test="${shift.dayOfWeek==3}">Thứ Ba
                                                                            </c:when>
                                                                            <c:when test="${shift.dayOfWeek==4}">Thứ Tư
                                                                            </c:when>
                                                                            <c:when test="${shift.dayOfWeek==5}">Thứ Năm
                                                                            </c:when>
                                                                            <c:when test="${shift.dayOfWeek==6}">Thứ Sáu
                                                                            </c:when>
                                                                            <c:when test="${shift.dayOfWeek==7}">Thứ Bảy
                                                                            </c:when>
                                                                            <c:when test="${shift.dayOfWeek==1}">Chủ
                                                                                Nhật</c:when>
                                                                        </c:choose>
                                                                    </span></td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when
                                                                            test="${shift.working && shift.startTime != null}">
                                                                            <span class="time-chip"><i
                                                                                    class="fa-regular fa-clock"></i>
                                                                                ${shift.startTime}</span>
                                                                        </c:when>
                                                                        <c:otherwise><span class="dash-text">—</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when
                                                                            test="${shift.working && shift.endTime != null}">
                                                                            <span class="time-chip"><i
                                                                                    class="fa-regular fa-clock"></i>
                                                                                ${shift.endTime}</span>
                                                                        </c:when>
                                                                        <c:otherwise><span class="dash-text">—</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when
                                                                            test="${shift.working && shift.breakStart != null}">
                                                                            <div class="time-range"><span
                                                                                    class="time-chip"><i
                                                                                        class="fa-regular fa-clock"></i>
                                                                                    ${shift.breakStart}</span><span>–</span><span
                                                                                    class="time-chip"><i
                                                                                        class="fa-regular fa-clock"></i>
                                                                                    ${shift.breakEnd}</span></div>
                                                                        </c:when>
                                                                        <c:otherwise><span class="dash-text">—</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                                <td>
                                                                    <div class="schedule-working-center">
                                                                        <c:choose>
                                                                            <c:when test="${shift.working}">
                                                                                <span class="status-working">Làm
                                                                                    việc</span>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <span class="status-off">Ngày
                                                                                    nghỉ</span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </div>
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

                    <!-- ══════════════════════════════════════════════════════════════════
     MODAL
     ══════════════════════════════════════════════════════════════════ -->
                    <div class="modal-overlay" id="scheduleModal">
                        <div class="modal schedule-modal" role="dialog" aria-modal="true" aria-labelledby="modalTitle">

                            <div class="modal-header">
                                <div class="modal-header-left">
                                    <div class="modal-header-icon"><i class="fa-regular fa-calendar-days"
                                            id="modalIcon"></i></div>
                                    <div>
                                        <div class="modal-title" id="modalTitle">Thêm lịch làm việc</div>
                                        <div class="modal-subtitle">Định nghĩa khung giờ cho từng nhóm ngày trong tuần
                                        </div>
                                    </div>
                                </div>
                                <button class="modal-close" onclick="closeModal()" aria-label="Đóng" title="Đóng">
                                    <i class="fa-solid fa-xmark"></i>
                                </button>
                            </div>

                            <%-- Effective date banner – nổi bật ngay dưới header --%>
                                <div class="effective-banner">
                                    <div class="effective-banner-icon"><i class="fa-solid fa-calendar-check"></i></div>
                                    <div class="effective-banner-body">
                                        <strong>Ngày bắt đầu áp dụng</strong>
                                        <!-- <span>Lịch hiện tại sẽ được lưu lịch sử tự động — không mất dữ liệu cũ</span> -->
                                    </div>
                                    <input type="date" id="effectiveDatePicker" class="effective-date-input"
                                        value="${today}" min="${today}" aria-label="Chọn ngày bắt đầu áp dụng">
                                </div>

                                <div class="modal-body">
                                    <form id="scheduleForm" action="${pageContext.request.contextPath}/work-schedule"
                                        method="post">
                                        <input type="hidden" name="effectiveDate" id="effectiveDateHidden"
                                            value="${today}">
                                        <%-- 7 hidden inputs sẽ được inject bởi JS trước khi submit --%>

                                            <div class="modal-body-inner">
                                                <!-- Validation error -->
                                                <div class="validation-error" id="validationError">
                                                    <i class="fa-solid fa-circle-exclamation"></i>
                                                    <span id="validationMsg"></span>
                                                </div>

                                                <!-- Rule blocks -->
                                                <div class="rules-container" id="rulesContainer"></div>

                                                <!-- Nút thêm rule -->
                                                <!-- <button type="button" class="btn-add-rule" onclick="addRule()">
                                                    <i class="fa-solid fa-plus"></i> Thêm khung giờ
                                                </button> -->

                                                <!-- Preview strip -->
                                                <div class="preview-section">
                                                    <div class="preview-section-header">
                                                        <i class="fa-solid fa-eye" style="color:var(--primary);"></i>
                                                        Xem trước lịch tuần
                                                    </div>
                                                    <div class="preview-strip" id="previewStrip"></div>
                                                </div>
                                            </div>
                                    </form>
                                </div>

                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" onclick="closeModal()">
                                        <i class="fa-solid fa-xmark"></i> Hủy bỏ
                                    </button>
                                    <button type="button" class="btn btn-primary" onclick="submitSchedule()">
                                        <i class="fa-solid fa-floppy-disk"></i> Lưu lịch làm việc
                                    </button>
                                </div>
                        </div>
                    </div>

                    <!-- Toast -->
                    <div class="toast" id="toast">
                        <i class="fa-solid fa-circle-check"></i>
                        <span>Lịch làm việc đã được lưu thành công!</span>
                    </div>

                    <!-- ══════════════════════════════════════════════════════════════════
     JSTL → JS data bridge
     ══════════════════════════════════════════════════════════════════ -->
                    <script>
                        /* Dữ liệu từ server */
                        const _today = '${today}';
                        const _hasSchedule = ${ hasSchedule };
                        const _existingShifts = [
                            <c:forEach var="s" items="${shifts}" varStatus="st">
                                {
                                    dow:     ${s.dayOfWeek},
                                working: ${s.working},
                                start:   '<c:out value="${s.startTime  != null ? s.startTime  : '08:00'}" />',
                                end:     '<c:out value="${s.endTime    != null ? s.endTime    : '17:00'}" />',
                                bstart:  '<c:out value="${s.breakStart != null ? s.breakStart : '12:00'}" />',
                                bend:    '<c:out value="${s.breakEnd   != null ? s.breakEnd   : '13:00'}" />'
        }${!st.last ? ',' : ''}
                            </c:forEach>
                        ];
                    </script>

                    <script>
                        /* ══════════════════════════════════════════════════════════════
                           CONSTANTS
                           ══════════════════════════════════════════════════════════════ */
                        const DAYS = [
                            { dow: 2, label: 'T2', full: 'Thứ Hai', weekend: false },
                            { dow: 3, label: 'T3', full: 'Thứ Ba', weekend: false },
                            { dow: 4, label: 'T4', full: 'Thứ Tư', weekend: false },
                            { dow: 5, label: 'T5', full: 'Thứ Năm', weekend: false },
                            { dow: 6, label: 'T6', full: 'Thứ Sáu', weekend: false },
                            { dow: 7, label: 'T7', full: 'Thứ Bảy', weekend: true },
                            { dow: 1, label: 'CN', full: 'Chủ Nhật', weekend: true },
                        ];

                        /* Thứ tự submit khớp với vòng lặp for i=0..6 trong Servlet */
                        const SUBMIT_ORDER = [2, 3, 4, 5, 6, 7, 1]; // dow values

                        /* ══════════════════════════════════════════════════════════════
                           STATE
                           ══════════════════════════════════════════════════════════════ */
                        let rules = [];   // [{id, days: Set<dow>, start, end, bstart, bend, working}]
                        let ruleCounter = 0;

                        /* ══════════════════════════════════════════════════════════════
                           INIT
                           ══════════════════════════════════════════════════════════════ */
                        function getDaysInRange(fromDow, toDow) {
                            const fi = DAYS.findIndex(d => d.dow === fromDow);
                            const ti = DAYS.findIndex(d => d.dow === toDow);
                            const result = new Set();
                            if (fi <= ti) {
                                for (let i = fi; i <= ti; i++) result.add(DAYS[i].dow);
                            } else {
                                for (let i = fi; i < DAYS.length; i++) result.add(DAYS[i].dow);
                                for (let i = 0; i <= ti; i++) result.add(DAYS[i].dow);
                            }
                            return result;
                        }

                        function findRangeFromDays(daysSet) {
                            if (daysSet.size === 0) return { fromDow: DAYS[0].dow, toDow: DAYS[0].dow };
                            if (daysSet.size === DAYS.length) return { fromDow: DAYS[0].dow, toDow: DAYS[DAYS.length - 1].dow };
                            for (let startIdx = 0; startIdx < DAYS.length; startIdx++) {
                                const rangeSet = new Set();
                                for (let k = 0; k < daysSet.size; k++) rangeSet.add(DAYS[(startIdx + k) % DAYS.length].dow);
                                if ([...daysSet].every(d => rangeSet.has(d)) && rangeSet.size === daysSet.size) {
                                    return {
                                        fromDow: DAYS[startIdx].dow,
                                        toDow: DAYS[(startIdx + daysSet.size - 1) % DAYS.length].dow
                                    };
                                }
                            }
                            const indices = [...daysSet].map(dow => DAYS.findIndex(d => d.dow === dow)).sort((a, b) => a - b);
                            return { fromDow: DAYS[indices[0]].dow, toDow: DAYS[indices[indices.length - 1]].dow };
                        }

                        function initRules() {
                            if (_hasSchedule && _existingShifts.length > 0) {
                                const groups = new Map();
                                _existingShifts.forEach(s => {
                                    const start = s.start.substring(0, 5);
                                    const end = s.end.substring(0, 5);
                                    const bstart = s.bstart.substring(0, 5);
                                    const bend = s.bend.substring(0, 5);
                                    const key = s.working + '|' + start + '|' + end + '|' + bstart + '|' + bend;
                                    if (!groups.has(key)) {
                                        groups.set(key, { days: new Set(), start, end, bstart, bend, working: s.working });
                                    }
                                    groups.get(key).days.add(s.dow);
                                });
                                groups.forEach(g => pushRule(g));
                            } else {
                                pushRule({ days: new Set([2, 3, 4, 5, 6]), start: '08:00', end: '17:00', bstart: '12:00', bend: '13:00', working: true });
                                pushRule({ days: new Set([7, 1]), start: '', end: '', bstart: '', bend: '', working: false });
                            }
                            renderAll();
                        }

                        function pushRule(data) {
                            let fromDay, toDay, days;
                            if (data.fromDay !== undefined && data.toDay !== undefined) {
                                fromDay = data.fromDay;
                                toDay = data.toDay;
                                days = getDaysInRange(fromDay, toDay);
                            } else if (data.days) {
                                const dset = data.days instanceof Set ? data.days : new Set(data.days);
                                if (dset.size > 0) {
                                    const r = findRangeFromDays(dset);
                                    fromDay = r.fromDow;
                                    toDay = r.toDow;
                                } else {
                                    fromDay = DAYS[0].dow;
                                    toDay = DAYS[0].dow;
                                }
                                days = getDaysInRange(fromDay, toDay);
                            } else {
                                fromDay = DAYS[0].dow;
                                toDay = DAYS[4].dow;
                                days = getDaysInRange(fromDay, toDay);
                            }
                            rules.push({
                                id: ++ruleCounter,
                                fromDay,
                                toDay,
                                days,
                                start: data.start || '08:00',
                                end: data.end || '17:00',
                                bstart: data.bstart || '12:00',
                                bend: data.bend || '13:00',
                                working: data.working !== false,
                            });
                        }

                        /* ══════════════════════════════════════════════════════════════
                           ADD / REMOVE RULE
                           ══════════════════════════════════════════════════════════════ */
                        function addRule() {
                            pushRule({ fromDay: DAYS[0].dow, toDay: DAYS[0].dow, start: '08:00', end: '17:00', bstart: '12:00', bend: '13:00', working: true });
                            renderAll();
                            const container = document.getElementById('rulesContainer');
                            container.lastElementChild && container.lastElementChild.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
                        }

                        function removeRule(id) {
                            if (rules.length <= 1) return;
                            rules = rules.filter(r => r.id !== id);
                            renderAll();
                        }

                        /* ══════════════════════════════════════════════════════════════
                           SYNC DOM → STATE
                           ══════════════════════════════════════════════════════════════ */
                        function syncFromDOM(id) {
                            const rule = rules.find(r => r.id === id);
                            if (!rule) return;
                            const el = document.getElementById('rule-' + id);
                            if (!el) return;

                            const fromSel = el.querySelector('[data-field="fromDay"]');
                            const toSel = el.querySelector('[data-field="toDay"]');
                            if (fromSel) rule.fromDay = +fromSel.value;
                            if (toSel) rule.toDay = +toSel.value;
                            rule.days = getDaysInRange(rule.fromDay, rule.toDay);

                            /* Times */
                            rule.start = el.querySelector('[data-field="start"]').value;
                            rule.end = el.querySelector('[data-field="end"]').value;
                            rule.bstart = el.querySelector('[data-field="bstart"]').value;
                            rule.bend = el.querySelector('[data-field="bend"]').value;

                            /* Working toggle */
                            rule.working = el.querySelector('[data-field="working"]').checked;
                        }


                        function syncAndRenderPreview(id) {
                            syncFromDOM(id);
                            updateWorkingUI(id);
                            renderPreview();
                            renderConflicts();
                        }

                        function updateWorkingUI(id) {
                            const rule = rules.find(r => r.id === id);
                            if (!rule) return;
                            const el = document.getElementById('rule-' + id);
                            if (!el) return;
                            const timeRow = el.querySelector('.rule-times-row');
                            const label = el.querySelector('.rule-working-label');
                            if (timeRow) timeRow.style.opacity = rule.working ? '1' : '0.35';
                            el.querySelectorAll('[data-field="start"],[data-field="end"],[data-field="bstart"],[data-field="bend"]')
                                .forEach(inp => inp.disabled = !rule.working);
                            if (label) {
                                label.textContent = rule.working ? 'Làm việc' : 'Nghỉ';
                                label.className = 'rule-working-label' + (rule.working ? '' : ' off');
                            }
                        }

                        /* ══════════════════════════════════════════════════════════════
                           RENDER
                           ══════════════════════════════════════════════════════════════ */
                        function renderAll() {
                            renderRules();
                            renderPreview();
                            renderConflicts();
                        }

                        function renderRules() {
                            const container = document.getElementById('rulesContainer');
                            container.innerHTML = '';
                            rules.forEach((rule, idx) => {
                                container.appendChild(buildRuleBlock(rule, idx + 1));
                            });
                        }

                        function onRangeDayChange(id) {
                            syncFromDOM(id);
                            const rule = rules.find(r => r.id === id);
                            if (!rule) return;
                            const el = document.getElementById('rule-' + id);
                            if (!el) return;
                            const fi = DAYS.findIndex(d => d.dow === rule.fromDay);
                            const ti = DAYS.findIndex(d => d.dow === rule.toDay);
                            const isWrap = fi > ti;
                            const row = el.querySelector('.day-range-row');
                            const badge = el.querySelector('.day-range-wrap-badge');
                            if (isWrap && !badge && row) {
                                const b = document.createElement('span');
                                b.className = 'day-range-wrap-badge';
                                b.innerHTML = '<i class="fa-solid fa-rotate"></i> Qua tuần';
                                row.appendChild(b);
                            } else if (!isWrap && badge) {
                                badge.remove();
                            }
                            renderPreview();
                            renderConflicts();
                        }

                        function buildRuleBlock(rule, index) {
                            const wrap = document.createElement('div');
                            wrap.className = 'rule-block';
                            wrap.id = 'rule-' + rule.id;

                            const fromOptions = DAYS.map(d =>
                                '<option value="' + d.dow + '"' + (d.dow === rule.fromDay ? ' selected' : '') + '>' + d.full + '</option>'
                            ).join('');
                            const toOptions = DAYS.map(d =>
                                '<option value="' + d.dow + '"' + (d.dow === rule.toDay ? ' selected' : '') + '>' + d.full + '</option>'
                            ).join('');

                            const canDelete = rules.length > 1;
                            const disAttr = rule.working ? '' : 'disabled';

                            const fi = DAYS.findIndex(d => d.dow === rule.fromDay);
                            const ti = DAYS.findIndex(d => d.dow === rule.toDay);
                            const isWrap = fi > ti;
                            const wrapBadge = isWrap
                                ? '<span class="day-range-wrap-badge"><i class="fa-solid fa-rotate"></i> Qua tuần</span>'
                                : '';

                            wrap.innerHTML =
                                '<!-- Header -->' +
                                '<div class="rule-header">' +
                                '<span class="rule-index-badge">' +
                                '<span class="rule-num">' + index + '</span> Khung giờ' +
                                '</span>' +
                                // '<button type="button" class="rule-delete-btn" onclick="removeRule(' + rule.id + ')" ' + (canDelete ? '' : 'disabled') + ' aria-label="Xóa khung giờ ' + index + '">' +
                                //     '<i class="fa-solid fa-trash-can"></i> Xóa' +
                                // '</button>' +
                                '</div>' +
                                '<!-- Body -->' +
                                '<div class="rule-body">' +
                                '<!-- Ngày áp dụng -->' +
                                '<div class="rule-row">' +
                                '<span class="rule-row-label">Áp dụng</span>' +
                                '<div class="day-range-row">' +
                                '<select class="day-range-select" data-field="fromDay" onchange="onRangeDayChange(' + rule.id + ')" aria-label="Từ ngày">' +
                                fromOptions +
                                '</select>' +
                                '<span class="day-range-sep">→</span>' +
                                '<select class="day-range-select" data-field="toDay" onchange="onRangeDayChange(' + rule.id + ')" aria-label="Đến ngày">' +
                                toOptions +
                                '</select>' +
                                wrapBadge +
                                '</div>' +
                                '</div>' +
                                '<!-- Giờ làm + Nghỉ trưa -->' +
                                '<div class="rule-row rule-times-row" style="opacity:' + (rule.working ? '1' : '0.35') + '">' +
                                '<span class="rule-row-label">Giờ làm</span>' +
                                '<div class="rule-times">' +
                                '<div class="rule-time-group">' +
                                '<input type="time" data-field="start" value="' + rule.start + '" ' + disAttr + ' oninput="syncAndRenderPreview(' + rule.id + ')" aria-label="Giờ bắt đầu">' +
                                '<span class="rule-time-sep">→</span>' +
                                '<input type="time" data-field="end" value="' + rule.end + '" ' + disAttr + ' oninput="syncAndRenderPreview(' + rule.id + ')" aria-label="Giờ kết thúc">' +
                                '</div>' +
                                '<div class="rule-time-divider"></div>' +
                                '<div class="rule-time-group">' +
                                '<span class="rule-row-label" style="min-width:auto;font-size:0.7rem;">Nghỉ trưa</span>' +
                                '<input type="time" data-field="bstart" value="' + rule.bstart + '" ' + disAttr + ' oninput="syncAndRenderPreview(' + rule.id + ')" aria-label="Bắt đầu nghỉ trưa">' +
                                '<span class="rule-time-sep">→</span>' +
                                '<input type="time" data-field="bend" value="' + rule.bend + '" ' + disAttr + ' oninput="syncAndRenderPreview(' + rule.id + ')" aria-label="Kết thúc nghỉ trưa">' +
                                '</div>' +
                                '</div>' +
                                '</div>' +
                                '<!-- Toggle trạng thái -->' +
                                '<div class="rule-row">' +
                                '<span class="rule-row-label">Trạng thái</span>' +
                                '<div class="rule-toggle-row">' +
                                '<label class="switch" aria-label="Bật/tắt làm việc">' +
                                '<input type="checkbox" data-field="working" ' + (rule.working ? 'checked' : '') + ' onchange="syncAndRenderPreview(' + rule.id + ')">' +
                                '<span class="slider"></span>' +
                                '</label>' +
                                '<span class="rule-working-label' + (rule.working ? '' : ' off') + '">' + (rule.working ? 'Làm việc' : 'Nghỉ') + '</span>' +
                                '</div>' +
                                '</div>' +
                                '</div>' +
                                '<!-- Conflict warning (ẩn mặc định, JS hiện khi cần) -->' +
                                '<div class="rule-conflict-warn" id="conflict-' + rule.id + '">' +
                                '<i class="fa-solid fa-triangle-exclamation"></i>' +
                                '<span id="conflict-msg-' + rule.id + '"></span>' +
                                '</div>';
                            return wrap;
                        }

                        /* ══════════════════════════════════════════════════════════════
                           PREVIEW STRIP
                           ══════════════════════════════════════════════════════════════ */
                        function renderPreview() {
                            /* Resolve: với mỗi dow, rule cuối trong list thắng */
                            const resolved = {}; // dow → {rule, count}
                            DAYS.forEach(d => { resolved[d.dow] = null; });

                            rules.forEach(rule => {
                                rule.days.forEach(dow => {
                                    if (!resolved[dow]) resolved[dow] = { rule, count: 0 };
                                    resolved[dow].count++;
                                    resolved[dow].rule = rule; // last wins
                                });
                            });

                            const strip = document.getElementById('previewStrip');
                            strip.innerHTML = '';

                            DAYS.forEach(d => {
                                const entry = resolved[d.dow];
                                const isConflict = entry && entry.count > 1;
                                const card = document.createElement('div');

                                let state, infoText;
                                if (!entry) {
                                    state = d.weekend ? 'state-weekend' : 'state-off';
                                    infoText = d.weekend ? 'Cuối tuần' : 'Chưa gán';
                                } else if (!entry.rule.working) {
                                    state = d.weekend ? 'state-weekend' : 'state-off';
                                    infoText = 'Nghỉ';
                                } else {
                                    state = 'state-work';
                                    const s = entry.rule.start || '--:--';
                                    const e = entry.rule.end || '--:--';
                                    infoText = s + '<br>' + e;
                                }

                                if (isConflict) state = 'state-conflict';

                                card.className = 'preview-day ' + state;
                                card.setAttribute('title', d.full);
                                card.innerHTML =
                                    (isConflict ? '<i class="fa-solid fa-triangle-exclamation preview-conflict-icon" title="Ngày này có trong nhiều khung giờ — khung cuối sẽ được áp dụng"></i>' : '') +
                                    '<span class="preview-day-name">' + d.label + '</span>' +
                                    '<div class="preview-day-dot"></div>' +
                                    '<span class="preview-day-info">' + infoText + '</span>';
                                strip.appendChild(card);
                            });
                        }

                        /* ══════════════════════════════════════════════════════════════
                           CONFLICT WARNINGS trên từng rule block
                           ══════════════════════════════════════════════════════════════ */
                        function renderConflicts() {
                            /* Đếm số rule chứa mỗi dow */
                            const dowCount = {};
                            rules.forEach(rule => rule.days.forEach(dow => { dowCount[dow] = (dowCount[dow] || 0) + 1; }));

                            rules.forEach(rule => {
                                const conflictDays = [...rule.days].filter(dow => dowCount[dow] > 1);
                                const warnEl = document.getElementById('conflict-' + rule.id);
                                const msgEl = document.getElementById('conflict-msg-' + rule.id);
                                const blockEl = document.getElementById('rule-' + rule.id);
                                if (!warnEl || !msgEl || !blockEl) return;

                                if (conflictDays.length > 0) {
                                    const labels = conflictDays.map(dow => DAYS.find(d => d.dow === dow)?.label).join(', ');
                                    msgEl.textContent = 'Ngày ' + labels + ' xuất hiện ở nhiều khung giờ — khung giờ cuối trong danh sách sẽ được áp dụng.';
                                    warnEl.classList.add('show');
                                    blockEl.classList.add('has-conflict');
                                } else {
                                    warnEl.classList.remove('show');
                                    blockEl.classList.remove('has-conflict');
                                }
                            });
                        }

                        /* ══════════════════════════════════════════════════════════════
                           SUBMIT
                           ══════════════════════════════════════════════════════════════ */
                        function submitSchedule() {
                            /* Sync tất cả rules từ DOM */
                            rules.forEach(r => syncFromDOM(r.id));

                            /* Validate: mỗi dow phải được cover ít nhất 1 lần */
                            /* (Bỏ qua — user có thể muốn để ngày nào đó không có rule → mặc định OFF) */

                            /* Validate: không có rule nào với days = empty */
                            const emptyRules = rules.filter(r => r.days.size === 0);
                            if (emptyRules.length > 0) {
                                showValidation('Một hoặc nhiều khung giờ chưa chọn ngày. Vui lòng chọn ít nhất 1 ngày cho mỗi khung giờ, hoặc xóa khung giờ trống.');
                                return;
                            }

                            /* Validate giờ khi working=true */
                            for (const r of rules) {
                                if (r.working && (!r.start || !r.end)) {
                                    showValidation('Khung giờ đang làm việc cần có giờ bắt đầu và kết thúc.');
                                    return;
                                }
                            }

                            hideValidation();

                            /* Resolve 7 ngày (last rule wins) */
                            const resolved = {}; // dow → rule
                            rules.forEach(rule => rule.days.forEach(dow => { resolved[dow] = rule; }));

                            /* Xóa hidden inputs cũ (nếu re-submit) */
                            document.querySelectorAll('#scheduleForm input[data-generated]').forEach(el => el.remove());

                            /* Inject 7 hidden inputs theo SUBMIT_ORDER (i=0..6) */
                            const form = document.getElementById('scheduleForm');
                            SUBMIT_ORDER.forEach((dow, i) => {
                                const rule = resolved[dow];
                                const w = rule ? rule.working : false;

                                injectHidden(form, 'dayOfWeek_' + i, dow, i);
                                injectHidden(form, 'working_' + i, w ? 'true' : '', i);
                                injectHidden(form, 'startTime_' + i, (rule && w) ? rule.start : '', i);
                                injectHidden(form, 'endTime_' + i, (rule && w) ? rule.end : '', i);
                                injectHidden(form, 'breakStart_' + i, (rule && w) ? rule.bstart : '', i);
                                injectHidden(form, 'breakEnd_' + i, (rule && w) ? rule.bend : '', i);
                            });

                            /* Đồng bộ effectiveDate */
                            const picker = document.getElementById('effectiveDatePicker');
                            if (picker && picker.value) document.getElementById('effectiveDateHidden').value = picker.value;

                            form.submit();
                        }

                        function injectHidden(form, name, value, idx) {
                            const inp = document.createElement('input');
                            inp.type = 'hidden';
                            inp.name = name;
                            inp.value = value;
                            inp.setAttribute('data-generated', idx);
                            form.appendChild(inp);
                        }

                        function showValidation(msg) {
                            const el = document.getElementById('validationError');
                            document.getElementById('validationMsg').textContent = msg;
                            el.classList.add('show');
                            el.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
                        }
                        function hideValidation() {
                            document.getElementById('validationError').classList.remove('show');
                        }

                        /* ══════════════════════════════════════════════════════════════
                           MODAL OPEN / CLOSE
                           ══════════════════════════════════════════════════════════════ */
                        function openModal(mode) {
                            const modal = document.getElementById('scheduleModal');
                            const title = document.getElementById('modalTitle');
                            const icon = document.getElementById('modalIcon');
                            title.textContent = mode === 'edit' ? 'Chỉnh sửa lịch làm việc' : 'Thêm lịch làm việc';
                            icon.className = mode === 'edit' ? 'fa-solid fa-pen-to-square' : 'fa-regular fa-calendar-plus';
                            modal.classList.add('open');
                            document.body.style.overflow = 'hidden';
                        }
                        function closeModal() {
                            document.getElementById('scheduleModal').classList.remove('open');
                            document.body.style.overflow = '';
                            hideValidation();
                        }
                        document.getElementById('scheduleModal').addEventListener('click', function (e) {
                            if (e.target === this) closeModal();
                        });
                        document.addEventListener('keydown', function (e) { if (e.key === 'Escape') closeModal(); });

                        /* ══════════════════════════════════════════════════════════════
                           TOAST + TOPBAR DATE
                           ══════════════════════════════════════════════════════════════ */
                        (function () {
                            var now = new Date(), p = n => String(n).padStart(2, '0');
                            document.getElementById('topbar-date').textContent =
                                p(now.getDate()) + '/' + p(now.getMonth() + 1) + '/' + now.getFullYear();

                            if (new URLSearchParams(window.location.search).get('saved') === '1') {
                                var t = document.getElementById('toast');
                                t.classList.add('show');
                                setTimeout(() => t.classList.remove('show'), 3500);
                                window.history.replaceState({}, '', window.location.pathname);
                            }
                        })();

                        /* ══════════════════════════════════════════════════════════════
                           BOOT
                           ══════════════════════════════════════════════════════════════ */
                        initRules();
                    </script>
            </body>

            </html>