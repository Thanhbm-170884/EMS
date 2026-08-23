package com.ems.controller;

import com.ems.dto.BaseSalaryDTO;
import com.ems.dto.SalarySummaryDTO;
import com.ems.model.Departments;
import com.ems.model.Positions;
import com.ems.service.BaseSalaryService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "BaseSalaryServlet", urlPatterns = {"/base-salaries", "/base-salary"})
public class BaseSalaryServlet extends HttpServlet {

    private final BaseSalaryService baseSalaryService = new BaseSalaryService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String search = request.getParameter("search");
        String deptIdParam = request.getParameter("departmentId");
        String posIdParam = request.getParameter("positionId");
        String sortBy = request.getParameter("sortBy");
        String sortOrder = request.getParameter("sortOrder");

        Integer departmentId = null;
        if (deptIdParam != null && !deptIdParam.trim().isEmpty()) {
            try {
                departmentId = Integer.parseInt(deptIdParam);
            } catch (NumberFormatException ignored) {
            }
        }

        Integer positionId = null;
        if (posIdParam != null && !posIdParam.trim().isEmpty()) {
            try {
                positionId = Integer.parseInt(posIdParam);
            } catch (NumberFormatException ignored) {
            }
        }

        List<BaseSalaryDTO> allFilteredBaseSalaries = baseSalaryService.getBaseSalaries(search, departmentId, positionId, sortBy, sortOrder);
        SalarySummaryDTO summary = baseSalaryService.getSalarySummary(search, departmentId, positionId);
        int totalEmployeesCount = baseSalaryService.getTotalEmployeeCount();
        List<Departments> departments = baseSalaryService.getAllDepartments();
        List<Positions> positions = baseSalaryService.getAllPositions();

        // Pagination handling
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

        int totalFilteredItems = allFilteredBaseSalaries.size();
        int totalPages = (int) Math.ceil((double) totalFilteredItems / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        int fromIndex = (page - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalFilteredItems);

        List<BaseSalaryDTO> pagedBaseSalaries = (fromIndex < totalFilteredItems)
                ? allFilteredBaseSalaries.subList(fromIndex, toIndex)
                : java.util.Collections.emptyList();

        request.setAttribute("baseSalaries", pagedBaseSalaries);
        request.setAttribute("allFilteredSalaries", allFilteredBaseSalaries);
        request.setAttribute("summary", summary);
        request.setAttribute("totalEmployeesCount", totalEmployeesCount > 0 ? totalEmployeesCount : summary.getTotalEmployees());
        request.setAttribute("totalFilteredItems", totalFilteredItems);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("departments", departments);
        request.setAttribute("positions", positions);

        request.setAttribute("search", search != null ? search : "");
        request.setAttribute("selectedDepartmentId", departmentId);
        request.setAttribute("selectedPositionId", positionId);
        request.setAttribute("sortBy", sortBy != null ? sortBy : "code");
        request.setAttribute("sortOrder", sortOrder != null ? sortOrder : "ASC");

        request.getRequestDispatcher("/base-salary-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String userIdParam = request.getParameter("userId");
        String baseSalaryParam = request.getParameter("baseSalary");
        String dependentsCountParam = request.getParameter("dependentsCount");

        if (userIdParam != null && baseSalaryParam != null) {
            try {
                int userId = Integer.parseInt(userIdParam);
                String cleanSalaryStr = baseSalaryParam.replaceAll("[^0-9.eE+\\-]", "");
                java.math.BigDecimal baseSalary = new java.math.BigDecimal(cleanSalaryStr);
                
                int dependentsCount = 0;
                if (dependentsCountParam != null && !dependentsCountParam.trim().isEmpty()) {
                    dependentsCount = Integer.parseInt(dependentsCountParam);
                }
                if (dependentsCount < 0) dependentsCount = 0;

                baseSalaryService.updateBaseSalaryAndDependents(userId, baseSalary, dependentsCount);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        // Redirect preserving parameters if needed
        String search = request.getParameter("search");
        String deptIdParam = request.getParameter("departmentId");
        String posIdParam = request.getParameter("positionId");
        String pageParam = request.getParameter("page");

        StringBuilder redirectUrl = new StringBuilder(request.getContextPath() + "/base-salaries?");
        if (search != null && !search.trim().isEmpty()) {
            redirectUrl.append("search=").append(java.net.URLEncoder.encode(search, "UTF-8")).append("&");
        }
        if (deptIdParam != null && !deptIdParam.trim().isEmpty()) {
            redirectUrl.append("departmentId=").append(deptIdParam).append("&");
        }
        if (posIdParam != null && !posIdParam.trim().isEmpty()) {
            redirectUrl.append("positionId=").append(posIdParam).append("&");
        }
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            redirectUrl.append("page=").append(pageParam).append("&");
        }

        response.sendRedirect(redirectUrl.toString());
    }
}
