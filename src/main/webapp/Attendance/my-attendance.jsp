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
            margin-bottom: 24px;
            flex-wrap: wrap;
        }

        .filter-bar .form-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
            margin-bottom: 0 !important;
            padding: 0 !important;
        }

        .filter-bar .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #475569;
            margin: 0 !important;
            padding: 0 !important;
            line-height: 1.2;
        }

        .filter-bar .form-group input,
        .filter-bar .form-group .flatpickr-input {
            box-sizing: border-box;
            width: 170px !important;
            height: 38px !important;
            padding: 7px 12px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 13.5px;
            color: #1e293b;
            background: #ffffff;
            outline: none;
            margin: 0 !important;
            transition: all 0.15s ease;
            font-family: inherit;
        }

        .filter-bar .form-group input:focus,
        .filter-bar .form-group .flatpickr-input:focus {
            border-color: #2563eb;
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
        }

        .btn-filter-submit {
            box-sizing: border-box;
            height: 38px;
            padding: 0 22px;
            background: #2563eb;
            color: #ffffff;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            font-size: 13.5px;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin: 0 !important;
            transition: all 0.15s ease;
            font-family: inherit;
            box-shadow: 0 1px 2px rgba(37, 99, 235, 0.15);
        }

        .btn-filter-submit:hover {
            background: #1d4ed8;
            transform: translateY(-1px);
            box-shadow: 0 3px 6px rgba(37, 99, 235, 0.2);
        }

        .btn-filter-submit:active {
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

        <div class="page-header" style="margin-bottom: 24px;">
            <h1 style="font-size: 24px; font-weight: 700; color: #111827; margin-bottom: 4px;">Lịch sử chấm công của tôi</h1>
            <p style="font-size: 14px; color: #4b5563;">
                Xem lại thông tin check-in / check-out theo khoảng thời gian bạn chọn.
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
                <input type="text"
                       id="fromDate"
                       name="fromDate"
                       placeholder="dd/mm/yyyy"
                       value="${fromDate}" />
            </div>

            <div class="form-group">
                <label for="toDate">Đến ngày</label>
                <input type="text"
                       id="toDate"
                       name="toDate"
                       placeholder="dd/mm/yyyy"
                       value="${toDate}" />
            </div>

            <button type="submit" class="btn-filter-submit">
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
    function formatToDDMMYYYY(val) {
        if (!val) return '';
        val = val.trim();
        // Xử lý dạng có dấu phân cách (ví dụ 2/11/2024 hoặc 2-11-2024)
        var parts = val.split(/[\/\-\.]/);
        if (parts.length === 3) {
            var d = parseInt(parts[0], 10);
            var m = parseInt(parts[1], 10);
            var y = parseInt(parts[2], 10);
            if (!isNaN(d) && !isNaN(m) && !isNaN(y)) {
                var dd = d < 10 ? '0' + d : '' + d;
                var mm = m < 10 ? '0' + m : '' + m;
                var yyyy = y < 100 ? (2000 + y) : '' + y;
                return dd + '/' + mm + '/' + yyyy;
            }
        }
        // Xử lý dạng chuỗi số liền nhau (ví dụ 02112024)
        var digits = val.replace(/\D/g, '');
        if (digits.length === 8) {
            return digits.slice(0, 2) + '/' + digits.slice(2, 4) + '/' + digits.slice(4, 8);
        }
        return val;
    }

    function initSmartDatePicker(selector) {
        if (typeof flatpickr === "undefined") return;
        var vnLocale = typeof flatpickr.l10ns.vn !== "undefined" ? flatpickr.l10ns.vn : "default";

        return flatpickr(selector, {
            dateFormat: "Y-m-d",
            altInput: true,
            altFormat: "d/m/Y",
            altInputClass: "flatpickr-input",
            allowInput: true,
            locale: vnLocale,
            parseDate: function(datestr, format) {
                if (!datestr) return null;
                var match = datestr.match(/^(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{4})$/);
                if (match) {
                    var day = parseInt(match[1], 10);
                    var month = parseInt(match[2], 10) - 1;
                    var year = parseInt(match[3], 10);
                    return new Date(year, month, day);
                }
                var isoMatch = datestr.match(/^(\d{4})[\/\-\.](\d{1,2})[\/\-\.](\d{1,2})$/);
                if (isoMatch) {
                    var year = parseInt(isoMatch[1], 10);
                    var month = parseInt(isoMatch[2], 10) - 1;
                    var day = parseInt(isoMatch[3], 10);
                    return new Date(year, month, day);
                }
                return flatpickr.parseDate(datestr, format);
            },
            onReady: function(selectedDates, dateStr, instance) {
                if (instance.altInput) {
                    // Tự động thêm số 0 khi nhập thiếu (ví dụ 2/11/2024 -> 02/11/2024)
                    instance.altInput.addEventListener('blur', function() {
                        var formatted = formatToDDMMYYYY(instance.altInput.value);
                        if (formatted !== instance.altInput.value) {
                            instance.altInput.value = formatted;
                        }
                        instance.setDate(instance.altInput.value, true, "d/m/Y");
                    });

                    // Tự động chèn dấu '/' khi người dùng gõ số
                    instance.altInput.addEventListener('input', function(e) {
                        if (e.inputType === 'deleteContentBackward') return;
                        var v = this.value;
                        var clean = v.replace(/[^\d\/]/g, '');
                        if (clean.length === 2 && !clean.includes('/')) {
                            this.value = clean + '/';
                        } else if (clean.length === 5 && clean.indexOf('/', 3) === -1) {
                            this.value = clean + '/';
                        }
                    });
                }
            }
        });
    }

    document.addEventListener("DOMContentLoaded", function() {
        initSmartDatePicker("#fromDate");
        initSmartDatePicker("#toDate");
    });
</script>
</body>
</html>