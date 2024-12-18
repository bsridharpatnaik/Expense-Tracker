package com.gb.et.service;

import com.gb.et.data.DateTransactionSummary;
import com.gb.et.data.MonthTransactionSummary;
import com.gb.et.data.TransactionSummary;
import com.gb.et.models.Organization;
import com.gb.et.models.Transaction;
import com.gb.et.models.TransactionType;
import com.gb.et.repository.TransactionRepository;
import com.gb.et.repository.UserRepository;
import com.gb.et.security.services.UserDetailsServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class DashboardService {

    @Autowired
    private TransactionRepository transactionRepository;

    @Autowired
    private UserDetailsServiceImpl userDetailsService;

    // Modified getTransactionSummary to filter by party
    public TransactionSummary getTransactionSummary(String dateOrMonth, String party) throws ParseException {
        SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat monthFormatter = new SimpleDateFormat("yyyy-MM");
        TransactionSummary summary;
        Organization userOrganization = userDetailsService.getOrganizationForCurrentUser();

        if (dateOrMonth.length() > 7) {
            // Daily summary
            Date date = dateFormatter.parse(dateOrMonth);
            summary = getSummary(date, true, userOrganization, party);
        } else {
            // Monthly summary
            Date month = monthFormatter.parse(dateOrMonth + "-01");
            summary = getSummary(month, false, userOrganization, party);
        }
        return summary;
    }

    // Modified getSummary to filter by party
    private TransactionSummary getSummary(Date date, boolean isDaily, Organization organization, String party) {
        Sort sort = Sort.by(Sort.Direction.DESC, "creationDate");
        Map<TransactionType, List<Transaction>> transactionsByType = new EnumMap<>(TransactionType.class);
        double carryForward = calculateCarryForward(date, organization, party);
        double totalIncome = 0.0, totalExpense = 0.0;

        for (TransactionType type : TransactionType.values()) {
            List<Transaction> transactions = isDaily ?
                    transactionRepository.findByDateAndTransactionTypeAndOrganizationAndParty(date, type, organization, party, sort) :
                    transactionRepository.findByMonthAndTransactionTypeAndOrganizationAndParty(date, type, organization, party, sort);

            transactionsByType.put(type, transactions);

            // Calculate total income/expense
            for (Transaction t : transactions) {
                if (type == TransactionType.INCOME) {
                    totalIncome += t.getAmount();
                } else if (type == TransactionType.EXPENSE) {
                    totalExpense += t.getAmount();
                }
            }
        }

        double balance = carryForward + totalIncome - totalExpense;
        String userName = userDetailsService.getCurrentUser();

        return new TransactionSummary(transactionsByType, carryForward, totalIncome, totalExpense, balance, userName);
    }

    // Modified getTransactionsGroupedByDateRange to filter by party
    public MonthTransactionSummary getTransactionsGroupedByDateRange(String startDateStr, String endDateStr, String party) throws ParseException {
        SimpleDateFormat fullDateFormatter = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat monthFormatter = new SimpleDateFormat("yyyy-MM");
        fullDateFormatter.setTimeZone(TimeZone.getTimeZone("Asia/Kolkata"));
        monthFormatter.setTimeZone(TimeZone.getTimeZone("Asia/Kolkata"));

        Organization userOrganization = userDetailsService.getOrganizationForCurrentUser();
        Date startDate, endDate;

        if (startDateStr.length() > 7) {
            // Single day or date range
            startDate = fullDateFormatter.parse(startDateStr);
            endDate = (endDateStr != null) ? fullDateFormatter.parse(endDateStr) : startDate;
        } else {
            // Month range
            startDate = monthFormatter.parse(startDateStr + "-01");
            Calendar cal = Calendar.getInstance();
            cal.setTime(startDate);
            cal.set(Calendar.DAY_OF_MONTH, cal.getActualMaximum(Calendar.DAY_OF_MONTH));
            endDate = (endDateStr != null) ? fullDateFormatter.parse(endDateStr) : cal.getTime();
        }

        // Calculate carryForward before the start date
        double carryForward = calculateCarryForward(startDate, userOrganization, party);
        double balance = carryForward;
        double totalIncome = 0.0;
        double totalExpense = 0.0;

        // Fetch all transactions in the given date range
        List<Transaction> transactions = transactionRepository.findByDateRangeAndOrganizationAndParty(startDate, endDate, userOrganization, party);

        // Group transactions by date
        Map<Date, List<Transaction>> transactionsByDate = transactions.stream()
                .collect(Collectors.groupingBy(Transaction::getDate, TreeMap::new, Collectors.toList()));

        // Initialize carryForward for daily calculations
        double currentCarryForward = carryForward;
        List<DateTransactionSummary> dailySummaries = new ArrayList<>();

        // Iterate over each day in the range
        for (Map.Entry<Date, List<Transaction>> entry : transactionsByDate.entrySet()) {
            Date date = entry.getKey();
            List<Transaction> dailyTransactions = entry.getValue();

            // Calculate daily income and expense
            double dailyIncome = 0.0;
            double dailyExpense = 0.0;
            List<Transaction> incomeTransactions = new ArrayList<>();
            List<Transaction> expenseTransactions = new ArrayList<>();

            for (Transaction t : dailyTransactions) {
                if (t.getTransactionType() == TransactionType.INCOME) {
                    dailyIncome += t.getAmount();
                    incomeTransactions.add(t);
                } else if (t.getTransactionType() == TransactionType.EXPENSE) {
                    dailyExpense += t.getAmount();
                    expenseTransactions.add(t);
                }
            }

            // Sort transactions by creationDate descending
            incomeTransactions.sort(Comparator.comparing(Transaction::getCreationDate).reversed());
            expenseTransactions.sort(Comparator.comparing(Transaction::getCreationDate).reversed());

            // Calculate the balance for the current day
            double dailyBalance = currentCarryForward + dailyIncome - dailyExpense;

            // Create summary for the current date
            DateTransactionSummary dailySummary = new DateTransactionSummary(
                    date,
                    currentCarryForward,  // Carryforward for today (balance of the previous day)
                    dailyIncome,
                    dailyExpense,
                    incomeTransactions,
                    expenseTransactions,
                    dailyBalance
            );

            dailySummaries.add(dailySummary);
            currentCarryForward = dailyBalance;
        }

        // Sort dailySummaries by date in descending order
        dailySummaries.sort(Comparator.comparing(DateTransactionSummary::getDate).reversed());

        // Aggregation outside of daily summaries
        if (!dailySummaries.isEmpty()) {
            carryForward = dailySummaries.get(0).getCarryForward();
            balance = dailySummaries.get(dailySummaries.size() - 1).getBalance();
            totalIncome = dailySummaries.stream().mapToDouble(DateTransactionSummary::getTotalIncome).sum();
            totalExpense = dailySummaries.stream().mapToDouble(DateTransactionSummary::getTotalExpense).sum();
        }

        return new MonthTransactionSummary(carryForward, totalIncome, totalExpense, balance, dailySummaries);
    }

    // Modified calculateCarryForward to consider party
    private double calculateCarryForward(Date startDate, Organization organization, String party) {
        List<Object[]> totals = transactionRepository.sumAmountByTypeBeforeDateAndOrganizationAndParty(startDate, organization, party);
        double totalIncome = 0.0;
        double totalExpense = 0.0;

        for (Object[] total : totals) {
            TransactionType type = (TransactionType) total[0];
            double sum = (double) total[1];
            if (type == TransactionType.INCOME) {
                totalIncome += sum;
            } else if (type == TransactionType.EXPENSE) {
                totalExpense += sum;
            }
        }

        return totalIncome - totalExpense;
    }
}

