import 'package:flutter/material.dart';
import 'package:celebrities/detail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:celebrities/stt.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List _celebrities = [
    {
      "name": "家養貓貓",
      "occupation": "貓貓",
      "image": "assets/125075.jpg",
      "description_funny": "牠不是寵物，是你家老闆。你準時餵牠、陪牠玩，還得感謝牠願意賞你一個喵眼。平常像空氣，半夜三點直接甩你臉叫你起床開罐頭。你以為你在養貓？不，是牠在收留你",
      "description_kids": "白白的貓咪像雲朵一樣軟軟的，牠會用頭蹭蹭你，還會躺在床上打呼呼，超級萌！",
      "description_fact": "貓性格多數溫馴但對環境變化較為敏感須細心照顧其情緒。"


    },
    {
      "name": "黃金獵犬",
      "occupation": "愛笑狗狗",
      "image": "assets/6.jpg",
      "description": "家養黃金獵犬",
      "description_funny": "黃金獵犬：我帥、我傻、我愛你！你心情不好我立刻上前舔臉安慰，心情好我也舔。腦袋裡想的只有：吃、你、跑跑、吃、還是你",
      "description_kids": "牠會搖尾巴陪你玩，還會舔你安慰你，是最溫柔的狗狗！",
      "description_fact": "黃金獵犬原為狩獵犬是熱門的家庭寵物與導盲犬品種之一。"

    },
    {
      "name": "家養黃金鼠",
      "occupation": "深夜運動怪",
      "image": "assets/2.jpg",
      "description_funny": "白天裝死，晚上開趴。滾輪滾一整夜，比你健身還努力。你餵的食物永遠瞬間消失，因為牠嘴巴能塞整包零食。牠超會裝無辜，但其實整天偷偷搬家、藏食物、磨牙偷咬紙箱",
      "description_kids": "黃金鼠小小的，住在迷你房子裡。牠會把食物藏在臉頰裡，變成小倉庫，好聰明！",
      "description_fact": "黃金鼠屬於倉鼠科活動力強適合觀察與飼養。"
    },
    {
      "name": "野外蛇蛇",
      "occupation": "靜靜看你",
      "image": "assets/5.jpg",
      "description_funny": "看起來冷酷無情，其實只是不想社交。牠安靜得比你老闆還有壓迫感。你叫牠，牠不理；你不叫牠，牠突然盯著你發呆一小時。吐舌頭不是挑釁，是牠聞味道的方式，但看起來就是在挑釁",
      "description_kids": "蛇沒有腳，但牠可以滑滑滑地前進喔！牠吐舌頭不是兇，是在嗅嗅味道！",
      "description_fact": "蛇是爬蟲類，無四肢，靠腹部肌肉波動前進。牠們透過吐舌收集空氣粒子以嗅辨環境變化。"

    },
    {
      "name": "可愛海獺",
      "occupation": "水上混吃等死",
      "image": "assets/3.jpg",
      "description_funny": "每天漂在水面上像躺著領月薪，還能邊吃邊飄。牠們還會牽手睡覺防走散，根本世界最浪漫生物。你努力工作養家，牠浮著吃蝦滑水睡覺",
      "description_kids": "海獺會用肚子當餐桌吃東西喔～而且睡覺的時候會牽牽手不走丟，超可愛的！",
      "description_fact": "海獺是水陸兩棲哺乳動物，以貝類為主食。牠們利用石頭敲開硬殼，是少數懂得使用工具的動物之一。"
    }
  ];

  List showCelebrities = [];
  final TextEditingController _searchController = TextEditingController();
  bool isRecording = false;
  final record = AudioRecorder();


  void _searchCelebrities() {
    setState(() {
      String keyword = _searchController.text;
      showCelebrities = _celebrities
          .where((celebrity) =>
      celebrity["name"].contains(keyword) ||
          celebrity["occupation"].contains(keyword))
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
      appBar: AppBar(title: const Text('可愛動物')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                FloatingActionButton(
                  onPressed: () async {
                    print("按鈕被按了，目前狀態：$isRecording");

                    if (isRecording) {
                      print("準備停止錄音...");
                      try {
                        await record.stop();
                        print("錄音已停止");

                        final tempPath = await getTemporaryDirectory();
                        String path = "${tempPath.path}/audio.wav";
                        print("錄音檔案路徑：$path");

                        String? result = await request(path);
                        print("語音辨識結果：$result");

                        if (result != null) {
                          _searchController.text = result;
                        } else {
                          _searchController.text = "";
                        }
                      } catch (e) {
                        print("停止錄音時出錯: $e");
                      } finally {
                        print("執行 setState 停止錄音");
                        setState(() {
                          isRecording = false;
                        });
                      }
                    } else {
                      print("準備開始錄音...");
                      final tempPath = await getTemporaryDirectory();
                      String path = "${tempPath.path}/audio.wav";

                      if (await record.hasPermission()) {
                        try {
                          await record.start(
                            const RecordConfig(
                              sampleRate: 16000,
                              numChannels: 1,
                              encoder: AudioEncoder.wav,
                            ),
                            path: path,
                          );
                          print("開始錄音成功");

                          setState(() {
                            isRecording = true;
                          });
                        } catch (e) {
                          print("開始錄音時出錯: $e");
                        }
                      } else {
                        print("沒有錄音權限");
                      }
                    }
                  },

                  backgroundColor: isRecording ? Colors.red : Colors.blue,
                  mini: true,
                  child: const Icon(Icons.mic, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
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
                            builder: (context) => CelebrityDetail(
                              celebrity: showCelebrities[index],
                            ),
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

