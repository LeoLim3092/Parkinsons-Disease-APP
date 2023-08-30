import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';


class HandGesturesHelp extends StatefulWidget {
  const HandGesturesHelp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HandGesturesHelpState();
}


class _HandGesturesHelpState extends State<HandGesturesHelp> {
  final List<VideoPlayerController> _controllers = [];

  @override
  void initState() {
    super.initState();
    List<String> videoAssets = [
      'assets/videos/videoHand1.mp4',
      'assets/videos/videoHand2.mp4',
      'assets/videos/videoHand3.mp4',
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
          title: Text("示範教學：如何錄製手勢影像",
              style: Theme.of(context).textTheme.titleLarge)),
      body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            buildInstruction(
                0, '第一步：點選左/右手手部錄影之後會進入錄影介面。',
                const TextStyle(fontSize: 28)),
            buildInstruction(
                -1, '第二步：下方紅色按鈕為開始錄製，按下之後就會開錄製影片，上方會開始計時。',
                const TextStyle(fontSize: 28)),
            buildInstruction(
                1, '第三步：請先把手放在方形框框內部。握拳之後再張開食指跟拇指。',
                const TextStyle(fontSize: 28)),
            buildInstruction(
                2, '第四步：快速張開食指跟拇指，然後快速閉合，連續紀錄15秒。',
                const TextStyle(fontSize: 28)),
            buildInstruction(
                -1, '最終步：15秒後可以再次按下紅色按鈕，就會停止錄影，並且會跳出上傳視窗，如沒有錯誤就可以點選上傳。',
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
