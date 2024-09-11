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
        Sort sort = Sort.by(Sort.Direction.DESC, "creationDate");
        Map<TransactionType, List<Transaction>> transactionsByType = new EnumMap<>(TransactionType.class);
        double carryForward = 0.0, totalIncome = 0.0, totalExpense = 0.0;

        for (TransactionType type : TransactionType.values()) {
            List<Transaction> transactions = isDaily ?
                    transactionRepository.findByDateAndTransactionTypeAndOrganization(date, type, organization, sort) :
                    transactionRepository.findByMonthAndTransactionTypeAndOrganization(date, type, organization, sort);

            transactionsByType.put(type, transactions);

            for (Transaction t : transactions) {
                if (type == TransactionType.INCOME) totalIncome += t.getAmount();
                if (type == TransactionType.EXPENSE) totalExpense += t.getAmount();
            }
        }
        carryForward += transactionRepository.sumAmountByTypeBeforeDateAndOrganization(date, TransactionType.INCOME, organization) - transactionRepository.sumAmountByTypeBeforeDateAndOrganization(date, TransactionType.EXPENSE, organization);
        double balance = carryForward + totalIncome - totalExpense;
        String userName = userDetailsService.getCurrentUser();
        return new TransactionSummary(transactionsByType, carryForward, totalIncome, totalExpense, balance, userName);
    }

    public MonthTransactionSummary getTransactionsGroupedByDateRange(String startDateStr, String endDateStr) throws ParseException {
        SimpleDateFormat fullDateFormatter = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat monthFormatter = new SimpleDateFormat("yyyy-MM");
        fullDateFormatter.setTimeZone(TimeZone.getTimeZone("Asia/Kolkata"));
        monthFormatter.setTimeZone(TimeZone.getTimeZone("Asia/Kolkata"));

        Organization userOrganization = userDetailsService.getOrganizationForCurrentUser();

        Date startDate = null;
        Date endDate = null;
        boolean isMonthQuery = false;

        // Parse startDate and endDate based on the inputs
        if (startDateStr.length() > 7) {
            // Single day query or start date in full date format
            startDate = fullDateFormatter.parse(startDateStr);
            if (endDateStr == null) {
                // If endDate is null, assume we are querying only one day
                endDate = startDate;
            } else {
                endDate = fullDateFormatter.parse(endDateStr);
            }
        } else {
            // Month query (e.g., "2024-08")
            startDate = monthFormatter.parse(startDateStr + "-01");
            if (endDateStr == null) {
                // Set endDate to the last day of the month
                Calendar cal = Calendar.getInstance();
                cal.setTime(startDate);
                cal.set(Calendar.DAY_OF_MONTH, cal.getActualMaximum(Calendar.DAY_OF_MONTH));
                endDate = cal.getTime();
            } else {
                // For custom range, parse endDate
                endDate = fullDateFormatter.parse(endDateStr);
            }
            isMonthQuery = true;
        }

        // Initialize aggregation variables
        double carryForward = calculateCarryForward(startDate, userOrganization);
        double balance = carryForward;
        double totalIncome = 0.0;
        double totalExpense = 0.0;

        // Fetch all transactions in the given date range
        List<Transaction> transactions = transactionRepository.findByDateRangeAndOrganization(startDate, endDate, userOrganization);

        // Group transactions by date
        Map<Date, List<Transaction>> transactionsByDate = transactions.stream()
                .collect(Collectors.groupingBy(Transaction::getDate, TreeMap::new, Collectors.toList()));

        // Initialize the carryForward for daily calculations
        double currentCarryForward = carryForward;
        List<DateTransactionSummary> dailySummaries = new ArrayList<>();
        Date firstDay = null;
        Date lastDay = null;

        // Iterate over each day in the range
        for (Map.Entry<Date, List<Transaction>> entry : transactionsByDate.entrySet()) {
            Date date = entry.getKey();
            List<Transaction> dailyTransactions = entry.getValue();

            if (firstDay == null) firstDay = date;
            lastDay = date;

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

            // Update carryForward for the next day (balance of the current day)
            currentCarryForward = dailyBalance;
        }

        // Aggregation outside of daily summaries
        if (!dailySummaries.isEmpty()) {
            // Carryforward is the carryforward from the first day of the period
            carryForward = dailySummaries.get(0).getCarryForward();
            // Balance is the balance of the last day
            balance = dailySummaries.get(dailySummaries.size() - 1).getBalance();
            // Total income and expense are sums across all days
            totalIncome = dailySummaries.stream().mapToDouble(DateTransactionSummary::getTotalIncome).sum();
            totalExpense = dailySummaries.stream().mapToDouble(DateTransactionSummary::getTotalExpense).sum();
        }

        // Return the overall month summary or date range summary with daily details
        return new MonthTransactionSummary(
                carryForward,
                totalIncome,
                totalExpense,
                balance,
                dailySummaries
        );
    }

    private double calculateCarryForward(Date startDate, Organization organization) {
        // Logic to calculate carryForward from transactions before the given date
        double totalIncomeBefore = transactionRepository.sumAmountByTypeBeforeDateAndOrganization(startDate, TransactionType.INCOME, organization);
        double totalExpenseBefore = transactionRepository.sumAmountByTypeBeforeDateAndOrganization(startDate, TransactionType.EXPENSE, organization);
        return totalIncomeBefore - totalExpenseBefore;
    }
}

