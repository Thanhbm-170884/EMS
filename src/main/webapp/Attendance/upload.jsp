<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>EMS – Chấm công nhân viên</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/ems.css"/>
    <style>
        .search-attendance-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;

            padding: 10px 20px;

            background: #1e3a8a;
            color: white;

            border: none;
            border-radius: 8px;

            font-size: 14px;
            font-weight: 600;

            text-decoration: none;

            cursor: pointer;

            transition: background 0.2s;
        }
        .search-attendance-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;

            padding: 10px 20px;

            background: #1e3a8a;
            color: white;

            border: none;
            border-radius: 999px;

            font-size: 14px;
            font-weight: 600;

            text-decoration: none;
            cursor: pointer;

            transition: background 0.2s, transform 0.2s;
        }

        .search-attendance-btn:hover {
            background: #172554;
            transform: translateY(-1px);
        }


        .}

        .search-attendance-wrapper {
            margin-top: 20px;
            display: flex;
            justify-content: flex-end;
        }
    </style>
</head>

<body>

<aside class="sidebar">

    <a href="${pageContext.request.contextPath}/home"
       class="sidebar-brand">
        <div class="brand-dot">E</div>
        <span class="brand-name">EMS</span>
    </a>

    <nav class="nav-group">

        <div class="nav-section-label">Menu chính</div>

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

    </nav>

    <div class="sidebar-footer">

        <div class="user-block">
            <div class="user-avatar">
                M
            </div>

            <div>
                <div class="user-name">Manager</div>
                <div class="user-role">Quản lý</div>
            </div>
        </div>

        <button class="btn-logout"
                onclick="window.location='${pageContext.request.contextPath}/login'">
            Đăng xuất
        </button>

    </div>

</aside>


<div class="main-content">

    <div class="topbar">
        <span class="topbar-left">Chấm công</span>

        <div>
            <span class="topbar-right" id="topbar-date"></span>
        </div>
    </div>


    <div class="page-body">

        <div class="page-header">

            <h1>Chấm công nhân viên</h1>

            <p>
                Upload file Excel để nhập và xem dữ liệu chấm công theo ngày.
            </p>

        </div>


        <!-- Khu vực upload -->

        <div class="card">

            <div class="card-header">
                Import dữ liệu chấm công
            </div>

            <form id="uploadForm"
                  action="${pageContext.request.contextPath}/Attendance/upload"
                  method="post"
                  enctype="multipart/form-data">

                <input type="file"
                       id="excelFile"
                       name="excelFile"
                       accept=".xlsx,.xls"
                       style="display:none;"
                       onchange="document.getElementById('uploadForm').submit();">


                <label for="excelFile"
                       style="
                       border: 2px dashed #cbd5e1;
                       border-radius: 12px;
                       padding: 60px 20px;
                       display: flex;
                       flex-direction: column;
                       align-items: center;
                       justify-content: center;
                       text-align: center;
                       cursor: pointer;
                       margin: 20px;
                       background: #f8fafc;
                       ">

                    <div style="
                         width: 70px;
                         height: 70px;
                         border-radius: 50%;
                         background: #e8eef9;
                         display: flex;
                         align-items: center;
                         justify-content: center;
                         margin-bottom: 20px;
                         font-size: 30px;
                         ">
                        ↑
                    </div>

                    <h2>
                        Chưa có dữ liệu chấm công
                    </h2>

                    <p style="color:#64748b;">
                        Nhấn để chọn file Excel (.xlsx hoặc .xls)
                    </p>

                    <span style="
                          margin-top: 15px;
                          padding: 10px 20px;
                          background: #1e3a8a;
                          color: white;
                          border-radius: 8px;
                          font-weight: 600;
                          ">
                        Chọn file Excel
                    </span>

                    <p style="
                       margin-top: 20px;
                       font-size: 12px;
                       color: #94a3b8;
                       ">
                        Cột yêu cầu:
                        Ngày |
                        Mã nhân viên |
                        Họ và Tên |
                        Phòng ban |
                        Check in |
                        Check out |
                        Chỉnh sửa
                    </p>

                </label>

            </form>

        </div>
         <!-- =========================
                 NÚT TÌM KIẾM
                 ========================= -->

            <a href="${pageContext.request.contextPath}/Attendance/search-attendance"
               class="search-attendance-btn">
                📋Bảng chấm công

            </a>





    </div>


    <footer>
        © 2026 Hệ thống Quản lý Nhân sự (EMS) · FPT University SWP391
    </footer>

</div>


<script>

    function tick() {

        var now = new Date();

        var p = function(n) {
            return String(n).padStart(2, '0');
        };

        var element = document.getElementById('topbar-date');

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