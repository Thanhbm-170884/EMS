package com.ems.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DBConnection
 * -------------
 * Class tiện ích để lấy kết nối JDBC tới MySQL.
 * Dùng chung cho toàn bộ các DAO trong dự án, tránh lặp code kết nối ở mỗi DAO.
 *
 * CÁCH DÙNG trong DAO:
 *   try (Connection conn = DBConnection.getConnection()) {
 *       // thao tác với conn ở đây
 *   } catch (SQLException e) {
 *       e.printStackTrace();
 *   }
 */
public class DBConnection {

    // ===== CẤU HÌNH - SỬA THEO MÔI TRƯỜNG CỦA BẠN =====
    private static final String URL = "jdbc:mysql://localhost:3306/hrms_db?useSSL=false&serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
    private static final String USER = "root";
    private static final String PASSWORD = "Thanh123";

    // Load driver 1 lần duy nhất khi class được nạp
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Không tìm thấy MySQL JDBC Driver. "
                    + "Kiểm tra lại đã thêm mysql-connector-j vào classpath/pom.xml chưa.", e);
        }
    }

    // Không cho tạo instance của class này (chỉ dùng static method)
    private DBConnection() {
    }

    /**
     * Tạo và trả về 1 Connection mới tới MySQL.
     * Mỗi lần gọi sẽ mở 1 connection mới — nên dùng try-with-resources để tự đóng sau khi dùng xong.
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}