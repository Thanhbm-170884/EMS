<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">

<head>

    <meta charset="UTF-8"/>

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0"/>

    <title>EMS – Xem trước dữ liệu chấm công</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/ems.css"/>


    <style>

        /* =====================================================
           BẢNG CHẤM CÔNG
           ===================================================== */

        .preview-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
            font-size: 14px;
        }

        .preview-table th {
            background-color: #f1f5f9;
            color: #475569;
            font-weight: 600;
            padding: 12px 16px;
            border-bottom: 1px solid #e2e8f0;
            text-transform: uppercase;
            font-size: 12px;
            letter-spacing: 0.5px;
        }

        .preview-table td {
            padding: 12px 16px;
            border-bottom: 1px solid #f1f5f9;
            color: #334155;
        }

        .preview-table tr:hover {
            background-color: #f8fafc;
        }


        /* =====================================================
           BADGE
           ===================================================== */

        .badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 9999px;
            font-size: 12px;
            font-weight: 600;
        }

        .badge-danger {
            background-color: #fee2e2;
            color: #dc2626;
        }

        .badge-success {
            background-color: #d1fae5;
            color: #059669;
        }


        /* =====================================================
           BUTTON
           ===================================================== */

        .btn-action-group {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-top: 20px;
        }

        .btn-primary {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 10px 20px;
            background: #1e3a8a;
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            font-size: 14px;
        }

        .btn-primary:hover {
            background: #172554;
        }

        .btn-secondary {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 9px 18px;
            background: #ffffff;
            color: #475569;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            font-size: 14px;
        }

        .btn-secondary:hover {
            background: #f8fafc;
            color: #0f172a;
        }

        .btn-edit {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 7px 12px;
            background: #eff6ff;
            color: #1d4ed8;
            border: 1px solid #bfdbfe;
            border-radius: 7px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
        }

        .btn-edit:hover {
            background: #dbeafe;
            color: #1e40af;
        }


        /* =====================================================
           ALERT
           ===================================================== */

        .alert-danger {
            background-color: #fef2f2;
            border: 1px solid #fecaca;
            color: #b91c1c;
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
        }


        /* =====================================================
           EDIT ATTENDANCE MODAL
           ===================================================== */

        .modal-overlay {
            display: none;

            position: fixed;
            top: 0;
            left: 0;

            width: 100%;
            height: 100%;

            background: rgba(15, 23, 42, 0.55);

            justify-content: center;
            align-items: center;

            z-index: 99999;

            padding: 20px;
            box-sizing: border-box;
        }

        .modal-overlay.show {
            display: flex;
        }

        .modal-content {
            width: 100%;
            max-width: 440px;

            background: #ffffff;

            border-radius: 14px;

            padding: 24px;

            box-sizing: border-box;

            box-shadow:
                0 20px 40px rgba(0, 0, 0, 0.18);

            animation: modalAppear 0.2s ease-out;
        }

        @keyframes modalAppear {

            from {
                opacity: 0;
                transform: translateY(-15px) scale(0.98);
            }

            to {
                opacity: 1;
                transform: translateY(0) scale(1);
            }

        }


        /* =====================================================
           EDIT MODAL HEADER
           ===================================================== */

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;

            margin-bottom: 22px;
        }

        .modal-header h2 {
            margin: 0;

            font-size: 20px;
            font-weight: 700;

            color: #0f172a;
        }

        .modal-close {
            width: 34px;
            height: 34px;

            border: none;
            background: transparent;

            border-radius: 7px;

            font-size: 27px;
            line-height: 1;

            color: #64748b;

            cursor: pointer;
        }

        .modal-close:hover {
            background: #f1f5f9;
            color: #dc2626;
        }


        /* =====================================================
           EDIT FORM
           ===================================================== */

        .edit-form-group {
            margin-bottom: 17px;
        }

        .edit-form-group label {
            display: block;

            margin-bottom: 7px;

            font-size: 13px;
            font-weight: 600;

            color: #475569;
        }

        .edit-form-group input {
            width: 100%;
            box-sizing: border-box;

            padding: 10px 12px;

            border: 1px solid #cbd5e1;
            border-radius: 8px;

            font-size: 14px;

            color: #0f172a;

            background: #ffffff;
        }

        .edit-form-group input:focus {
            outline: none;

            border-color: #2563eb;

            box-shadow:
                0 0 0 3px rgba(37, 99, 235, 0.10);
        }

        .edit-form-group input[readonly] {
            background: #f1f5f9;
            color: #64748b;
            cursor: not-allowed;
        }


        /* =====================================================
           EDIT MODAL BUTTONS
           ===================================================== */

        .modal-actions {
            display: flex;

            justify-content: flex-end;

            gap: 10px;

            margin-top: 24px;

            padding-top: 18px;

            border-top: 1px solid #e2e8f0;
        }


        /* =====================================================
           SUCCESS MESSAGE
           ===================================================== */

        .alert-success {
            position: fixed;

            top: 50%;
            left: 50%;

            transform: translate(-50%, -50%);

            background: #d1fae5;
            color: #065f46;

            padding: 14px 24px;

            border-radius: 8px;

            box-shadow:
                0 4px 15px rgba(0, 0, 0, 0.2);

            font-size: 15px;
            font-weight: 500;

            z-index: 99999;

            animation: fadeInOut 3s ease forwards;
        }

        @keyframes fadeInOut {

            0% {
                opacity: 0;
                transform: translate(-50%, -60%);
            }

            10% {
                opacity: 1;
                transform: translate(-50%, -50%);
            }

            80% {
                opacity: 1;
                transform: translate(-50%, -50%);
            }

            100% {
                opacity: 0;
                transform: translate(-50%, -40%);
            }

        }
        /* =========================
           PAGINATION
           ========================= */

        .pagination-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px 20px;
            border-top: 1px solid #e2e8f0;
            background: #ffffff;
            flex-wrap: wrap;
            gap: 12px;
        }

        .pagination-info {
            font-size: 13px;
            color: #64748b;
        }

        .pagination {
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .pagination button {
            min-width: 36px;
            height: 36px;

            padding: 0 10px;

            border: 1px solid #cbd5e1;
            background: #ffffff;
            color: #475569;

            border-radius: 7px;

            font-size: 13px;
            font-weight: 600;

            cursor: pointer;
        }

        .pagination button:hover:not(:disabled) {
            background: #f1f5f9;
        }

        .pagination button.active {
            background: #1e3a8a;
            color: #ffffff;
            border-color: #1e3a8a;
        }

        .pagination button:disabled {
            opacity: 0.45;
            cursor: not-allowed;
        }

        .pagination-size {
            display: flex;
            align-items: center;
            gap: 8px;

            font-size: 13px;
            color: #64748b;
        }

        .pagination-size select {
            height: 36px;

            padding: 0 30px 0 10px;

            border: 1px solid #cbd5e1;
            border-radius: 7px;

            background: #ffffff;

            font-size: 13px;
            color: #334155;

            cursor: pointer;
        }


        /* =====================================================
           EXPORT EXCEL MODAL
           ===================================================== */

        .export-modal-overlay {

            display: none;

            position: fixed;

            inset: 0;

            background: rgba(15, 23, 42, 0.45);

            align-items: center;
            justify-content: center;

            z-index: 99998;

            padding: 20px;

            box-sizing: border-box;
        }

        .export-modal-overlay.show {
            display: flex;
        }


        .export-modal {

            width: 420px;

            max-width: calc(100% - 32px);

            background: #ffffff;

            border-radius: 12px;

            box-shadow:
                0 20px 50px rgba(0, 0, 0, 0.2);

            overflow: hidden;

            animation: modalAppear 0.2s ease-out;
        }


        /* EXPORT HEADER */

        .export-modal-header {

            display: flex;

            align-items: center;

            justify-content: space-between;

            padding: 18px 20px;

            border-bottom: 1px solid #e2e8f0;
        }

        .export-modal-header h2 {

            margin: 0;

            font-size: 18px;

            color: #1e293b;
        }


        .export-modal-close {

            width: 34px;
            height: 34px;

            border: none;

            background: transparent;

            font-size: 26px;

            color: #64748b;

            cursor: pointer;

            border-radius: 7px;
        }

        .export-modal-close:hover {

            background: #f1f5f9;

            color: #dc2626;
        }


        /* EXPORT BODY */

        .export-modal-body {

            padding: 20px;
        }

        .export-modal-body label {

            display: block;

            margin-bottom: 8px;

            font-size: 14px;

            font-weight: 600;

            color: #334155;
        }

        .export-modal-body input {

            width: 100%;

            box-sizing: border-box;

            padding: 10px 12px;

            border: 1px solid #cbd5e1;

            border-radius: 8px;

            font-size: 14px;

            outline: none;
        }

        .export-modal-body input:focus {

            border-color: #059669;

            box-shadow:
                0 0 0 3px rgba(5, 150, 105, 0.10);
        }


        .file-extension {

            margin-top: 8px;

            font-size: 12px;

            color: #94a3b8;
        }


        /* EXPORT FOOTER */

        .export-modal-footer {

            display: flex;

            justify-content: flex-end;

            gap: 10px;

            padding: 16px 20px;

            border-top: 1px solid #e2e8f0;
        }


        .btn-export {

            display: inline-flex;

            align-items: center;
            justify-content: center;

            padding: 10px 20px;

            border: none;

            background: #059669;

            color: #ffffff;

            border-radius: 8px;

            font-weight: 600;

            cursor: pointer;

            font-size: 14px;
        }

        .btn-export:hover {

            background: #047857;
        }

    </style>

</head>


<body>


<!-- =========================================================
     SIDEBAR
     ========================================================= -->

<aside class="sidebar">

    <a href="${pageContext.request.contextPath}/home"
       class="sidebar-brand">

        <div class="brand-dot">
            E
        </div>

        <span class="brand-name">
            EMS
        </span>

    </a>


    <nav class="nav-group">

        <div class="nav-section-label">
            Menu chính
        </div>


        <a href="${pageContext.request.contextPath}/home_manager.jsp"
           class="nav-link ${pageContext.request.servletPath == '/home_manager.jsp' ? 'active' : ''}">
            Trang chủ
        </a>


        <div class="nav-section-label">
            Quản lý
        </div>


        <a href="${pageContext.request.contextPath}/work-schedule"
           class="nav-link ${pageContext.request.servletPath == '/work-schedule.jsp' ? 'active' : ''}">
            Lịch làm việc
        </a>


        <a href="${pageContext.request.contextPath}/requests?action=pending"
           class="nav-link ${pageContext.request.servletPath == '/request-manager.jsp' ? 'active' : ''}">
            Xử lý đơn
        </a>


        <a href="${pageContext.request.contextPath}/holiday"
           class="nav-link ${pageContext.request.servletPath == '/holiday.jsp' ? 'active' : ''}">
            Quản lý ngày nghỉ lễ
        </a>


        <a href="${pageContext.request.contextPath}/shift-management"
           class="nav-link ${pageContext.request.servletPath == '/shift-management.jsp' ? 'active' : ''}">
            Ca làm việc
        </a>


        <a href="${pageContext.request.contextPath}/shift-assignment"
           class="nav-link ${pageContext.request.servletPath == '/shift-assignment.jsp' ? 'active' : ''}">
            Phân ca làm việc
        </a>


        <a href="${pageContext.request.contextPath}/salary-management"
           class="nav-link ${pageContext.request.servletPath == '/salary-management.jsp' ? 'active' : ''}">
            Quản lý lương
        </a>


        <a href="${pageContext.request.contextPath}/Attendance/upload.jsp"
           class="nav-link ${pageContext.request.servletPath == '/Attendance/attendance.jsp' ? 'active' : ''}">
            Quản lý chấm công
        </a>

    </nav>


    <div class="sidebar-footer">

        <div class="user-block">

            <div class="user-avatar">
                M
            </div>

            <div>

                <div class="user-name">
                    Manager
                </div>

                <div class="user-role">
                    Quản lý
                </div>

            </div>

        </div>


        <button class="btn-logout"
                onclick="window.location='${pageContext.request.contextPath}/login'">

            Đăng xuất

        </button>

    </div>

</aside>


<!-- =========================================================
     MAIN CONTENT
     ========================================================= -->

<div class="main-content">


    <!-- TOPBAR -->

    <div class="topbar">

        <span class="topbar-left">
            Chấm công
        </span>


        <div>

            <span class="topbar-right"
                  id="topbar-date">
            </span>

        </div>

    </div>


    <div class="page-body">


        <!-- =====================================================
             PAGE HEADER
             ===================================================== -->

        <div class="page-header"
             style="
                 display:flex;
                 justify-content:space-between;
                 align-items:flex-start;
                 flex-wrap:wrap;
                 gap:15px;
             ">

            <div>

                <h1>
                    Xem trước dữ liệu chấm công
                </h1>

                <p>

                    Đã đọc

                    <strong>
                        ${sessionScope.previewList.size()}
                    </strong>

                    dòng từ file Excel.

                    Kiểm tra lại trước khi xác nhận lưu.

                </p>

            </div>


            <a href="${pageContext.request.contextPath}/Attendance/upload.jsp"
               class="btn-secondary">

                ↻ Upload lại file khác

            </a>
            <a href="${pageContext.request.contextPath}/Attendance/upload.jsp"
                           class="btn-secondary">

                            Tìm kiếm

            </a>

        </div>


        <!-- =====================================================
             ERROR
             ===================================================== -->

        <% if (request.getAttribute("error") != null) { %>

            <div class="alert-danger">

                ⚠ <%= request.getAttribute("error") %>

            </div>

        <% } %>


        <!-- =====================================================
             ATTENDANCE TABLE
             ===================================================== -->

        <div class="card"
             style="padding:0; overflow:hidden;">

            <div class="card-header">
                Danh sách chi tiết
            </div>


            <div style="overflow-x:auto;">

                <table class="preview-table">

                    <thead>

                    <tr>

                        <th>Ngày</th>

                        <th>Mã NV</th>

                        <th>Họ và Tên</th>

                        <th>Phòng ban</th>

                        <th>Check in</th>

                        <th>Check out</th>

                        <th>Trạng thái</th>

                        <th>Chỉnh sửa</th>

                    </tr>

                    </thead>


                    <tbody>

                    <c:choose>

                        <c:when test="${not empty sessionScope.previewList}">

                            <c:forEach var="r"
                                       items="${sessionScope.previewList}">

                                <tr>

                                    <td>
                                        ${r.date}
                                    </td>


                                    <td style="
                                        font-weight:600;
                                        color:#1e293b;
                                    ">
                                        ${r.employeeCode}
                                    </td>


                                    <td>
                                        ${r.fullName}
                                    </td>


                                    <td style="color:#64748b;">
                                        ${r.department}
                                    </td>


                                    <td>
                                        ${r.checkIn}
                                    </td>


                                    <td>
                                        ${r.checkOut}
                                    </td>


                                    <!-- TRẠNG THÁI -->

                                    <td>

                                        <!-- CHECK IN -->

                                        <div class="status-row">

                                            <c:choose>

                                                <c:when test="${r.lateMinutes > 0}">

                                                    <span class="badge badge-danger">

                                                        Check-in:
                                                        Muộn
                                                        ${r.lateMinutes}
                                                        phút

                                                    </span>

                                                </c:when>


                                                <c:otherwise>

                                                    <span class="badge badge-success">

                                                        Check-in:
                                                        Đúng giờ

                                                    </span>

                                                </c:otherwise>

                                            </c:choose>

                                        </div>


                                        <!-- CHECK OUT -->

                                        <div class="status-row">

                                            <c:choose>

                                                <c:when test="${r.earlyLeaveMinutes > 0}">

                                                    <span class="badge badge-danger">

                                                        Check-out:
                                                        Sớm
                                                        ${r.earlyLeaveMinutes}
                                                        phút

                                                    </span>

                                                </c:when>


                                                <c:otherwise>

                                                    <span class="badge badge-success">

                                                        Check-out:
                                                        Đúng giờ

                                                    </span>

                                                </c:otherwise>

                                            </c:choose>

                                        </div>

                                    </td>


                                    <!-- EDIT -->

                                    <td>

                                        <button type="button"
                                                class="btn-edit"
                                                onclick="openEditModal(
                                                    '${r.employeeCode}',
                                                    '${r.date}',
                                                    '${r.checkIn}',
                                                    '${r.checkOut}'
                                                )">

                                            ✏ Sửa

                                        </button>

                                    </td>

                                </tr>

                            </c:forEach>

                        </c:when>


                        <c:otherwise>

                            <tr>

                                <td colspan="8"
                                    style="
                                        text-align:center;
                                        padding:40px;
                                        color:#94a3b8;
                                    ">

                                    Không có dữ liệu hiển thị.

                                </td>

                            </tr>

                        </c:otherwise>

                    </c:choose>

                    </tbody>

                </table>

            </div>

        </div>
        <!-- =========================
             PAGINATION
             ========================= -->

        <div class="pagination-container">

            <div class="pagination-info"
                 id="paginationInfo">
                Hiển thị 0 - 0 trong tổng số 0 bản ghi
            </div>

            <div class="pagination-container">

                <div class="pagination-info"
                     id="paginationInfo">
                    Hiển thị 0 - 0 trong tổng số 0 bản ghi
                </div>

                <div class="pagination"
                     id="pagination">
                </div>

            </div>

            <div class="pagination"
                 id="pagination">
            </div>

        </div>


        <!-- =====================================================
             BOTTOM ACTIONS
             ===================================================== -->

        <div class="btn-action-group">


            <!-- CONFIRM -->

            <form action="${pageContext.request.contextPath}/Attendance/confirm"
                  method="post"
                  style="margin:0;">

                <button type="submit"
                        class="btn-primary">

                    ✓ Xác nhận lưu vào hệ thống

                </button>

            </form>


            <!-- EXPORT EXCEL -->

            <button type="button"
                    onclick="openExportModal()"
                    style="
                        display:inline-flex;
                        align-items:center;
                        gap:6px;
                        padding:10px 18px;
                        background:#059669;
                        color:white;
                        border:none;
                        border-radius:8px;
                        font-weight:600;
                        cursor:pointer;
                        font-size:14px;
                    ">

                ↓ Export Excel

            </button>


            <!-- CANCEL -->

            <a href="${pageContext.request.contextPath}/Attendance/upload.jsp"
               class="btn-secondary"
               style="border-color:transparent;">

                Hủy bỏ

            </a>

        </div>


    </div>


    <!-- FOOTER -->

    <footer>

        © 2026 Hệ thống Quản lý Nhân sự (EMS)
        · FPT University SWP391

    </footer>

