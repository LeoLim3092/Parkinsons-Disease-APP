import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:keep_screen_on/keep_screen_on.dart';

import 'package:pd_app/api/UploadService.dart';
import 'package:pd_app/model/Patient.dart';
import 'package:pd_app/ui/patient/action/PatientActionPage.dart';
import 'package:pd_app/ui/patient/gesture/GestureRecordingPageTurningLeft.dart';
import 'package:pd_app/ui/patient/walk/WalkRecordingCubit.dart' as WRC;
import 'package:pd_app/prefs/UploadStatus.dart';

import 'package:pd_app/utils/UploadUtil.dart';
import 'package:pd_app/utils/TimeUtil.dart';


class WalkRecordingPage extends StatefulWidget {
  List<CameraDescription> cameras;
  Patient patient;

  WalkRecordingPage({Key? key, required this.cameras, required this.patient}) : super(key: key);

  @override
  State<WalkRecordingPage> createState() {
    return _WalkRecordingPageState();
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

class _WalkRecordingPageState extends State<WalkRecordingPage> with WidgetsBindingObserver, TickerProviderStateMixin {
  var viewModel = WRC.WalkRecordingCubit();

  @override
  void initState() {
    super.initState();
    viewModel.init();
    try {
      viewModel.onNewCameraSelected(widget.cameras.firstWhere((element) => element.lensDirection == CameraLensDirection.back));
    } catch (e) {

    }
    WidgetsBinding.instance.addObserver(this);
    KeepScreenOn.turnOn();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    KeepScreenOn.turnOff();
    super.dispose();
  }

  // #docregion AppLifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      viewModel.dispose();
    } else if (state == AppLifecycleState.resumed) {
      viewModel.resume();
    }
  }

  // #enddocregion AppLifecycle

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WRC.WalkRecordingCubit, WRC.WalkRecordingState>(
        bloc: viewModel,
        listener: (context, state) async {
          WRC.Action? action = state.action;
          state.action = null;
          if (action == null) return;
          if (action is WRC.Error) {
            showInSnackBar(action.metaData);
          } else if (action is WRC.Dialog) {
            showUploadDialog(
              context: context,
              filePath: action.metaData, // Assuming `action.metaData` contains the file path
              uploadFunction: (filePath) => UploadService.uploadWalkRecording(
                widget.patient.patientId ?? "",
                filePath,
              ),
              onSuccessNavigation: () => gotoGesturePageTurningLeft(widget.patient),
              dialogTitle: "上傳",
              dialogContent: "請問您是否要上傳步態影片？",
              cancelText: "取消",
              uploadText: "上傳",
            );
          }
        },
        listenWhen: (prev, cur) {
          return cur.action != null;
        },
        buildWhen: (prev, cur) {
          return cur.action == null;
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('步態錄影'),
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
                                color: state.controller != null && state.controller!.value.isRecordingVideo ? Colors.redAccent : Colors.grey,
                                width: 3.0,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Center(
                                child: _cameraPreviewWidget(state.controller, context.read<WRC.WalkRecordingCubit>()),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(height: 100, width: double.infinity, decoration: BoxDecoration(color: Color(0x72000000))),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(height: 100, width: double.infinity, decoration: BoxDecoration(color: Color(0x72000000))),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(height: double.infinity, width: 100, decoration: BoxDecoration(color: Color(0x72000000))),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(height: double.infinity, width: 100, decoration: BoxDecoration(color: Color(0x72000000))),
                          )
                        ],
                      ),
                      getWidgetByAccelerometerValues(state.accelerometerValues),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(
                              getTimeString(state.time),
                              style: TextStyle(fontSize: 70, color: Colors.red),
                            )
                          ]),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [getFLB(state.controller)],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
          // return widget here based on BlocA's state
        });
  }

  FloatingActionButton getFLB(CameraController? controller) {
    if (controller?.value.isRecordingVideo == true) {
      return FloatingActionButton(
        child: Icon(Icons.stop),
        onPressed: () {
          viewModel.click(controller);
        },
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      );
    } else {
      return FloatingActionButton(
        onPressed: () {
          viewModel.click(controller);
        },
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      );
    }
  }

  Widget getWidgetByAccelerometerValues(List<double> accelerometerValues) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[getIconByAccelerometerValues(accelerometerValues)],
    );
  }

  Icon getIconByAccelerometerValues(List<double> accelerometerValues) {
    if (accelerometerValues.length < 3) {
      return Icon(null, color: Color(0xFFFFFFFF), size: 60.0);
    }
    var y = accelerometerValues[1];
    var z = accelerometerValues[2];
    var eps = 1 / 10.0;
    if ((y - 9.8).abs() < eps) {
      return Icon(Icons.check, color: Color(0xFFFFFFFF), size: 60.0);
    } else if (z > 0) {
      return Icon(Icons.arrow_drop_up, color: Color(0xFFFFFFFF), size: 60.0);
    } else {
      return Icon(Icons.arrow_drop_down, color: Color(0xFFFFFFFF), size: 60.0);
    }
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget(CameraController? cameraController, WRC.WalkRecordingCubit cubit) {
    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text(
        '開啟相機中',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Listener(
        onPointerDown: (_) => cubit.state.pointers++,
        onPointerUp: (_) => cubit.state.pointers--,
        child: CameraPreview(
          cameraController,
          child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: (details) {
                cubit.handleScaleStart(details);
              },
              onScaleUpdate: (details) {
                cubit.handleScaleUpdate(details);
              },
              onTapDown: (TapDownDetails details) => onViewFinderTap(details, constraints, cameraController),
            );
          }),
        ),
      );
    }
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints, CameraController? controller) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  void gotoGesturePageTurningLeft(Patient patient) async {
    final cameras = await availableCameras();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => GestureRecordingPageTurningLeft(
          cameras: cameras,
          patient: patient,
        )));
  }

}
