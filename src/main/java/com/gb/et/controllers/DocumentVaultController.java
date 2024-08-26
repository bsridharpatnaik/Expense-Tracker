package com.gb.et.controllers;

import com.gb.et.data.FileInfo;
import com.gb.et.models.DocumentVault;
import com.gb.et.models.Organization;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.annotation.PostConstruct;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

@RestController
@RequestMapping("/api/vault")
public class DocumentVaultController {

    private final Map<Long, DocumentVault> vaults = new HashMap<>(); // Mocked database

    @GetMapping()
    public ResponseEntity<DocumentVault> getVaultContent() {
        DocumentVault vault = vaults.get(1L);
        if (vault == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(vault);
    }

    @PatchMapping("/add")
    public ResponseEntity<DocumentVault> addFileInfoToVault(@RequestBody FileInfo fileInfo) {
        DocumentVault vault = vaults.get(1L);
        if (vault == null) {
            return ResponseEntity.notFound().build();
        }
        // Add new FileInfo at the beginning of the list to keep it on top
        List<FileInfo> updatedFiles = new ArrayList<>(vault.getFiles());
        updatedFiles.add(0, fileInfo); // Adds the new file to the top of the list
        vault.setFiles(updatedFiles);
        return ResponseEntity.ok(vault);
    }

    @PatchMapping("/remove")
    public ResponseEntity<DocumentVault> removeFileInfoFromVault(@RequestBody FileInfo fileInfo) {
        DocumentVault vault = vaults.get(1L);
        if (vault == null) {
            return ResponseEntity.notFound().build();
        }
        vault.getFiles().removeIf(file -> file.getFileUuid().equals(fileInfo.getFileUuid()));
        return ResponseEntity.ok(vault);
    }

    @PostConstruct
    public void init() throws ParseException {
        DocumentVault vault = new DocumentVault();
        vault.setVaultId(1L);
        vault.setFiles(new ArrayList<>());
        vault.setOrganization(new Organization(100L, "Global Tech Solutions"));
        List<FileInfo> files = new ArrayList<>();
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy");

        String[] filenames = {
                "contract-2024-01-03.pdf", "summary-2024-01-04.pdf", "budget-2024-01-05.pdf",
                "meeting-notes-2024-01-06.pdf", "proposal-2024-01-07.pdf", "email-correspondence-2024-01-08.pdf",
                "project-plan-2024-01-09.pdf", "compliance-documents-2024-01-10.pdf", "sales-report-2024-01-11.pdf",
                "customer-feedback-2024-01-12.pdf", "audit-report-2024-01-13.pdf", "training-material-2024-01-14.pdf",
                "annual-review-2024-01-15.pdf", "financial-statement-2024-01-16.pdf", "risk-assessment-2024-01-17.pdf",
                "policy-document-2024-01-18.pdf", "strategic-plan-2024-01-19.pdf", "service-agreement-2024-01-20.pdf"
        };

        for (int i = 0; i < filenames.length; i++) {
            files.add(new FileInfo(UUID.randomUUID(), filenames[i], dateFormat.parse(String.format("0%d-01-2024", i + 3))));
        }
        vault.setFiles(files);
        vaults.put(1L, vault);
    }
}

