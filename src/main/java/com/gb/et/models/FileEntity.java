package com.gb.et.models;

import java.util.UUID;

import lombok.Data;

import javax.persistence.*;

@Entity
@Table(name = "files")
@Data
public class FileEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;
    private String fileUuid;
    private String filename;

    @Lob
    @Column(name = "data")
    private byte[] data;
}
