package com.ems.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/requests")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 6 * 1024 * 1024)
public class RequestController extends HttpServlet {

    private final RequestEmployeeController employeeController = new RequestEmployeeController();
    private final RequestManagerController managerController = new RequestManagerController();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            action = "list";
        }

        try {
            switch (action) {

                case "list":
                    employeeController.list(request, response);
                    break;

                case "detail":
                    employeeController.detail(request, response);
                    break;

                case "ajaxDetail":
                    managerController.ajaxDetail(request, response);
                    break;

                case "myRequests":
                    employeeController.myRequests(request, response);
                    break;

                case "showForm":
                    employeeController.showForm(request, response);
                    break;

                case "pending":
                    managerController.pending(request, response);
                    break;

                case "employeeBalances":
                    managerController.employeeBalances(request, response);
                    break;

                case "create":
                    request.getRequestDispatcher(
                            "/WEB-INF/views/request/create.jsp").forward(request, response);
                    break;

                default:
                    response.sendError(
                            HttpServletResponse.SC_NOT_FOUND);
            }

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        try {
            switch (action) {

                case "insert":
                    employeeController.insert(request, response, getServletContext());
                    break;

                case "approve":
                    managerController.approve(request, response);
                    break;

                case "reject":
                    managerController.reject(request, response);
                    break;

                case "delete":
                    employeeController.delete(request, response);
                    break;

                default:
                    response.sendError(
                            HttpServletResponse.SC_BAD_REQUEST);
            }

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
