import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:celebrities/detail.dart';
import 'package:path_provider/path_provider.dart'; // getTemporaryDirectory
import 'package:just_audio/just_audio.dart'; // AudioPlayer
import 'package:record/record.dart'; // Record

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List _celebrities = [
    {
      "name": "家養貓貓",
      "occupation": "白貓",
      "image": "assets/125075.jpg",
      "description": "家養貓"
    },
    {
      "name": "家養狗狗",
      "occupation": "黃金獵犬",
      "image": "assets/Qf7AMPawsrZ.jpg",
      "description": "家養獵犬"
    },
    {
      "name": "家養老鼠",
      "occupation": "黃金鼠",
      "image": "assets/2.jpg",
      "description": "家養黃金鼠"
    },
    {
      "name": "野外蛇蛇",
      "occupation": "蛇",
      "image": "assets/5.jpg",
      "description": "荒野小蛇"

    },
    {
      "name": "可愛海獺",
      "occupation": "海獺",
      "image": "assets/3.jpg",
      "description": "普通可愛海獺"
    }

  ];

  List showCelebrities = [];
  final TextEditingController _searchController = TextEditingController();
  bool isRecording = false;
  final record = AudioRecorder();
  final player = AudioPlayer();

  void _searchCelebrities() {
    setState(() {
      String keyword = _searchController.text;
      showCelebrities = _celebrities
          .where((celebrity) =>
      (celebrity["name"].contains(keyword) ||
          celebrity["occupation"].contains(keyword)))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    showCelebrities = List.from(_celebrities);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('可愛動物'),
      ),
      body: Column(
        children: [
          // 搜索框 + 錄音按鈕
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                // 錄音按鈕
                FloatingActionButton(
                  onPressed: () async {
                    final tempPath = await getTemporaryDirectory();
                    String path = "${tempPath.path}/audio.wav";

                    if (isRecording) {
                      await record.stop();
                      player.setFilePath(path);
                      player.play();
                      isRecording = false;
                    } else {
                      if (await record.hasPermission()) {
                        await record.start(
                          const RecordConfig(
                            sampleRate: 16000,
                            numChannels: 1,
                            encoder: AudioEncoder.wav,
                          ),
                          path: path,
                        );
                      }
                      isRecording = true;
                    }
                    setState(() {});
                  },
                  backgroundColor: isRecording ? Colors.red : Colors.blue,
                  mini: true, // 讓按鈕變小
                  child: const Icon(Icons.mic, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10), // 間距

                // 搜索欄 + 搜索按鈕
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      contentPadding: EdgeInsets.all(10),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, size: 30, color: Colors.blue),
                  onPressed: _searchCelebrities,
                ),
              ],
            ),
          ),

          // 人物列表
          Expanded(
            child: ListView.builder(
              itemCount: showCelebrities.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Image.asset(
                      showCelebrities[index]["image"],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, size: 50);
                      },
                    ),
                    title: Text(
                      showCelebrities[index]["name"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(showCelebrities[index]["occupation"]),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return CelebrityDetail(
                                  celebrity: showCelebrities[index]);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}