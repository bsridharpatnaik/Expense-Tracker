package com.gb.et.controllers;

import com.gb.et.data.TransactionCreateDTO;
import com.gb.et.models.Transaction;
import com.gb.et.service.TransactionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/transaction")
public class TransactionController {

    @Autowired
    TransactionService transactionService;

    @PostMapping
    public ResponseEntity<Transaction> createTransaction(@RequestBody TransactionCreateDTO payload) {
        try {
            Transaction newTransaction = transactionService.createTransaction(payload);
            return new ResponseEntity<>(newTransaction, HttpStatus.CREATED);  // Return 201 status code
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @PutMapping("/{id}")
    public Transaction updateTransaction(
            @PathVariable Long id,  // Extract path variable from URL
            @RequestBody TransactionCreateDTO payload) throws Exception {  // Extract request body as DTO
        return transactionService.updateTransaction(id, payload);
    }

    @GetMapping("/party")
    public List<String> getExistingParty() throws Exception {
        return transactionService.getParty();
    }
}
