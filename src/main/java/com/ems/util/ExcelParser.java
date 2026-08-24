package com.ems.util;

import com.ems.model.AttendanceRecord;
import org.apache.poi.ss.usermodel.*;

import java.io.InputStream;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

/**
 * Đọc file Excel chấm công và chuyển thành danh sách AttendanceRecord.
 * Cấu trúc cột kỳ vọng (header ở dòng 0, dữ liệu bắt đầu từ dòng 1):
 * A: Ngày | B: Mã nhân viên | C: Họ và Tên | D: Phòng ban | E: Check in | F: Check out
 */
public class ExcelParser {

    private static final LocalTime STANDARD_CHECKIN = LocalTime.of(8, 0); // mốc 8h sáng
    private static final LocalTime STANDARD_CHECKOUT = LocalTime.of(17, 0);
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("H:mm");
    private static final DataFormatter DATA_FORMATTER = new DataFormatter();

    public static List<AttendanceRecord> parse(InputStream fileInputStream) throws Exception {
        List<AttendanceRecord> result = new ArrayList<>();

        try (Workbook workbook = WorkbookFactory.create(fileInputStream)) {
            Sheet sheet = workbook.getSheetAt(0);

            // Bỏ qua dòng header (dòng đầu tiên = index 0)
            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null || isRowEmpty(row)) {
                    continue; // bỏ qua dòng trống
                }

                LocalDate date = readDateCell(row.getCell(0));
                String employeeCode = readStringCell(row.getCell(1));
                String fullName = readStringCell(row.getCell(2));
                String department = readStringCell(row.getCell(3));
                LocalTime checkIn = readTimeCell(row.getCell(4));
                LocalTime checkOut = readTimeCell(row.getCell(5));


                long lateMinutes = 0;
                if (checkIn != null && checkIn.isAfter(STANDARD_CHECKIN)) {
                    lateMinutes = Duration.between(STANDARD_CHECKIN, checkIn).toMinutes();
                }
                long earlyLeaveMinutes = 0;
                if (checkOut != null && checkOut.isBefore(STANDARD_CHECKOUT)) {
                    earlyLeaveMinutes = Duration.between(checkOut, STANDARD_CHECKOUT).toMinutes();
                }
                System.out.println(
                        "DEBUG: Check-out = " + checkOut
                                + " | Standard = " + STANDARD_CHECKOUT
                                + " | EarlyLeave = " + earlyLeaveMinutes
                );

                result.add(new AttendanceRecord(date, employeeCode, fullName,
                        department, checkIn, checkOut, lateMinutes, earlyLeaveMinutes));
            }
        }

        return result;
    }

    private static boolean isRowEmpty(Row row) {
        Cell firstCell = row.getCell(0);
        return firstCell == null || firstCell.getCellType() == CellType.BLANK;
    }

    private static String readStringCell(Cell cell) {
        if (cell == null) return "";
        return DATA_FORMATTER.formatCellValue(cell).trim();
    }

    private static LocalDate readDateCell(Cell cell) {
        if (cell == null) return null;
        try {
            if (cell.getCellType() == CellType.NUMERIC && DateUtil.isCellDateFormatted(cell)) {
                return cell.getLocalDateTimeCellValue().toLocalDate();
            }
            // fallback: cột ngày được nhập dạng text "yyyy-MM-dd" hoặc "dd/MM/yyyy"
            String raw = cell.toString().trim();
            if (raw.contains("/")) {
                return LocalDate.parse(raw, DateTimeFormatter.ofPattern("d/M/yyyy"));
            }
            return LocalDate.parse(raw); // ISO: yyyy-MM-dd
        } catch (Exception e) {
            return null;
        }
    }

    private static LocalTime readTimeCell(Cell cell) {
        if (cell == null) return null;
        try {
            if (cell.getCellType() == CellType.NUMERIC && DateUtil.isCellDateFormatted(cell)) {
                return cell.getLocalDateTimeCellValue().toLocalTime();
            }
            // fallback: cột giờ được nhập dạng text "8:15" hoặc "08:15"
            String raw = cell.toString().trim();
            return LocalTime.parse(raw, TIME_FORMATTER);
        } catch (Exception e) {
            return null;
        }
    }
}
