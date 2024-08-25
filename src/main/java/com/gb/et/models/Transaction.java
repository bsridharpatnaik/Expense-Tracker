package com.gb.et.models;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.gb.et.data.FileInfo;
import com.gb.et.others.DoubleTwoDigitDecimalSerializer;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Entity
@Data
@NoArgsConstructor
public class Transaction {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    @JsonInclude
    private Long id;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd-MM-yyyy")
    private Date date;
    private String title;
    private String party;

    @JsonSerialize(using = DoubleTwoDigitDecimalSerializer.class)
    private Double amount;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "organization_id")
    @JsonIgnore
    private Organization organization;

    @ElementCollection
    @CollectionTable(name = "transaction_files", joinColumns = @JoinColumn(name = "transaction_id"))
    @Column(name = "file_info")
    private List<FileInfo> fileInfos = new ArrayList<>();

    @Enumerated(EnumType.STRING)
    private TransactionType transactionType;
}
