package com.ems.dao;

import com.ems.dto.TimesheetPeriodDTO;
import com.ems.util.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class TimesheetPeriodDAO {

    public List<TimesheetPeriodDTO> getAllPeriods() {
        return getPeriods(null, null, "StartDate", "DESC");
    }

    public List<TimesheetPeriodDTO> getPeriods(String search, String statusFilter, String sortBy, String sortOrder) {
        ensureSampleDataExists();
        List<TimesheetPeriodDTO> periods = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT Id, Name, StartDate, EndDate, IsLocked ");
        sql.append("FROM timesheetperiods WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND Name LIKE ? ");
            params.add("%" + search.trim() + "%");
        }

        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            if ("active".equalsIgnoreCase(statusFilter) || "open".equalsIgnoreCase(statusFilter)) {
                sql.append("AND (IsLocked = 0 OR IsLocked IS NULL) ");
            } else if ("locked".equalsIgnoreCase(statusFilter)) {
                sql.append("AND IsLocked = 1 ");
            }
        }

        // Sorting
        String orderBy = "StartDate";
        if ("name".equalsIgnoreCase(sortBy)) {
            orderBy = "Name";
        } else if ("id".equalsIgnoreCase(sortBy)) {
            orderBy = "Id";
        } else if ("enddate".equalsIgnoreCase(sortBy)) {
            orderBy = "EndDate";
        }

        String orderDirection = "DESC";
        if ("ASC".equalsIgnoreCase(sortOrder)) {
            orderDirection = "ASC";
        }

        sql.append("ORDER BY ").append(orderBy).append(" ").append(orderDirection).append(", Id DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TimesheetPeriodDTO period = new TimesheetPeriodDTO();
                    period.setId(rs.getInt("Id"));
                    period.setName(rs.getString("Name"));
                    period.setStartDate(rs.getDate("StartDate"));
                    period.setEndDate(rs.getDate("EndDate"));
                    boolean isLocked = rs.getBoolean("IsLocked");
                    period.setLocked(isLocked);
                    periods.add(period);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return periods;
    }

    public TimesheetPeriodDTO getPeriodById(int id) {
        ensureSampleDataExists();
        String sql = "SELECT Id, Name, StartDate, EndDate, IsLocked FROM timesheetperiods WHERE Id = ?";
        TimesheetPeriodDTO period = null;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    period = new TimesheetPeriodDTO();
                    period.setId(rs.getInt("Id"));
                    period.setName(rs.getString("Name"));
                    period.setStartDate(rs.getDate("StartDate"));
                    period.setEndDate(rs.getDate("EndDate"));
                    period.setLocked(rs.getBoolean("IsLocked"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return period;
    }

    public boolean createPeriod(TimesheetPeriodDTO period) {
        String sql = "INSERT INTO timesheetperiods (Name, StartDate, EndDate, IsLocked) VALUES (?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, period.getName());
            ps.setDate(2, period.getStartDate());
            ps.setDate(3, period.getEndDate());
            ps.setBoolean(4, period.isLocked());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updatePeriod(TimesheetPeriodDTO period) {
        String sql = "UPDATE timesheetperiods SET Name = ?, StartDate = ?, EndDate = ?, IsLocked = ? WHERE Id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, period.getName());
            ps.setDate(2, period.getStartDate());
            ps.setDate(3, period.getEndDate());
            ps.setBoolean(4, period.isLocked());
            ps.setInt(5, period.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deletePeriod(int id) {
        String sql = "DELETE FROM timesheetperiods WHERE Id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updatePeriodStatus(int id, String status) {
        boolean isLocked = "Đã khóa".equalsIgnoreCase(status) || "LOCKED".equalsIgnoreCase(status) || "1".equals(status);
        return updatePeriodLockStatus(id, isLocked);
    }

    public boolean updatePeriodLockStatus(int id, boolean isLocked) {
        String sql = "UPDATE timesheetperiods SET IsLocked = ? WHERE Id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isLocked);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean hasAssociatedPayslips(int periodId) {
        String sql = "SELECT COUNT(*) FROM payslips WHERE PeriodId = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, periodId);
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

    public int getTotalPeriodsCount() {
        return getCountByQuery("SELECT COUNT(*) FROM timesheetperiods");
    }

    public int getActivePeriodsCount() {
        return getCountByQuery("SELECT COUNT(*) FROM timesheetperiods WHERE IsLocked = 0 OR IsLocked IS NULL");
    }

    public int getLockedPeriodsCount() {
        return getCountByQuery("SELECT COUNT(*) FROM timesheetperiods WHERE IsLocked = 1");
    }

    public boolean isDuplicatePeriod(String name, Date startDate, Date endDate, Integer excludeId) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM timesheetperiods WHERE (Name = ? OR (StartDate <= ? AND EndDate >= ?))");
        
        if (excludeId != null) {
            sql.append(" AND Id != ?");
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            ps.setString(1, name);
            ps.setDate(2, endDate);
            ps.setDate(3, startDate);
            
            if (excludeId != null) {
                ps.setInt(4, excludeId);
            }
            
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

    private int getCountByQuery(String sql) {
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private synchronized void ensureSampleDataExists() {
        String checkSql = "SELECT COUNT(*) FROM timesheetperiods";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(checkSql)) {
            if (rs.next() && rs.getInt(1) == 0) {
                String insertSql = "INSERT INTO timesheetperiods (Name, StartDate, EndDate, IsLocked) VALUES (?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    // Sample period 1 (Current month - active)
                    ps.setString(1, "Kỳ lương Tháng 08/2026");
                    ps.setDate(2, Date.valueOf(LocalDate.of(2026, 8, 1)));
                    ps.setDate(3, Date.valueOf(LocalDate.of(2026, 8, 31)));
                    ps.setBoolean(4, false);
                    ps.executeUpdate();

                    // Sample period 2 (Previous month - locked)
                    ps.setString(1, "Kỳ lương Tháng 07/2026");
                    ps.setDate(2, Date.valueOf(LocalDate.of(2026, 7, 1)));
                    ps.setDate(3, Date.valueOf(LocalDate.of(2026, 7, 31)));
                    ps.setBoolean(4, true);
                    ps.executeUpdate();

                    // Sample period 3 (Earlier month - locked)
                    ps.setString(1, "Kỳ lương Tháng 06/2026");
                    ps.setDate(2, Date.valueOf(LocalDate.of(2026, 6, 1)));
                    ps.setDate(3, Date.valueOf(LocalDate.of(2026, 6, 30)));
                    ps.setBoolean(4, true);
                    ps.executeUpdate();
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}

