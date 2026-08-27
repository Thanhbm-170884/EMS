<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.ems.dto.RequestDTO" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    List<RequestDTO> requests =
            (List<RequestDTO>) request.getAttribute("requests");

    if (requests == null) {
        response.sendRedirect(
                request.getContextPath() + "/requests?action=myRequests"
        );
        return;
    }

    SimpleDateFormat dateFormat =
            new SimpleDateFormat("dd/MM/yyyy HH:mm");

    String username = (String) session.getAttribute("username");

    Integer totalFilteredItems =
            (Integer) request.getAttribute("totalFilteredItems");

    if (totalFilteredItems == null) {
        totalFilteredItems = requests.size();
    }

    Integer currentPage =
            (Integer) request.getAttribute("currentPage");

    if (currentPage == null || currentPage < 1) {
        currentPage = 1;
    }

    Integer pageSize =
            (Integer) request.getAttribute("pageSize");

    if (pageSize == null || pageSize < 1) {
        pageSize = 5;
    }

    Integer totalPages =
            (Integer) request.getAttribute("totalPages");

    if (totalPages == null || totalPages < 1) {
        totalPages = 1;
    }

    int startItem = totalFilteredItems > 0
            ? (currentPage - 1) * pageSize + 1
            : 0;

    int endItem = Math.min(
            currentPage * pageSize,
            totalFilteredItems
    );
%>

<%!
    private String buildPageUrl(
            String contextPath,
            int page,
            int pageSize) {

        return contextPath
                + "/requests?action=myRequests"
                + "&page=" + page
                + "&pageSize=" + pageSize;
    }

    private String escapeAttr(String str) {

        if (str == null) {
            return "";
        }

        return str
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }

    private String escapeHtml(String str) {

        if (str == null) {
            return "";
        }

        return str
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }

    private String formatValue(double val, int typeId) {

        // typeId = 3: ứng lương / tiền
        if (typeId == 3) {
            return java.text.NumberFormat
                    .getIntegerInstance(
                            new java.util.Locale("vi", "VN"))
                    .format(val)
                    + " đ";
        }

        if (val == (long) val) {
            return String.valueOf((long) val);
        }

        return String.valueOf(val);
    }
%>

