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

        .flatpickr-calendar {
            border-radius: 12px !important;
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1) !important;
            border: 1px solid #e2e8f0 !important;
            font-family: inherit !important;
        }

        .flatpickr-months {
            padding: 6px 4px 0 !important;
            align-items: center !important;
        }

        .flatpickr-current-month {
            padding: 4px 0 0 0 !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            gap: 4px !important;
        }

        .flatpickr-current-month .flatpickr-monthDropdown-months {
            font-size: 13.5px !important;
            font-weight: 600 !important;
            padding: 2px 6px !important;
            border-radius: 6px !important;
        }

        .flatpickr-current-month .numInputWrapper {
            font-size: 13.5px !important;
            font-weight: 600 !important;
            width: 65px !important;
        }

        .flatpickr-months .flatpickr-prev-month,
        .flatpickr-months .flatpickr-next-month {
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            height: 32px !important;
            width: 32px !important;
            padding: 0 !important;
            top: 6px !important;
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
        <div id="clientErrorAlert" class="alert-danger" style="display: none;"></div>

        <form class="filter-bar"
              method="get"
              action="${pageContext.request.contextPath}/Attendance/my-attendance"
              onsubmit="return validateAttendanceFilter(event)">

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
    function attachDateMask(input, instance) {
        if (!input) return;

        input.addEventListener('keydown', function(e) {
            if (['Backspace', 'Delete', 'Tab', 'ArrowLeft', 'ArrowRight', 'Home', 'End', 'Enter'].includes(e.key)) {
                return;
            }
            if (!/^\d$/.test(e.key)) {
                e.preventDefault();
            }
        });

        input.addEventListener('input', function(e) {
            if (e.inputType === 'deleteContentBackward' || e.inputType === 'deleteContentForward') {
                return;
            }
            var raw = this.value.replace(/\D/g, '');
            if (raw.length === 0) return;

            var res = '';
            // Xử lý ngày (dd)
            if (raw.length >= 1) {
                var d1 = parseInt(raw[0], 10);
                if (d1 > 3 && raw.length === 1) {
                    res = '0' + d1 + '/';
                } else if (raw.length >= 2) {
                    var dd = parseInt(raw.slice(0, 2), 10);
                    if (dd > 31) dd = 31;
                    if (dd === 0) dd = 1;
                    var ddStr = dd < 10 ? '0' + dd : '' + dd;
                    res = ddStr + '/';
                } else {
                    res = raw.slice(0, 1);
                }
            }

            // Xử lý tháng (mm)
            if (raw.length >= 3) {
                var dayStr = res.slice(0, 2);
                var mPart = raw.slice(2);
                if (mPart.length >= 1) {
                    var m1 = parseInt(mPart[0], 10);
                    if (m1 > 1 && mPart.length === 1) {
                        res = dayStr + '/0' + m1 + '/';
                    } else if (mPart.length >= 2) {
                        var mm = parseInt(mPart.slice(0, 2), 10);
                        if (mm > 12) mm = 12;
                        if (mm === 0) mm = 1;
                        var mmStr = mm < 10 ? '0' + mm : '' + mm;
                        res = dayStr + '/' + mmStr + '/';
                    } else {
                        res = dayStr + '/' + mPart.slice(0, 1);
                    }
                }
            }

            // Xử lý năm (yyyy)
            if (raw.length >= 5) {
                var dayStr = res.slice(0, 2);
                var monthStr = res.slice(3, 5);
                var yPart = raw.slice(4, 8);
                res = dayStr + '/' + monthStr + '/' + yPart;
            }

            this.value = res;

            if (res.length === 10 && instance) {
                instance.setDate(res, false, "d/m/Y");
            }
        });

        input.addEventListener('blur', function() {
            var val = this.value.trim();
            if (!val) return;
            var parts = val.split('/');
            if (parts.length === 3) {
                var d = parseInt(parts[0], 10);
                var m = parseInt(parts[1], 10);
                var y = parseInt(parts[2], 10);
                if (!isNaN(d) && !isNaN(m) && !isNaN(y)) {
                    if (d < 1) d = 1;
                    if (d > 31) d = 31;
                    if (m < 1) m = 1;
                    if (m > 12) m = 12;
                    if (y < 100) y = 2000 + y;
                    var dd = d < 10 ? '0' + d : '' + d;
                    var mm = m < 10 ? '0' + m : '' + m;
                    this.value = dd + '/' + mm + '/' + y;
                    if (instance) {
                        instance.setDate(this.value, false, "d/m/Y");
                    }
                }
            }
        });
    }

    var fromPicker = null;
    var toPicker = null;

    function validateAttendanceFilter(e) {
        var fromInput = document.getElementById('fromDate');
        var toInput = document.getElementById('toDate');
        var fromVal = fromInput ? fromInput.value : '';
        var toVal = toInput ? toInput.value : '';
        var errorBox = document.getElementById('clientErrorAlert');

        if (fromVal && toVal) {
            var from = new Date(fromVal);
            var to = new Date(toVal);
            if (from > to) {
                if (e) e.preventDefault();
                if (errorBox) {
                    errorBox.innerHTML = '⚠ <strong>Lỗi:</strong> Ngày bắt đầu không được sau ngày kết thúc.';
                    errorBox.style.display = 'block';
                    errorBox.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
                return false;
            }
        }
        if (errorBox) errorBox.style.display = 'none';
        return true;
    }

    document.addEventListener("DOMContentLoaded", function() {
        if (typeof flatpickr !== "undefined") {
            var customVnLocale = {
                firstDayOfWeek: 1,
                weekdays: {
                    shorthand: ["CN", "T2", "T3", "T4", "T5", "T6", "T7"],
                    longhand: ["Chủ Nhật", "Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy"]
                },
                months: {
                    shorthand: ["Thg 1", "Thg 2", "Thg 3", "Thg 4", "Thg 5", "Thg 6", "Thg 7", "Thg 8", "Thg 9", "Thg 10", "Thg 11", "Thg 12"],
                    longhand: ["Tháng 1", "Tháng 2", "Tháng 3", "Tháng 4", "Tháng 5", "Tháng 6", "Tháng 7", "Tháng 8", "Tháng 9", "Tháng 10", "Tháng 11", "Tháng 12"]
                }
            };

            fromPicker = flatpickr("#fromDate", {
                dateFormat: "Y-m-d",
                altInput: true,
                altFormat: "d/m/Y",
                altInputClass: "flatpickr-input",
                allowInput: true,
                locale: customVnLocale,
                onChange: function(selectedDates) {
                    if (selectedDates.length > 0 && toPicker) {
                        toPicker.set("minDate", selectedDates[0]);
                    }
                    var errorBox = document.getElementById('clientErrorAlert');
                    if (errorBox) errorBox.style.display = 'none';
                },
                onReady: function(selectedDates, dateStr, instance) {
                    if (instance.altInput) {
                        attachDateMask(instance.altInput, instance);
                    }
                }
            });

            toPicker = flatpickr("#toDate", {
                dateFormat: "Y-m-d",
                altInput: true,
                altFormat: "d/m/Y",
                altInputClass: "flatpickr-input",
                allowInput: true,
                locale: customVnLocale,
                onChange: function(selectedDates) {
                    if (selectedDates.length > 0 && fromPicker) {
                        fromPicker.set("maxDate", selectedDates[0]);
                    }
                    var errorBox = document.getElementById('clientErrorAlert');
                    if (errorBox) errorBox.style.display = 'none';
                },
                onReady: function(selectedDates, dateStr, instance) {
                    if (instance.altInput) {
                        attachDateMask(instance.altInput, instance);
                    }
                }
            });
        }
    });
</script>
</body>
</html>