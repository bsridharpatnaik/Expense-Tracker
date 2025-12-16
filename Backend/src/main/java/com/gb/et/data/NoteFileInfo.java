// NoteFileInfo.java
package com.gb.et.data;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.UUID;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class NoteFileInfo implements Serializable {
    private UUID fileUuid;
    private String filename;
}