<%@ page contentType="text/html;charset=UTF-8" %>
  <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
      <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

        <%@ page import="java.util.List" %>
          <%@ page import="com.ems.dto.BaseSalaryDTO" %>
            <%@ page import="com.ems.dto.SalarySummaryDTO" %>
              <%@ page import="com.ems.model.Departments" %>
                <%@ page import="com.ems.model.Positions" %>
                  <% List<BaseSalaryDTO> baseSalaries = (List<BaseSalaryDTO>) request.getAttribute("baseSalaries");
                      SalarySummaryDTO summary = (SalarySummaryDTO) request.getAttribute("summary");
                      List<Departments> departments = (List<Departments>) request.getAttribute("departments");
                          List<Positions> positions = (List<Positions>) request.getAttribute("positions");

                              Integer totalEmployeesCount = (Integer) request.getAttribute("totalEmployeesCount");
                              if (totalEmployeesCount == null) totalEmployeesCount = (summary != null ?
                              summary.getTotalEmployees() : 0);

                              Integer totalFilteredItems = (Integer) request.getAttribute("totalFilteredItems");
                              if (totalFilteredItems == null) totalFilteredItems = (baseSalaries != null ?
                              baseSalaries.size() : 0);

                              Integer currentPage = (Integer) request.getAttribute("currentPage");
                              if (currentPage == null) currentPage = 1;

                              Integer pageSize = (Integer) request.getAttribute("pageSize");
                              if (pageSize == null) pageSize = 5;

                              Integer totalPages = (Integer) request.getAttribute("totalPages");
                              if (totalPages == null) totalPages = 1;

                              String searchStr = (String) request.getAttribute("search");
                              if (searchStr == null) searchStr = "";

                              Integer selectedDeptId = (Integer) request.getAttribute("selectedDepartmentId");
                              Integer selectedPosId = (Integer) request.getAttribute("selectedPositionId");
                              String sortByVal = (String) request.getAttribute("sortBy");
                              String sortOrderVal = (String) request.getAttribute("sortOrder");

                              int startItem = totalFilteredItems > 0 ? (currentPage - 1) * pageSize + 1 : 0;
                              int endItem = Math.min(currentPage * pageSize, totalFilteredItems);
                              %>
                              <%! private String buildPageUrl(String search, Integer deptId, Integer posId, int page, int pageSize) {
    StringBuilder sb = new StringBuilder("base-salaries?page=").append(page).append("&pageSize=").append(pageSize);
    if (search != null && !search.trim().isEmpty()) {
        try {
            sb.append("&search=").append(java.net.URLEncoder.encode(search.trim(), "UTF-8")); 
        } catch (Exception ignored) {} 
    } 
    if (deptId != null && deptId > 0) {
        sb.append("&departmentId=").append(deptId);
    }
    if (posId != null && posId > 0) {
        sb.append("&positionId=").append(posId);
    }
    return sb.toString();
}
%>
                                <!DOCTYPE html>
                                <html lang="vi">

                                <head>
                                  <meta charset="UTF-8" />
                                  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                                  <title>Lương hợp đồng – EMS</title>
                                  <link rel="stylesheet" href="css/ems.css" />
                                  <link rel="stylesheet" href="css/base-salary-list.css" />
                                  <link rel="preconnect" href="https://fonts.googleapis.com">
                                  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
                                  <link
                                    href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                                    rel="stylesheet">
                                </head>

                                <!-- ── Sidebar ── -->
                                <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>

                                  <body>

                                    <!-- MAIN CONTENT WRAPPER -->
                                    <div class="main-content">
                                      <!-- TOPBAR -->
                                      <div class="topbar">
                                        <span class="topbar-left"><a href="home_manager.jsp"
                                            style="color:inherit;text-decoration:none;">Trang chủ</a> / <a
                                            href="salary-management" style="color:inherit;text-decoration:none;">Quản lý
                                            lương</a> / Xem lương cơ bản</span>
                                        <span class="topbar-right" id="topbar-date"></span>
                                      </div>

                                      <!-- PAGE BODY (Image 1 UI) -->
                                      <div class="page-body">
                                        <!-- Header Section -->
                                        <div class="bs-header">
                                          <h1>Lương hợp đồng</h1>
                                          <p>Thiết lập mức lương cơ bản (Base Salary) cho từng nhân viên</p>
                                        </div>

                                        <!-- Summary Metrics Grid -->
                                        <div class="bs-stats-row">
                                          <div class="bs-stat-card">
                                            <div class="bs-stat-label">Tổng nhân viên</div>
                                            <div class="bs-stat-value">
                                              <%= totalEmployeesCount %>
                                            </div>
                                          </div>

                                          <div class="bs-stat-card">
                                            <div class="bs-stat-label">Kết quả lọc</div>
                                            <div class="bs-stat-value">
                                              <%= totalFilteredItems %>
                                            </div>
                                          </div>

                                          <div class="bs-stat-card">
                                            <div class="bs-stat-label">Tổng quỹ lương (lọc)</div>
                                            <div class="bs-stat-value">
                                              <%= summary !=null ? summary.getFormattedTotalBudget() : "0" %> đ
                                            </div>
                                          </div>
                                        </div>

                                        <!-- Filter & Search Toolbar -->
                                        <div class="bs-filter-card">
                                          <form action="base-salaries" method="GET" class="bs-filter-form"
                                            id="filterForm">

                                            <!-- Search Input -->
                                            <div class="bs-search-wrapper">
                                              <svg class="bs-search-icon" width="16" height="16" viewBox="0 0 24 24"
                                                fill="none" stroke="currentColor" stroke-width="2"
                                                stroke-linecap="round" stroke-linejoin="round">
                                                <circle cx="11" cy="11" r="8"></circle>
                                                <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                                              </svg>
                                              <input type="text" name="search" class="bs-input"
                                                placeholder="Tìm tên hoặc mã nhân viên..." value="<%= searchStr %>" />
                                            </div>

                                            <!-- Search Button -->
                                            <button type="submit" class="bs-btn-search">
                                              <svg width="15" height="15" viewBox="0 0 24 24" fill="none"
                                                stroke="currentColor" stroke-width="2.5" stroke-linecap="round"
                                                stroke-linejoin="round">
                                                <circle cx="11" cy="11" r="8"></circle>
                                                <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                                              </svg>
                                              Tìm kiếm
                                            </button>

                                            <!-- Department Filter -->
                                            <span class="bs-filter-label">Phòng ban</span>
                                            <select name="departmentId" class="bs-select"
                                              onchange="document.getElementById('filterForm').submit()">
                                              <option value="">Tất cả</option>
                                              <% if (departments !=null) { for (Departments dept : departments) {
                                                boolean isSelected=selectedDeptId !=null &&
                                                selectedDeptId.equals(dept.getId()); %>
                                                <option value="<%= dept.getId() %>" <%=isSelected ? "selected" : "" %>>
                                                  <%= dept.getName() %>
                                                </option>
                                                <% } } %>
                                            </select>

                                            <!-- Position Filter -->
                                            <span class="bs-filter-label">Chức vụ</span>
                                            <select name="positionId" class="bs-select"
                                              onchange="document.getElementById('filterForm').submit()">
                                              <option value="">Tất cả</option>
                                              <% if (positions !=null) { for (Positions pos : positions) { boolean
                                                isSelected=selectedPosId !=null && selectedPosId.equals(pos.getId()); %>
                                                <option value="<%= pos.getId() %>" <%=isSelected ? "selected" : "" %>>
                                                  <%= pos.getName() %>
                                                </option>
                                                <% } } %>
                                            </select>

                                            <!-- Hidden Page preservation -->
                                            <input type="hidden" name="page" value="1" />
                                            <input type="hidden" name="pageSize" value="<%= pageSize %>" />
                                          </form>
                                        </div>

                                        <!-- Data Table -->
                                        <div class="bs-table-card">
                                          <table class="bs-table">
                                            <thead>
                                              <tr>
                                                <th>MÃ NV <span class="sort-caret">^</span></th>
                                                <th>HỌ VÀ TÊN <span class="sort-caret">^</span></th>
                                                <th>PHÒNG BAN <span class="sort-caret">^</span></th>
                                                <th>CHỨC VỤ <span class="sort-caret">^</span></th>
                                                <th>LƯƠNG CƠ BẢN <span class="sort-caret">^</span></th>
                                                <th>HÀNH ĐỘNG</th>
                                              </tr>
                                            </thead>
                                            <tbody>
                                              <% if (baseSalaries !=null && !baseSalaries.isEmpty()) { String[]
                                                colors={"#f87171", "#fb923c" , "#fbbf24" , "#34d399" , "#60a5fa"
                                                , "#a78bfa" , "#f472b6" }; for (BaseSalaryDTO item : baseSalaries) {
                                                String fullName=item.getFullName() !=null ? item.getFullName() : "" ;
                                                String firstChar=(!fullName.trim().isEmpty()) ?
                                                fullName.trim().substring(0, 1).toUpperCase() : "N" ; int
                                                colorIdx=Math.abs(fullName.hashCode()) % colors.length; String
                                                avatarColor=colors[colorIdx]; String code=item.getEmployeeCode() !=null
                                                ? item.getEmployeeCode() : "" ; String dept=item.getDepartmentName()
                                                !=null ? item.getDepartmentName() : "Chưa phân công" ; String
                                                pos=item.getPositionName() !=null ? item.getPositionName()
                                                : "Chưa phân công" ; String
                                                formattedSalary=item.getFormattedBaseSalary() + " đ" ; double
                                                rawSalary=item.getBaseSalary() !=null ?
                                                item.getBaseSalary().doubleValue() : 0; %>
                                                <tr>
                                                  <td class="emp-code-text">
                                                    <%= code %>
                                                  </td>
                                                  <td>
                                                    <div class="emp-user-cell">
                                                      <div class="emp-avatar-circle"
                                                        style="background-color: <%= avatarColor %>;">
                                                        <%= firstChar %>
                                                      </div>
                                                      <span class="emp-name-text">
                                                        <%= fullName %>
                                                      </span>
                                                    </div>
                                                  </td>
                                                  <td>
                                                    <span class="dept-badge">
                                                      <%= dept %>
                                                    </span>
                                                  </td>
                                                  <td class="pos-text">
                                                    <%= pos %>
                                                  </td>
                                                  <td class="salary-text">
                                                    <%= formattedSalary %>
                                                  </td>
                                                  <td>
                                                    <button type="button" class="btn-edit-outline"
                                                      onclick="openEditModal(<%= item.getUserId() %>, '<%= code %>', '<%= fullName.replace("'", "\\'") %>', '<%= dept.replace("'", "\\'") %>', '<%= pos.replace("'", "\\'") %>', <%= rawSalary %>)">
                                                      <svg width="13" height="13" viewBox="0 0 24 24" fill="none"
                                                        stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                                        stroke-linejoin="round">
                                                        <path d="M12 20h9"></path>
                                                        <path
                                                          d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z">
                                                        </path>
                                                      </svg>
                                                      Chỉnh sửa
                                                    </button>
                                                  </td>
                                                </tr>
                                                <% } } else { %>
                                                  <tr>
                                                    <td colspan="6"
                                                      style="text-align: center; padding: 40px; color: #64748b;">
                                                      Không tìm thấy dữ liệu nhân viên nào phù hợp.
                                                    </td>
                                                  </tr>
                                                  <% } %>
                                            </tbody>
                                          </table>

                                          <!-- Pagination Footer -->
                                          <div class="bs-pagination-bar">
                                            <div class="bs-pagination-info">
                                              <span>Hiển thị <strong>
                                                  <%= startItem %>-<%= endItem %>
                                                </strong> / <%= totalFilteredItems %> nhân viên</span>
                                              <span>Mỗi trang
                                                <select class="bs-page-size-select"
                                                  onchange="changePageSize(this.value)">
                                                  <option value="5" <%=pageSize==5 ? "selected" : "" %>>5</option>
                                                  <option value="10" <%=pageSize==10 ? "selected" : "" %>>10</option>
                                                  <option value="20" <%=pageSize==20 ? "selected" : "" %>>20</option>
                                                </select>
                                              </span>
                                            </div>

                                            <div class="bs-pagination-controls">
                                              <!-- Previous page button -->
                                              <a href="<%= buildPageUrl(searchStr, selectedDeptId, selectedPosId, currentPage - 1, pageSize) %>"
                                                class="bs-page-nav-btn <%= currentPage <= 1 ? " disabled" : ""
                                                %>">&lt;</a>

                                              <!-- Page numbers -->
                                              <% for (int p=1; p <=totalPages; p++) { %>
                                                <a href="<%= buildPageUrl(searchStr, selectedDeptId, selectedPosId, p, pageSize) %>"
                                                  class="bs-page-btn <%= p == currentPage ? " active" : "" %>"><%= p %>
                                                    </a>
                                                <% } %>

                                                  <!-- Next page button -->
                                                  <a href="<%= buildPageUrl(searchStr, selectedDeptId, selectedPosId, currentPage + 1, pageSize) %>"
                                                    class="bs-page-nav-btn <%= currentPage >= totalPages ? " disabled"
                                                    : "" %>">&gt;</a>
                                            </div>
                                          </div>
                                        </div>
                                      </div>

                                      <!-- FOOTER -->
                                      <footer>© 2026 Hệ thống Quản lý Nhân sự (EMS) · FPT University SWP391</footer>
                                    </div>

                                    <!-- EDIT MODAL FORM (Image 2 UI) -->
                                    <div class="modal-overlay" id="salaryModal">
                                      <div class="modal-card">
                                        <button type="button" class="modal-close-btn"
                                          onclick="closeEditModal()">✕</button>

                                        <div class="modal-title">Chỉnh sửa thông tin lương</div>
                                        <div class="modal-subtitle" id="modalSubtitle">NV001 · Nguyễn Văn An</div>

                                        <!-- Read-only Dept & Pos -->
                                        <div class="modal-info-box">
                                          <div class="modal-info-item">
                                            <label>Phòng ban</label>
                                            <span id="modalDept">Kỹ thuật</span>
                                          </div>
                                          <div class="modal-info-item">
                                            <label>Chức vụ</label>
                                            <span id="modalPos">Trưởng nhóm</span>
                                          </div>
                                        </div>

                                        <!-- Form -->
                                        <form action="base-salaries" method="POST" id="editForm"
                                          onsubmit="return confirm('Bạn có chắc chắn muốn thay đổi không?');">
                                          <input type="hidden" name="userId" id="editUserId" value="" />
                                          <input type="hidden" name="search" value="<%= searchStr %>" />
                                          <% if (selectedDeptId !=null) { %><input type="hidden" name="departmentId"
                                              value="<%= selectedDeptId %>" />
                                            <% } %>
                                              <% if (selectedPosId !=null) { %><input type="hidden" name="positionId"
                                                  value="<%= selectedPosId %>" />
                                                <% } %>
                                                  <input type="hidden" name="page" value="<%= currentPage %>" />

                                                  <!-- Base Salary Input -->
                                                  <div class="modal-form-group">
                                                    <label for="editBaseSalary">Lương cơ bản (Base Salary)</label>
                                                    <div class="currency-input-wrapper">
                                                      <input type="number" id="editBaseSalary" name="baseSalary"
                                                        required step="100000" min="0" value="22000000" />
                                                      <span class="currency-suffix">đ</span>
                                                    </div>
                                                  </div>

                                                  <!-- Action Buttons -->
                                                  <div class="modal-footer">
                                                    <button type="button" class="btn-modal-cancel"
                                                      onclick="closeEditModal()">Huỷ</button>
                                                    <button type="submit" class="btn-modal-save">Lưu thay đổi</button>
                                                  </div>
                                        </form>
                                      </div>
                                    </div>

                                    <script>
                                      // Topbar date script
                                      function tick() {
                                        var now = new Date();
                                        var p = function (n) { return String(n).padStart(2, '0'); };
                                        var el = document.getElementById('topbar-date');
                                        if (el) {
                                          el.textContent = p(now.getDate()) + '/' + p(now.getMonth() + 1) + '/' + now.getFullYear();
                                        }
                                      }
                                      tick();

                                      // Modal Functions
                                      function openEditModal(userId, code, name, dept, pos, salary) {
                                        document.getElementById('editUserId').value = userId;
                                        document.getElementById('modalSubtitle').textContent = code + ' · ' + name;
                                        document.getElementById('modalDept').textContent = dept || 'Chưa phân công';
                                        document.getElementById('modalPos').textContent = pos || 'Chưa phân công';
                                        document.getElementById('editBaseSalary').value = Math.round(salary);

                                        var modal = document.getElementById('salaryModal');
                                        modal.style.display = 'flex';
                                      }

                                      function closeEditModal() {
                                        var modal = document.getElementById('salaryModal');
                                        modal.style.display = 'none';
                                      }

                                      // Change page size function
                                      function changePageSize(newSize) {
                                        var search = encodeURIComponent('<%= searchStr %>');
                                        var deptId = '<%= selectedDeptId != null ? selectedDeptId : "" %>';
                                        var posId = '<%= selectedPosId != null ? selectedPosId : "" %>';
                                        var url = 'base-salaries?page=1&pageSize=' + newSize;
                                        if (search) url += '&search=' + search;
                                        if (deptId) url += '&departmentId=' + deptId;
                                        if (posId) url += '&positionId=' + posId;
                                        window.location.href = url;
                                      }

                                      // Close modal when clicking outside modal-card
                                      window.onclick = function (event) {
                                        var modal = document.getElementById('salaryModal');
                                        if (event.target === modal) {
                                          closeEditModal();
                                        }
                                      };
                                    </script>

                                  </body>

                                </html>