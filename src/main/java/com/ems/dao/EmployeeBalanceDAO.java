package com.ems.dao;

import com.ems.dto.EmployeeBalanceDTO;
import com.ems.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class EmployeeBalanceDAO {

    /**
     * Lấy danh sách số dư phép của tất cả nhân viên
     */
    public List<EmployeeBalanceDTO> getAllEmployeeBalances() {

        List<EmployeeBalanceDTO> list = new ArrayList<>();

        String sql = "SELECT " +
                "    u.Id AS UserId, " +
                "    u.FullName AS EmployeeName, " +
                "    d.Name AS DepartmentName, " +
                "    COALESCE(lb.TotalDays, 12) AS TotalDays, " +
                "    COALESCE(lb.UsedDays, 0) AS UsedDays, " +
                "    COALESCE(lb.RemainingDays, 12) AS RemainingDays, " +
                "    COALESCE(ebs.BaseSalary, 0) AS BaseSalary, " +
                "    ( " +
                "        SELECT COALESCE(SUM(r.Value), 0) " +
                "        FROM Requests r " +
                "        JOIN Accounts a " +
                "            ON r.CreatedByAccountId = a.Id " +
                "        WHERE a.UserId = u.Id " +
                "          AND r.RequestTypeId = 3 " +
                "          AND r.Status = 'Approved' " +
                "          AND MONTH(r.StartDate) = MONTH(CURDATE()) " +
                "          AND YEAR(r.StartDate) = YEAR(CURDATE()) " +
                "    ) AS AdvancedThisMonth " +
                "FROM Users u " +
                "LEFT JOIN Departments d " +
                "    ON u.DepartmentId = d.Id " +
                "LEFT JOIN Accounts acc " +
                "    ON u.Id = acc.UserId " +
                "LEFT JOIN leavebalances lb " +
                "    ON u.Id = lb.UserId " +
                "    AND lb.Year = YEAR(CURDATE()) " +
                "LEFT JOIN employmentbasesalarys ebs " +
                "    ON u.Id = ebs.UserId " +
                "WHERE acc.Id IS NOT NULL " +
                "ORDER BY u.FullName ASC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                EmployeeBalanceDTO employeeBalance = new EmployeeBalanceDTO(
                        rs.getInt("UserId"),
                        rs.getString("EmployeeName"),
                        rs.getString("DepartmentName"),
                        rs.getInt("TotalDays"),
                        rs.getInt("UsedDays"),
                        rs.getInt("RemainingDays"),
                        rs.getDouble("AdvancedThisMonth"),
                        rs.getDouble("BaseSalary"));

                list.add(employeeBalance);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<EmployeeBalanceDTO> getEmployeeBalancesByDepartmentId(int deptId) {
        List<EmployeeBalanceDTO> list = new ArrayList<>();
        String sql = "SELECT " +
                "    u.Id AS UserId, " +
                "    u.FullName AS EmployeeName, " +
                "    d.Name AS DepartmentName, " +
                "    COALESCE(lb.TotalDays, 12) AS TotalDays, " +
                "    COALESCE(lb.UsedDays, 0) AS UsedDays, " +
                "    COALESCE(lb.RemainingDays, 12) AS RemainingDays, " +
                "    COALESCE(ebs.BaseSalary, 0) AS BaseSalary, " +
                "    ( " +
                "        SELECT COALESCE(SUM(r.Value), 0) " +
                "        FROM Requests r " +
                "        JOIN Accounts a " +
                "            ON r.CreatedByAccountId = a.Id " +
                "        WHERE a.UserId = u.Id " +
                "          AND r.RequestTypeId = 3 " +
                "          AND r.Status = 'Approved' " +
                "          AND MONTH(r.StartDate) = MONTH(CURDATE()) " +
                "          AND YEAR(r.StartDate) = YEAR(CURDATE()) " +
                "    ) AS AdvancedThisMonth " +
                "FROM Users u " +
                "LEFT JOIN Departments d " +
                "    ON u.DepartmentId = d.Id " +
                "LEFT JOIN Accounts acc " +
                "    ON u.Id = acc.UserId " +
                "LEFT JOIN leavebalances lb " +
                "    ON u.Id = lb.UserId " +
                "    AND lb.Year = YEAR(CURDATE()) " +
                "LEFT JOIN employmentbasesalarys ebs " +
                "    ON u.Id = ebs.UserId " +
                "WHERE acc.Id IS NOT NULL AND u.DepartmentId = ? " +
                "ORDER BY u.FullName ASC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, deptId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    EmployeeBalanceDTO employeeBalance = new EmployeeBalanceDTO(
                            rs.getInt("UserId"),
                            rs.getString("EmployeeName"),
                            rs.getString("DepartmentName"),
                            rs.getInt("TotalDays"),
                            rs.getInt("UsedDays"),
                            rs.getInt("RemainingDays"),
                            rs.getDouble("AdvancedThisMonth"),
                            rs.getDouble("BaseSalary")
                    );
                    list.add(employeeBalance);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    /**
     * Lấy thông tin số dư phép của một nhân viên
     */
    public EmployeeBalanceDTO getEmployeeBalanceByUserId(int userId) {

        String sql = "SELECT " +
                "    u.Id AS UserId, " +
                "    u.FullName AS EmployeeName, " +
                "    d.Name AS DepartmentName, " +
                "    COALESCE(lb.TotalDays, 12) AS TotalDays, " +
                "    COALESCE(lb.UsedDays, 0) AS UsedDays, " +
                "    COALESCE(lb.RemainingDays, 12) AS RemainingDays, " +
                "    COALESCE(ebs.BaseSalary, 0) AS BaseSalary, " +
                "    ( " +
                "        SELECT COALESCE(SUM(r.Value), 0) " +
                "        FROM Requests r " +
                "        JOIN Accounts a " +
                "            ON r.CreatedByAccountId = a.Id " +
                "        WHERE a.UserId = u.Id " +
                "          AND r.RequestTypeId = 3 " +
                "          AND r.Status = 'Approved' " +
                "          AND MONTH(r.StartDate) = MONTH(CURDATE()) " +
                "          AND YEAR(r.StartDate) = YEAR(CURDATE()) " +
                "    ) AS AdvancedThisMonth " +
                "FROM Users u " +
                "LEFT JOIN Departments d " +
                "    ON u.DepartmentId = d.Id " +
                "LEFT JOIN leavebalances lb " +
                "    ON u.Id = lb.UserId " +
                "    AND lb.Year = YEAR(CURDATE()) " +
                "LEFT JOIN employmentbasesalarys ebs " +
                "    ON u.Id = ebs.UserId " +
                "WHERE u.Id = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {

                    return new EmployeeBalanceDTO(
                            rs.getInt("UserId"),
                            rs.getString("EmployeeName"),
                            rs.getString("DepartmentName"),
                            rs.getInt("TotalDays"),
                            rs.getInt("UsedDays"),
                            rs.getInt("RemainingDays"),
                            rs.getDouble("AdvancedThisMonth"),
                            rs.getDouble("BaseSalary"));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Kiểm tra nhân viên đã có dữ liệu số dư phép trong năm chưa
     */
    public boolean existsBalance(int userId, int year) {

        String sql = "SELECT COUNT(*) " +
                "FROM leavebalances " +
                "WHERE UserId = ? AND Year = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, year);

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
     * Thêm số dư phép cho nhân viên
     */
    public boolean addEmployeeBalance(
            int userId,
            int year,
            int totalDays) {

        String sql = "INSERT INTO leavebalances " +
                "(UserId, Year, TotalDays, UsedDays, RemainingDays) " +
                "VALUES (?, ?, ?, 0, ?)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, year);
            ps.setInt(3, totalDays);
            ps.setInt(4, totalDays);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Cập nhật số ngày phép
     */
    public boolean updateEmployeeBalance(
            int userId,
            int year,
            int totalDays,
            int usedDays) {

        int remainingDays = totalDays - usedDays;

        String sql = "UPDATE leavebalances " +
                "SET TotalDays = ?, " +
                "    UsedDays = ?, " +
                "    RemainingDays = ? " +
                "WHERE UserId = ? " +
                "AND Year = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, totalDays);
            ps.setInt(2, usedDays);
            ps.setInt(3, remainingDays);
            ps.setInt(4, userId);
            ps.setInt(5, year);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Cập nhật số ngày phép đã sử dụng
     */
    public boolean updateUsedDays(
            int userId,
            int year,
            int usedDays) {

        String sql = "UPDATE leavebalances " +
                "SET UsedDays = ?, " +
                "    RemainingDays = TotalDays - ? " +
                "WHERE UserId = ? " +
                "AND Year = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, usedDays);
            ps.setInt(2, usedDays);
            ps.setInt(3, userId);
            ps.setInt(4, year);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Trừ số ngày phép của nhân viên khi đơn nghỉ phép được duyệt.
     */
    public boolean deductLeaveDays(int createdByAccountId, double days) {
        String userSql = "SELECT UserId FROM accounts WHERE Id = ?";
        String updateSql = "UPDATE leavebalances " +
                "SET UsedDays = UsedDays + ?, " +
                "    RemainingDays = RemainingDays - ? " +
                "WHERE UserId = ? AND Year = YEAR(CURDATE())";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement psUser = conn.prepareStatement(userSql)) {
            
            psUser.setInt(1, createdByAccountId);
            try (ResultSet rs = psUser.executeQuery()) {
                if (rs.next()) {
                    int userId = rs.getInt("UserId");
                    
                    try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                        psUpdate.setDouble(1, days);
                        psUpdate.setDouble(2, days);
                        psUpdate.setInt(3, userId);
                        
                        return psUpdate.executeUpdate() > 0;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
