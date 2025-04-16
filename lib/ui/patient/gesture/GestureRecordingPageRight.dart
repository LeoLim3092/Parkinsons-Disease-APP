import 'dart:async';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:pd_app/api/UploadService.dart';
import 'package:pd_app/model/Patient.dart';
import 'package:pd_app/prefs/UploadStatus.dart';
import 'package:pd_app/ui/patient/sound_recording/SoundRecordingPage.dart';

import 'package:pd_app/utils/UploadUtil.dart';
import 'package:pd_app/utils/TimeUtil.dart';

class GestureRecordingPageRight extends StatefulWidget {
  List<CameraDescription> cameras;
  Patient patient;

  /// Default Constructor
  GestureRecordingPageRight({Key? key, required this.cameras, required this.patient}) : super(key: key);

  @override
  State<GestureRecordingPageRight> createState() {
    return _GestureRecordingPageRightState();
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
    default:
      throw ArgumentError('Unknown lens direction');
  }
}

void _logError(String code, String? message) {
  if (message != null) {
    print('Error: $code\nError Message: $message');
  } else {
    print('Error: $code');
  }
}

class _GestureRecordingPageRightState extends State<GestureRecordingPageRight> with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  bool enableAudio = true;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  List<double> _accelerometerValues = [];
  String type = "右手";

  @override
  void initState() {
    super.initState();
    onNewCameraSelected(widget.cameras.firstWhere((element) => element.lensDirection == CameraLensDirection.back));
    WidgetsBinding.instance.addObserver(this);
    _streamSubscriptions.add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        //TODO: 優化
        _accelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
    KeepScreenOn.turnOn();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    KeepScreenOn.turnOff();
    super.dispose();
  }

  // #docregion AppLifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  // #enddocregion AppLifecycle
  Timer? timer;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('手勢錄影'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(
                          color: controller != null && controller!.value.isRecordingVideo ? Colors.redAccent : Colors.grey,
                          width: 3.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Center(
                          child: _cameraPreviewWidget(),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(height: 300, width: double.infinity, decoration: BoxDecoration(color: Color(0x72000000))),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(height: 150, width: double.infinity, decoration: BoxDecoration(color: Color(0x72000000))),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(height: double.infinity, width: 50, decoration: BoxDecoration(color: Color(0x72000000))),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(height: double.infinity, width: 50, decoration: BoxDecoration(color: Color(0x72000000))),
                    )
                  ],
                ),
                getWidgetByAccelerometerValues(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            getTimeString(time),
                            style: TextStyle(fontSize: 70, color: Colors.red),
                          )
                        ]
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FloatingActionButton(
                          onPressed: () {
                            click(controller);
                          },
                          backgroundColor: Colors.red,
                        )
                      ],
                    )

                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getWidgetByAccelerometerValues() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[getIconByAccelerometerValues()],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              type,
              style: TextStyle(fontSize: 20, color: Colors.white),
            )
          ],
        )
      ],
    );
  }

  Icon getIconByAccelerometerValues() {
    if (_accelerometerValues.length >=3) {
        var y = _accelerometerValues[1];
        var z = _accelerometerValues[2];
        var eps = 1 / 10.0;
        if ((y - 9.8).abs() < eps) {
          return Icon(Icons.check, color: Color(0xFFFFFFFF), size: 60.0);
        } else if (z > 0) {
          return Icon(Icons.arrow_drop_up, color: Color(0xFFFFFFFF), size: 60.0);
        } else {
          return Icon(Icons.arrow_drop_down, color: Color(0xFFFFFFFF), size: 60.0);
        }
    }
    else{
        return Icon(Icons.error, color: Colors.red, size: 60.0);
    }
  }


  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: CameraPreview(
          controller!,
          child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              onTapDown: (TapDownDetails details) => onViewFinderTap(details, constraints),
            );
          }),
        ),
      );
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale).clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }

  void click(CameraController? cameraController) {
    if (cameraController == null) {
      return;
    }
    if (!cameraController.value.isInitialized) {
      return;
    }
    if (cameraController.value.isRecordingVideo) {
      onStopButtonPressed();
    } else {
      onVideoRecordButtonPressed();
    }
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    final CameraController? oldController = controller;
    if (oldController != null) {
      // `controller` needs to be set to null before getting disposed,
      // to avoid a race condition when we use the controller that is being
      // disposed. This happens when camera permission dialog shows up,
      // which triggers `didChangeAppLifecycleState`, which disposes and
      // re-creates the controller.
      controller = null;
      await oldController.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar('Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        // The exposure mode is currently not supported on the web.
        ...!kIsWeb ? <Future<Object?>>[] : <Future<Object?>>[],
        cameraController.getMaxZoomLevel().then((double value) => _maxAvailableZoom = value),
        cameraController.getMinZoomLevel().then((double value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
          break;
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
          break;
        case 'CameraAccessRestricted':
          // iOS only
          showInSnackBar('Camera access is restricted.');
          break;
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
          break;
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
          break;
        case 'AudioAccessRestricted':
          // iOS only
          showInSnackBar('Audio access is restricted.');
          break;
        default:
          _showCameraException(e);
          break;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  int time = 0;
  void onVideoRecordButtonPressed() {
    startVideoRecording(type).then((_) {
      if (mounted) {
        setState(() {});
      }
      int currentTime = DateTime.now().second;
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        time = DateTime.now().second - currentTime;
        setState(() {});
      });
    });
  }

  void onStopButtonPressed() {
    timer?.cancel();
    time = 0;
    setState(() {});
    stopVideoRecording().then((XFile? file) {
      if (mounted) {
        setState(() {});
      }
      if (file != null) {
        showUploadDialog(
          context: context,
          filePath: file.path,
          uploadFunction: (filePath) => UploadService.uploadGestureRecording(
            widget.patient.patientId ?? "",
            filePath,
            type,
          ),
          onSuccessNavigation: () => gotoSoundRecordingPage(widget.patient),
          dialogTitle: "上傳",
          dialogContent: "請問您是否要上傳此次右手錄影？",
          cancelText: "取消",
          uploadText: "上傳",
        );
      }
    });
  }

  Future<void> startVideoRecording(String type) async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void gotoSoundRecordingPage(Patient patient) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SoundRecordingPage(patient: patient)));
  }
}
