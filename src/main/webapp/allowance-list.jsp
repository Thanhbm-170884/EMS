<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
            <%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8" />
                    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                    <title>Quản lý Phụ Cấp – EMS</title>
                    <link rel="stylesheet" href="css/ems.css" />
                    <link rel="stylesheet" href="css/allowance-list.css" />
                    <link rel="preconnect" href="https://fonts.googleapis.com">
                    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                        rel="stylesheet">
                </head>

                <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>

                    <body>
                        <div class="main-content">
                            <div class="topbar">
                                <span class="topbar-left"><a href="home_manager.jsp"
                                        style="color:inherit;text-decoration:none;">Trang chủ</a> / <a
                                        href="salary-management" style="color:inherit;text-decoration:none;">Quản lý
                                        lương</a> / Quản lý phụ cấp</span>
                                <span class="topbar-right" id="topbar-date"></span>
                            </div>

                            <div class="page-body">

                                <c:if test="${not empty sessionScope.successMsg}">
                                    <div class="alert-box alert-success" id="alertSuccess">
                                        <span>${sessionScope.successMsg}</span>
                                        <button class="close-alert"
                                            onclick="document.getElementById('alertSuccess').style.display='none'">✕</button>
                                    </div>
                                    <c:remove var="successMsg" scope="session" />
                                </c:if>
                                <c:if test="${not empty sessionScope.errorMsg}">
                                    <div class="alert-box alert-danger" id="alertError">
                                        <span>${sessionScope.errorMsg}</span>
                                        <button class="close-alert"
                                            onclick="document.getElementById('alertError').style.display='none'">✕</button>
                                    </div>
                                    <c:remove var="errorMsg" scope="session" />
                                </c:if>

                                <!-- Header Section -->
                                <div class="al-header">
                                    <div>
                                        <h1>Danh mục Phụ Cấp (Allowances)</h1>
                                        <p>Thiết lập danh mục phụ cấp, định mức, và các quy định tính thuế TNCN, đóng
                                            BHXH</p>
                                    </div>

                                </div>

                                <!-- Filter Toolbar -->
                                <div class="al-filter-card">
                                    <form action="${pageContext.request.contextPath}/allowances" method="GET"
                                        class="al-filter-form">
                                        <div class="al-search-wrapper">
                                            <svg class="al-search-icon" width="16" height="16" viewBox="0 0 24 24"
                                                fill="none" stroke="currentColor" stroke-width="2"
                                                stroke-linecap="round" stroke-linejoin="round">
                                                <circle cx="11" cy="11" r="8"></circle>
                                                <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                                            </svg>
                                            <input type="text" name="keyword" class="al-input"
                                                placeholder="Tìm theo Mã hoặc Tên phụ cấp..." value="${keyword}">
                                        </div>
                                        <button type="submit" class="al-btn-search">
                                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none"
                                                stroke="currentColor" stroke-width="2.5" stroke-linecap="round"
                                                stroke-linejoin="round">
                                                <circle cx="11" cy="11" r="8"></circle>
                                                <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                                            </svg>
                                            Tìm kiếm
                                        </button>
                                    </form>
                                </div>

                                <!-- Table -->
                                <div class="al-table-card">
                                    <table class="al-table">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>MÃ PC</th>
                                                <th>TÊN PHỤ CẤP</th>
                                                <th>LOẠI</th>
                                                <th>MỨC TIỀN</th>
                                                <th>HẠN MỨC TÍNH THUẾ</th>
                                                <th>ĐÓNG BHXH?</th>
                                                <th>TRẠNG THÁI</th>
                                                <th style="text-align: right; padding-right: 24px;">HÀNH ĐỘNG</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="item" items="${allowances}">
                                                <tr>
                                                    <td class="text-muted">#${item.id}</td>
                                                    <td><span class="allowance-code-text">${item.code}</span></td>
                                                    <td><span class="allowance-name-text">${item.name}</span></td>
                                                    <td>
                                                        ${item.type == 'Allowance' ? 'Phụ cấp (+)' : 'Khấu trừ (-)'}<br>
                                                        <span class="text-muted">${item.calculationmethod}</span>
                                                    </td>
                                                    <td>
                                                        <fmt:setLocale value="vi_VN" />
                                                        <fmt:formatNumber value="${item.defaultamount}" type="currency"
                                                            currencySymbol="VNĐ" />
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${item.istaxable}">
                                                                <span class="text-danger">Có</span>
                                                                <span class="text-muted">(Miễn:
                                                                    <fmt:formatNumber value="${item.taxexemptlimit}"
                                                                        type="number" /> đ)
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-success fw-bold">Miễn thuế 100%</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${item.isinsurancesalary}">
                                                                <span class="badge-status-pill badge-yes">Có</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge-status-pill badge-no">Không</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${item.isactive}">
                                                                <span class="badge-status-pill badge-active">Hoạt
                                                                    động</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge-status-pill badge-paused">Tạm
                                                                    dừng</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <div class="action-group" style="justify-content: flex-end;">
                                                            <!-- Edit Button -->
                                                            <button type="button" class="btn-action-edit"
                                                                data-id="${item.id}" data-code="${item.code}"
                                                                data-name="${fn:escapeXml(item.name)}"
                                                                data-type="${item.type}"
                                                                data-calc="${item.calculationmethod}"
                                                                data-amount="${item.defaultamount}"
                                                                data-taxlimit="${item.taxexemptlimit}"
                                                                data-taxable="${item.istaxable}"
                                                                data-insurance="${item.isinsurancesalary}"
                                                                data-active="${item.isactive}"
                                                                onclick="openEditModal(this)">
                                                                <svg width="13" height="13" viewBox="0 0 24 24"
                                                                    fill="none" stroke="currentColor" stroke-width="2">
                                                                    <path d="M12 20h9" />
                                                                    <path
                                                                        d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z" />
                                                                </svg>
                                                                Sửa
                                                            </button>


                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                            <c:if test="${empty allowances}">
                                                <tr>
                                                    <td colspan="9"
                                                        style="text-align: center; padding: 40px; color: #64748b;">
                                                        Không tìm thấy dữ liệu phụ cấp nào!
                                                    </td>
                                                </tr>
                                            </c:if>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                            <!-- FOOTER -->
                            <footer>© 2026 Hệ thống Quản lý Nhân sự (EMS) · FPT University SWP391</footer>
                        </div>


                        <!-- Modal Add -->
                        <div class="modal-overlay" id="addModal">
                            <div class="modal-card">
                                <button type="button" class="modal-close-btn" onclick="closeAddModal()">✕</button>
                                <div class="modal-title">Thêm Mới Phụ Cấp</div>
                                <div class="modal-subtitle">Tạo khoản phụ cấp hoặc khấu trừ mới cho hệ thống</div>

                                <form action="${pageContext.request.contextPath}/allowances" method="POST">
                                    <input type="hidden" name="action" value="add">

                                    <div class="modal-grid-1-2">
                                        <div class="modal-form-group">
                                            <label>Mã Phụ Cấp (Unique)</label>
                                            <input type="text" name="code" required pattern=".*\S+.*" title="Vui lòng nhập định dạng hợp lệ, không thể chỉ chứa khoảng trắng" placeholder="VD: PC_AN_TRUA">
                                        </div>
                                        <div class="modal-form-group">
                                            <label>Tên Phụ Cấp</label>
                                            <input type="text" name="name" required pattern=".*\S+.*" title="Vui lòng nhập định dạng hợp lệ, không thể chỉ chứa khoảng trắng" placeholder="VD: Phụ cấp ăn trưa">
                                        </div>
                                    </div>

                                    <div class="modal-grid-2">
                                        <div class="modal-form-group">
                                            <label>Loại (Type)</label>
                                            <select name="type">
                                                <option value="Allowance">Cộng thêm (Allowance)</option>
                                                <option value="Deduction">Giảm trừ (Deduction)</option>
                                            </select>
                                        </div>
                                        <div class="modal-form-group">
                                            <label>Phương thức tính</label>
                                            <select name="calculationmethod">
                                                <option value="Fixed">Cố định tháng (Fixed)</option>
                                                <option value="ByWorkDay">Theo ngày công (ByWorkDay)</option>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="modal-grid-2">
                                        <div class="modal-form-group">
                                            <label>Số tiền mặc định (VNĐ)</label>
                                            <input type="number" name="defaultamount" value="0" min="0" required>
                                        </div>
                                        <div class="modal-form-group">
                                            <label>Hạn mức miễn thuế TNCN (VNĐ)</label>
                                            <input type="number" name="taxexemptlimit" value="0" min="0" required>
                                            <span style="font-size: 11.5px; color: #64748b;">Nhập 0 nếu không có hạn
                                                mức.</span>
                                        </div>
                                    </div>

                                    <div class="modal-form-group" style="margin-top:20px;">
                                        <label class="checkbox-label">
                                            <input type="checkbox" name="istaxable" value="true" checked>
                                            <span>Khoản này BỊ tính Thuế TNCN (Is Taxable)</span>
                                        </label>
                                        <label class="checkbox-label">
                                            <input type="checkbox" name="isinsurancesalary" value="true">
                                            <span>Khoản này BỊ tính vào Lương đóng BHXH</span>
                                        </label>
                                        <label class="checkbox-label">
                                            <input type="checkbox" name="isactive" value="true" checked>
                                            <span>Kích hoạt áp dụng ngay (Is Active)</span>
                                        </label>
                                    </div>

                                    <div class="modal-footer">
                                        <button type="button" class="btn-modal-cancel"
                                            onclick="closeAddModal()">Hủy</button>
                                        <button type="submit" class="btn-modal-save">Lưu Phụ Cấp</button>
                                    </div>
                                </form>
                            </div>
                        </div>


                        <!-- MODAL: EDIT ALLOWANCE -->
                        <div class="modal-overlay" id="editModal">
                            <div class="modal-card">
                                <button type="button" class="modal-close-btn" onclick="closeEditModal()">✕</button>
                                <div class="modal-title warning">Cập Nhật Phụ Cấp</div>
                                <div class="modal-subtitle">Chỉnh sửa thông tin, định mức cho phụ cấp <strong
                                        id="displayEditCode"></strong></div>

                                <form action="${pageContext.request.contextPath}/allowances" method="POST">
                                    <input type="hidden" name="action" value="edit">
                                    <input type="hidden" name="id" id="edit_id">
                                    <input type="hidden" name="keyword" value="${keyword}">

                                    <div class="modal-grid-1-2">
                                        <div class="modal-form-group">
                                            <label>Mã Phụ Cấp (Không đổi)</label>
                                            <input type="text" name="code" id="edit_code" readonly>
                                        </div>
                                        <div class="modal-form-group">
                                            <label>Tên Phụ Cấp</label>
                                            <input type="text" name="name" id="edit_name" required pattern=".*\S+.*" title="Vui lòng nhập định dạng hợp lệ, không thể chỉ chứa khoảng trắng">
                                        </div>
                                    </div>

                                    <div class="modal-grid-2">
                                        <div class="modal-form-group">
                                            <label>Loại (Type)</label>
                                            <select name="type" id="edit_type">
                                                <option value="Allowance">Cộng thêm (Allowance)</option>
                                                <option value="Deduction">Giảm trừ (Deduction)</option>
                                            </select>
                                        </div>
                                        <div class="modal-form-group">
                                            <label>Phương thức tính</label>
                                            <select name="calculationmethod" id="edit_calc">
                                                <option value="Fixed">Cố định tháng (Fixed)</option>
                                                <option value="ByWorkDay">Theo ngày công (ByWorkDay)</option>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="modal-grid-2">
                                        <div class="modal-form-group">
                                            <label>Số tiền mặc định (VNĐ)</label>
                                            <input type="number" name="defaultamount" id="edit_amount" min="0" required>
                                        </div>
                                        <div class="modal-form-group">
                                            <label>Hạn mức miễn thuế TNCN (VNĐ)</label>
                                            <input type="number" name="taxexemptlimit" id="edit_taxlimit" min="0"
                                                required>
                                            <span style="font-size: 11.5px; color: #64748b;">Nhập 0 nếu không có hạn
                                                mức.</span>
                                        </div>
                                    </div>

                                    <div class="modal-form-group" style="margin-top:20px;">
                                        <label class="checkbox-label">
                                            <input type="checkbox" name="istaxable" id="edit_taxable" value="true">
                                            <span>Khoản này BỊ tính Thuế TNCN (Is Taxable)</span>
                                        </label>
                                        <label class="checkbox-label">
                                            <input type="checkbox" name="isinsurancesalary" id="edit_insurance"
                                                value="true">
                                            <span>Khoản này BỊ tính vào Lương đóng BHXH</span>
                                        </label>
                                        <label class="checkbox-label">
                                            <input type="checkbox" name="isactive" id="edit_active" value="true">
                                            <span>Kích hoạt áp dụng (Is Active)</span>
                                        </label>
                                    </div>

                                    <div class="modal-footer">
                                        <button type="button" class="btn-modal-cancel"
                                            onclick="closeEditModal()">Hủy</button>
                                        <button type="submit" class="btn-modal-update">Cập Nhật</button>
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

                            /* Layout & Modal Scripts */
                            function openAddModal() {
                                document.getElementById('addModal').style.display = 'flex';
                            }
                            function closeAddModal() {
                                document.getElementById('addModal').style.display = 'none';
                            }

                            function openEditModal(btn) {
                                document.getElementById('edit_id').value = btn.getAttribute('data-id');
                                document.getElementById('displayEditCode').innerText = btn.getAttribute('data-code');
                                document.getElementById('edit_code').value = btn.getAttribute('data-code');
                                document.getElementById('edit_name').value = btn.getAttribute('data-name');

                                document.getElementById('edit_type').value = btn.getAttribute('data-type');
                                document.getElementById('edit_calc').value = btn.getAttribute('data-calc');
                                document.getElementById('edit_amount').value = btn.getAttribute('data-amount');
                                document.getElementById('edit_taxlimit').value = btn.getAttribute('data-taxlimit');

                                document.getElementById('edit_taxable').checked = btn.getAttribute('data-taxable') === 'true';
                                document.getElementById('edit_insurance').checked = btn.getAttribute('data-insurance') === 'true';
                                document.getElementById('edit_active').checked = btn.getAttribute('data-active') === 'true';

                                document.getElementById('editModal').style.display = 'flex';
                            }
                            function closeEditModal() {
                                document.getElementById('editModal').style.display = 'none';
                            }



                            window.onclick = function (event) {
                                var addM = document.getElementById('addModal');
                                var editM = document.getElementById('editModal');
                                if (event.target === addM) closeAddModal();
                                if (event.target === editM) closeEditModal();
                            }
                        </script>
                    </body>

                </html>