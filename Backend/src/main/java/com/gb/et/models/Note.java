// Note.java
package com.gb.et.models;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import javax.persistence.*;
import java.util.Date;
import java.util.List;
import java.util.UUID;

@Entity
@Data
public class Note {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    private Date date;

    @Column(length = 300)
    private String text;

    @ElementCollection
    @CollectionTable(name = "note_file_mapping", joinColumns = @JoinColumn(name = "note_id"))
    @Column(name = "file_uuid")
    private List<UUID> fileUuids;
}