</div>


<!-- =========================================================
     EDIT ATTENDANCE MODAL
     ========================================================= -->

<div id="editAttendanceModal"
     class="modal-overlay">


    <div class="modal-content">


        <!-- HEADER -->

        <div class="modal-header">

            <h2>
                Sửa chấm công
            </h2>


            <button type="button"
                    class="modal-close"
                    onclick="closeEditModal()">

                &times;

            </button>

        </div>


        <!-- FORM -->

        <form action="${pageContext.request.contextPath}/Attendance/edit"
              method="post"
              onsubmit="return validateCheckOutTime();">


            <input type="hidden"
                   id="originalCode"
                   name="originalCode">


            <input type="hidden"
                   id="originalDate"
                   name="originalDate">


            <!-- NHÂN VIÊN -->

            <div class="edit-form-group">

                <label>
                    Mã nhân viên
                </label>

                <input type="text"
                       id="editEmployeeCode"
                       readonly>

            </div>


            <!-- NGÀY -->

            <div class="edit-form-group">

                <label>
                    Ngày
                </label>

                <input type="date"
                       id="editDate"
                       readonly>

            </div>


            <!-- CHECK IN -->

            <div class="edit-form-group">

                <label>
                    Check in
                </label>

                <input type="time"
                       id="editCheckIn"
                       name="checkIn"
                       step="60">

            </div>


            <!-- CHECK OUT -->

            <div class="edit-form-group">

                <label>
                    Check out
                </label>

                <input type="time"
                       id="editCheckOut"
                       name="checkOut"
                       step="60">

            </div>


            <!-- BUTTONS -->

            <div class="modal-actions">

                <button type="button"
                        class="btn-secondary"
                        onclick="closeEditModal()">

                    Hủy

                </button>


                <button type="submit"
                        class="btn-primary">

                    💾 Lưu thay đổi

                </button>

            </div>

        </form>

    </div>

