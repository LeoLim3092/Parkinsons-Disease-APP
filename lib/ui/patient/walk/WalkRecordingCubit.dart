import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:flutter/gestures.dart';
import 'package:sensors_plus/sensors_plus.dart';

class WalkRecordingCubit extends Cubit<WalkRecordingState> {
  WalkRecordingCubit() : super(WalkRecordingState());

  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  void init() {
    _streamSubscriptions.add(accelerometerEvents.listen((AccelerometerEvent event) {
      state.accelerometerValues = <double>[event.x, event.y, event.z];
      emit(WalkRecordingState.fromState(state));
    }));
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

  void onStopButtonPressed() {
    timer?.cancel();
    state.time = 0;
    stopVideoRecording().then((XFile? file) {
      if (file != null) {
        var newState = WalkRecordingState.fromState(state);
        newState.action = Dialog(file.path);
        emit(newState);
      }
    });
  }

  Timer? timer;

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((_) {
      if (isClosed) {
        return;
      }
      emit(WalkRecordingState.fromState(state));
      int currentTime = DateTime.now().second;

      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        state.time = DateTime.now().second - currentTime;
        emit(WalkRecordingState.fromState(state));
      });
    });
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = state.controller;

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
    final CameraController? cameraController = state.controller;

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

  void resume() {
    _streamSubscriptions.add(accelerometerEvents.listen((AccelerometerEvent event) {
      state.accelerometerValues = <double>[event.x, event.y, event.z];
      emit(WalkRecordingState.fromState(state));
    }));

    CameraController? controller = state.controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    onNewCameraSelected(controller.description);
  }

  void dispose() {
    timer?.cancel();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }

    CameraController? controller = state.controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    controller.dispose();
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    final CameraController? oldController = state.controller;
    if (oldController != null) {
      // `controller` needs to be set to null before getting disposed,
      // to avoid a race condition when we use the controller that is being
      // disposed. This happens when camera permission dialog shows up,
      // which triggers `didChangeAppLifecycleState`, which disposes and
      // re-creates the controller.
      state.controller = null;
      await oldController.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    state.controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (isClosed) {
        return;
      }
      emit(WalkRecordingState.fromState(state));

      if (cameraController.value.hasError) {
        showInSnackBar('Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        // The exposure mode is currently not supported on the web.
        ...<Future<Object?>>[],
        cameraController.getMaxZoomLevel().then((double value) => state.maxAvailableZoom = value),
        cameraController.getMinZoomLevel().then((double value) => state.minAvailableZoom = value),
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
    emit(WalkRecordingState.fromState(state));
  }

  void _showCameraException(CameraException e) {
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void handleScaleStart(ScaleStartDetails details) {
    state.baseScale = state.currentScale;
  }

  Future<void> handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    CameraController? controller = state.controller;
    if (controller == null || state.pointers != 2) {
      return;
    }
    state.currentScale = (state.baseScale * details.scale).clamp(state.minAvailableZoom, state.maxAvailableZoom);

    await controller.setZoomLevel(state.currentScale);
  }

  void showInSnackBar(String errorMsg) {
    var newState = WalkRecordingState.fromState(state);
    newState.action = Error(errorMsg);
    emit(newState);
  }
}

class Action {
  String metaData = "";

  Action({
    required this.metaData
  });
}

class Error extends Action {
  Error(String errorMsg) : super(metaData: errorMsg);
}

class Dialog extends Action {
  Dialog(String path) : super(metaData: path);
}

class WalkRecordingState {
  int time = 0;
  CameraController? controller;
  bool enableAudio = true;

  List<double> accelerometerValues = [];
  double minAvailableZoom = 1.0;
  double maxAvailableZoom = 1.0;
  double currentScale = 1.0;
  double baseScale = 1.0;

  // Counting pointers (number of user fingers on screen)
  int pointers = 0;
  Action? action = null;


  WalkRecordingState({this.time = 0,
    this.controller,
    this.enableAudio = true,
    this.accelerometerValues = const [],
    this.minAvailableZoom = 1.0,
    this.maxAvailableZoom = 1.0,
    this.currentScale = 1.0,
    this.baseScale = 1.0,
    this.pointers = 0,
    this.action});

  WalkRecordingState.fromState(WalkRecordingState state) {
    time = state.time;
    controller = state.controller;
    enableAudio = state.enableAudio;
    accelerometerValues = state.accelerometerValues;
    minAvailableZoom = state.minAvailableZoom;
    maxAvailableZoom = state.maxAvailableZoom;
    currentScale = state.currentScale;
    baseScale = state.baseScale;
    pointers = state.pointers;
  }
}
