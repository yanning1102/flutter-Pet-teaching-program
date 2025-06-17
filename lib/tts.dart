import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Client {
  final String server = '140.116.245.147';
  final int port = 9999;
  final String endOfTransmission = 'EOT';
  final List<String> finetuneList = ["P_M_005", "M95", "M04"];
  late Future<Socket> _socketFuture; // 確保 _socket 被初始化

  final String _token = "mi2stts";
  final String _id = "10012";

  Client() {
    _socketFuture = _connect();
  }

  Future<Socket> _connect() async {
    try {
      final socket = await Socket.connect(server, port);
      print("Connected to $server:$port");
      return socket;
    } catch (e) {
      print("Connection failed: $e");
      rethrow;
    }
  }

  Future<void> send(String language, String speaker, String data) async {
    if (!([for (int i = 0; i < 4817; i++) i.toString()].contains(speaker) ||
        finetuneList.contains(speaker))) {
      throw ArgumentError(
          "Speaker ID must be in range 0 ~ 4815 or in FINETUNE_LIST");
    }

    if (data.isEmpty) {
      throw ArgumentError("Text must not be empty");
    }

    if (![
      'zh',
      'tw',
      'hakka',
      'en',
      'id',
      'mix',
      'tw_tl',
      'tw_tl_none',
      'phones'
    ].contains(language)) {
      throw ArgumentError(
          "Language must be one of ['zh', 'tw', 'hakka', 'en', 'id']");
    }

    String message = "$_id@@@$_token@@@$language@@@$speaker@@@$data";
    message += endOfTransmission;
    List<int> encodedMessage = utf8.encode(message);

    // 等待 _socket 連線成功
    final socket = await _socketFuture;
    socket.add(encodedMessage);
    await socket.flush();
  }

  Future<String> receive({int bufsize = 8192}) async {
    final socket = await _socketFuture;
    Completer<String> completer = Completer<String>();
    String receivedData = '';

    socket.listen((List<int> data) {
      receivedData += utf8.decode(data);
    }, onDone: () {
      completer.complete(receivedData);
    });

    return completer.future;
  }

  Future<void> close() async {
    final socket = await _socketFuture;
    await socket.close();
    print("Connection closed.");
  }
}

// 處理音檔的函數
Future<String?> processAudioFile(String text) async {
  String speaker = "4794";
  Client client = Client();
  await client.send('zh', speaker, text);

  String result = await client.receive();
  await client.close();

  return result; // 👉 將完整 JSON 給 detail.dart 處理
}