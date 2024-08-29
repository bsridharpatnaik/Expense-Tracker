package com.gb.et.controllers;

import com.gb.et.data.FileStorageException;
import com.gb.et.data.FolderContentsResponse;
import com.gb.et.data.InvalidOperationException;
import com.gb.et.models.FileEntityForVault;
import com.gb.et.models.FolderEntity;
import com.gb.et.service.FolderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import com.gb.et.data.FileUploadResponse;
import java.io.IOException;

@RestController
@RequestMapping("/api/vault")
public class VaultController {

    @Autowired
    private FolderService folderService;

    // Create a folder
    @PostMapping("/folders")
    public ResponseEntity<FolderEntity> createFolder(@RequestParam String name, @RequestParam(required = false) Long parentId) {
        FolderEntity folder = folderService.createFolder(name, parentId);
        return ResponseEntity.ok(folder);
    }

    // Upload a file
    @PostMapping("/files")
    public ResponseEntity<FileUploadResponse> uploadFile(@RequestParam("file") MultipartFile file, @RequestParam Long folderId) {
        try {
            String filename = file.getOriginalFilename();
            FileEntityForVault uploadedFile = folderService.uploadFile(filename, file.getBytes(), folderId);

            // Create and return a response DTO with only the necessary fields
            FileUploadResponse response = new FileUploadResponse(
                    uploadedFile.getFilename(),
                    uploadedFile.getUploadDate(),
                    uploadedFile.getFolder().getId()
            );

            return ResponseEntity.ok(response);
        } catch (IOException ex) {
            throw new FileStorageException("Failed to upload file: " + ex.getMessage());
        }
    }

    // Get folder contents (simplified response)
    @GetMapping("/folders")
    public ResponseEntity<FolderContentsResponse> getFolderContents(@RequestParam(required = false) Long folderId) {
        FolderContentsResponse folderContents = folderService.getFolderContentsWithSummary(folderId);
        return ResponseEntity.ok(folderContents);
    }

    // Get folder path
    @GetMapping("/folders/{folderId}/path")
    public ResponseEntity<String> getFolderPath(@PathVariable Long folderId) {
        FolderEntity folder = folderService.getFolderContents(folderId);
        String fullPath = folder.getFullPath();
        return ResponseEntity.ok(fullPath);
    }

    // Get parent folder
    @GetMapping("/folders/{folderId}/parent")
    public ResponseEntity<FolderEntity> getParentFolder(@PathVariable Long folderId) {
        FolderEntity currentFolder = folderService.getFolderContents(folderId);
        FolderEntity parentFolder = currentFolder.getParentFolder();
        if (parentFolder == null) {
            throw new InvalidOperationException("This is the root folder, no parent exists.");
        }
        return ResponseEntity.ok(parentFolder);
    }

    // Get home folder
    @GetMapping("/folders/home")
    public ResponseEntity<FolderEntity> getHomeFolder() {
        FolderEntity rootFolder = folderService.getRootFolder();
        return ResponseEntity.ok(rootFolder);
    }

    // Download file
    @GetMapping("/files/download/{fileUuid}")
    public ResponseEntity<byte[]> downloadFile(@PathVariable String fileUuid) {
        FileEntityForVault file = folderService.getFileByUuid(fileUuid);

        return ResponseEntity.ok()
                .header("Content-Disposition", "attachment; filename=\"" + file.getFilename() + "\"")
                .header("Content-Type", "application/octet-stream")
                .body(file.getData());
    }
}
