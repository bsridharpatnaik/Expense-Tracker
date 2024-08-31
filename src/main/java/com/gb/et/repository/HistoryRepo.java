package com.gb.et.repository;

import com.gb.et.models.FolderEntity;
import com.gb.et.models.History;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface HistoryRepo extends JpaRepository<History, Long> {
}
