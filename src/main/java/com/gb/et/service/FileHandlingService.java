package com.gb.et.service;

import com.gb.et.data.FileInfo;
import com.gb.et.models.FileEntity;
import com.gb.et.repository.FileRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Date;
import java.util.UUID;

@Service
public class FileHandlingService {

    @Autowired
    private FileRepository fileRepository;

    public FileInfo uploadFile(MultipartFile file) throws IOException {
        String filename = file.getOriginalFilename();
        byte[] data = file.getBytes();
        UUID fileUuid = UUID.randomUUID();
        FileEntity fileEntity = new FileEntity();
        fileEntity.setFileUuid(fileUuid);
        fileEntity.setFilename(filename);
        fileEntity.setData(data);
        //fileRepository.save(fileEntity);
        return new FileInfo(fileUuid, filename, new Date());
    }

    public byte[] downloadFile(UUID fileUuid) throws IOException {
        FileEntity fileEntity = fileRepository.findByFileUuid(fileUuid);
        if (fileEntity == null) {
            throw new IOException("File not found");
        }
        return fileEntity.getData();
    }
}