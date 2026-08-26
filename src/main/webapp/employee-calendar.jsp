<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    if (request.getAttribute("days") == null) {
        response.sendRedirect(request.getContextPath() + "/employee-calendar");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Lịch làm việc – EMS</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ems.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/employee-calendar.css">
  <!-- Font Awesome for icons -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>

<body>

  <%@include file="/WEB-INF/jspf/sidebar.jsp"%>

  <div class="main-content">

    <!-- Topbar -->
    <div class="topbar">
      <div>
        <div class="topbar-title"> Lịch làm việc</div>
        <div class="topbar-breadcrumb">EMS &rsaquo; Lịch làm việc</div>
      </div>
      <div class="topbar-right">Tháng <strong>${month}/${year}</strong></div>
    </div>

    <!-- Page body -->
    <div class="page-body">

      <!-- JSTL month calculations -->
      <c:set var="prevMonth" value="${month == 1 ? 12 : month - 1}" />
      <c:set var="prevYear"  value="${month == 1 ? year - 1 : year}" />
      <c:set var="nextMonth" value="${month == 12 ? 1 : month + 1}" />
      <c:set var="nextYear"  value="${month == 12 ? year + 1 : year}" />

      <!-- Page header -->
      <div class="hol-page-header">
        <div class="hol-page-header-text">
          <h1>
            <i class="fa-solid fa-calendar-week" style="color:var(--primary);font-size:1.2rem;"></i>
            Lịch làm việc của bạn
          </h1>
          <p>Xem lịch ca làm việc và ngày nghỉ lễ theo từng tháng</p>
        </div>

        <!-- Month navigator -->
        <div class="month-nav">
          <a class="month-nav-btn"
             href="${pageContext.request.contextPath}/employee-calendar?year=${prevYear}&amp;month=${prevMonth}&amp;employeeId=${employeeId}"
             title="Tháng trước">
            <i class="fa-solid fa-chevron-left"></i>
          </a>
          <div class="month-chip">
            <i class="fa-regular fa-calendar"></i>
            Tháng ${month}/${year}
          </div>
          <a class="month-nav-btn"
             href="${pageContext.request.contextPath}/employee-calendar?year=${nextYear}&amp;month=${nextMonth}&amp;employeeId=${employeeId}"
             title="Tháng sau">
            <i class="fa-solid fa-chevron-right"></i>
          </a>
        </div>
      </div>

      <!-- Legend -->
      <div class="cal-legend">
        <div class="cal-legend-item"><span class="cal-dot cal-dot-work"></span> Ngày làm việc</div>
        <div class="cal-legend-item"><span class="cal-dot cal-dot-holiday"></span> Ngày lễ</div>
        <div class="cal-legend-item"><span class="cal-dot cal-dot-weekend"></span> Chủ nhật</div>
        <div class="cal-legend-item"><span class="cal-dot cal-dot-off"></span> Không có ca</div>
      </div>

      <!-- Calendar card -->
      <div class="cal-card">

        <!-- Card header -->
        <div class="cal-card-header">
          <div class="cal-card-header-left">
            <div class="cal-card-icon"><i class="fa-solid fa-calendar-days"></i></div>
            <div>
              <div class="cal-card-title">Tháng ${month} / ${year}</div>
              <div class="cal-card-subtitle">Lịch cá nhân – ca làm việc &amp; ngày lễ</div>
            </div>
          </div>
        </div>

        <!-- Calendar grid -->
        <div class="cal-grid-wrap">
          <div class="calendar-grid">

            <!-- Weekday headers -->
            <div class="weekday-header">T2</div>
            <div class="weekday-header">T3</div>
            <div class="weekday-header">T4</div>
            <div class="weekday-header">T5</div>
            <div class="weekday-header">T6</div>
            <div class="weekday-header">T7</div>
            <div class="weekday-header sunday">CN</div>

            <!-- Leading blanks -->
            <c:forEach begin="1" end="${leadingBlanks}">
              <div class="day-cell blank"></div>
            </c:forEach>

            <!-- Day cells: dùng c:choose để tính class TRƯỚC rồi gán vào biến, tránh lồng JSTL vào attribute -->
            <c:forEach var="d" items="${days}">
              <c:choose>
                <c:when test="${d.dayType == 'WORK'}">    <c:set var="cellClass" value="day-cell work"    /></c:when>
                <c:when test="${d.dayType == 'HOLIDAY'}"> <c:set var="cellClass" value="day-cell holiday" /></c:when>
                <c:when test="${d.dayType == 'WEEKEND'}"> <c:set var="cellClass" value="day-cell weekend" /></c:when>
                <c:otherwise>                             <c:set var="cellClass" value="day-cell off"     /></c:otherwise>
              </c:choose>

              <div class="${cellClass}">

                <div class="day-number">${d.dayOfMonth}</div>

                <c:if test="${d.dayType == 'HOLIDAY'}">
                  <span class="cal-tag cal-tag-holiday">
                    <i class="fa-solid fa-star" style="font-size:0.6rem;"></i> Nghỉ lễ
                  </span>
                  <div class="holiday-label">${d.holidayName}</div>
                  <div class="coef-label">x${d.holidayCoefficient}</div>
                </c:if>

                <c:if test="${d.dayType == 'WORK'}">
                  <span class="cal-tag cal-tag-work">${d.shiftName}</span>
                  <div class="shift-time">${d.shiftTime}</div>
                </c:if>

                <c:if test="${d.dayType == 'WEEKEND'}">
                  <span class="weekend-label">Chủ nhật</span>
                </c:if>

              </div>
            </c:forEach>

          </div><!-- /calendar-grid -->
        </div><!-- /cal-grid-wrap -->

      </div><!-- /cal-card -->

    </div><!-- /page-body -->

    <!-- Footer -->
    <footer>EMS &copy; 2025 &mdash; Employee Management System</footer>

  </div><!-- /main-content -->

</body>

</html>