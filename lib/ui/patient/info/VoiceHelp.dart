import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';


class VoiceHelp extends StatefulWidget {
  const VoiceHelp({super.key});

  @override
  State<StatefulWidget> createState() => _VoiceHelpState();

}

class _VoiceHelpState extends State<VoiceHelp> {
  final List<VideoPlayerController> _controllers = [];

  @override
  void initState() {
    super.initState();
    List<String> videoAssets = [
      'assets/videos/videoVoice1.mp4',
      'assets/videos/videoVoice2.mp4',
      'assets/videos/videoVoice3.mp4',
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
          title: Text("示範教學：如何錄製閱讀聲音",
              style: Theme.of(context).textTheme.titleLarge)),
      body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            buildInstruction(
                0, '第一步：點選閱讀聲音錄製之後會進入錄音介面。',
                const TextStyle(fontSize: 28)),
            buildInstruction(
                -1, '第二步：下方中間紅色圓形按鈕為開始錄音，按下之後就會開始計時。',
                const TextStyle(fontSize: 28)),
            buildInstruction(
                1, '第三步：兩側各有一個 “+” “-” 符號，可以放大或縮小文字。',
                const TextStyle(fontSize: 28)),
            buildInstruction(
                2, '第四步：請盡量靠近手機，準備好就可以開始按下中間紅色圓形按鈕開始錄音，請用一般朗讀的方式閱讀文章。',
                const TextStyle(fontSize: 28)),
            buildInstruction(
                -1, '最終步：朗讀結束後可以再次按下紅色按鈕，就會停止錄音，並且會跳出上傳視窗，如沒有錯誤就可以點選上傳。',
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
