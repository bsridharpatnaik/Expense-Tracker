package com.gb.et.data;

import lombok.Data;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonProperty;

public class FolderContentsResponse {
    private Long id;
    private String name;
    private Long parentFolderId;
    private List<FolderSummary> subFolders;
    private List<FileSummary> files;

    // Constructor
    public FolderContentsResponse(Long id, String name, Long parentFolderId, List<FolderSummary> subFolders, List<FileSummary> files) {
        this.id = id;
        this.name = name;
        this.parentFolderId = parentFolderId;
        this.subFolders = subFolders;
        this.files = files;
    }

    // Getters and Setters
    @JsonProperty
    public Long getId() {
        return id;
    }

    @JsonProperty
    public String getName() {
        return name;
    }

    @JsonProperty
    public Long getParentFolderId() {
        return parentFolderId;
    }

    @JsonProperty
    public List<FolderSummary> getSubFolders() {
        return subFolders;
    }

    @JsonProperty
    public List<FileSummary> getFiles() {
        return files;
    }

    public static class FolderSummary {
        private Long id;
        private String name;

        // Constructor
        public FolderSummary(Long id, String name) {
            this.id = id;
            this.name = name;
        }

        // Getters and Setters
        @JsonProperty
        public Long getId() {
            return id;
        }

        @JsonProperty
        public String getName() {
            return name;
        }
    }

    public static class FileSummary {
        private Long id;
        private String filename;

        // Constructor
        public FileSummary(Long id, String filename) {
            this.id = id;
            this.filename = filename;
        }

        // Getters and Setters
        @JsonProperty
        public Long getId() {
            return id;
        }

        @JsonProperty
        public String getFilename() {
            return filename;
        }
    }
}
