package com.ems.dao;

import com.ems.model.Payrollconfigs;
import com.ems.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PayrollconfigsDAO {
    private Payrollconfigs mapResultSet(ResultSet rs) throws SQLException {
        Payrollconfigs item = new Payrollconfigs();
        item.setId(rs.getInt("Id"));
        item.setConfigname(rs.getString("ConfigName"));

        // Convert java.sql.Date sang java.time.LocalDate
        Date sqlDate = rs.getDate("EffectiveDate");
        if (sqlDate != null) item.setEffectivedate(sqlDate.toLocalDate());

        item.setBhxhpercent(rs.getBigDecimal("BhxhPercent"));
        item.setBhytpercent(rs.getBigDecimal("BhytPercent"));
        item.setBhtnpercent(rs.getBigDecimal("BhtnPercent"));
        item.setEmployerbhxhpercent(rs.getBigDecimal("EmployerBhxhPercent"));
        item.setEmployerbhtnldpercent(rs.getBigDecimal("EmployerBhtnldPercent"));
        item.setEmployerbhytpercent(rs.getBigDecimal("EmployerBhytPercent"));
        item.setEmployerbhtnpercent(rs.getBigDecimal("EmployerBhtnPercent"));
        item.setMaxinsurancesalary(rs.getBigDecimal("MaxInsuranceSalary"));
        item.setPersonaltaxdeduction(rs.getBigDecimal("PersonalTaxDeduction"));
        item.setDependenttaxdeduction(rs.getBigDecimal("DependentTaxDeduction"));
        item.setStandardworkingdays(rs.getInt("StandardWorkingDays"));
        item.setIsactive(rs.getBoolean("IsActive"));
        item.setCreatedbyaccountid(rs.getObject("CreatedByAccountId") != null ? rs.getInt("CreatedByAccountId") : null);

        // Convert java.sql.Timestamp sang java.time.LocalDateTime
        Timestamp sqlTimestamp = rs.getTimestamp("CreatedAt");
        if (sqlTimestamp != null) item.setCreatedat(sqlTimestamp.toLocalDateTime());

        return item;
    }

    public List<Payrollconfigs> getAll(){
        List<Payrollconfigs> list = new ArrayList<>();
        String sql = "SELECT * FROM payrollconfigs ORDER BY EffectiveDate DESC, Id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Payrollconfigs getById(int id){
        String sql = "SELECT * FROM payrollconfigs WHERE Id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapResultSet(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Payrollconfigs getActiveConfig(){
        String sql = "SELECT * FROM payrollconfigs WHERE IsActive = 1 ORDER BY EffectiveDate DESC LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return mapResultSet(rs);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean insert(Payrollconfigs item){
        // CÂU LỆNH INSERT ĐÃ SẠCH BÓNG OT
        String sql = "INSERT INTO payrollconfigs (ConfigName, EffectiveDate, BhxhPercent, BhytPercent, BhtnPercent, " +
                "EmployerBhxhPercent, EmployerBhtnldPercent, EmployerBhytPercent, EmployerBhtnPercent, " +
                "MaxInsuranceSalary, PersonalTaxDeduction, DependentTaxDeduction, StandardWorkingDays, " +
                "IsActive, CreatedByAccountId) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, item.getConfigname());
            ps.setDate(2, Date.valueOf(item.getEffectivedate()));
            ps.setBigDecimal(3, item.getBhxhpercent());
            ps.setBigDecimal(4, item.getBhytpercent());
            ps.setBigDecimal(5, item.getBhtnpercent());

            ps.setBigDecimal(6, item.getEmployerbhxhpercent());
            ps.setBigDecimal(7, item.getEmployerbhtnldpercent());
            ps.setBigDecimal(8, item.getEmployerbhytpercent());
            ps.setBigDecimal(9, item.getEmployerbhtnpercent());

            ps.setBigDecimal(10, item.getMaxinsurancesalary());
            ps.setBigDecimal(11, item.getPersonaltaxdeduction());
            ps.setBigDecimal(12, item.getDependenttaxdeduction());
            ps.setInt(13, item.getStandardworkingdays());

            ps.setBoolean(14, item.getIsactive() != null ? item.getIsactive() : false);

            if (item.getCreatedbyaccountid() != null) {
                ps.setInt(15, item.getCreatedbyaccountid());
            } else {
                ps.setNull(15, Types.INTEGER);
            }

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        item.setId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public void deactivateAllExcept(int activeId){
        String sql = "UPDATE payrollconfigs SET IsActive = 0 WHERE Id != ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, activeId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
