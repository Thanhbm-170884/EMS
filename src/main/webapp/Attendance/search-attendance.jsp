<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">

<head>

    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>

    <title>EMS – Tìm kiếm chấm công</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/ems.css"/>

    <style>
    .pagination {
        display: flex;
        justify-content: center;
        align-items: center;
        gap: 6px;
        padding: 20px;
    }

    .pagination a,
    .pagination span {
        min-width: 36px;
        height: 36px;
        padding: 0 10px;

        display: inline-flex;
        align-items: center;
        justify-content: center;

        border: 1px solid #cbd5e1;
        border-radius: 8px;

        background: white;
        color: #475569;

        text-decoration: none;
        font-size: 14px;
        font-weight: 600;

        box-sizing: border-box;
    }

    .pagination a:hover {
        background: #f1f5f9;
    }

    .pagination .active {
        background: #1e3a8a;
        color: white;
        border-color: #1e3a8a;
    }

    .pagination .disabled {
        color: #cbd5e1;
        background: #f8fafc;
        cursor: not-allowed;
    }
    .btn-clear {
        height: 40px;
        box-sizing: border-box;
        padding: 10px 20px;
        background: #64748b;
        color: white;
        border: none;
        border-radius: 8px;
        font-weight: 600;
        cursor: pointer;
        font-size: 14px;
    }

    .btn-clear:hover {
        background: #475569;
    }

        .search-card {
            background: white;
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 20px;
        }

        .search-form {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr auto;
            gap: 15px;
            align-items: end;
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }

        .form-group label {
            font-size: 13px;
            font-weight: 600;
            color: #475569;
            margin-bottom: 7px;
        }

        .form-group input {
            height: 40px;
            box-sizing: border-box;
            padding: 8px 12px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 14px;
        }

        .search-button-group {
            display: flex;
            align-items: flex-end;
            gap: 10px;
        }

        .search-button-group .btn-search,
        .search-button-group .btn-clear {
            width: auto !important;
            min-width: 120px !important;
            height: 40px !important;
            min-height: 40px !important;
            max-height: 40px !important;

            box-sizing: border-box !important;

            padding: 0 20px !important;
            margin: 0 !important;

            border: none !important;
            border-radius: 8px !important;

            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;

            font-family: inherit;
            font-size: 14px !important;
            font-weight: 600 !important;

            cursor: pointer;
            line-height: normal !important;
        }

        .search-button-group .btn-search {
            background: #2563eb !important;
            color: white !important;
            box-shadow: 0 1px 2px rgba(37, 99, 235, 0.2);
            transition: all 0.15s ease;
        }

        .search-button-group .btn-search:hover {
            background: #1d4ed8 !important;
            box-shadow: 0 3px 6px rgba(37, 99, 235, 0.25);
            transform: translateY(-1px);
        }

        .search-button-group .btn-clear {
            background: #f1f5f9 !important;
            color: #475569 !important;
            border: 1px solid #e2e8f0 !important;
            transition: all 0.15s ease;
        }

        .search-button-group .btn-clear:hover {
            background: #e2e8f0 !important;
            color: #1e293b !important;
        }

        .btn-back {
            display: inline-flex;
            align-items: center;
            padding: 10px 18px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            text-decoration: none;
            color: #475569;
            background: white;
            font-weight: 600;
        }

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

        .badge-success {
            background: #d1fae5;
            color: #059669;
        }

        .badge-danger {
            background: #fee2e2;
            color: #dc2626;
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
        }

        @media (max-width: 900px) {

            .search-form {
                grid-template-columns: 1fr 1fr;
            }

        }

    </style>

</head>


<body>


<%@ include file="/WEB-INF/jspf/sidebar.jsp" %>


<!-- ================= MAIN ================= -->

