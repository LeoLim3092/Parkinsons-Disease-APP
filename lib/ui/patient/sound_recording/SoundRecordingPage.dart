import 'dart:async';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pd_app/api/PredictService.dart';
import 'package:pd_app/api/UploadService.dart';
import 'package:pd_app/model/Patient.dart';
import 'package:pd_app/prefs/UploadStatus.dart';
import 'package:pd_app/ui/patient/sound_recording/SoundRecordingFreeTalkPage.dart';

import 'package:pd_app/utils/UploadUtil.dart';
import 'package:pd_app/utils/TimeUtil.dart';

enum RecordPlayState {
  record,
  recording,
  play,
  playing,
}

class SoundRecordingPage extends StatefulWidget {
  final Patient patient;
  int startTimestamp = 0;
  double fontSize = 20;

  SoundRecordingPage({Key? key, required this.patient}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SoundRecordingPageState();
  }

  void recordClick() {
    startTimestamp = DateTime.now().millisecond;
  }
}

class _SoundRecordingPageState extends State<SoundRecordingPage> {
  FlutterSoundRecorder? _myRecorder;
  int time = 0;

  @override
  void initState() {
    super.initState();
    FlutterSoundRecorder().openRecorder().then((value) {
      _myRecorder = value;
    });
    KeepScreenOn.turnOn();
  }

  @override
  void dispose() {
    _myRecorder?.closeRecorder().then((value) => _myRecorder = null);
    KeepScreenOn.turnOff();
    super.dispose();
  }

  Future<bool> getPermissionStatus() async {
    Permission permission = Permission.microphone;
    //granted 通过，denied 被拒绝，permanentlyDenied 拒绝且不在提示
    PermissionStatus status = await permission.status;
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      requestPermission(permission);
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    } else if (status.isRestricted) {
      requestPermission(permission);
    } else {}
    return false;
  }

  ///申请权限
  void requestPermission(Permission permission) async {
    PermissionStatus status = await permission.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("文章錄音")),
        body: Flex(
          direction: Axis.vertical,
          children: [
            Expanded(
                child: ListView(children: [
              Container(
                  margin: const EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
                  child: Center(
                    child: Text(
                      "有一回，北風和太陽正在爭論誰的能耐大。爭來爭去，就是分不出個高低來。這會兒，來了個路人，他身上穿了件厚大衣。他們倆就說好了，誰能先叫這個路人把他的厚大衣脫下來，就算誰比較有本事。於是，北風就拚命地吹。怎料，他吹得越厲害，那個路人就把大衣包得越緊。最後，北風沒辦法，只好放棄。過了一陣子，太陽出來了。他火辣辣地曬了一下，那個路人就立刻把身上的厚大衣脫下來。於是，北風只好認輸了，他們倆之間還是太陽的能耐大。",
                      style: TextStyle(
                          fontSize: widget.fontSize, color: Colors.black),
                    ),
                  ))
            ])),
            Center(
              child: Text(
                getTimeString(time),
                style: TextStyle(fontSize: 70, color: Colors.red),
              ),
            ),
            Container(
              height: 30,
            ),
            Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                    child: FloatingActionButton(
                  onPressed: remove,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.remove),
                )),
                Expanded(
                    child: FloatingActionButton(
                  onPressed: click,
                  backgroundColor: Colors.red,
                )),
                Expanded(
                    child: FloatingActionButton(
                  onPressed: add,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.add),
                ))
              ],
            ),
            Container(
              height: 30,
            )
          ],
        ));
  }

  void add() {
    widget.fontSize += 2;
    setState(() {});
  }

  void remove() {
    widget.fontSize -= 2;
    setState(() {});
  }

  Timer? timer;
  String path = "";
  void click() {
    Future<void> record() async {
      await getPermissionStatus().then((value) async {
        if (!value) {
          return;
        }
        Directory tempDir = await getTemporaryDirectory();
        time = DateTime.now().millisecondsSinceEpoch;
        path = '${tempDir.path}/$time${ext[Codec.aacADTS.index]}';

        final session = await AudioSession.instance;
        await session.configure(AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
          AVAudioSessionCategoryOptions.defaultToSpeaker,
          avAudioSessionMode: AVAudioSessionMode.spokenAudio,
          avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
          avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
          androidAudioAttributes: const AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            flags: AndroidAudioFlags.none,
            usage: AndroidAudioUsage.voiceCommunication,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
          androidWillPauseWhenDucked: true,
        ));
        await _myRecorder?.startRecorder(
          toFile: path,
          codec: Codec.aacMP4,
        );
        int currentTime = DateTime.now().second;
        timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          time = DateTime.now().second - currentTime;
          setState(() {});
        });
      });
    }

    Future<bool?> stopRecorder() async {
      final uploadStatus = Provider.of<UploadStatus>(context, listen: false);
      await _myRecorder?.stopRecorder();
      timer?.cancel();
      time = 0;
      setState(() {});

      showUploadDialog(
        context: context,
        filePath: path,
        uploadFunction: (filePath) => UploadService.uploadSoundRecording(
          widget.patient.patientId ?? "",
          filePath,
        ),
        onSuccessNavigation: () => gotoSoundRecordingFreeTalkPage(widget.patient),
        dialogTitle: "上傳",
        dialogContent: "請問您是否要上傳此次閱讀錄音？",
        cancelText: "取消",
        uploadText: "上傳",
      );

      return null;
    }

    if (_myRecorder?.isRecording == true) {
      stopRecorder();
    } else {
      record();
    }
  }

  Future<void> performPredictions(Patient patient, BuildContext context) async {
    PredictService.predictModels(patient.patientId ?? "");
  }

  void gotoSoundRecordingFreeTalkPage(Patient patient) {
    // performPredictions(patient, context);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SoundRecordingFreeTalkPage(patient: patient)));
  }
}
