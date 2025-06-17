import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:celebrities/tts.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class CelebrityDetail extends StatefulWidget {
  final Map celebrity;

  const CelebrityDetail({super.key, required this.celebrity});

  @override
  State<CelebrityDetail> createState() => _CelebrityDetailState();
}

class _CelebrityDetailState extends State<CelebrityDetail> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  final AudioPlayer player = AudioPlayer();
  bool isFavorite = false;

  String currentStyle = "fact"; // 預設風格描述

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    player.dispose();
    super.dispose();
  }

  String getDescriptionByStyle(Map celeb, String style) {
    switch (style) {
      case "fact":
      return celeb["description_fact"] ?? celeb["description"];
      case "funny":
        return celeb["description_funny"] ?? celeb["description"];
      case "kids":
        return celeb["description_kids"] ?? celeb["description"];
      default:
        return celeb["description"];
    }
  }

  IconData getAnimalIcon(String name) {
    if (name.contains("貓")) return Icons.pets;
    if (name.contains("狗")) return Icons.emoji_nature;
    if (name.contains("鼠")) return Icons.adb;
    if (name.contains("蛇")) return Icons.all_inclusive;
    if (name.contains("海獺")) return Icons.water;
    return Icons.pets;
  }

  Future<void> playLongText(String fullText) async {
    List<String> parts = fullText
        .split(RegExp(r'[，。！？\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    for (String part in parts) {
      print("🔊 正在合成語音段落：$part");

      String? result;
      try {
        result = await processAudioFile(part);
      } catch (e) {
        print("❌ 語音請求失敗：$e");
        continue;
      }

      if (result == null || result.trim().isEmpty) {
        print("⚠️ 無回傳資料");
        continue;
      }

      try {
        // 自行解析 JSON
        Map<String, dynamic> json = jsonDecode(result);

        if (json["status"] != true) {
          print("❌ 合成失敗：${json["message"]}");
          continue;
        }

        // 手動補 Base64 padding
        String base64Str = json["bytes"] ?? "";
        int missingPadding = base64Str.length % 4;
        if (missingPadding != 0) {
          base64Str += '=' * (4 - missingPadding);
        }

        List<int> audioBytes = base64Decode(base64Str);
        Directory tempDirectory = await getTemporaryDirectory();
        String path = "${tempDirectory.path}/tts_${DateTime.now().millisecondsSinceEpoch}.wav";
        File(path).writeAsBytesSync(audioBytes);

        print("✅ 撥放語音：$path");
        await player.setFilePath(path);
        await player.play();

        await player.playerStateStream
            .firstWhere((state) => state.processingState == ProcessingState.completed)
            .timeout(const Duration(seconds: 10));
      } catch (e) {
        print("❌ 播放或解碼失敗：$e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("語音失敗：$part")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final celebrity = widget.celebrity;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(celebrity["name"]),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              setState(() => isFavorite = !isFavorite);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isFavorite ? "已加入最愛！" : "已從最愛移除")),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 圖片
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    celebrity["image"],
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 250,
                      color: Colors.grey,
                      child: const Icon(Icons.error, size: 50),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 名稱 + 小圖標
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(getAnimalIcon(celebrity["name"]), color: Colors.pinkAccent, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    celebrity["name"],
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                celebrity["occupation"],
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // 卡片描述
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getDescriptionByStyle(celebrity, currentStyle),
                      style: const TextStyle(fontSize: 16, height: 1.6),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text("描述風格：", style: TextStyle(fontWeight: FontWeight.bold)),
                        DropdownButton<String>(
                          value: currentStyle,
                          items: const [
                            DropdownMenuItem(value: "fact", child: Text("知識型")),
                            DropdownMenuItem(value: "funny", child: Text("搞笑")),
                            DropdownMenuItem(value: "kids", child: Text("兒童版")),

                          ],
                          onChanged: (value) {
                            setState(() => currentStyle = value ?? "funny");
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 功能按鈕
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("回首頁"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final text = getDescriptionByStyle(celebrity, currentStyle);
                      await player.stop();

                      // 顯示提示
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("語音播放中...")),
                      );

                      try {
                        await playLongText(text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("語音播放結束")),
                        );
                      } catch (e) {
                        print("❌ 播放錯誤：$e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("語音播放失敗：$e")),
                        );
                      }
                    },

                    icon: const Icon(Icons.volume_up),
                    label: const Text("語音播放"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 分隔點點
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  6,
                      (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}







