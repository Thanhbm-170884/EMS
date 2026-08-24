<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="j" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">

<head>

    <meta charset="UTF-8"/>

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0"/>

    <title>EMS – Thông tin cá nhân</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/ems.css"/>

    <style>

        /* =========================
           PROFILE CARD
           ========================= */

        .profile-card {
            background: #ffffff;
            border-radius: 12px;
            padding: 28px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
        }


        /* =========================
           PROFILE HEADER
           ========================= */

        .profile-header {
            display: flex;
            align-items: center;
            gap: 18px;

            padding-bottom: 24px;
            margin-bottom: 24px;

            border-bottom: 1px solid #e2e8f0;
        }


        .profile-avatar {
            width: 64px;
            height: 64px;

            border-radius: 50%;

            display: flex;
            align-items: center;
            justify-content: center;

            background: #1e3a8a;
            color: white;

            font-size: 24px;
            font-weight: 700;
        }


        .profile-title h2 {
            margin: 0 0 5px 0;

            font-size: 20px;
            font-weight: 700;

            color: #0f172a;
        }


        .profile-title p {
            margin: 0;

            font-size: 14px;

            color: #64748b;
        }


        /* =========================
           INFORMATION GRID
           ========================= */

        .profile-grid {
            display: grid;

            grid-template-columns:
                repeat(2, minmax(0, 1fr));

            gap: 20px;
        }


        .profile-item {
            display: flex;
            flex-direction: column;
            gap: 7px;
        }


        .profile-label {
            font-size: 13px;

            font-weight: 600;

            color: #64748b;
        }


        .profile-value {
            min-height: 42px;

            box-sizing: border-box;

            display: flex;
            align-items: center;

            padding: 10px 12px;

            background: #f8fafc;

            border: 1px solid #e2e8f0;

            border-radius: 8px;

            font-size: 14px;

            color: #1e293b;
        }


        /* =========================
           STATUS
           ========================= */

        .status-active {
            display: inline-flex;

            align-items: center;

            width: fit-content;

            padding: 5px 12px;

            border-radius: 9999px;

            background: #d1fae5;

            color: #059669;

            font-size: 12px;

            font-weight: 600;
        }


        .status-inactive {
            display: inline-flex;

            align-items: center;

            width: fit-content;

            padding: 5px 12px;

            border-radius: 9999px;

            background: #fee2e2;

            color: #dc2626;

            font-size: 12px;

            font-weight: 600;
        }


        /* =========================
           ERROR
           ========================= */

        .alert-danger {
            background: #fef2f2;

            border: 1px solid #fecaca;

            color: #b91c1c;

            padding: 12px 16px;

            border-radius: 8px;

            margin-bottom: 20px;

            font-size: 14px;
        }


        /* =========================
           RESPONSIVE
           ========================= */

        @media (max-width: 768px) {

            .profile-grid {
                grid-template-columns: 1fr;
            }

            .profile-card {
                padding: 20px;
            }

        }

    </style>

</head>


<body>


<!-- =========================
     SIDEBAR
     ========================= -->

<%@ include file="/WEB-INF/jspf/sidebar.jsp" %>


<!-- =========================
     MAIN CONTENT
     ========================= -->

