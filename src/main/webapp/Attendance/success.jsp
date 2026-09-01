<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>EMS – Lưu thành công</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/ems.css"/>
</head>

<body>

<%@ include file="/WEB-INF/jspf/sidebar.jsp" %>


<div class="main-content">

    <div class="topbar">

        <span class="topbar-left">
            Chấm công
        </span>

        <div>
            <span class="topbar-right" id="topbar-date"></span>
        </div>

    </div>


    <div class="page-body">

        <div class="page-header">

            <h1>
                Chấm công nhân viên
            </h1>

            <p>
                Kết quả xử lý dữ liệu vừa upload.
            </p>

        </div>


        <!-- Kết quả lưu thành công -->

        <div class="card">

            <div style="
                min-height: 440px;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                text-align: center;
                padding: 60px 20px;
            ">

                <!-- Icon thành công -->

                <div style="
                    width: 80px;
                    height: 80px;
                    border-radius: 50%;
                    background: #d1fae5;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    margin-bottom: 20px;
                    color: #059669;
                    font-size: 38px;
                ">
                    ✓
                </div>


                <!-- Tiêu đề -->

                <h2 style="
                    font-size: 20px;
                    font-weight: 700;
                    color: #1e293b;
                    margin-bottom: 8px;
                ">
                    Lưu dữ liệu thành công
                </h2>


                <!-- Số lượng bản ghi -->

                <p style="
                    font-size: 14px;
                    color: #64748b;
                    margin-bottom: 25px;
                ">
                    Đã lưu
                    <strong style="color:#334155;">
                        ${requestScope.savedCount}
                    </strong>
                    bản ghi chấm công vào hệ thống.
                </p>



                </a>
                <!-- Tìm kiếm -->

                   <!-- Nhóm nút thao tác -->
                   <div style="
                       display: flex;
                       justify-content: center;
                       align-items: center;
                       gap: 16px;
                       margin-top: 20px;
                   ">

                       <!-- Upload file khác -->
                       <a href="${pageContext.request.contextPath}/Attendance/upload.jsp"
                          style="
                              display: inline-flex;
                              align-items: center;
                              gap: 8px;
                              padding: 10px 20px;
                              background: #1e3a8a;
                              color: white;
                              border-radius: 8px;
                              font-size: 14px;
                              font-weight: 600;
                              text-decoration: none;
                              transition: background 0.2s;
                          "
                          onmouseover="this.style.background='#182e6e'"
                          onmouseout="this.style.background='#1e3a8a'">

                           <span style="font-size:16px;">↑</span>
                           <span>Upload file khác</span>

                       </a>

                       <!-- Bảng chấm công -->
                       <a href="${pageContext.request.contextPath}/Attendance/search-attendance"
                          style="
                              display: inline-flex;
                              align-items: center;
                              gap: 8px;
                              padding: 10px 20px;
                              background: #1e3a8a;
                              color: white;
                              border-radius: 8px;
                              font-size: 14px;
                              font-weight: 600;
                              text-decoration: none;
                              transition: background 0.2s;
                          "
                          onmouseover="this.style.background='#182e6e'"
                          onmouseout="this.style.background='#1e3a8a'">

                           <span style="font-size:16px;">📋</span>
                           <span>Bảng chấm công</span>

                       </a>

                   </div>

            </div>

        </div>

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
```
