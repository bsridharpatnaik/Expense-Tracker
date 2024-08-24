package com.gb.et.service;

import com.gb.et.data.TransactionCreateDTO;
import org.springframework.stereotype.Service;

@Service
public class TransactionValidationService {

    public void validateTransactionCreateDTO(TransactionCreateDTO dto) {
        if (dto == null) {
            throw new IllegalArgumentException("TransactionCreateDTO must not be null");
        }

        if (dto.getDate() == null) {
            throw new IllegalArgumentException("Date must not be null");
        }

        if (dto.getTitle() == null || dto.getTitle().isEmpty()) {
            throw new IllegalArgumentException("Title must not be null or empty");
        }

        if (dto.getParty() == null || dto.getParty().isEmpty()) {
            throw new IllegalArgumentException("Party must not be null or empty");
        }

        if (dto.getAmount() == null) {
            throw new IllegalArgumentException("Amount must not be null");
        }
    }
}
