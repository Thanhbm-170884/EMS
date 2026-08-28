package com.ems.controller;

import com.ems.dto.TimesheetPeriodDTO;
import com.ems.service.TimesheetPeriodService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Date;
import java.util.Collections;
import java.util.List;

@WebServlet(name = "PayPeriodServlet", urlPatterns = {"/pay-periods", "/pay_periods", "/pay-period", "/pay_period"})
public class PayPeriodServlet extends HttpServlet {
    private final TimesheetPeriodService periodService = new TimesheetPeriodService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String search = request.getParameter("search");
        String statusFilter = request.getParameter("status");
        String sortBy = request.getParameter("sortBy");
        String sortOrder = request.getParameter("sortOrder");

        if (sortBy == null || sortBy.trim().isEmpty()) sortBy = "startdate";
        if (sortOrder == null || sortOrder.trim().isEmpty()) sortOrder = "DESC";

        List<TimesheetPeriodDTO> allPeriods = periodService.getPeriods(search, statusFilter, sortBy, sortOrder);

        int totalPeriodsCount = periodService.getTotalPeriodsCount();
        int activePeriodsCount = periodService.getActivePeriodsCount();
        int lockedPeriodsCount = periodService.getLockedPeriodsCount();

        // Pagination
        int page = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
            } catch (NumberFormatException ignored) {}
        }
        if (page < 1) page = 1;

        int pageSize = 5;
        String pageSizeParam = request.getParameter("pageSize");
        if (pageSizeParam != null && !pageSizeParam.trim().isEmpty()) {
            try {
                pageSize = Integer.parseInt(pageSizeParam);
            } catch (NumberFormatException ignored) {}
        }
        if (pageSize < 1) pageSize = 5;

        int totalFilteredItems = allPeriods.size();
        int totalPages = (int) Math.ceil((double) totalFilteredItems / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        int fromIndex = (page - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalFilteredItems);

        List<TimesheetPeriodDTO> pagedPeriods = (fromIndex < totalFilteredItems)
                ? allPeriods.subList(fromIndex, toIndex)
                : Collections.emptyList();

        // Pass Toast message from session if available
        HttpSession session = request.getSession();
        String toastMessage = (String) session.getAttribute("toastMessage");
        String toastType = (String) session.getAttribute("toastType");
        if (toastMessage != null) {
            request.setAttribute("toastMessage", toastMessage);
            request.setAttribute("toastType", toastType != null ? toastType : "success");
            session.removeAttribute("toastMessage");
            session.removeAttribute("toastType");
        }

        request.setAttribute("periods", pagedPeriods);
        request.setAttribute("allFilteredPeriods", allPeriods);
        request.setAttribute("totalFilteredItems", totalFilteredItems);
        request.setAttribute("totalPeriodsCount", totalPeriodsCount);
        request.setAttribute("activePeriodsCount", activePeriodsCount);
        request.setAttribute("lockedPeriodsCount", lockedPeriodsCount);

        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);

        request.setAttribute("search", search != null ? search : "");
        request.setAttribute("selectedStatus", statusFilter != null ? statusFilter : "");
        request.setAttribute("sortBy", sortBy);
        request.setAttribute("sortOrder", sortOrder);

        request.getRequestDispatcher("/pay-period-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        String action = request.getParameter("action");
        if (action == null) action = "";

        try {
            switch (action) {
                case "create": {
                    String name = request.getParameter("name");
                    String startDateStr = request.getParameter("startDate");
                    String endDateStr = request.getParameter("endDate");
                    String isLockedStr = request.getParameter("isLocked");

                    if (name == null || name.trim().isEmpty() || startDateStr == null || endDateStr == null) {
                        session.setAttribute("toastMessage", "Vui lòng nhập đầy đủ thông tin kỳ lương!");
                        session.setAttribute("toastType", "error");
                    } else {
                        Date startDate = Date.valueOf(startDateStr);
                        Date endDate = Date.valueOf(endDateStr);

                        if (endDate.before(startDate)) {
                            session.setAttribute("toastMessage", "Ngày kết thúc không được nhỏ hơn ngày bắt đầu!");
                            session.setAttribute("toastType", "error");
                        } else {
                            if (periodService.isDuplicatePeriod(name.trim(), startDate, endDate, null)) {
                                session.setAttribute("toastMessage", "Kỳ lương đã tồn tại hoặc bị trùng lặp thời gian!");
                                session.setAttribute("toastType", "error");
                            } else {
                                TimesheetPeriodDTO dto = new TimesheetPeriodDTO();
                                dto.setName(name.trim());
                            dto.setStartDate(startDate);
                            dto.setEndDate(endDate);
                            dto.setLocked("true".equalsIgnoreCase(isLockedStr) || "on".equalsIgnoreCase(isLockedStr) || "1".equals(isLockedStr));

                            boolean success = periodService.createPeriod(dto);
                            if (success) {
                                session.setAttribute("toastMessage", "Tạo kỳ lương mới thành công!");
                                session.setAttribute("toastType", "success");
                            } else {
                                session.setAttribute("toastMessage", "Tạo kỳ lương thất bại. Vui lòng thử lại!");
                                session.setAttribute("toastType", "error");
                            }
                        }
                    }
                    }
                    break;
                }
                case "update": {
                    String idStr = request.getParameter("id");
                    String name = request.getParameter("name");
                    String startDateStr = request.getParameter("startDate");
                    String endDateStr = request.getParameter("endDate");
                    String isLockedStr = request.getParameter("isLocked");

                    if (idStr == null || name == null || name.trim().isEmpty()) {
                        session.setAttribute("toastMessage", "Thông tin cập nhật không hợp lệ!");
                        session.setAttribute("toastType", "error");
                    } else {
                        int id = Integer.parseInt(idStr);
                        Date startDate = Date.valueOf(startDateStr);
                        Date endDate = Date.valueOf(endDateStr);

                        if (endDate.before(startDate)) {
                            session.setAttribute("toastMessage", "Ngày kết thúc không được nhỏ hơn ngày bắt đầu!");
                            session.setAttribute("toastType", "error");
                        } else {
                            if (periodService.isDuplicatePeriod(name.trim(), startDate, endDate, id)) {
                                session.setAttribute("toastMessage", "Kỳ lương đã tồn tại hoặc bị trùng lặp thời gian!");
                                session.setAttribute("toastType", "error");
                            } else {
                                TimesheetPeriodDTO existingPeriod = periodService.getPeriodById(id);
                                boolean currentLockStatus = (existingPeriod != null) ? existingPeriod.isLocked() : false;
                                if (isLockedStr != null && !isLockedStr.trim().isEmpty()) {
                                    currentLockStatus = "true".equalsIgnoreCase(isLockedStr) || "on".equalsIgnoreCase(isLockedStr) || "1".equals(isLockedStr);
                                }

                                TimesheetPeriodDTO dto = new TimesheetPeriodDTO();
                                dto.setId(id);
                                dto.setName(name.trim());
                                dto.setStartDate(startDate);
                                dto.setEndDate(endDate);
                                dto.setLocked(currentLockStatus);

                            boolean success = periodService.updatePeriod(dto);
                            if (success) {
                                session.setAttribute("toastMessage", "Cập nhật thông tin kỳ lương thành công!");
                                session.setAttribute("toastType", "success");
                            } else {
                                session.setAttribute("toastMessage", "Cập nhật kỳ lương thất bại!");
                                session.setAttribute("toastType", "error");
                            }
                        }
                    }
                    }
                    break;
                }
                case "toggle-lock": {
                    String idStr = request.getParameter("id");
                    if (idStr != null) {
                        int id = Integer.parseInt(idStr);
                        TimesheetPeriodDTO existing = periodService.getPeriodById(id);
                        boolean success = periodService.toggleLockStatus(id);
                        if (success) {
                            String lockStateName = (existing != null && existing.isLocked()) ? "Mở khóa" : "Chốt/Khóa";
                            session.setAttribute("toastMessage", lockStateName + " kỳ lương thành công!");
                            session.setAttribute("toastType", "success");
                        } else {
                            session.setAttribute("toastMessage", "Thay đổi trạng thái thất bại!");
                            session.setAttribute("toastType", "error");
                        }
                    }
                    break;
                }

                default:
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("toastMessage", "Đã xảy ra lỗi: " + e.getMessage());
            session.setAttribute("toastType", "error");
        }

        // Build redirect URL preserving filters
        String search = request.getParameter("search");
        String statusFilter = request.getParameter("status");
        String pageParam = request.getParameter("page");
        String pageSizeParam = request.getParameter("pageSize");

        StringBuilder redirectUrl = new StringBuilder(request.getContextPath() + "/pay-periods?");
        if (search != null && !search.trim().isEmpty()) {
            redirectUrl.append("search=").append(URLEncoder.encode(search.trim(), "UTF-8")).append("&");
        }
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            redirectUrl.append("status=").append(statusFilter.trim()).append("&");
        }
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            redirectUrl.append("page=").append(pageParam).append("&");
        }
        if (pageSizeParam != null && !pageSizeParam.trim().isEmpty()) {
            redirectUrl.append("pageSize=").append(pageSizeParam).append("&");
        }

        response.sendRedirect(redirectUrl.toString());
    }
}