<!DOCTYPE html>
<html lang="vi">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>EMS - Yêu cầu của tôi</title>

    <link rel="stylesheet"
          href="<%= request.getContextPath() %>/css/ems.css">

    <style>

        /* ================================
           ACTIONS
           ================================ */

        .request-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            margin-bottom: 20px;
        }

        .btn-create {
            display: inline-block;
            padding: 9px 16px;
            border-radius: 7px;
            background: #2563eb;
            color: #fff;
            text-decoration: none;
            font-size: 13px;
            font-weight: 600;
        }

        .btn-create:hover {
            background: #1d4ed8;
        }

        /* ================================
           REQUEST
           ================================ */

        .request-title {
            color: #111827;
            font-weight: 600;
        }

        .request-reason {
            max-width: 260px;
            color: #6b7280;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        /* ================================
           EMPTY
           ================================ */

        .empty-state {
            padding: 48px 20px;
            text-align: center;
            color: #6b7280;
        }

        .empty-state p {
            margin: 8px 0 18px;
        }

        /* ================================
           DELETE
           ================================ */

        .delete-form {
            display: inline;
        }

        .btn-delete {
            border: 0;
            background: transparent;
            color: #dc2626;
            font: inherit;
            font-size: 12px;
            cursor: pointer;
        }

        .btn-delete:hover {
            text-decoration: underline;
        }

        /* ================================
           VIEW
           ================================ */

        .btn-view {
            border: 0;
            background: transparent;
            color: #2563eb;
            font: inherit;
            font-size: 12px;
            cursor: pointer;
            text-decoration: none;
            margin-right: 8px;
        }

        .btn-view:hover {
            text-decoration: underline;
        }

        /* ================================
           PAGINATION
           ================================ */

        .hol-pagination {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 12px 20px;
            border-top: 1px solid #e5e7eb;
            flex-wrap: wrap;
            gap: 10px;
        }

        .hol-page-info {
            font-size: 0.84rem;
            color: #6b7280;
        }

        .hol-page-btns {
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .hol-page-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 34px;
            height: 32px;
            padding: 0 10px;
            border: 1px solid #d1d5db;
            border-radius: 6px;
            background: #fff;
            color: #374151;
            text-decoration: none;
            font-size: 13px;
        }

        .hol-page-btn:hover {
            background: #f3f4f6;
        }

        .hol-page-btn.active {
            background: #2563eb;
            border-color: #2563eb;
            color: #fff;
        }

        .hol-page-btn.disabled {
            opacity: 0.5;
            pointer-events: none;
            cursor: default;
        }

        .hol-page-ellipsis {
            color: #6b7280;
            padding: 0 4px;
        }

        /* ================================
           RESPONSIVE
           ================================ */

        @media (max-width: 800px) {

            .sidebar {
                position: static;
                width: 100%;
                min-height: auto;
            }

            body {
                display: block;
            }

            .main-content {
                margin-left: 0;
            }

            .table-wrap {
                overflow-x: auto;
            }

            th,
            td {
                white-space: nowrap;
            }

            .request-actions {
                align-items: flex-start;
                flex-direction: column;
            }

            .hol-pagination {
                flex-direction: column;
                align-items: flex-start;
            }

        }

    </style>

</head>

<body>

<%@include file="/WEB-INF/jspf/sidebar.jsp" %>

<main class="main-content">

    <!-- ================================
         TOPBAR
         ================================ -->

    <div class="topbar">

        <span class="topbar-left">
            Yêu cầu của tôi
        </span>

        <span class="topbar-right"
              id="topbar-date">
        </span>

    </div>

    <!-- ================================
         PAGE BODY
         ================================ -->

    <div class="page-body">

        <div class="request-actions">

            <div class="page-header">

                <h1>
                    Danh sách yêu cầu
                </h1>

                <p>
                    Theo dõi trạng thái các yêu cầu bạn đã gửi.
                </p>

            </div>

            <a class="btn-create"
               href="<%= request.getContextPath() %>/requests?action=showForm">
                + Tạo yêu cầu
            </a>

        </div>

        <!-- ================================
             CARD
             ================================ -->

        <section class="card">

            <div class="card-header">

                <span>
                    Tất cả yêu cầu
                </span>

                <span class="badge badge-active">
                    <%= totalFilteredItems %> yêu cầu
                </span>

            </div>

            <!-- ================================
                 EMPTY
                 ================================ -->

            <% if (requests.isEmpty()) { %>

                <div class="empty-state">

                    <strong>
                        Bạn chưa gửi yêu cầu nào.
                    </strong>

                    <p>
                        Tạo yêu cầu mới để bắt đầu.
                    </p>

                    <a class="btn-create"
                       href="<%= request.getContextPath() %>/requests?action=showForm">
                        Tạo yêu cầu
                    </a>

                </div>

            <% } else { %>

                <!-- ================================
                     TABLE
                     ================================ -->

                <div class="table-wrap">

                    <table>

                        <thead>

                            <tr>

                                <th>
                                    Tiêu đề
                                </th>

                                <th>
                                    Loại
                                </th>

                                <th>
                                    Giá trị
                                </th>

                                <th>
                                    Người duyệt
                                </th>

                                <th>
                                    Trạng thái
                                </th>

                                <th>
                                </th>

                            </tr>

                        </thead>

                        <tbody>

                        <% for (RequestDTO item : requests) { %>

                            <%
                                String status =
                                        item.getStatus() == null
                                                ? ""
                                                : item.getStatus();

                                String badgeClass =
                                        "badge-pending";

                                if ("Approved".equalsIgnoreCase(status)) {

                                    badgeClass =
                                            "badge-approved";

                                } else if ("Rejected".equalsIgnoreCase(status)) {

                                    badgeClass =
                                            "badge-rejected";
                                }

                                String startDateStr =
                                        item.getStartDate() != null
                                                ? dateFormat.format(item.getStartDate())
                                                : "-";

                                String endDateStr =
                                        item.getEndDate() != null
                                                ? dateFormat.format(item.getEndDate())
                                                : "-";

                                String createdAtStr =
                                        item.getCreatedAt() != null
                                                ? dateFormat.format(item.getCreatedAt())
                                                : "-";

                                String approverStr =
                                        item.getCurrentApproverName() != null
                                                && !item.getCurrentApproverName().isBlank()
                                                ? item.getCurrentApproverName()
                                                : "Chưa phân công";

                                String statusLabel;

                                if ("Approved".equalsIgnoreCase(status)) {

                                    statusLabel = "Đã duyệt";

                                } else if ("Rejected".equalsIgnoreCase(status)) {

                                    statusLabel = "Từ chối";

                                } else {

                                    statusLabel = "Chờ duyệt";
                                }

                                String formattedValue =
                                        formatValue(
                                                item.getValue(),
                                                item.getRequestTypeId()
                                        );
                            %>

                            <tr
                                style="cursor: pointer;"

                                onclick="showRequestDetail(this)"

                                data-id="<%= item.getId() %>"

                                data-title="<%= escapeAttr(item.getTitle()) %>"

                                data-type="<%= escapeAttr(item.getRequestTypeName()) %>"

                                data-start-date="<%= escapeAttr(startDateStr) %>"

                                data-end-date="<%= escapeAttr(endDateStr) %>"

                                data-value="<%= escapeAttr(formattedValue) %>"

                                data-approver="<%= escapeAttr(approverStr) %>"

                                data-status="<%= escapeAttr(statusLabel) %>"

                                data-status-class="<%= badgeClass %>"

                                data-reason="<%= escapeAttr(item.getReason()) %>"

                                data-rejection-reason="<%= escapeAttr(item.getRejectionReason()) %>"

                                data-image-url="<%= escapeAttr(item.getImageUrl()) %>"

                                data-created-at="<%= escapeAttr(createdAtStr) %>"
                            >

                                <!-- TITLE -->

                                <td>

                                    <div class="request-title">

                                        <%= escapeHtml(item.getTitle()) %>

                                    </div>

                                </td>

                                <!-- TYPE -->

                                <td>

                                    <%= escapeHtml(item.getRequestTypeName()) %>

                                </td>

                                <!-- VALUE -->

                                <td>

                                    <%= formattedValue %>

                                </td>

                                <!-- APPROVER -->

                                <td>

                                    <%= escapeHtml(approverStr) %>

                                </td>

                                <!-- STATUS -->

                                <td>

                                    <span class="badge <%= badgeClass %>">

                                        <%= statusLabel %>

                                    </span>

                                    <% if (
                                            "Rejected".equalsIgnoreCase(status)
                                            && item.getRejectionReason() != null
                                            && !item.getRejectionReason().isBlank()
                                    ) { %>

                                        <div
                                            style="font-size:11px;
                                                   color:#dc2626;
                                                   margin-top:4px;"
                                            title="<%= escapeAttr(item.getRejectionReason()) %>"
                                        >

                                            Lý do:
                                            <%= escapeHtml(item.getRejectionReason()) %>

                                        </div>

                                    <% } %>

                                </td>

                                <!-- ACTION -->

                                <td
                                    onclick="event.stopPropagation();"
                                >

                                    <a
                                        href="javascript:void(0)"
                                        class="btn-view"
                                        onclick="showRequestDetail(this.closest('tr'))"
                                    >
                                        Xem
                                    </a>

                                    <% if ("Pending".equalsIgnoreCase(status)) { %>

                                        <form
                                            class="delete-form"
                                            method="post"
                                            action="<%= request.getContextPath() %>/requests"
                                            onsubmit="return confirm('Bạn có muốn hủy yêu cầu này?');"
                                        >

                                            <input
                                                type="hidden"
                                                name="action"
                                                value="delete"
                                            >

                                            <input
                                                type="hidden"
                                                name="id"
                                                value="<%= item.getId() %>"
                                            >

                                            <button
                                                class="btn-delete"
                                                type="submit"
                                            >
                                                Hủy
                                            </button>

                                        </form>

                                    <% } %>

                                </td>

                            </tr>

                        <% } %>

                        </tbody>

                    </table>

                </div>

                <!-- ================================
                     PAGINATION
                     ================================ -->

                <% if (totalPages > 1) {

                    int winStart =
                            Math.max(
                                    2,
                                    currentPage - 2
                            );

                    int winEnd =
                            Math.min(
                                    totalPages - 1,
                                    currentPage + 2
                            );

                    boolean isFirstPage =
                            currentPage <= 1;

                    boolean isLastPage =
                            currentPage >= totalPages;
                %>

                    <div class="hol-pagination">

                        <!-- PAGE INFO -->

                        <div class="hol-page-info">

                            <span>

                                Hiển thị

                                <strong>
                                    <%= startItem %>-<%= endItem %>
                                </strong>

                                /

                                <%= totalFilteredItems %>

                                yêu cầu

                            </span>

                        </div>

                        <!-- PAGE BUTTONS -->

                        <div class="hol-page-btns">

                            <!-- PREVIOUS -->

                            <% if (isFirstPage) { %>

                                <span class="hol-page-btn disabled">
                                    &lt; Trước
                                </span>

                            <% } else { %>

                                <a
                                    class="hol-page-btn"
                                    href="<%= buildPageUrl(
                                            request.getContextPath(),
                                            currentPage - 1,
                                            pageSize
                                    ) %>"
                                >
                                    &lt; Trước
                                </a>

                            <% } %>


                            <!-- PAGE 1 -->

                            <a
                                class="hol-page-btn <%= currentPage == 1 ? "active" : "" %>"
                                href="<%= buildPageUrl(
                                        request.getContextPath(),
                                        1,
                                        pageSize
                                ) %>"
                            >
                                1
                            </a>


                            <!-- LEFT ELLIPSIS -->

                            <% if (currentPage > 4) { %>

                                <span class="hol-page-ellipsis">
                                    &hellip;
                                </span>

                            <% } %>


                            <!-- MIDDLE PAGES -->

                            <% for (
                                    int p = winStart;
                                    p <= winEnd;
                                    p++
                            ) { %>

                                <a
                                    class="hol-page-btn <%= p == currentPage ? "active" : "" %>"
                                    href="<%= buildPageUrl(
                                            request.getContextPath(),
                                            p,
                                            pageSize
                                    ) %>"
                                >
                                    <%= p %>
                                </a>

                            <% } %>


                            <!-- RIGHT ELLIPSIS -->

                            <% if (currentPage < totalPages - 3) { %>

                                <span class="hol-page-ellipsis">
                                    &hellip;
                                </span>

                            <% } %>


                            <!-- LAST PAGE -->

                            <% if (totalPages > 1) { %>

                                <a
                                    class="hol-page-btn <%= currentPage == totalPages ? "active" : "" %>"
                                    href="<%= buildPageUrl(
                                            request.getContextPath(),
                                            totalPages,
                                            pageSize
                                    ) %>"
                                >
                                    <%= totalPages %>
                                </a>

                            <% } %>


                            <!-- NEXT -->

                            <% if (isLastPage) { %>

                                <span class="hol-page-btn disabled">
                                    Tiếp &gt;
                                </span>

                            <% } else { %>

                                <a
                                    class="hol-page-btn"
                                    href="<%= buildPageUrl(
                                            request.getContextPath(),
                                            currentPage + 1,
                                            pageSize
                                    ) %>"
                                >
                                    Tiếp &gt;
                                </a>

                            <% } %>

                        </div>

                    </div>

                <% } %>

            <% } %>

        </section>

    </div>

    <footer>
        © 2026 Hệ thống Quản lý Nhân sự (EMS) · FPT University SWP391
    </footer>

