import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../handlers/http_request_handler.dart';
import '../models/folderModel.dart';

class DocumentationVault extends StatefulWidget {
  final String folderId;
  const DocumentationVault({required this.folderId, super.key});

  @override
  State<DocumentationVault> createState() => _DocumentationVaultState();
}

enum AppBarMenuItems { download, delete }

class _DocumentationVaultState extends State<DocumentationVault> {
  double width = 0;
  Folder folder = Folder.fromJson({});
  TextEditingController folderNameController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    folderGet();
    super.initState();
  }

  folderGet() async {
    Map<String, dynamic> respJson =
        await HttpRequestHandler(context).fileVaultGet(widget.folderId);
    if (respJson.isNotEmpty) {
      setState(() {
        folder = Folder.fromJson(respJson);
      });
    } else {
      print("Not Authorised");
    }
  }

  subFolderCard(SubFolder subFolder) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => DocumentationVault(
                      folderId: subFolder.id.toString(),
                    )));
      },
      child: Card(
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
                    // child:
                    // Text(transaction.transactionType == 'INCOME' ? 'I' : 'E'),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: width * 0.68,
                            child: Text(
                              subFolder.name,
                              softWrap: true,
                              maxLines: 2,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                          ),
                          PopupMenuButton<AppBarMenuItems>(
                            iconColor: Colors.black,
                            position: PopupMenuPosition.under,
                            onSelected: (AppBarMenuItems item) {
                              setState(() {
                                if (item == AppBarMenuItems.delete) {
                                  folderDeleteDialog(
                                      context: context,
                                      fileId: subFolder.id.toString());
                                }
                              });
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<AppBarMenuItems>>[
                              // const PopupMenuItem<AppBarMenuItems>(
                              //   value: AppBarMenuItems.download,
                              //   child: Text('Download'),
                              // ),
                              const PopupMenuItem<AppBarMenuItems>(
                                value: AppBarMenuItems.delete,
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        width: width * 0.8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(subFolder.itemCount.toString()),
                            Text(subFolder.lastUpdateDate.toString()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  fileCard(FileData file) {
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
                  // child:
                  // Text(transaction.transactionType == 'INCOME' ? 'I' : 'E'),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: width * 0.80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            file.filename.toString(),
                            softWrap: true,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          PopupMenuButton<AppBarMenuItems>(
                            iconColor: Colors.black,
                            position: PopupMenuPosition.under,
                            onSelected: (AppBarMenuItems item) {
                              setState(() {
                                if (item == AppBarMenuItems.delete) {
                                  fileDeleteDialog(
                                      context: context,
                                      fileId: file.id.toString());
                                }
                              });
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<AppBarMenuItems>>[
                              // const PopupMenuItem<AppBarMenuItems>(
                              //   value: AppBarMenuItems.download,
                              //   child: Text('Download'),
                              // ),
                              const PopupMenuItem<AppBarMenuItems>(
                                value: AppBarMenuItems.delete,
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: width * 0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(file.lastUpdateDate.toString()),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _fileName;
  File? _file;
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
    } else {
      setStateModal(() {
        _file = null; // Reset if no file is selected
        _fileName = null;
      });
    }
  }

  addFolderSheet() {
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
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add Folder',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            ' Folder Name',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      TextField(
                        controller: folderNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter Folder Name',
                          filled: true,
                          fillColor: Constants.gray10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
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
                            'Add Folder',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            var body = {
                              "name": folderNameController.text,
                              "parentId": folder.id
                            };
                            var respJson = await HttpRequestHandler(context)
                                .addFolder(body);
                            print("file resp: $respJson");
                            if (respJson['status'] == 200) {
                              Navigator.pop(context);
                              folderGet();
                            }
                          },
                        ),
                      ),
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

  addFileSheet() {
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
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add file',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      DottedBorder(
                        color: Colors.grey,
                        strokeWidth: 1,
                        dashPattern: [6, 3],
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
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
                      const SizedBox(
                        height: 10,
                      ),
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
                            'Add File',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            await HttpRequestHandler(context)
                                .vaultFileUpload(_file!, folder.id.toString());
                            Navigator.pop(context);
                            folderGet();
                          },
                        ),
                      ),
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

  void _handleMenuSelection(String value) {
    if (value == 'addFolder') {
      addFolderSheet();
    } else if (value == 'addFile') {
      addFileSheet();
    }
  }

  Future<void> fileDeleteDialog(
      {required BuildContext context, required String fileId}) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 60,
                color: Colors.orange,
              ),
              const SizedBox(height: 10),
              const Text(
                "Are you sure?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Do you really want to delete this item? This action cannot be undone!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      bool deleted =
                          await HttpRequestHandler(context).deleteFiles(fileId);
                      if (deleted) {
                        Navigator.of(context).pop();
                        folderGet();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3085D6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Yes, delete it!",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.red,
                      // side: BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> folderDeleteDialog(
      {required BuildContext context, required String fileId}) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 60,
                color: Colors.orange,
              ),
              const SizedBox(height: 10),
              const Text(
                "Are you sure?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Do you really want to delete this item? This action cannot be undone!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      bool deleted = await HttpRequestHandler(context)
                          .deleteFolder(fileId);
                      if (deleted) {
                        Navigator.of(context).pop();
                        folderGet();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3085D6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Yes, delete it!",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.red,
                      // side: BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Documentation Vault"),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () async {
            if (folder.breadcrumb.length > 1) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DocumentationVault(
                            folderId: folder
                                .breadcrumb[folder.breadcrumb.length - 2].id
                                .toString(),
                          )));
            } else {
              Navigator.pop(context); // Go back to the previous screen
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: width,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    GestureDetector(
                      child: const Text(
                        'Home',
                        style: TextStyle(color: Colors.blue),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DocumentationVault(
                                      folderId:
                                          folder.breadcrumb[0].id.toString(),
                                    )));
                      },
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    if (folder.breadcrumb.isNotEmpty)
                      ...List.generate(folder.breadcrumb.length - 1, (index) {
                        return GestureDetector(
                          child: Text(
                            "/ ${folder.breadcrumb[index + 1].name}",
                            style: const TextStyle(color: Colors.blue),
                          ),
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DocumentationVault(
                                          folderId: folder
                                              .breadcrumb[index + 1].id
                                              .toString(),
                                        )));
                          },
                        );
                      })
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Column(
                children: [
                  ...List.generate(folder.subFolders.length, (index) {
                    return subFolderCard(folder.subFolders[index]);
                  }),
                  ...List.generate(folder.files.length, (index) {
                    return fileCard(folder.files[index]);
                  }),
                ],
              )
            ],
          ),
        ),
      ),
      floatingActionButton: Visibility(
        child: FloatingActionButton(
          onPressed: () {
            final RenderBox button = context.findRenderObject() as RenderBox;
            final RenderBox overlay =
                Overlay.of(context).context.findRenderObject() as RenderBox;
            final RelativeRect position = RelativeRect.fromRect(
              Rect.fromPoints(
                button.localToGlobal(button.size.bottomRight(Offset.zero),
                    ancestor: overlay),
                button.localToGlobal(button.size.bottomRight(Offset.zero),
                    ancestor: overlay),
              ),
              Offset.zero & overlay.size,
            );
            showMenu(
              context: context,
              position: position,
              items: <PopupMenuEntry>[
                const PopupMenuItem(
                  value: 'addFolder',
                  child: Text('Add Folder'),
                ),
                const PopupMenuItem(
                  value: 'addFile',
                  child: Text('Add File'),
                ),
              ],
            ).then((value) {
              if (value != null) {
                _handleMenuSelection(value);
              }
            });
          },
          backgroundColor: Colors.green,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
