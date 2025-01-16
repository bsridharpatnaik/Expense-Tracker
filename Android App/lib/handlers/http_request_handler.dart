import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../build_config.dart';
import '../screens/login.dart';
import 'package:http/http.dart' as http;
import 'notification_handler.dart';

class HttpRequestHandler {
  String authorizationToken = BuildConfig.authorization;
  Map<String, String> headers = {'Content-Type': 'application/json'};
  BuildContext? buildContext;

  HttpRequestHandler(BuildContext context) {
    buildContext = context;
    headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      'Authorization': 'Bearer $authorizationToken',
    };
  }

  Future<bool> _checkNetwork() async {
    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      return true;
    }
    NotificationHandler.showErrorNotification("No internet connection available.");
    return false;
  }

  void signOut() async {
    Navigator.of(buildContext!).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  signInRequest(String userName, String password) async {
    if(!await _checkNetwork()){
      return {};
    }
    String signUrl = '${BuildConfig.serverUrl}/api/auth/login';
    var body = {
      "username": userName,
      "password": password,
    };
    try {
      http.Response response = await http.post(Uri.parse(signUrl),
          headers: headers, body: jsonEncode(body));
      Map<String, dynamic> respJson = jsonDecode(response.body);
      if (response.statusCode == 200) {
        respJson['status'] = 200;
        BuildConfig.authorization = respJson['token'];
        BuildConfig.username = respJson['username'];
        return respJson;
      } else {
        NotificationHandler.showErrorNotification(respJson["message"]);
        return respJson;
      }
    } catch (e) {
      NotificationHandler.showErrorNotification("Error");
      print("Error in signInRequest: $e");
      return {};
    }
  }

  Future<Map<String, dynamic>> transactionGet(String dateOrMonth, String party) async {
    if(!await _checkNetwork()){
      return {};
    }
    String transactionUrl =
        '${BuildConfig.serverUrl}/api/dashboard/summary?dateOrMonth=$dateOrMonth&party=$party';
    try {
      http.Response response = await http.get(
        Uri.parse(transactionUrl),
        headers: headers,
      );
      Map<String, dynamic> respJson = jsonDecode(response.body);
      if (response.statusCode == 200) {
        respJson['status'] = 200;
        return respJson;
      } else if (response.statusCode == 401) {
        signOut();
        return {};
      } else {
        NotificationHandler.showErrorNotification(respJson["message"]);
        return respJson;
      }
    } catch (e) {
      print("Error in transactionGet: $e");
      return {};
    }
  }

  Future<Map<String, dynamic>> monthlyTransactionGet(String dateOrMonth, String party) async {
    if(!await _checkNetwork()){
      return {};
    }
    String transactionUrl =
        '${BuildConfig.serverUrl}/api/dashboard/summary/grouped?startDate=$dateOrMonth&party=$party';
    try {
      http.Response response = await http.get(
        Uri.parse(transactionUrl),
        headers: headers,
      );
      Map<String, dynamic> respJson = jsonDecode(response.body);
      if (response.statusCode == 200) {
        respJson['status'] = 200;
        return respJson;
      } else if (response.statusCode == 401) {
        signOut();
        return {};
      } else {
        NotificationHandler.showErrorNotification(respJson["message"]);
        return respJson;
      }
    } catch (e) {
      print("Error in monthlyTransactionGet: $e");
      return {};
    }
  }

  Future<Map<String, dynamic>> dateRangeTransactionGet(
      String startDate, String endDate, String party) async {
    if(!await _checkNetwork()){
      return {};
    }
    String transactionUrl =
        '${BuildConfig.serverUrl}/api/dashboard/summary/grouped?startDate=$startDate&endDate=$endDate&party=$party';
    try {
      http.Response response = await http.get(
        Uri.parse(transactionUrl),
        headers: headers,
      );
      Map<String, dynamic> respJson = jsonDecode(response.body);
      if (response.statusCode == 200) {
        respJson['status'] = 200;
        return respJson;
      } else if (response.statusCode == 401) {
        signOut();
        return {};
      } else {
        NotificationHandler.showErrorNotification(respJson["message"]);
        return respJson;
      }
    } catch (e) {
      print("Error in dateRangeTransactionGet: $e");
      return {};
    }
  }

  fileUpload(File file) async {
    if(!await _checkNetwork()){
      return {};
    }
    String url = '${BuildConfig.serverUrl}/api/file/upload';
    try {
      var uri = Uri.parse(url);
      var request = http.MultipartRequest('POST', uri);
      var multipartFile = await http.MultipartFile.fromPath(
        'file', // 'file' is the name of the field expected by the server
        file.path,
      );
      request.headers.addAll(headers);
      request.files.add(multipartFile);
      var response = await request.send();
      var responseString = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseString);
      if (response.statusCode == 200) {
        return jsonResponse;
      } else if (response.statusCode == 401) {
        signOut();
      } else {
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  postTransaction(var body) async {
    if(!await _checkNetwork()){
      return {};
    }
    String url = '${BuildConfig.serverUrl}/api/transaction';
    try {
      http.Response response = await http.post(Uri.parse(url),
          headers: headers, body: jsonEncode(body));
      Map<String, dynamic> respJson = jsonDecode(response.body);
      if (response.statusCode == 201) {
        respJson['status'] = 201;
        return respJson;
      } else if (response.statusCode == 401) {
        signOut();
      }else {
        NotificationHandler.showErrorNotification(respJson["message"]);
        return respJson;
      }
    } catch (e) {
      print("Error in postTransaction: $e");
      return {};
    }
  }

  updateTransaction(var body, String id) async {
    if(!await _checkNetwork()){
      return {};
    }
    String url = '${BuildConfig.serverUrl}/api/transaction/$id';
    try {
      http.Response response = await http.put(Uri.parse(url),
          headers: headers, body: jsonEncode(body));
      Map<String, dynamic> respJson = jsonDecode(response.body);
      if (response.statusCode == 200) {
        respJson['status'] = 200;
        return respJson;
      } else if (response.statusCode == 401) {
        signOut();
      } else {
        NotificationHandler.showErrorNotification(respJson["message"]);
        return respJson;
      }
    } catch (e) {
      print("Error in updateTransaction: $e");
      return {};
    }
  }

  deleteTransaction(String id) async {
    if(!await _checkNetwork()){
      return {};
    }
    String url = '${BuildConfig.serverUrl}/api/transaction/$id';
    try {
      http.Response response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );
      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 401) {
        signOut();
      } else {
        return false;
      }
    } catch (e) {
      print("Error in deleteTransaction: $e");
      return false;
    }
  }

  getParty() async {
    if(!await _checkNetwork()){
      return [];
    }
    String url = '${BuildConfig.serverUrl}/api/transaction/party';
    try {
      http.Response response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      if (response.statusCode == 200) {
        List<dynamic> respJson = jsonDecode(response.body);
        return respJson;
      } else if (response.statusCode == 401) {
        signOut();
      } else {
        return [];
      }
    } catch (e) {
      print("Error in getParty: $e");
      return [];
    }
  }

  Future<List<dynamic>> getHistory() async {
    if(!await _checkNetwork()){
      return [];
    }
    String url = '${BuildConfig.serverUrl}/api/history';
    try {
      http.Response response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      if (response.statusCode == 200) {
        List<dynamic> respJson = jsonDecode(response.body);
        return respJson;
      } else if (response.statusCode == 401) {
        signOut();
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print("Error in getHistory: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> fileVaultGet(String folderId) async {
    if(!await _checkNetwork()){
      return {};
    }
    String url =
        '${BuildConfig.serverUrl}/api/vault/folders?folderId=$folderId';
    try {
      http.Response response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      Map<String, dynamic> respJson = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return respJson;
      } else if (response.statusCode == 401) {
        signOut();
        return {};
      } else {
        NotificationHandler.showErrorNotification(respJson["message"]);
        return {};
      }
    } catch (e) {
      print("Error in fileVaultGet: $e");
      return {};
    }
  }

  addFolder(var body) async {
    if(!await _checkNetwork()){
      return {};
    }
    String url =
        '${BuildConfig.serverUrl}/api/vault/folders?name=${body['name']}&parentId=${body['parentId']}';
    try {
      http.Response response = await http.post(Uri.parse(url),
          headers: headers, body: jsonEncode(body));
      Map<String, dynamic> respJson = jsonDecode(response.body);
      if (response.statusCode == 200) {
        respJson['status'] = 200;
        return respJson;
      } else if (response.statusCode == 401) {
        signOut();
      } else {
        NotificationHandler.showErrorNotification(respJson["message"]);
        return respJson;
      }
    } catch (e) {
      print("Error in addFolder: $e");
      return {};
    }
  }

  vaultFileUpload(File file, String folderId) async {
    if(!await _checkNetwork()){
      return {};
    }
    String url = '${BuildConfig.serverUrl}/api/vault/files';
    try {
      var uri = Uri.parse(url);
      var request = http.MultipartRequest('POST', uri);
      var multipartFile = await http.MultipartFile.fromPath(
        'file', // 'file' is the name of the field expected by the server
        file.path,
      );
      request.fields['folderId'] = folderId;
      request.headers.addAll(headers);
      request.files.add(multipartFile);
      var response = await request.send();
      var responseString = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseString);
      if (response.statusCode == 200) {
        return jsonResponse;
      } else if (response.statusCode == 401) {
        signOut();
      } else {
        NotificationHandler.showErrorNotification(jsonResponse["message"]);
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  deleteFiles(String id) async {
    if(!await _checkNetwork()){
      return {};
    }
    String url = '${BuildConfig.serverUrl}/api/vault/files/$id';
    try {
      http.Response response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );
      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 401) {
        signOut();
      } else {
        return false;
      }
    } catch (e) {
      print("Error in deleteFiles: $e");
      return false;
    }
  }

  deleteFolder(String id) async {
    if(!await _checkNetwork()){
      return {};
    }
    String url = '${BuildConfig.serverUrl}/api/vault/folders/$id';
    try {
      http.Response response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );
      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 401) {
        signOut();
        return {};
      } else {
        return false;
      }
    } catch (e) {
      print("Error in deleteFolder: $e");
      return false;
    }
  }

  Future<Uint8List> fetchBlob(String fileUuid) async {
    if(!await _checkNetwork()){
      throw Exception("Failed to load blob data");
    }
    String url = '${BuildConfig.serverUrl}/api/file/download/$fileUuid';
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      return response.bodyBytes; // Blob data
    } else {
      NotificationHandler.showErrorNotification(json.decode(response.body)["message"]);
      throw Exception("Failed to load blob data");
    }
  }

  Future<Uint8List> fetchVaultBlob(String fileUuid) async {
    if(!await _checkNetwork()){
      throw Exception("Failed to load blob data");
    }
    String url = '${BuildConfig.serverUrl}/api/vault/files/download/$fileUuid';
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      return response.bodyBytes; // Blob data
    } else {
      NotificationHandler.showErrorNotification(json.decode(response.body)["message"]);
      throw Exception("Failed to load blob data");
    }
  }
}