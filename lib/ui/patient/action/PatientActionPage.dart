import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pd_app/model/Patient.dart';
import 'package:pd_app/ui/patient/gesture/GestureRecordingPageLeft.dart';
import 'package:pd_app/ui/patient/gesture/GestureRecordingPageRight.dart';
import 'package:pd_app/ui/patient/sound_recording/SoundRecordingPage.dart';
import 'package:pd_app/ui/patient/sound_recording/SoundRecordingFreeTalkPage.dart';
import 'package:pd_app/ui/patient/walk/WalkRecordingPage.dart';
import 'package:pd_app/ui/patient/action/newResultPage.dart';
import 'package:pd_app/api/UploadService.dart';
import 'package:pd_app/api/PredictService.dart';
import 'package:pd_app/ui/patient/info/HelpPages.dart';
import 'package:pd_app/ui/patient/info/HandWritingHelp.dart';
import 'package:pd_app/ui/login/LoginPage.dart';
import 'package:provider/provider.dart';
import 'package:pd_app/prefs/UploadStatus.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pd_app/ui/patient/action/VideoPageNew.dart';


final RouteObserver<ModalRoute<dynamic>> routeObserver =
RouteObserver<ModalRoute<dynamic>>();


class PatientActionPage extends StatefulWidget {
  final Patient patient;
  const PatientActionPage({Key? key, required this.patient}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _PatientActionPageState();

}

class _PatientActionPageState extends State<PatientActionPage> with RouteAware, WidgetsBindingObserver {

  final _formKey = GlobalKey<FormState>();
  var medicine = "0";
  var medicine_3hr = "0";
  var exercise = "0";
  bool isPredict = true;


  @override
  void initState() {
    int age;
    Future(() {
      showMedicationDialog();
      age = widget.patient.age ?? 0;
      if (age < 50){
        showAgeWarningDialog();
        isPredict = false;
      }
      else{
        isPredict = true;
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      centerTitle: true,
      title: Text(
              "${widget.patient.name ?? ""} 的紀錄介面",
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
               image: AssetImage("assets/images/APP001.jpg"),
               fit: BoxFit.cover,
             ),
           ),
           child: ListView(
             key: _formKey,
             children: [
               ...getContent(), // This will spread out the widgets from getContent() in the list
               Padding(
                 padding: const EdgeInsets.only(top: 10, bottom: 10), // adding 5 px space at top and bottom
                 child: Center(
                   child: GestureDetector(
                     onTap: () => gotoResultPage(widget.patient),
                     child: Container(
                       width: 250,
                       child: Image.asset(
                         "assets/images/APP005.png",
                         fit: BoxFit.contain,
                       ),
                     ),
                   ),
                 ),
               ),
             ],
           ),
         ),

//         Positioned(
//           bottom: 5.0,
//           left: 5.0,
//           child: GestureDetector(
//             onTap: () => gotoHelpPage(),
//             child: Image.asset(
//               "assets/images/APP003.png",
//               width: 200,
//               fit: BoxFit.fill,
//             )
//           ),
//         ),
//
//         Positioned(
//           bottom: 5.0,
//           right: 5.0,
//           child: GestureDetector(
//             onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage(title: "NTU PD"))),
//             child: Image.asset(
//               "assets/images/APP004.png",  // replace with your image path
//               width: 65,  // adjust the width as needed
//               fit: BoxFit.fill,
//             )
//           ),
//         )

      ],
    ),

