
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:pd_app/ui/patient/info/VoiceHelp.dart';
import 'package:pd_app/ui/patient/info/GaitHelp.dart';
import 'package:pd_app/ui/patient/info/HandGesturesHelp.dart';



class HelpPages extends StatefulWidget {
  const HelpPages({super.key});

  @override
  State<StatefulWidget> createState() => _HelpPagesState();

}

class _HelpPagesState extends State<HelpPages> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("使用教學示範",
          style: Theme
              .of(context)
              .textTheme
              .titleLarge)),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/wallpaper.png"), // Replace with the path to your wallpaper image
                fit: BoxFit.cover,
              ),
            ),
            child: ListView(
              key: _formKey,
              children: getContent(),
            ),
          ),
        ],
      ),
    );
  }
  List<Widget> getContent() {
    return [
      getActionButton(() {
        gotoHelpGesturePage();
      }, "assets/images/handL.png", "手勢錄影教學"),
      getActionButton(() {
        gotoHelpSoundRecordingPage();
      }, "assets/images/voice.png", "聲音錄製教學"),
      getActionButton(() {
        gotoHelpGaitPage();
      }, "assets/images/walk.png", "步態錄影教學"),
    ];
  }

  Widget getActionButton(VoidCallback click, String imgPath, String text) {
    return Container(
      margin:const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
      width: double.infinity,
      color: Colors.greenAccent.withAlpha(128),
      // borderRadius: BorderRadius.circular(10.0),
      child: ListTile(
        onTap: click,
        leading: Image.asset(
          imgPath,
          width: 100.0,
          height: 100.0,
        ),
        title: Text(
          text,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 1.0), // Adjust the padding as needed
      ),
    );
  }

  void gotoHelpGesturePage() async {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HandGesturesHelp()));

  }

  void gotoHelpSoundRecordingPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const VoiceHelp()));
  }

  void gotoHelpGaitPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const GaitHelp()));
  }

}
