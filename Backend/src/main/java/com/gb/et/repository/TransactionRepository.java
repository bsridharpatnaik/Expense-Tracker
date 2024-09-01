package com.gb.et.repository;

import com.gb.et.models.Organization;
import com.gb.et.models.Transaction;
import com.gb.et.models.TransactionType;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Date;
import java.util.List;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {

    @Query("SELECT t FROM Transaction t WHERE FUNCTION('DATE', t.date) = FUNCTION('DATE', :date) AND t.transactionType = :type AND t.organization = :organization")
    List<Transaction> findByDateAndTransactionTypeAndOrganization(@Param("date") Date date, @Param("type") TransactionType type, @Param("organization") Organization organization, Sort sort);

    @Query("SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t WHERE FUNCTION('DATE', t.date) < FUNCTION('DATE', :date) AND t.transactionType = :type AND t.organization = :organization")
    Double sumAmountByTypeBeforeDateAndOrganization(@Param("date") Date date, @Param("type") TransactionType type, @Param("organization") Organization organization);

    @Query("SELECT DISTINCT t.party FROM Transaction t WHERE t.organization = :organization")
    List<String> findDistinctPartiesByOrganization(Organization organization);

    @Query("SELECT t FROM Transaction t WHERE FUNCTION('MONTH', t.date) = FUNCTION('MONTH', :date) AND FUNCTION('YEAR', t.date) = FUNCTION('YEAR', :date) AND t.transactionType = :type AND t.organization = :organization")
    List<Transaction> findByMonthAndTransactionTypeAndOrganization(@Param("date") Date date, @Param("type") TransactionType type, @Param("organization") Organization organization, Sort sort);
}


