import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../models/transactionModel.dart';
import '../../../widgets/transactionWidgets.dart';

class DayWiseTab extends StatefulWidget {
  final TransactionResponse transactions;
  final Future<void> Function() onRefresh;
  const DayWiseTab({required this.transactions, required this.onRefresh, super.key});

  @override
  State<DayWiseTab> createState() => _DayWiseTabState();
}
enum TransactionTab { expenses, income }
class _DayWiseTabState extends State<DayWiseTab> {
  TransactionTab selectedTransactionTab = TransactionTab.expenses;
  @override
  Widget build(BuildContext context) {
    TransactionResponse transactions = widget.transactions;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Transaction History",
                  style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedTransactionTab = TransactionTab.expenses;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: selectedTransactionTab ==
                              TransactionTab.expenses
                              ? Constants.selectedTab
                              : Constants.expense10),
                      child: const Text(
                        "Expenses",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedTransactionTab = TransactionTab.income;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: selectedTransactionTab ==
                              TransactionTab.income
                              ? Constants.selectedTab
                              : Constants.income10),
                      child: const Text("Income"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (selectedTransactionTab == TransactionTab.income)
                  Column(
                    children: [
                      ...List.generate(
                          transactions.transactionsByType['INCOME']!.length,
                              (index) {
                            return GestureDetector(
                                onTap: () => TransactionWidgets(widget.onRefresh,context)
                                    .editTransactionSheet(transactions
                                    .transactionsByType['INCOME']![index]),
                                child: TransactionWidgets(widget.onRefresh,context)
                                    .transactionHistoryCard(transactions
                                    .transactionsByType['INCOME']![index]));
                          }),
                      if (transactions
                          .transactionsByType['INCOME']!.isEmpty)
                        const Center(
                          child: Text(
                            "No Transaction",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                if (selectedTransactionTab == TransactionTab.expenses)
                  Column(
                    children: [
                      ...List.generate(
                          transactions.transactionsByType['EXPENSE']!
                              .length, (index) {
                        return GestureDetector(
                            onTap: () => TransactionWidgets(widget.onRefresh,context)
                                .editTransactionSheet(transactions
                                .transactionsByType['EXPENSE']![index]),
                            child: TransactionWidgets(widget.onRefresh,context)
                                .transactionHistoryCard(
                                transactions.transactionsByType[
                                'EXPENSE']![index]));
                      }),
                      if (transactions
                          .transactionsByType['EXPENSE']!.isEmpty)
                        const Center(
                          child: Text(
                            "No Transaction",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}