<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
            <%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>



                <fmt:setLocale value="vi_VN" />

                <%@ page import="java.util.List" %>
                    <% Integer totalFilteredItems=(Integer) request.getAttribute("totalFilteredItems"); if
                        (totalFilteredItems==null) totalFilteredItems=0; Integer currentPage=(Integer)
                        request.getAttribute("currentPage"); if (currentPage==null) currentPage=1; Integer
                        pageSize=(Integer) request.getAttribute("pageSize"); if (pageSize==null) pageSize=5; Integer
                        totalPages=(Integer) request.getAttribute("totalPages"); if (totalPages==null) totalPages=1;
                        String searchStr=(String) request.getAttribute("search"); if (searchStr==null) searchStr="" ;
                        Integer selectedPeriodId=(Integer) request.getAttribute("selectedPeriodId"); Integer
                        selectedDeptId=(Integer) request.getAttribute("selectedDepartmentId"); int
                        startItem=totalFilteredItems> 0 ? (currentPage - 1) * pageSize + 1 : 0;
                        int endItem = Math.min(currentPage * pageSize, totalFilteredItems);
                        %>
<%! 
    private String buildPageUrl(Integer periodId, String search, Integer deptId, int page, int pageSize) { 
        StringBuilder sb = new StringBuilder("payslips?page=").append(page).append("&pageSize=").append(pageSize);
        if (periodId != null && periodId > 0) {
            sb.append("&periodId=").append(periodId);
        }
        if (search != null && !search.trim().isEmpty()) {
            try {
                sb.append("&search=").append(java.net.URLEncoder.encode(search.trim(), "UTF-8")); 
            } catch (Exception ignored) {} 
        } 
        if (deptId != null && deptId > 0) {
            sb.append("&departmentId=").append(deptId);
        }
        return sb.toString();
    }
