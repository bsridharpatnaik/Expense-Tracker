package com.gb.et.models;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDate;

@Entity
@Data
public class Transaction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private LocalDate date;
    private String title;
    private String party;
    private Double amount;
    private String filePath; // Path to file

    @ManyToOne
    @JoinColumn(name = "organization_id")
    private Organization organization;
}