</div>


<!-- =========================================================
     EXPORT EXCEL MODAL
     ========================================================= -->

<div id="exportModal"
     class="export-modal-overlay">


    <div class="export-modal">


        <!-- HEADER -->

        <div class="export-modal-header">

            <h2>
                Export Excel
            </h2>


            <button type="button"
                    class="export-modal-close"
                    onclick="closeExportModal()">

                &times;

            </button>

        </div>


        <!-- BODY -->

        <div class="export-modal-body">

            <label for="fileName">
                Tên file
            </label>


            <input type="text"
                   id="fileName"
                   value="ChamCong_Preview"
                   placeholder="Nhập tên file">


            <div class="file-extension">

                File sẽ được lưu dưới dạng
                <strong>.xlsx</strong>

            </div>

        </div>


        <!-- FOOTER -->

        <div class="export-modal-footer">

            <button type="button"
                    class="btn-secondary"
                    onclick="closeExportModal()">

                Cancel

            </button>


            <button type="button"
                    class="btn-export"
                    onclick="exportExcel()">

                Export

            </button>

        </div>

    </div>

</div>


<!-- =========================================================
     SUCCESS MESSAGE
     ========================================================= -->

<c:if test="${not empty sessionScope.editSuccess}">

    <div class="alert-success">

        ✓ ${sessionScope.editSuccess}

    </div>


    <c:remove var="editSuccess"
              scope="session"/>

