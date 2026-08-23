<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>EMS – Đăng nhập</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="css/login.css"/>
</head>
<body>
<div class="card">
  <div class="brand">
    <div class="brand-dot">E</div>
    <span class="brand-name">EMS</span>
  </div>
  <div class="form-title">Đăng nhập</div>
  <div class="form-sub">Nhập thông tin tài khoản để tiếp tục</div>

  <% if (request.getAttribute("error") != null) { %>
    <div class="error flash-alert"><%= request.getAttribute("error") %></div>
  <% } %>
  <% if (request.getAttribute("success") != null) { %>
    <div class="success flash-alert" style="background: #ecfdf5; border: 1px solid #a7f3d0; color: #047857; font-size: 13px; padding: 10px 13px; border-radius: 7px; margin-bottom: 16px;"><%= request.getAttribute("success") %></div>
  <% } %>

  <form action="login" method="post" id="loginForm" onsubmit="return validateLoginForm(true)">
    <div style="margin-bottom: 16px;">
      <label for="username">Tên đăng nhập</label>
      <input type="text" id="username" name="username" placeholder="Nhập tên đăng nhập" required autocomplete="username" value="<%= request.getParameter("username") != null ? request.getParameter("username") : "" %>" oninput="validateLoginForm()" style="margin-bottom: 4px;"/>
      <div id="usernameMsg" style="font-size: 12px; min-height: 16px;"></div>
    </div>

    <div style="margin-bottom: 16px;">
      <label for="password">Mật khẩu</label>
      <input type="password" id="password" name="password" placeholder="Nhập mật khẩu" required autocomplete="current-password" oninput="validateLoginForm()" style="margin-bottom: 4px;"/>
      <div id="passwordMsg" style="font-size: 12px; min-height: 16px;"></div>
    </div>

    <a href="forgot-password" style="display: block; text-align: right; font-size: 13px; color: #2563eb; text-decoration: none; margin-top: -4px; margin-bottom: 16px;">Quên mật khẩu?</a>
    <button type="submit" id="loginSubmitBtn">Đăng nhập</button>
  </form>

  <hr/>
  <div class="footer-note">Hệ thống Quản lý Nhân sự · FPT University SWP391</div>
</div>

<script>
  function setFieldStatus(inputEl, msgEl, isValid, message) {
    if (!inputEl || !msgEl) return;
    if (isValid === false) {
      inputEl.style.borderColor = "#ef4444";
      inputEl.style.boxShadow = "0 0 0 3px rgba(239, 68, 68, 0.15)";
      msgEl.style.color = "#ef4444";
      msgEl.textContent = message;
    } else {
      inputEl.style.borderColor = "#d1d5db";
      inputEl.style.boxShadow = "none";
      msgEl.textContent = "";
    }
  }

  function validateLoginForm(isSubmitting) {
    const unInput = document.getElementById("username");
    const unMsg   = document.getElementById("usernameMsg");
    const pwInput = document.getElementById("password");
    const pwMsg   = document.getElementById("passwordMsg");
    const submitBtn = document.getElementById("loginSubmitBtn");

    const rawUn = unInput ? unInput.value : "";
    const rawPw = pwInput ? pwInput.value : "";

    let hasError = false;

    // 1. Kiểm tra Username
    if (rawUn.length > 0) {
      if (/\s/.test(rawUn)) {
        setFieldStatus(unInput, unMsg, false, "Tên đăng nhập không được chứa khoảng trắng!");
        hasError = true;
      } else if (rawUn.trim().length === 0) {
        setFieldStatus(unInput, unMsg, false, "Tên đăng nhập không được chỉ chứa khoảng trắng!");
        hasError = true;
      } else {
        setFieldStatus(unInput, unMsg, true, "");
      }
    } else {
      setFieldStatus(unInput, unMsg, true, "");
    }

    // 2. Kiểm tra Mật khẩu
    if (rawPw.length > 0) {
      if (/\s/.test(rawPw)) {
        setFieldStatus(pwInput, pwMsg, false, "Mật khẩu không được chứa khoảng trắng!");
        hasError = true;
      } else if (rawPw.trim().length === 0) {
        setFieldStatus(pwInput, pwMsg, false, "Mật khẩu không được chỉ chứa khoảng trắng!");
        hasError = true;
      } else {
        setFieldStatus(pwInput, pwMsg, true, "");
      }
    } else {
      setFieldStatus(pwInput, pwMsg, true, "");
    }

    if (submitBtn) {
      submitBtn.disabled = hasError;
      submitBtn.style.opacity = hasError ? "0.5" : "1";
      submitBtn.style.cursor = hasError ? "not-allowed" : "pointer";
    }

    if (isSubmitting && hasError) {
      return false;
    }
    return !hasError;
  }

  // Tự động ẩn thông báo flash sau 2 giây
  setTimeout(function() {
    var alerts = document.querySelectorAll('.flash-alert');
    alerts.forEach(function(alert) {
      alert.style.transition = 'opacity 0.4s ease, transform 0.4s ease, max-height 0.4s ease, margin-bottom 0.4s ease';
      alert.style.opacity = '0';
      alert.style.transform = 'translateY(-8px)';
      alert.style.maxHeight = '0';
      alert.style.marginBottom = '0';
      alert.style.paddingTop = '0';
      alert.style.paddingBottom = '0';
      alert.style.overflow = 'hidden';
      setTimeout(function() {
        alert.remove();
      }, 400);
    });
  }, 2000);
</script>
</body>
</html>
