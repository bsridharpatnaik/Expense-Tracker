package com.gb.et.others;

import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.databind.SerializerProvider;
import com.fasterxml.jackson.databind.JsonSerializer;
import com.gb.et.data.FileInfo;
import com.gb.et.models.FileEntity;
import com.gb.et.repository.FileRepository;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.UUID;

public class FileInfoSerializer extends JsonSerializer<List<UUID>> {

    @Autowired
    FileRepository fileRepository;

    @Override
    public void serialize(List<UUID> uuidList, JsonGenerator gen, SerializerProvider serializers) throws IOException {
        // Start writing array
        gen.writeStartArray();

        for (UUID uuid : uuidList) {
            // Customize the output format
            SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy");
            FileEntity file = fileRepository.findByFileUuid(uuid.toString());
            gen.writeStartObject();
            gen.writeStringField("fileUuid", file.getFileUuid());
            gen.writeStringField("filename", file.getFilename());
            gen.writeStringField("uploadDate", dateFormat.format(file.getUploadDate()));
            gen.writeEndObject();
        }

        // End array
        gen.writeEndArray();
    }
}
