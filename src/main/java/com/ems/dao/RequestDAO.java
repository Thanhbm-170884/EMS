package com.ems.dao;

import com.ems.dto.RequestDTO;
import com.ems.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class RequestDAO {

    /**
     * Common SELECT query
     */
    private static final String BASE_SELECT = "SELECT " +
            "r.Id, " +
            "r.Title, " +
            "r.Reason, " +
            "r.Status, " +
            "r.StartDate, " +
            "r.EndDate, " +
            "r.Value, " +
            "r.ImageUrl, " +
            "r.CreatedAt, " +
            "r.RequestTypeId, " +
            "rt.Name AS RequestTypeName, " +
            "r.CreatedByAccountId, " +
            "u.FullName AS CreatedByName, " +
            "r.CurrentApproverAccountId, " +
            "au.FullName AS ApproverName, " +
            "r.RejectionReason " +

            "FROM Requests r " +

            "INNER JOIN RequestTypes rt " +
            "ON r.RequestTypeId = rt.Id " +

            "INNER JOIN Accounts ca " +
            "ON r.CreatedByAccountId = ca.Id " +

            "INNER JOIN Users u " +
            "ON ca.UserId = u.Id " +

            "LEFT JOIN Accounts aa " +
            "ON r.CurrentApproverAccountId = aa.Id " +

            "LEFT JOIN Users au " +
            "ON aa.UserId = au.Id ";

    /**
     * Convert ResultSet -> RequestDTO
     */
    private RequestDTO mapResultSet(ResultSet rs) throws SQLException {
        RequestDTO request = new RequestDTO();

        request.setId(rs.getInt("Id"));
        request.setTitle(rs.getString("Title"));
        request.setReason(rs.getString("Reason"));
        request.setStatus(rs.getString("Status"));
        request.setStartDate(rs.getTimestamp("StartDate"));
        request.setEndDate(rs.getTimestamp("EndDate"));
        request.setValue(rs.getDouble("Value"));
        request.setImageUrl(rs.getString("ImageUrl"));
        request.setCreatedAt(rs.getTimestamp("CreatedAt"));

        // Request Type
        request.setRequestTypeId(rs.getInt("RequestTypeId"));
        request.setRequestTypeName(rs.getString("RequestTypeName"));

        // Creator
        request.setCreatedByAccountId(rs.getInt("CreatedByAccountId"));
        request.setCreatedByName(rs.getString("CreatedByName"));

        // Current Approver
        int approverId = rs.getInt("CurrentApproverAccountId");
        if (rs.wasNull()) {
            request.setCurrentApproverAccountId(null);
        } else {
            request.setCurrentApproverAccountId(approverId);
        }
        request.setCurrentApproverName(rs.getString("ApproverName"));
        request.setRejectionReason(rs.getString("RejectionReason"));

        return request;
    }

    /**
     * Get all requests
     */
    public List<RequestDTO> getAll() {
        List<RequestDTO> list = new ArrayList<>();
        String sql = BASE_SELECT + "ORDER BY r.CreatedAt DESC";

        try (Connection connection = DBConnection.getConnection();
                PreparedStatement ps = connection.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get request by ID
     */
    public RequestDTO getById(int id) {
        String sql = BASE_SELECT + "WHERE r.Id = ?";

        try (Connection connection = DBConnection.getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Insert new request
     */
    public boolean insert(RequestDTO request) {
        String sql = "INSERT INTO Requests " +
                "(Title, Reason, Status, StartDate, EndDate, Value, ImageUrl, RequestTypeId, CreatedByAccountId, CurrentApproverAccountId) "
                +
                "VALUES (?, ?, 'Pending', ?, ?, ?, ?, ?, ?, ?)";

        try (Connection connection = DBConnection.getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, request.getTitle());
            ps.setString(2, request.getReason());
            ps.setTimestamp(3, request.getStartDate());
            ps.setTimestamp(4, request.getEndDate());
            ps.setDouble(5, request.getValue());
            ps.setString(6, request.getImageUrl());
            ps.setInt(7, request.getRequestTypeId());
            ps.setInt(8, request.getCreatedByAccountId());

            if (request.getCurrentApproverAccountId() != null) {
                ps.setInt(9, request.getCurrentApproverAccountId());
            } else {
                ps.setNull(9, Types.INTEGER);
            }

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Update request status
     */
    public boolean updateStatus(int requestId, String status) {
        String sql = "UPDATE Requests SET Status = ? WHERE Id = ?";

        try (Connection connection = DBConnection.getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, requestId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Updates a pending request, setting the status, recording the manager who
     * approved/rejected it, and optionally setting the rejection reason.
     */
    public boolean updateStatusForApprover(int requestId, int approverAccountId, String status,
            String rejectionReason) {
        String sql = "UPDATE Requests SET Status = ?, CurrentApproverAccountId = ?, RejectionReason = ? WHERE Id = ? "
                + "AND Status = 'Pending'";

        try (Connection connection = DBConnection.getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, approverAccountId);
            ps.setString(3, rejectionReason);
            ps.setInt(4, requestId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Delete request
     */
    public boolean delete(int id) {
        String sql = "DELETE FROM Requests WHERE Id = ?";

        try (Connection connection = DBConnection.getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, id);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Get requests created by account
     */
    public List<RequestDTO> getByCreatedByAccountId(int accountId) {
        List<RequestDTO> list = new ArrayList<>();
        String sql = BASE_SELECT +
                "WHERE r.CreatedByAccountId = ? " +
                "ORDER BY r.CreatedAt DESC";

        try (Connection connection = DBConnection.getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, accountId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get gender of user linked to the given accountId.
     * Returns Boolean.TRUE for male (Gender=1), Boolean.FALSE for female (Gender=0), null if unknown.
     */
    public Boolean getGenderByAccountId(int accountId) {
        String sql = "SELECT u.Gender FROM accounts a " +
                     "INNER JOIN users u ON a.UserId = u.Id " +
                     "WHERE a.Id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    boolean val = rs.getBoolean("Gender");
                    return rs.wasNull() ? null : val;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Get remaining annual leave days for the current year.
     * Returns -1 if no record found.
     */
    public int getRemainingLeaveByAccountId(int accountId) {
        int year = java.time.LocalDate.now().getYear();
        String sql = "SELECT lb.RemainingDays FROM leavebalances lb " +
                     "INNER JOIN accounts a ON a.UserId = lb.UserId " +
                     "WHERE a.Id = ? AND lb.Year = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setInt(2, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("RemainingDays");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Check if an account already has an Approved request overlapping the given date range.
     * Used to prevent double-booking of approved leave periods.
     */
    public boolean hasOverlappingApprovedRequest(int accountId, java.sql.Timestamp startDate, java.sql.Timestamp endDate) {
        String sql = "SELECT COUNT(*) FROM requests " +
                     "WHERE CreatedByAccountId = ? " +
                     "AND Status = 'Approved' " +
                     "AND StartDate <= ? AND EndDate >= ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setTimestamp(2, endDate);
            ps.setTimestamp(3, startDate);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Count total used sick leave days this year for an account (Approved requests).
     */
    public double getUsedSickLeaveDaysThisYear(int accountId, int requestTypeId) {
        int year = java.time.LocalDate.now().getYear();
        String sql = "SELECT COALESCE(SUM(Value), 0) FROM requests " +
                     "WHERE CreatedByAccountId = ? " +
                     "AND RequestTypeId = ? " +
                     "AND Status = 'Approved' " +
                     "AND YEAR(StartDate) = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setInt(2, requestTypeId);
            ps.setInt(3, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Get request type ID by its Code string.
     */
    public int getRequestTypeIdByCode(String code) {
        String sql = "SELECT Id FROM requesttypes WHERE Code = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("Id");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Get pending requests
     */
    public List<RequestDTO> getPendingRequests() {
        List<RequestDTO> list = new ArrayList<>();
        String sql = BASE_SELECT +
                "WHERE r.Status = 'Pending' " +
                "ORDER BY r.CreatedAt ASC";

        try (Connection connection = DBConnection.getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy AccountId của Trưởng phòng (HeadAccountId) của phòng ban mà employee (theo accountId) thuộc về.
     * Trả về null nếu không tìm thấy.
     */
    public Integer getManagerAccountIdByEmployeeAccountId(int employeeAccountId) {
        String sql = "SELECT d.HeadAccountId " +
                     "FROM accounts a " +
                     "JOIN users u ON a.UserId = u.Id " +
                     "JOIN departments d ON u.DepartmentId = d.Id " +
                     "WHERE a.Id = ? AND d.HeadAccountId IS NOT NULL";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, employeeAccountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int headId = rs.getInt("HeadAccountId");
                    return rs.wasNull() ? null : headId;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy tất cả request mà approver (manager) có thể xử lý:
     * - Các request có CurrentApproverAccountId = approverAccountId
     * - HOẶC các request được tạo bởi nhân viên thuộc cùng phòng ban do manager này làm Trưởng phòng (HeadAccountId)
     */
    public List<RequestDTO> getByApproverAccountId(int approverAccountId) {
        List<RequestDTO> list = new ArrayList<>();
        String sql = BASE_SELECT +
                "WHERE r.CurrentApproverAccountId = ? " +
                "OR ca.UserId IN (" +
                "    SELECT u_emp.Id FROM users u_emp " +
                "    JOIN departments d ON u_emp.DepartmentId = d.Id " +
                "    WHERE d.HeadAccountId = ?" +
                ") " +
                "ORDER BY r.CreatedAt DESC";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, approverAccountId);
            ps.setInt(2, approverAccountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