</main>


<!-- =====================================================
     MODAL CHI TIẾT
     ===================================================== -->

<div
    class="modal-overlay"
    id="requestDetailModal"
    style="display: none;"
>

    <div
        class="modal"
        style="
            max-width: 600px;
            display: flex;
            flex-direction: column;
        "
    >

        <!-- MODAL HEADER -->

        <div class="modal-header">

            <div class="modal-header-left">

                <div
                    class="modal-header-icon"
                    style="
                        display:flex;
                        align-items:center;
                        justify-content:center;
                    "
                >

                    <svg
                        width="20"
                        height="20"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="2"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                    >

                        <path
                            d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"
                        />

                        <polyline
                            points="14 2 14 8 20 8"
                        />

                        <line
                            x1="16"
                            y1="13"
                            x2="8"
                            y2="13"
                        />

                        <line
                            x1="16"
                            y1="17"
                            x2="8"
                            y2="17"
                        />

                        <polyline
                            points="10 9 9 9 8 9"
                        />

                    </svg>

                </div>

                <div>

                    <div class="modal-title">
                        Chi tiết yêu cầu
                    </div>

                    <div
                        class="modal-subtitle"
                        id="detailModalSubtitle"
                    >
                        Mã đơn và thông tin gửi
                    </div>

                </div>

            </div>

            <button
                class="modal-close"
                type="button"
                onclick="closeDetailModal()"
            >
                ✕
            </button>

        </div>


        <!-- MODAL BODY -->

        <div
            class="modal-body"
            style="
                padding:20px;
                overflow-y:auto;
            "
        >

            <table
                style="
                    width:100%;
                    border-collapse:collapse;
                "
            >

                <!-- TITLE -->

                <tr style="border-bottom:1px solid #f1f5f9;">

                    <td class="detail-label">
                        Tiêu đề:
                    </td>

                    <td
                        style="
                            padding:10px 0;
                            color:#1e293b;
                        "
                        id="detTitle"
                    >
                        -
                    </td>

                </tr>


                <!-- TYPE -->

                <tr style="border-bottom:1px solid #f1f5f9;">

                    <td class="detail-label">
                        Loại đơn:
                    </td>

                    <td
                        style="
                            padding:10px 0;
                            color:#1e293b;
                        "
                        id="detType"
                    >
                        -
                    </td>

                </tr>


                <!-- START DATE -->

                <tr
                    id="detStartDateRow"
                    style="
                        border-bottom:1px solid #f1f5f9;
                        display:none;
                    "
                >

                    <td class="detail-label">
                        Từ ngày:
                    </td>

                    <td
                        style="
                            padding:10px 0;
                            color:#1e293b;
                        "
                        id="detStartDate"
                    >
                        -
                    </td>

                </tr>


                <!-- END DATE -->

                <tr
                    id="detEndDateRow"
                    style="
                        border-bottom:1px solid #f1f5f9;
                        display:none;
                    "
                >

                    <td class="detail-label">
                        Đến ngày:
                    </td>

                    <td
                        style="
                            padding:10px 0;
                            color:#1e293b;
                        "
                        id="detEndDate"
                    >
                        -
                    </td>

                </tr>


                <!-- VALUE -->

                <tr style="border-bottom:1px solid #f1f5f9;">

                    <td class="detail-label">
                        Giá trị / Số ngày:
                    </td>

                    <td
                        style="
                            padding:10px 0;
                            color:#1e293b;
                        "
                        id="detValue"
                    >
                        -
                    </td>

                </tr>


                <!-- STATUS -->

                <tr style="border-bottom:1px solid #f1f5f9;">

                    <td class="detail-label">
                        Trạng thái:
                    </td>

                    <td
                        style="
                            padding:10px 0;
                        "
                        id="detStatusContainer"
                    >

                        <span
                            class="badge"
                            id="detStatus"
                        >
                            -
                        </span>

                    </td>

                </tr>


                <!-- APPROVER -->

                <tr style="border-bottom:1px solid #f1f5f9;">

                    <td class="detail-label">
                        Người phê duyệt:
                    </td>

                    <td
                        style="
                            padding:10px 0;
                            color:#1e293b;
                        "
                        id="detApprover"
                    >
                        -
                    </td>

                </tr>


                <!-- CREATED -->

                <tr style="border-bottom:1px solid #f1f5f9;">

                    <td class="detail-label">
                        Ngày tạo:
                    </td>

                    <td
                        style="
                            padding:10px 0;
                            color:#1e293b;
                        "
                        id="detCreatedAt"
                    >
                        -
                    </td>

                </tr>


                <!-- REASON -->

                <tr style="border-bottom:1px solid #f1f5f9;">

                    <td
                        style="
                            padding:10px 0;
                            font-weight:600;
                            color:#475569;
                            vertical-align:top;
                            width:150px;
                        "
                    >
                        Lý do / Nội dung:
                    </td>

                    <td
                        style="
                            padding:10px 0;
                            color:#1e293b;
                            white-space:pre-wrap;
                        "
                        id="detReason"
                    >
                        -
                    </td>

                </tr>


                <!-- REJECTION REASON -->

                <tr
                    id="detRejectionReasonRow"
                    style="
                        border-bottom:1px solid #f1f5f9;
                        display:none;
                    "
                >

                    <td
                        style="
                            padding:10px 0;
                            font-weight:600;
                            color:#dc2626;
                            vertical-align:top;
                        "
                    >
                        Lý do từ chối:
                    </td>

                    <td
                        style="
                            padding:10px 0;
                            color:#dc2626;
                            white-space:pre-wrap;
                        "
                        id="detRejectionReason"
                    >
                        -
                    </td>

                </tr>


                <!-- IMAGE -->

                <tr
                    id="detImageRow"
                    style="
                        border-bottom:1px solid #f1f5f9;
                        display:none;
                    "
                >

                    <td
                        style="
                            padding:10px 0;
                            font-weight:600;
                            color:#475569;
                            vertical-align:top;
                        "
                    >
                        Minh chứng:
                    </td>

                    <td
                        style="
                            padding:10px 0;
                            color:#1e293b;
                        "
                    >

                        <a
                            id="detImageLink"
                            href="#"
                            target="_blank"
                            style="
                                color:#2563eb;
                                text-decoration:underline;
                                display:block;
                                margin-bottom:5px;
                            "
                        >
                            Xem ảnh gốc
                        </a>

                        <img
                            id="detImagePreview"
                            src=""
                            alt="Minh chứng"
                            style="
                                max-width:100%;
                                max-height:200px;
                                border-radius:8px;
                                border:1px solid #e2e8f0;
                                display:block;
                                margin-top:5px;
                            "
                        >

                    </td>

                </tr>

            </table>

        </div>


        <!-- MODAL FOOTER -->

        <div class="modal-footer">

            <button
                type="button"
                class="btn btn-secondary"
                onclick="closeDetailModal()"
            >
                Đóng
            </button>

        </div>

    </div>

