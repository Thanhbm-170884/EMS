<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ems.model.AttendanceRecord" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <title>EMS – Sửa dòng chấm công</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ems.css"/>
    <style>
        .edit-form { max-width: 480px; margin: 32px; }
        .form-group { margin-bottom: 16px; }
        .form-group label { display:block; font-size:13px; font-weight:600; color:#475569; margin-bottom:6px; }
        .form-group input {
            width:100%; padding:9px 12px; border:1px solid #cbd5e1; border-radius:8px; font-size:14px;
        }
        .error-list { color:#dc2626; font-size:13px; margin-top:10px; }
        .btn-action-group { display:flex; gap:12px; margin-top:20px; }
    </style>
</head>
<body>
<div class="main-content" style="margin-left:0;">
<div class="edit-form">
    <h1>Sửa dòng chấm công</h1>

    <%
        AttendanceRecord r = (AttendanceRecord) request.getAttribute("record");
    %>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alert-danger">⚠ <%= request.getAttribute("error") %></div>
    <% } %>

    <% if (r != null) { %>
        <form action="${pageContext.request.contextPath}/Attendance/edit" method="post">
            <input type="hidden" name="originalCode" value="<%= r.getEmployeeCode() %>" />
            <input type="hidden" name="originalDate" value="<%= r.getDate() %>" />

            <div class="form-group">
                <label>Ngày</label>
                <input type="date" name="date" value="<%= r.getDate() %>" />
            </div>
            <div class="form-group">
                <label>Mã nhân viên</label>
                <input type="text" name="employeeCode" value="<%= r.getEmployeeCode() %>" />
            </div>
            <div class="form-group">
                <label>Họ và Tên</label>
                <input type="text" name="fullName" value="<%= r.getFullName() %>" />
            </div>
            <div class="form-group">
                <label>Phòng ban</label>
                <input type="text" name="department" value="<%= r.getDepartment() %>" />
            </div>
            <div class="form-group">
                <label>Check in</label>
                <input type="time" name="checkIn" value="<%= r.getCheckIn() %>" />
            </div>
            <div class="form-group">
                <label>Check out</label>
                <input type="time" name="checkOut" value="<%= r.getCheckOut() %>" />
            </div>

            <% if (!r.isValid()) { %>
                <div class="error-list">
                    <% for (String err : r.getErrors()) { %>
                        • <%= err %><br/>
                    <% } %>
                </div>
            <% } %>

            <div class="btn-action-group">
                <button type="submit" class="btn-primary">💾 Lưu thay đổi</button>
                <a href="${pageContext.request.contextPath}/Attendance/attendance.jsp" class="btn-secondary">Hủy</a>
            </div>
        </form>
    <% } %>
</div>
</div>
</body>
</html>