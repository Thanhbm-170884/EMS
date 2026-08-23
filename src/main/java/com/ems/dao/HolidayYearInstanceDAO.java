package com.ems.dao;

import com.ems.model.HolidayYearInstance;
import com.ems.util.DBConnection;
import com.mysql.cj.xdevapi.DbDoc;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class HolidayYearInstanceDAO {

    public static Map<Integer, HolidayYearInstance> getInstanceByYear(int year) {
        Map<Integer, HolidayYearInstance> holidayYearInstanceMap = new HashMap<>();
        String sql = "Select Id, TemplateId, Year, StartDate, EndDate, Coefficient, CreatedBy " +
                "from holidayyearinstances where Year = ?";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            preparedStatement.setInt(1, year);
            try (ResultSet rs = preparedStatement.executeQuery()) {
                while (rs.next()) {
                    HolidayYearInstance hi = new HolidayYearInstance();
                    hi.setId(rs.getInt("Id"));
                    hi.setTemplateId(rs.getInt("TemplateId"));
                    hi.setYear(rs.getInt("Year"));
                    hi.setStartDate(rs.getObject("StartDate", LocalDate.class));
                    hi.setEndDate(rs.getObject("EndDate", LocalDate.class));
                    hi.setCoefficient(rs.getDouble("Coefficient"));
                    hi.setCreatedBy((Integer) rs.getObject("CreatedBy"));
                    holidayYearInstanceMap.put(hi.getTemplateId(), hi);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return holidayYearInstanceMap;
    }

    public static List<HolidayYearInstance> getInstanceInRange(LocalDate from, LocalDate to) {
        List<HolidayYearInstance> list = new ArrayList<>();
        String sql = "select hi.Id, hi.TemplateId, hi.Year, hi.StartDate, hi.EndDate, hi.Coefficient, hi.CreatedBy, ht.HolidayName " +
                "from holidayyearinstances hi " +
                "join holidaytemplates ht on ht.Id = hi.TemplateId " +
                "where hi.StartDate <= ? and hi.EndDate >= ?";

        try(Connection conn = DBConnection.getConnection();
            PreparedStatement stm = conn.prepareStatement(sql)) {
            stm.setObject(1, to);
            stm.setObject(2, from);
            try (ResultSet rs = stm.executeQuery()) {
                while (rs.next()) {
                    HolidayYearInstance hi = new HolidayYearInstance();
                    hi.setId(rs.getInt("Id"));
                    hi.setTemplateId(rs.getInt("TemplateId"));
                    hi.setYear(rs.getInt("Year"));
                    hi.setStartDate(rs.getObject("StartDate", LocalDate.class));
                    hi.setEndDate(rs.getObject("EndDate", LocalDate.class));
                    hi.setCoefficient(rs.getDouble("Coefficient"));
                    hi.setCreatedBy((Integer) rs.getObject("CreatedBy"));
                    hi.setHolidayName(rs.getString("HolidayName"));
                    list.add(hi);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return list;
    }

    public static void upsertInstance(HolidayYearInstance hi){
        String sql = "insert into holidayyearinstances (TemplateId, Year, StartDate, EndDate, Coefficient, CreatedBy) " +
                "values (?, ?, ?, ?, ?, ?) " +
                "on duplicate key update StartDate = ?, EndDate = ?, Coefficient = ?";
        try(Connection conn = DBConnection.getConnection();
            PreparedStatement stm = conn.prepareStatement(sql)) {
            stm.setInt(1, hi.getTemplateId());
            stm.setInt(2, hi.getYear());
            
            if (hi.getStartDate() != null) {
                stm.setDate(3, java.sql.Date.valueOf(hi.getStartDate()));
                stm.setDate(7, java.sql.Date.valueOf(hi.getStartDate()));
            } else {
                stm.setNull(3, java.sql.Types.DATE);
                stm.setNull(7, java.sql.Types.DATE);
            }
            
            if (hi.getEndDate() != null) {
                stm.setDate(4, java.sql.Date.valueOf(hi.getEndDate()));
                stm.setDate(8, java.sql.Date.valueOf(hi.getEndDate()));
            } else {
                stm.setNull(4, java.sql.Types.DATE);
                stm.setNull(8, java.sql.Types.DATE);
            }
            
            stm.setObject(5, hi.getCoefficient());
            stm.setObject(6, hi.getCreatedBy());
            stm.setObject(9, hi.getCoefficient());
            
            stm.execute();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
}
