package com.gb.et.service;

import com.gb.et.data.TransactionSummary;
import com.gb.et.models.Organization;
import com.gb.et.models.Transaction;
import com.gb.et.models.TransactionType;
import com.gb.et.repository.TransactionRepository;
import com.gb.et.repository.UserRepository;
import com.gb.et.security.services.UserDetailsServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

@Service
public class DashboardService {

    @Autowired
    private TransactionRepository transactionRepository;

    @Autowired
    private UserRepository userRepository;  // Assuming you have a repository to fetch user details

    @Autowired
    UserDetailsServiceImpl userDetailsService;

    public TransactionSummary getTransactionSummary(String dateOrMonth) throws ParseException {
        SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat monthFormatter = new SimpleDateFormat("yyyy-MM");
        TransactionSummary summary;
        Organization userOrganization = userDetailsService.getOrganizationForCurrentUser();

        if (dateOrMonth.length() > 7) {
            Date date = dateFormatter.parse(dateOrMonth);
            summary = getSummary(date, true, userOrganization);
        } else {
            Date month = monthFormatter.parse(dateOrMonth + "-01");
            summary = getSummary(month, false, userOrganization);
        }
        return summary;
    }

    private TransactionSummary getSummary(Date date, boolean isDaily, Organization organization) {
        Map<TransactionType, List<Transaction>> transactionsByType = new EnumMap<>(TransactionType.class);
        double carryForward = 0.0, totalIncome = 0.0, totalExpense = 0.0;

        for (TransactionType type : TransactionType.values()) {
            List<Transaction> transactions = isDaily ?
                    transactionRepository.findByDateAndTransactionTypeAndOrganization(date, type, organization) :
                    transactionRepository.findByMonthAndTransactionTypeAndOrganization(date, type, organization);

            transactionsByType.put(type, transactions);

            for (Transaction t : transactions) {
                if (type == TransactionType.INCOME) totalIncome += t.getAmount();
                if (type == TransactionType.EXPENSE) totalExpense += t.getAmount();
            }
        }

        carryForward += transactionRepository.sumAmountByTypeBeforeDateAndOrganization(date, TransactionType.INCOME, organization) - transactionRepository.sumAmountByTypeBeforeDateAndOrganization(date, TransactionType.EXPENSE, organization);
        double balance = carryForward + totalIncome - totalExpense;

        return new TransactionSummary(transactionsByType, carryForward, totalIncome, totalExpense, balance);
    }
}

