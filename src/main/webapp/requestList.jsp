<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.ems.dto.RequestDTO" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    List<RequestDTO> requests = (List<RequestDTO>) request.getAttribute("requests");
    if (requests == null) {
        response.sendRedirect(request.getContextPath() + "/requests?action=myRequests");
        return;
    }
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    String username = (String) session.getAttribute("username");

    Integer totalFilteredItems = (Integer) request.getAttribute("totalFilteredItems");
    if (totalFilteredItems == null) totalFilteredItems = (requests != null ? requests.size() : 0);

    Integer currentPage = (Integer) request.getAttribute("currentPage");
    if (currentPage == null) currentPage = 1;

    Integer pageSize = (Integer) request.getAttribute("pageSize");
    if (pageSize == null) pageSize = 5;

    Integer totalPages = (Integer) request.getAttribute("totalPages");
    if (totalPages == null) totalPages = 1;

    int startItem = totalFilteredItems > 0 ? (currentPage - 1) * pageSize + 1 : 0;
    int endItem = Math.min(currentPage * pageSize, totalFilteredItems);
%>
<%!
    private String buildPageUrl(String contextPath, int page, int pageSize) {
        return contextPath + "/requests?action=myRequests&page=" + page + "&pageSize=" + pageSize;
    }

    private String escapeAttr(String str) {
        if (str == null) return "";
        return str.replace("&", "&amp;")
                  .replace("<", "&lt;")
                  .replace(">", "&gt;")
                  .replace("\"", "&quot;")
                  .replace("'", "&#x27;");
    }

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
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EMS - Yêu cầu của tôi</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/ems.css">
    <style>
        .request-actions { display: flex; justify-content: space-between; align-items: center; gap: 16px; margin-bottom: 20px; }
        .btn-create { display: inline-block; padding: 9px 16px; border-radius: 7px; background: #2563eb; color: #fff; text-decoration: none; font-size: 13px; font-weight: 600; }
        .btn-create:hover { background: #1d4ed8; }
        .request-title { color: #111827; font-weight: 600; }
        .request-reason { max-width: 260px; color: #6b7280; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .empty-state { padding: 48px 20px; text-align: center; color: #6b7280; }
        .empty-state p { margin: 8px 0 18px; }
        .delete-form { display: inline; }
        .btn-delete { border: 0; background: transparent; color: #dc2626; font: inherit; font-size: 12px; cursor: pointer; }
        .btn-delete:hover { text-decoration: underline; }
        .btn-view { border: 0; background: transparent; color: #2563eb; font: inherit; font-size: 12px; cursor: pointer; text-decoration: none; margin-right: 8px; }
        .btn-view:hover { text-decoration: underline; }
        @media (max-width: 800px) { .sidebar { position: static; width: 100%; min-height: auto; } body { display: block; } .main-content { margin-left: 0; } .table-wrap { overflow-x: auto; } th, td { white-space: nowrap; } }
    </style>
</head>
<body>
<aside class="sidebar">
    <a href="home" class="sidebar-brand"><div class="brand-dot">E</div><span class="brand-name">EMS</span></a>
    <nav class="nav-group">
        <div class="nav-section-label">Menu chính</div>
        <a href="home" class="nav-link">Trang chủ</a>
        <a href="#" class="nav-link">Lịch trình</a>
        <div class="nav-section-label">Công việc</div>
        <a href="<%= request.getContextPath() %>/requests?action=myRequests" class="nav-link active">Yêu cầu</a>
        <a href="#" class="nav-link">Bảng lương</a>
    </nav>
    <div class="sidebar-footer">
        <div class="user-block">
            <div class="user-avatar"><%= username != null && !username.isEmpty() ? username.substring(0, 1).toUpperCase() : "N" %></div>
            <div><div class="user-name"><%= username != null ? username : "Nhân viên" %></div><div class="user-role">Nhân viên</div></div>
        </div>
        <button class="btn-logout" onclick="window.location='<%= request.getContextPath() %>/login'">Đăng xuất</button>
    </div>
</aside>

<main class="main-content">
    <div class="topbar"><span class="topbar-left">Yêu cầu của tôi</span><span class="topbar-right" id="topbar-date"></span></div>
    <div class="page-body">
        <div class="request-actions">
            <div class="page-header"><h1>Danh sách yêu cầu</h1><p>Theo dõi trạng thái các yêu cầu bạn đã gửi.</p></div>
            <a class="btn-create" href="request.jsp">+ Tạo yêu cầu</a>
        </div>
        <section class="card">
            <div class="card-header"><span>Tất cả yêu cầu</span><span class="badge badge-active"><%= totalFilteredItems %> yêu cầu</span></div>
            <% if (requests.isEmpty()) { %>
                <div class="empty-state"><strong>Bạn chưa gửi yêu cầu nào.</strong><p>Tạo yêu cầu mới để bắt đầu.</p><a class="btn-create" href="request.jsp">Tạo yêu cầu</a></div>
            <% } else { %>
                <div class="table-wrap"><table>
                    <thead><tr><th>Tiêu đề</th><th>Loại</th><th>Giá trị</th><th>Người duyệt</th><th>Trạng thái</th><th></th></tr></thead>
                    <tbody>
                    <% for (RequestDTO item : requests) {
                        String status = item.getStatus() == null ? "" : item.getStatus();
                        String badgeClass = "badge-pending";
                        if ("Approved".equalsIgnoreCase(status)) badgeClass = "badge-approved";
                        else if ("Rejected".equalsIgnoreCase(status)) badgeClass = "badge-rejected";
                    %>
                    <tr style="cursor: pointer;" onclick="showRequestDetail(this)"
                        data-id="<%= item.getId() %>"
                        data-title="<%= escapeAttr(item.getTitle()) %>"
                        data-type="<%= escapeAttr(item.getRequestTypeName()) %>"
                        data-start-date="<%= item.getStartDate() != null ? dateFormat.format(item.getStartDate()) : "-" %>"
                        data-end-date="<%= item.getEndDate() != null ? dateFormat.format(item.getEndDate()) : "-" %>"
                        data-value="<%= formatValue(item.getValue(), item.getRequestTypeId()) %>"
                        data-approver="<%= escapeAttr(item.getCurrentApproverName() != null ? item.getCurrentApproverName() : "Chưa phân công") %>"
                        data-status="<%= "Approved".equalsIgnoreCase(status) ? "Đã duyệt" : "Rejected".equalsIgnoreCase(status) ? "Từ chối" : "Chờ duyệt" %>"
                        data-status-class="<%= badgeClass %>"
                        data-reason="<%= escapeAttr(item.getReason()) %>"
                        data-rejection-reason="<%= escapeAttr(item.getRejectionReason()) %>"
                        data-image-url="<%= escapeAttr(item.getImageUrl()) %>"
                        data-created-at="<%= item.getCreatedAt() != null ? dateFormat.format(item.getCreatedAt()) : "-" %>">
                        <td><div class="request-title"><%= item.getTitle() %></div></td>
                        <td><%= item.getRequestTypeName() %></td>
                        <td><%= formatValue(item.getValue(), item.getRequestTypeId()) %></td>
                        <td><%= item.getCurrentApproverName() != null ? item.getCurrentApproverName() : "Chưa phân công" %></td>
                        <td>
                            <span class="badge <%= badgeClass %>"><%= "Approved".equalsIgnoreCase(status) ? "Đã duyệt" : "Rejected".equalsIgnoreCase(status) ? "Từ chối" : "Chờ duyệt" %></span>
                            <% if ("Rejected".equalsIgnoreCase(status) && item.getRejectionReason() != null && !item.getRejectionReason().isBlank()) { %>
                                <div style="font-size: 11px; color: #dc2626; margin-top: 4px;" title="<%= escapeAttr(item.getRejectionReason()) %>">Lý do: <%= item.getRejectionReason() %></div>
                            <% } %>
                        </td>
                        <td onclick="event.stopPropagation();">
                            <a href="javascript:void(0)" class="btn-view" onclick="showRequestDetail(this.closest('tr'))">Xem</a>
                            <% if ("Pending".equalsIgnoreCase(status)) { %>
                                <form class="delete-form" method="post" action="<%= request.getContextPath() %>/requests" onsubmit="return confirm('Bạn có muốn hủy yêu cầu này?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="<%= item.getId() %>">
                                    <button class="btn-delete" type="submit">Hủy</button>
                                </form>
                            <% } %>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table></div>

                <!-- Thanh phân trang -->
                <div class="hol-pagination" style="display: flex; align-items: center; justify-content: space-between; padding: 12px 20px; border-top: 1px solid #e5e7eb; flex-wrap: wrap; gap: 10px;">
                    <div class="hol-page-info" style="font-size: 0.84rem; color: #6b7280;">
                        <span>Hiển thị <strong><%= startItem %>-<%= endItem %></strong> / <%= totalFilteredItems %> yêu cầu</span>
                    </div>
                    <% if (totalPages > 1) { %>
                    <div class="hol-page-btns" style="display: flex; align-items: center; gap: 4px;">
                        <%-- Nút Trước --%>
                        <a href="<%= buildPageUrl(request.getContextPath(), currentPage - 1, pageSize) %>"
                           class="hol-page-btn <%= currentPage <= 1 ? "disabled" : "" %>">&lt; Trước</a>

                        <%-- Các số trang --%>
                        <%
                            int winStart = Math.max(2, currentPage - 2);
                            int winEnd = Math.min(totalPages - 1, currentPage + 2);
                        %>

                        <a href="<%= buildPageUrl(request.getContextPath(), 1, pageSize) %>"
                           class="hol-page-btn <%= currentPage == 1 ? "active" : "" %>">1</a>

                        <% if (currentPage > 4) { %>
                            <span class="hol-page-ellipsis" style="color: #6b7280; padding: 0 4px;">&hellip;</span>
                        <% } %>

                        <% for (int p = winStart; p <= winEnd; p++) { %>
                            <a href="<%= buildPageUrl(request.getContextPath(), p, pageSize) %>"
                               class="hol-page-btn <%= p == currentPage ? "active" : "" %>"><%= p %></a>
                        <% } %>

                        <% if (currentPage < totalPages - 3) { %>
                            <span class="hol-page-ellipsis" style="color: #6b7280; padding: 0 4px;">&hellip;</span>
                        <% } %>

                        <% if (totalPages > 1) { %>
                            <a href="<%= buildPageUrl(request.getContextPath(), totalPages, pageSize) %>"
                               class="hol-page-btn <%= currentPage == totalPages ? "active" : "" %>"><%= totalPages %></a>
                        <% } %>

                        <%-- Nút Tiếp --%>
                        <a href="<%= buildPageUrl(request.getContextPath(), currentPage + 1, pageSize) %>"
                           class="hol-page-btn <%= currentPage >= totalPages ? "disabled" : "" %>">Tiếp &gt;</a>
                    </div>
                    <% } %>
                </div>
            <% } %>
        </section>
    </div>
    <footer>© 2026 Hệ thống Quản lý Nhân sự (EMS) · FPT University SWP391</footer>
</main>

<!-- Modal Chi tiết Yêu cầu -->
<div class="modal-overlay" id="requestDetailModal" style="display: none;">
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
          <div class="modal-subtitle" id="detailModalSubtitle">Mã đơn và thông tin gửi</div>
        </div>
      </div>
      <button class="modal-close" onclick="closeDetailModal()">✕</button>
    </div>
    <div class="modal-body" style="padding: 20px; overflow-y: auto;">
      <table style="width: 100%; border-collapse: collapse;">
        <tr style="border-bottom: 1px solid #f1f5f9;">
          <td style="padding: 10px 0; font-weight: 600; color: #475569; width: 150px;">Tiêu đề:</td>
          <td style="padding: 10px 0; color: #1e293b;" id="detTitle">-</td>
        </tr>
        <tr style="border-bottom: 1px solid #f1f5f9;">
          <td style="padding: 10px 0; font-weight: 600; color: #475569;">Loại đơn:</td>
          <td style="padding: 10px 0; color: #1e293b;" id="detType">-</td>
        </tr>
        <tr id="detStartDateRow" style="border-bottom: 1px solid #f1f5f9; display: none;">
          <td style="padding: 10px 0; font-weight: 600; color: #475569;">Từ ngày:</td>
          <td style="padding: 10px 0; color: #1e293b;" id="detStartDate">-</td>
        </tr>
        <tr id="detEndDateRow" style="border-bottom: 1px solid #f1f5f9; display: none;">
          <td style="padding: 10px 0; font-weight: 600; color: #475569;">Đến ngày:</td>
          <td style="padding: 10px 0; color: #1e293b;" id="detEndDate">-</td>
        </tr>
        <tr style="border-bottom: 1px solid #f1f5f9;">
          <td style="padding: 10px 0; font-weight: 600; color: #475569;">Giá trị / Số ngày:</td>
          <td style="padding: 10px 0; color: #1e293b;" id="detValue">-</td>
        </tr>
        <tr style="border-bottom: 1px solid #f1f5f9;">
          <td style="padding: 10px 0; font-weight: 600; color: #475569;">Trạng thái:</td>
          <td style="padding: 10px 0;" id="detStatusContainer"><span class="badge" id="detStatus">-</span></td>
        </tr>
        <tr style="border-bottom: 1px solid #f1f5f9;">
          <td style="padding: 10px 0; font-weight: 600; color: #475569;">Người phê duyệt:</td>
          <td style="padding: 10px 0; color: #1e293b;" id="detApprover">-</td>
        </tr>
        <tr style="border-bottom: 1px solid #f1f5f9;">
          <td style="padding: 10px 0; font-weight: 600; color: #475569;">Ngày tạo:</td>
          <td style="padding: 10px 0; color: #1e293b;" id="detCreatedAt">-</td>
        </tr>
        <tr style="border-bottom: 1px solid #f1f5f9;">
          <td style="padding: 10px 0; font-weight: 600; color: #475569; vertical-align: top;">Lý do / Nội dung:</td>
          <td style="padding: 10px 0; color: #1e293b; white-space: pre-wrap;" id="detReason">-</td>
        </tr>
        <tr id="detRejectionReasonRow" style="border-bottom: 1px solid #f1f5f9; display: none;">
          <td style="padding: 10px 0; font-weight: 600; color: #dc2626; vertical-align: top;">Lý do từ chối:</td>
          <td style="padding: 10px 0; color: #dc2626; white-space: pre-wrap;" id="detRejectionReason">-</td>
        </tr>
        <tr id="detImageRow" style="border-bottom: 1px solid #f1f5f9; display: none;">
          <td style="padding: 10px 0; font-weight: 600; color: #475569; vertical-align: top;">Minh chứng:</td>
          <td style="padding: 10px 0; color: #1e293b;">
            <a id="detImageLink" href="#" target="_blank" style="color: #2563eb; text-decoration: underline; display: block; margin-bottom: 5px;">Xem ảnh gốc</a>
            <img id="detImagePreview" src="" alt="Minh chứng" style="max-width: 100%; max-height: 200px; border-radius: 8px; border: 1px solid #e2e8f0; display: block; margin-top: 5px;">
          </td>
        </tr>
      </table>
    </div>
    <div class="modal-footer">
      <button type="button" class="btn btn-secondary" onclick="closeDetailModal()">Đóng</button>
    </div>
  </div>
</div>

<script>
    (function () { var now = new Date(), pad = function (n) { return String(n).padStart(2, '0'); }; document.getElementById('topbar-date').textContent = pad(now.getDate()) + '/' + pad(now.getMonth() + 1) + '/' + now.getFullYear(); }());

    function showRequestDetail(row) {
        var id = row.getAttribute('data-id');
        var title = row.getAttribute('data-title');
        var type = row.getAttribute('data-type');
        var startDate = row.getAttribute('data-start-date');
        var endDate = row.getAttribute('data-end-date');
        var value = row.getAttribute('data-value');
        var approver = row.getAttribute('data-approver');
        var status = row.getAttribute('data-status');
        var statusClass = row.getAttribute('data-status-class');
        var reason = row.getAttribute('data-reason');
        var rejectionReason = row.getAttribute('data-rejection-reason');
        var imageUrl = row.getAttribute('data-image-url');
        var createdAt = row.getAttribute('data-created-at');

        document.getElementById('detailModalSubtitle').textContent = 'Gửi lúc ' + createdAt;
        document.getElementById('detTitle').textContent = title;
        document.getElementById('detType').textContent = type;
        
        var startRow = document.getElementById('detStartDateRow');
        var endRow = document.getElementById('detEndDateRow');
        
        if (startDate && startDate !== '-' && startDate.trim() !== '') {
            startRow.style.display = '';
            document.getElementById('detStartDate').textContent = startDate;
        } else {
            startRow.style.display = 'none';
        }

        if (endDate && endDate !== '-' && endDate.trim() !== '') {
            endRow.style.display = '';
            document.getElementById('detEndDate').textContent = endDate;
        } else {
            endRow.style.display = 'none';
        }

        document.getElementById('detValue').textContent = value;
        
        var statusBadge = document.getElementById('detStatus');
        statusBadge.className = 'badge ' + statusClass;
        statusBadge.textContent = status;

        document.getElementById('detApprover').textContent = approver;
        document.getElementById('detCreatedAt').textContent = createdAt;
        document.getElementById('detReason').textContent = reason ? reason : "Không có nội dung";

        var rejRow = document.getElementById('detRejectionReasonRow');
        if (rejectionReason && rejectionReason.trim() !== '') {
            rejRow.style.display = '';
            document.getElementById('detRejectionReason').textContent = rejectionReason;
        } else {
            rejRow.style.display = 'none';
        }

        var imgRow = document.getElementById('detImageRow');
        if (imageUrl && imageUrl.trim() !== '') {
            imgRow.style.display = '';
            document.getElementById('detImageLink').href = imageUrl;
            document.getElementById('detImagePreview').src = imageUrl;
        } else {
            imgRow.style.display = 'none';
        }

        var modal = document.getElementById('requestDetailModal');
        modal.style.display = 'flex';
        modal.classList.add('open');
        document.body.style.overflow = 'hidden';
    }

    function closeDetailModal() {
        var modal = document.getElementById('requestDetailModal');
        modal.style.display = 'none';
        modal.classList.remove('open');
        document.body.style.overflow = '';
    }

    // Đóng modal khi click ra ngoài card
    window.addEventListener('click', function(event) {
        var modal = document.getElementById('requestDetailModal');
        if (event.target === modal) {
            closeDetailModal();
        }
    });

    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            closeDetailModal();
        }
    });
</script>
</body>
</html>
