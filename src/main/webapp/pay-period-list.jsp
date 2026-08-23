<%@ page contentType="text/html;charset=UTF-8" %>
  <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
      <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

        <%@ page import="java.util.List" %>
          <%@ page import="com.ems.dto.TimesheetPeriodDTO" %>
            <% List<TimesheetPeriodDTO> periods = (List<TimesheetPeriodDTO>) request.getAttribute("periods");
                Integer totalFilteredItems = (Integer) request.getAttribute("totalFilteredItems");
                if (totalFilteredItems == null) totalFilteredItems = (periods != null ? periods.size() : 0);

                Integer totalPeriodsCount = (Integer) request.getAttribute("totalPeriodsCount");
                if (totalPeriodsCount == null) totalPeriodsCount = totalFilteredItems;

                Integer activePeriodsCount = (Integer) request.getAttribute("activePeriodsCount");
                if (activePeriodsCount == null) activePeriodsCount = 0;

                Integer lockedPeriodsCount = (Integer) request.getAttribute("lockedPeriodsCount");
                if (lockedPeriodsCount == null) lockedPeriodsCount = 0;

                Integer currentPage = (Integer) request.getAttribute("currentPage");
                if (currentPage == null) currentPage = 1;

                Integer pageSize = (Integer) request.getAttribute("pageSize");
                if (pageSize == null) pageSize = 5;

                Integer totalPages = (Integer) request.getAttribute("totalPages");
                if (totalPages == null) totalPages = 1;

                String searchStr = (String) request.getAttribute("search");
                if (searchStr == null) searchStr = "";

                String selectedStatus = (String) request.getAttribute("selectedStatus");
                if (selectedStatus == null) selectedStatus = "";

                String toastMessage = (String) request.getAttribute("toastMessage");
                String toastType = (String) request.getAttribute("toastType");

                int startItem = totalFilteredItems > 0 ? (currentPage - 1) * pageSize + 1 : 0;
                int endItem = Math.min(currentPage * pageSize, totalFilteredItems);
                %>
                <%!
                    private String buildPageUrl(String search, String status, int page, int pageSize) {
                        StringBuilder sb = new StringBuilder("pay-periods?page=").append(page).append("&pageSize=").append(pageSize);
                        if (search != null && !search.trim().isEmpty()) {
                            try {
                                sb.append("&search=").append(java.net.URLEncoder.encode(search.trim(), "UTF-8"));
                            } catch (Exception ignored) {}
                        }
                        if (status != null && !status.trim().isEmpty()) {
                            sb.append("&status=").append(status);
                        }
                        return sb.toString();
                    }