</c:if>


<!-- =========================================================
     JAVASCRIPT
     ========================================================= -->

<script>


    /* =====================================================
       TOPBAR DATE
       ===================================================== */

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



    /* =====================================================
       EDIT MODAL
       ===================================================== */

    function openEditModal(
        employeeCode,
        date,
        checkIn,
        checkOut
    ) {

        document.getElementById("originalCode").value =
            employeeCode || "";


        document.getElementById("originalDate").value =
            date || "";


        document.getElementById("editEmployeeCode").value =
            employeeCode || "";


        document.getElementById("editDate").value =
            date || "";


        document.getElementById("editCheckIn").value =
            formatTimeForInput(checkIn);


        document.getElementById("editCheckOut").value =
            formatTimeForInput(checkOut);


        document
            .getElementById("editAttendanceModal")
            .classList.add("show");


        document.body.style.overflow = "hidden";

    }



    /* =====================================================
       FORMAT TIME
       ===================================================== */

    function formatTimeForInput(time) {

        if (!time) {

            return "";

        }


        return String(time).substring(0, 5);

    }



    /* =====================================================
       CLOSE EDIT MODAL
       ===================================================== */

    function closeEditModal() {

        document
            .getElementById("editAttendanceModal")
            .classList.remove("show");


        document.body.style.overflow = "";

    }



    /* =====================================================
       OPEN EXPORT MODAL
       ===================================================== */

    function openExportModal() {

        var modal =
            document.getElementById("exportModal");

        var input =
            document.getElementById("fileName");


        if (!modal || !input) {

            console.error(
                "Không tìm thấy Export Modal."
            );

            return;

        }


        modal.classList.add("show");


        document.body.style.overflow = "hidden";


        setTimeout(function() {

            input.focus();

            input.select();

        }, 100);

    }



    /* =====================================================
       CLOSE EXPORT MODAL
       ===================================================== */

    function closeExportModal() {

        var modal =
            document.getElementById("exportModal");


        if (!modal) {

            return;

        }


        modal.classList.remove("show");


        document.body.style.overflow = "";

    }



    /* =====================================================
       EXPORT EXCEL
       ===================================================== */

    function exportExcel() {

        var input =
            document.getElementById("fileName");


        if (!input) {

            return;

        }


        var fileName =
            input.value.trim();


        /*
         * Không cho phép tên file rỗng
         */

        if (!fileName) {

            alert("Vui lòng nhập tên file.");

            input.focus();

            return;

        }


        /*
         * Loại bỏ .xlsx nếu người dùng tự nhập
         */

        if (
            fileName
                .toLowerCase()
                .endsWith(".xlsx")
        ) {

            fileName =
                fileName.substring(
                    0,
                    fileName.length - 5
                );

        }


        /*
         * Tạo URL tới ExportServlet
         */

        var url =
            "${pageContext.request.contextPath}/export"
            + "?fileName="
            + encodeURIComponent(fileName);


        /*
         * Đóng modal
         */

        closeExportModal();


        /*
         * Bắt đầu tải file Excel
         */

        window.location.href = url;

    }



    /* =====================================================
       CLICK OUTSIDE EDIT MODAL
       ===================================================== */

    document
        .getElementById("editAttendanceModal")
        .addEventListener(
            "click",
            function(event) {

                if (event.target === this) {

                    closeEditModal();

                }

            }
        );



    /* =====================================================
       CLICK OUTSIDE EXPORT MODAL
       ===================================================== */

    document
        .getElementById("exportModal")
        .addEventListener(
            "click",
            function(event) {

                if (event.target === this) {

                    closeExportModal();

                }

            }
        );



    /* =====================================================
       ESC TO CLOSE
       ===================================================== */

    document.addEventListener(
        "keydown",
        function(event) {

            if (event.key !== "Escape") {

                return;

            }


            var editModal =
                document.getElementById(
                    "editAttendanceModal"
                );


            var exportModal =
                document.getElementById(
                    "exportModal"
                );


            if (
                editModal &&
                editModal.classList.contains("show")
            ) {

                closeEditModal();

            }


            if (
                exportModal &&
                exportModal.classList.contains("show")
            ) {

                closeExportModal();

            }

        }
    );

    // Validate sửa thời gian check in và check out//

    function validateCheckOutTime() {

        var checkIn = document.getElementById("editCheckIn").value;
        var checkOut = document.getElementById("editCheckOut").value;

        // Nếu một trong hai ô trống thì chưa kiểm tra
        if (!checkIn || !checkOut) {
            return true;
        }

        if (checkOut < checkIn) {

            alert("Thời gian Check out không được trước thời gian Check in.");

            document.getElementById("editCheckOut").focus();

            return false;
        }

        return true;
    }


