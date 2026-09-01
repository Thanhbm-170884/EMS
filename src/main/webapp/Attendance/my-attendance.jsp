<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>EMS – Lịch sử chấm công của tôi</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ems.css"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
    <script src="https://npmcdn.com/flatpickr/dist/l10n/vn.js"></script>

    <style>
        .preview-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
            font-size: 14px;
        }

        .preview-table th {
            background: #f1f5f9;
            color: #475569;
            font-weight: 600;
            padding: 12px 16px;
            border-bottom: 1px solid #e2e8f0;
            text-transform: uppercase;
            font-size: 12px;
            letter-spacing: .5px;
        }

        .preview-table td {
            padding: 12px 16px;
            border-bottom: 1px solid #f1f5f9;
            color: #334155;
        }

        .preview-table tr:hover {
            background: #f8fafc;
        }

        .badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 9999px;
            font-size: 12px;
            font-weight: 600;
        }

        .badge-danger {
            background: #fee2e2;
            color: #dc2626;
        }

        .badge-success {
            background: #d1fae5;
            color: #059669;
        }

        .badge-warning {
            background: #fef3c7;
            color: #b45309;
        }

        .filter-bar {
            display: flex;
            align-items: flex-end;
            gap: 12px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }

        .filter-bar .form-group {
            display: flex;
            flex-direction: column;
            margin-bottom: 0 !important;
        }

        .filter-bar .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #475569;
            margin-bottom: 6px;
        }

        .date-input-wrap {
            position: relative;
            display: inline-flex;
            align-items: center;
            width: 170px;
        }

        .date-input-wrap input,
        .date-input-wrap .flatpickr-input {
            box-sizing: border-box;
            width: 100% !important;
            height: 40px !important;
            padding: 8px 36px 8px 12px !important;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 14px;
            color: #1e293b;
            background: #ffffff;
            outline: none;
            margin: 0 !important;
            font-family: inherit;
            cursor: pointer;
        }

        .date-input-wrap input:focus,
        .date-input-wrap .flatpickr-input:focus {
            border-color: #2563eb;
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
        }

        .date-input-wrap .calendar-icon {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: #475569;
            pointer-events: none;
            z-index: 2;
        }

        .btn-primary {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            height: 40px;
            box-sizing: border-box;
            padding: 0 22px;
            background: #2563eb;
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            font-size: 14px;
            margin: 0 !important;
            transition: all 0.15s ease;
            box-shadow: 0 1px 2px rgba(37, 99, 235, 0.15);
            font-family: inherit;
        }

        .btn-primary:hover {
            background: #1d4ed8;
            transform: translateY(-1px);
            box-shadow: 0 3px 6px rgba(37, 99, 235, 0.2);
        }

        .btn-primary:active {
            transform: translateY(0);
        }

        .alert-danger {
            background: #fef2f2;
            border: 1px solid #fecaca;
            color: #b91c1c;
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
        }
    </style>
</head>

<body>

<%@ include file="/WEB-INF/jspf/sidebar.jsp" %>

<div class="main-content">

    <div class="page-body">

        <div class="page-header">
            <h1>Lịch sử chấm công của tôi</h1>
            <p>
                Xem lại thông tin check-in / check-out
                theo khoảng thời gian bạn chọn.
            </p>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert-danger">
                ⚠ <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <form class="filter-bar"
              method="get"
              action="${pageContext.request.contextPath}/Attendance/my-attendance">

            <div class="form-group">
                <label for="fromDate">Từ ngày</label>
                <div class="date-input-wrap">
                    <input type="text"
                           id="fromDate"
                           name="fromDate"
                           placeholder="dd/mm/yyyy"
                           value="${fromDate}" />
                    <svg class="calendar-icon" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                        <line x1="16" y1="2" x2="16" y2="6"></line>
                        <line x1="8" y1="2" x2="8" y2="6"></line>
                        <line x1="3" y1="10" x2="21" y2="10"></line>
                    </svg>
                </div>
            </div>

            <div class="form-group">
                <label for="toDate">Đến ngày</label>
                <div class="date-input-wrap">
                    <input type="text"
                           id="toDate"
                           name="toDate"
                           placeholder="dd/mm/yyyy"
                           value="${toDate}" />
                    <svg class="calendar-icon" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                        <line x1="16" y1="2" x2="16" y2="6"></line>
                        <line x1="8" y1="2" x2="8" y2="6"></line>
                        <line x1="3" y1="10" x2="21" y2="10"></line>
                    </svg>
                </div>
            </div>

            <button type="submit" class="btn-primary">
                Lọc
            </button>

        </form>

        <div class="card" style="padding:0; overflow:hidden;">

            <div style="overflow-x:auto;">

                <table class="preview-table">

                    <thead>
                    <tr>
                        <th>Ngày</th>
                        <th>Check in</th>
                        <th>Check out</th>
                        <th>Trạng thái</th>
                    </tr>
                    </thead>

                    <tbody>

                    <c:choose>

                        <c:when test="${not empty history}">

                            <c:forEach var="h" items="${history}">

                                <tr>

                                    <td>
                                        <fmt:parseDate value="${h.date}" pattern="yyyy-MM-dd" var="parsedDate" />
                                        <fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy" />
                                    </td>

                                    <td>
                                        ${h.checkIn != null ? h.checkIn : '—'}
                                    </td>

                                    <td>
                                        ${h.checkOut != null ? h.checkOut : '—'}
                                    </td>

                                    <td>

                                        <c:choose>

                                            <c:when test="${h.status == 'ABSENT'}">
                                                <span class="badge badge-danger">
                                                    Vắng
                                                </span>
                                            </c:when>

                                            <c:when test="${h.status == 'MISSING_CHECKOUT'}">
                                                <span class="badge badge-warning">
                                                    Thiếu Check out
                                                </span>
                                            </c:when>

                                            <c:when test="${h.status == 'LATE'}">
                                                <span class="badge badge-danger">
                                                    Muộn ${h.lateMinutes} phút
                                                </span>
                                            </c:when>

                                            <c:otherwise>
                                                <span class="badge badge-success">
                                                    Đúng giờ
                                                </span>
                                            </c:otherwise>

                                        </c:choose>

                                    </td>

                                </tr>

                            </c:forEach>

                        </c:when>

                        <c:otherwise>

                            <tr>

                                <td colspan="4"
                                    style="text-align:center;
                                           padding:40px;
                                           color:#94a3b8;">

                                    Không có dữ liệu chấm công
                                    trong khoảng thời gian này.

                                </td>

                            </tr>

                        </c:otherwise>

                    </c:choose>

                    </tbody>

                </table>

            </div>

        </div>

    </div>

</div>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        if (typeof flatpickr !== "undefined") {
            var vnLocale = typeof flatpickr.l10ns.vn !== "undefined" ? flatpickr.l10ns.vn : "default";

            flatpickr("#fromDate", {
                dateFormat: "Y-m-d",
                altInput: true,
                altFormat: "d/m/Y",
                altInputClass: "flatpickr-input",
                allowInput: true,
                locale: vnLocale
            });

            flatpickr("#toDate", {
                dateFormat: "Y-m-d",
                altInput: true,
                altFormat: "d/m/Y",
                altInputClass: "flatpickr-input",
                allowInput: true,
                locale: vnLocale
            });
        }
    });
</script>
</body>
</html>