class Transaction {
  final int id;
  final String date;
  final String creationDate;
  final String modificationDate;
  final String title;
  final String party;
  final int amount;
  final String transactionType;
  final String? description;
  final List<FileInfo> fileInfos;

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
    var fileInfosFromJson = json['fileInfos'] as List;
    List<FileInfo> fileInfosList = fileInfosFromJson.map((i) => FileInfo.fromJson(i)).toList();

    return Transaction(
      id: json['id'],
      date: json['date'],
      creationDate: json['creationDate'],
      modificationDate: json['modificationDate'],
      title: json['title'],
      party: json['party'],
      amount: json['amount'],
      transactionType: json['transactionType'],
      description: json['description'],
      fileInfos: fileInfosList,
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
      'fileInfos': fileInfos.map((i) => i.toJson()).toList(),
    };
  }
}

class FileInfo {
  // Define properties for FileInfo here if necessary
  // For now, we assume it's an empty object in the JSON
  FileInfo();

  factory FileInfo.fromJson(Map<String, dynamic> json) {
    return FileInfo();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}

class TransactionResponse {
  final Map<String, List<Transaction>> transactionsByType;
  final int carryForward;
  final int totalIncome;
  final int totalExpense;
  final int balance;
  final String username;

  TransactionResponse({
    required this.transactionsByType,
    required this.carryForward,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.username,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    var transactionsByTypeFromJson = json['transactionsByType']??{
      "EXPENSE": [],
      "INCOME": []
    } as Map<String, dynamic>;
    Map<String, List<Transaction>> transactionsByType = {};

    transactionsByTypeFromJson.forEach((key, value) {
      var list = value as List;
      transactionsByType[key] = list.map((item) => Transaction.fromJson(item)).toList();
    });

    return TransactionResponse(
      transactionsByType: transactionsByType,
      carryForward: json['carryForward']??0,
      totalIncome: json['totalIncome']??0,
      totalExpense: json['totalExpense']??0,
      balance: json['balance']??0,
      username: json['username']??'',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionsByType': transactionsByType.map((key, value) {
        return MapEntry(key, value.map((e) => e.toJson()).toList());
      }),
      'carryForward': carryForward,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': balance,
      'username': username,
    };
  }
}

