package com.ems.dao;

import com.ems.dto.BaseSalaryDTO;
import com.ems.dto.SalarySummaryDTO;
import com.ems.model.Departments;
import com.ems.model.Employmentbasesalarys;
import com.ems.model.Positions;
import com.ems.util.DBConnection;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class BaseSalaryDAO {

    public List<BaseSalaryDTO> getBaseSalaries(String search, Integer departmentId, Integer positionId, String sortBy, String sortOrder) {
        List<BaseSalaryDTO> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT ebs.Id AS salaryId, ebs.BaseSalary AS baseSalary, " +
                "u.Id AS userId, u.EmployeeCode AS employeeCode, u.FullName AS fullName, " +
                "u.EmailCompany AS emailCompany, u.Phone AS phone, u.Gender AS gender, u.Status AS status, " +
                "u.DependentsCount AS dependentsCount, " +
                "d.Id AS departmentId, d.Name AS departmentName, d.Code AS departmentCode, " +
                "p.Id AS positionId, p.Name AS positionName, p.Code AS positionCode " +
                "FROM employmentbasesalarys ebs " +
                "JOIN users u ON ebs.UserId = u.Id " +
                "LEFT JOIN departments d ON u.DepartmentId = d.Id " +
                "LEFT JOIN positions p ON u.PositionId = p.Id " +
                "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (LOWER(u.FullName) LIKE ? OR LOWER(u.EmployeeCode) LIKE ? OR LOWER(u.EmailCompany) LIKE ?) ");
            String searchPattern = "%" + search.trim().toLowerCase() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }

        if (departmentId != null && departmentId > 0) {
            sql.append("AND u.DepartmentId = ? ");
            params.add(departmentId);
        }

        if (positionId != null && positionId > 0) {
            sql.append("AND u.PositionId = ? ");
            params.add(positionId);
        }

        // Sorting
        String orderByColumn = "ebs.Id";
        if ("name".equalsIgnoreCase(sortBy)) {
            orderByColumn = "u.FullName";
        } else if ("code".equalsIgnoreCase(sortBy)) {
            orderByColumn = "u.EmployeeCode";
        } else if ("salary".equalsIgnoreCase(sortBy)) {
            orderByColumn = "ebs.BaseSalary";
        } else if ("department".equalsIgnoreCase(sortBy)) {
            orderByColumn = "d.Name";
        } else if ("position".equalsIgnoreCase(sortBy)) {
            orderByColumn = "p.Name";
        }

        String orderDir = "DESC".equalsIgnoreCase(sortOrder) ? "DESC" : "ASC";
        sql.append("ORDER BY ").append(orderByColumn).append(" ").append(orderDir);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BaseSalaryDTO dto = new BaseSalaryDTO();
                    dto.setId(rs.getInt("salaryId"));
                    dto.setBaseSalary(rs.getBigDecimal("baseSalary"));
                    dto.setUserId(rs.getInt("userId"));
                    dto.setEmployeeCode(rs.getString("employeeCode"));
                    dto.setFullName(rs.getString("fullName"));
                    dto.setEmailCompany(rs.getString("emailCompany"));
                    dto.setPhone(rs.getString("phone"));
                    dto.setGender(rs.getObject("gender") != null ? rs.getBoolean("gender") : null);
                    dto.setStatus(rs.getBoolean("status"));
                    dto.setDependentsCount(rs.getInt("dependentsCount"));
                    dto.setDepartmentId(rs.getInt("departmentId"));
                    dto.setDepartmentName(rs.getString("departmentName"));
                    dto.setDepartmentCode(rs.getString("departmentCode"));
                    dto.setPositionId(rs.getInt("positionId"));
                    dto.setPositionName(rs.getString("positionName"));
                    dto.setPositionCode(rs.getString("positionCode"));

                    list.add(dto);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public SalarySummaryDTO getSalarySummary(String search, Integer departmentId, Integer positionId) {
        SalarySummaryDTO summary = new SalarySummaryDTO();

        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(ebs.Id) AS totalEmployees, " +
                "COALESCE(AVG(ebs.BaseSalary), 0) AS averageSalary, " +
                "COALESCE(MAX(ebs.BaseSalary), 0) AS maxSalary, " +
                "COALESCE(MIN(ebs.BaseSalary), 0) AS minSalary, " +
                "COALESCE(SUM(ebs.BaseSalary), 0) AS totalBudget " +
                "FROM employmentbasesalarys ebs " +
                "JOIN users u ON ebs.UserId = u.Id " +
                "LEFT JOIN departments d ON u.DepartmentId = d.Id " +
                "LEFT JOIN positions p ON u.PositionId = p.Id " +
                "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (LOWER(u.FullName) LIKE ? OR LOWER(u.EmployeeCode) LIKE ? OR LOWER(u.EmailCompany) LIKE ?) ");
            String searchPattern = "%" + search.trim().toLowerCase() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }

        if (departmentId != null && departmentId > 0) {
            sql.append("AND u.DepartmentId = ? ");
            params.add(departmentId);
        }

        if (positionId != null && positionId > 0) {
            sql.append("AND u.PositionId = ? ");
            params.add(positionId);
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    summary.setTotalEmployees(rs.getInt("totalEmployees"));
                    summary.setAverageSalary(rs.getBigDecimal("averageSalary").setScale(2, RoundingMode.HALF_UP));
                    summary.setMaxSalary(rs.getBigDecimal("maxSalary"));
                    summary.setMinSalary(rs.getBigDecimal("minSalary"));
                    summary.setTotalBudget(rs.getBigDecimal("totalBudget"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return summary;
    }

    public List<Departments> getAllDepartments() {
        List<Departments> list = new ArrayList<>();
        String sql = "SELECT Id, Code, Name FROM departments ORDER BY Name ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Departments dept = new Departments();
                dept.setId(rs.getInt("Id"));
                dept.setCode(rs.getString("Code"));
                dept.setName(rs.getString("Name"));
                list.add(dept);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Positions> getAllPositions() {
        List<Positions> list = new ArrayList<>();
        String sql = "SELECT Id, Code, Name, JobLevel FROM positions ORDER BY Name ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Positions pos = new Positions();
                pos.setId(rs.getInt("Id"));
                pos.setCode(rs.getString("Code"));
                pos.setName(rs.getString("Name"));
                pos.setJoblevel(rs.getInt("JobLevel"));
                list.add(pos);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getTotalEmployeeCount() {
        String sql = "SELECT COUNT(*) FROM users";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean updateBaseSalary(int userId, BigDecimal baseSalary) {
        String sqlCheck = "SELECT COUNT(*) FROM employmentbasesalarys WHERE UserId = ?";
        String sqlUpdateSalary = "UPDATE employmentbasesalarys SET BaseSalary = ? WHERE UserId = ?";
        String sqlInsertSalary = "INSERT INTO employmentbasesalarys (BaseSalary, UserId) VALUES (?, ?)";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            boolean exists = false;
            try (PreparedStatement psCheck = conn.prepareStatement(sqlCheck)) {
                psCheck.setInt(1, userId);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        exists = true;
                    }
                }
            }

            if (exists) {
                try (PreparedStatement ps1 = conn.prepareStatement(sqlUpdateSalary)) {
                    ps1.setBigDecimal(1, baseSalary);
                    ps1.setInt(2, userId);
                    ps1.executeUpdate();
                }
            } else {
                try (PreparedStatement ps1 = conn.prepareStatement(sqlInsertSalary)) {
                    ps1.setBigDecimal(1, baseSalary);
                    ps1.setInt(2, userId);
                    ps1.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        }
    }

    /** Lấy thông tin lương cơ bản theo userId */
    public Employmentbasesalarys getByUserId(int userId) {
        String sql = "SELECT * FROM employmentbasesalarys WHERE UserId = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Employmentbasesalarys item = new Employmentbasesalarys();
                    item.setId(rs.getInt("Id"));
                    item.setBasesalary(rs.getBigDecimal("BaseSalary"));
                    item.setUserid(rs.getInt("UserId"));
                    return item;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
