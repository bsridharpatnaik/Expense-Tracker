package com.gb.et.repository;

import com.gb.et.models.FileEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface FileRepository extends JpaRepository<FileEntity, Long> {
    FileEntity findByFileUuid(String fileUuid);
}
