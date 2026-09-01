<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="j" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <title>EMS – Lịch sử chấm công của tôi</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/ems.css"/>

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

        .filter-bar .form-group input {
            box-sizing: border-box;
            height: 40px;
            padding: 8px 12px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 14px;
            color: #1e293b;
            background: #ffffff;
            outline: none;
            margin: 0 !important;
            font-family: inherit;
        }

        .filter-bar .form-group input:focus {
            border-color: #2563eb;
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
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