   bottomNavigationBar: BottomAppBar(

     child: Container(

       height: 60,  // Adjust height as needed
       color: Color(0xFF9AC6C7),  // Change to your desired fixed color
       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: <Widget>[
           // Padding for left image
           Padding(
             padding: EdgeInsets.only(left: 5.0), // Added space to the left
             child: GestureDetector(
               onTap: () => gotoHelpPage(),
               child: Image.asset(
                 "assets/images/APP003.png",
                 width: 150,
                 fit: BoxFit.fill,
               )
             ),
           ),
           // Padding for right image
           Padding(
             padding: EdgeInsets.only(right: 5.0), // Added space to the right
             child: GestureDetector(
               onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage(title: "NTU PD"))),
               child: Image.asset(
                 "assets/images/APP004.png",
                 width: 65,
                 fit: BoxFit.fill,
               )
             ),
           ),
         ],
       ),
     ),
   ),



    );
  }


  List<Widget> getContent() {
    return [

      getActionButton(() {
        gotoGesturePageLeft(widget.patient);
      }, "assets/images/APP017.png"),
      getActionButton(() {
        gotoGesturePageRight(widget.patient);
      }, "assets/images/APP018.png"),
      getActionButton(() {
        gotoSoundRecordingPage(widget.patient);
      }, "assets/images/APP019.png"),
      getActionButton(() {
        gotoSoundRecordingFreeTalkPage(widget.patient);
      }, "assets/images/APP028.png"),
      getActionButton(() {
        gotoWalkPage(widget.patient);
      }, "assets/images/APP020.png"),
        getActionButton(() {
          gotoPredictPage(widget.patient);
        }, "assets/images/APP021.png"),

    ];
  }

