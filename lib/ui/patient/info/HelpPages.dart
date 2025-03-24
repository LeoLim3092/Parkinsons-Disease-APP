
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
     appBar: AppBar(
          centerTitle: true,
          title: Text(
                  "使用教學示範",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                 ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue, Colors.green],  // Adjust colors as needed
              ),
            ),
          ),
          backgroundColor: Colors.transparent, // Set this to transparent to see the gradient
        ),

      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/APP001.jpg"), // Replace with the path to your wallpaper image
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
      }, "assets/images/APP006.png", "手勢錄影教學"),
      getActionButton(() {
        gotoHelpSoundRecordingPage();
      }, "assets/images/APP011.png", "聲音錄製教學"),
      getActionButton(() {
        gotoHelpGaitPage();
      }, "assets/images/APP013.png", "步態錄影教學"),
    ];
  }

  Widget getActionButton(VoidCallback click, String imgPath, String text) {
    return Container(
        decoration: BoxDecoration(
            color: Color(0xFFAFAFA0).withOpacity(0.2),
            borderRadius: BorderRadius.circular(15.0),
          ),
      margin:const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
      width: double.infinity + 40,

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
          style: TextStyle(fontSize: 32.0),
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