<div class="main-content">


    <!-- HEADER -->

    <div class="topbar">

        <span class="topbar-left">
            Chấm công
        </span>

        <span class="topbar-right"
              id="topbar-date">
        </span>

    </div>


    <div class="page-body">


        <!-- PAGE HEADER -->

        <div class="page-header">

            <h1>
                Tìm kiếm chấm công
            </h1>

            <p>
                Tìm kiếm lịch sử chấm công của nhân viên.
            </p>

        </div>


        <!-- ERROR -->

        <c:if test="${not empty error}">

            <div class="alert-danger">

                ⚠ ${error}

            </div>

        </c:if>


        <!-- SEARCH -->

        <div class="search-card">

            <div class="card-header"
                 style="margin-bottom:20px;">

                Điều kiện tìm kiếm

            </div>


            <form class="search-form"
                  method="get"
                  action="${pageContext.request.contextPath}/Attendance/search-attendance">


                <!-- TÊN -->

                <div class="form-group">

                    <label>
                        Tên nhân viên
                    </label>

                    <input type="text"
                           name="employeeName"
                           value="${employeeName}"
                           placeholder="Nhập tên nhân viên">

                </div>


                <!-- MÃ -->

                <div class="form-group">

                    <label>
                        Mã nhân viên
                    </label>

                    <input type="text"
                           name="employeeCode"
                           value="${employeeCode}"
                           placeholder="Nhập mã nhân viên">

                </div>


                <!-- DATE -->

                <div class="form-group">

                    <label>
                        Ngày
                    </label>

                    <input type="date"
                           name="date"
                           value="${date}">

                </div>


                <div class="search-button-group">

                    <button type="submit" class="btn-search">
                        Tìm kiếm
                    </button>

                    <button type="button"
                            class="btn-clear"
                            onclick="clearFilter()">
                        Đặt lại
                    </button>

                </div>

            </form>

        </div>


        <!-- ================= RESULT ================= -->

        <div id="resultCard"
             class="card"
             style="padding:0; overflow:hidden;">


            <div class="card-header">

                Kết quả tìm kiếm

            </div>


            <div style="overflow-x:auto;">

                <table class="preview-table">

                    <thead>

                    <tr>

                        <th>Ngày</th>

                        <th>Mã NV</th>

                        <th>Họ và Tên</th>

                        <th>Check in</th>

                        <th>Check out</th>

                        <th>Trạng thái</th>

                    </tr>

                    </thead>


                    <tbody>


                    <c:choose>


                        <c:when test="${not empty results}">


                            <c:forEach var="r"
                                       items="${results}">

                                <tr>

                                    <td>
                                        ${r.date}
                                    </td>


                                    <td style="font-weight:600;">

                                        ${r.employeeCode}

                                    </td>


                                    <td>

                                        ${r.fullName}

                                    </td>


                                    <td>

                                        ${r.checkIn != null ? r.checkIn : '—'}

                                    </td>


                                    <td>

                                        ${r.checkOut != null ? r.checkOut : '—'}

                                    </td>


                                    <td>

                                        <c:choose>

                                            <c:when test="${r.checkIn == null}">

                                                <span class="badge badge-danger">
                                                    Vắng
                                                </span>

                                            </c:when>


                                            <c:when test="${r.checkOut == null}">

                                                <span class="badge badge-warning">
                                                    Thiếu Check out
                                                </span>

                                            </c:when>


                                            <c:otherwise>

                                                <span class="badge badge-success">
                                                    Đã chấm công
                                                </span>

                                            </c:otherwise>

                                        </c:choose>

                                    </td>

                                </tr>

                            </c:forEach>


                        </c:when>


                        <c:otherwise>

                            <tr>

                                <td colspan="6"
                                    style="
                                    text-align:center;
                                    padding:40px;
                                    color:#94a3b8;
                                    ">

                                    Chưa có dữ liệu tìm kiếm.

                                </td>

                            </tr>

                        </c:otherwise>


                    </c:choose>


                    </tbody>

                </table>
                <!-- PHÂN TRANG -->

                <c:if test="${totalPages > 1}">

                    <div class="pagination">

                        <!-- Trang trước -->

                        <c:choose>

                            <c:when test="${currentPage > 1}">
                                <a href="${pageContext.request.contextPath}/Attendance/search-attendance?employeeName=${employeeName}&employeeCode=${employeeCode}&date=${date}&page=${i}">
                                    ${i}
                                </a>
                            </c:when>

                            <c:otherwise>
                                <span class="disabled">
                                    ←
                                </span>
                            </c:otherwise>

                        </c:choose>


                        <!-- Các số trang -->

                        <c:forEach var="i"
                                   begin="1"
                                   end="${totalPages}">

                            <c:choose>

                                <c:when test="${i == currentPage}">

                                    <span class="active">
                                        ${i}
                                    </span>

                                </c:when>

                                <c:otherwise>

                                    <a href="${pageContext.request.contextPath}/Attendance/search-attendance
                                        ?employeeName=${employeeName}
                                        &employeeCode=${employeeCode}
                                        &date=${date}
                                        &page=${i}">
                                        ${i}
                                    </a>

                                </c:otherwise>

                            </c:choose>

                        </c:forEach>


                        <!-- Trang sau -->

                        <c:choose>

                            <c:when test="${currentPage < totalPages}">

                                <a href="${pageContext.request.contextPath}/Attendance/search-attendance
                                    ?employeeName=${employeeName}
                                    &employeeCode=${employeeCode}
                                    &date=${date}
                                    &page=${currentPage + 1}">
                                    →
                                </a>

                            </c:when>

                            <c:otherwise>

                                <span class="disabled">
                                    →
                                </span>

                            </c:otherwise>

                        </c:choose>

                    </div>

                </c:if>

            </div>

        </div>


        <div style="margin-top:20px;">

            <a href="${pageContext.request.contextPath}/Attendance/upload.jsp"
               class="btn-back">

                ← Quay lại quản lý chấm công

            </a>

        </div>


    </div>


    <footer>

        © 2026 Hệ thống Quản lý Nhân sự (EMS) · FPT University SWP391

    </footer>

</div>


<script>

    function tick() {

        var now = new Date();

        var p = function(n) {
            return String(n).padStart(2, '0');
        };

        var element =
            document.getElementById('topbar-date');

        if (element) {

            element.textContent =
                p(now.getDate()) + '/' +
                p(now.getMonth() + 1) + '/' +
                now.getFullYear();

        }

    }

    tick();


</script>
<script>
    function clearFilter() {

        // Xóa ô Tên nhân viên
        document.querySelector('input[name="employeeName"]').value = '';

        // Xóa ô Mã nhân viên
        document.querySelector('input[name="employeeCode"]').value = '';

        // Xóa ô Ngày
        document.querySelector('input[name="date"]').value = '';

        // Ẩn bảng kết quả
        const resultCard = document.getElementById('resultCard');

        if (resultCard) {
            resultCard.style.display = 'none';
        }
    }
</script>

</body>
</html>