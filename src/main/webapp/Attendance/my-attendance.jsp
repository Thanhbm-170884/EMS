<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>EMS – Lịch sử chấm công của tôi</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ems.css?v=3.0"/>

    <style>
        .filter-bar {
            display: flex;
            align-items: flex-end;
            gap: 14px;
            margin-bottom: 24px;
            flex-wrap: wrap;
            background: #ffffff;
            padding: 16px 20px;
            border-radius: 12px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.03);
        }

        .filter-bar .form-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .filter-bar .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #334155;
        }

        .filter-bar .form-group input[type="date"] {
            box-sizing: border-box;
            height: 38px;
            padding: 6px 12px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 13.5px;
            color: #1e293b;
            background-color: #f8fafc;
            outline: none;
            transition: all 0.15s ease;
            font-family: inherit;
        }

        .filter-bar .form-group input[type="date"]:focus {
            background-color: #ffffff;
            border-color: #2563eb;
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
        }

        .btn-filter-submit {
            height: 38px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0 20px;
            background: #2563eb;
            color: #ffffff;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            font-size: 13.5px;
            cursor: pointer;
            transition: all 0.15s ease;
            box-shadow: 0 1px 2px rgba(37, 99, 235, 0.2);
            font-family: inherit;
        }

        .btn-filter-submit:hover {
            background: #1d4ed8;
            box-shadow: 0 3px 6px rgba(37, 99, 235, 0.25);
            transform: translateY(-1px);
        }

        .btn-filter-submit:active {
            transform: translateY(0);
        }

        .btn-filter-reset {
            height: 38px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0 16px;
            background: #f1f5f9;
            color: #475569;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            font-weight: 500;
            font-size: 13.5px;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.15s ease;
            font-family: inherit;
        }

        .btn-filter-reset:hover {
            background: #e2e8f0;
            color: #1e293b;
        }

        .preview-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
            font-size: 13.5px;
        }

        .preview-table th {
            background: #f8fafc;
            color: #64748b;
            font-weight: 700;
            padding: 13px 18px;
            border-bottom: 1.5px solid #e2e8f0;
            text-transform: uppercase;
            font-size: 11.5px;
            letter-spacing: .5px;
        }

        .preview-table td {
            padding: 13px 18px;
            border-bottom: 1px solid #f1f5f9;
            color: #1e293b;
            font-weight: 500;
        }

        .preview-table tr:hover td {
            background: #f8fafc;
        }

        .badge {
            display: inline-flex;
            align-items: center;
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

        .alert-danger {
            background: #fef2f2;
            border: 1px solid #fecaca;
            color: #b91c1c;
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 13.5px;
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
                <label>Từ ngày</label>
                <input type="date"
                       name="fromDate"
                       value="${fromDate}" />
            </div>

            <div class="form-group">
                <label>Đến ngày</label>
                <input type="date"
                       name="toDate"
                       value="${toDate}" />
            </div>

            <button type="submit" class="btn-filter-submit">
                Lọc
            </button>

            <% if (request.getParameter("fromDate") != null || request.getParameter("toDate") != null) { %>
                <a href="${pageContext.request.contextPath}/Attendance/my-attendance.jsp" class="btn-filter-reset">
                    Đặt lại
                </a>
            <% } %>

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

                                    <td>${h.date}</td>

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

</body>
</html>