</div>


<script>

    /* =====================================================
       TOPBAR DATE
       ===================================================== */

    (function () {

        var now = new Date();

        function pad(n) {
            return String(n).padStart(2, '0');
        }

        var topbarDate =
            document.getElementById('topbar-date');

        if (topbarDate) {

            topbarDate.textContent =
                pad(now.getDate())
                + '/'
                + pad(now.getMonth() + 1)
                + '/'
                + now.getFullYear();
        }

    })();


    /* =====================================================
       SHOW DETAIL
       ===================================================== */

    function showRequestDetail(row) {

        if (!row) {
            return;
        }

        var id =
            row.getAttribute('data-id');

        var title =
            row.getAttribute('data-title') || '';

        var type =
            row.getAttribute('data-type') || '';

        var startDate =
            row.getAttribute('data-start-date') || '';

        var endDate =
            row.getAttribute('data-end-date') || '';

        var value =
            row.getAttribute('data-value') || '';

        var approver =
            row.getAttribute('data-approver') || '';

        var status =
            row.getAttribute('data-status') || '';

        var statusClass =
            row.getAttribute('data-status-class')
            || 'badge-pending';

        var reason =
            row.getAttribute('data-reason') || '';

        var rejectionReason =
            row.getAttribute('data-rejection-reason') || '';

        var imageUrl =
            row.getAttribute('data-image-url') || '';

        var createdAt =
            row.getAttribute('data-created-at') || '';


        /* ================================
           BASIC INFO
           ================================ */

        document.getElementById(
            'detailModalSubtitle'
        ).textContent =
            'Gửi lúc ' + createdAt;

        document.getElementById(
            'detTitle'
        ).textContent = title;

        document.getElementById(
            'detType'
        ).textContent = type;


        /* ================================
           START DATE
           ================================ */

        var startRow =
            document.getElementById(
                'detStartDateRow'
            );

        if (
            startDate
            && startDate !== '-'
            && startDate.trim() !== ''
        ) {

            startRow.style.display = '';

            document.getElementById(
                'detStartDate'
            ).textContent = startDate;

        } else {

            startRow.style.display = 'none';
        }


        /* ================================
           END DATE
           ================================ */

        var endRow =
            document.getElementById(
                'detEndDateRow'
            );

        if (
            endDate
            && endDate !== '-'
            && endDate.trim() !== ''
        ) {

            endRow.style.display = '';

            document.getElementById(
                'detEndDate'
            ).textContent = endDate;

        } else {

            endRow.style.display = 'none';
        }


        /* ================================
           VALUE
           ================================ */

        document.getElementById(
            'detValue'
        ).textContent = value;


        /* ================================
           STATUS
           ================================ */

        var statusBadge =
            document.getElementById(
                'detStatus'
            );

        statusBadge.className =
            'badge ' + statusClass;

        statusBadge.textContent =
            status;


        /* ================================
           APPROVER
           ================================ */

        document.getElementById(
            'detApprover'
        ).textContent =
            approver;


        /* ================================
           CREATED AT
           ================================ */

        document.getElementById(
            'detCreatedAt'
        ).textContent =
            createdAt;


        /* ================================
           REASON
           ================================ */

        document.getElementById(
            'detReason'
        ).textContent =
            reason
                ? reason
                : 'Không có nội dung';


        /* ================================
           REJECTION REASON
           ================================ */

        var rejectionRow =
            document.getElementById(
                'detRejectionReasonRow'
            );

        if (
            rejectionReason
            && rejectionReason.trim() !== ''
        ) {

            rejectionRow.style.display = '';

            document.getElementById(
                'detRejectionReason'
            ).textContent =
                rejectionReason;

        } else {

            rejectionRow.style.display =
                'none';
        }


        /* ================================
           IMAGE
           ================================ */

        var imageRow =
            document.getElementById(
                'detImageRow'
            );

        var imageLink =
            document.getElementById(
                'detImageLink'
            );

        var imagePreview =
            document.getElementById(
                'detImagePreview'
            );

        if (
            imageUrl
            && imageUrl.trim() !== ''
        ) {

            imageRow.style.display = '';

            imageLink.href = imageUrl;

            imagePreview.src = imageUrl;

        } else {

            imageRow.style.display =
                'none';

            imageLink.href = '#';

            imagePreview.src = '';
        }


        /* ================================
           OPEN MODAL
           ================================ */

        var modal =
            document.getElementById(
                'requestDetailModal'
            );

        modal.style.display = 'flex';

        modal.classList.add('open');

        document.body.style.overflow =
            'hidden';
    }


    /* =====================================================
       CLOSE MODAL
       ===================================================== */

    function closeDetailModal() {

        var modal =
            document.getElementById(
                'requestDetailModal'
            );

        modal.style.display = 'none';

        modal.classList.remove('open');

        document.body.style.overflow = '';

    }


    /* =====================================================
       CLICK OUTSIDE MODAL
       ===================================================== */

    window.addEventListener(
        'click',
        function (event) {

            var modal =
                document.getElementById(
                    'requestDetailModal'
                );

            if (event.target === modal) {

                closeDetailModal();

            }

        }
    );


    /* =====================================================
       ESC CLOSE
       ===================================================== */

    document.addEventListener(
        'keydown',
        function (event) {

            if (event.key === 'Escape') {

                closeDetailModal();

            }

        }
    );

</script>

</body>

</html>