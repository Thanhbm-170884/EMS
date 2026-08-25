<%@ page pageEncoding="UTF-8" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.util.List" %>
<%@ page import="com.ems.dto.RequestDTO" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    List<RequestDTO> requests = (List<RequestDTO>) request.getAttribute("requests");
    if (requests == null) {
        response.sendRedirect(request.getContextPath() + "/requests?action=pending");
        return;
    }
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    String tab = (String) request.getAttribute("tab");
    if (tab == null) tab = "Pending";
    String searchName = (String) request.getAttribute("searchName");
    if (searchName == null) searchName = "";
    String filterType = (String) request.getAttribute("filterType");
    if (filterType == null) filterType = "";
    java.util.Set<String> allRequestTypes = (java.util.Set<String>) request.getAttribute("allRequestTypes");
    RequestDTO selectedRequest = (RequestDTO) request.getAttribute("selectedRequest");
    String username = (String) session.getAttribute("username");

    // Pre-encode URL parameters in Java to avoid quote issues inside HTML onclick attributes
    String searchNameEnc = java.net.URLEncoder.encode(searchName, "UTF-8");
    String filterTypeEnc = java.net.URLEncoder.encode(filterType, "UTF-8");
%>
<%!

    private String formatValue(double val, int typeId) {
        if (typeId == 3) {
            return java.text.NumberFormat.getIntegerInstance(new java.util.Locale("vi", "VN")).format(val) + " đ";
        }
        if (val == (long) val) {
            return String.format("%d", (long) val);
        } else {
            return String.format("%s", val);
        }
    }

    private String escapeAttr(String str) {
        if (str == null) return "";
        return str.replace("&", "&amp;")
                  .replace("<", "&lt;")
                  .replace(">", "&gt;")
                  .replace("\"", "&quot;")
                  .replace("'", "&#x27;");
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EMS - Xử lý đơn</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/ems.css">
    <style>
        .request-name { color: #111827; font-weight: 600; }
        .request-reason { max-width: 280px; color: #6b7280; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .request-actions { display: flex; gap: 8px; justify-content: flex-end; }
        .decision-form { display: inline; }
        .btn-decision { border: 0; border-radius: 6px; padding: 7px 11px; color: #fff; font: inherit; font-size: 12px; font-weight: 600; cursor: pointer; }
        .btn-approve { background: #059669; } .btn-approve:hover { background: #047857; }
        .btn-reject { background: #dc2626; } .btn-reject:hover { background: #b91c1c; }
        .empty-state { padding: 48px 20px; text-align: center; color: #6b7280; }
        .request-image { display: inline-block; margin-top: 5px; color: #2563eb; font-size: 12px; }
        .tab-btn { border: 1px solid #d1d5db; background: #fff; color: #374151; padding: 6px 12px; font-size: 13px; font-weight: 600; border-radius: 6px; cursor: pointer; transition: all 0.2s; }
        .tab-btn:hover { background: #f3f4f6; }
        .tab-btn.active { background: #2563eb; color: #fff; border-color: #2563eb; }
        .card-header-flex { display: flex; justify-content: space-between; align-items: center; width: 100%; }
        .filter-bar { display: flex; gap: 8px; padding: 10px 0 4px 0; flex-wrap: wrap; }
        .filter-bar input, .filter-bar select { padding: 6px 12px; border: 1px solid #d1d5db; border-radius: 6px; font-size: 13px; outline: none; color: #374151; background: #fff; }
        .filter-bar input { width: 220px; }
        .filter-bar select { cursor: pointer; }
        @media (max-width: 800px) { .sidebar { position: static; width: 100%; min-height: auto; } body { display: block; } .main-content { margin-left: 0; } .table-wrap { overflow-x: auto; } th, td { white-space: nowrap; } }
        
        /* Pagination CSS */
        .page-nav-btn, .page-num-btn {
            padding: 6px 12px;
            border: 1px solid #e5e7eb;
            border-radius: 6px;
            background: #ffffff;
            color: #374151;
            font-size: 13px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.15s ease;
            text-decoration: none;
            display: inline-block;
            line-height: 1.2;
        }
        .page-nav-btn:hover:not(.disabled), .page-num-btn:hover:not(.active) {
            background: #f3f4f6;
            border-color: #d1d5db;
        }
        .page-nav-btn.disabled {
            opacity: 0.4;
            cursor: not-allowed;
            pointer-events: none;
        }
        .page-num-btn.active {
            background: #2563eb;
            color: #ffffff;
            border-color: #2563eb;
            font-weight: 600;
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
<main class="main-content">
    <div class="topbar"><span class="topbar-left">Xử lý đơn</span><span class="topbar-right" id="topbar-date"></span></div>
    <div class="page-body">
        <div class="page-header"><h1>Quản lý yêu cầu</h1><p>Xem danh sách và phê duyệt hoặc từ chối các yêu cầu của nhân viên.</p></div>
        <section class="card">
            <div class="card-header card-header-flex">
                <div>
                    <span>Danh sách đơn yêu cầu</span>
                    <span class="badge badge-active" id="requestCountBadge"><%= requests.size() %> đơn</span>
                </div>
                <div style="display: flex; gap: 8px;">
                    <button type="button" class="tab-btn <%= "Pending".equals(tab) ? "active" : "" %>" onclick="submitTab('Pending')">Chờ duyệt</button>
                    <button type="button" class="tab-btn <%= "History".equals(tab) ? "active" : "" %>" onclick="submitTab('History')">Lịch sử</button>
                </div>
            </div>
            
            <form method="get" action="<%= request.getContextPath() %>/requests" class="filter-bar" id="filterForm">
                <input type="hidden" name="action" value="pending">
                <input type="hidden" name="tab" id="formTabValue" value="<%= tab %>">
                
                <input type="text" name="searchName" placeholder="🔍 Tìm theo tên nhân viên..."
                       value="<%= escapeAttr(searchName) %>" onchange="resetPageAndSubmit()">
                <select name="filterType" onchange="resetPageAndSubmit()">
                    <option value="">-- Tất cả loại đơn --</option>
                    <%
                        if (allRequestTypes != null) {
                            for (String t : allRequestTypes) {
                                String isSel = t.equalsIgnoreCase(filterType) ? "selected" : "";
                    %>
                    <option value="<%= t %>" <%= isSel %>><%= t %></option>
                    <%
                            }
                        }
                    %>
                </select>
            </form>
            
            <% if (requests.isEmpty()) { %>
                <div class="empty-state"><strong>Chưa có đơn yêu cầu nào gửi lên hệ thống.</strong><p>Các đơn yêu cầu của nhân viên sẽ hiển thị tại đây.</p></div>
            <% } else { %>
                <div class="table-wrap"><table>
                    <thead><tr><th>Nhân viên</th><th>Đơn yêu cầu</th><th>Loại</th><th>Ngày gửi</th><th>Thao tác</th></tr></thead>
                    <tbody>
                    <% for (RequestDTO item : requests) {
                        String status = item.getStatus() == null ? "" : item.getStatus();
                        String badgeClass = "badge-pending";
                        if ("Approved".equalsIgnoreCase(status)) badgeClass = "badge-approved";
                        else if ("Rejected".equalsIgnoreCase(status)) badgeClass = "badge-rejected";
                    %>
                        <tr class="request-row" style="cursor: pointer;" onclick="if (!event.target.closest('form') && !event.target.closest('a')) window.location.href='requests?action=pending&id=<%= item.getId() %>&tab=<%= tab %>&page=' + currentPage + '&searchName=<%= searchNameEnc %>&filterType=<%= filterTypeEnc %>';">
                            <td><span class="request-name"><%= item.getCreatedByName() %></span></td>
                            <td><div class="request-name"><%= item.getTitle() %></div></td>
                            <td><%= item.getRequestTypeName() %></td>
                            <td><%= item.getCreatedAt() == null ? "-" : dateFormat.format(item.getCreatedAt()) %></td>
                            <td>
                                <div style="display: flex; gap: 8px; justify-content: flex-end; align-items: center;">
                                    <a href="#" onclick="window.location.href='requests?action=pending&id=<%= item.getId() %>&tab=<%= tab %>&page=' + currentPage + '&searchName=<%= searchNameEnc %>&filterType=<%= filterTypeEnc %>'; return false;" class="btn-view" style="text-decoration:none;">Chi tiết</a>
                                    <% if ("Pending".equalsIgnoreCase(status)) { %>
                                        <form class="decision-form" method="post" action="<%= request.getContextPath() %>/requests" onsubmit="return confirm('Duyệt đơn này?');">
                                            <input type="hidden" name="action" value="approve">
                                            <input type="hidden" name="id" value="<%= item.getId() %>">
                                            <button class="btn-decision btn-approve" type="submit">Duyệt</button>
                                        </form>
                                        <form class="decision-form" method="post" action="<%= request.getContextPath() %>/requests" onsubmit="var reason = prompt('Nhập lý do từ chối đơn:'); if (reason === null) return false; if (reason.trim() === '') { alert('Lý do từ chối không được để trống!'); return false; } this.rejectionReason.value = reason.trim(); return true;">
                                            <input type="hidden" name="action" value="reject">
                                            <input type="hidden" name="id" value="<%= item.getId() %>">
                                            <input type="hidden" name="rejectionReason" value="">
                                            <button class="btn-decision btn-reject" type="submit">Từ chối</button>
                                        </form>
                                    <% } else {
                                        String statusText = "Đã duyệt";
                                        if ("Rejected".equalsIgnoreCase(status)) {
                                            statusText = "Từ chối";
                                        }
                                    %>
                                        <div style="text-align: right;">
                                            <span class="badge <%= badgeClass %>"><%= statusText %></span>
                                            <span style="font-size: 11px; color: #6b7280; display: block; margin-top: 4px;">Bởi: <%= item.getCurrentApproverName() != null ? item.getCurrentApproverName() : "Hệ thống" %></span>
                                        </div>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table></div>
                <!-- Thanh phân trang -->
                <div class="hol-pagination" style="display: flex; align-items: center; justify-content: space-between; padding: 12px 20px; border-top: 1px solid #e5e7eb; flex-wrap: wrap; gap: 10px;">
                    <div class="hol-page-info" style="font-size: 0.84rem; color: #6b7280;">
                        <span id="paginationInfo">Hiển thị 0 - 0 / 0 đơn</span>
                    </div>
                    <div id="paginationControls" style="display: flex; align-items: center; gap: 4px;"></div>
                </div>
            <% } %>
        </section>
    </div>
    <footer>© 2026 Hệ thống Quản lý Nhân sự (EMS) · FPT University SWP391</footer>
</main>

<%
    if (selectedRequest != null) {
        String status = selectedRequest.getStatus() == null ? "" : selectedRequest.getStatus();
        String badgeClass = "badge-pending";
        String statusText = "Chờ duyệt";
        if ("Approved".equalsIgnoreCase(status)) {
            badgeClass = "badge-approved";
            statusText = "Đã duyệt";
        } else if ("Rejected".equalsIgnoreCase(status)) {
            badgeClass = "badge-rejected";
            statusText = "Từ chối";
        }
%>
<!-- Modal Chi tiết Yêu cầu (Java-driven) -->
<div class="modal-overlay" id="requestDetailModal" style="display: flex;">
  <div class="modal" style="max-width: 600px; display: flex; flex-direction: column;">
    <div class="modal-header">
      <div class="modal-header-left">
        <div class="modal-header-icon" style="display: flex; align-items: center; justify-content: center;">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
            <polyline points="14 2 14 8 20 8"></polyline>
            <line x1="16" y1="13" x2="8" y2="13"></line>
            <line x1="16" y1="17" x2="8" y2="17"></line>
            <polyline points="10 9 9 9 8 9"></polyline>
          </svg>
        </div>
        <div>
          <div class="modal-title">Chi tiết yêu cầu</div>
          <div class="modal-subtitle">Gửi lúc <%= selectedRequest.getCreatedAt() != null ? dateFormat.format(selectedRequest.getCreatedAt()) : "-" %></div>
        </div>
      </div>
      <a class="modal-close" style="text-decoration: none;" href="#" onclick="window.location.href='requests?action=pending&tab=<%= tab %>&page=' + currentPage + '&searchName=<%= searchNameEnc %>&filterType=<%= filterTypeEnc %>'; return false;">✕</a>
    </div>
    <div class="modal-body" style="padding: 20px; overflow-y: auto;">
      <table style="width: 100%; border-collapse: collapse;">
        <tr style="border-bottom: 1px solid #f1f5f9;">
          <td style="padding: 10px 0; font-weight: 600; color: #475569; width: 150px;">Nhân viên:</td>
          <td style="padding: 10px 0; color: #1e293b; font-weight: 600;"><%= selectedRequest.getCreatedByName() != null ? selectedRequest.getCreatedByName() : "-" %></td>
        </tr>
        <tr style="border-bottom: 1px solid #f1f5f9;">
          <td style="padding: 10px 0; font-weight: 600; color: #475569;">Tiêu đề:</td>
          <td style="padding: 10px 0; color: #1e293b;"><%= selectedRequest.getTitle() != null ? selectedRequest.getTitle() : "-" %></td>
        </tr>
        <tr style="border-bottom: 1px solid #f1f5f9;">
          <td style="padding: 10px 0; font-weight: 600; color: #475569;">Loại đơn:</td>
          <td style="padding: 10px 0; color: #1e293b;"><%= selectedRequest.getRequestTypeName() != null ? selectedRequest.getRequestTypeName() : "-" %></td>
        </tr>
        <% if (selectedRequest.getStartDate() != null) { %>
        <tr style="border-bottom: 1px solid #f1f5f9;">
          <td style="padding: 10px 0; font-weight: 600; color: #475569;">Từ ngày:</td>
          <td style="padding: 10px 0; color: #1e293b;"><%= dateFormat.format(selectedRequest.getStartDate()) %></td>
        </tr>
        <% } %>
        <% if (selectedRequest.getEndDate() != null) { %>
        <tr style="border-bottom: 1px solid #f1f5f9;">
          <td style="padding: 10px 0; font-weight: 600; color: #475569;">Đến ngày:</td>
          <td style="padding: 10px 0; color: #1e293b;"><%= dateFormat.format(selectedRequest.getEndDate()) %></td>
        </tr>
        <% } %>
        <tr style="border-bottom: 1px solid #f1f5f9;">
          <td style="padding: 10px 0; font-weight: 600; color: #475569;">Giá trị / Số ngày:</td>
          <td style="padding: 10px 0; color: #1e293b;"><%= formatValue(selectedRequest.getValue(), selectedRequest.getRequestTypeId()) %></td>
        </tr>
        <tr style="border-bottom: 1px solid #f1f5f9;">
          <td style="padding: 10px 0; font-weight: 600; color: #475569;">Trạng thái:</td>
          <td style="padding: 10px 0;"><span class="badge <%= badgeClass %>"><%= statusText %></span></td>
        </tr>
        <tr style="border-bottom: 1px solid #f1f5f9;">
          <td style="padding: 10px 0; font-weight: 600; color: #475569;">Người phê duyệt:</td>
          <td style="padding: 10px 0; color: #1e293b;"><%= selectedRequest.getCurrentApproverName() != null ? selectedRequest.getCurrentApproverName() : "Chưa phân công" %></td>
        </tr>
        <tr style="border-bottom: 1px solid #f1f5f9;">
          <td style="padding: 10px 0; font-weight: 600; color: #475569;">Ngày tạo:</td>
          <td style="padding: 10px 0; color: #1e293b;"><%= selectedRequest.getCreatedAt() != null ? dateFormat.format(selectedRequest.getCreatedAt()) : "-" %></td>
        </tr>
        <tr style="border-bottom: 1px solid #f1f5f9;">
          <td style="padding: 10px 0; font-weight: 600; color: #475569; vertical-align: top;">Lý do / Nội dung:</td>
          <td style="padding: 10px 0; color: #1e293b; white-space: pre-wrap;"><%= selectedRequest.getReason() != null && !selectedRequest.getReason().trim().isEmpty() ? selectedRequest.getReason() : "Không có nội dung" %></td>
        </tr>
        <% if (selectedRequest.getRejectionReason() != null && !selectedRequest.getRejectionReason().trim().isEmpty()) { %>
        <tr style="border-bottom: 1px solid #f1f5f9;">
          <td style="padding: 10px 0; font-weight: 600; color: #dc2626; vertical-align: top;">Lý do từ chối:</td>
          <td style="padding: 10px 0; color: #dc2626; white-space: pre-wrap;"><%= selectedRequest.getRejectionReason() %></td>
        </tr>
        <% } %>
        <% if (selectedRequest.getImageUrl() != null && !selectedRequest.getImageUrl().trim().isEmpty()) { %>
        <tr style="border-bottom: 1px solid #f1f5f9;">
          <td style="padding: 10px 0; font-weight: 600; color: #475569; vertical-align: top;">Minh chứng:</td>
          <td style="padding: 10px 0; color: #1e293b;">
            <a href="<%= selectedRequest.getImageUrl() %>" target="_blank" style="color: #2563eb; text-decoration: underline; display: block; margin-bottom: 5px;">Xem ảnh gốc</a>
            <img src="<%= selectedRequest.getImageUrl() %>" alt="Minh chứng" style="max-width: 100%; max-height: 200px; border-radius: 8px; border: 1px solid #e2e8f0; display: block; margin-top: 5px;">
          </td>
        </tr>
        <% } %>
      </table>
    </div>
    <div class="modal-footer">
      <% if ("Pending".equalsIgnoreCase(status)) { %>
          <form class="decision-form" method="post" action="<%= request.getContextPath() %>/requests" onsubmit="return confirm('Duyệt đơn này?');" style="display:inline;">
              <input type="hidden" name="action" value="approve">
              <input type="hidden" name="id" value="<%= selectedRequest.getId() %>">
              <button class="btn btn-primary" style="background:#059669; border-color:#059669; color:#fff;" type="submit">Duyệt đơn</button>
          </form>
          <form class="decision-form" method="post" action="<%= request.getContextPath() %>/requests" onsubmit="var reason = prompt('Nhập lý do từ chối đơn:'); if (reason === null) return false; if (reason.trim() === '') { alert('Lý do từ chối không được để trống!'); return false; } this.rejectionReason.value = reason.trim(); return true;" style="display:inline;">
              <input type="hidden" name="action" value="reject">
              <input type="hidden" name="id" value="<%= selectedRequest.getId() %>">
              <input type="hidden" name="rejectionReason" value="">
              <button class="btn btn-primary" style="background:#dc2626; border-color:#dc2626; color:#fff;" type="submit">Từ chối</button>
          </form>
      <% } %>
      <a class="btn btn-secondary" style="text-decoration: none; text-align: center; border: 1px solid #d1d5db; display: inline-block; padding: 8px 16px; border-radius: 6px; color:#374151; background:#fff;" href="#" onclick="window.location.href='requests?action=pending&tab=<%= tab %>&page=' + currentPage + '&searchName=<%= searchNameEnc %>&filterType=<%= filterTypeEnc %>'; return false;">Đóng</a>
    </div>
  </div>
</div>
<% } %>

<script>
    (function () { var now = new Date(), pad = function (n) { return String(n).padStart(2, '0'); }; document.getElementById('topbar-date').textContent = pad(now.getDate()) + '/' + pad(now.getMonth() + 1) + '/' + now.getFullYear(); }());

    function submitTab(tabName) {
        document.getElementById('formTabValue').value = tabName;
        // Reset page back to 1 on tab change
        var form = document.getElementById('filterForm');
        var pageInput = document.createElement('input');
        pageInput.type = 'hidden';
        pageInput.name = 'page';
        pageInput.value = '1';
        form.appendChild(pageInput);
        form.submit();
    }

    function resetPageAndSubmit() {
        var form = document.getElementById('filterForm');
        var pageInput = document.createElement('input');
        pageInput.type = 'hidden';
        pageInput.name = 'page';
        pageInput.value = '1';
        form.appendChild(pageInput);
        form.submit();
    }

    const PAGE_SIZE = 10;
    let currentPage = 1;
    let allRows = [];

    function initPagination() {
        const urlParams = new URLSearchParams(window.location.search);
        currentPage = parseInt(urlParams.get('page')) || 1;
        allRows = Array.from(document.querySelectorAll('tbody .request-row'));
        renderPagination();
    }

    function renderPagination() {
        allRows.forEach(function(r) { r.style.display = 'none'; });

        var total = allRows.length;
        var totalPages = Math.ceil(total / PAGE_SIZE) || 1;

        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;

        var startIdx = (currentPage - 1) * PAGE_SIZE;
        var endIdx = Math.min(startIdx + PAGE_SIZE, total);

        for (var i = startIdx; i < endIdx; i++) {
            allRows[i].style.display = '';
        }

        // Update badge count
        var badge = document.getElementById('requestCountBadge');
        if (badge) {
            badge.textContent = total + ' đơn';
        }

        var infoEl = document.getElementById('paginationInfo');
        if (infoEl) {
            if (total === 0) {
                infoEl.textContent = 'Không tìm thấy yêu cầu nào phù hợp';
            } else {
                infoEl.innerHTML = 'Hiển thị <strong>' + (startIdx + 1) + '-' + endIdx + '</strong> / ' + total + ' đơn';
            }
        }

        var controlsEl = document.getElementById('paginationControls');
        if (!controlsEl) return;
        controlsEl.innerHTML = '';

        if (totalPages <= 1) {
            return;
        }

        // Nút Trước
        var prevBtn = document.createElement('button');
        prevBtn.innerHTML = '&laquo; Trước';
        prevBtn.className = 'page-nav-btn';
        prevBtn.type = 'button';
        prevBtn.disabled = currentPage === 1;
        prevBtn.onclick = function() {
            if (currentPage > 1) {
                currentPage--;
                renderPagination();
            }
        };
        controlsEl.appendChild(prevBtn);

        // Các số trang
        for (var p = 1; p <= totalPages; p++) {
            if (totalPages > 7) {
                if (p !== 1 && p !== totalPages && Math.abs(p - currentPage) > 2) {
                    if (p === 2 || p === totalPages - 1) {
                        var dots = document.createElement('span');
                        dots.textContent = '...';
                        dots.style.padding = '0 4px';
                        dots.style.color = '#9ca3af';
                        controlsEl.appendChild(dots);
                    }
                    continue;
                }
            }
            var pageBtn = document.createElement('button');
            pageBtn.textContent = p;
            pageBtn.type = 'button';
            pageBtn.className = 'page-num-btn' + (p === currentPage ? ' active' : '');
            pageBtn.onclick = (function(page) {
                return function() {
                    currentPage = page;
                    renderPagination();
                };
            })(p);
            controlsEl.appendChild(pageBtn);
        }

        // Nút Tiếp
        var nextBtn = document.createElement('button');
        nextBtn.innerHTML = 'Tiếp &raquo;';
        nextBtn.className = 'page-nav-btn';
        nextBtn.type = 'button';
        nextBtn.disabled = currentPage === totalPages;
        nextBtn.onclick = function() {
            if (currentPage < totalPages) {
                currentPage++;
                renderPagination();
            }
        };
        controlsEl.appendChild(nextBtn);
    }

    document.addEventListener("DOMContentLoaded", function() {
        initPagination();
    });

    <% if (selectedRequest != null) { %>
    window.addEventListener('click', function(event) {
        var modal = document.getElementById('requestDetailModal');
        if (event.target === modal) {
            window.location.href = 'requests?action=pending&tab=<%= tab %>&page=' + currentPage + '&searchName=<%= searchNameEnc %>&filterType=<%= filterTypeEnc %>';
        }
    });

    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            window.location.href = 'requests?action=pending&tab=<%= tab %>&page=' + currentPage + '&searchName=<%= searchNameEnc %>&filterType=<%= filterTypeEnc %>';
        }
    });
    <% } %>
</script>
</body>
</html>