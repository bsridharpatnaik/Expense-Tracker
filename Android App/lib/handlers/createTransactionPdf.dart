import 'dart:io';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/transactionModel.dart';
import 'package:permission_handler/permission_handler.dart';

import 'notification_handler.dart';


Future<void> requestManageExternalStoragePermission() async {
  if (await Permission.manageExternalStorage.request().isGranted) {
    print('Storage permission granted');
  } else {
    print('Storage permission denied, opening app settings...');
    // Guide the user to open app settings to manually enable the permission
    await openAppSettings();
  }
}

Future<void> requestStoragePermission() async {
  final permissionStatus = await Permission.storage.status;
  if (permissionStatus.isDenied) {
    await Permission.storage.request();
  } else if (permissionStatus.isPermanentlyDenied) {
    await openAppSettings();
  } else {
  }
}

Future<void> createTransactionPdf(TransactionResponse transactions) async {
  // Create a new PDF document.
  final PdfDocument document = PdfDocument();

  // Add a new page to the document.
  final PdfPage page = document.pages.add();
  final PdfGraphics graphics = page.graphics;
  final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);

  // Add the title.
  graphics.drawString(
    'Transaction Summary',
    font,
    brush: PdfBrushes.black,
    bounds: const Rect.fromLTWH(0, 0, 500, 30),
  );

  // Add the summary section.
  final String summary = '''
    Balance: ${transactions.balance}
    Carry Forward: ${transactions.carryForward}
    Total Expense: ${transactions.totalExpense}
    Total Income: ${transactions.totalIncome}
    ''';

  graphics.drawString(
    summary,
    font,
    brush: PdfBrushes.black,
    bounds: const Rect.fromLTWH(0, 40, 500, 100),
  );

  // Create grids for Expenses and Income tables.
  final PdfGrid expenseGrid = PdfGrid();
  final PdfGrid incomeGrid = PdfGrid();

  // Add columns for the grid.
  expenseGrid.columns.add(count: 4);
  incomeGrid.columns.add(count: 4);

  // Add headers for Expenses table.
  final PdfGridRow expenseHeader = expenseGrid.headers.add(1)[0];
  expenseHeader.cells[0].value = 'Date';
  expenseHeader.cells[1].value = 'Title';
  expenseHeader.cells[2].value = 'Party';
  expenseHeader.cells[3].value = 'Amount';
  expenseHeader.style.font =
      PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);

  // Populate rows for expenses.
  for (final expense in transactions.transactionsByType['EXPENSE'] ?? []) {
    final PdfGridRow row = expenseGrid.rows.add();
    row.cells[0].value = expense.date;
    row.cells[1].value = expense.title;
    row.cells[2].value = expense.party;
    row.cells[3].value = expense.amount.toString();
  }

  // Add headers for Income table.
  final PdfGridRow incomeHeader = incomeGrid.headers.add(1)[0];
  incomeHeader.cells[0].value = 'Date';
  incomeHeader.cells[1].value = 'Title';
  incomeHeader.cells[2].value = 'Party';
  incomeHeader.cells[3].value = 'Amount';
  incomeHeader.style.font =
      PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);

  // Populate rows for income.
  for (final income in transactions.transactionsByType['INCOME'] ?? []) {
    final PdfGridRow row = incomeGrid.rows.add();
    row.cells[0].value = income.date;
    row.cells[1].value = income.title;
    row.cells[2].value = income.party;
    row.cells[3].value = income.amount.toString();
  }

  // Set padding and alignment for the grid cells.
  expenseGrid.style.cellPadding = PdfPaddings(left: 5, right: 5, top: 2, bottom: 2);
  incomeGrid.style.cellPadding = PdfPaddings(left: 5, right: 5, top: 2, bottom: 2);

  // Add "Expenses" title above the Expenses table.
  graphics.drawString(
    'Expenses',
    PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
    brush: PdfBrushes.black,
    bounds: const Rect.fromLTWH(0, 150, 500, 20),
  );

  // Draw the Expenses table below the "Expenses" title.
  expenseGrid.draw(
    page: page,
    bounds: const Rect.fromLTWH(0, 170, 500, 400),
  );

  // Add a new page for Income table.
  final PdfPage incomePage = document.pages.add();

  // Add "Income" title above the Income table.
  incomePage.graphics.drawString(
    'Income',
    PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
    brush: PdfBrushes.black,
    bounds: const Rect.fromLTWH(0, 0, 500, 20),
  );

  // Draw the Income table below the "Income" title.
  incomeGrid.draw(
    page: incomePage,
    bounds: const Rect.fromLTWH(0, 20, 500, 400),
  );

  // Save the document.
  final List<int> bytes = document.saveSync();
  document.dispose();
  // Save the file to the Downloads directory.
  final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  final Directory downloadsDirectory = Directory('/storage/emulated/0/Download');
  final String path = '${downloadsDirectory.path}/TransactionReport_$timestamp.pdf';
  // Write the file.
  final File file = File(path);
  await file.writeAsBytes(bytes);
  NotificationHandler.showDefault("PDF successfully downloaded in download folder.");
}