Widget getActionButton(VoidCallback click, String imgPath) {
  return GestureDetector(
    onTap: click,
    child: Container(
      margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 1.0),
        child: Image.asset(
          imgPath,
          width: MediaQuery.of(context).size.width - 32.0 - 20.0, // Screen width minus horizontal paddings and margins
          fit: BoxFit.contain,
        ),
      ),
    ),
  );
}


  void gotoHelpPage(){
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HelpPages()));
  }
  void gotoSoundRecordingPage(Patient patient) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => SoundRecordingPage(patient: patient)));
  }

  void gotoSoundRecordingFreeTalkPage(Patient patient) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => SoundRecordingFreeTalkPage(patient: patient)));
  }

  void gotoResultPage(Patient patient){
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => newResultPage(patient: patient)));
  }

  void gotoPredictPage(Patient patient) {
    showPredictDialog(widget.patient);
  }

  void gotoWalkPage(Patient patient) {
    EasyLoading.show(status: 'start camera');
    availableCameras().then((cameras) {
      EasyLoading.dismiss();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => WalkRecordingPage(
                cameras: cameras,
                patient: patient,
              )));
    });
  }

  void gotoGesturePageLeft(Patient patient) async {
    final cameras = await availableCameras();
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => GestureRecordingPageLeft(
          cameras: cameras,
          patient: patient,
        )));
  }

  void gotoGesturePageRight(Patient patient) async {
    final cameras = await availableCameras();
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => GestureRecordingPageRight(
          cameras: cameras,
          patient: patient,
        )));
  }

  void gotoHandWritingHelp(Patient patient) async {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => HandWritingHelp(patient: patient)));
    // Navigator.of(context).push(MaterialPageRoute(
    //     builder: (context) => VideoPage(patient: patient)));
  }

  void showMedicationDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(title: Align(
                    alignment: Alignment.centerLeft,  // Aligns to the left
                    child: UnconstrainedBox(
                      child: Container(
                        width: 150,  // set your desired width
                        child: Image.asset("assets/images/APP022.png", fit: BoxFit.cover),
                      ),
                    ),
                  ),
              content: Text("請問您過去有被診斷為巴金森氏症嗎？", style: Theme.of(context).textTheme.headlineMedium), actions: <Widget>[
            TextButton(
              child: Image.asset("assets/images/APP023.png", width: 70),
              onPressed: () {
                var medicine = "0";
                var medicine_3hr = "0";
                UploadService.uploadMedicineRecord(widget.patient.patientId ?? "", medicine, medicine_3hr);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Image.asset("assets/images/APP024.png", width: 70),
              onPressed: () {
                Navigator.of(context).pop();
                var medicine = "1";
                show3HourMedicationDialog(medicine);

              },
            ),
          ]);
        });
  }

  void show3HourMedicationDialog(String medicine) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(title: Align(
                   alignment: Alignment.centerLeft,  // Aligns to the left
                   child: UnconstrainedBox(
                     child: Container(
                       width: 150,  // set your desired width
                       child: Image.asset("assets/images/APP022.png", fit: BoxFit.cover),
                     ),
                   ),
                 ),
              content: Text("請問您在3小時內有服用巴金森藥物嗎?", style: Theme.of(context).textTheme.headlineMedium), actions: <Widget>[
            TextButton(
              child: Image.asset("assets/images/APP023.png", width: 70),
              onPressed: () {
                var medicine_3hr = "0";
                UploadService.uploadMedicineRecord(widget.patient.patientId ?? "", medicine, medicine_3hr);
                Navigator.of(context).pop();
                showExercisesQuestion();
              },
            ),
            TextButton(
              child: Image.asset("assets/images/APP024.png", width: 70),
              onPressed: () {
                var medicine_3hr = "1";
                UploadService.uploadMedicineRecord(widget.patient.patientId ?? "", medicine, medicine_3hr);
                Navigator.of(context).pop();
                showExercisesQuestion();
              },
            ),
          ]);
        });

  }


  void showExercisesQuestion() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(title: Align(
                   alignment: Alignment.centerLeft,  // Aligns to the left
                   child: UnconstrainedBox(
                     child: Container(
                       width: 150,  // set your desired width
                       child: Image.asset("assets/images/APP022.png", fit: BoxFit.cover),
                     ),
                   ),
                 ),
              content: Text("請問您這一天有進行我們APP提供的動作運動嗎?", style: Theme.of(context).textTheme.headlineMedium), actions: <Widget>[
            TextButton(
              child: Image.asset("assets/images/APP023.png", width: 70),
              onPressed: () {
                var exercise = "0";
                UploadService.uploadExerciseRecord(widget.patient.patientId ?? "", exercise);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Image.asset("assets/images/APP024.png", width: 70),
              onPressed: () {
                var exercise = "1";
                UploadService.uploadExerciseRecord(widget.patient.patientId ?? "", exercise);
                Navigator.of(context).pop();
              },
            ),
          ]);
        });
  }

  void showAgeWarningDialog(){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(title: Text("年齡小於 50", style: Theme.of(context).textTheme.headlineMedium),
              content: Text("如果您的年齡小於50歲，目前評估罹患神經退化性疾病的風險極低，建議不使用本模型預測是否會罹患巴金森氏症",
                  style: Theme.of(context).textTheme.headlineMedium),
              actions: <Widget>[
            TextButton(
              child: Text('了解', style: Theme.of(context).textTheme.headlineMedium),
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage(title: "NTU PD")));
              },
            ),
          ]);
        });
  }

  void showPredictDialog(Patient patient) {
    final uploadStatus = Provider.of<UploadStatus>(context, listen: false);
    String noUploadFile = '';
    bool isUploadSuccessful = true;
    bool isUploadSoundSuccessful = uploadStatus.isUploadSoundSuccessful;
    bool isUploadGaitSuccessful = uploadStatus.isUploadGaitSuccessful;
    bool isUploadLHSuccessful = uploadStatus.isUploadLHSuccessful;
    bool isUploadRHSuccessful = uploadStatus.isUploadRHSuccessful;
    if (isUploadSoundSuccessful && isUploadGaitSuccessful && isUploadLHSuccessful && isUploadRHSuccessful) {
      isUploadSuccessful = true;
    }

    if (!isUploadLHSuccessful){
      noUploadFile += '左手，';
    }

    if (!isUploadRHSuccessful){
      noUploadFile += '右手，';
    }

    if (!isUploadSoundSuccessful){
      noUploadFile += '聲音，';
    }

    if (!isUploadGaitSuccessful){
      noUploadFile += '步態，';
    }

    if (isUploadSuccessful){
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return AlertDialog(title:  Align(
                 alignment: Alignment.centerLeft,  // Aligns to the left
                 child: UnconstrainedBox(
                   child: Container(
                     width: 150,  // set your desired width
                     child: Image.asset("assets/images/APP022.png", fit: BoxFit.cover),
                   ),
                 ),
               ),
            
            content: const Text("是否要進行模型預測", style:
            TextStyle(fontSize: 28)),

            actions: <Widget>[
              TextButton(
                child: Image.asset("assets/images/APP023.png", width: 70),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Image.asset("assets/images/APP024.png", width: 70),
                onPressed: () {
                  performPredictions(patient, context);
                  Navigator.of(context).pop();
                  gotoHandWritingHelp(widget.patient);
                  // showLoadingAnimation(patient, context);
                },
              ),
            ]);
          });
    }
    else{
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(title: Text("這次還沒上傳的資料：", style: Theme.of(context).textTheme.headlineMedium),
                content: Text(noUploadFile, style: Theme.of(context).textTheme.headlineMedium),
                actions: <Widget>[
                  TextButton(
                    child: Text("返回", style: Theme.of(context).textTheme.headlineMedium),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ]);
          });
    }
  }


  Future<void> showLoadingAnimation(Patient patient, BuildContext context) async {
    EasyLoading.show(status: '模型分析中，請耐心等待！');
    await Future.delayed(Duration(seconds: 30));
    EasyLoading.dismiss();
    gotoResultPage(patient);

  }

  Future<void> performPredictions(Patient patient, BuildContext context) async {
    PredictService.predictModels(patient.patientId ?? "");
  }

  // Future<void> performPredictions(Patient patient, BuildContext context) async {
  //   EasyLoading.show(status: '檢查上傳資料中請耐心等待 1-2 分鐘！');
  //   http.Response response = await PredictService.checkRecording(patient.patientId ?? "");
  //
  //   if (response.statusCode == 200) {
  //     Map<String, dynamic> jsonResponse = jsonDecode(response.body);
  //
  //     if (jsonResponse['success'] == "success") {
  //       PredictService.predictModels(patient.patientId ?? "");
  //       Navigator.of(context).pop(true);
  //       gotoPaintThreePage(widget.patient);
  //       EasyLoading.dismiss();
  //     }
  //     else {
  //       Navigator.of(context).push(
  //         MaterialPageRoute(
  //           builder: (BuildContext context) {
  //             return AlertDialog(
  //                 title: const Text("資料上傳錯誤請從新上傳下列！", style: TextStyle(fontSize: 28)),
  //                 content: Text("${jsonResponse['error']}", style: const TextStyle(fontSize: 28)),
  //                 actions: <Widget>[
  //                   TextButton(
  //                     child: Text("了解", style: Theme.of(context).textTheme.headlineMedium),
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                       Navigator.of(context).pop();
  //                     },
  //                   )
  //                 ]
  //             );
  //           },
  //           fullscreenDialog: true,
  //         ),
  //       );
  //       EasyLoading.dismiss();
  //     }
  //   }
  //   else {
  //     EasyLoading.dismiss();
  //     throw Exception('Failed to load data');
  //   }
  // }

}

Color blendWithWhite(Color color, double alpha) {
  int red = ((1 - alpha) * 255 + alpha * color.red).round();
  int green = ((1 - alpha) * 255 + alpha * color.green).round();
  int blue = ((1 - alpha) * 255 + alpha * color.blue).round();
  return Color.fromARGB(255, red, green, blue);
}


class CustomImageButton extends StatelessWidget {
  final VoidCallback onPressed;
  final ImageProvider image;

  const CustomImageButton({super.key, required this.onPressed, required this.image});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: image,
            fit: BoxFit.cover,
          ),
        ),
        child: const SizedBox(
          width: 100, // Adjust the width and height according to your needs
          height: 100,
          child: Center(
            child: Icon(
              Icons.play_arrow, // You can replace this with any other widget
              color: Colors.white,
              size: 40.0,
            ),
          ),
        ),
      ),
    );
  }
}

