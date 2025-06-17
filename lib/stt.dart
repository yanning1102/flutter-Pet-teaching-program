import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String?> request(String path) async {
  try {
    print("[STT] 開始讀取錄音檔");

    File file = File(path);
    List<int> fileBytes = await file.readAsBytes();

    print("[STT] 轉 base64");
    String base64Audio = base64Encode(fileBytes);

    Map<String, dynamic> data = {
      "audio": base64Audio,
      "lang": "STT for course",
      "source": "人本and多語",
      "timestamp": false
    };

    Uri url = Uri.parse("http://140.116.245.147:9000/api/base64_recognition");

    print("[STT] 發送請求到語音伺服器");
    http.Response response = await http
        .post(
      url,
      body: jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    )
        .timeout(const Duration(seconds: 5)); // 最多等 5 秒

    print("[STT] 回傳狀態碼: ${response.statusCode}");

    if (response.statusCode == 200) {
      if (response.body == "<{silent}>") {
        return null;
      } else {
        return response.body;
      }
    } else {
      print("Request failed with status code: ${response.statusCode}");
      return null;
    }
  } on TimeoutException catch (_) {
    print("[STT] 語音伺服器請求逾時");
    return null;
  } catch (e) {
    print("[STT] 發生錯誤: $e");
    return null;
  }
}

/*Future<String?> request(String path) async {
  print("[STT] 模擬語音辨識中...");
  await Future.delayed(const Duration(seconds: 1));
  return "這是一段假語音";
}*/

