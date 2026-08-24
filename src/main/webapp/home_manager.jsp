<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    if (request.getAttribute("isLoaded") == null) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    String fullName = (String) request.getAttribute("fullName");
    String deptName = (String) request.getAttribute("deptName");
    Integer deptEmployeeCount = (Integer) request.getAttribute("deptEmployeeCount");
    Integer pendingCount = (Integer) request.getAttribute("pendingCount");
    String attendanceRate = (String) request.getAttribute("attendanceRate");
    List<Map<String, Object>> pendingRequests = (List<Map<String, Object>>) request.getAttribute("pendingRequests");
    List<Map<String, Object>> departmentAttendance = (List<Map<String, Object>>) request.getAttribute("departmentAttendance");
    List<Map<String, Object>> notificationsList = (List<Map<String, Object>>) request.getAttribute("notificationsList");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>EMS – Quản lý</title>
  <link rel="stylesheet" href="css/ems.css"/>
</head>
<body>

<%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
<%--<aside class="sidebar">--%>
<%--  <a href="home" class="sidebar-brand">--%>
<%--    <div class="brand-dot">E</div>--%>
<%--    <span class="brand-name">EMS</span>--%>
<%--  </a>--%>
<%--  <nav class="nav-group">--%>
<%--    <div class="nav-section-label">Menu chính</div>--%>
<%--    <a href="home_manager.jsp" class="nav-link active">Trang chủ</a>--%>
<%--    <div class="nav-section-label">Quản lý</div>--%>
<%--    <a href="work-schedule" class="nav-link">Lịch làm việc </a>--%>
<%--    <a href="holiday" class="nav-link">Quản lý ngày nghỉ lễ </a>--%>
<%--    <a href="#" class="nav-link">Điểm danh phòng ban</a>--%>
<%--    <a href="salary-management" class="nav-link">Quản lý lương</a>--%>
<%--  </nav>--%>
<%--  <div class="sidebar-footer">--%>
<%--    <div class="user-block">--%>
<%--      <div class="user-avatar">--%>
<%--        <%= fullName != null && !fullName.isEmpty() ? fullName.substring(0,1).toUpperCase() : "M" %>--%>
<%--      </div>--%>
<%--      <div>--%>
<%--        <div class="user-name"><%= fullName != null ? fullName : "Manager" %></div>--%>
<%--        <div class="user-role"><%= deptName != null ? deptName : "Quản lý" %></div>--%>
<%--      </div>--%>
<%--    </div>--%>
<%--    <button class="btn-logout" onclick="window.location='login'">Đăng xuất</button>--%>
<%--  </div>--%>
<%--</aside>--%>

