package com.gb.et.models;

import java.util.UUID;
import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "files")
@Data
public class FileEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;
    private UUID fileUuid;
    private String filename;

    @Lob
    @Column(name = "data")
    private byte[] data;
}
