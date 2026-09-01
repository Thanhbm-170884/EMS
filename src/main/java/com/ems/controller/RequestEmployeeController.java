package com.ems.controller;

import com.ems.dao.EmployeeBalanceDAO;
import com.ems.dao.RequestDAO;
import com.ems.dto.EmployeeBalanceDTO;
import com.ems.dto.RequestDTO;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.sql.Timestamp;
import java.util.List;
import java.util.UUID;

public class RequestEmployeeController {

    private final RequestDAO dao = new RequestDAO();
    private final EmployeeBalanceDAO balanceDAO = new EmployeeBalanceDAO();

    /**
     * Load data (remainingDays, gender) rồi forward sang request.jsp để hiển thị form.
     */
    public void showForm(
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("accountId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer accountId = (Integer) session.getAttribute("accountId");

        // Lấy thông tin phép năm đầy đủ từ EmployeeBalanceDAO
        EmployeeBalanceDTO leaveBalance = getLeaveBalance(accountId);
        Boolean gender = dao.getGenderByAccountId(accountId);

        request.setAttribute("leaveBalance", leaveBalance);
        // gender: true = male (1), false = female (0), null = unknown
        request.setAttribute("gender", gender);

        request.getRequestDispatcher("/request.jsp").forward(request, response);
    }

    public void list(
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        List<RequestDTO> list = dao.getAll();
        request.setAttribute("requests", list);
        request.getRequestDispatcher("/WEB-INF/views/request/list.jsp").forward(request, response);
    }

    public void detail(
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        int id = Integer.parseInt(request.getParameter("id"));
        RequestDTO requestDTO = dao.getById(id);

        if (requestDTO == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        request.setAttribute("request", requestDTO);
        request.getRequestDispatcher("/WEB-INF/views/request/detail.jsp").forward(request, response);
    }

    public void myRequests(
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        HttpSession session = request.getSession();
        Integer accountId = (Integer) session.getAttribute("accountId");

        if (accountId == null) {
            response.sendRedirect("login");
            return;
        }

        List<RequestDTO> list = dao.getByCreatedByAccountId(accountId);

        int page = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try { page = Integer.parseInt(pageParam); } catch (NumberFormatException ignored) {}
        }
        if (page < 1) page = 1;

        int pageSize = 5;
        String pageSizeParam = request.getParameter("pageSize");
        if (pageSizeParam != null && !pageSizeParam.trim().isEmpty()) {
            try { pageSize = Integer.parseInt(pageSizeParam); } catch (NumberFormatException ignored) {}
        }
        if (pageSize < 1) pageSize = 5;

        int totalFilteredItems = list.size();
        int totalPages = (int) Math.ceil((double) totalFilteredItems / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        int fromIndex = (page - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalFilteredItems);

        List<RequestDTO> pagedRequests = (fromIndex < totalFilteredItems)
                ? list.subList(fromIndex, toIndex)
                : java.util.Collections.emptyList();

        request.setAttribute("requests", pagedRequests);
        request.setAttribute("totalFilteredItems", totalFilteredItems);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);

        request.getRequestDispatcher("/requestList.jsp").forward(request, response);
    }

    public void insert(
            HttpServletRequest request,
            HttpServletResponse response,
            ServletContext servletContext) throws Exception {

        HttpSession session = request.getSession();
        Integer accountId = (Integer) session.getAttribute("accountId");

        if (accountId == null) {
            response.sendRedirect("login");
            return;
        }

        String title = request.getParameter("title");
        String reason = request.getParameter("reason");
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");
        String requestTypeCode = request.getParameter("requestTypeCode");
        String valueStr = request.getParameter("value");

        // ---- Resolve requestTypeId from Code ----
        int requestTypeId = -1;
        if (requestTypeCode != null && !requestTypeCode.isEmpty()) {
            requestTypeId = dao.getRequestTypeIdByCode(requestTypeCode);
        }
        // Fallback: try direct ID param
        if (requestTypeId == -1) {
            String idParam = request.getParameter("requestTypeId");
            if (idParam != null && !idParam.isEmpty()) {
                try { requestTypeId = Integer.parseInt(idParam); } catch (NumberFormatException ignored) {}
            }
        }

        // Guard: loại đơn không tồn tại trong DB → báo lỗi rõ ràng
        if (requestTypeId == -1) {
            forwardWithError(request, response, accountId,
                    "Loại đơn \"" + (requestTypeCode != null ? requestTypeCode : "") +
                    "\" chưa được cấu hình trong hệ thống. Vui lòng liên hệ quản trị viên để thêm loại đơn vào database.",
                    requestTypeCode);
            return;
        }

        Timestamp startDate = parseTimestamp(startDateStr);
        Timestamp endDate   = parseTimestamp(endDateStr);

        // ---- Common Server-Side Validation ----
        java.time.LocalDate today = java.time.LocalDate.now();

        // 1. Start date must not be in the past
        if (startDate != null) {
            java.time.LocalDate start = startDate.toLocalDateTime().toLocalDate();
            if (start.isBefore(today)) {
                forwardWithError(request, response, accountId,
                        "Ngày bắt đầu không được ở trong quá khứ.", requestTypeCode);
                return;
            }
        }

        // 2. Start <= End
        if (startDate != null && endDate != null && startDate.after(endDate)) {
            forwardWithError(request, response, accountId,
                    "Ngày bắt đầu phải trước hoặc bằng ngày kết thúc.", requestTypeCode);
            return;
        }

        // 3. Overlapping with approved requests
        if (startDate != null && endDate != null) {
            if (dao.hasOverlappingApprovedRequest(accountId, startDate, endDate)) {
                forwardWithError(request, response, accountId,
                        "Khoảng thời gian này đã có đơn được duyệt. Vui lòng chọn ngày khác.", requestTypeCode);
                return;
            }
        }

        double days = 0;
        if (valueStr != null && !valueStr.isBlank()) {
            try { days = Double.parseDouble(valueStr); } catch (NumberFormatException ignored) {}
        }

        // ---- Per-type Validation ----
        if (requestTypeCode != null) {
            switch (requestTypeCode) {
                case "ANNUAL": {
                    EmployeeBalanceDTO balance = getLeaveBalance(accountId);
                    int usedDays = (balance != null) ? balance.getUsedDays() : 0;
                    int totalDays = (balance != null) ? balance.getTotalDays() : 12;
                    int remaining = (balance != null) ? balance.getRemainingDays() : (totalDays - usedDays);
                    // Chặn nếu đã dùng đủ 12 ngày (usedDays >= totalDays)
                    if (usedDays >= totalDays) {
                        forwardWithError(request, response, accountId,
                                "Bạn đã sử dụng hết " + usedDays + "/" + totalDays + " ngày phép năm. Không thể gửi thêm đơn nghỉ phép năm.", requestTypeCode);
                        return;
                    }
                    if (remaining >= 0 && days > remaining) {
                        forwardWithError(request, response, accountId,
                                "Số ngày xin nghỉ (" + (int)days + " ngày) vượt quá số ngày phép còn lại (" + remaining + " ngày). Đã dùng: " + usedDays + "/" + totalDays + " ngày.", requestTypeCode);
                        return;
                    }
                    break;
                }
                case "UNPAID": {
                    int unpaidTypeId = dao.getRequestTypeIdByCode("UNPAID");
                    double usedUnpaid = dao.getUsedSickLeaveDaysThisYear(accountId, unpaidTypeId);
                    if (days + usedUnpaid > 30) {
                        forwardWithError(request, response, accountId,
                                "Tổng số ngày nghỉ không lương trong năm không được vượt quá 30 ngày. Đã sử dụng: " + (int)usedUnpaid + " ngày.", requestTypeCode);
                        return;
                    }
                    break;
                }
                case "SICK": {
                    int sickTypeId = dao.getRequestTypeIdByCode("SICK");
                    double usedSick = dao.getUsedSickLeaveDaysThisYear(accountId, sickTypeId);
                    if (days + usedSick > 60) {
                        forwardWithError(request, response, accountId,
                                "Tổng số ngày nghỉ ốm hưởng BHXH trong năm không được vượt quá 60 ngày. Đã sử dụng: " + (int)usedSick + " ngày.", requestTypeCode);
                        return;
                    }
                    if (days > 3) {
                        Part imgPart = null;
                        try { imgPart = request.getPart("image"); } catch (Exception ignored) {}
                        if (imgPart == null || imgPart.getSize() == 0) {
                            forwardWithError(request, response, accountId,
                                    "Nghỉ ốm trên 3 ngày bắt buộc đính kèm giấy xác nhận y tế.", requestTypeCode);
                            return;
                        }
                    }
                    break;
                }
                case "MARRIAGE": {
                    Part imgPart = null;
                    try { imgPart = request.getPart("image"); } catch (Exception ignored) {}
                    if (imgPart == null || imgPart.getSize() == 0) {
                        forwardWithError(request, response, accountId,
                                "Nghỉ kết hôn bắt buộc đính kèm giấy đăng ký kết hôn.", requestTypeCode);
                        return;
                    }
                    break;
                }
                case "CHILD_MARRIAGE": {
                    Part imgPart = null;
                    try { imgPart = request.getPart("image"); } catch (Exception ignored) {}
                    if (imgPart == null || imgPart.getSize() == 0) {
                        forwardWithError(request, response, accountId,
                                "Nghỉ con kết hôn bắt buộc đính kèm giấy tờ chứng minh.", requestTypeCode);
                        return;
                    }
                    break;
                }
                case "FUNERAL": {
                    Part imgPart = null;
                    try { imgPart = request.getPart("image"); } catch (Exception ignored) {}
                    if (imgPart == null || imgPart.getSize() == 0) {
                        forwardWithError(request, response, accountId,
                                "Nghỉ tang bắt buộc đính kèm giấy báo tử hoặc giấy tờ liên quan.", requestTypeCode);
                        return;
                    }
                    break;
                }
                case "MATERNITY": {
                    Part imgPart = null;
                    try { imgPart = request.getPart("image"); } catch (Exception ignored) {}
                    if (imgPart == null || imgPart.getSize() == 0) {
                        forwardWithError(request, response, accountId,
                                "Nghỉ thai sản bắt buộc đính kèm giấy khai sinh hoặc giấy chứng sinh.", requestTypeCode);
                        return;
                    }
                    Boolean isMale = dao.getGenderByAccountId(accountId);
                    if (isMale != null) {
                        if (isMale && days > 14) {
                            forwardWithError(request, response, accountId,
                                    "Nam giới nghỉ thai sản tối đa 14 ngày theo quy định.", requestTypeCode);
                            return;
                        }
                        if (!isMale && days > 180) {
                            forwardWithError(request, response, accountId,
                                    "Nghỉ thai sản tối đa 6 tháng (180 ngày) theo quy định.", requestTypeCode);
                            return;
                        }
                    }
                    break;
                }
            }
        }

        // ---- Upload image ----
        String imageUrl = null;
        String contentType = request.getContentType();
        if (contentType != null && contentType.toLowerCase().startsWith("multipart/")) {
            try {
                imageUrl = saveUploadedImage(request, servletContext);
            } catch (ServletException e) {
                forwardWithError(request, response, accountId, e.getMessage(), requestTypeCode);
                return;
            }
        }

        // ---- Build DTO and Insert ----
        // Tra cứu manager (HeadAccountId) của phòng ban employee để định tuyến đơn
        Integer managerAccountId = dao.getManagerAccountIdByEmployeeAccountId(accountId);

        RequestDTO dto = new RequestDTO();
        dto.setTitle(title);
        dto.setReason(reason);
        dto.setStartDate(startDate);
        dto.setEndDate(endDate);
        dto.setValue(days > 0 ? days : 1);
        dto.setImageUrl(imageUrl);
        dto.setRequestTypeId(requestTypeId);
        dto.setCreatedByAccountId(accountId);
        dto.setStatus("Pending");
        dto.setCurrentApproverAccountId(managerAccountId); // Gán manager phòng ban

        dao.insert(dto);

        response.sendRedirect(request.getContextPath() + "/requests?action=myRequests");
    }

    /** Helper: lấy EmployeeBalanceDTO theo accountId thông qua EmployeeBalanceDAO */
    private EmployeeBalanceDTO getLeaveBalance(int accountId) {
        // Lấy userId từ accountId trước
        String sql = "SELECT UserId FROM accounts WHERE Id = ?";
        try (java.sql.Connection conn = com.ems.util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int userId = rs.getInt("UserId");
                    return balanceDAO.getEmployeeBalanceByUserId(userId);
                }
            }
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /** Forward back to the form with an error message and preserved data. */
    private void forwardWithError(
            HttpServletRequest request,
            HttpServletResponse response,
            int accountId,
            String errorMessage,
            String selectedTypeCode) throws Exception {

        EmployeeBalanceDTO leaveBalance = getLeaveBalance(accountId);
        Boolean gender = dao.getGenderByAccountId(accountId);

        request.setAttribute("leaveBalance", leaveBalance);
        request.setAttribute("gender", gender);
        request.setAttribute("errorMessage", errorMessage);
        request.setAttribute("selectedTypeCode", selectedTypeCode);

        request.getRequestDispatcher("/request.jsp").forward(request, response);
    }

    public void delete(
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        int id = Integer.parseInt(request.getParameter("id"));
        dao.delete(id);
        response.sendRedirect(request.getContextPath() + "/requests?action=myRequests");
    }

    private Timestamp parseTimestamp(String dateStr) {
        if (dateStr == null || dateStr.trim().isBlank() || "null".equalsIgnoreCase(dateStr.trim())) {
            return null;
        }
        String cleanStr = dateStr.trim().replace("T", " ");
        if (cleanStr.length() == 10) {
            cleanStr += " 00:00:00";
        } else if (cleanStr.length() == 16) {
            cleanStr += ":00";
        }
        try {
            return Timestamp.valueOf(cleanStr);
        } catch (IllegalArgumentException e) {
            try {
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
                java.util.Date parsed = sdf.parse(cleanStr);
                return new Timestamp(parsed.getTime());
            } catch (Exception ex) {
                System.err.println("Error parsing date: '" + dateStr + "' - " + ex.getMessage());
                return null;
            }
        }
    }

    private String saveUploadedImage(
            HttpServletRequest request,
            ServletContext servletContext) throws IOException, ServletException {

        Part imagePart = request.getPart("image");
        if (imagePart == null || imagePart.getSize() == 0) {
            return null;
        }

        String contentType = imagePart.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new ServletException("Tệp minh chứng phải là ảnh.");
        }

        String submittedFileName = Path.of(imagePart.getSubmittedFileName()).getFileName().toString();
        String extension = "";
        int extensionIndex = submittedFileName.lastIndexOf('.');
        if (extensionIndex >= 0) {
            extension = submittedFileName.substring(extensionIndex).toLowerCase();
        }
        if (!extension.matches("\\.(png|jpe?g|gif|webp)")) {
            throw new ServletException("Định dạng ảnh không được hỗ trợ.");
        }

        Path uploadDirectory = Path.of(servletContext.getRealPath("/uploads"));
        Files.createDirectories(uploadDirectory);

        String storedFileName = UUID.randomUUID() + extension;
        try (InputStream input = imagePart.getInputStream()) {
            Files.copy(input, uploadDirectory.resolve(storedFileName), StandardCopyOption.REPLACE_EXISTING);
        }
        return request.getContextPath() + "/uploads/" + storedFileName;
    }
}
