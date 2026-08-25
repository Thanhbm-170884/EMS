package com.ems.controller;

import com.ems.dao.RequestDAO;
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

    public void list(
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        List<RequestDTO> list = dao.getAll();

        request.setAttribute("requests", list);

        request.getRequestDispatcher(
                "/WEB-INF/views/request/list.jsp").forward(request, response);
    }

    public void detail(
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        int id = Integer.parseInt(
                request.getParameter("id"));

        RequestDTO requestDTO = dao.getById(id);

        if (requestDTO == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        request.setAttribute("request", requestDTO);

        request.getRequestDispatcher(
                "/WEB-INF/views/request/detail.jsp").forward(request, response);
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

        // Pagination handling
        int page = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
            } catch (NumberFormatException ignored) {
            }
        }
        if (page < 1)
            page = 1;

        int pageSize = 5;
        String pageSizeParam = request.getParameter("pageSize");
        if (pageSizeParam != null && !pageSizeParam.trim().isEmpty()) {
            try {
                pageSize = Integer.parseInt(pageSizeParam);
            } catch (NumberFormatException ignored) {
            }
        }
        if (pageSize < 1)
            pageSize = 5;

        int totalFilteredItems = list.size();
        int totalPages = (int) Math.ceil((double) totalFilteredItems / pageSize);
        if (totalPages < 1)
            totalPages = 1;
        if (page > totalPages)
            page = totalPages;

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

        request.getRequestDispatcher(
                "/requestList.jsp").forward(request, response);
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
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");

        int requestTypeId = Integer.parseInt(
                request.getParameter("requestTypeId"));

        String imageUrl = null;
        String contentType = request.getContentType();
        if (contentType != null && contentType.toLowerCase().startsWith("multipart/")) {
            imageUrl = saveUploadedImage(request, servletContext);
        }

        RequestDTO dto = new RequestDTO();

        dto.setTitle(title);
        dto.setReason(reason);
        
        if (requestTypeId == 3) {
            Timestamp now = new Timestamp(System.currentTimeMillis());
            dto.setStartDate(now);
            dto.setEndDate(now);
        } else {
            dto.setStartDate(parseTimestamp(startDate));
            dto.setEndDate(parseTimestamp(endDate));
        }

        String value = request.getParameter("value");
        dto.setValue(value == null || value.isBlank() ? 1 : Double.parseDouble(value));
        dto.setImageUrl(imageUrl);
        dto.setRequestTypeId(requestTypeId);
        dto.setCreatedByAccountId(accountId);
        dto.setStatus("Pending");

        dao.insert(dto);

        response.sendRedirect(
                request.getContextPath()
                        + "/requests?action=myRequests");
    }

    public void delete(
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        int id = Integer.parseInt(
                request.getParameter("id"));

        dao.delete(id);

        response.sendRedirect(
                request.getContextPath()
                        + "/requests?action=myRequests");
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
