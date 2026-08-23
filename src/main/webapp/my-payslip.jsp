<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<fmt:setLocale value="vi_VN" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>EMS – Tra cứu bảng lương</title>
    <link rel="stylesheet" href="css/ems.css"/>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        :root {
            --primary: #4f46e5;
            --primary-hover: #4338ca;
            --success: #10b981;
            --success-light: #d1fae5;
            --danger: #ef4444;
            --danger-light: #fee2e2;
            --slate-50: #f8fafc;
            --slate-100: #f1f5f9;
            --slate-200: #e2e8f0;
            --slate-600: #475569;
            --slate-700: #334155;
            --slate-800: #1e293b;
            --dark: #0f172a;
            --card-shadow: 0 10px 25px -5px rgba(15,23,42,0.05), 0 8px 10px -6px rgba(15,23,42,0.04);
            --transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .tabs-header {
            display: flex;
            border-bottom: 2px solid var(--slate-200);
            margin-bottom: 24px;
            gap: 16px;
        }

        .tab-btn {
            background: none;
            border: none;
            padding: 12px 20px;
            font-size: 14px;
            font-weight: 600;
            color: var(--slate-600);
            cursor: pointer;
            position: relative;
            transition: var(--transition);
            outline: none;
        }

        .tab-btn:hover {
            color: var(--primary);
        }

        .tab-btn.active {
            color: var(--primary);
        }

        .tab-btn.active::after {
            content: '';
            position: absolute;
            bottom: -2px;
            left: 0;
            right: 0;
            height: 2px;
            background-color: var(--primary);
            border-radius: 2px;
        }

        .tab-content {
            display: none;
            animation: fadeIn 0.3s ease-in-out;
        }

        .tab-content.active {
            display: block;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(5px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Detailed Payslip Card */
        .payslip-container {
            background: #fff;
            border: 1px solid var(--slate-200);
            border-radius: 16px;
            box-shadow: var(--card-shadow);
            padding: 30px;
            margin-bottom: 24px;
        }

        .payslip-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            border-bottom: 2px solid var(--slate-100);
            padding-bottom: 20px;
            margin-bottom: 20px;
        }

        .company-info .logo-text {
            font-size: 20px;
            font-weight: 800;
            color: var(--slate-800);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .company-info .logo-text i {
            color: var(--primary);
        }

        .company-info .sub-text {
            font-size: 12px;
            color: var(--slate-600);
            margin-top: 4px;
        }

        .payslip-title-block {
            text-align: right;
        }

        .payslip-title-block h2 {
            font-size: 20px;
            font-weight: 800;
            color: var(--slate-800);
            margin: 0;
        }

        .period-badge {
            display: inline-block;
            background-color: var(--slate-100);
            color: var(--slate-800);
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            margin-top: 6px;
        }

        /* Metadata info grid */
        .info-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            background-color: var(--slate-50);
            padding: 16px;
            border-radius: 12px;
            margin-bottom: 24px;
        }

        .info-item {
            display: flex;
            flex-direction: column;
        }

        .info-label {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            color: var(--slate-600);
            letter-spacing: 0.5px;
            margin-bottom: 4px;
        }

        .info-value {
            font-size: 13.5px;
            font-weight: 600;
            color: var(--dark);
        }

        /* Breakdown columns */
        .breakdown-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin-bottom: 30px;
        }

        .breakdown-col h3 {
            font-size: 14px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 2px solid var(--slate-100);
            padding-bottom: 8px;
            margin-bottom: 12px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .breakdown-col.earnings h3 {
            color: var(--primary);
        }

        .breakdown-col.deductions h3 {
            color: var(--danger);
        }

        .calc-table {
            width: 100%;
            border-collapse: collapse;
        }

        .calc-table td {
            padding: 10px 0;
            font-size: 13.5px;
            color: var(--slate-700);
            border-bottom: 1px solid var(--slate-100);
        }

        .calc-table tr:last-child td {
            border-bottom: none;
        }

        .calc-table td.val-col {
            text-align: right;
            font-weight: 600;
            color: var(--dark);
        }

        .calc-table td.deduct-val {
            color: var(--danger);
        }

        .calc-table .subtle-indent {
            padding-left: 16px;
            font-size: 12.5px;
            color: var(--slate-600);
        }

        .total-row td {
            font-weight: 700 !important;
            font-size: 14px !important;
            padding-top: 14px !important;
            border-top: 2px double var(--slate-200) !important;
            border-bottom: none !important;
        }

        .total-row td.val-col {
            color: var(--primary) !important;
        }

        .total-row.deduct-total td.val-col {
            color: var(--danger) !important;
        }

        /* NET Amount Card */
        .net-amount-card {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            border-radius: 12px;
            padding: 24px;
            color: #fff;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 15px rgba(16, 185, 129, 0.25);
            margin-bottom: 20px;
        }

        .net-amount-card .label {
            font-size: 14px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            opacity: 0.9;
        }

        .net-amount-card .value {
            font-size: 26px;
            font-weight: 800;
        }

        .payslip-note {
            font-size: 13px;
            font-style: italic;
            color: var(--slate-600);
            background-color: var(--slate-50);
            padding: 12px 16px;
            border-left: 4px solid var(--primary);
            border-radius: 0 8px 8px 0;
        }

        /* History Table Styles */
        .history-card {
            background: #fff;
            border: 1px solid var(--slate-200);
            border-radius: 16px;
            box-shadow: var(--card-shadow);
            overflow: hidden;
        }

        .history-table {
            width: 100%;
            border-collapse: collapse;
        }

        .history-table th {
            background-color: var(--slate-50);
            font-weight: 600;
            color: var(--slate-600);
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 14px 20px;
            border-bottom: 1.5px solid var(--slate-200);
            text-align: left;
        }

        .history-table td {
            padding: 14px 20px;
            font-size: 13.5px;
            color: var(--slate-700);
            border-bottom: 1px solid var(--slate-100);
        }

        .history-table tr:hover td {
            background-color: var(--slate-50);
        }

        .history-table td.money {
            font-weight: 600;
            color: var(--dark);
        }

        .history-table td.net-money {
            color: var(--success);
            font-weight: 700;
        }

        /* Action Buttons */
        .btn-view-detail {
            background-color: var(--slate-100);
            color: var(--slate-800);
            border: none;
            border-radius: 6px;
            padding: 6px 14px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: var(--transition);
        }

        .btn-view-detail:hover {
            background-color: var(--primary);
            color: #fff;
        }

        .action-header {
            display: flex;
            justify-content: flex-end;
            margin-bottom: 16px;
        }

        .btn-print {
            background-color: var(--slate-100);
            color: var(--slate-800);
            border: 1px solid var(--slate-200);
            border-radius: 8px;
            padding: 8px 16px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: var(--transition);
            outline: none;
        }

        .btn-print:hover {
            background-color: #fff;
            border-color: var(--primary);
            color: var(--primary);
            box-shadow: 0 4px 10px rgba(79, 70, 229, 0.1);
        }

        /* Empty states */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            background: #fff;
            border-radius: 16px;
            border: 1.5px dashed var(--slate-200);
        }

        .empty-state i {
            font-size: 48px;
            color: var(--slate-600);
            opacity: 0.5;
            margin-bottom: 16px;
        }

        .empty-state h3 {
            font-size: 18px;
            color: var(--dark);
            margin-bottom: 8px;
        }

        .empty-state p {
            color: var(--slate-600);
            font-size: 14px;
        }

        /* Modal styling */
        .modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background-color: rgba(15, 23, 42, 0.6);
            backdrop-filter: blur(4px);
            z-index: 1000;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .modal-overlay.open {
            display: flex;
        }

        .modal-card {
            background-color: #fff;
            border-radius: 16px;
            max-width: 800px;
            width: 100%;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 25px 50px -12px rgba(15, 23, 42, 0.25);
            animation: modalSlide 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
        }

        @keyframes modalSlide {
            from { opacity: 0; transform: scale(0.95) translateY(15px); }
            to { opacity: 1; transform: scale(1) translateY(0); }
        }

        .modal-header {
            padding: 20px 24px;
            border-bottom: 1px solid var(--slate-200);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .modal-title {
            font-size: 16px;
            font-weight: 700;
            color: var(--slate-800);
        }

        .modal-close {
            background: var(--slate-100);
            color: var(--slate-700);
            border: none;
            padding: 8px;
            border-radius: 8px;
            cursor: pointer;
            transition: var(--transition);
        }

        .modal-close:hover {
            background-color: var(--slate-200);
        }

        .modal-body {
            padding: 24px;
        }

        @media print {
            body * {
                visibility: hidden;
            }
            .payslip-container, .payslip-container * {
                visibility: visible;
            }
            .payslip-container {
                position: absolute;
                left: 0;
                top: 0;
                width: 100%;
                border: none;
                box-shadow: none;
                padding: 0;
            }
            .btn-print, .tabs-header {
                display: none !important;
            }
            .sidebar {
                display: none !important;
            }
            .main-content {
                margin-left: 0 !important;
            }
        }
    </style>
</head>
<body>
<%@include file="/WEB-INF/jspf/sidebar.jsp"%>

<div class="main-content">
    <div class="topbar">
        <span class="topbar-left">Tra cứu bảng lương</span>
        <span class="topbar-right" id="topbar-date"></span>
    </div>

    <div class="page-body">
        <div class="page-header">
            <h1>Thông tin lương cá nhân</h1>
            <p>Tra cứu chi tiết bảng lương hiện tại và lịch sử nhận lương.</p>
        </div>

        <div class="tabs-header">
            <button class="tab-btn active" onclick="openTab(event, 'current-month')">Bảng lương tháng này</button>
            <button class="tab-btn" onclick="openTab(event, 'history')">Lịch sử nhận lương</button>
        </div>

        <!-- TAB 1: BẢNG LƯƠNG THÁNG NÀY -->
        <div id="current-month" class="tab-content active">
            <c:choose>
                <c:when test="${not empty currentPayslip}">
                    <div class="action-header">
                        <button class="btn-print" onclick="window.print()">
                            <i class="fa-solid fa-print"></i> In phiếu lương
                        </button>
                    </div>

                    <div class="payslip-container">
                        <!-- Header -->
                        <div class="payslip-header">
                            <div class="company-info">
                                <div class="logo-text">
                                    <i class="fa-solid fa-hotel"></i> EMS SYSTEM
                                </div>
                                <div class="sub-text">Hệ thống quản lý nhân sự chuyên nghiệp</div>
                            </div>
                            <div class="payslip-title-block">
                                <h2>PHIẾU LƯƠNG CHI TIẾT</h2>
                                <span class="period-badge">${currentPayslip.periodName}</span>
                            </div>
                        </div>

                        <!-- Info Grid -->
                        <div class="info-grid">
                            <div class="info-item">
                                <span class="info-label">Mã nhân viên</span>
                                <span class="info-value">${currentPayslip.employeeCode}</span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Họ và tên</span>
                                <span class="info-value">${currentPayslip.fullName}</span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Phòng ban</span>
                                <span class="info-value">${currentPayslip.departmentName}</span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Chức vụ</span>
                                <span class="info-value">${currentPayslip.positionName}</span>
                            </div>
                        </div>

                        <!-- Breakdown Grid -->
                        <div class="breakdown-row">
                            <!-- Earnings -->
                            <div class="breakdown-col earnings">
                                <h3>KHOẢN THU NHẬP (A) <span>VND</span></h3>
                                <table class="calc-table">
                                    <tr>
                                        <td>Lương cơ bản (Hợp đồng)</td>
                                        <td class="val-col">
                                            <fmt:formatNumber value="${currentPayslip.baseSalary}" type="number" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Số ngày công quy chuẩn</td>
                                        <td class="val-col">${currentPayslip.standardWorkDays} ngày</td>
                                    </tr>
                                    <tr>
                                        <td>Số ngày công thực tế làm việc</td>
                                        <td class="val-col">${currentPayslip.actualWorkDays} ngày</td>
                                    </tr>
                                    <tr>
                                        <td class="subtle-indent">➡️ Lương theo ngày công làm việc</td>
                                        <td class="val-col">
                                            <fmt:formatNumber value="${currentPayslip.actualBaseSalary}" type="number" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Lương tăng ca (OT) (${currentPayslip.otHours} giờ)</td>
                                        <td class="val-col">
                                            <fmt:formatNumber value="${currentPayslip.otSalary}" type="number" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Tiền thưởng / Bonus</td>
                                        <td class="val-col">
                                            <fmt:formatNumber value="${currentPayslip.bonusAmount}" type="number" />
                                        </td>
                                    </tr>
                                    <!-- Allowances list -->
                                    <c:forEach items="${currentPayslip.allowanceDetails}" var="allw">
                                        <tr>
                                            <td class="subtle-indent">+ Phụ cấp: ${allw.allowanceName}</td>
                                            <td class="val-col">
                                                <fmt:formatNumber value="${allw.amount}" type="number" />
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <tr class="total-row">
                                        <td>TỔNG THU NHẬP (GROSS)</td>
                                        <td class="val-col">
                                            <fmt:formatNumber value="${currentPayslip.grossAmount}" type="number" />
                                        </td>
                                    </tr>
                                </table>
                            </div>

                            <!-- Deductions -->
                            <div class="breakdown-col deductions">
                                <h3>KHOẢN KHẨU TRỪ & THUẾ (B) <span>VND</span></h3>
                                <table class="calc-table">
                                    <tr>
                                        <td>Bảo hiểm bắt buộc</td>
                                        <td class="val-col deduct-val">
                                            - <fmt:formatNumber value="${currentPayslip.totalInsurance}" type="number" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="subtle-indent">- BHXH (8%)</td>
                                        <td class="val-col deduct-val">
                                            - <fmt:formatNumber value="${currentPayslip.bhxh}" type="number" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="subtle-indent">- BHYT (1.5%)</td>
                                        <td class="val-col deduct-val">
                                            - <fmt:formatNumber value="${currentPayslip.bhyt}" type="number" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="subtle-indent">- BHTN (1%)</td>
                                        <td class="val-col deduct-val">
                                            - <fmt:formatNumber value="${currentPayslip.bhtn}" type="number" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Giảm trừ gia cảnh (${currentPayslip.dependentsCount} NPT)</td>
                                        <td class="val-col" style="color:var(--success);">
                                            <fmt:formatNumber value="${currentPayslip.dependentDeduction}" type="number" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Thu nhập chịu thuế thu nhập cá nhân</td>
                                        <td class="val-col">
                                            <fmt:formatNumber value="${currentPayslip.taxableIncome}" type="number" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="subtle-indent">➡️ Thuế TNCN khấu trừ</td>
                                        <td class="val-col deduct-val">
                                            - <fmt:formatNumber value="${currentPayslip.taxDeduction}" type="number" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Khấu trừ khác (Phạt, Ứng)</td>
                                        <td class="val-col deduct-val">
                                            - <fmt:formatNumber value="${currentPayslip.otherDeductions}" type="number" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="subtle-indent">- Tiền phạt</td>
                                        <td class="val-col deduct-val">
                                            - <fmt:formatNumber value="${currentPayslip.penaltyAmount}" type="number" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="subtle-indent">- Tạm ứng lương</td>
                                        <td class="val-col deduct-val">
                                            - <fmt:formatNumber value="${currentPayslip.advanceAmount}" type="number" />
                                        </td>
                                    </tr>
                                    <tr class="total-row deduct-total">
                                        <td>TỔNG KHẨU TRỪ (B)</td>
                                        <td class="val-col deduct-val">
                                            - <fmt:formatNumber value="${currentPayslip.totalInsurance + currentPayslip.taxDeduction + currentPayslip.otherDeductions}" type="number" />
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>

                        <!-- NET Pay -->
                        <div class="net-amount-card">
                            <div class="label">THỰC LĨNH CHUYỂN KHOẢN (NET PAY)</div>
                            <div class="value">
                                <fmt:formatNumber value="${currentPayslip.netAmount}" type="number" /> đ
                            </div>
                        </div>

                        <!-- Note -->
                        <c:if test="${not empty currentPayslip.note}">
                            <div class="payslip-note">
                                <strong>Ghi chú:</strong> ${currentPayslip.note}
                            </div>
                        </c:if>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <i class="fa-solid fa-receipt"></i>
                        <h3>Chưa có bảng lương</h3>
                        <p>Thông tin bảng lương cho tháng hiện tại chưa được tạo hoặc chốt bởi quản lý.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- TAB 2: LỊCH SỬ PHIẾU LƯƠNG -->
        <div id="history" class="tab-content">
            <c:choose>
                <c:when test="${not empty historyPayslips}">
                    <div class="history-card">
                        <table class="history-table">
                            <thead>
                            <tr>
                                <th>Kỳ lương</th>
                                <th>Lương cơ bản</th>
                                <th>Tổng thu nhập (Gross)</th>
                                <th>Tổng Khấu trừ</th>
                                <th>Thực lĩnh (Net)</th>
                                <th>Trạng thái</th>
                                <th style="text-align: right">Thao tác</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach items="${historyPayslips}" var="hp">
                                <tr>
                                    <td><strong>${hp.periodName}</strong></td>
                                    <td class="money"><fmt:formatNumber value="${hp.baseSalary}" type="number" /> đ</td>
                                    <td class="money"><fmt:formatNumber value="${hp.grossAmount}" type="number" /> đ</td>
                                    <td class="money text-danger">
                                        - <fmt:formatNumber value="${hp.totalInsurance + hp.taxDeduction + hp.otherDeductions}" type="number" /> đ
                                    </td>
                                    <td class="net-money"><fmt:formatNumber value="${hp.netAmount}" type="number" /> đ</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${hp.status == 'Paid'}">
                                                <span class="badge badge-approved" style="background-color: var(--success-light); color: var(--success)">Đã thanh toán</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-pending">Đã chốt</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="text-align: right">
                                        <button class="btn-view-detail" onclick="openDetailsModal(${hp.id})">
                                            <i class="fa-solid fa-eye"></i> Xem chi tiết
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <i class="fa-solid fa-folder-open"></i>
                        <h3>Không có lịch sử</h3>
                        <p>Hệ thống chưa ghi nhận các lịch sử bảng lương từ các tháng trước của bạn.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<!-- Details Modal Overlay -->
<div id="details-modal" class="modal-overlay" onclick="closeDetailsModal(event)">
    <div class="modal-card" onclick="event.stopPropagation()">
        <div class="modal-header">
            <div class="modal-title" id="modal-period-title">Chi Tiết Phiếu Lương Lịch Sử</div>
            <button class="modal-close" onclick="closeDetailsModal(null)">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <div class="modal-body" id="modal-content-area">
            <!-- Details template dynamically loaded here -->
        </div>
    </div>
</div>

<!-- Hidden templates containing historical details -->
<c:if test="${not empty historyPayslips}">
    <c:forEach items="${historyPayslips}" var="hp">
        <div id="temp-payslip-${hp.id}" style="display: none">
            <div class="payslip-header">
                <div class="company-info">
                    <div class="logo-text">
                        <i class="fa-solid fa-hotel"></i> EMS SYSTEM
                    </div>
                    <div class="sub-text">Hệ thống quản lý nhân sự chuyên nghiệp</div>
                </div>
                <div class="payslip-title-block">
                    <h2>PHIẾU LƯƠNG CHI TIẾT</h2>
                    <span class="period-badge">${hp.periodName}</span>
                </div>
            </div>

            <div class="info-grid">
                <div class="info-item">
                    <span class="info-label">Mã nhân viên</span>
                    <span class="info-value">${hp.employeeCode}</span>
                </div>
                <div class="info-item">
                    <span class="info-label">Họ và tên</span>
                    <span class="info-value">${hp.fullName}</span>
                </div>
                <div class="info-item">
                    <span class="info-label">Phòng ban</span>
                    <span class="info-value">${hp.departmentName}</span>
                </div>
                <div class="info-item">
                    <span class="info-label">Chức vụ</span>
                    <span class="info-value">${hp.positionName}</span>
                </div>
            </div>

            <div class="breakdown-row">
                <div class="breakdown-col earnings">
                    <h3>KHOẢN THU NHẬP (A) <span>VND</span></h3>
                    <table class="calc-table">
                        <tr>
                            <td>Lương cơ bản (Hợp đồng)</td>
                            <td class="val-col">
                                <fmt:formatNumber value="${hp.baseSalary}" type="number" />
                            </td>
                        </tr>
                        <tr>
                            <td>Số ngày công quy chuẩn</td>
                            <td class="val-col">${hp.standardWorkDays} ngày</td>
                        </tr>
                        <tr>
                            <td>Số ngày công thực tế làm việc</td>
                            <td class="val-col">${hp.actualWorkDays} ngày</td>
                        </tr>
                        <tr>
                            <td class="subtle-indent">➡️ Lương theo ngày công làm việc</td>
                            <td class="val-col">
                                <fmt:formatNumber value="${hp.actualBaseSalary}" type="number" />
                            </td>
                        </tr>
                        <tr>
                            <td>Lương tăng ca (OT) (${hp.otHours} giờ)</td>
                            <td class="val-col">
                                <fmt:formatNumber value="${hp.otSalary}" type="number" />
                            </td>
                        </tr>
                        <tr>
                            <td>Tiền thưởng / Bonus</td>
                            <td class="val-col">
                                <fmt:formatNumber value="${hp.bonusAmount}" type="number" />
                            </td>
                        </tr>
                        <c:forEach items="${hp.allowanceDetails}" var="allw">
                            <tr>
                                <td class="subtle-indent">+ Phụ cấp: ${allw.allowanceName}</td>
                                <td class="val-col">
                                    <fmt:formatNumber value="${allw.amount}" type="number" />
                                </td>
                            </tr>
                        </c:forEach>
                        <tr class="total-row">
                            <td>TỔNG THU NHẬP (GROSS)</td>
                            <td class="val-col">
                                <fmt:formatNumber value="${hp.grossAmount}" type="number" />
                            </td>
                        </tr>
                    </table>
                </div>

                <div class="breakdown-col deductions">
                    <h3>KHOẢN KHẨU TRỪ & THUẾ (B) <span>VND</span></h3>
                    <table class="calc-table">
                        <tr>
                            <td>Bảo hiểm bắt buộc</td>
                            <td class="val-col deduct-val">
                                - <fmt:formatNumber value="${hp.totalInsurance}" type="number" />
                            </td>
                        </tr>
                        <tr>
                            <td class="subtle-indent">- BHXH (8%)</td>
                            <td class="val-col deduct-val">
                                - <fmt:formatNumber value="${hp.bhxh}" type="number" />
                            </td>
                        </tr>
                        <tr>
                            <td class="subtle-indent">- BHYT (1.5%)</td>
                            <td class="val-col deduct-val">
                                - <fmt:formatNumber value="${hp.bhyt}" type="number" />
                            </td>
                        </tr>
                        <tr>
                            <td class="subtle-indent">- BHTN (1%)</td>
                            <td class="val-col deduct-val">
                                - <fmt:formatNumber value="${hp.bhtn}" type="number" />
                            </td>
                        </tr>
                        <tr>
                            <td>Giảm trừ gia cảnh (${hp.dependentsCount} NPT)</td>
                            <td class="val-col" style="color:var(--success);">
                                <fmt:formatNumber value="${hp.dependentDeduction}" type="number" />
                            </td>
                        </tr>
                        <tr>
                            <td>Thu nhập chịu thuế thu nhập cá nhân</td>
                            <td class="val-col">
                                <fmt:formatNumber value="${hp.taxableIncome}" type="number" />
                            </td>
                        </tr>
                        <tr>
                            <td class="subtle-indent">➡️ Thuế TNCN khấu trừ</td>
                            <td class="val-col deduct-val">
                                - <fmt:formatNumber value="${hp.taxDeduction}" type="number" />
                            </td>
                        </tr>
                        <tr>
                            <td>Khấu trừ khác (Phạt, Ứng)</td>
                            <td class="val-col deduct-val">
                                - <fmt:formatNumber value="${hp.otherDeductions}" type="number" />
                            </td>
                        </tr>
                        <tr>
                            <td class="subtle-indent">- Tiền phạt</td>
                            <td class="val-col deduct-val">
                                - <fmt:formatNumber value="${hp.penaltyAmount}" type="number" />
                            </td>
                        </tr>
                        <tr>
                            <td class="subtle-indent">- Tạm ứng lương</td>
                            <td class="val-col deduct-val">
                                - <fmt:formatNumber value="${hp.advanceAmount}" type="number" />
                            </td>
                        </tr>
                        <tr class="total-row deduct-total">
                            <td>TỔNG KHẨU TRỪ (B)</td>
                            <td class="val-col deduct-val">
                                - <fmt:formatNumber value="${hp.totalInsurance + hp.taxDeduction + hp.otherDeductions}" type="number" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>

            <div class="net-amount-card">
                <div class="label">THỰC LĨNH CHUYỂN KHOẢN (NET PAY)</div>
                <div class="value">
                    <fmt:formatNumber value="${hp.netAmount}" type="number" /> đ
                </div>
            </div>

            <c:if test="${not empty hp.note}">
                <div class="payslip-note" style="margin-top: 15px;">
                    <strong>Ghi chú:</strong> ${hp.note}
                </div>
            </c:if>
        </div>
    </c:forEach>
</c:if>

<script>
    function tick() {
        var now = new Date();
        var p = function (n) { return String(n).padStart(2, '0'); };
        var el = document.getElementById('topbar-date');
        if (el) el.textContent = p(now.getDate()) + '/' + p(now.getMonth() + 1) + '/' + now.getFullYear();
    }
    tick();

    function openTab(evt, tabName) {
        var i, tabcontent, tablinks;
        tabcontent = document.getElementsByClassName("tab-content");
        for (i = 0; i < tabcontent.length; i++) {
            tabcontent[i].classList.remove("active");
        }
        tablinks = document.getElementsByClassName("tab-btn");
        for (i = 0; i < tablinks.length; i++) {
            tablinks[i].classList.remove("active");
        }
        document.getElementById(tabName).classList.add("active");
        evt.currentTarget.classList.add("active");
    }

    function openDetailsModal(id) {
        const template = document.getElementById('temp-payslip-' + id);
        const modalContent = document.getElementById('modal-content-area');
        const modal = document.getElementById('details-modal');
        
        if (template && modalContent && modal) {
            modalContent.innerHTML = template.innerHTML;
            modal.classList.add('open');
        }
    }

    function closeDetailsModal(event) {
        if (!event || event.target === document.getElementById('details-modal') || event.target.closest('.modal-close')) {
            const modal = document.getElementById('details-modal');
            if (modal) {
                modal.classList.remove('open');
            }
        }
    }
</script>
</body>
</html>
