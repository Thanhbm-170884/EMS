package com.ems.service;

import com.ems.dto.BaseSalaryDTO;
import com.ems.dto.SalarySummaryDTO;
import com.ems.dto.EmployeeBalanceDTO;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;

public class BaseSalaryServiceTest {

    @Test
    public void testBaseSalaryDTOSettersAndGetters() {
        BaseSalaryDTO dto = new BaseSalaryDTO();
        dto.setId(1);
        dto.setEmployeeCode("EMP001");
        dto.setFullName("Nguyen Van A");
        dto.setBaseSalary(new BigDecimal("15000000.00"));
        dto.setDepartmentName("Phòng Công Nghệ Thông Tin");
        dto.setPositionName("Senior Developer");
        dto.setStatus(true);

        Assertions.assertEquals(1, dto.getId());
        Assertions.assertEquals("EMP001", dto.getEmployeeCode());
        Assertions.assertEquals("Nguyen Van A", dto.getFullName());
        Assertions.assertEquals(new BigDecimal("15000000.00"), dto.getBaseSalary());
        Assertions.assertEquals("Phòng Công Nghệ Thông Tin", dto.getDepartmentName());
        Assertions.assertEquals("Senior Developer", dto.getPositionName());
        Assertions.assertTrue(dto.getStatus());
    }

    @Test
    public void testSalarySummaryDTO() {
        SalarySummaryDTO summary = new SalarySummaryDTO(
                10,
                new BigDecimal("20000000.00"),
                new BigDecimal("35000000.00"),
                new BigDecimal("10000000.00"),
                new BigDecimal("200000000.00")
        );

        Assertions.assertEquals(10, summary.getTotalEmployees());
        Assertions.assertEquals(new BigDecimal("20000000.00"), summary.getAverageSalary());
        Assertions.assertEquals(new BigDecimal("35000000.00"), summary.getMaxSalary());
        Assertions.assertEquals(new BigDecimal("10000000.00"), summary.getMinSalary());
        Assertions.assertEquals(new BigDecimal("200000000.00"), summary.getTotalBudget());
    }

    @Test
    @Disabled("Yêu cầu kết nối CSDL MySQL cục bộ")
    public void printRequestTypes() throws java.sql.SQLException {
        try (java.sql.Connection conn = com.ems.util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement("SELECT * FROM requesttypes");
             java.sql.ResultSet rs = ps.executeQuery()) {
            System.out.println("=== REQUEST TYPES ===");
            while (rs.next()) {
                System.out.println("ID: " + rs.getInt("Id") + ", Code: " + rs.getString("Code") + ", Name: " + rs.getString("Name"));
            }
        }
    }

    @Test
    @Disabled("Yêu cầu kết nối CSDL MySQL cục bộ")
    public void printRequests() throws java.sql.SQLException {
        try (java.sql.Connection conn = com.ems.util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement("SELECT r.Id, r.RequestTypeId, r.Status, r.Value, r.StartDate, r.EndDate, rt.Name FROM requests r JOIN requesttypes rt ON r.RequestTypeId = rt.Id ORDER BY r.Id DESC LIMIT 10");
             java.sql.ResultSet rs = ps.executeQuery()) {
            System.out.println("=== RECENT REQUESTS ===");
            while (rs.next()) {
                System.out.println("ID: " + rs.getInt("Id") + ", TypeId: " + rs.getInt("RequestTypeId") + ", TypeName: " + rs.getString("Name") + ", Status: " + rs.getString("Status") + ", Value: " + rs.getDouble("Value") + ", StartDate: " + rs.getTimestamp("StartDate"));
            }
        }
    }

    @Test
    @Disabled("Yêu cầu kết nối CSDL MySQL cục bộ")
    public void testDeductLeaveDaysAndRemainingSalaryAdvance() throws java.sql.SQLException {
        com.ems.dao.RequestDAO requestDao = new com.ems.dao.RequestDAO();
        com.ems.dao.EmployeeBalanceDAO balanceDao = new com.ems.dao.EmployeeBalanceDAO();

        // Let's test for Employee Account ID 3 (hoangnam), who corresponds to UserId = 3
        int employeeAccountId = 3;
        int employeeUserId = 3;
        int managerAccountId = 2; // quochuy

        // --- PART 1: LEAVE DAYS DEDUCTION ---
        // Get initial leave balance
        EmployeeBalanceDTO initialBalance = balanceDao.getEmployeeBalanceByUserId(employeeUserId);
        System.out.println("Initial Leave: Total=" + initialBalance.getTotalDays() + ", Used=" + initialBalance.getUsedDays() + ", Remaining=" + initialBalance.getRemainingDays());

        // Create a leave request
        com.ems.dto.RequestDTO leaveReq = new com.ems.dto.RequestDTO();
        leaveReq.setTitle("Nghỉ phép test");
        leaveReq.setReason("Nghỉ phép nghỉ ngơi");
        leaveReq.setRequestTypeId(1); // Annual Leave
        leaveReq.setCreatedByAccountId(employeeAccountId);
        leaveReq.setValue(2.0); // 2 days
        leaveReq.setStatus("Pending");
        
        java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
        leaveReq.setStartDate(now);
        leaveReq.setEndDate(now);

        boolean insertLeave = requestDao.insert(leaveReq);
        Assertions.assertTrue(insertLeave);

        // Find the inserted request ID
        int leaveRequestId = -1;
        try (java.sql.Connection conn = com.ems.util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement("SELECT MAX(Id) AS MaxId FROM requests WHERE CreatedByAccountId = ? AND RequestTypeId = 1")) {
            ps.setInt(1, employeeAccountId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    leaveRequestId = rs.getInt("MaxId");
                }
            }
        }
        Assertions.assertTrue(leaveRequestId > 0);

