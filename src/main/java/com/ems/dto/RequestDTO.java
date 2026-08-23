package com.ems.dto;

import java.sql.Timestamp;

public class RequestDTO {

    private int id;
    private String title;
    private String reason;
    private String status;
    private Timestamp startDate;
    private Timestamp endDate;
    private double value;
    private String imageUrl;
    private Timestamp createdAt;

    private int requestTypeId;
    private String requestTypeName;

    private int createdByAccountId;
    private String createdByName;

    private Integer currentApproverAccountId;
    private String currentApproverName;
    private String rejectionReason;

    public RequestDTO() {
    }

    public RequestDTO(int id, String title, String reason, String status,
                      Timestamp startDate, Timestamp endDate,
                      double value, String imageUrl, Timestamp createdAt,
                      int requestTypeId, String requestTypeName,
                      int createdByAccountId, String createdByName,
                      Integer currentApproverAccountId, String currentApproverName) {

        this.id = id;
        this.title = title;
        this.reason = reason;
        this.status = status;
        this.startDate = startDate;
        this.endDate = endDate;
        this.value = value;
        this.imageUrl = imageUrl;
        this.createdAt = createdAt;
        this.requestTypeId = requestTypeId;
        this.requestTypeName = requestTypeName;
        this.createdByAccountId = createdByAccountId;
        this.createdByName = createdByName;
        this.currentApproverAccountId = currentApproverAccountId;
        this.currentApproverName = currentApproverName;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getStartDate() {
        return startDate;
    }

    public void setStartDate(Timestamp startDate) {
        this.startDate = startDate;
    }

    public Timestamp getEndDate() {
        return endDate;
    }

    public void setEndDate(Timestamp endDate) {
        this.endDate = endDate;
    }

    public double getValue() {
        return value;
    }

    public void setValue(double value) {
        this.value = value;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public int getRequestTypeId() {
        return requestTypeId;
    }

    public void setRequestTypeId(int requestTypeId) {
        this.requestTypeId = requestTypeId;
    }

    public String getRequestTypeName() {
        return requestTypeName;
    }

    public void setRequestTypeName(String requestTypeName) {
        this.requestTypeName = requestTypeName;
    }

    public int getCreatedByAccountId() {
        return createdByAccountId;
    }

    public void setCreatedByAccountId(int createdByAccountId) {
        this.createdByAccountId = createdByAccountId;
    }

    public String getCreatedByName() {
        return createdByName;
    }

    public void setCreatedByName(String createdByName) {
        this.createdByName = createdByName;
    }

    public Integer getCurrentApproverAccountId() {
        return currentApproverAccountId;
    }

    public void setCurrentApproverAccountId(Integer currentApproverAccountId) {
        this.currentApproverAccountId = currentApproverAccountId;
    }

    public String getCurrentApproverName() {
        return currentApproverName;
    }

    public void setCurrentApproverName(String currentApproverName) {
        this.currentApproverName = currentApproverName;
    }

    public String getRejectionReason() {
        return rejectionReason;
    }

    public void setRejectionReason(String rejectionReason) {
        this.rejectionReason = rejectionReason;
    }
}