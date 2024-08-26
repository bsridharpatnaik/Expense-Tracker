package com.gb.et.service;

import com.gb.et.data.TransactionCreateDTO;
import com.gb.et.models.Organization;
import com.gb.et.models.Transaction;
import com.gb.et.repository.TransactionRepository;
import com.gb.et.security.services.UserDetailsServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.PostMapping;

import java.util.List;
import java.util.Optional;

@Service
public class TransactionService {

    @Autowired
    TransactionRepository transactionRepository;

    @Autowired
    private TransactionValidationService validationService;

    @Autowired
    UserDetailsServiceImpl userDetailsService;

    public Transaction createTransaction(TransactionCreateDTO payload) throws Exception {
        validationService.validateTransactionCreateDTO(payload);
        Transaction transaction = new Transaction();
        setFields(payload, transaction);
        return transactionRepository.save(transaction);
    }

    private void setFields(TransactionCreateDTO payload, Transaction transaction) {
        transaction.setAmount(payload.getAmount());
        transaction.setDate(payload.getDate());
        transaction.setParty(payload.getParty());
        transaction.setTitle(payload.getTitle());
        Organization o = userDetailsService.getOrganizationForCurrentUser();
        transaction.setOrganization(o);
        transaction.setFileInfos(payload.getFiles());
        transaction.setTransactionType(payload.getTransactionType());
    }

    public Transaction updateTransaction(Long id, TransactionCreateDTO payload) throws Exception {
        // Fetch the existing transaction from the database
        Transaction existingTransaction = transactionRepository.findById(id)
                .orElseThrow(() -> new Exception("Transaction not found with id: " + id));

        // Update fields based on the payload
        if (payload.getDate() != null) {
            existingTransaction.setDate(payload.getDate());
        }
        if (payload.getTitle() != null) {
            existingTransaction.setTitle(payload.getTitle());
        }
        if (payload.getParty() != null) {
            existingTransaction.setParty(payload.getParty());
        }
        if (payload.getAmount() != null) {
            existingTransaction.setAmount(payload.getAmount());
        }
        if (payload.getFiles() != null) {
            existingTransaction.setFileInfos(payload.getFiles());
        }
        if (payload.getTransactionType() != null) {
            existingTransaction.setTransactionType(payload.getTransactionType());
        }
        return transactionRepository.save(existingTransaction);
    }

    public List<String> getParty() {
        return transactionRepository.findDistinctPartiesByOrganization(userDetailsService.getOrganizationForCurrentUser());
    }
}
