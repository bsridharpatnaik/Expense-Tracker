package com.gb.et.data;

import java.util.List;
import java.util.Map;

import com.gb.et.models.Transaction;
import com.gb.et.models.TransactionType;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class TransactionSummary {
    private Map<TransactionType, List<Transaction>> transactionsByType;
    private Double carryForward;
    private Double totalIncome;
    private Double totalExpense;
    private Double balance;

    // Constructors, Getters, and Setters
    public TransactionSummary(Map<TransactionType, List<Transaction>> transactionsByType, Double carryForward, Double totalIncome, Double totalExpense, Double balance) {
        this.transactionsByType = transactionsByType;
        this.carryForward = carryForward;
        this.totalIncome = totalIncome;
        this.totalExpense = totalExpense;
        this.balance = balance;
    }
}
