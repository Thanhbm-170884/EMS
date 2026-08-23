<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Cấu hình Tham số Lương – EMS</title>
    <link rel="stylesheet" href="css/ems.css" />
    <link rel="stylesheet" href="css/payroll-config.css" />
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>

<%@ include file="/WEB-INF/jspf/sidebar.jsp" %>

<body>
<div class="main-content">
    <div class="topbar">
        <span class="topbar-left"><a href="home_manager.jsp" style="color:inherit;text-decoration:none;">Trang chủ</a> / <a href="salary-management" style="color:inherit;text-decoration:none;">Quản lý lương</a> / Cấu hình Tham số Lương</span>
        <span class="topbar-right" id="topbar-date"></span>
    </div>

    <div class="page-body">

        <!-- Thông báo lỗi -->
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert-box alert-danger" id="alertError">
                <span>${sessionScope.errorMessage}</span>
                <button type="button" class="close-alert" onclick="document.getElementById('alertError').style.display='none'">✕</button>
            </div>
            <c:remove var="errorMessage" scope="session" />
        </c:if>

        <!-- Header Section -->
        <div class="pc-header">
            <div>
                <h1>Lịch sử Cấu hình Lương (Payroll Config)</h1>
                <p>Thiết lập các tham số lương, tỷ lệ bảo hiểm xã hội, mức giảm trừ gia cảnh và biến động hệ số OT.</p>
            </div>
            <button type="button" class="btn-create-config" onclick="openAddModal()">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                    <line x1="12" y1="5" x2="12" y2="19"></line>
                    <line x1="5" y1="12" x2="19" y2="12"></line>
                </svg>
                Tạo Đợt Cấu Hình Mới
            </button>
        </div>

        <!-- Table -->
        <div class="pc-table-card">
            <table class="pc-table">
                <thead>
                    <tr>
                        <th>Tên Cấu Hình</th>
                        <th>Ngày Áp Dụng</th>
                        <th>Ngày Công</th>
                        <th>Tỷ lệ BH (XH-YT-TN)</th>
                        <th>Giảm trừ (Bản thân - NPT)</th>
                        <th>OT (Ngày - Nghỉ - Lễ)</th>
                        <th>Trạng Thái</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="item" items="${historyList}">
                        <tr class="${item.isactive ? 'active-row' : ''}">
                            <td class="fw-bold" style="${item.isactive ? 'color:#9333ea;' : ''}">${item.configname}</td>
                            <td>${item.effectivedate}</td>
                            <td>${item.standardworkingdays} ngày</td>
                            <td>
                                ${item.bhxhpercent}% - ${item.bhytpercent}% - ${item.bhtnpercent}%
                            </td>
                            <td>
                                <fmt:setLocale value="vi_VN"/>
                                <fmt:formatNumber value="${item.personaltaxdeduction}" type="number"/> đ <br>
                                <span class="text-muted"><fmt:formatNumber value="${item.dependenttaxdeduction}" type="number"/> đ / NPT</span>
                            </td>
                            <td>
                                x${item.otweekdayrate} - x${item.otweekendrate} - x${item.otholidayrate}
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${item.isactive}">
                                        <span class="badge-status-pill badge-active">✔ Đang áp dụng</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge-status-pill badge-history">Lịch sử cũ</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty historyList}">
                        <tr>
                            <td colspan="7" style="text-align: center; padding: 40px; color: #64748b;">
                                Không tìm thấy dữ liệu cấu hình nào!
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
<div class="modal-overlay" id="addConfigModal">
    <div class="modal-card">
        <button type="button" class="modal-close-btn" onclick="closeAddModal()">✕</button>
        <div class="modal-title">Tạo Đợt Cấu Hình Lương Mới</div>
        <div class="modal-subtitle">Thêm mới cấu hình lương để theo kịp các thay đổi chính sách từ nhà nước</div>

        <div class="modal-alert">
            <strong>Lưu ý:</strong> Khi tích chọn "Áp dụng cấu hình này", các cấu hình cũ sẽ tự động chuyển về trạng thái Lịch sử cũ.
        </div>

        <form action="${pageContext.request.contextPath}/payroll-configs" method="POST">
            
            <div class="modal-section-title">1. Thông tin đợt áp dụng</div>
            <div class="modal-grid-3">
                <div class="modal-form-group">
                    <label>Tên đợt cấu hình</label>
                    <input type="text" name="configname" required pattern=".*\S+.*" title="Vui lòng nhập định dạng hợp lệ, không thể chỉ chứa khoảng trắng" placeholder="VD: Luật Thuế 2026">
                </div>
                <div class="modal-form-group">
                    <label>Ngày bắt đầu áp dụng</label>
                    <input type="date" name="effectivedate" required>
                </div>
                <div class="modal-form-group">
                    <label>Ngày công chuẩn / tháng</label>
                    <input type="number" name="standardworkingdays" value="22" min="1" max="31" required>
                </div>
            </div>

            <div class="modal-section-title">2. Tham số Bảo Hiểm (Người lao động đóng)</div>
            <div class="modal-grid-4">
                <div class="modal-form-group">
                    <label>Tỷ lệ BHXH (%)</label>
                    <input type="number" step="0.01" name="bhxhpercent" value="8.00" required>
                </div>
                <div class="modal-form-group">
                    <label>Tỷ lệ BHYT (%)</label>
                    <input type="number" step="0.01" name="bhytpercent" value="1.50" required>
                </div>
                <div class="modal-form-group">
                    <label>Tỷ lệ BHTN (%)</label>
                    <input type="number" step="0.01" name="bhtnpercent" value="1.00" required>
                </div>
                <div class="modal-form-group">
                    <label>Lương trần đóng BH</label>
                    <input type="number" name="maxinsurancesalary" value="46800000" required>
                </div>
            </div>

            <div class="modal-grid-2">
                <div>
                    <div class="modal-section-title">3. Mức Giảm Trừ Gia Cảnh</div>
                    <div class="modal-form-group">
                        <label>Giảm trừ Bản thân (VNĐ)</label>
                        <input type="number" name="personaltaxdeduction" value="11000000" required>
                    </div>
                    <div class="modal-form-group">
                        <label>Giảm trừ Người phụ thuộc (VNĐ)</label>
                        <input type="number" name="dependenttaxdeduction" value="4400000" required>
                    </div>
                </div>

                <div>
                    <div class="modal-section-title">4. Hệ Số Phụ Cấp Làm Thêm Giờ (OT)</div>
                    <div class="modal-grid-3">
                        <div class="modal-form-group">
                            <label>Ngày thường</label>
                            <input type="number" step="0.1" name="otweekdayrate" value="1.5" required>
                        </div>
                        <div class="modal-form-group">
                            <label>Cuối tuần</label>
                            <input type="number" step="0.1" name="otweekendrate" value="2.0" required>
                        </div>
                        <div class="modal-form-group">
                            <label>Ngày Lễ/Tết</label>
                            <input type="number" step="0.1" name="otholidayrate" value="3.0" required>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-form-group" style="margin-top:24px;">
                <label class="checkbox-label">
                    <input type="checkbox" name="isactive" value="true" checked>
                    <span>Áp dụng cấu hình này làm cấu hình hiện tại</span>
                </label>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn-modal-cancel" onclick="closeAddModal()">Hủy bỏ</button>
                <button type="submit" class="btn-modal-save">Lưu Đợt Cấu Hình</button>
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

    function openAddModal() {
        document.getElementById('addConfigModal').style.display = 'flex';
    }
    function closeAddModal() {
        document.getElementById('addConfigModal').style.display = 'none';
    }

    window.onclick = function (event) {
        var addM = document.getElementById('addConfigModal');
        if (event.target === addM) closeAddModal();
    }
</script>
</body>
</html>