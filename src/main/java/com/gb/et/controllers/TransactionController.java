package com.gb.et.controllers;

import com.gb.et.data.TransactionCreateDTO;
import com.gb.et.models.Transaction;
import com.gb.et.service.TransactionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/transaction")
public class TransactionController {

    @Autowired
    TransactionService transactionService;

    @PostMapping
    public Transaction createTransaction(@RequestBody TransactionCreateDTO payload) {
        return transactionService.createTransaction(payload);
    }

    @PutMapping("/{id}")
    public Transaction updateTransaction(
            @PathVariable Long id,  // Extract path variable from URL
            @RequestBody TransactionCreateDTO payload) throws Exception {  // Extract request body as DTO
        return transactionService.updateTransaction(id, payload);
    }

}
