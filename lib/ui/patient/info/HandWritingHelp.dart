import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:pd_app/model/Patient.dart';
import 'package:pd_app/ui/patient/paint/PaintThreePage.dart';



class HandWritingHelp extends StatefulWidget {
  // const HandWritingHelp({super.key});
  final Patient patient;
  const HandWritingHelp({Key? key, required this.patient}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HandWritingHelpState();

}

class _HandWritingHelpState extends State<HandWritingHelp> {
  final List<VideoPlayerController> _controllers = [];

  @override
  void initState() {
    super.initState();
    List<String> videoAssets = [
      'assets/videos/handWrite3.mp4',
      'assets/videos/handSpiral.mp4'
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
      appBar: null,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[

          buildInstruction(
              -1, '感謝您上傳資料，模型將用5分鐘分析您的資料。在此同時請您協助我們蒐集手寫資料。',
              const TextStyle(fontSize: 28)),

          buildInstruction(
              0, '第一個手寫資料：連續手寫 “3” 二十次',
              const TextStyle(fontSize: 28)),

          buildInstruction(
              1, '第二個手寫資料：跟著指示圖，請沿著紅線內畫螺旋。',
              const TextStyle(fontSize: 28)),

          buildInstruction(
          -1, '最後一步：請填寫PD風險問卷',
          const TextStyle(fontSize: 28)),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), // adjust the value as per your need.
              color: const Color(0xFF70DDE8), // your desired color
            ),
            margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 50.0, bottom: 100),
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () {
                  gotoPaintThreePage(widget.patient);
                },
                child: Text("開始手寫以及問卷", style: Theme.of(context).textTheme.headlineMedium)

            ),
          ),

        ],
      ),
    );
  }

  void gotoPaintThreePage(Patient patient) async {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PaintThreePage(patient: patient)));
    // Navigator.of(context).push(MaterialPageRoute(
    //     builder: (context) => VideoPage(patient: patient)));
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
          margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 50.0),
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
