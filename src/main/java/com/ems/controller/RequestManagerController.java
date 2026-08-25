package com.ems.controller;

import com.ems.dao.RequestDAO;
import com.ems.dao.EmployeeBalanceDAO;
import com.ems.dto.RequestDTO;
import com.ems.dto.EmployeeBalanceDTO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.util.List;

public class RequestManagerController {

    private final RequestDAO dao = new RequestDAO();
    private final EmployeeBalanceDAO balanceDao = new EmployeeBalanceDAO();

    public void pending(
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        HttpSession session = request.getSession();

        Integer accountId = (Integer) session.getAttribute("accountId");

        if (accountId == null) {
            response.sendRedirect("login");
            return;
        }

        String role = (String) session.getAttribute("role");
        if (role == null || !"manager".equalsIgnoreCase(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        // 1. Get filter params
        String tab = request.getParameter("tab");
        if (tab == null || tab.trim().isEmpty()) {
            tab = "Pending";
        }
        String searchName = request.getParameter("searchName");
        String filterType = request.getParameter("filterType");

        // 2. Fetch all requests
        List<RequestDTO> allRequests = dao.getAll();

        // 3. Extract request types for dropdown
        java.util.Set<String> allRequestTypes = new java.util.LinkedHashSet<>();
        if (allRequests != null) {
            for (RequestDTO item : allRequests) {
                if (item.getRequestTypeName() != null) {
                    allRequestTypes.add(item.getRequestTypeName());
                }
            }
        }

        // 4. Load selected request for detail view if id is provided
        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                int id = Integer.parseInt(idParam.trim());
                RequestDTO selectedRequest = dao.getById(id);
                request.setAttribute("selectedRequest", selectedRequest);
            } catch (NumberFormatException ignored) {
            }
        }

        // 5. Filter list for presentation
        List<RequestDTO> filteredList = allRequests;
        if (filteredList != null) {
            String finalTab = tab;
            filteredList = filteredList.stream().filter(item -> {
                String itemStatus = item.getStatus() == null ? "" : item.getStatus();
                boolean tabOk = "Pending".equalsIgnoreCase(finalTab)
                        ? "Pending".equalsIgnoreCase(itemStatus)
                        : ("Approved".equalsIgnoreCase(itemStatus) || "Rejected".equalsIgnoreCase(itemStatus));

                String employeeName = item.getCreatedByName() == null ? "" : item.getCreatedByName();
                boolean nameOk = searchName == null || searchName.trim().isEmpty()
                        || employeeName.toLowerCase().contains(searchName.trim().toLowerCase());

                String typeName = item.getRequestTypeName() == null ? "" : item.getRequestTypeName();
                boolean typeOk = filterType == null || filterType.trim().isEmpty()
                        || typeName.equalsIgnoreCase(filterType.trim());

                return tabOk && nameOk && typeOk;
            }).collect(java.util.stream.Collectors.toList());
        }
        request.setAttribute("requests", filteredList);
        request.setAttribute("allRequestTypes", allRequestTypes);
        request.setAttribute("tab", tab);
        request.setAttribute("searchName", searchName);
        request.setAttribute("filterType", filterType);

        request.getRequestDispatcher(
                "/request-manager.jsp").forward(request, response);
    }

    public void employeeBalances(
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");
        if (role == null || !"manager".equalsIgnoreCase(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        List<EmployeeBalanceDTO> list = balanceDao.getAllEmployeeBalances();
        request.setAttribute("balances", list);

        request.getRequestDispatcher(
                "/employee-balances.jsp").forward(request, response);
    }

    public void ajaxDetail(
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        int id = Integer.parseInt(request.getParameter("id"));
        RequestDTO dto = dao.getById(id);
        if (dto == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        request.setAttribute("selectedRequest", dto);
        request.getRequestDispatcher("/request-manager.jsp").forward(request, response);
    }

    public void approve(
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        updateStatus(request, response, "Approved");
    }

    public void reject(
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        updateStatus(request, response, "Rejected");
    }

    private void updateStatus(
            HttpServletRequest request,
            HttpServletResponse response,
            String status) throws Exception {

        HttpSession session = request.getSession(false);
        Integer accountId = session == null ? null : (Integer) session.getAttribute("accountId");
        String role = session == null ? null : (String) session.getAttribute("role");

        if (accountId == null || role == null || !"manager".equalsIgnoreCase(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        int id = Integer.parseInt(request.getParameter("id"));
        String rejectionReason = request.getParameter("rejectionReason");
        if (rejectionReason != null) {
            rejectionReason = rejectionReason.trim();
        }

        RequestDTO req = dao.getById(id);

        if (!dao.updateStatusForApprover(id, accountId, status, rejectionReason)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        if ("Approved".equalsIgnoreCase(status) && req != null) {
            if (req.getRequestTypeId() == 1) {
                balanceDao.deductLeaveDays(req.getCreatedByAccountId(), req.getValue());
            }
        }

        response.sendRedirect(
                request.getContextPath()
                        + "/requests?action=pending");
    }
}