%>
<!DOCTYPE html>
<html lang="vi">

                  <head>
                    <meta charset="UTF-8" />
                    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                    <title>Quản lý Kỳ Lương – EMS</title>
                    <link rel="stylesheet" href="css/ems.css" />
                    <link rel="stylesheet" href="css/pay-period-list.css" />
                    <link rel="preconnect" href="https://fonts.googleapis.com">
                    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                      rel="stylesheet">
                  </head>

                  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>

                    <body>

                      <!-- TOAST ALERT CONTAINER -->
                      <% if (toastMessage !=null && !toastMessage.trim().isEmpty()) { %>
                        <div class="toast-container" id="toastBox">
                          <div class="toast <%= " error".equals(toastType) ? "toast-error" : "toast-success" %>">
                            <% if ("error".equals(toastType)) { %>
                              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#ef4444"
                                stroke-width="2">
                                <circle cx="12" cy="12" r="10" />
                                <line x1="15" y1="9" x2="9" y2="15" />
                                <line x1="9" y1="9" x2="15" y2="15" />
                              </svg>
                              <% } else { %>
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#16a34a"
                                  stroke-width="2">
                                  <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
                                  <polyline points="22 4 12 14.01 9 11.01" />
                                </svg>
                                <% } %>
                                  <span>
                                    <%= toastMessage %>
                                  </span>
                          </div>
                        </div>
                        <% } %>

                          <!-- MAIN CONTENT WRAPPER -->
                          <div class="main-content">
                            <!-- TOPBAR -->
                            <div class="topbar">
                              <span class="topbar-left"><a href="home_manager.jsp"
                                  style="color:inherit;text-decoration:none;">Trang chủ</a> / <a
                                  href="salary-management" style="color:inherit;text-decoration:none;">Quản lý lương</a>
                                / Quản lý kỳ lương</span>
                              <span class="topbar-right" id="topbar-date"></span>
                            </div>

                            <!-- PAGE BODY -->
                            <div class="page-body">
                              <!-- Header Section -->
                              <div class="pp-header">
                                <div>
                                  <h1>Quản lý Kỳ Lương (Pay Periods)</h1>
                                  <p>Thiết lập, cập nhật ngày bắt đầu - kết thúc và quản lý trạng thái khóa/mở kỳ lương
                                    nhân sự</p>
                                </div>
                                <button type="button" class="btn-create-period" onclick="openCreateModal()">
                                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                    <line x1="12" y1="5" x2="12" y2="19"></line>
                                    <line x1="5" y1="12" x2="19" y2="12"></line>
                                  </svg>
                                  Tạo kỳ lương mới
                                </button>
                              </div>

                              <!-- Summary Metrics Grid -->
                              <div class="pp-stats-row">
                                <div class="pp-stat-card">
                                  <div>
                                    <div class="pp-stat-label">Tổng số kỳ lương</div>
                                    <div class="pp-stat-value">
                                      <%= totalPeriodsCount %>
                                    </div>
                                  </div>
                                  <div class="pp-stat-icon icon-blue-bg">
                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                      stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                      <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                                      <line x1="16" y1="2" x2="16" y2="6"></line>
                                      <line x1="8" y1="2" x2="8" y2="6"></line>
                                      <line x1="3" y1="10" x2="21" y2="10"></line>
                                    </svg>
                                  </div>
                                </div>

                                <div class="pp-stat-card">
                                  <div>
                                    <div class="pp-stat-label">Kỳ lương đang mở</div>
                                    <div class="pp-stat-value">
                                      <%= activePeriodsCount %>
                                    </div>
                                  </div>
                                  <div class="pp-stat-icon icon-green-bg">
                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                      stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                      <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                                      <polyline points="22 4 12 14.01 9 11.01"></polyline>
                                    </svg>
                                  </div>
                                </div>

                                <div class="pp-stat-card">
                                  <div>
                                    <div class="pp-stat-label">Kỳ lương đã khóa</div>
                                    <div class="pp-stat-value">
                                      <%= lockedPeriodsCount %>
                                    </div>
                                  </div>
                                  <div class="pp-stat-icon icon-amber-bg">
                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                      stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                      <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                                      <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                                    </svg>
                                  </div>
                                </div>
                              </div>

                              <!-- Filter & Search Toolbar -->
                              <div class="pp-filter-card">
                                <form action="pay-periods" method="GET" class="pp-filter-form" id="filterForm">

                                  <!-- Search Input -->
                                  <div class="pp-search-wrapper">
                                    <svg class="pp-search-icon" width="16" height="16" viewBox="0 0 24 24" fill="none"
                                      stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                      stroke-linejoin="round">
                                      <circle cx="11" cy="11" r="8"></circle>
                                      <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                                    </svg>
                                    <input type="text" name="search" class="pp-input"
                                      placeholder="Tìm theo tên kỳ lương (VD: Tháng 08/2026)..."
                                      value="<%= searchStr %>" />
                                  </div>

                                  <!-- Search Button -->
                                  <button type="submit" class="pp-btn-search">
                                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                      stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                      <circle cx="11" cy="11" r="8"></circle>
                                      <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                                    </svg>
                                    Tìm kiếm
                                  </button>

                                  <!-- Status Filter -->
                                  <span class="pp-filter-label">Trạng thái</span>
                                  <select name="status" class="pp-select"
                                    onchange="document.getElementById('filterForm').submit()">
                                    <option value="">Tất cả trạng thái</option>
                                    <option value="active" <%="active" .equalsIgnoreCase(selectedStatus) ? "selected"
                                      : "" %>>Đang mở</option>
                                    <option value="locked" <%="locked" .equalsIgnoreCase(selectedStatus) ? "selected"
                                      : "" %>>Đã khóa</option>
                                  </select>

                                  <!-- Hidden Page preservation -->
                                  <input type="hidden" name="page" value="1" />
                                  <input type="hidden" name="pageSize" value="<%= pageSize %>" />
                                </form>
                              </div>

                              <!-- Data Table Card -->
                              <div class="pp-table-card">
                                <table class="pp-table">
                                  <thead>
                                    <tr>
                                      <th>MÃ KỲ</th>
                                      <th>TÊN KỲ LƯƠNG</th>
                                      <th>NGÀY BẮT ĐẦU</th>
                                      <th>NGÀY KẾT THÚC</th>
                                      <th>TRẠNG THÁI</th>
                                      <th style="text-align: right; padding-right: 24px;">HÀNH ĐỘNG</th>
                                    </tr>
                                  </thead>
                                  <tbody>
                                    <% if (periods !=null && !periods.isEmpty()) { for (TimesheetPeriodDTO p : periods)
                                      { boolean isLocked=p.isLocked(); %>
                                      <tr>
                                        <td class="period-id-text">#<%= p.getId() %>
                                        </td>
                                        <td>
                                          <span class="period-name-text">
                                            <%= p.getName() %>
                                          </span>
                                        </td>
                                        <td class="date-text">
                                          <%= p.getFormattedStartDate() %>
                                        </td>
                                        <td class="date-text">
                                          <%= p.getFormattedEndDate() %>
                                        </td>
                                        <td>
                                          <span class="badge-status-pill <%= p.getStatusBadgeClass() %>">
                                            <span class="status-dot"></span>
                                            <%= p.getStatus() %>
                                          </span>
                                        </td>
                                        <td>
                                          <div class="action-group" style="justify-content: flex-end;">

                                            <!-- Link to view payslips of this period -->
                                            <a href="payslips?periodId=<%= p.getId() %>" class="btn-action-view"
                                              title="Xem bảng lương kỳ này">
                                              <svg width="13" height="13" viewBox="0 0 24 24" fill="none"
                                                stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                                stroke-linejoin="round">
                                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                                <circle cx="12" cy="12" r="3"></circle>
                                              </svg>
                                              Xem bảng lương
                                            </a>

                                            <!-- Toggle Lock/Unlock button -->
                                            <form action="pay-periods" method="POST" style="display:inline;"
                                              id="toggleForm_<%= p.getId() %>">
                                              <input type="hidden" name="action" value="toggle-lock" />
                                              <input type="hidden" name="id" value="<%= p.getId() %>" />
                                              <input type="hidden" name="search" value="<%= searchStr %>" />
                                              <input type="hidden" name="status" value="<%= selectedStatus %>" />
                                              <input type="hidden" name="page" value="<%= currentPage %>" />
                                              <input type="hidden" name="pageSize" value="<%= pageSize %>" />

                                              <% if (isLocked) { %>
                                                <button type="button" class="btn-action-toggle btn-unlock"
                                                  onclick="confirmToggleLock(<%= p.getId() %>, '<%= p.getName().replace("'", "\\'") %>', false)">
                                                  <svg width="13" height="13" viewBox="0 0 24 24" fill="none"
                                                    stroke="currentColor" stroke-width="2">
                                                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                                                    <path d="M7 11V7a5 5 0 0 1 9.9-1" />
                                                  </svg>
                                                  Mở khóa
                                                </button>
                                                <% } else { %>
                                                  <button type="button" class="btn-action-toggle btn-lock"
                                                    onclick="confirmToggleLock(<%= p.getId() %>, '<%= p.getName().replace("'", "\\'") %>', true)">
                                                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none"
                                                      stroke="currentColor" stroke-width="2">
                                                      <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                                                      <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                                                    </svg>
                                                    Chốt sổ
                                                  </button>
                                                  <% } %>
                                            </form>

                                            <!-- Edit button -->
                                            <button type="button" class="btn-action-edit"
                                              onclick="openEditModal(<%= p.getId() %>, '<%= p.getName().replace("'", "\\'") %>', '<%= p.getStartDate() %>', '<%= p.getEndDate() %>', <%= isLocked %>)">
                                              <svg width="13" height="13" viewBox="0 0 24 24" fill="none"
                                                stroke="currentColor" stroke-width="2">
                                                <path d="M12 20h9" />
                                                <path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z" />
                                              </svg>
                                              Sửa
                                            </button>

                                          </div>
                                        </td>
                                      </tr>
                                      <% } } else { %>
                                        <tr>
                                          <td colspan="6" style="text-align: center; padding: 40px; color: #64748b;">
                                            Không tìm thấy kỳ lương nào phù hợp.
                                          </td>
                                        </tr>
                                        <% } %>
                                  </tbody>
                                </table>

                                <!-- Pagination Footer -->
                                <div class="pp-pagination-bar">
                                  <div class="pp-pagination-info">
                                    <span>Hiển thị <strong>
                                        <%= startItem %>-<%= endItem %>
                                      </strong> / <%= totalFilteredItems %> kỳ lương</span>
                                    <span>Mỗi trang
                                      <select class="pp-page-size-select" onchange="changePageSize(this.value)">
                                        <option value="5" <%=pageSize==5 ? "selected" : "" %>>5</option>
                                        <option value="10" <%=pageSize==10 ? "selected" : "" %>>10</option>
                                        <option value="20" <%=pageSize==20 ? "selected" : "" %>>20</option>
                                      </select>
                                    </span>
                                  </div>

                                  <div class="pp-pagination-controls">
                                    <% if (currentPage> 1) { %>
                                      <a href="<%= buildPageUrl(searchStr, selectedStatus, currentPage - 1, pageSize) %>"
                                        class="pp-page-nav-btn">&lt;</a>
                                      <% } else { %>
                                        <span class="pp-page-nav-btn disabled">&lt;</span>
                                        <% } %>

                                          <% for (int p=1; p <=totalPages; p++) { %>
                                            <% if (p==currentPage) { %>
                                              <span class="pp-page-btn active">
                                                <%= p %>
                                              </span>
                                              <% } else { %>
                                                <a href="<%= buildPageUrl(searchStr, selectedStatus, p, pageSize) %>"
                                                  class="pp-page-btn">
                                                  <%= p %>
                                                </a>
                                                <% } %>
                                                  <% } %>

                                                    <% if (currentPage < totalPages) { %>
                                                      <a href="<%= buildPageUrl(searchStr, selectedStatus, currentPage + 1, pageSize) %>"
                                                        class="pp-page-nav-btn">&gt;</a>
                                                      <% } else { %>
                                                        <span class="pp-page-nav-btn disabled">&gt;</span>
                                                        <% } %>
                                  </div>
                                </div>
                              </div>
                            </div>

                            <!-- FOOTER -->
                            <footer>© 2026 Hệ thống Quản lý Nhân sự (EMS) · FPT University SWP391</footer>
                          </div>


                          <!-- MODAL: TẠO KỲ LƯƠNG MỚI -->
                          <div class="modal-overlay" id="createModal">
                            <div class="modal-card">
                              <button type="button" class="modal-close-btn" onclick="closeCreateModal()">✕</button>
                              <div class="modal-title">Tạo kỳ lương mới</div>
                              <div class="modal-subtitle">Điền thông tin tên và chu kỳ thời gian cho kỳ lương nhân viên
                              </div>

                              <form action="pay-periods" method="POST" id="createForm">
                                <input type="hidden" name="action" value="create" />
                                <input type="hidden" name="search" value="<%= searchStr %>" />
                                <input type="hidden" name="status" value="<%= selectedStatus %>" />
                                <input type="hidden" name="page" value="1" />
                                <input type="hidden" name="pageSize" value="<%= pageSize %>" />

                                <div class="modal-form-group">
                                  <label>Tên kỳ lương <span style="color:#ef4444;">*</span></label>
                                  <input type="text" name="name" id="createName"
                                    placeholder="VD: Kỳ lương Tháng 09/2026" required pattern=".*\S+.*" title="Vui lòng nhập định dạng hợp lệ, không thể chỉ chứa khoảng trắng" />
                                </div>

                                <div class="modal-form-group modal-date-grid">
                                  <div>
                                    <label>Ngày bắt đầu <span style="color:#ef4444;">*</span></label>
                                    <input type="date" name="startDate" id="createStartDate" required />
                                  </div>
                                  <div>
                                    <label>Ngày kết thúc <span style="color:#ef4444;">*</span></label>
                                    <input type="date" name="endDate" id="createEndDate" required />
                                  </div>
                                </div>

                                <div class="modal-form-group" style="margin-top:10px;">
                                  <label class="checkbox-label">
                                    <input type="checkbox" name="isLocked" value="true" />
                                    <span>Chốt/Khóa kỳ lương này ngay sau khi tạo</span>
                                  </label>
                                </div>

                                <div class="modal-footer">
                                  <button type="button" class="btn-modal-cancel"
                                    onclick="closeCreateModal()">Hủy</button>
                                  <button type="submit" class="btn-modal-save">Tạo kỳ lương</button>
                                </div>
                              </form>
                            </div>
                          </div>


                          <!-- MODAL: CHỈNH SỬA KỲ LƯƠNG -->
                          <div class="modal-overlay" id="editModal">
                            <div class="modal-card">
                              <button type="button" class="modal-close-btn" onclick="closeEditModal()">✕</button>
                              <div class="modal-title">Chỉnh sửa kỳ lương</div>
                              <div class="modal-subtitle">Cập nhật tên và khoảng thời gian cho kỳ lương #<span
                                  id="editDisplayId"></span></div>

                              <form action="pay-periods" method="POST" id="editForm">
                                <input type="hidden" name="action" value="update" />
                                <input type="hidden" name="id" id="editId" />
                                <input type="hidden" name="search" value="<%= searchStr %>" />
                                <input type="hidden" name="status" value="<%= selectedStatus %>" />
                                <input type="hidden" name="page" value="<%= currentPage %>" />
                                <input type="hidden" name="pageSize" value="<%= pageSize %>" />

                                <div class="modal-form-group">
                                  <label>Tên kỳ lương <span style="color:#ef4444;">*</span></label>
                                  <input type="text" name="name" id="editName" required pattern=".*\S+.*" title="Vui lòng nhập định dạng hợp lệ, không thể chỉ chứa khoảng trắng" />
                                </div>

                                <div class="modal-form-group modal-date-grid">
                                  <div>
                                    <label>Ngày bắt đầu <span style="color:#ef4444;">*</span></label>
                                    <input type="date" name="startDate" id="editStartDate" required />
                                  </div>
                                  <div>
                                    <label>Ngày kết thúc <span style="color:#ef4444;">*</span></label>
                                    <input type="date" name="endDate" id="editEndDate" required />
                                  </div>
                                </div>

                                <div class="modal-form-group" style="margin-top:10px;">
                                  <label class="checkbox-label">
                                    <input type="checkbox" name="isLocked" id="editIsLocked" value="true" />
                                    <span>Khóa kỳ lương (Không cho phép chỉnh sửa bảng lương)</span>
                                  </label>
                                </div>

                                <div class="modal-footer">
                                  <button type="button" class="btn-modal-cancel" onclick="closeEditModal()">Hủy</button>
                                  <button type="submit" class="btn-modal-save">Cập nhật</button>
                                </div>
                              </form>
                            </div>
                          </div>



                          <script>
                            function tick() {
                              var now = new Date();
                              var p = function (n) { return String(n).padStart(2, '0'); };
                              var el = document.getElementById('topbar-date');
                              if (el) {
                                el.textContent = p(now.getDate()) + '/' + p(now.getMonth() + 1) + '/' + now.getFullYear();
                              }
                            }
                            tick();

                            // Toast Auto Fade Out
                            setTimeout(function () {
                              var toastBox = document.getElementById('toastBox');
                              if (toastBox) {
                                toastBox.style.opacity = '0';
                                toastBox.style.transition = 'opacity 0.5s ease';
                                setTimeout(function () { toastBox.remove(); }, 500);
                              }
                            }, 4000);

                            function changePageSize(newSize) {
                              var url = new URL(window.location.href);
                              url.searchParams.set('pageSize', newSize);
                              url.searchParams.set('page', '1');
                              window.location.href = url.toString();
                            }

                            // Create Modal Controls
                            function openCreateModal() {
                              var now = new Date();
                              var y = now.getFullYear();
                              var m = String(now.getMonth() + 1).padStart(2, '0');

                              // Auto suggest next month name if current day is late in month
                              document.getElementById('createName').value = 'Kỳ lương Tháng ' + m + '/' + y;

                              // Default dates
                              var firstDay = y + '-' + m + '-01';
                              var lastDayObj = new Date(y, now.getMonth() + 1, 0);
                              var lastDay = y + '-' + m + '-' + String(lastDayObj.getDate()).padStart(2, '0');

                              document.getElementById('createStartDate').value = firstDay;
                              document.getElementById('createEndDate').value = lastDay;

                              document.getElementById('createModal').style.display = 'flex';
                            }

                            function closeCreateModal() {
                              document.getElementById('createModal').style.display = 'none';
                            }

                            // Edit Modal Controls
                            function openEditModal(id, name, startDate, endDate, isLocked) {
                              document.getElementById('editId').value = id;
                              document.getElementById('editDisplayId').textContent = id;
                              document.getElementById('editName').value = name;
                              document.getElementById('editStartDate').value = startDate;
                              document.getElementById('editEndDate').value = endDate;
                              document.getElementById('editIsLocked').checked = (isLocked === true || isLocked === 'true');
                              document.getElementById('editModal').style.display = 'flex';
                            }

                            function closeEditModal() {
                              document.getElementById('editModal').style.display = 'none';
                            }

                            // Toggle Lock Confirm
                            function confirmToggleLock(id, name, shouldLock) {
                              var msg = shouldLock
                                ? 'Bạn có chắc chắn muốn CHỐT / KHÓA ' + name + '? Sau khi khóa, dữ liệu bảng lương sẽ được bảo lưu chắc chắn.'
                                : 'Bạn có chắc chắn muốn MỞ KHÓA ' + name + '?';
                              if (confirm(msg)) {
                                document.getElementById('toggleForm_' + id).submit();
                              }
                            }

                            // Close modals when clicking outside
                            window.onclick = function (event) {
                              var createM = document.getElementById('createModal');
                              var editM = document.getElementById('editModal');
                              if (event.target === createM) closeCreateModal();
                              if (event.target === editM) closeEditModal();
                            }
                          </script>

                    </body>

                    </html>