<div class="main-content">


    <!-- =========================
         HEADER
         ========================= -->

    <div class="topbar">

        <span class="topbar-left">
            Thông tin cá nhân
        </span>

        <div>

            <span class="topbar-right"
                  id="topbar-date">
            </span>

        </div>

    </div>


    <!-- =========================
         PAGE BODY
         ========================= -->

    <div class="page-body">


        <!-- =========================
             PAGE HEADER
             ========================= -->

        <div class="page-header">

            <h1>
                Thông tin cá nhân
            </h1>

            <p>
                Xem thông tin hồ sơ cá nhân của bạn trong hệ thống EMS.
            </p>

        </div>


        <!-- =========================
             ERROR
             ========================= -->

        <% if (request.getAttribute("error") != null) { %>

            <div class="alert-danger">

                ⚠ <%= request.getAttribute("error") %>

            </div>

        <% } %>


        <!-- =========================
             PROFILE
             ========================= -->

        <j:if test="${not empty profile}">

            <div class="profile-card">


                <!-- PROFILE HEADER -->

                <div class="profile-header">

                    <div class="profile-avatar">

                        ${profile.fullName.substring(0,1)}

                    </div>


                    <div class="profile-title">

                        <h2>
                            ${profile.fullName}
                        </h2>

                        <p>
                            ${profile.employeeCode}
                        </p>

                    </div>

                </div>


                <!-- =========================
                     INFORMATION
                     ========================= -->

                <div class="profile-grid">


                    <!-- MÃ NHÂN VIÊN -->

                    <div class="profile-item">

                        <span class="profile-label">
                            Mã nhân viên
                        </span>

                        <div class="profile-value">
                            ${profile.employeeCode}
                        </div>

                    </div>


                    <!-- HỌ VÀ TÊN -->

                    <div class="profile-item">

                        <span class="profile-label">
                            Họ và tên
                        </span>

                        <div class="profile-value">
                            ${profile.fullName}
                        </div>

                    </div>


                    <!-- EMAIL -->

                    <div class="profile-item">

                        <span class="profile-label">
                            Email công ty
                        </span>

                        <div class="profile-value">
                            ${profile.emailCompany}
                        </div>

                    </div>


                    <!-- PHONE -->

                    <div class="profile-item">

                        <span class="profile-label">
                            Số điện thoại
                        </span>

                        <div class="profile-value">

                            <j:choose>

                                <j:when test="${not empty profile.phone}">
                                    ${profile.phone}
                                </j:when>

                                <j:otherwise>
                                    Chưa cập nhật
                                </j:otherwise>

                            </j:choose>

                        </div>

                    </div>


                    <!-- GIỚI TÍNH -->

                    <div class="profile-item">

                        <span class="profile-label">
                            Giới tính
                        </span>

                        <div class="profile-value">

                            <j:choose>

                                <j:when test="${profile.gender == true}">
                                    Nam
                                </j:when>

                                <j:when test="${profile.gender == false}">
                                    Nữ
                                </j:when>

                                <j:otherwise>
                                    Chưa cập nhật
                                </j:otherwise>

                            </j:choose>

                        </div>

                    </div>


                    <!-- NGÀY SINH -->

                    <div class="profile-item">

                        <span class="profile-label">
                            Ngày sinh
                        </span>

                        <div class="profile-value">

                            <j:choose>

                                <j:when test="${not empty profile.dateOfBirth}">
                                    ${profile.dateOfBirth}
                                </j:when>

                                <j:otherwise>
                                    Chưa cập nhật
                                </j:otherwise>

                            </j:choose>

                        </div>

                    </div>


                    <!-- PHÒNG BAN -->

                    <div class="profile-item">

                        <span class="profile-label">
                            Phòng ban
                        </span>

                        <div class="profile-value">
                            ${profile.departmentName}
                        </div>

                    </div>


                    <!-- CHỨC VỤ -->

                    <div class="profile-item">

                        <span class="profile-label">
                            Chức vụ
                        </span>

                        <div class="profile-value">
                            ${profile.positionName}
                        </div>

                    </div>


                    <!-- SỐ NGƯỜI PHỤ THUỘC -->

                    <div class="profile-item">

                        <span class="profile-label">
                            Số người phụ thuộc
                        </span>

                        <div class="profile-value">
                            ${profile.dependentsCount}
                        </div>

                    </div>


                    <!-- TRẠNG THÁI -->

                    <div class="profile-item">

                        <span class="profile-label">
                            Trạng thái tài khoản
                        </span>

                        <div class="profile-value"
                             style="background:#ffffff; border:none; padding-left:0;">

                            <j:choose>

                                <j:when test="${profile.status}">

                                    <span class="status-active">
                                        Đang hoạt động
                                    </span>

                                </j:when>

                                <j:otherwise>

                                    <span class="status-inactive">
                                        Ngừng hoạt động
                                    </span>

                                </j:otherwise>

                            </j:choose>

                        </div>

                    </div>


                </div>

            </div>

        </j:if>


        <!-- =========================
             NO DATA
             ========================= -->

        <j:if test="${empty profile and empty requestScope.error}">

            <div class="card"
                 style="
                    padding:40px;
                    text-align:center;
                    color:#94a3b8;
                 ">

                Không tìm thấy thông tin cá nhân.

            </div>

        </j:if>


    </div>


    <!-- =========================
         FOOTER
         ========================= -->

    <footer>

        © 2026 Hệ thống Quản lý Nhân sự (EMS)
        · FPT University SWP391

    </footer>


</div>


<!-- =========================
     JAVASCRIPT
     ========================= -->

<script>

    function tick() {

        var now = new Date();

        var p = function(n) {
            return String(n).padStart(2, '0');
        };

        var element =
            document.getElementById('topbar-date');

        if (element) {

            element.textContent =
                p(now.getDate()) + '/' +
                p(now.getMonth() + 1) + '/' +
                now.getFullYear();

        }

    }

    tick();

</script>


</body>

</html>