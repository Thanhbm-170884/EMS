<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    HttpSession currentSession = request.getSession(false);
    if (currentSession == null || currentSession.getAttribute("username") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String username = (String) currentSession.getAttribute("username");
    String role = (String) currentSession.getAttribute("role");
    String displayName = username != null ? username : "Nhân viên";
    String initial = displayName.isEmpty() ? "N" : displayName.substring(0, 1).toUpperCase();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EMS – Gửi yêu cầu</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/ems.css">
    <style>
        .request-card { max-width: 920px; }
        .request-card-body { padding: 22px; }
        .request-form-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 18px; }
        .request-field { display: flex; flex-direction: column; gap: 7px; }
        .request-field.full { grid-column: 1 / -1; }
        .request-field label { color: #374151; font-size: 13px; font-weight: 600; }
        .required { color: #dc2626; }
        .request-field input, .request-field select, .request-field textarea {
            width: 100%; padding: 10px 12px; border: 1px solid #d1d5db; border-radius: 8px;
            background: #fff; color: #111827; font: inherit;
           }
        .request-field input:focus, .request-field select:focus, .request-field textarea:focus {
            outline: none; border-color: #2563eb; box-shadow: 0 0 0 3px rgba(37, 99, 235, .12);
        }
        .request-field textarea { min-height: 120px; resize: vertical; }
        .request-field input[readonly] { background: #f9fafb; color: #6b7280; }
        .request-notice { margin-top: 18px; padding: 12px 14px; border: 1px solid #bfdbfe; border-radius: 8px; background: #eff6ff; color: #1e40af; font-size: 13px; }
        .request-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 22px; padding-top: 18px; border-top: 1px solid #e5e7eb; }
        @media (max-width: 768px) {
            .sidebar { position: static; width: 100%; min-height: auto; }
            .main-content { margin-left: 0; }
            body { display: block; }
            .request-form-grid { grid-template-columns: 1fr; }
            .request-field.full { grid-column: auto; }
            .page-body { padding: 20px 16px; }
        }
    </style>
</head>
<body>
<aside class="sidebar">
    <a href="<%= request.getContextPath() %>/home" class="sidebar-brand">
        <div class="brand-dot">E</div>
        <span class="brand-name">EMS</span>
    </a>
    <nav class="nav-group">
        <div class="nav-section-label">Menu chính</div>
        <a href="<%= request.getContextPath() %>/home" class="nav-link">Trang chủ</a>
        <a href="#" class="nav-link">Lịch trình</a>
        <div class="nav-section-label">Công việc</div>
        <a href="<%= request.getContextPath() %>/request.jsp" class="nav-link active">Yêu cầu</a>
        <a href="#" class="nav-link">Bảng lương</a>
    </nav>
    <div class="sidebar-footer">
        <div class="user-block">
            <div class="user-avatar"><%= initial %></div>
            <div>
                <div class="user-name"><%= displayName %></div>
                <div class="user-role"><%= role != null ? role : "Nhân viên" %></div>
            </div>
        </div>
        <button class="btn-logout" onclick="window.location='<%= request.getContextPath() %>/login'">Đăng xuất</button>
    </div>
</aside>

<div class="main-content">
    <div class="topbar">
        <span class="topbar-left">Yêu cầu</span>
        <span class="topbar-right" id="topbar-date"></span>
    </div>

    <main class="page-body">
        <div class="page-header">
            <h1>Gửi yêu cầu</h1>
            <p>Tạo và gửi yêu cầu đến quản lý để được phê duyệt.</p>
        </div>

        <section class="card request-card">
            <div class="card-header">Thông tin yêu cầu</div>
            <div class="request-card-body">
                <form action="<%= request.getContextPath() %>/requests" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="insert">
                    <div class="request-form-grid">
                        <div class="request-field">
                            <label for="requestTypeId">Loại đơn <span class="required">*</span></label>
                            <select id="requestTypeId" name="requestTypeId" required>
                                <option value="">-- Chọn loại đơn --</option>
                                <option value="2">Nghỉ ốm</option>
                                <option value="1">Nghỉ phép</option>
                                <option value="3">Ứng lương</option>
                                <option value="4">Đơn khác</option>
                            </select>
                        </div>
                        <div class="request-field">
                            <label for="title">Tiêu đề <span class="required">*</span></label>
                            <input id="title" type="text" name="title" maxlength="100" placeholder="Nhập tiêu đề đơn" required>
                        </div>
                        <div class="request-field" id="startDateField">
                            <label for="startDate">Từ ngày</label>
                            <input id="startDate" type="date" name="startDate">
                        </div>
                        <div class="request-field" id="endDateField">
                            <label for="endDate">Đến ngày</label>
                            <input id="endDate" type="date" name="endDate">
                        </div>
                        <div class="request-field" id="valueField">
                            <label for="value">Giá trị / Số ngày</label>
                            <input id="value" type="number" name="value" step="0.5" min="0" placeholder="Ví dụ: 1.0">
                        </div>
                        <div class="request-field" id="imageField">
                            <label for="image">Ảnh minh chứng</label>
                            <input id="image" type="file" name="image" accept="image/*">
                        </div>
                        <div class="request-field full">
                            <label for="reason">Lý do / Nội dung</label>
                            <textarea id="reason" name="reason" maxlength="255" placeholder="Nhập lý do hoặc nội dung chi tiết của đơn..."></textarea>
                        </div>
                    </div>
                    <div class="request-notice">Sau khi gửi, đơn sẽ ở trạng thái <strong>Pending</strong> và được chuyển đến quản lý để phê duyệt.</div>
                    <div class="request-actions">
                        <a href="<%= request.getContextPath() %>/requests?action=myRequests" class="btn btn-secondary">Danh sách yêu cầu</a>
                        <button type="reset" class="btn btn-secondary">Nhập lại</button>
                        <button type="submit" class="btn btn-primary">Gửi đơn</button>
                    </div>
                </form>
            </div>
        </section>
    </main>
    <footer>© 2026 Hệ thống Quản lý Nhân sự (EMS) · FPT University SWP391</footer>
</div>

<script>
    (function () {
        var now = new Date();
        document.getElementById('topbar-date').textContent = String(now.getDate()).padStart(2, '0') + '/' + String(now.getMonth() + 1).padStart(2, '0') + '/' + now.getFullYear();

        // Set min date to today (YYYY-MM-DD)
        var today = now.getFullYear() + '-' + String(now.getMonth() + 1).padStart(2, '0') + '-' + String(now.getDate()).padStart(2, '0');
        document.getElementById('startDate').min = today;
        document.getElementById('endDate').min = today;
    }());

    function calculateDays() {
        var startInput = document.getElementById('startDate');
        var endInput = document.getElementById('endDate');
        var valueInput = document.getElementById('value');
        var type = document.getElementById('requestTypeId').value;

        if ((type === '1' || type === '2') && startInput.value && endInput.value) {
            var start = new Date(startInput.value);
            var end = new Date(endInput.value);
            var diff = end - start;
            if (diff >= 0) {
                var days = (diff / (1000 * 60 * 60 * 24)) + 1;
                var roundedDays = Math.round(days * 2) / 2;
                if (roundedDays < 0.5) roundedDays = 0.5;
                valueInput.value = roundedDays;
            } else {
                valueInput.value = '0';
            }
        }
    }

    document.getElementById('startDate').addEventListener('change', function() {
        document.getElementById('endDate').min = this.value;
        calculateDays();
    });
    document.getElementById('endDate').addEventListener('change', calculateDays);

    document.getElementById('requestTypeId').addEventListener('change', function() {
        var type = this.value;
        var valueLabel = document.querySelector('label[for="value"]');
        var valueInput = document.getElementById('value');
        
        var startField = document.getElementById('startDateField');
        var endField = document.getElementById('endDateField');
        var startInput = document.getElementById('startDate');
        var endInput = document.getElementById('endDate');

        // Reset default states
        startInput.required = false;
        endInput.required = false;
        valueInput.readOnly = false;
        valueInput.style.backgroundColor = '';
        startField.style.display = '';
        endField.style.display = '';

        if (type === '3') { // Ứng lương
            startField.style.display = 'none';
            endField.style.display = 'none';
            startInput.value = '';
            endInput.value = '';

            valueLabel.innerHTML = 'Số tiền ứng (VNĐ) <span class="required">*</span>';
            valueInput.placeholder = 'Ví dụ: 2000000';
            valueInput.step = '1000';
            valueInput.required = true;
            valueInput.value = '';
        } else if (type === '1' || type === '2') { // Nghỉ phép, Nghỉ ốm
            startInput.required = true;
            endInput.required = true;
            document.querySelector('label[for="startDate"]').innerHTML = 'Từ ngày <span class="required">*</span>';
            document.querySelector('label[for="endDate"]').innerHTML = 'Đến ngày <span class="required">*</span>';

            valueLabel.innerHTML = 'Số ngày nghỉ (Tự động tính)';
            valueInput.placeholder = 'Chọn khoảng thời gian...';
            valueInput.readOnly = true;
            valueInput.style.backgroundColor = '#f3f4f6';
            valueInput.required = true;
            calculateDays();
        } else { // Đơn khác
            valueLabel.innerHTML = 'Giá trị / Số ngày';
            valueInput.placeholder = 'Ví dụ: 1.0';
            valueInput.step = '0.5';
            valueInput.required = false;

            document.querySelector('label[for="startDate"]').innerHTML = 'Từ ngày';
            document.querySelector('label[for="endDate"]').innerHTML = 'Đến ngày';
        }
    });
</script>
</body>
</html>
