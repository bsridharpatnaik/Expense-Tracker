class GroupedSummary {
  int carryForward;
  int totalIncome;
  int totalExpense;
  int balance;
  List<DailySummary> dailySummaries;

  GroupedSummary({
    required this.carryForward,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.dailySummaries,
  });

  factory GroupedSummary.fromJson(Map<String, dynamic> json) {
    return GroupedSummary(
      carryForward: (json['carryForward'] ?? 0.0).toInt(),
      totalIncome: (json['totalIncome'] ?? 0.0).toInt(),
      totalExpense: (json['totalExpense'] ?? 0.0).toInt(),
      balance: (json['balance'] ?? 0.0).toInt(),
      dailySummaries: (json['dailySummaries'] as List?)
          ?.map((e) => DailySummary.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carryForward': carryForward,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': balance,
      'dailySummaries': dailySummaries.map((e) => e.toJson()).toList(),
    };
  }
}

class DailySummary {
  String date;
  int carryForward;
  int totalIncome;
  int totalExpense;
  List<Transaction> incomeTransactions;
  List<Transaction> expenseTransactions;
  int balance;

  DailySummary({
    required this.date,
    required this.carryForward,
    required this.totalIncome,
    required this.totalExpense,
    required this.incomeTransactions,
    required this.expenseTransactions,
    required this.balance,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      date: json['date'] ?? '',
      carryForward: (json['carryForward'] ?? 0).toInt(),
      totalIncome: (json['totalIncome'] ?? 0).toInt(),
      totalExpense: (json['totalExpense'] ?? 0).toInt(),
      incomeTransactions: (json['incomeTransactions'] as List?)
          ?.map((e) => Transaction.fromJson(e))
          .toList() ??
          [],
      expenseTransactions: (json['expenseTransactions'] as List?)
          ?.map((e) => Transaction.fromJson(e))
          .toList() ??
          [],
      balance: (json['balance'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'carryForward': carryForward,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'incomeTransactions':
      incomeTransactions.map((e) => e.toJson()).toList(),
      'expenseTransactions':
      expenseTransactions.map((e) => e.toJson()).toList(),
      'balance': balance,
    };
  }
}

class Transaction {
  int id;
  String date;
  String creationDate;
  String modificationDate;
  String title;
  String party;
  int amount;
  String transactionType;
  String? description;
  List<FileInfo> fileInfos;

  Transaction({
    required this.id,
    required this.date,
    required this.creationDate,
    required this.modificationDate,
    required this.title,
    required this.party,
    required this.amount,
    required this.transactionType,
    this.description,
    required this.fileInfos,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      creationDate: json['creationDate'] ?? '',
      modificationDate: json['modificationDate'] ?? '',
      title: json['title'] ?? '',
      party: json['party'] ?? '',
      amount: (json['amount'] ?? 0).toInt(),
      transactionType: json['transactionType'] ?? '',
      description: json['description'],
      fileInfos: (json['fileInfos'] as List?)
          ?.map((e) => FileInfo.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'creationDate': creationDate,
      'modificationDate': modificationDate,
      'title': title,
      'party': party,
      'amount': amount,
      'transactionType': transactionType,
      'description': description,
      'fileInfos': fileInfos.map((e) => e.toJson()).toList(),
    };
  }
}

class FileInfo {
  String fileUuid;
  String filename;
  String uploadDate;

  FileInfo({
    required this.fileUuid,
    required this.filename,
    required this.uploadDate,
  });

  factory FileInfo.fromJson(Map<String, dynamic> json) {
    return FileInfo(
      fileUuid: json['fileUuid'] ?? '',
      filename: json['filename'] ?? '',
      uploadDate: json['uploadDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileUuid': fileUuid,
      'filename': filename,
      'uploadDate': uploadDate,
    };
  }
}