<div class="main-content">
  <div class="topbar">
    <span class="topbar-left">Trang chủ</span>
    <div style="display: flex; align-items: center; gap: 16px;">
      <span class="topbar-right" id="topbar-date"></span>
      <div class="noti-dropdown-wrapper" style="position: relative; display: inline-block;">
        <button class="btn-noti-bell" onclick="toggleNotiDropdown()" style="background: none; border: none; cursor: pointer; position: relative; padding: 4px; display: flex; align-items: center; outline: none;">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color: #4b5563;"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg>

        </button>
        <div id="noti-dropdown" style="display: none; position: absolute; right: 0; top: 32px; width: 320px; background: #fff; border: 1px solid #e5e7eb; border-radius: 8px; box-shadow: 0 4px 16px rgba(0,0,0,0.08); z-index: 100; max-height: 280px; overflow-y: auto;">
          <div style="padding: 10px 14px; font-weight: 600; border-bottom: 1px solid #f3f4f6; font-size: 13px; color: #111;">Thông báo mới nhận</div>
          <%
            if (notificationsList != null && !notificationsList.isEmpty()) {
              for (Map<String, Object> noti : notificationsList) {
                String notiTitle = (String) noti.get("title");
                if ("Request Submitted".equalsIgnoreCase(notiTitle)) {
                  notiTitle = "Yêu cầu đã được gửi";
                } else if ("Request Approved".equalsIgnoreCase(notiTitle)) {
                  notiTitle = "Yêu cầu đã được duyệt";
                } else if ("Request Rejected".equalsIgnoreCase(notiTitle)) {
                  notiTitle = "Yêu cầu bị từ chối";
                }

                String notiMessage = (String) noti.get("message");
                if ("Your leave request has been submitted successfully.".equalsIgnoreCase(notiMessage)) {
                  notiMessage = "Yêu cầu nghỉ phép của bạn đã được gửi thành công.";
                }
          %>
                <div style="padding: 10px 14px; border-bottom: 1px solid #f9fafb; transition: background 0.1s; cursor: pointer;" onmouseover="this.style.background='#f9fafb'" onmouseout="this.style.background='transparent'">
                  <div style="font-weight: 500; font-size: 12.5px; color: #111;"><%= notiTitle %></div>
                  <div style="font-size: 11.5px; color: #6b7280; margin-top: 2px;"><%= notiMessage %></div>
                </div>
          <%
              }
            } else {
          %>
            <div style="padding: 20px; text-align: center; color: #9ca3af; font-size: 12px;">Không có thông báo nào.</div>
          <% } %>
        </div>
      </div>
    </div>
  </div>

  <div class="page-body">
    <div class="page-header">
      <h1>Chào mừng, <%= fullName != null ? fullName : "Manager" %></h1>
      <p>Dưới đây là tổng quan quản lý phòng ban: <strong><%= deptName != null ? deptName : "N/A" %></strong>.</p>
    </div>

    <div class="stats-row">
      <div class="stat-card">
        <div class="stat-label">Tổng số nhân sự</div>
        <div class="stat-value"><%= deptEmployeeCount != null ? deptEmployeeCount : 0 %> <span class="stat-unit">nhân viên</span></div>
      </div>
      <div class="stat-card" onclick="window.location.href='requests?action=pending'" style="cursor: pointer;" title="Nhấn để xem danh sách xử lý đơn">
        <div class="stat-label">Yêu cầu chờ duyệt</div>
        <div class="stat-value"><%= pendingCount != null ? pendingCount : 0 %></div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Tỷ lệ đi làm hôm nay</div>
        <div class="stat-value"><%= attendanceRate != null ? attendanceRate : "0%" %></div>
      </div>
    </div>

    <div class="cards-row">
      <div class="card">
        <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
          <span>Yêu cầu chờ duyệt</span>
          <a href="requests?action=pending" style="font-size: 12.5px; color: #0d9488; text-decoration: none; font-weight: 600;">Xem tất cả</a>
        </div>
        <%
          if (pendingRequests != null && !pendingRequests.isEmpty()) {
            for (Map<String, Object> req : pendingRequests) {
        %>
              <%
                Object valObj = req.get("value");
                String valStr = "0";
                if (valObj instanceof Number) {
                  double val = ((Number) valObj).doubleValue();
                  if (val == (int) val) {
                    valStr = String.valueOf((int) val);
                  } else {
                    valStr = String.valueOf(val);
                  }
                } else if (valObj != null) {
                  valStr = valObj.toString();
                }
              %>
              <div class="row-item" onclick="window.location.href='requests?action=pending'" style="cursor: pointer; transition: background 0.12s ease; display: flex; justify-content: space-between; align-items: center;" onmouseover="this.style.background='#f9fafb'" onmouseout="this.style.background='transparent'" title="Nhấn để xử lý đơn này">
                <div>
                  <div class="row-main"><%= req.get("fullName") %></div>
                  <div class="row-sub"><%= req.get("title") %> · <%= req.get("startDate") %> (<%= valStr %> ngày)</div>
                </div>
                <div style="display: flex; align-items: center; gap: 4px; color: #0d9488; font-size: 12.5px; font-weight: 600;">
                  <span>Xử lý</span>
                </div>
              </div>
        <%
            }
          } else {
        %>
          <div style="padding: 20px; text-align: center; color: #9ca3af; font-size: 13.5px;">Không có yêu cầu nào chờ duyệt.</div>
        <% } %>
      </div>

      <div class="card">
        <div class="card-header">Tình hình điểm danh hôm nay</div>
        <div style="max-height: 300px; overflow-y: auto;">
          <table>
            <thead>
              <tr><th>Nhân viên</th><th>Giờ vào</th><th>Trạng thái</th></tr>
            </thead>
            <tbody>
              <%
                if (departmentAttendance != null && !departmentAttendance.isEmpty()) {
                  for (Map<String, Object> att : departmentAttendance) {
                    String checkIn = (String) att.get("checkIn");
                    String statusDot = (checkIn == null) ? "dot-yellow" : "dot-green";
                    String statusText = (checkIn == null) ? "Vắng mặt" : "Có mặt";
              %>
                    <tr>
                      <td><%= att.get("fullName") %></td>
                      <td><%= checkIn != null ? checkIn : "--:--" %></td>
                      <td><span class="dot <%= statusDot %>"></span><%= statusText %></td>
                    </tr>
              <%
                  }
                } else {
              %>
                <tr><td colspan="3" style="text-align: center; color: #9ca3af;">Không có nhân viên nào trong phòng ban.</td></tr>
              <% } %>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <div class="card" style="margin-top: 20px;">
      <div class="card-header">Thông báo mới nhất</div>
      <%
        if (notificationsList != null && !notificationsList.isEmpty()) {
          for (Map<String, Object> noti : notificationsList) {
            java.sql.Timestamp ts = (java.sql.Timestamp) noti.get("createdAt");
            String timeStr = "";
            if (ts != null) {
              java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
              timeStr = sdf.format(ts);
            }
            
            String notiTitle = (String) noti.get("title");
            if ("Request Submitted".equalsIgnoreCase(notiTitle)) {
              notiTitle = "Yêu cầu đã được gửi";
            } else if ("Request Approved".equalsIgnoreCase(notiTitle)) {
              notiTitle = "Yêu cầu đã được duyệt";
            } else if ("Request Rejected".equalsIgnoreCase(notiTitle)) {
              notiTitle = "Yêu cầu bị từ chối";
            }

            String notiMessage = (String) noti.get("message");
            if ("Your leave request has been submitted successfully.".equalsIgnoreCase(notiMessage)) {
              notiMessage = "Yêu cầu nghỉ phép của bạn đã được gửi thành công.";
            }
      %>
            <div class="row-item">
              <div>
                <div class="row-main"><%= notiTitle %></div>
                <div class="row-sub"><%= notiMessage %></div>
              </div>
              <span class="row-sub" style="font-size: 11px; white-space: nowrap; margin-left: 10px;"><%= timeStr %></span>
            </div>
      <%
          }
        } else {
      %>
        <div style="padding: 20px; text-align: center; color: #9ca3af; font-size: 13.5px;">Không có thông báo nào.</div>
      <% } %>
    </div>
  </div>

  <footer>© 2026 Hệ thống Quản lý Nhân sự (EMS) · FPT University SWP391</footer>
</div>

<script>
  function tick() {
    var now = new Date();
    var p = function(n){ return String(n).padStart(2,'0'); };
    document.getElementById('topbar-date').textContent = p(now.getDate())+'/'+p(now.getMonth()+1)+'/'+now.getFullYear();
  }
  tick();

  function toggleNotiDropdown() {
    var dd = document.getElementById('noti-dropdown');
    if (dd.style.display === 'none' || dd.style.display === '') {
      dd.style.display = 'block';
    } else {
      dd.style.display = 'none';
    }
  }
  window.addEventListener('click', function(e) {
    var dd = document.getElementById('noti-dropdown');
    var wrapper = document.querySelector('.noti-dropdown-wrapper');
    if (dd && wrapper && !wrapper.contains(e.target)) {
      dd.style.display = 'none';
    }
  });
</script>
</body>
</html>
