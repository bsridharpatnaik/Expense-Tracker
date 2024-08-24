package com.gb.et.data;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.Objects;
import java.util.UUID;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class FileInfo implements Serializable {

    private UUID fileUuid;
    private String filename;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        FileInfo fileInfo = (FileInfo) o;
        return Objects.equals(fileUuid, fileInfo.fileUuid) && Objects.equals(filename, fileInfo.filename);
    }

    @Override
    public int hashCode() {
        return Objects.hash(fileUuid, filename);
    }

    @Override
    public String toString() {
        return "FileInfo{" +
                "fileUuid=" + fileUuid +
                ", filename='" + filename + '\'' +
                '}';
    }
}
