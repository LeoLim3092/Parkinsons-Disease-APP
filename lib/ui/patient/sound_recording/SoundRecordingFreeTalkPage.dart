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

class SoundRecordingFreeTalkPage extends StatefulWidget {
  final Patient patient;
  int startTimestamp = 0;
  double fontSize = 32;

  SoundRecordingFreeTalkPage({Key? key, required this.patient}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SoundRecordingFreeTalkPageState();
  }

  void recordClick() {
    startTimestamp = DateTime.now().millisecond;
  }
}

class _SoundRecordingFreeTalkPageState extends State<SoundRecordingFreeTalkPage> {
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
        appBar: AppBar(title: const Text("對談錄音")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '這是對談錄音，請受試者面對手機進行語音錄製',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              '1. 請說說您這半年來生活中發生的有趣或是印象深刻的事情或是出去玩的經驗，請病患列舉 1-2 件',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 8),
            Text(
              '2. 您覺得您的健康狀態是否影響你的生活作息、聚會或出外的活動呢？有的話，是那些呢？',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 8),
            Text(
              '3. 未來您覺得是否可以透過調整生活型態或是飲食，來改善自己的健康？例如哪些呢？',
              style: TextStyle(fontSize: 20),
            ),
            Spacer(),
            Center(
              child: Text(
                getTimeString(time),
                style: TextStyle(fontSize: 70, color: Colors.red),
              ),
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton(
                onPressed: click,
                backgroundColor: Colors.green,
                child: Icon(Icons.play_arrow),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
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
        path = '${tempDir.path}/freetalk_$time${ext[Codec.aacADTS.index]}';

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
        onSuccessNavigation: () => gotoWalkPage(widget.patient),
        dialogTitle: "上傳",
        dialogContent: "請問您是否要上傳此次錄音？",
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
}
