package com.ems.servlet;

import com.ems.dao.UserDAO;
import com.ems.dto.UserProfileDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        Object accountIdObj = session.getAttribute("accountId");

        // Chưa đăng nhập
        if (accountIdObj == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        int accountId = (int) accountIdObj;

        UserProfileDTO profile =
                userDAO.findProfileByAccountId(accountId);

        if (profile == null) {
            request.setAttribute(
                    "error",
                    "Không tìm thấy thông tin nhân viên."
            );
        } else {
            request.setAttribute("profile", profile);
        }

        request.getRequestDispatcher(
                "/employee-profile.jsp"
        ).forward(request, response);
    }
}