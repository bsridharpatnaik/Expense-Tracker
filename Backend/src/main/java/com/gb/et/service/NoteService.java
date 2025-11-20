// NoteService.java
package com.gb.et.service;

import com.gb.et.data.ResourceNotFoundException;
import com.gb.et.models.Note;
import com.gb.et.repository.NoteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

@Service
public class NoteService {

    @Autowired
    private NoteRepository noteRepository;

    public Note createNote(Note note) {
        return noteRepository.save(note);
    }

    public Note updateNote(Long id, Note updatedNote) {
        Note note = noteRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Note not found with id: " + id));
        note.setText(updatedNote.getText());
        note.setFileUuids(updatedNote.getFileUuids());
        return noteRepository.save(note);
    }

    public void deleteNote(Long id) {
        Note note = noteRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Note not found with id: " + id));
        noteRepository.delete(note);
    }

    public List<Note> getNotesByDate(Date date) {
        return noteRepository.findByDateOrderByIdDesc(date);
    }
}