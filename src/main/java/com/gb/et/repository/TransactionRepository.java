package com.gb.et.repository;

import com.gb.et.models.Organization;
import com.gb.et.models.Transaction;
import com.gb.et.models.TransactionType;
import com.gb.et.models.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Date;
import java.util.List;
import java.util.Optional;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {

    List<Transaction> findByDateAndTransactionTypeAndOrganization(Date date, TransactionType type, Organization organization);

    @Query("SELECT SUM(t.amount) FROM Transaction t WHERE t.date < :date AND t.transactionType = :type AND t.organization = :organization")
    Double sumAmountByTypeBeforeDateAndOrganization(@Param("date") Date date, @Param("type") TransactionType type, @Param("organization") Organization organization);

    @Query("SELECT t FROM Transaction t WHERE FUNCTION('MONTH', t.date) = FUNCTION('MONTH', :date) AND FUNCTION('YEAR', t.date) = FUNCTION('YEAR', :date) AND t.transactionType = :type AND t.organization = :organization")
    List<Transaction> findByMonthAndTransactionTypeAndOrganization(@Param("date") Date date, @Param("type") TransactionType type, @Param("organization") Organization organization);
}