        // Approve it and call the logic
        boolean approvedLeave = requestDao.updateStatusForApprover(leaveRequestId, managerAccountId, "Approved", null);
        Assertions.assertTrue(approvedLeave);

        // Call the deduction method
        com.ems.dto.RequestDTO fetchedLeaveReq = requestDao.getById(leaveRequestId);
        Assertions.assertNotNull(fetchedLeaveReq);
        
        boolean deducted = balanceDao.deductLeaveDays(fetchedLeaveReq.getCreatedByAccountId(), fetchedLeaveReq.getValue());
        Assertions.assertTrue(deducted);

        EmployeeBalanceDTO finalBalance = balanceDao.getEmployeeBalanceByUserId(employeeUserId);
        System.out.println("Final Leave: Total=" + finalBalance.getTotalDays() + ", Used=" + finalBalance.getUsedDays() + ", Remaining=" + finalBalance.getRemainingDays());
        
        // Assertions
        Assertions.assertEquals(initialBalance.getUsedDays() + (int)fetchedLeaveReq.getValue(), finalBalance.getUsedDays());
        Assertions.assertEquals(initialBalance.getRemainingDays() - (int)fetchedLeaveReq.getValue(), finalBalance.getRemainingDays());

        // --- PART 2: SALARY ADVANCE DEDUCTION ---
        // Get initial salary advance details
        EmployeeBalanceDTO initialAdvanceBal = balanceDao.getEmployeeBalanceByUserId(employeeUserId);
        double initialAdvanced = initialAdvanceBal.getAdvancedThisMonth();
        double baseSalary = initialAdvanceBal.getBaseSalary();
        double initialRemainingAdvance = (baseSalary * 0.5) - initialAdvanced;
        System.out.println("Base Salary=" + baseSalary + ", Initial Advanced=" + initialAdvanced + ", Initial Remaining Advance=" + initialRemainingAdvance);

        // Create a salary advance request
        com.ems.dto.RequestDTO advReq = new com.ems.dto.RequestDTO();
        advReq.setTitle("Ứng lương test");
        advReq.setReason("Cần tiền chi tiêu");
        advReq.setRequestTypeId(3); // Ứng lương
        advReq.setCreatedByAccountId(employeeAccountId);
        advReq.setValue(150000.0); // 150,000 VND
        advReq.setStatus("Pending");
        advReq.setStartDate(now); // Set to current time (simulating RequestEmployeeController)
        advReq.setEndDate(now);

        boolean insertAdv = requestDao.insert(advReq);
        Assertions.assertTrue(insertAdv);

        // Find the inserted request ID
        int advRequestId = -1;
        try (java.sql.Connection conn = com.ems.util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement("SELECT MAX(Id) AS MaxId FROM requests WHERE CreatedByAccountId = ? AND RequestTypeId = 3")) {
            ps.setInt(1, employeeAccountId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    advRequestId = rs.getInt("MaxId");
                }
            }
        }
        Assertions.assertTrue(advRequestId > 0);

        // Approve it
        boolean approvedAdv = requestDao.updateStatusForApprover(advRequestId, managerAccountId, "Approved", null);
        Assertions.assertTrue(approvedAdv);

        EmployeeBalanceDTO finalAdvanceBal = balanceDao.getEmployeeBalanceByUserId(employeeUserId);
        double finalAdvanced = finalAdvanceBal.getAdvancedThisMonth();
        double finalRemainingAdvance = (baseSalary * 0.5) - finalAdvanced;
        System.out.println("Final Advanced=" + finalAdvanced + ", Final Remaining Advance=" + finalRemainingAdvance);

        // Assertions: finalAdvanced should increase by 150000.0, so finalRemainingAdvance should decrease by 150000.0
        Assertions.assertEquals(initialAdvanced + 150000.0, finalAdvanced, 0.001);
        Assertions.assertEquals(initialRemainingAdvance - 150000.0, finalRemainingAdvance, 0.001);
    }
}
