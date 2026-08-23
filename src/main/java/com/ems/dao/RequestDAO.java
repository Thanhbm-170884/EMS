package com.ems.dao;

import com.ems.dto.RequestDTO;
import com.ems.dto.EmployeeBalanceDTO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class RequestDAO {

    private final Connection connection;

    public RequestDAO(Connection connection) {
        this.connection = connection;
    }

    /**
     * Common SELECT query
     */
    private static final String BASE_SELECT =
            "SELECT " +
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

        request.setTitle(
                rs.getString("Title")
        );

        request.setReason(
                rs.getString("Reason")
        );

        request.setStatus(
                rs.getString("Status")
        );

        request.setStartDate(
                rs.getTimestamp("StartDate")
        );

        request.setEndDate(
                rs.getTimestamp("EndDate")
        );

        request.setValue(
                rs.getDouble("Value")
        );

        request.setImageUrl(
                rs.getString("ImageUrl")
        );

        request.setCreatedAt(
                rs.getTimestamp("CreatedAt")
        );

        // Request Type
        request.setRequestTypeId(
                rs.getInt("RequestTypeId")
        );

        request.setRequestTypeName(
                rs.getString("RequestTypeName")
        );

        // Creator
        request.setCreatedByAccountId(
                rs.getInt("CreatedByAccountId")
        );

        request.setCreatedByName(
                rs.getString("CreatedByName")
        );

        // Current Approver
        int approverId =
                rs.getInt("CurrentApproverAccountId");

        if (rs.wasNull()) {

            request.setCurrentApproverAccountId(null);

        } else {

            request.setCurrentApproverAccountId(
                    approverId
            );
        }

        request.setCurrentApproverName(
                rs.getString("ApproverName")
        );

        request.setRejectionReason(
                rs.getString("RejectionReason")
        );

        return request;
    }

    /**
     * Get all requests
     */
    public List<RequestDTO> getAll() throws SQLException {

        List<RequestDTO> list = new ArrayList<>();

        String sql =
                BASE_SELECT +
                        "ORDER BY r.CreatedAt DESC";

        try (
                PreparedStatement ps =
                        connection.prepareStatement(sql);

                ResultSet rs =
                        ps.executeQuery()
        ) {

            while (rs.next()) {

                list.add(
                        mapResultSet(rs)
                );
            }
        }

        return list;
    }

    /**
     * Get request by ID
     */
    public RequestDTO getById(int id) throws SQLException {

        String sql =
                BASE_SELECT +
                        "WHERE r.Id = ?";

        try (
                PreparedStatement ps =
                        connection.prepareStatement(sql)
        ) {

            ps.setInt(1, id);

            try (
                    ResultSet rs =
                            ps.executeQuery()
            ) {

                if (rs.next()) {

                    return mapResultSet(rs);
                }
            }
        }

        return null;
    }

    /**
     * Insert new request
     */
    public boolean insert(RequestDTO request)
            throws SQLException {

        String sql =
                "INSERT INTO Requests " +
                        "(" +
                        "Title, " +
                        "Reason, " +
                        "Status, " +
                        "StartDate, " +
                        "EndDate, " +
                        "Value, " +
                        "ImageUrl, " +
                        "RequestTypeId, " +
                        "CreatedByAccountId, " +
                        "CurrentApproverAccountId" +
                        ") " +
                        "VALUES (?, ?, 'Pending', ?, ?, ?, ?, ?, ?, ?)";

        try (
                PreparedStatement ps =
                        connection.prepareStatement(sql)
        ) {

            ps.setString(
                    1,
                    request.getTitle()
            );

            ps.setString(
                    2,
                    request.getReason()
            );

            ps.setTimestamp(
                    3,
                    request.getStartDate()
            );

            ps.setTimestamp(
                    4,
                    request.getEndDate()
            );

            ps.setDouble(
                    5,
                    request.getValue()
            );

            ps.setString(
                    6,
                    request.getImageUrl()
            );

            ps.setInt(
                    7,
                    request.getRequestTypeId()
            );

            ps.setInt(
                    8,
                    request.getCreatedByAccountId()
            );

            if (
                    request.getCurrentApproverAccountId()
                            != null
            ) {

                ps.setInt(
                        9,
                        request.getCurrentApproverAccountId()
                );

            } else {

                ps.setNull(
                        9,
                        Types.INTEGER
                );
            }

            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Update request status
     */
    public boolean updateStatus(
            int requestId,
            String status
    ) throws SQLException {

        String sql =
                "UPDATE Requests " +
                        "SET Status = ? " +
                        "WHERE Id = ?";

        try (
                PreparedStatement ps =
                        connection.prepareStatement(sql)
        ) {

            ps.setString(
                    1,
                    status
            );

            ps.setInt(
                    2,
                    requestId
            );

            return ps.executeUpdate() > 0;
        }
    }

    /** Updates a pending request, setting the status, recording the manager who approved/rejected it, and optionally setting the rejection reason. */
    public boolean updateStatusForApprover(int requestId, int approverAccountId, String status, String rejectionReason)
            throws SQLException {
        String sql = "UPDATE Requests SET Status = ?, CurrentApproverAccountId = ?, RejectionReason = ? WHERE Id = ? "
                + "AND Status = 'Pending'";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, approverAccountId);
            ps.setString(3, rejectionReason);
            ps.setInt(4, requestId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Delete request
     */
    public boolean delete(int id)
            throws SQLException {

        String sql =
                "DELETE FROM Requests " +
                        "WHERE Id = ?";

        try (
                PreparedStatement ps =
                        connection.prepareStatement(sql)
        ) {

            ps.setInt(1, id);

            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Get requests created by account
     */
    public List<RequestDTO> getByCreatedByAccountId(
            int accountId
    ) throws SQLException {

        List<RequestDTO> list = new ArrayList<>();

        String sql =
                BASE_SELECT +
                        "WHERE r.CreatedByAccountId = ? " +
                        "ORDER BY r.CreatedAt DESC";

        try (
                PreparedStatement ps =
                        connection.prepareStatement(sql)
        ) {

            ps.setInt(1, accountId);

            try (
                    ResultSet rs =
                            ps.executeQuery()
            ) {

                while (rs.next()) {

                    list.add(
                            mapResultSet(rs)
                    );
                }
            }
        }

        return list;
    }

    /**
     * Get pending requests
     */
    public List<RequestDTO> getPendingRequests() throws SQLException {

        List<RequestDTO> list = new ArrayList<>();

        String sql =
                BASE_SELECT +
                        "WHERE r.Status = 'Pending' " +
                        "ORDER BY r.CreatedAt ASC";

        try (
                PreparedStatement ps =
                        connection.prepareStatement(sql)
        ) {

            try (
                    ResultSet rs =
                            ps.executeQuery()
            ) {

                while (rs.next()) {

                    list.add(
                            mapResultSet(rs)
                    );
                }
            }
        }

        return list;
    }

    public List<EmployeeBalanceDTO> getEmployeeBalances() throws SQLException {
        List<EmployeeBalanceDTO> list = new ArrayList<>();
        String sql = "SELECT " +
                     "  u.Id AS UserId, " +
                     "  u.FullName AS EmployeeName, " +
                     "  d.Name AS DepartmentName, " +
                     "  COALESCE(lb.TotalDays, 12) AS TotalDays, " +
                     "  COALESCE(lb.UsedDays, 0) AS UsedDays, " +
                     "  COALESCE(lb.RemainingDays, 12) AS RemainingDays, " +
                     "  ( " +
                     "      SELECT COALESCE(SUM(r.Value), 0) " +
                     "      FROM Requests r " +
                     "      JOIN Accounts a ON r.CreatedByAccountId = a.Id " +
                     "      WHERE a.UserId = u.Id " +
                     "        AND r.RequestTypeId = 3 " +
                     "        AND r.Status = 'Approved' " +
                     "        AND MONTH(r.StartDate) = MONTH(CURDATE()) " +
                     "        AND YEAR(r.StartDate) = YEAR(CURDATE()) " +
                     "  ) AS AdvancedThisMonth " +
                     "FROM Users u " +
                     "LEFT JOIN Departments d ON u.DepartmentId = d.Id " +
                     "LEFT JOIN Accounts acc ON u.Id = acc.UserId " +
                     "LEFT JOIN leavebalances lb ON u.Id = lb.UserId AND lb.Year = 2026 " +
                     "WHERE acc.Id IS NOT NULL " +
                     "ORDER BY u.FullName ASC";

        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new EmployeeBalanceDTO(
                    rs.getInt("UserId"),
                    rs.getString("EmployeeName"),
                    rs.getString("DepartmentName"),
                    rs.getInt("TotalDays"),
                    rs.getInt("UsedDays"),
                    rs.getInt("RemainingDays"),
                    rs.getDouble("AdvancedThisMonth")
                ));
            }
        }
        return list;
    }
}
