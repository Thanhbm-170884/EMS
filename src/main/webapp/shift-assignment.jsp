<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.time.LocalDate" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    // Tính ngày hôm nay để truyền vào JSTL so sánh với batch startDate/endDate
    pageContext.setAttribute("today", LocalDate.now());
    // Lấy exportError từ session (nếu có) rồi xóa đi
    String exportErr = (String) session.getAttribute("exportError");
    if (exportErr != null) {
        pageContext.setAttribute("exportError", exportErr);
        session.removeAttribute("exportError");
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Phân Ca Nhân Viên | EMS</title>
    <meta name="description" content="Tạo và quản lý bảng phân ca làm việc cho nhân viên">
    <link rel="stylesheet" href="css/ems.css"/>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap"
          rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/shift-assignment.css"/>
</head>
<body>

<%@ include file="/WEB-INF/jspf/sidebar.jsp" %>

<div class="main-content">
    <div class="topbar">
        <span class="topbar-left">Phân ca nhân viên</span>
        <span class="topbar-right" id="topbar-date"></span>
    </div>

    <div class="page-body">
        <!-- Page header -->
        <div class="hol-page-header">
            <div class="hol-page-header-text">
                <h1>
                    <i class="fa-regular fa-calendar-days" style="color:var(--primary);"></i>
                    Phân Ca Nhân Viên
                </h1>
                <p>Gán ca làm việc cho nhân viên với quy tắc lặp linh hoạt.</p>
            </div>
            <button class="btn btn-primary" id="btnToggleForm" onclick="toggleForm()">
                <i class="fa-solid fa-plus"></i> Thêm phân ca
            </button>
        </div>

        <!-- Alert -->
        <c:if test="${not empty error}">
            <textarea id="saErrorMsgData" style="display:none">${fn:escapeXml(error)}</textarea>
            <script>window.__conflictError = true;</script>
        </c:if>
        <c:if test="${not empty exportError}">
            <div class="alert-error">
                <i class="fa-solid fa-circle-exclamation"></i>
                <span>${fn:escapeXml(exportError)}</span>
            </div>
        </c:if>
        <c:if test="${not empty successMsg}">
            <script>window.__autoToast = true;</script>
        </c:if>

        <!-- ── Layout 2 cột: Form + Calendar (n panel ẩn mặc định) ── -->
        <div id="formPanel" style="${(batch != null || not empty error) ? '' : 'display:none;'}">
            <div class="sa-layout">
                <!-- CỘT TRÁI: Form -->
                <div class="sa-form-card">
                    <form id="saForm" method="post" action="${pageContext.request.contextPath}/shift-assignment">
                        <input type="hidden" name="action" id="saAction" value="${batch != null ? 'update' : 'create'}">
                        <c:if test="${batch != null}">
                            <input type="hidden" name="id" value="${batch.id}">
                        </c:if>

                        <!-- Thông tin chung -->
                        <div class="sa-section-title">Thông tin chung</div>

                        <div class="sa-field">
                            <label for="saName">Tên bảng phân ca <span class="req">*</span></label>
                            <input type="text" id="saName" name="name" maxlength="100"
                                   placeholder="VD: Lịch T2-T6 tháng 8, Làm bù 26/12…"
                                   value="${batch != null ? fn:escapeXml(batch.name) : ''}" required>
                        </div>

                        <div class="sa-field">
                            <label for="saShift">Ca làm việc <span class="req">*</span></label>
                            <select id="saShift" name="shiftId" required onchange="updateBadge()">
                                <option value="">-- Chọn ca làm việc --</option>
                                <c:forEach var="s" items="${shiftOptions}">
                                    <option value="${s.id}"
                                            data-time="${s.starttime} - ${s.endtime}"
                                            data-abbr="${fn:substring(s.name,0,2)}"
                                        ${batch != null && batch.shiftId == s.id ? 'selected' : ''}>
                                            ${fn:escapeXml(s.name)}
                                        <c:if test="${s.starttime != null}"> (${s.starttime} - ${s.endtime})</c:if>
                                    </option>
                                </c:forEach>
                            </select>
                            <c:if test="${empty shiftOptions}">
                                <div style="margin-top:6px;font-size:12px;color:#ef4444;">
                                    <i class="fa-solid fa-triangle-exclamation"></i>
                                    Chưa có ca làm việc. <a href="${pageContext.request.contextPath}/shift-management">Tạo
                                    ca trước</a>
                                </div>
                            </c:if>
                        </div>

                        <!-- Thời gian áp dụng -->
                        <div class="sa-section-title">Thời gian áp dụng</div>

                        <div class="sa-row2">
                            <div class="sa-field">
                                <label for="saStartDate">Ngày bắt đầu <span class="req">*</span></label>
                                <input type="date" id="saStartDate" name="startDate"
                                       value="${batch != null ? batch.startDate : ''}" required
                                       onchange="triggerPreview()">
                            </div>
                            <div class="sa-field">
                                <label for="saEndDate">Ngày kết thúc</label>
                                <input type="date" id="saEndDate" name="endDate"
                                       value="${batch != null ? batch.endDate : ''}" onchange="triggerPreview()">
                            </div>
                        </div>

                        <!-- Lặp theo -->
                        <div class="sa-field">
                            <label>Lặp theo</label>
                            <div class="recur-box">
                                <!-- Dòng 1: chọn kiểu lặp + chu kỳ -->
                                <div class="recur-row">
                                    <select id="recurType" name="recurType"
                                            onchange="onRecurTypeChange(); triggerPreview();">
                                        <option value="NONE"    ${batch != null && batch.recurType == 'NONE'    ? 'selected' : ''}>
                                            Không lặp
                                        </option>
                                        <option value="WEEKLY"  ${batch == null || batch.recurType == 'WEEKLY'  ? 'selected' : ''}>
                                            Tuần
                                        </option>
                                        <option value="MONTHLY" ${batch != null && batch.recurType == 'MONTHLY' ? 'selected' : ''}>
                                            Tháng
                                        </option>
                                    </select>
                                    <span id="intervalLabel" style="font-size:13px;">Chu kỳ lặp</span>
                                    <input type="number" id="recurInterval" name="recurInterval" min="1" max="52"
                                           style="width:60px;" value="${batch != null ? batch.recurInterval : 1}"
                                           onchange="triggerPreview()">
                                    <span id="intervalUnit" style="font-size:13px;">Tuần</span>
                                </div>

                                <!-- WEEKLY: chọn ngày trong tuần -->
                                <div id="weeklyPanel">
                                    <div class="day-checks">
                                        <c:forEach var="day" items="${[2,3,4,5,6,7,1]}">
                                            <label class="day-check-label">
                                                <input type="checkbox" name="weekdays" value="${day}"
                                                       onchange="triggerPreview()"
                                                <c:if test="${batch != null}">
                                                <c:forEach var="wd" items="${batch.weekdays}">
                                                    ${wd == day ? 'checked' : ''}
                                                </c:forEach>
                                                </c:if>
                                                <c:if test="${batch == null}">
                                                    ${day >= 2 && day <= 6 ? 'checked' : ''}
                                                </c:if>
                                                >
                                                <c:choose>
                                                    <c:when test="${day==2}">T2</c:when>
                                                    <c:when test="${day==3}">T3</c:when>
                                                    <c:when test="${day==4}">T4</c:when>
                                                    <c:when test="${day==5}">T5</c:when>
                                                    <c:when test="${day==6}">T6</c:when>
                                                    <c:when test="${day==7}">T7</c:when>
                                                    <c:when test="${day==1}">CN</c:when>
                                                </c:choose>
                                            </label>
                                        </c:forEach>
                                    </div>
                                </div>

                                <!-- MONTHLY: chọn kiểu tháng -->
                                <div id="monthlyPanel" style="display:none;">
                                    <div class="recur-row">
                                        <label><input type="radio" name="monthlyType" value="WEEKDAY"
                                        ${batch == null || batch.monthlyType == 'WEEKDAY' || batch.monthlyType == null ? 'checked' : ''}
                                                      onchange="onMonthlyTypeChange(); triggerPreview();"> Vào</label>
                                        <select id="mWeekday" name="monthlyWeekday" onchange="triggerPreview()">
                                            <option value="2" ${batch != null && batch.monthlyWeekday == 2 ? 'selected':''}>
                                                Thứ Hai
                                            </option>
                                            <option value="3" ${batch != null && batch.monthlyWeekday == 3 ? 'selected':''}>
                                                Thứ Ba
                                            </option>
                                            <option value="4" ${batch != null && batch.monthlyWeekday == 4 ? 'selected':''}>
                                                Thứ Tư
                                            </option>
                                            <option value="5" ${batch != null && batch.monthlyWeekday == 5 ? 'selected':''}>
                                                Thứ Năm
                                            </option>
                                            <option value="6" ${batch != null && batch.monthlyWeekday == 6 ? 'selected':''}>
                                                Thứ Sáu
                                            </option>
                                            <option value="7" ${batch != null && batch.monthlyWeekday == 7 ? 'selected':''}>
                                                Thứ Bảy
                                            </option>
                                            <option value="1" ${batch != null && batch.monthlyWeekday == 1 ? 'selected':''}>
                                                Chủ Nhật
                                            </option>
                                        </select>
                                        <select id="mOccurrence" name="monthlyOccurrence" onchange="triggerPreview()">
                                            <option value="1"  ${batch != null && batch.monthlyOccurrence == 1  ? 'selected':''}>
                                                Đầu tiên của tháng
                                            </option>
                                            <option value="2"  ${batch != null && batch.monthlyOccurrence == 2  ? 'selected':''}>
                                                Thứ hai của tháng
                                            </option>
                                            <option value="3"  ${batch != null && batch.monthlyOccurrence == 3  ? 'selected':''}>
                                                Thứ ba của tháng
                                            </option>
                                            <option value="-1" ${batch != null && batch.monthlyOccurrence == -1 ? 'selected':''}>
                                                Cuối cùng của tháng
                                            </option>
                                        </select>
                                    </div>
                                    <div class="recur-row">
                                        <label><input type="radio" name="monthlyType" value="DATE"
                                        ${batch != null && batch.monthlyType == 'DATE' ? 'checked' : ''}
                                                      onchange="onMonthlyTypeChange(); triggerPreview();"> Vào
                                            ngày</label>
                                        <input type="number" id="mDay" name="monthlyDay" min="1" max="31"
                                               style="width:60px;"
                                               value="${batch != null && batch.monthlyDay != null ? batch.monthlyDay : 1}"
                                               onchange="triggerPreview()">
                                        <span style="font-size:13px;">trong tháng</span>
                                    </div>
                                </div>
                            </div><!-- /recur-box -->
                        </div><!-- /sa-field -->

                        <!-- Đối tượng áp dụng -->
                        <div class="sa-section-title">Đối tượng áp dụng</div>

                        <div class="scope-options">
                            <label class="scope-opt">
                                <input type="radio" name="scope" value="employees" id="scopeEmp"
                                ${batch == null || batch.employeeCount > 0 ? 'checked' : ''}
                                       onchange="onScopeChange()"> Danh sách nhân viên
                            </label>
                            <label class="scope-opt">
                                <input type="radio" name="scope" value="dept" id="scopeDept"
                                       onchange="onScopeChange()"> Theo phòng ban
                            </label>
                            <label class="scope-opt">
                                <input type="radio" name="scope" value="all" id="scopeAll"
                                       onchange="onScopeChange()"> Toàn bộ nhân viên
                            </label>
                        </div>

                        <!-- Panel chọn phòng ban -->
                        <div id="deptPanel" style="display:none;" class="sa-field">
                            <label for="deptSelect">Phòng ban</label>
                            <select id="deptSelect" name="deptId" onchange="loadDeptEmployees()">
                                <option value="">-- Chọn phòng ban --</option>
                                <c:forEach var="d" items="${departments}">
                                    <option value="${d.id}">${fn:escapeXml(d.name)}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- Bảng nhân viên -->
                        <div id="empPanel">
                            <div class="emp-search-wrap">
                                <i class="fa-solid fa-magnifying-glass search-icon"></i>
                                <input type="text" id="empSearch" placeholder="Tìm kiếm nhân viên..."
                                       oninput="filterEmployees()">
                            </div>
                            <div class="emp-table-wrap">
                                <table class="emp-table" id="empTable">
                                    <thead>
                                    <tr>
                                        <th style="width:32px;"><input type="checkbox" id="checkAll"
                                                                       onchange="toggleAll(this)"></th>
                                        <th>Mã NV</th>
                                        <th>Họ và tên</th>
                                        <th>Phòng ban</th>
                                    </tr>
                                    </thead>
                                    <tbody id="empTableBody">
                                    <c:forEach var="emp" items="${employees}">
                                        <tr>
                                            <td><input type="checkbox" name="employeeIds" value="${emp.id}"
                                                       class="emp-checkbox"
                                            <c:if test="${batch != null}">
                                            <c:forEach var="eid" items="${batch.employeeIds}">
                                                ${eid == emp.id ? 'checked' : ''}
                                            </c:forEach>
                                            </c:if>
                                            ></td>
                                            <td>${fn:escapeXml(emp.employeeCode)}</td>
                                            <td>${fn:escapeXml(emp.fullName)}</td>
                                            <td>${fn:escapeXml(emp.departmentName)}</td>
                                        </tr>
                                    </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                            <div class="emp-count-badge">
                                <span id="empCountLabel">Tổng số bản ghi: 0</span>
                            </div>
                        </div>

                        <!-- Preview link -->
                        <div style="text-align:right;margin-top:12px;">
                            <a href="#" onclick="triggerPreview(); return false;" style="color:#2563eb;font-size:13px;">
                                <i class="fa-solid fa-calendar-days"></i> Xem trước phân ca
                            </a>
                        </div>

                        <!-- Buttons -->
                        <div style="display:flex;gap:10px;margin-top:18px;justify-content:flex-end;">
                            <c:choose>
                                <c:when test="${batch != null}">
                                    <a href="${pageContext.request.contextPath}/shift-assignment"
                                       class="btn btn-secondary">
                                        <i class="fa-solid fa-xmark"></i> Hủy
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <button type="button" class="btn btn-secondary" onclick="toggleForm()">
                                        <i class="fa-solid fa-xmark"></i> Hủy
                                    </button>
                                </c:otherwise>
                            </c:choose>
                            <button type="submit" class="btn btn-success" id="btnSave">
                                <i class="fa-solid fa-floppy-disk"></i>
                                ${batch != null ? 'Cập nhật phân ca' : 'Lưu phân ca'}
                            </button>
                        </div>
                    </form>
                </div><!-- /col-left -->

                <!-- CỘT PHẢI: Calendar Preview -->
                <div class="cal-card">
                    <div class="cal-nav">
                        <button class="cal-nav-btn" id="calPrev" onclick="calGo(-1)">
                            <i class="fa-solid fa-chevron-left"></i>
                        </button>
                        <span class="cal-month-label" id="calLabel">Tháng 8/2026</span>
                        <button class="cal-nav-btn" id="calNext" onclick="calGo(1)">
                            <i class="fa-solid fa-chevron-right"></i>
                        </button>
                    </div>
                    <div class="cal-grid" id="calGrid"></div>
                    <div class="cal-legend">
                        <div class="cal-legend-dot"></div>
                        <span>Ngày có ca làm việc</span>
                    </div>
                    <div id="previewMsg" style="font-size:12px;color:#9ca3af;margin-top:8px;text-align:center;"></div>
                </div>
            </div><!-- /sa-layout -->
        </div><!-- /formPanel -->

        <!-- ── Bảng tổng hợp phân ca ── -->
        <div class="sa-summary-card">
            <div class="sa-summary-header">
        <span class="sa-summary-title">
          <i class="fa-solid fa-table-list" style="color:var(--primary);"></i>
          Bảng phân ca tổng hợp
        </span>
            </div>

            <c:choose>
                <c:when test="${empty batches}">
                    <div style="text-align:center;padding:32px;color:#9ca3af;">
                        <i class="fa-regular fa-calendar-xmark"
                           style="font-size:2rem;display:block;margin-bottom:8px;"></i>
                        Chưa có bảng phân ca nào.
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="overflow-x:auto;">
                        <table class="schedule-table">
                            <thead>
                            <tr>
                                <th>Tên bảng phân ca</th>
                                <th>Ca làm việc</th>
                                <th>Từ ngày</th>
                                <th>Đến ngày</th>
                                <th>Lặp theo</th>
                                <th>Số NV</th>
                                <th style="text-align:right;">Hành động</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="b" items="${batches}">
                                <tr>
                                    <td><strong>${fn:escapeXml(b.name)}</strong></td>
                                    <td>
                                        <span class="active-days-badge"
                                              style="font-size:11px;"> ${fn:escapeXml(b.shiftName)} </span>
                                        <br><small style="color:#6b7280;">${fn:escapeXml(b.shiftTime)}</small>
                                    </td>
                                    <td>
                                        <span class="date-text">${b.startDateStr}</span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${b.endDateStr != null}">
                                                <span class="date-text">${b.endDateStr}</span>
                                            </c:when>
                                            <c:otherwise><span class="dash-text">Không giới hạn</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${b.recurType == 'NONE'}">
                                                <span class="recur-badge recur-none">Không lặp</span>
                                            </c:when>
                                            <c:when test="${b.recurType == 'WEEKLY'}">
                                                <span class="recur-badge recur-weekly">Mỗi ${b.recurInterval} tuần</span>
                                                <c:if test="${not empty b.weekdays}">
                                                    <div class="recur-detail">
                                                        <c:forEach var="wd" items="${b.weekdays}" varStatus="st">
                                                            <c:choose>
                                                                <c:when test="${wd==2}">T2</c:when>
                                                                <c:when test="${wd==3}">T3</c:when>
                                                                <c:when test="${wd==4}">T4</c:when>
                                                                <c:when test="${wd==5}">T5</c:when>
                                                                <c:when test="${wd==6}">T6</c:when>
                                                                <c:when test="${wd==7}">T7</c:when>
                                                                <c:when test="${wd==1}">CN</c:when>
                                                            </c:choose>
                                                            <c:if test="${!st.last}">, </c:if>
                                                        </c:forEach>
                                                    </div>
                                                </c:if>
                                            </c:when>
                                            <c:when test="${b.recurType == 'MONTHLY'}">
                                                <span class="recur-badge recur-monthly">Mỗi ${b.recurInterval} tháng</span>
                                                <c:choose>
                                                    <c:when test="${b.monthlyType == 'DATE'}">
                                                        <div class="recur-detail">Vào ngày ${b.monthlyDay}</div>
                                                    </c:when>
                                                    <c:when test="${b.monthlyType == 'WEEKDAY'}">
                                                        <div class="recur-detail">
                                                            Vào
                                                            <c:choose>
                                                                <c:when test="${b.monthlyWeekday==2}">T2</c:when>
                                                                <c:when test="${b.monthlyWeekday==3}">T3</c:when>
                                                                <c:when test="${b.monthlyWeekday==4}">T4</c:when>
                                                                <c:when test="${b.monthlyWeekday==5}">T5</c:when>
                                                                <c:when test="${b.monthlyWeekday==6}">T6</c:when>
                                                                <c:when test="${b.monthlyWeekday==7}">T7</c:when>
                                                                <c:when test="${b.monthlyWeekday==1}">CN</c:when>
                                                            </c:choose>
                                                            <c:choose>
                                                                <c:when test="${b.monthlyOccurrence==1}"> đầu tiên</c:when>
                                                                <c:when test="${b.monthlyOccurrence==2}"> thứ hai</c:when>
                                                                <c:when test="${b.monthlyOccurrence==3}"> thứ ba</c:when>
                                                                <c:when test="${b.monthlyOccurrence==-1}"> cuối cùng</c:when>
                                                            </c:choose>
                                                        </div>
                                                    </c:when>
                                                </c:choose>
                                            </c:when>
                                        </c:choose>
                                    </td>
                                    <td style="text-align:center;">
                                        <span class="active-days-badge"
                                              style="font-size:11px;">${b.employeeCount}</span>
                                    </td>
                                    <td style="text-align:right;">
                                        <div class="action-btns">
                                            <%-- Tính xem batch này có active hôm nay không --%>
                                            <c:set var="bActive" value="false"/>
                                            <c:if test="${b.endDate != null}">
                                                <c:if test="${!today.isBefore(b.startDate) && !today.isAfter(b.endDate)}">
                                                    <c:set var="bActive" value="true"/>
                                                </c:if>
                                            </c:if>
                                            <c:choose>
                                                <c:when test="${bActive}">
                                                    <a href="${pageContext.request.contextPath}/shift-assignment/export-attendance?batchId=${b.id}"
                                                       class="btn btn-sm btn-success"
                                                       title="Export Excel chấm công hôm nay">
                                                        <i class="fa-solid fa-file-excel"></i>
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <button class="btn btn-sm btn-secondary" disabled
                                                            title="${b.endDate == null ? 'Batch chưa có ngày kết thúc' : (today.isAfter(b.endDate) ? 'Batch đã hết hạn' : 'Batch chưa bắt đầu')}"
                                                            style="opacity:0.45;cursor:not-allowed;">
                                                        <i class="fa-solid fa-file-excel"></i>
                                                    </button>
                                                </c:otherwise>
                                            </c:choose>
                                            <a href="${pageContext.request.contextPath}/shift-assignment?action=edit&id=${b.id}"
                                               class="btn btn-sm btn-secondary" title="Sửa">
                                                <i class="fa-solid fa-pen-to-square"></i>
                                            </a>
                                            <button class="btn btn-sm btn-danger" title="Xóa"
                                                    onclick="confirmDelete(${b.id},'${fn:escapeXml(b.name)}')">
                                                <i class="fa-solid fa-trash"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div><!-- /page-body -->

    <footer>© 2026 Hệ thống Quản lý Nhân sự (EMS) · FPT University SWP391</footer>
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
                    <div class="modal-title">Xác nhận xóa phân ca</div>
                    <div class="modal-subtitle">Hành động này không thể hoàn tác</div>
                </div>
            </div>
            <button class="modal-close" onclick="closeDeleteModal()"><i class="fa-solid fa-xmark"></i></button>
        </div>
        <div class="modal-body">
            <p>Bạn có chắc muốn xóa bảng phân ca "<strong id="deleteBatchName"></strong>"?</p>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-secondary" onclick="closeDeleteModal()">Hủy</button>
            <form id="deleteForm" method="post" action="${pageContext.request.contextPath}/shift-assignment"
                  style="display:inline;">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="id" id="deleteBatchId">
                <button type="submit" class="btn btn-danger"><i class="fa-solid fa-trash"></i> Xóa</button>
            </form>
        </div>
    </div>
</div>

<!-- ── Modal Conflict Ca ── -->
<style>
.conflict-modal-overlay {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.55);
    z-index: 9000;
    align-items: center;
    justify-content: center;
    padding: 16px;
    backdrop-filter: blur(3px);
}
.conflict-modal-overlay.open { display: flex; }
.conflict-modal {
    background: #fff;
    border-radius: 16px;
    box-shadow: 0 24px 64px rgba(0,0,0,0.22);
    width: 100%;
    max-width: 560px;
    max-height: 85vh;
    display: flex;
    flex-direction: column;
    animation: conflictSlideIn .22s cubic-bezier(.4,0,.2,1);
    overflow: hidden;
}
@keyframes conflictSlideIn {
    from { transform: translateY(-24px); opacity: 0; }
    to   { transform: translateY(0);     opacity: 1; }
}
.conflict-modal-head {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 20px 22px 16px;
    border-bottom: 1px solid #fee2e2;
    background: linear-gradient(135deg,#fff5f5 0%,#fff 100%);
    flex-shrink: 0;
}
.conflict-modal-icon {
    width: 46px; height: 46px;
    border-radius: 12px;
    background: rgba(239,68,68,0.12);
    display: flex; align-items: center; justify-content: center;
    font-size: 20px; color: #dc2626;
    flex-shrink: 0;
}
.conflict-modal-title { font-size: 16px; font-weight: 700; color: #1e293b; }
.conflict-modal-sub   { font-size: 12px; color: #94a3b8; margin-top: 2px; }
.conflict-modal-close {
    margin-left: auto;
    background: none; border: none;
    width: 32px; height: 32px;
    border-radius: 8px;
    cursor: pointer;
    color: #94a3b8;
    font-size: 16px;
    display: flex; align-items: center; justify-content: center;
    transition: background .15s, color .15s;
}
.conflict-modal-close:hover { background: #f1f5f9; color: #ef4444; }
.conflict-modal-body {
    padding: 18px 22px;
    overflow-y: auto;
    flex: 1;
}
.conflict-intro {
    font-size: 13.5px;
    color: #475569;
    margin-bottom: 14px;
    line-height: 1.6;
}
.conflict-intro strong { color: #dc2626; }
.conflict-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
    max-height: 320px;
    overflow-y: auto;
    padding-right: 4px;
}
.conflict-list::-webkit-scrollbar { width: 4px; }
.conflict-list::-webkit-scrollbar-track { background: #f8fafc; }
.conflict-list::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 4px; }
.conflict-item {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    padding: 10px 13px;
    background: #fef2f2;
    border: 1px solid #fecaca;
    border-radius: 10px;
    font-size: 13px;
}
.conflict-item-icon {
    color: #ef4444;
    font-size: 14px;
    margin-top: 1px;
    flex-shrink: 0;
}
.conflict-item-name { font-weight: 600; color: #1e293b; }
.conflict-item-shift {
    font-size: 11.5px;
    color: #64748b;
    margin-top: 2px;
}
.conflict-hint {
    margin-top: 14px;
    padding: 10px 13px;
    background: #fffbeb;
    border: 1px solid #fde68a;
    border-radius: 10px;
    font-size: 12.5px;
    color: #92400e;
    display: flex;
    gap: 8px;
    align-items: flex-start;
}
.conflict-modal-foot {
    padding: 14px 22px;
    border-top: 1px solid #f1f5f9;
    display: flex;
    justify-content: flex-end;
    flex-shrink: 0;
    background: #fafafa;
}
</style>

<div class="conflict-modal-overlay" id="conflictModal">
    <div class="conflict-modal" role="alertdialog" aria-modal="true" aria-labelledby="conflictModalTitle">
        <div class="conflict-modal-head">
            <div class="conflict-modal-icon">
                <i class="fa-solid fa-users-slash"></i>
            </div>
            <div>
                <div class="conflict-modal-title" id="conflictModalTitle">Xung đột ca làm việc</div>
                <div class="conflict-modal-sub">Một số nhân viên đã được xếp ca trong khung giờ này</div>
            </div>
            <button class="conflict-modal-close" onclick="closeConflictModal()" aria-label="Đóng">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <div class="conflict-modal-body">
            <p class="conflict-intro">
                Phát hiện <strong id="conflictCount">0</strong> nhân viên bị trùng ca.
                Vui lòng điều chỉnh lại ca hoặc danh sách nhân viên.
            </p>
            <div class="conflict-list" id="conflictList"></div>
            <div class="conflict-hint">
                <i class="fa-solid fa-lightbulb" style="color:#d97706;flex-shrink:0;margin-top:1px;"></i>
                <span>Kiểm tra lại <b>ngày áp dụng</b>, <b>ngày trong tuần</b> hoặc bỏ chọn các nhân viên bị xung đột.</span>
            </div>
        </div>
        <div class="conflict-modal-foot">
            <button class="btn btn-primary" onclick="closeConflictModal()">
                <i class="fa-solid fa-check"></i> Đã hiểu, chỉnh lại
            </button>
        </div>
    </div>
</div>

<!-- Toast -->
<div class="toast" id="toast">
    <i class="fa-solid fa-circle-check"></i>
    <span id="toastMsg">Phân ca đã được lưu thành công!</span>
</div>

<script>
    // ── Danh sách đầy đủ Id nhân viên, dùng khi scope = "all" ──
    var allEmployeeIds = [
        <c:forEach var="emp" items="${employees}" varStatus="st">${emp.id}<c:if test="${!st.last}">,</c:if></c:forEach>
    ];

    // ── Topbar date ──
    (function () {
        var n = new Date(), p = n => String(n).padStart(2, '0');
        document.getElementById('topbar-date').textContent =
            p(n.getDate()) + '/' + p(n.getMonth() + 1) + '/' + n.getFullYear();
    })();

    // ── Calendar state ──
    var calYear = new Date().getFullYear();
    var calMonth = new Date().getMonth(); // 0-indexed
    var applyDates = []; // ["2026-08-18", ...]
    var calBadgeText = '';

    function calGo(dir) {
        calMonth += dir;
        if (calMonth < 0) {
            calMonth = 11;
            calYear--;
        }
        if (calMonth > 11) {
            calMonth = 0;
            calYear++;
        }
        renderCalendar();
    }

    function renderCalendar() {
        var label = document.getElementById('calLabel');
        label.textContent = 'Tháng ' + (calMonth + 1) + '/' + calYear;

        var grid = document.getElementById('calGrid');
        grid.innerHTML = '';

        // Day headers
        ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'].forEach(function (d) {
            var el = document.createElement('div');
            el.className = 'cal-dow';
            el.textContent = d;
            grid.appendChild(el);
        });

        // First day of month
        var first = new Date(calYear, calMonth, 1);
        var startDow = first.getDay(); // 0=Sun

        // Cells from previous month
        for (var i = 0; i < startDow; i++) {
            var d = new Date(calYear, calMonth, 1 - (startDow - i));
            grid.appendChild(makeDay(d, true));
        }

        // Days of this month
        var daysInMonth = new Date(calYear, calMonth + 1, 0).getDate();
        for (var d2 = 1; d2 <= daysInMonth; d2++) {
            grid.appendChild(makeDay(new Date(calYear, calMonth, d2), false));
        }

        // Pad to complete row
        var total = startDow + daysInMonth;
        var remaining = (7 - (total % 7)) % 7;
        for (var i2 = 0; i2 < remaining; i2++) {
            var d3 = new Date(calYear, calMonth + 1, i2 + 1);
            grid.appendChild(makeDay(d3, true));
        }
    }

    function makeDay(date, otherMonth) {
        var el = document.createElement('div');
        el.className = 'cal-day' + (otherMonth ? ' other-month' : '');

        var iso = date.getFullYear() + '-' + pad(date.getMonth() + 1) + '-' + pad(date.getDate());
        var today = new Date();
        today.setHours(0, 0, 0, 0);
        if (date.getTime() === today.getTime()) el.classList.add('today');

        var num = document.createElement('span');
        num.textContent = date.getDate();
        el.appendChild(num);

        if (applyDates.indexOf(iso) >= 0) {
            el.classList.add('has-shift');
            var badge = document.createElement('div');
            badge.className = 'cal-badge';
            badge.textContent = calBadgeText || 'CA';
            el.appendChild(badge);
        }
        return el;
    }

    function pad(n) {
        return String(n).padStart(2, '0');
    }

    // ── Preview ──
    var previewTimer = null;

    function triggerPreview() {
        clearTimeout(previewTimer);
        previewTimer = setTimeout(doPreview, 400);
    }

    function doPreview() {
        var startDate = document.getElementById('saStartDate').value;
        var endDate = document.getElementById('saEndDate').value;
        var recurType = document.getElementById('recurType').value;
        var interval = document.getElementById('recurInterval').value;

        var weekdays = [];
        document.querySelectorAll('input[name=weekdays]:checked').forEach(function (cb) {
            weekdays.push(cb.value);
        });

        var monthlyType = '', monthlyWeekday = '', monthlyOccurrence = '', monthlyDay = '';
        if (recurType === 'MONTHLY') {
            var mTypeEl = document.querySelector('input[name=monthlyType]:checked');
            if (mTypeEl) monthlyType = mTypeEl.value;
            monthlyWeekday = document.getElementById('mWeekday').value;
            monthlyOccurrence = document.getElementById('mOccurrence').value;
            monthlyDay = document.getElementById('mDay').value;
        }

        // Badge text from selected shift
        var shiftEl = document.getElementById('saShift');
        if (shiftEl.selectedIndex > 0) {
            var abbr = shiftEl.options[shiftEl.selectedIndex].getAttribute('data-abbr') || 'CA';
            calBadgeText = abbr.toUpperCase();
        }

        var params = new URLSearchParams({
            action: 'preview', startDate, endDate, recurType,
            recurInterval: interval,
            weekdays: weekdays.join(','),
            monthlyType, monthlyWeekday, monthlyOccurrence, monthlyDay
        });

        var msg = document.getElementById('previewMsg');
        msg.textContent = 'Đang tính...';

        fetch('${pageContext.request.contextPath}/shift-assignment?' + params)
            .then(r => r.json())
            .then(function (dates) {
                applyDates = dates;
                msg.textContent = dates.length > 0 ? dates.length + ' ngày áp dụng' : 'Không có ngày nào';
                renderCalendar();
            })
            .catch(function () {
                msg.textContent = '';
            });
    }

    // ── Recur type change ──
    function onRecurTypeChange() {
        var v = document.getElementById('recurType').value;
        document.getElementById('weeklyPanel').style.display = v === 'WEEKLY' ? '' : 'none';
        document.getElementById('monthlyPanel').style.display = v === 'MONTHLY' ? '' : 'none';
        document.getElementById('intervalLabel').style.display = v === 'NONE' ? 'none' : '';
        document.getElementById('recurInterval').style.display = v === 'NONE' ? 'none' : '';
        document.getElementById('intervalUnit').textContent = v === 'MONTHLY' ? 'Tháng' : 'Tuần';
    }

    function onMonthlyTypeChange() {
        var v = document.querySelector('input[name=monthlyType]:checked');
        var isDate = v && v.value === 'DATE';
        document.getElementById('mWeekday').disabled = isDate;
        document.getElementById('mOccurrence').disabled = isDate;
        document.getElementById('mDay').disabled = !isDate;
    }

    // ── Snapshot nội dung bảng nhân viên gốc (server-rendered) ──
    // Được ghi 1 lần khi trang load; dùng để phục hồi khi scope quay lại "employees"
    var _origEmpTableHTML = null;

    // ── Scope change ──
    function onScopeChange() {
        var v = document.querySelector('input[name=scope]:checked').value;
        document.getElementById('deptPanel').style.display = v === 'dept' ? '' : 'none';
        document.getElementById('empPanel').style.display  = v === 'employees' ? '' : 'none';

        if (v === 'employees') {
            // Quay về "Danh sách nhân viên": phục hồi nội dung bảng gốc
            // (loadDeptEmployees đã ghi đè tbody.innerHTML, cần restore lại)
            if (_origEmpTableHTML !== null) {
                document.getElementById('empTableBody').innerHTML = _origEmpTableHTML;
                updateEmpCount();
            }
        } else if (v === 'dept') {
            // Quay lại "Theo phòng ban": nếu đã chọn phòng ban thì load lại NV
            // (sau khi restore về employees, tbody không còn chứa NV phòng ban nữa)
            var deptId = document.getElementById('deptSelect').value;
            if (deptId) loadDeptEmployees();
        }
    }

    function loadDeptEmployees() {
        var deptId = document.getElementById('deptSelect').value;
        if (!deptId) return;

        // Chỉ lưu snapshot một lần (trước lần ghi đè đầu tiên)
        if (_origEmpTableHTML === null) {
            _origEmpTableHTML = document.getElementById('empTableBody').innerHTML;
        }

        fetch('${pageContext.request.contextPath}/shift-assignment?action=dept-employees&deptId=' + deptId)
            .then(r => r.json())
            .then(function (emps) {
                var tbody = document.getElementById('empTableBody');
                tbody.innerHTML = '';
                emps.forEach(function (e) {
                    var tr = document.createElement('tr');
                    tr.innerHTML =
                        '<td><input type="checkbox" name="employeeIds" value="' + e.id + '" class="emp-checkbox" checked></td>' +
                        '<td>' + escHtml(e.employeeCode) + '</td>' +
                        '<td>' + escHtml(e.fullName) + '</td>' +
                        '<td>' + escHtml(e.departmentName) + '</td>';
                    tbody.appendChild(tr);
                });
                document.getElementById('empPanel').style.display = '';
                updateEmpCount();
            });
    }

    // ── Employee search & count ──
    function filterEmployees() {
        var q = document.getElementById('empSearch').value.toLowerCase();
        document.querySelectorAll('#empTableBody tr').forEach(function (tr) {
            var text = tr.textContent.toLowerCase();
            tr.style.display = text.includes(q) ? '' : 'none';
        });
        updateEmpCount();
    }

    function updateEmpCount() {
        var count = document.querySelectorAll('#empTableBody input.emp-checkbox:checked').length;
        document.getElementById('empCountLabel').textContent = 'Tổng số bản ghi: ' + count;
    }

    function toggleAll(cb) {
        document.querySelectorAll('#empTableBody input.emp-checkbox').forEach(function (c) {
            c.checked = cb.checked;
        });
        updateEmpCount();
    }

    document.addEventListener('change', function (e) {
        if (e.target && e.target.classList.contains('emp-checkbox')) updateEmpCount();
    });

    // ── Delete modal ──
    function confirmDelete(id, name) {
        document.getElementById('deleteBatchId').value = id;
        document.getElementById('deleteBatchName').textContent = name;
        document.getElementById('deleteModal').classList.add('open');
        document.body.style.overflow = 'hidden';
    }

    function closeDeleteModal() {
        document.getElementById('deleteModal').classList.remove('open');
        document.body.style.overflow = '';
    }

    document.getElementById('deleteModal').addEventListener('click', function (e) {
        if (e.target === this) closeDeleteModal();
    });
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') closeDeleteModal();
    });

    // ── Toast ──
    function showToast(msg) {
        if (msg) document.getElementById('toastMsg').textContent = msg;
        var t = document.getElementById('toast');
        t.classList.add('show');
        setTimeout(function () {
            t.classList.remove('show');
        }, 3500);
    }

    if (window.__autoToast) {
        var p = new URLSearchParams(window.location.search);
        var s = p.get('success');
        showToast(s === '1' ? 'Phân ca đã được tạo thành công!'
            : s === '2' ? 'Cập nhật phân ca thành công!'
                : s === '3' ? 'Xóa phân ca thành công!' : '');
        window.history.replaceState({}, '', (window.location.pathname));
    }

    function escHtml(str) {
        return (str || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }

    // ── Conflict Modal ──
    function openConflictModal(rawMsg) {
        // Parse danh sách nhân viên từ message dạng:
        // "Một số nhân viên...\n  • Nguyễn A [ca: Hành chính (08:00 – 17:00)]\n  • Trần B..."
        var lines = rawMsg.split('\n');
        var empLines = lines.filter(function(l) { return l.trim().startsWith('•'); });

        document.getElementById('conflictCount').textContent = empLines.length || '?';

        var listEl = document.getElementById('conflictList');
        listEl.innerHTML = '';

        if (empLines.length === 0) {
            // Fallback: hiển thị toàn bộ message
            listEl.innerHTML = '<div class="conflict-item"><i class="fa-solid fa-circle-exclamation conflict-item-icon"></i><div>' + escHtml(rawMsg) + '</div></div>';
        } else {
            empLines.forEach(function(line) {
                var text = line.replace(/^\s*•\s*/, '').trim();
                // Tách "Tên NV [ca: Ca X (HH:MM – HH:MM)]"
                var caMatch = text.match(/^(.+?)\s*\[ca:\s*(.+?)\]$/);
                var name  = caMatch ? caMatch[1].trim() : text;
                var shift = caMatch ? caMatch[2].trim() : '';

                var item = document.createElement('div');
                item.className = 'conflict-item';
                item.innerHTML =
                    '<i class="fa-solid fa-user-clock conflict-item-icon"></i>' +
                    '<div>' +
                        '<div class="conflict-item-name">' + escHtml(name) + '</div>' +
                        (shift ? '<div class="conflict-item-shift"><i class="fa-regular fa-clock" style="margin-right:4px;"></i>' + escHtml(shift) + '</div>' : '') +
                    '</div>';
                listEl.appendChild(item);
            });
        }

        var overlay = document.getElementById('conflictModal');
        overlay.classList.add('open');
        document.body.style.overflow = 'hidden';
    }

    function closeConflictModal() {
        document.getElementById('conflictModal').classList.remove('open');
        document.body.style.overflow = '';
    }

    document.getElementById('conflictModal').addEventListener('click', function(e) {
        if (e.target === this) closeConflictModal();
    });

    // Auto-open conflict modal nếu server trả về lỗi conflict
    if (window.__conflictError) {
        var msgEl = document.getElementById('saErrorMsgData');
        var msg = msgEl ? msgEl.value : '';
        var panel = document.getElementById('formPanel');
        var btn   = document.getElementById('btnToggleForm');
        if (panel) { panel.style.display = ''; }
        if (btn)   { btn.innerHTML = '<i class="fa-solid fa-xmark"></i> Hủy'; btn.className = 'btn btn-secondary'; }
        openConflictModal(msg);
    }


    // ── Toggle form panel ──
    function toggleForm() {
        var panel = document.getElementById('formPanel');
        var btn = document.getElementById('btnToggleForm');
        var isOpen = panel.style.display !== 'none';
        if (isOpen) {
            panel.style.display = 'none';
            btn.innerHTML = '<i class="fa-solid fa-plus"></i> Thêm phân ca';
            btn.className = 'btn btn-primary';
        } else {
            panel.style.display = '';
            btn.innerHTML = '<i class="fa-solid fa-xmark"></i> Hủy';
            btn.className = 'btn btn-secondary';
            panel.scrollIntoView({behavior: 'smooth', block: 'start'});
            renderCalendar();
        }
    }

    // ── Submit: build lại employeeIds đúng theo scope đang chọn ──
    document.getElementById('saForm').addEventListener('submit', function (e) {
        var scope = document.querySelector('input[name=scope]:checked').value;

        // Đọc trước các Id đang được chọn (checkbox cũng có name="employeeIds"
        // nên phải lấy giá trị TRƯỚC khi xóa, không sẽ đọc hụt)
        var idsToSubmit = [];
        if (scope === 'all') {
            idsToSubmit = allEmployeeIds.slice();
        } else {
            document.querySelectorAll('#empTableBody input.emp-checkbox:checked').forEach(function (cb) {
                idsToSubmit.push(cb.value);
            });
        }

        // Xóa hết input employeeIds hiện có (bao gồm cả checkbox)
        // -> tránh trùng lặp / dữ liệu sót từ lần đổi scope trước đó
        document.querySelectorAll('input[name=employeeIds]').forEach(function (el) {
            el.remove();
        });

        // Build lại bằng hidden input duy nhất theo idsToSubmit đã đọc ở trên
        idsToSubmit.forEach(function (id) {
            var hidden = document.createElement('input');
            hidden.type = 'hidden';
            hidden.name = 'employeeIds';
            hidden.value = id;
            e.target.appendChild(hidden);
        });
    });

    // ── Init ──
    // Lưu snapshot HTML gốc của tbody ngay khi trang load,
    // trước khi onScopeChange() có thể ẩn/hiện empPanel
    _origEmpTableHTML = document.getElementById('empTableBody').innerHTML;
    onRecurTypeChange();
    onMonthlyTypeChange();
    onScopeChange();
    updateEmpCount();
    renderCalendar();
    // Auto-preview nếu đang ở chế độ sửa
    <c:if test="${batch != null}">
    // Đang ở chế độ edit: cập nhật nút và auto-preview
    (function () {
        var btn = document.getElementById('btnToggleForm');
        btn.innerHTML = '<i class="fa-solid fa-xmark"></i> Hủy';
        btn.className = 'btn btn-secondary';
    })();
    setTimeout(triggerPreview, 300);
    </c:if>
</script>
</body>
</html>
