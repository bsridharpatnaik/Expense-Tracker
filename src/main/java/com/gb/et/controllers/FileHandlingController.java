package com.gb.et.controllers;

import com.gb.et.data.FileInfo;
import com.gb.et.service.FileHandlingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.UUID;

@RestController
@RequestMapping("/api/file")
public class FileHandlingController {

    @Autowired
    private FileHandlingService fileHandlingService;

    @PostMapping("/upload")
    public ResponseEntity<FileInfo> uploadFile(@RequestParam("file") MultipartFile file) throws IOException {
        FileInfo fileInfo = fileHandlingService.uploadFile(file);
        return ResponseEntity.ok(fileInfo);
    }

    @GetMapping("/download/{fileUuid}")
    public ResponseEntity<Resource> downloadFile(@PathVariable UUID fileUuid) throws IOException {
        byte[] fileData = fileHandlingService.downloadFile(fileUuid);
        ByteArrayResource resource = new ByteArrayResource(fileData);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + fileUuid.toString())
                .body(resource);
    }
}