%>

                            <!DOCTYPE html>
                            <html lang="vi">

                            <head>
                                <meta charset="UTF-8" />
                                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                                <title>Bảng Lương Nhân Viên</title>

                                <link rel="stylesheet" href="css/ems.css" />
                                <link rel="stylesheet" href="css/manager-payslip-list.css" />
                                <link rel="preconnect" href="https://fonts.googleapis.com">
                                <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
                                <link
                                    href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                                    rel="stylesheet">

                                <style>
                                    /* Reusing and cleaning up styles for the specific new table needs */
                                    .table-payslip {
                                        width: 100%;
                                        border-collapse: collapse;
                                        margin-top: 5px;
                                    }

                                    .table-payslip th,
                                    .table-payslip td {
                                        padding: 12px;
                                        border-bottom: 1px solid #e2e8f0;
                                        vertical-align: middle;
                                    }

                                    .table-payslip th {
                                        background-color: #f8fafc;
                                        font-weight: 600;
                                        color: #475569;
                                        text-align: left;
                                    }

                                    .money {
                                        font-family: monospace;
                                        font-weight: 500;
                                    }

                                    .text-danger {
                                        color: #dc2626;
                                    }

                                    .text-success {
                                        color: #16a34a;
                                    }

                                    .fw-bold {
                                        font-weight: 600;
                                    }

                                    /* Modal for specific Allowances Details */
                                    .allowance-modal-overlay {
                                        position: fixed;
                                        top: 0;
                                        left: 0;
                                        width: 100%;
                                        height: 100%;
                                        background: rgba(0, 0, 0, 0.4);
                                        display: none;
                                        align-items: center;
                                        justify-content: center;
                                        z-index: 1000;
                                    }

                                    .allowance-modal-content {
                                        background: #fff;
                                        border-radius: 8px;
                                        width: 350px;
                                        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
                                        overflow: hidden;
                                        animation: fadeIn 0.2s ease-out;
                                    }

                                    @keyframes fadeIn {
                                        from {
                                            opacity: 0;
                                            transform: translateY(-10px);
                                        }

                                        to {
                                            opacity: 1;
                                            transform: translateY(0);
                                        }
                                    }

                                    .modal-hdr {
                                        background: #3b82f6;
                                        color: white;
                                        padding: 15px;
                                        font-weight: 600;
                                        display: flex;
                                        justify-content: space-between;
                                        align-items: center;
                                    }

                                    .close-btn {
                                        background: none;
                                        border: none;
                                        color: white;
                                        cursor: pointer;
                                        font-size: 1.2rem;
                                    }

                                    .modal-body {
                                        padding: 0;
                                    }

                                    .allowance-table {
                                        width: 100%;
                                        border-collapse: collapse;
                                    }

                                    .allowance-table th,
                                    .allowance-table td {
                                        padding: 10px 15px;
                                        border-bottom: 1px solid #eee;
                                    }

                                    .allowance-table th {
                                        background: #f8fafc;
                                        font-weight: 500;
                                        color: #64748b;
                                        font-size: 0.9rem;
                                    }

                                    .badge-status {
                                        padding: 4px 10px;
                                        border-radius: 999px;
                                        font-size: 12px;
                                        font-weight: 500;
                                    }

                                    .bdg-paid {
                                        background: #dcfce7;
                                        color: #166534;
                                    }

                                    .bdg-confirmed {
                                        background: #dbeafe;
                                        color: #1e40af;
                                    }

                                    .bdg-draft {
                                        background: #f1f5f9;
                                        color: #475569;
                                    }

                                    .btn-success-run {
                                        background: #10b981;
                                        color: white;
                                        border: none;
                                        padding: 8px 16px;
                                        border-radius: 6px;
                                        cursor: pointer;
                                        font-weight: 500;
                                        font-size: 14px;
                                    }

                                    .btn-success-run:hover {
                                        background: #059669;
                                    }
                                </style>
                            </head>

                            <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>

                                <body>
                                    <div class="main-content">
                                        <div class="topbar">
                                            <span class="topbar-left"><a href="home_manager.jsp"
                                                    style="color:inherit;text-decoration:none;">Trang
                                                    chủ</a> / <a href="salary-management.jsp"
                                                    style="color:inherit;text-decoration:none;">Quản lý
                                                    lương</a> / Bảng lương nhân viên</span>
                                            <span class="topbar-right" id="topbar-date"></span>
                                        </div>

                                        <div class="page-body">

                                            <c:if test="${not empty sessionScope.msgSuccess}">
                                                <div
                                                    style="background:#dcfce7; color:#166534; padding:15px; margin-bottom: 15px; border-radius:6px; border:1px solid #16a34a; font-weight: 500;">
                                                    ${sessionScope.msgSuccess}
                                                </div>
                                                <c:remove var="msgSuccess" scope="session" />
                                            </c:if>
                                            <c:if test="${not empty sessionScope.msgError}">
                                                <div
                                                    style="background:#fee2e2; color:#b91c1c; padding:15px; margin-bottom: 15px; border-radius:6px; border:1px solid #dc2626; font-weight: 500;">
                                                    ${sessionScope.msgError}
                                                </div>
                                                <c:remove var="msgError" scope="session" />
                                            </c:if>

                                            <div class="ps-header"
                                                style="display:flex; justify-content: space-between; align-items: center;">
                                                <div>
                                                    <h1>Bảng Lương Nhân Viên</h1>
                                                    <p>Xem, quản lý và duyệt bảng lương của bộ phận</p>
                                                </div>
                                                <c:choose>
                                                    <c:when test="${isCurrentPeriodLocked}">
                                                        <div
                                                            style="background:#fef3c7; color:#b45309; padding:8px 16px; border-radius:6px; font-weight:600; display:inline-flex; align-items:center; gap:8px;">
                                                            KỲ LƯƠNG ĐÃ KHÓA
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <form action="payslips" method="POST" style="margin: 0;">
                                                            <input type="hidden" name="action" value="generate">
                                                            <input type="hidden" name="periodId"
                                                                value="${selectedPeriodId}">

                                                            <button type="submit" class="btn-success-run"
                                                                onclick="return confirm('Bạn có chắc chắn muốn chạy tính toán bảng lương cho kỳ này? Quá trình này có thể mất vài giây.');">
                                                                Tính Lương Tháng Này
                                                            </button>
                                                        </form>

                                                        <c:if test="${not empty payslips}">
                                                            <form action="payslips" method="POST" style="margin: 0;">
                                                                <input type="hidden" name="action" value="confirm">
                                                                <input type="hidden" name="periodId"
                                                                    value="${selectedPeriodId}">
                                                                <button type="submit"
                                                                    style="background:#3b82f6; color:white; border:none; padding:8px 16px; border-radius:6px; cursor:pointer; font-weight:500; font-size:14px;"
                                                                    onclick="return confirm('XÁC NHẬN CHỐT BẢNG LƯƠNG?\nSau khi chốt, trạng thái sẽ chuyển sang Đã chốt và bạn không thể sửa đổi số liệu được nữa!');">
                                                                    Chốt Bảng Lương
                                                                </button>
                                                            </form>
                                                        </c:if>
                                                    </c:otherwise>
                                                </c:choose>

                                            </div>

                                            <div class="ps-filter-card">
                                                <form action="payslips" method="GET" class="ps-filter-form"
                                                    id="periodForm">
                                                    <div class="ps-period-select-wrapper">
                                                        <span class="ps-period-label">📅 Chọn kỳ
                                                            lương:</span>
                                                        <select name="periodId" class="ps-period-select"
                                                            onchange="document.getElementById('periodForm').submit()">
                                                            <c:forEach var="p" items="${periods}">
                                                                <option value="${p.id}" ${p.id==selectedPeriodId
                                                                    ? 'selected' : '' }>
                                                                    ${p.name} (${p.startdate} -
                                                                    ${p.enddate})
                                                                </option>
                                                            </c:forEach>
                                                        </select>
                                                    </div>

                                                    <div class="ps-search-wrapper">
                                                        <svg class="ps-search-icon" width="16" height="16"
                                                            viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                            stroke-width="2">
                                                            <circle cx="11" cy="11" r="8"></circle>
                                                            <line x1="21" y1="21" x2="16.65" y2="16.65">
                                                            </line>
                                                        </svg>
                                                        <input type="text" name="search" class="ps-input"
                                                            placeholder="Tìm kiếm nhân viên..." value="${search}" />
                                                    </div>

                                                    <select name="departmentId" class="ps-select"
                                                        onchange="document.getElementById('periodForm').submit()">
                                                        <option value="">Tất cả phòng ban</option>
                                                        <c:forEach var="d" items="${departments}">
                                                            <option value="${d.id}" ${d.id==selectedDepartmentId
                                                                ? 'selected' : '' }>${d.name}</option>
                                                        </c:forEach>
                                                    </select>

                                                    <input type="hidden" name="page" value="1" />
                                                    <input type="hidden" name="pageSize" value="<%= pageSize %>" />

                                                    <button type="submit" class="ps-btn-search">Lọc dữ
                                                        liệu</button>
                                                </form>
                                            </div>

                                            <div class="ps-stats-row">
                                                <div class="ps-stat-card">
                                                    <div class="ps-stat-label">Tổng nhân viên</div>
                                                    <div class="ps-stat-value">${totalEmployees}</div>
                                                </div>
                                                <div class="ps-stat-card">
                                                    <div class="ps-stat-label">Tổng lương Gross</div>
                                                    <div class="ps-stat-value">${formattedTotalGross} đ
                                                    </div>
                                                </div>
                                                <div class="ps-stat-card">
                                                    <div class="ps-stat-label">Tổng khấu trừ</div>
                                                    <div class="ps-stat-value">
                                                        ${formattedTotalDeductions} đ</div>
                                                </div>
                                                <div class="ps-stat-card">
                                                    <div class="ps-stat-label">Tổng thực lĩnh (Net)
                                                    </div>
                                                    <div class="ps-stat-value highlight-net">
                                                        ${formattedTotalNet} đ</div>
                                                </div>
                                            </div>

                                            <div class="ps-table-card" style="padding:0; overflow-x: auto;">
                                                <table class="table-payslip">
                                                    <thead>
                                                        <tr>
                                                            <th style="padding-left: 20px;">MÃ NV</th>
                                                            <th>HỌ VÀ TÊN</th>
                                                            <th>PHÒNG BAN</th>
                                                            <th style="text-align: center;">CÔNG CHUẨN
                                                            </th>
                                                            <th style="text-align: center;">CÔNG THỰC TẾ
                                                            </th>
                                                            <th style="text-align: right;">LƯƠNG C.BẢN
                                                            </th>
                                                            <th style="text-align: right;">GROSS</th>
                                                            <th style="text-align: right;">KHẤU TRỪ BH
                                                            </th>
                                                            <th style="text-align: right;">TRỪ THUẾ</th>
                                                            <th style="text-align: right;">THỰC LĨNH
                                                                (NET)</th>
                                                            <th>TRẠNG THÁI</th>
                                                            <th style="padding-right: 20px;">CHI TIẾT
                                                            </th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:forEach var="p" items="${payslips}">
                                                            <tr>
                                                                <td style="padding-left: 20px;"><span
                                                                        style="color:#64748b; font-weight:500;">${p.employeeCode}</span>
                                                                </td>
                                                                <td>
                                                                    <div style="font-weight:600; color:#1e293b;">
                                                                        ${p.fullName}</div>
                                                                    <div style="font-size: 0.85rem; color:#94a3b8;">
                                                                        ${p.positionName}</div>
                                                                </td>
                                                                <td>${p.departmentName}</td>
                                                                <td style="text-align:center;">
                                                                    ${p.standardWorkDays}</td>
                                                                <td style="text-align:center;">
                                                                    ${p.actualWorkDays}</td>
                                                                <td class="money" style="text-align: right;">
                                                                    <fmt:formatNumber value="${p.baseSalary}"
                                                                        type="number" /> đ
                                                                </td>
                                                                <td class="money" style="text-align: right;">
                                                                    <fmt:formatNumber value="${p.grossAmount}"
                                                                        type="number" /> đ
                                                                </td>
                                                                <td class="money text-danger"
                                                                    style="text-align: right;">
                                                                    -
                                                                    <fmt:formatNumber value="${p.totalInsurance}"
                                                                        type="number" /> đ
                                                                </td>
                                                                <td class="money text-danger"
                                                                    style="text-align: right;">
                                                                    -
                                                                    <fmt:formatNumber value="${p.taxDeduction}"
                                                                        type="number" /> đ
                                                                </td>
                                                                <td class="money text-success fw-bold"
                                                                    style="text-align: right;">
                                                                    <fmt:formatNumber value="${p.netAmount}"
                                                                        type="number" /> đ
                                                                </td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when test="${p.status == 'Paid'}">
                                                                            <span class="badge-status bdg-paid">Đã
                                                                                thanh toán</span>
                                                                        </c:when>
                                                                        <c:when test="${p.status == 'Confirmed'}">
                                                                            <span class="badge-status bdg-confirmed">Đã
                                                                                chốt</span>
                                                                        </c:when>
                                                                        <c:otherwise><span
                                                                                class="badge-status bdg-draft">Bản
                                                                                nháp</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                                <td
                                                                    style="padding-right: 20px; display: flex; gap: 8px; justify-content: flex-end; align-items: center; border-bottom: none;">

                                                                    <!-- NÚT SỬA VÀ FORM MODAL SỬA ĐI KÈM -->
                                                                    <c:if
                                                                        test="${p.status == 'Draft' && !isCurrentPeriodLocked}">
                                                                        <button type="button"
                                                                            style="border:1px solid #f59e0b; background:transparent; color:#f59e0b; border-radius:4px; padding:4px 12px; cursor:pointer; font-weight: 500;"
                                                                            onclick="document.getElementById('modal_edit_${p.id}').style.display='flex'">
                                                                            ✎ Sửa
                                                                        </button>
                                                                    </c:if>

                                                                    <div class="allowance-modal-overlay"
                                                                        id="modal_edit_${p.id}"
                                                                        onclick="if(event.target===this) this.style.display='none';">
                                                                        <div class="allowance-modal-content"
                                                                            style="width: 400px; text-align: left;">
                                                                            <div class="modal-hdr"
                                                                                style="background: #f59e0b;">
                                                                                <span>Điều chỉnh -
                                                                                    ${p.employeeCode}</span>
                                                                                <button type="button" class="close-btn"
                                                                                    onclick="document.getElementById('modal_edit_${p.id}').style.display='none'">✕</button>
                                                                            </div>
                                                                            <div class="modal-body"
                                                                                style="padding: 20px;">
                                                                                <form action="payslips" method="POST"
                                                                                    style="margin: 0;">
                                                                                    <input type="hidden" name="action"
                                                                                        value="edit">
                                                                                    <input type="hidden"
                                                                                        name="payslipId"
                                                                                        value="${p.id}">
                                                                                    <input type="hidden" name="periodId"
                                                                                        value="${selectedPeriodId}">

                                                                                    <div style="margin-bottom: 15px;">
                                                                                        <label
                                                                                            style="display:block; font-weight:600; margin-bottom:5px; color:#475569; font-size:14px;">Thưởng
                                                                                            thêm (Bonus)</label>
                                                                                        <input type="number"
                                                                                            name="bonus"
                                                                                            value="${p.bonusAmount}"
                                                                                            min="0"
                                                                                            style="width:100%; padding:10px; border:1px solid #cbd5e1; border-radius:6px; font-family: monospace; font-size:15px;"
                                                                                            placeholder="0">
                                                                                    </div>

                                                                                    <div style="margin-bottom: 15px;">
                                                                                        <label
                                                                                            style="display:block; font-weight:600; margin-bottom:5px; color:#475569; font-size:14px;">Tiền
                                                                                            phạt (Penalty)</label>
                                                                                        <input type="number"
                                                                                            name="penalty"
                                                                                            value="${p.penaltyAmount}"
                                                                                            min="0"
                                                                                            style="width:100%; padding:10px; border:1px solid #cbd5e1; border-radius:6px; font-family: monospace; font-size:15px; color:#dc2626;"
                                                                                            placeholder="0">
                                                                                    </div>

                                                                                    <div style="margin-bottom: 15px;">
                                                                                        <label
                                                                                            style="display:block; font-weight:600; margin-bottom:5px; color:#475569; font-size:14px;">Tạm
                                                                                            ứng (Advance)</label>
                                                                                        <input type="number"
                                                                                            name="advance"
                                                                                            value="${p.advanceAmount}"
                                                                                            min="0"
                                                                                            style="width:100%; padding:10px; border:1px solid #cbd5e1; border-radius:6px; font-family: monospace; font-size:15px; color:#ea580c;"
                                                                                            placeholder="0">
                                                                                    </div>

                                                                                    <div style="margin-bottom: 20px;">
                                                                                        <label
                                                                                            style="display:block; font-weight:600; margin-bottom:5px; color:#475569; font-size:14px;">Ghi
                                                                                            chú (Lý do)</label>
                                                                                        <textarea name="note" rows="2"
                                                                                            style="width:100%; padding:10px; border:1px solid #cbd5e1; border-radius:6px; resize:none; font-size:14px;"
                                                                                            placeholder="VD: Thưởng dự án ABC...">${p.note}</textarea>
                                                                                    </div>

                                                                                    <div
                                                                                        style="display:flex; justify-content:flex-end; gap:10px;">
                                                                                        <button type="button"
                                                                                            onclick="document.getElementById('modal_edit_${p.id}').style.display='none'"
                                                                                            style="padding:10px 16px; border:1px solid #cbd5e1; background:#f8fafc; color:#475569; border-radius:6px; cursor:pointer; font-weight:500;">Hủy</button>
                                                                                        <button type="submit"
                                                                                            style="padding:10px 16px; border:none; background:#f59e0b; color:white; border-radius:6px; cursor:pointer; font-weight:600; box-shadow: 0 4px 6px -1px rgba(245, 158, 11, 0.2);">💾
                                                                                            Lưu thay đổi</button>
                                                                                    </div>
                                                                                </form>
                                                                            </div>
                                                                        </div>
                                                                    </div>

                                                                    <!-- NÚT CHI TIẾT CŨ GIỮ NGUYÊN -->
                                                                    <button type="button" class="btn-view-detail"
                                                                        style="border:1px solid #3b82f6; background:transparent; color:#3b82f6; border-radius:4px; padding:4px 8px; cursor:pointer;"
                                                                        onclick="document.getElementById('modal_allowance_${p.id}').style.display='flex'">
                                                                        Chi tiết
                                                                    </button>

                                                                    <!-- MODAL PHIẾU LƯƠNG CHI TIẾT -->
                                                                    <div class="allowance-modal-overlay"
                                                                        id="modal_allowance_${p.id}"
                                                                        onclick="if(event.target===this) this.style.display='none';">
                                                                        <div class="allowance-modal-content"
                                                                            style="width: 480px;">
                                                                            <div class="modal-hdr">
                                                                                <span>Phiếu lương -
                                                                                    ${p.employeeCode}</span>
                                                                                <button type="button" class="close-btn"
                                                                                    onclick="document.getElementById('modal_allowance_${p.id}').style.display='none'">✕</button>
                                                                            </div>
                                                                            <div class="modal-body"
                                                                                style="padding: 15px;">
                                                                                <!-- CỘNG -->
                                                                                <h6
                                                                                    style="color:#475569; margin-bottom:10px; font-size:14px; font-weight:600; text-transform:uppercase;">
                                                                                    1. Thu Nhập (Cộng)
                                                                                </h6>
                                                                                <table class="allowance-table"
                                                                                    style="margin-bottom: 20px;">
                                                                                    <tr>
                                                                                        <td>Lương cơ bản
                                                                                        </td>
                                                                                        <td
                                                                                            style="text-align: right; font-weight:600;">
                                                                                            <fmt:formatNumber
                                                                                                value="${p.baseSalary}"
                                                                                                type="number" />
                                                                                            đ
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td>Lương thực
                                                                                            nhận (theo
                                                                                            ngày công)
                                                                                        </td>
                                                                                        <td
                                                                                            style="text-align: right; font-weight:600; color:#1e40af;">
                                                                                            <fmt:formatNumber
                                                                                                value="${p.actualBaseSalary}"
                                                                                                type="number" />
                                                                                            đ
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td>Làm thêm OT
                                                                                            (
                                                                                            <fmt:formatNumber
                                                                                                value="${p.otHours}"
                                                                                                type="number" />
                                                                                            h)
                                                                                        </td>
                                                                                        <td
                                                                                            style="text-align: right; font-weight:600;">
                                                                                            <fmt:formatNumber
                                                                                                value="${p.otSalary}"
                                                                                                type="number" />
                                                                                            đ
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td>Thường
                                                                                            (Bonus)</td>
                                                                                        <td
                                                                                            style="text-align: right; font-weight:600; color:#16a34a;">
                                                                                            <fmt:formatNumber
                                                                                                value="${p.bonusAmount}"
                                                                                                type="number" />
                                                                                            đ
                                                                                        </td>
                                                                                    </tr>
                                                                                    <c:forEach var="detail"
                                                                                        items="${p.allowanceDetails}">
                                                                                        <tr>
                                                                                            <td
                                                                                                style="color:#64748b; font-size:13px; padding-left: 20px;">
                                                                                                + Phụ
                                                                                                cấp:
                                                                                                ${detail.allowanceName}
                                                                                            </td>
                                                                                            <td
                                                                                                style="text-align: right; font-weight:600; color:#16a34a;">
                                                                                                <fmt:formatNumber
                                                                                                    value="${detail.amount}"
                                                                                                    type="number" />
                                                                                                đ
                                                                                            </td>
                                                                                        </tr>
                                                                                    </c:forEach>
                                                                                    <tr
                                                                                        style="background:#f8fafc; border-top: 1px solid #cbd5e1;">
                                                                                        <td style="font-weight:700;">
                                                                                            TỔNG THU
                                                                                            NHẬP (GROSS)
                                                                                        </td>
                                                                                        <td
                                                                                            style="text-align: right; font-weight:700; color:#1e40af;">
                                                                                            <fmt:formatNumber
                                                                                                value="${p.grossAmount}"
                                                                                                type="number" />
                                                                                            đ
                                                                                        </td>
                                                                                    </tr>
                                                                                </table>

                                                                                <!-- TRỪ -->
                                                                                <h6
                                                                                    style="color:#475569; margin-bottom:10px; font-size:14px; font-weight:600; text-transform:uppercase;">
                                                                                    2. Khấu Trừ (Trừ)
                                                                                </h6>
                                                                                <table class="allowance-table"
                                                                                    style="margin-bottom: 20px;">
                                                                                    <tr>
                                                                                        <td>Bảo hiểm
                                                                                            (BHXH, BHYT)
                                                                                        </td>
                                                                                        <td
                                                                                            style="text-align: right; font-weight:600; color:#dc2626;">
                                                                                            -
                                                                                            <fmt:formatNumber
                                                                                                value="${p.totalInsurance}"
                                                                                                type="number" />
                                                                                            đ
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td
                                                                                            style="color:#64748b; font-size:13px; padding-left: 20px;">
                                                                                            - Trừ BHXH
                                                                                        </td>
                                                                                        <td
                                                                                            style="text-align: right; font-weight:500; font-size:13px; color:#dc2626;">
                                                                                            -
                                                                                            <fmt:formatNumber
                                                                                                value="${p.bhxh}"
                                                                                                type="number" />
                                                                                            đ
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td
                                                                                            style="color:#64748b; font-size:13px; padding-left: 20px;">
                                                                                            - Trừ BHYT
                                                                                        </td>
                                                                                        <td
                                                                                            style="text-align: right; font-weight:500; font-size:13px; color:#dc2626;">
                                                                                            -
                                                                                            <fmt:formatNumber
                                                                                                value="${p.bhyt}"
                                                                                                type="number" />
                                                                                            đ
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td
                                                                                            style="color:#64748b; font-size:13px; padding-left: 20px;">
                                                                                            - Trừ BHTN
                                                                                        </td>
                                                                                        <td
                                                                                            style="text-align: right; font-weight:500; font-size:13px; color:#dc2626;">
                                                                                            -
                                                                                            <fmt:formatNumber
                                                                                                value="${p.bhtn}"
                                                                                                type="number" />
                                                                                            đ
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td>Giảm trừ gia
                                                                                            cảnh
                                                                                            (${p.dependentsCount}
                                                                                            NPT)</td>
                                                                                        <td
                                                                                            style="text-align: right; font-weight:600; color:#059669;">
                                                                                            <fmt:formatNumber
                                                                                                value="${p.dependentDeduction}"
                                                                                                type="number" />
                                                                                            đ
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td>Thu nhập
                                                                                            tính thuế
                                                                                        </td>
                                                                                        <td
                                                                                            style="text-align: right; font-weight:600;">
                                                                                            <fmt:formatNumber
                                                                                                value="${p.taxableIncome}"
                                                                                                type="number" />
                                                                                            đ
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td
                                                                                            style="color:#64748b; font-size:13px; padding-left: 20px;">
                                                                                            ➡️ Thuế TNCN
                                                                                            phải nộp
                                                                                        </td>
                                                                                        <td
                                                                                            style="text-align: right; font-weight:600; font-size:13px; color:#dc2626;">
                                                                                            -
                                                                                            <fmt:formatNumber
                                                                                                value="${p.taxDeduction}"
                                                                                                type="number" />
                                                                                            đ
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td>Khấu trừ
                                                                                            khác (Phạt,
                                                                                            Ứng)</td>
                                                                                        <td
                                                                                            style="text-align: right; font-weight:600; color:#dc2626;">
                                                                                            -
                                                                                            <fmt:formatNumber
                                                                                                value="${p.otherDeductions}"
                                                                                                type="number" />
                                                                                            đ
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td
                                                                                            style="color:#64748b; font-size:13px; padding-left: 20px;">
                                                                                            - Tiền phạt
                                                                                            (Penalty)
                                                                                        </td>
                                                                                        <td
                                                                                            style="text-align: right; font-weight:500; font-size:13px; color:#dc2626;">
                                                                                            -
                                                                                            <fmt:formatNumber
                                                                                                value="${p.penaltyAmount}"
                                                                                                type="number" />
                                                                                            đ
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td
                                                                                            style="color:#64748b; font-size:13px; padding-left: 20px;">
                                                                                            - Tạm ứng
                                                                                            (Advance)
                                                                                        </td>
                                                                                        <td
                                                                                            style="text-align: right; font-weight:500; font-size:13px; color:#dc2626;">
                                                                                            -
                                                                                            <fmt:formatNumber
                                                                                                value="${p.advanceAmount}"
                                                                                                type="number" />
                                                                                            đ
                                                                                        </td>
                                                                                    </tr>
                                                                                </table>

                                                                                <!-- NET -->
                                                                                <div
                                                                                    style="background:#fef2f2; padding: 12px 15px; display:flex; justify-content:space-between; align-items:center; border-radius: 6px; border: 1px dashed #fca5a5;">
                                                                                    <div
                                                                                        style="font-weight:700; color:#991b1b; font-size:15px;">
                                                                                        THỰC LĨNH (NET
                                                                                        PAY)</div>
                                                                                    <div
                                                                                        style="font-weight:bold; color:#dc2626; font-size:18px;">
                                                                                        <fmt:formatNumber
                                                                                            value="${p.netAmount}"
                                                                                            type="number" />
                                                                                        đ
                                                                                    </div>
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                        <c:if test="${empty payslips}">
                                                            <tr>
                                                                <td colspan="12"
                                                                    style="text-align: center; padding: 40px; color: #64748b;">
                                                                    Chưa có dữ liệu bảng lương cho kỳ
                                                                    này! Hãy thay đổi kỳ lương hoặc chạy
                                                                    tính toán lại.
                                                                </td>
                                                            </tr>
                                                        </c:if>
                                                    </tbody>
                                                </table>

                                                <!-- Pagination Footer -->
                                                <div class="ps-pagination-bar">
                                                    <div class="ps-pagination-info">
                                                        <span>Hiển thị <strong>
                                                                <%= startItem %>-<%= endItem %>
                                                            </strong> / <%= totalFilteredItems %> phiếu lương</span>
                                                        <span>Mỗi trang
                                                            <select class="ps-page-size-select"
                                                                onchange="changePageSize(this.value)">
                                                                <option value="5" <%=pageSize==5 ? "selected" : "" %>>5
                                                                </option>
                                                                <option value="10" <%=pageSize==10 ? "selected" : "" %>
                                                                    >10</option>
                                                                <option value="20" <%=pageSize==20 ? "selected" : "" %>
                                                                    >20</option>
                                                            </select>
                                                        </span>
                                                    </div>
                                                    <div class="ps-pagination-controls">
                                                        <!-- Previous page button -->
                                                        <a href="<%= buildPageUrl(selectedPeriodId, searchStr, selectedDeptId, currentPage - 1, pageSize) %>"
                                                            class="ps-page-nav-btn <%= currentPage <= 1 ? "disabled" : "" %>">&lt;</a>

                                                        <!-- Page numbers -->
                                                        <% for (int p = 1; p <= totalPages; p++) { %>
                                                            <a href="<%= buildPageUrl(selectedPeriodId, searchStr, selectedDeptId, p, pageSize) %>"
                                                                class="ps-page-btn <%= p == currentPage ? "active" : "" %>"><%= p %></a>
                                                        <% } %>

                                                        <!-- Next page button -->
                                                        <a href="<%= buildPageUrl(selectedPeriodId, searchStr, selectedDeptId, currentPage + 1, pageSize) %>"
                                                            class="ps-page-nav-btn <%= currentPage >= totalPages ? "disabled" : "" %>">&gt;</a>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <footer>© 2026 Hệ thống Quản lý Nhân sự (EMS) · FPT University
                                            SWP391</footer>
                                    </div>

                                    <script>
                                        function tick() {
                                            var now = new Date();
                                            var p = function (n) { return String(n).padStart(2, '0'); };
                                            var el = document.getElementById('topbar-date');
                                            if (el) el.textContent = p(now.getDate()) + '/' + p(now.getMonth() + 1) + '/' + now.getFullYear();
                                        }
                                        tick();

                                        function changePageSize(newSize) {
                                            var search = encodeURIComponent('<%= searchStr %>');
                                            var deptId = '<%= selectedDeptId != null ? selectedDeptId : "" %>';
                                            var periodId = '<%= selectedPeriodId != null ? selectedPeriodId : "" %>';
                                            var url = 'payslips?page=1&pageSize=' + newSize;
                                            if (periodId) url += '&periodId=' + periodId;
                                            if (search) url += '&search=' + search;
                                            if (deptId) url += '&departmentId=' + deptId;
                                            window.location.href = url;
                                        }
                                    </script>
                                </body>

                            </html>