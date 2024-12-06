import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../build_config.dart';
import '../constants.dart';
import '../utils/dateTimeFormatter.dart';
import '../handlers/http_request_handler.dart';
import '../models/transactionModel.dart';
import 'alertDialogs.dart';

class TransactionWidgets {
  BuildContext context;
  final Future<void> Function() onRefresh;
  TransactionWidgets( this.onRefresh,this.context);
  transactionHistoryCard(Transaction transaction) {
    return Card(
      child: Container(
        color: Constants.gray15,
        padding: const EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Constants.gray30,
                  child:
                      Text(transaction.transactionType == 'INCOME' ? 'I' : 'E'),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style:
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    Text(transaction.party),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  '₹${transaction.amount.toString()}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.green),
                ),
                Text(DateTimeFormatter()
                    .formatTime(transaction.modificationDate))
              ],
            ),
          ],
        ),
      ),
    );
  }
  addTransactionSheet(Transaction? transaction) {
    String transactionType = "income";
    TextEditingController titleController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    TextEditingController selectPartyController = TextEditingController();
    DateTime? selectedDate = DateTime.now();
    bool editMode = false;
    if (transaction != null) {
      titleController.text = transaction.title;
      amountController.text = transaction.amount.toString();
      selectedDate = DateTimeFormatter().parseDate(transaction.date);
      transactionType = transaction.transactionType.toLowerCase();
      editMode = true;
    }
    dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
    final List<String> partyList = BuildConfig.partyList;
    String? _fileName;
    File? _file;
    var fileMaps = [];
    Future<void> _pickFile(StateSetter setStateModal) async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
        // allowedExtensions: ['jpg', 'png', 'pdf', 'docx'],
      );
      if (result != null) {
        setStateModal(() {
          _file = File(result.files.single.path!); // Store the file
          _fileName = result.files.single.name; // Store the file name
        });
        var fileMap = await HttpRequestHandler(context).fileUpload(_file!);
        if (fileMap != null) {
          fileMaps.add(fileMap);
        }
      } else {
        setStateModal(() {
          _file = null; // Reset if no file is selected
          _fileName = null;
        });
      }
    }
    showModalBottomSheet<void>(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      editMode?"Update":'Add',
                      style:
                          const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Radio(
                              value: "income",
                              groupValue: transactionType,
                              onChanged: (value) {
                                setStateModal(() {
                                  transactionType =
                                      value!; // Update the selected value
                                });
                              },
                              activeColor: Colors.green,
                            ),
                            const Text('Income'),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Row(
                          children: [
                            Radio(
                              value: "expense",
                              groupValue: transactionType,
                              onChanged: (value) {
                                setStateModal(() {
                                  transactionType =
                                      value!; // Update the selected value
                                });
                              },
                              activeColor: Colors.green,
                            ),
                            const Text('Expense'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Title',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Title',
                        filled: true,
                        fillColor: Constants.gray10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Amount',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Amount',
                        filled: true,
                        fillColor: Constants.gray10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Date',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      readOnly: true,
                      controller: dateController,
                      decoration: InputDecoration(
                        hintText: 'Date',
                        filled: true,
                        fillColor: Constants.gray10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                      ),
                      onTap: () async {
                        selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        setStateModal(() {
                          dateController.text =
                              DateFormat('dd/MM/yyyy').format(selectedDate!);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Party',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    // TextField(
                    //   controller: selectPartyController,
                    //   decoration: InputDecoration(
                    //     hintText: 'Select...',
                    //     filled: true,
                    //     fillColor: Constants.gray10,
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //       borderSide: BorderSide.none,
                    //     ),
                    //     contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    //   ),
                    // ),
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return partyList;
                        }
                        return partyList.where((String option) {
                          return option
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (String selection) {
                        selectPartyController.text = selection;
                      },
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController fieldController,
                          FocusNode focusNode,
                          VoidCallback onFieldSubmitted) {
                        if(transaction!=null){
                          fieldController.text = transaction.party;
                        }
                        selectPartyController = fieldController;
                        return TextField(
                          controller: fieldController,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: 'Select...',
                            filled: true,
                            fillColor: Constants.gray10,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Upload Document',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DottedBorder(
                      color: Colors.grey,
                      strokeWidth: 1,
                      dashPattern: const [6, 3],
                      child: GestureDetector(
                        onTap: () {
                          _pickFile(setStateModal);
                        },
                        child: Container(
                          width: double.infinity,
                          height: 100,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_file,
                                    size: 40, color: Colors.grey),
                                Text(
                                  'Browse Files\nJPG, PNG, PDF, EXCEL',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Display file name and thumbnail if a file is selected
                    const SizedBox(height: 5),
                    if (_file != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (_fileName!.endsWith('.jpg') ||
                                  _fileName!.endsWith('.png'))
                                Image.file(
                                  _file!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              const SizedBox(width: 5),
                              Text(
                                _fileName!,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          GestureDetector(
                            child: const Icon(Icons.cancel_outlined),
                            onTap: () {
                              setStateModal(() {
                                _file = null;
                                _fileName = null;
                              });
                            },
                          )
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    if(!editMode)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Add',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          var body = {
                            "title": titleController.text,
                            "party": selectPartyController.text,
                            "amount": int.parse(amountController.text),
                            "transactionType": transactionType.toUpperCase(),
                            "date":
                                DateFormat('dd-MM-yyyy').format(selectedDate!),
                            "files": fileMaps
                          };
                          var respJson = await HttpRequestHandler(context)
                              .postTransaction(body);
                          if (respJson['status'] == 201) {
                            Navigator.pop(context);
                            onRefresh();
                          }
                        },
                      ),
                    ),
                    if(editMode)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Update',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            var body = {
                              "title": titleController.text,
                              "party": selectPartyController.text,
                              "amount": int.parse(amountController.text),
                              "transactionType": transactionType.toUpperCase(),
                              "date":
                              DateFormat('dd-MM-yyyy').format(selectedDate!),
                              "files": fileMaps
                            };
                            var respJson = await HttpRequestHandler(context)
                                .updateTransaction(body,transaction!.id.toString());
                            if (respJson['status'] == 200) {
                              Navigator.pop(context);
                              onRefresh();
                            }
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  editTransactionSheet(Transaction transaction) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  top: 16,
                  left: 16,
                  right: 16,
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        child: const Icon(Icons.cancel_outlined),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Transaction History',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                child: const Icon(Icons.create_outlined),
                                onTap: () {
                                  Navigator.pop(context);
                                  addTransactionSheet(transaction);
                                },
                              ),
                              GestureDetector(
                                  child: const Icon(Icons.delete_outline),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await AlertDialogs.showConfirmationDialog(context: context, transactionId: transaction.id.toString());
                                  onRefresh();
                                },
                              )
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      transactionHistoryCard(transaction),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ));
          },
        );
      },
    );
  }
}
