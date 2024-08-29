package com.gb.et.service;

import com.gb.et.data.FileStorageException;
import com.gb.et.data.FolderContentsResponse;
import com.gb.et.data.InvalidOperationException;
import com.gb.et.data.ResourceNotFoundException;
import com.gb.et.models.FileEntityForVault;
import com.gb.et.models.FolderEntity;
import com.gb.et.models.Organization;
import com.gb.et.models.User;
import com.gb.et.repository.FolderRepository;
import com.gb.et.repository.VaultFileRepository;
import com.gb.et.security.services.UserDetailsServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Date;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class FolderService {

    @Autowired
    private FolderRepository folderRepository;

    @Autowired
    VaultFileRepository fileRepository;

    @Autowired
    UserDetailsServiceImpl userDetailsService;

    public FolderContentsResponse getFolderContentsWithSummary(Long folderId) {
        FolderEntity folder = (folderId == null) ? getOrCreateRootFolderWithContents() : getFolderContents(folderId);

        List<FolderContentsResponse.FolderSummary> subFolders = folder.getSubFolders().stream()
                .map(subFolder -> new FolderContentsResponse.FolderSummary(subFolder.getId(), subFolder.getName()))
                .collect(Collectors.toList());

        List<FolderContentsResponse.FileSummary> files = folder.getFiles().stream()
                .map(file -> new FolderContentsResponse.FileSummary(file.getId(), file.getFilename()))
                .collect(Collectors.toList());

        return new FolderContentsResponse(
                folder.getId(),
                folder.getName(),
                (folder.getParentFolder() != null) ? folder.getParentFolder().getId() : null,
                subFolders,
                files
        );
    }

    public FolderEntity getOrCreateRootFolderWithContents() {
        Organization organization = userDetailsService.getOrganizationForCurrentUser();
        return folderRepository.findRootFolderByOrganizationId(organization.getId())
                .orElseGet(() -> {
                    FolderEntity rootFolder = new FolderEntity();
                    rootFolder.setName("root");
                    rootFolder.setOrganization(organization);
                    return folderRepository.save(rootFolder);
                });
    }

    // Create a folder
    public FolderEntity createFolder(String name, Long parentId) {
        Organization organization = userDetailsService.getOrganizationForCurrentUser();

        // If creating a root folder, ensure there's no existing root folder
        if (parentId == null) {
            Optional<FolderEntity> existingRootFolder = folderRepository.findRootFolderByOrganizationId(organization.getId());
            if (existingRootFolder.isPresent()) {
                throw new InvalidOperationException("Root folder already exists for this organization.");
            }
        } else {
            // Check if a folder with the same name already exists in the specified parent folder
            boolean folderExists = folderRepository.existsByNameAndParentFolderId(name, parentId);
            if (folderExists) {
                throw new InvalidOperationException("A folder with the same name already exists in this location.");
            }
        }

        FolderEntity folder = new FolderEntity();
        folder.setName(name);
        folder.setOrganization(organization);

        if (parentId != null) {
            FolderEntity parentFolder = folderRepository.findById(parentId)
                    .orElseThrow(() -> new ResourceNotFoundException("Parent folder not found with ID: " + parentId));
            folder.setParentFolder(parentFolder);
        }

        return folderRepository.save(folder);
    }

    // Upload a file into a folder or the root folder if folderId is null
    public FileEntityForVault uploadFile(String filename, byte[] data, Long folderId) {
        Organization organization = userDetailsService.getOrganizationForCurrentUser();

        FolderEntity folder;
        if (folderId == null) {
            folder = folderRepository.findRootFolderByOrganizationId(organization.getId())
                    .orElseThrow(() -> new ResourceNotFoundException("Root folder not found for organization: " + organization.getName()));
        } else {
            folder = folderRepository.findById(folderId)
                    .orElseThrow(() -> new ResourceNotFoundException("Folder not found with ID: " + folderId));
        }

        if (data == null || data.length == 0) {
            throw new FileStorageException("File data is empty or invalid.");
        }

        // Check if a file with the same name already exists in the folder
        boolean fileExists = fileRepository.existsByFilenameAndFolder(filename, folder);
        if (fileExists) {
            throw new FileStorageException("A file with the same name already exists in this folder.");
        }

        FileEntityForVault file = new FileEntityForVault();
        file.setFilename(filename);
        file.setData(data);
        file.setOrganization(organization);
        file.setFolder(folder);
        file.setUploadDate(new Date());

        return fileRepository.save(file);
    }


    // Retrieve folder contents
    public FolderEntity getFolderContents(Long folderId) {
        return folderRepository.findById(folderId)
                .orElseThrow(() -> new ResourceNotFoundException("Folder not found with ID: " + folderId));
    }

    // Retrieve the root folder of an organization
    public FolderEntity getRootFolder() {
        Organization organization = userDetailsService.getOrganizationForCurrentUser();
        return folderRepository.findRootFolderByOrganizationId(organization.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Root folder not found for organization: " + organization.getName()));
    }

    // Retrieve a file by its UUID
    public FileEntityForVault getFileByUuid(String fileUuid) {
        FileEntityForVault file = fileRepository.findByFileUuid(fileUuid)
                .orElseThrow(() -> new ResourceNotFoundException("File not found with UUID: " + fileUuid));

        Organization currentUserOrganization = userDetailsService.getOrganizationForCurrentUser();

        if (!file.getOrganization().getId().equals(currentUserOrganization.getId())) {
            throw new AccessDeniedException("You do not have permission to access this file.");
        }

        return file;
    }
}