</script>
<script>

    /* =========================
       PAGINATION
       ========================= */

    var currentPage = 1;
    var pageSize = 8;

    function getAttendanceRows() {

        var table = document.querySelector(".preview-table");

        if (!table) {
            return [];
        }

        var tbody = table.querySelector("tbody");

        if (!tbody) {
            return [];
        }

        return Array.from(
            tbody.querySelectorAll("tr")
        ).filter(function(row) {

            /*
             * Không tính dòng "Không có dữ liệu"
             */

            return !row.querySelector("td[colspan]");

        });

    }


    function renderPagination() {

        var rows = getAttendanceRows();

        var totalRows = rows.length;

        var totalPages =
            Math.ceil(totalRows / pageSize);


        /*
         * Nếu không có dữ liệu
         */

        if (totalRows === 0) {

            document.getElementById("paginationInfo")
                .textContent =
                "Không có dữ liệu";

            document.getElementById("pagination")
                .innerHTML = "";

            return;
        }


        /*
         * Nếu currentPage vượt quá tổng số trang
         */

        if (currentPage > totalPages) {
            currentPage = totalPages;
        }


        /*
         * Xác định dòng bắt đầu
         */

        var start =
            (currentPage - 1) * pageSize;


        /*
         * Xác định dòng kết thúc
         */

        var end =
            Math.min(
                start + pageSize,
                totalRows
            );


        /*
         * Ẩn tất cả dòng
         */

        rows.forEach(function(row) {

            row.style.display = "none";

        });


        /*
         * Hiển thị dòng của trang hiện tại
         */

        for (var i = start; i < end; i++) {

            rows[i].style.display = "";

        }


        /*
         * Thông tin:
         *
         * Hiển thị 1 - 20 trong tổng số 127 bản ghi
         */

        document.getElementById("paginationInfo")
            .textContent =
            "Hiển thị " +
            (start + 1) +
            " - " +
            end +
            " trong tổng số " +
            totalRows +
            " bản ghi";


        renderPaginationButtons(totalPages);

    }


    function renderPaginationButtons(totalPages) {

        var pagination =
            document.getElementById("pagination");


        pagination.innerHTML = "";


        /*
         * Nút Previous
         */

        var previous =
            document.createElement("button");

        previous.type = "button";

        previous.innerHTML = "‹";

        previous.title = "Trang trước";

        previous.disabled =
            currentPage === 1;

        previous.onclick = function() {

            if (currentPage > 1) {

                currentPage--;

                renderPagination();

            }

        };

        pagination.appendChild(previous);


        /*
         * Xác định các trang cần hiển thị
         */

        var pages = getPageNumbers(totalPages);


        pages.forEach(function(page) {

            /*
             * Dấu ...
             */

            if (page === "...") {

                var dots =
                    document.createElement("span");

                dots.textContent = "...";

                dots.style.padding =
                    "0 5px";

                dots.style.color =
                    "#94a3b8";

                pagination.appendChild(dots);

                return;
            }


            /*
             * Nút số trang
             */

            var button =
                document.createElement("button");

            button.type = "button";

            button.textContent = page;


            if (page === currentPage) {

                button.classList.add("active");

            }


            button.onclick = function() {

                currentPage = page;

                renderPagination();

            };


            pagination.appendChild(button);

        });


        /*
         * Nút Next
         */

        var next =
            document.createElement("button");

        next.type = "button";

        next.innerHTML = "›";

        next.title = "Trang sau";

        next.disabled =
            currentPage === totalPages;

        next.onclick = function() {

            if (currentPage < totalPages) {

                currentPage++;

                renderPagination();

            }

        };

        pagination.appendChild(next);

    }


    /*
     * Tạo danh sách số trang
     *
     * Ví dụ:
     *
     * 1 2 3 4 5
     *
     * hoặc:
     *
     * 1 2 3 ... 10
     */

    function getPageNumbers(totalPages) {

        var pages = [];


        /*
         * Nếu <= 7 trang
         * hiển thị toàn bộ
         */

        if (totalPages <= 7) {

            for (
                var i = 1;
                i <= totalPages;
                i++
            ) {

                pages.push(i);

            }

            return pages;
        }


        /*
         * Đang ở những trang đầu
         */

        if (currentPage <= 4) {

            pages = [
                1,
                2,
                3,
                4,
                5,
                "...",
                totalPages
            ];

            return pages;
        }


        /*
         * Đang ở những trang cuối
         */

        if (currentPage >= totalPages - 3) {

            pages = [
                1,
                "...",
                totalPages - 4,
                totalPages - 3,
                totalPages - 2,
                totalPages - 1,
                totalPages
            ];

            return pages;
        }


        /*
         * Đang ở giữa
         */

        pages = [
            1,
            "...",
            currentPage - 1,
            currentPage,
            currentPage + 1,
            "...",
            totalPages
        ];

        return pages;

    }


    /*
     * Khởi tạo pagination
     */

    document.addEventListener(
        "DOMContentLoaded",
        function() {

            renderPagination();

        }
    );

</script>


</body>

</html>