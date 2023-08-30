import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';


class GaitHelp extends StatefulWidget {
  const GaitHelp({super.key});

  @override
  State<StatefulWidget> createState() => _GaitHelpState();

}

class _GaitHelpState extends State<GaitHelp> {
  final List<VideoPlayerController> _controllers = [];

  @override
  void initState() {
    super.initState();
    List<String> videoAssets = [
      'assets/videos/videoGait1.mp4',
      'assets/videos/videoGait2.mp4',
      'assets/videos/videoGait3.mp4',
      'assets/videos/videoGait4.mp4',
    ];

    for (var asset in videoAssets) {
      VideoPlayerController controller = VideoPlayerController.asset(asset);
      _controllers.add(controller);
      controller.initialize().then((_) {
        setState(() {
          controller.setLooping(true);
          controller.play();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA8D9ED),
      appBar: AppBar(
          title: Text("示範教學：如何錄製行走步態",
              style: Theme.of(context).textTheme.titleLarge)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          buildInstruction(
              0, '第一步：點選行走步態錄影之後會進入錄影介面。',
              const TextStyle(fontSize: 28)),
          buildInstruction(
              1, '第二步：請先找一個空曠的空間，相機面對一面牆。如果有相機腳架可以先架設離地面大約80-100公分，如果沒有請另一位朋友/家屬協助拿著手機錄影。',
              const TextStyle(fontSize: 28)),
          buildInstruction(
              2, '第三步：請先水平上下調整手機到上方出現閃爍打勾，再請需要錄影分析的使用者靠近手機站到長條型的框框內。請注意 ⚠️！ 被錄影者的雙腳以及雙手必須全程都在長條型的框框內。',
              const TextStyle(fontSize: 28)),
          buildInstruction(
              3, '第四步：準備好就可以按下紅色按鈕開始錄影。請被錄影者以直線走向牆壁再左轉回來面對鏡頭走回起點，來回走路大約1分鐘。',
              const TextStyle(fontSize: 28)),
          buildInstruction(
              -1, '最終步：錄製1分種後可以再次按下紅色按鈕，就會停止錄影，並且會跳出上傳視窗，如沒有錯誤就可以點選上傳。',
              const TextStyle(fontSize: 28)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
  }

  Widget buildInstruction(int index, String text, TextStyle style) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), // adjust the value as per your need.
            color: const Color(0xFF70DDE8), // your desired color
          ),
          margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
          padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
          width: double.infinity,
          child: Text(text, style: style),
        ),

        if (index >= 0)
          if (_controllers[index].value.isInitialized)
            Column(
              children: [
                const Text("示範影片：", style: TextStyle(fontSize: 24)),
                SizedBox(
                  width: 250, // Set your desired width// Set your desired height
                  child: AspectRatio(
                    aspectRatio: _controllers[index].value.aspectRatio,
                    child: VideoPlayer(_controllers[index]),
                  ),
                ),
              ],
            )
      ],
    );
  }
}
