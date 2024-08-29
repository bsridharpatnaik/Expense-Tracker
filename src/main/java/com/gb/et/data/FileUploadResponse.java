package com.gb.et.data;

import com.fasterxml.jackson.annotation.JsonFormat;

import java.util.Date;

public class FileUploadResponse {
    private String filename;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd-MM-yyyy")
    private Date uploadDate;
    private Long folderId;

    public FileUploadResponse(String filename, Date uploadDate, Long folderId) {
        this.filename = filename;
        this.uploadDate = uploadDate;
        this.folderId = folderId;
    }

    // Getters and setters (if needed)
    public String getFilename() {
        return filename;
    }

    public void setFilename(String filename) {
        this.filename = filename;
    }

    public Date getUploadDate() {
        return uploadDate;
    }

    public void setUploadDate(Date uploadDate) {
        this.uploadDate = uploadDate;
    }

    public Long getFolderId() {
        return folderId;
    }

    public void setFolderId(Long folderId) {
        this.folderId = folderId;
    }
}

