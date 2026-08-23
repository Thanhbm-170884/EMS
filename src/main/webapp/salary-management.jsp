<%@ page contentType="text/html;charset=UTF-8" %>
  <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
      <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

        <!DOCTYPE html>
        <html lang="vi">

        <head>
          <meta charset="UTF-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1.0" />
          <title>Quản lý lương – EMS Manager</title>
          <link rel="stylesheet" href="css/ems.css" />
          <link rel="stylesheet" href="css/salary-management.css" />
          <link rel="preconnect" href="https://fonts.googleapis.com">
          <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
          <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
            rel="stylesheet">
        </head>
        <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>

          <body>

            <!-- SIDEBAR -->

            <!-- MAIN CONTENT WRAPPER -->
            <div class="main-content">
              <!-- TOPBAR -->
              <div class="topbar">
                <span class="topbar-left">Trang chủ / Quản lý lương</span>
                <span class="topbar-right" id="topbar-date"></span>
              </div>

              <!-- PAGE BODY -->
              <div class="page-body">
                <!-- Header Section -->
                <div class="sm-header">
                  <h1>Trung tâm Quản lý Lương (Salary Management)</h1>
                  <p>Chọn một trong các danh mục quản lý lương dưới đây để tiếp tục</p>
                </div>

                <!-- Option Cards Grid in BODY -->
                <div class="sm-grid">

                  <!-- Option Card 1: Xem Lương cơ bản -->
                  <div class="sm-card">
                    <div>
                      <div class="sm-card-icon-wrapper icon-blue">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                          stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                          <rect x="2" y="5" width="20" height="14" rx="2"></rect>
                          <line x1="2" y1="10" x2="22" y2="10"></line>
                        </svg>
                      </div>
                      <div class="sm-card-title">Xem lương cơ bản</div>
                      <div class="sm-card-desc">
                        Quản lý mức lương cơ bản (Base Salary) hợp đồng cho toàn bộ nhân viên.
                      </div>
                    </div>
                    <div class="sm-card-footer">
                      <a href="base-salaries" class="btn-sm-action btn-action-primary">
                        Truy cập ngay →
                      </a>
                    </div>
                  </div>

                  <!-- Option Card 2: Quản lý các kỳ lương -->
                  <div class="sm-card">
                    <div>
                      <div class="sm-card-icon-wrapper icon-emerald">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                          stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                          <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                          <line x1="16" y1="2" x2="16" y2="6"></line>
                          <line x1="8" y1="2" x2="8" y2="6"></line>
                          <line x1="3" y1="10" x2="21" y2="10"></line>
                        </svg>
                      </div>
                      <div class="sm-card-title">Quản lý kỳ lương</div>
                      <div class="sm-card-desc">
                        Tạo mới, chỉnh sửa chu kỳ thời gian, chốt sổ/khóa hoặc mở khóa các kỳ tính lương nhân viên.
                      </div>
                    </div>
                    <div class="sm-card-footer">
                      <a href="pay-periods" class="btn-sm-action btn-action-emerald">
                        Quản lý kỳ lương →
                      </a>
                    </div>
                  </div>

                  <!-- Option Card 3: Xem Bảng lương các kỳ -->
                  <div class="sm-card">
                    <div>
                      <div class="sm-card-icon-wrapper icon-indigo">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                          stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                          <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                          <polyline points="14 2 14 8 20 8"></polyline>
                          <line x1="16" y1="13" x2="8" y2="13"></line>
                          <line x1="16" y1="17" x2="8" y2="17"></line>
                          <polyline points="10 9 9 9 8 9"></polyline>
                        </svg>
                      </div>
                      <div class="sm-card-title">Xem bảng lương chi tiết</div>
                      <div class="sm-card-desc">
                        Lựa chọn từng kỳ lương để kiểm tra toàn bộ phiếu lương nhân viên, phụ cấp, OT, BHXH và thuế
                        TNCN.
                      </div>
                    </div>
                    <div class="sm-card-footer">
                      <a href="payslips" class="btn-sm-action btn-action-indigo">
                        Xem bảng lương →
                      </a>
                    </div>
                  </div>

                  <!-- Option Card 4: Quản lý Phụ cấp -->
                  <div class="sm-card">
                    <div>
                      <div class="sm-card-icon-wrapper icon-amber">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                          stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                          <rect x="2" y="6" width="20" height="12" rx="2"></rect>
                          <circle cx="12" cy="12" r="2"></circle>
                          <path d="M6 12h.01M18 12h.01"></path>
                        </svg>
                      </div>
                      <div class="sm-card-title">Quản lý phụ cấp</div>
                      <div class="sm-card-desc">
                        Thiết lập danh mục phụ cấp, định mức, và các quy định tính thuế TNCN, đóng BHXH.
                      </div>
                    </div>
                    <div class="sm-card-footer">
                      <a href="allowances" class="btn-sm-action btn-action-amber">
                        Cấu hình phụ cấp →
                      </a>
                    </div>
                  </div>

                  <!-- Option Card 5: Cấu hình tham số lương -->
                  <div class="sm-card">
                    <div>
                      <div class="sm-card-icon-wrapper icon-purple">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                          stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                          <circle cx="12" cy="12" r="3"></circle>
                          <path
                            d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z">
                          </path>
                        </svg>
                      </div>
                      <div class="sm-card-title">Cấu hình Tham số Lương</div>
                      <div class="sm-card-desc">
                        Thiết lập các tham số lương, tỷ lệ bảo hiểm xã hội, mức giảm trừ gia cảnh và biến động hệ số OT.
                      </div>
                    </div>
                    <div class="sm-card-footer">
                      <a href="payroll-configs" class="btn-sm-action btn-action-purple">
                        Cấu hình ngay →
                      </a>
                    </div>
                  </div>

                </div>
              </div>


              <!-- FOOTER -->
              <footer>© 2026 Hệ thống Quản lý Nhân sự (EMS) · FPT University SWP391</footer>
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
            </script>

          </body>

        </html>