<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.util.List" %>
        <%@ page import="com.ems.dto.EmployeeBalanceDTO" %>
            <% List<EmployeeBalanceDTO> balances = (List<EmployeeBalanceDTO>) request.getAttribute("balances");
                    if (balances == null) {
                    response.sendRedirect(request.getContextPath() + "/requests?action=employeeBalances");
                    return;
                    }
                    %>
                    <!DOCTYPE html>
                    <html lang="vi">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>EMS - Trạng thái phép & ứng lương</title>
                        <link rel="stylesheet" href="<%= request.getContextPath() %>/css/ems.css">
                        <style>
                            .balance-value {
                                font-weight: 600;
                                color: #111827;
                            }

                            .balance-remaining {
                                color: #059669;
                                font-weight: 700;
                            }

                            .balance-advance {
                                color: #dc2626;
                                font-weight: 700;
                            }

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
                            }

                            /* Pagination CSS */
                            .page-nav-btn,
                            .page-num-btn {
                                padding: 6px 12px;
                                border: 1px solid #e5e7eb;
                                border-radius: 6px;
                                background: #ffffff;
                                color: #374151;
                                font-size: 13px;
                                font-weight: 500;
                                cursor: pointer;
                                transition: all 0.15s ease;
                                outline: none;
                            }

                            .page-nav-btn:hover:not(:disabled),
                            .page-num-btn:hover:not(.active) {
                                background: #f3f4f6;
                                border-color: #d1d5db;
                            }

                            .page-nav-btn:disabled {
                                opacity: 0.4;
                                cursor: not-allowed;
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
                                <div class="topbar">
                                    <span class="topbar-left">Trạng thái nhân sự</span>
                                    <span class="topbar-right" id="topbar-date"></span>
                                </div>
                                <div class="page-body">
                                    <div class="page-header">
                                        <h1>Theo dõi phép & ứng lương</h1>
                                        <p>Theo dõi số ngày phép còn lại và tổng tiền ứng lương trong tháng này của từng
                                            nhân viên.</p>
                                    </div>
                                    <section class="card">
                                        <div class="card-header"
                                            style="display: flex; justify-content: space-between; align-items: center;">
                                            <div>
                                                <span>Trạng thái phép & ứng lương</span>
                                                <span class="badge badge-active" id="staffCountBadge">
                                                    <%= balances.size() %> nhân sự
                                                </span>
                                            </div>
                                            <div style="display: flex; align-items: center; gap: 8px;">
                                                <input type="text" id="searchInput"
                                                    placeholder="Tìm theo tên nhân viên..."
                                                    oninput="filterTable(this.value)"
                                                    style="padding: 6px 12px; border: 1px solid #d1d5db; border-radius: 6px; font-size: 13px; outline: none; width: 220px;">
                                            </div>
                                        </div>
                                        <% if (balances.isEmpty()) { %>
                                            <div style="padding: 48px 20px; text-align: center; color: #6b7280;">
                                                <strong>Không có dữ liệu nhân sự.</strong>
                                            </div>
                                            <% } else { %>
                                                <div class="table-wrap">
                                                    <table>
                                                        <thead>
                                                            <tr>
                                                                <th>Nhân viên</th>
                                                                <th>Phòng ban</th>
                                                                <th style="text-align: center;">Phép còn lại</th>
                                                                <th style="text-align: right;">Ứng còn lại tháng này</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <% java.text.NumberFormat
                                                                curFormat=java.text.NumberFormat.getIntegerInstance(new
                                                                java.util.Locale("vi", "VN" )); for (EmployeeBalanceDTO
                                                                item : balances) { %>
                                                                <tr class="staff-row">
                                                                    <td><strong style="color: #111827;">
                                                                            <%= item.getEmployeeName() %>
                                                                        </strong></td>
                                                                    <td>
                                                                        <%= item.getDepartmentName() !=null ?
                                                                            item.getDepartmentName() : "Chưa xếp phòng"
                                                                            %>
                                                                    </td>
                                                                    <td style="text-align: center;"
                                                                        class="balance-remaining">
                                                                        <%= item.getRemainingDays() %> ngày
                                                                    </td>
                                                                    <td style="text-align: right;"
                                                                        class="balance-advance">
                                                                        <%
                                                                            double remainingAdvance = Math.max(0.0, (item.getBaseSalary() * 0.5) - item.getAdvancedThisMonth());
                                                                        %>
                                                                        <%= remainingAdvance > 0 ?
                                                                            curFormat.format(remainingAdvance) + " đ" : "0 đ" %>
                                                                    </td>
                                                                </tr>
                                                                <% } %>
                                                        </tbody>
                                                    </table>
                                                </div>
                                                <!-- Pagination Container -->
                                                <div class="pagination-container"
                                                    style="display: flex; justify-content: space-between; align-items: center; padding: 14px 18px; border-top: 1px solid #f3f4f6; font-size: 13px; color: #6b7280; flex-wrap: wrap; gap: 10px;">
                                                    <div id="paginationInfo">Hiển thị 0 - 0 / 0 nhân sự</div>
                                                    <div id="paginationControls"
                                                        style="display: flex; gap: 6px; align-items: center;"></div>
                                                </div>
                                                <% } %>
                                    </section>
                                </div>
                                <footer>© 2026 Hệ thống Quản lý Nhân sự (EMS) · FPT University SWP391</footer>
                            </main>
                            <script>
                                (function () {
                                    var now = new Date(), pad = function (n) { return String(n).padStart(2, '0'); };
                                    document.getElementById('topbar-date').textContent = pad(now.getDate()) + '/' + pad(now.getMonth() + 1) + '/' + now.getFullYear();
                                }());

                                const PAGE_SIZE = 10;
                                let currentPage = 1;
                                let filteredRows = [];

                                function filterTable(keyword) {
                                    var kw = keyword.trim().toLowerCase();
                                    var allRows = Array.from(document.querySelectorAll('tbody .staff-row'));

                                    filteredRows = allRows.filter(function (row) {
                                        var name = row.querySelector('td:first-child').textContent.toLowerCase();
                                        var dept = row.querySelector('td:nth-child(2)').textContent.toLowerCase();
                                        return kw === '' || name.includes(kw) || dept.includes(kw);
                                    });

                                    currentPage = 1;
                                    renderPagination();
                                }

                                function renderPagination() {
                                    var allRows = document.querySelectorAll('tbody .staff-row');
                                    allRows.forEach(function (r) { r.style.display = 'none'; });

                                    var total = filteredRows.length;
                                    var totalPages = Math.ceil(total / PAGE_SIZE) || 1;

                                    if (currentPage > totalPages) currentPage = totalPages;
                                    if (currentPage < 1) currentPage = 1;

                                    var startIdx = (currentPage - 1) * PAGE_SIZE;
                                    var endIdx = Math.min(startIdx + PAGE_SIZE, total);

                                    for (var i = startIdx; i < endIdx; i++) {
                                        filteredRows[i].style.display = '';
                                    }

                                    // Cập nhật số lượng nhân sự hiển thị trên badge
                                    var staffBadge = document.getElementById('staffCountBadge');
                                    if (staffBadge) {
                                        staffBadge.textContent = total + ' nhân sự';
                                    }

                                    var infoEl = document.getElementById('paginationInfo');
                                    if (infoEl) {
                                        if (total === 0) {
                                            infoEl.textContent = 'Không tìm thấy nhân viên nào phù hợp';
                                        } else {
                                            infoEl.textContent = 'Hiển thị ' + (startIdx + 1) + ' - ' + endIdx + ' trên tổng số ' + total + ' nhân sự';
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
                                    prevBtn.onclick = function () {
                                        if (currentPage > 1) {
                                            currentPage--;
                                            renderPagination();
                                        }
                                    };
                                    controlsEl.appendChild(prevBtn);

                                    // Các trang số
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
                                        pageBtn.onclick = (function (page) {
                                            return function () {
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
                                    nextBtn.onclick = function () {
                                        if (currentPage < totalPages) {
                                            currentPage++;
                                            renderPagination();
                                        }
                                    };
                                    controlsEl.appendChild(nextBtn);
                                }

                                // Khởi tạo chạy lần đầu
                                document.addEventListener("DOMContentLoaded", function () {
                                    filterTable('');
                                });
                            </script>
                    </body>

                    </html>