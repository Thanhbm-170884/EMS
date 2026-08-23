package com.ems.dao;

import com.ems.dto.AllowanceDetailDTO;
import com.ems.dto.ManagerPayslipDTO;
import com.ems.dto.PayslipDTO;
import com.ems.model.Payslips;
import com.ems.model.Timesheetperiods;
import com.ems.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class PayslipDAO {
    public List<PayslipDTO> getPayslipsByPeriodForView(int periodId, String search, Integer departmentId) {
        List<PayslipDTO> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("SELECT p.Id, p.PeriodId, p.StandardWorkDays, p.ActualWorkDays, " +
                "p.BaseSalary, p.ActualBaseSalary, p.OtHours, p.OtSalary, p.BonusAmount, " +
                "p.DependentsCount, p.DependentDeduction, p.TaxableIncome, p.PenaltyAmount, p.AdvanceAmount, " +
                "(COALESCE(p.PenaltyAmount, 0) + COALESCE(p.AdvanceAmount, 0) + COALESCE(p.OtherDeductions, 0)) AS OtherDeductions, "
                +
                "p.GrossAmount, p.TotalInsuranceDeduction, p.BhxhAmount, p.BhytAmount, p.BhtnAmount, p.TaxDeduction, p.NetAmount, p.Status, p.Note, "
                +
                "u.EmployeeCode, u.FullName, d.Name AS DepartmentName, pos.Name AS PositionName " +
                "FROM payslips p " +
                "JOIN users u ON p.UserId = u.Id " +
                "LEFT JOIN departments d ON u.DepartmentId = d.Id " +
                "LEFT JOIN positions pos ON u.PositionId = pos.Id " +
                "WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (periodId > 0) {
            sql.append("AND p.PeriodId = ? ");
            params.add(periodId);
        }

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (LOWER(u.FullName) LIKE ? OR LOWER(u.EmployeeCode) LIKE ?) ");
            String likeSearch = "%" + search.trim().toLowerCase() + "%";
            params.add(likeSearch);
            params.add(likeSearch);
        }

        if (departmentId != null && departmentId > 0) {
            sql.append("AND u.DepartmentId = ? ");
            params.add(departmentId);
        }

        sql.append("ORDER BY p.Id DESC");

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PayslipDTO dto = new PayslipDTO();
                    dto.setId(rs.getInt("Id"));
                    dto.setPeriodId(rs.getInt("PeriodId"));
                    dto.setStatus(rs.getString("Status"));

                    dto.setEmployeeCode(rs.getString("EmployeeCode"));
                    dto.setFullName(rs.getString("FullName"));
                    dto.setDepartmentName(rs.getString("DepartmentName"));
                    dto.setPositionName(rs.getString("PositionName"));

                    dto.setStandardWorkDays(rs.getInt("StandardWorkDays"));
                    dto.setActualWorkDays(rs.getBigDecimal("ActualWorkDays"));
                    dto.setBaseSalary(rs.getBigDecimal("BaseSalary"));
                    dto.setActualBaseSalary(rs.getBigDecimal("ActualBaseSalary"));
                    dto.setOtHours(rs.getBigDecimal("OtHours"));
                    dto.setOtSalary(rs.getBigDecimal("OtSalary"));
                    dto.setBonusAmount(rs.getBigDecimal("BonusAmount"));
                    dto.setDependentsCount(rs.getInt("DependentsCount"));
                    dto.setDependentDeduction(rs.getBigDecimal("DependentDeduction"));
                    dto.setTaxableIncome(rs.getBigDecimal("TaxableIncome"));
                    dto.setPenaltyAmount(rs.getBigDecimal("PenaltyAmount"));
                    dto.setAdvanceAmount(rs.getBigDecimal("AdvanceAmount"));
                    dto.setOtherDeductions(rs.getBigDecimal("OtherDeductions"));
                    dto.setGrossAmount(rs.getBigDecimal("GrossAmount"));
                    dto.setTotalInsurance(rs.getBigDecimal("TotalInsuranceDeduction"));
                    dto.setBhxh(rs.getBigDecimal("BhxhAmount"));
                    dto.setBhyt(rs.getBigDecimal("BhytAmount"));
                    dto.setBhtn(rs.getBigDecimal("BhtnAmount"));
                    dto.setTaxDeduction(rs.getBigDecimal("TaxDeduction"));
                    dto.setNetAmount(rs.getBigDecimal("NetAmount"));
                    dto.setNote(rs.getString("Note"));

                    dto.setAllowanceDetails(getAllowanceDetailsByPayslipId(dto.getId()));

                    list.add(dto);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private List<AllowanceDetailDTO> getAllowanceDetailsByPayslipId(int payslipId) {
        List<AllowanceDetailDTO> details = new ArrayList<>();
        String sql = "SELECT a.Name, pa.Amount " +
                "FROM payslip_allowances pa " +
                "JOIN allowancetypes a ON pa.AllowanceTypeId = a.Id " +
                "WHERE pa.PayslipId = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, payslipId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    details.add(new AllowanceDetailDTO(
                            rs.getString("Name"),
                            rs.getBigDecimal("Amount")));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return details;
    }

    public List<Timesheetperiods> getAllTimesheetPeriods() {
        List<Timesheetperiods> list = new ArrayList<>();
        String sql = "SELECT * FROM timesheetperiods ORDER BY StartDate DESC";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Timesheetperiods item = new Timesheetperiods();
                item.setId(rs.getInt("Id"));
                item.setName(rs.getString("Name"));
                if (rs.getDate("StartDate") != null) {
                    item.setStartdate(rs.getDate("StartDate").toLocalDate());
                }
                if (rs.getDate("EndDate") != null) {
                    item.setEnddate(rs.getDate("EndDate").toLocalDate());
                }
                item.setIslocked(rs.getBoolean("IsLocked"));
                list.add(item);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<ManagerPayslipDTO> getPayslipsByPeriod(Integer periodId, String search, Integer departmentId) {
        List<ManagerPayslipDTO> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT p.Id, p.UserId, u.EmployeeCode, u.FullName, d.Name AS DepartmentName, pos.Name AS PositionName, "
                        +
                        "t.Id AS PeriodId, t.Name AS PeriodName, " +
                        "p.BaseSalary, p.OtSalary, p.TotalAllowanceAmount, p.TotalInsuranceDeduction, " +
                        "p.DependentDeduction, p.TaxDeduction, " +
                        "(COALESCE(p.PenaltyAmount, 0) + COALESCE(p.AdvanceAmount, 0) + COALESCE(p.OtherDeductions, 0)) AS OtherDeductions, "
                        +
                        "p.GrossAmount, p.NetAmount, p.Status, p.Note, p.CreatedAt " +
                        "FROM payslips p " +
                        "JOIN users u ON p.UserId = u.Id " +
                        "LEFT JOIN departments d ON u.DepartmentId = d.Id " +
                        "LEFT JOIN positions pos ON u.PositionId = pos.Id " +
                        "LEFT JOIN timesheetperiods t ON p.PeriodId = t.Id " +
                        "WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (periodId != null && periodId > 0) {
            sql.append("AND p.PeriodId = ? ");
            params.add(periodId);
        }

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (LOWER(u.FullName) LIKE ? OR LOWER(u.EmployeeCode) LIKE ?) ");
            String likeSearch = "%" + search.trim().toLowerCase() + "%";
            params.add(likeSearch);
            params.add(likeSearch);
        }

        if (departmentId != null && departmentId > 0) {
            sql.append("AND u.DepartmentId = ? ");
            params.add(departmentId);
        }

        sql.append("ORDER BY u.EmployeeCode ASC");

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ManagerPayslipDTO dto = new ManagerPayslipDTO();
                    dto.setId(rs.getInt("Id"));
                    dto.setUserId(rs.getInt("UserId"));
                    dto.setEmployeeCode(rs.getString("EmployeeCode"));
                    dto.setFullName(rs.getString("FullName"));
                    dto.setDepartmentName(rs.getString("DepartmentName"));
                    dto.setPositionName(rs.getString("PositionName"));

                    dto.setPeriodId(rs.getInt("PeriodId"));
                    dto.setPeriodName(rs.getString("PeriodName"));

                    dto.setBaseSalary(rs.getBigDecimal("BaseSalary"));
                    dto.setOtSalary(rs.getBigDecimal("OtSalary"));
                    dto.setAllowances(rs.getBigDecimal("TotalAllowanceAmount"));
                    dto.setInsuranceDeduction(rs.getBigDecimal("TotalInsuranceDeduction"));
                    dto.setDependentDeduction(rs.getBigDecimal("DependentDeduction"));
                    dto.setTaxDeduction(rs.getBigDecimal("TaxDeduction"));
                    dto.setOtherDeductions(rs.getBigDecimal("OtherDeductions"));
                    dto.setGrossAmount(rs.getBigDecimal("GrossAmount"));
                    dto.setNetAmount(rs.getBigDecimal("NetAmount"));
                    dto.setStatus(rs.getString("Status"));
                    dto.setNote(rs.getString("Note"));

                    if (rs.getTimestamp("CreatedAt") != null) {
                        dto.setCreatedAt(rs.getTimestamp("CreatedAt").toLocalDateTime());
                    }

                    list.add(dto);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Payslips getPayslipById(int id){
        String sql = "SELECT * FROM payslips WHERE Id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    com.ems.model.Payslips p = new com.ems.model.Payslips();
                    p.setId(rs.getInt("Id"));
                    p.setUserid(rs.getInt("UserId"));
                    p.setPeriodid(rs.getInt("PeriodId"));
                    p.setActualworkdays(rs.getBigDecimal("ActualWorkDays"));
                    p.setOthours(rs.getBigDecimal("OtHours"));
                    p.setStatus(rs.getString("Status"));
                    return p;
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public int updatePayslipStatusByPeriod(int periodId, String oldStatus, String newStatus) {
        String sql = "UPDATE payslips SET Status = ? WHERE PeriodId = ? AND Status = ?";
        try (java.sql.Connection conn = com.ems.util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, periodId);
            ps.setString(3, oldStatus);
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Hàm để tính lương

    public boolean checkPayrollExists(int periodId) {
        String sql = "SELECT COUNT(*) FROM payslips WHERE PeriodId = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, periodId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public int countActualWorkDays(int userId, int periodId) {
        String sql = "SELECT COUNT(DISTINCT a.AttendanceDate) " +
                "FROM attendance a " +
                "JOIN timesheetperiods t ON t.Id = ? " +
                "WHERE a.EmployeeId = ? " +
                "AND a.AttendanceDate BETWEEN t.StartDate AND t.EndDate " +
                "AND a.CheckInTime IS NOT NULL";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, periodId);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int insertPayslip(com.ems.model.Payslips p) {
        String sql = "INSERT INTO payslips (UserId, PeriodId, StandardWorkDays, ActualWorkDays, OtHours, " +
                "BaseSalary, ActualBaseSalary, OtSalary, TotalAllowanceAmount, BonusAmount, GrossAmount, " +
                "BhxhAmount, BhytAmount, BhtnAmount, TotalInsuranceDeduction, DependentsCount, " +
                "DependentDeduction, TaxableIncome, TaxDeduction, PenaltyAmount, AdvanceAmount, " +
                "OtherDeductions, NetAmount, Status, AdjustedByAccountId) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, p.getUserid());
            ps.setInt(2, p.getPeriodid());
            ps.setInt(3, p.getStandardworkdays());
            ps.setBigDecimal(4, p.getActualworkdays());
            ps.setBigDecimal(5, p.getOthours());
            ps.setBigDecimal(6, p.getBasesalary());
            ps.setBigDecimal(7, p.getActualbasesalary());
            ps.setBigDecimal(8, p.getOtsalary());
            ps.setBigDecimal(9, p.getTotalallowanceamount());
            ps.setBigDecimal(10, p.getBonusamount());
            ps.setBigDecimal(11, p.getGrossamount());
            ps.setBigDecimal(12, p.getBhxhamount());
            ps.setBigDecimal(13, p.getBhytamount());
            ps.setBigDecimal(14, p.getBhtnamount());
            ps.setBigDecimal(15, p.getTotalinsurancededuction());
            ps.setInt(16, p.getDependentscount());
            ps.setBigDecimal(17, p.getDependentdeduction());
            ps.setBigDecimal(18, p.getTaxableincome());
            ps.setBigDecimal(19, p.getTaxdeduction());
            ps.setBigDecimal(20, p.getPenaltyamount());
            ps.setBigDecimal(21, p.getAdvanceamount());
            ps.setBigDecimal(22, p.getOtherdeductions());
            ps.setBigDecimal(23, p.getNetamount());
            ps.setString(24, p.getStatus());
            if (p.getAdjustedbyaccountid() != null)
                ps.setInt(25, p.getAdjustedbyaccountid());
            else
                ps.setNull(25, java.sql.Types.INTEGER);

            if (ps.executeUpdate() > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next())
                        return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public void insertPayslipAllowance(int payslipId, int allowanceTypeId, java.math.BigDecimal amount) {
        String sql = "INSERT INTO payslip_allowances (PayslipId, AllowanceTypeId, Amount) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, payslipId);
            ps.setInt(2, allowanceTypeId);
            ps.setBigDecimal(3, amount);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean updatePayslip(Payslips p) {
        String sql = "UPDATE payslips SET BonusAmount=?, PenaltyAmount=?, AdvanceAmount=?, " +
                "GrossAmount=?, TaxableIncome=?, TaxDeduction=?, NetAmount=?, Note=?, AdjustedByAccountId=? " +
                "WHERE Id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setBigDecimal(1, p.getBonusamount());
            ps.setBigDecimal(2, p.getPenaltyamount());
            ps.setBigDecimal(3, p.getAdvanceamount());
            ps.setBigDecimal(4, p.getGrossamount());
            ps.setBigDecimal(5, p.getTaxableincome());
            ps.setBigDecimal(6, p.getTaxdeduction());
            ps.setBigDecimal(7, p.getNetamount());
            ps.setString(8, p.getNote());
            if (p.getAdjustedbyaccountid() != null) ps.setInt(9, p.getAdjustedbyaccountid());
            else ps.setNull(9, java.sql.Types.INTEGER);
            ps.setInt(10, p.getId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }
}