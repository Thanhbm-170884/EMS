<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>


<aside class="sidebar">
    <a href="home" class="sidebar-brand">
        <div class="brand-dot">E</div>
        <span class="brand-name">EMS</span>

    </a>
    <nav class="nav-group">
        <div class="nav-section-label">Menu chính</div>
        <!- Manager ->
        <c:if test="${sessionScope.role == 'Manager'}">

            <a href="${pageContext.request.contextPath}/home_manager.jsp"
               class="nav-link ${pageContext.request.servletPath == '/home_manager.jsp' ? 'active' : ''}">
                Trang chủ
            </a>
            <div class="nav-section-label">Quản lý</div>
            <a href="${pageContext.request.contextPath}/work-schedule"
               class="nav-link ${pageContext.request.servletPath == '/work-schedule.jsp' ? 'active' : ''}">
                Lịch làm việc
            </a>
            <a href="${pageContext.request.contextPath}/requests?action=pending"
                           class="nav-link ${pageContext.request.servletPath == '/request-manager.jsp' ? 'active' : ''}">
                            Xử lý đơn
                        </a>
            <a href="${pageContext.request.contextPath}/requests?action=employeeBalances"
                           class="nav-link ${pageContext.request.servletPath == '/employee-balances.jsp' ? 'active' : ''}">
                            Trạng thái nhân sự
                        </a>
            <a href="${pageContext.request.contextPath}/holiday"
               class="nav-link ${pageContext.request.servletPath == '/holiday.jsp' ? 'active' : ''}">
                Quản lý ngày nghỉ lễ
            </a>

            <a href="${pageContext.request.contextPath}/shift-management"
               class="nav-link ${pageContext.request.servletPath == '/shift-management.jsp' ? 'active' : ''}">
                Ca làm việc
            </a>

            <a href="${pageContext.request.contextPath}/shift-assignment"
               class="nav-link ${pageContext.request.servletPath == '/shift-assignment.jsp' ? 'active' : ''}">
                Phân ca làm việc
            </a>

            <a href="${pageContext.request.contextPath}/salary-management"
               class="nav-link ${pageContext.request.servletPath == '/salary-management.jsp' ? 'active' : ''}">
                Quản lý lương
            </a>
            <a href="${pageContext.request.contextPath}/Attendance/upload.jsp"
                                       class="nav-link ${pageContext.request.servletPath == '/Attendance/upload.jsp' ? 'active' : ''}">
                                        Quản lý chấm công
                          </a>
        </c:if>


        <!- Admin ->
        <c:if test="${sessionScope.role == 'Admin'}">

        </c:if>

        <!- Employee ->
        <c:if test="${sessionScope.role == 'Employee'}">

            <a href="${pageContext.request.contextPath}/home"
               class="nav-link ${pageContext.request.servletPath == '/home.jsp' ? 'active' : ''}">
                Trang chủ
            </a>
            <div class="nav-section-label">Công việc</div>
            <a href="${pageContext.request.contextPath}/employee-calendar?year=<%=java.time.LocalDate.now().getYear()%>&amp;month=<%=java.time.LocalDate.now().getMonthValue()%>&amp;employeeId=${sessionScope.accountId}"
               class="nav-link ${pageContext.request.servletPath == '/employee-calendar.jsp' ? 'active' : ''}">
                Lịch làm việc
            </a>
            <a href="${pageContext.request.contextPath}/request.jsp"
               class="nav-link ${pageContext.request.servletPath == '/request.jsp' ? 'active' : ''}">
                Yêu cầu
            </a>
            <a href="${pageContext.request.contextPath}/notification"
               class="nav-link ${pageContext.request.servletPath == '/notification.jsp' ? 'active' : ''}">
                Thông báo
            </a>

        </c:if>

    </nav>

    <%--    <div class="bg-[#F0F4FA] p-3.5 rounded-xl border border-slate-200/80">--%>
    <%--        <div class="flex items-center space-x-2 text-emerald-600 font-semibold text-xs mb-1">--%>
    <%--            <i data-lucide="check-circle-2" class="w-4 h-4"></i>--%>
    <%--            <span>Hệ thống</span>--%>
    <%--        </div>--%>
    <%--        <p class="text-[11px] text-slate-500 leading-snug">--%>
    <%--            Lịch đã được đồng bộ lúc <strong class="text-slate-700">08:30</strong> hôm nay.--%>
    <%--        </p>--%>
    <%--    </div>--%>
    <div class="sidebar-footer">
        <div class="user-block">
            <div class="user-avatar">
                <%= session.getAttribute("username") != null ? session.getAttribute("username").toString().substring(0, 1).toUpperCase() : "M" %>
            </div>
            <div>
                <div class="user-name"><%= session.getAttribute("username") != null ? session.getAttribute("username") : "Manager" %>
                </div>
                <div class="user-role">Quản lý</div>
            </div>
        </div>
        <button class="btn-logout" onclick="window.location='${pageContext.request.contextPath}/logout'">Đăng xuất</button>
    </div>
</aside>
