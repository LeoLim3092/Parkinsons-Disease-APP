import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pd_app/api/UploadService.dart';
import 'package:pd_app/model/Patient.dart';
import 'package:pd_app/ui/patient/paint/PaintSpiralRightHandPage.dart';


class PaintThreePage extends StatefulWidget {
  final Patient patient;
  const PaintThreePage({Key? key, required this.patient}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PaintThreePageState();
}

class _PaintThreePageState extends State<PaintThreePage> {
  final _controller = HandwrittenSignatureController();
  Uint8List? _savedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("請連續寫 20 個 3",
          style: TextStyle(fontSize: 28))),
      body: Column(
        children: [
          Expanded(
              child: HandwrittenSignatureWidget(
                controller: _controller,
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  _controller.saveImage().then((value) => setState(() {
                    _savedImage = value;
                    if (value != null) {
                      showUpload(value);
                    }
                  }));
                },
                child: const Text(
                  '儲存圖片',
                  style: TextStyle(color: Colors.black, fontSize: 28),
                ),
              ),
              TextButton(
                onPressed: () {
                  _controller.reset();
                  setState(() {
                    _savedImage = null;
                  });
                },
                child: const Text(
                  '清空',
                  style: TextStyle(color: Colors.black, fontSize: 28),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
  void showUpload(Uint8List _savedImage) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(title: const Text("上傳",
              style: TextStyle(fontSize: 28)),
              content: const Text("請問請問您是否要上傳步態影片",
                  style: TextStyle(fontSize: 28)),
              actions: <Widget>[
            TextButton(
              child: const Text("取消", style: TextStyle(fontSize: 28)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("上傳", style: TextStyle(fontSize: 28)),
              onPressed: () async {
                EasyLoading.show(status: '上傳中');
                // print('ptName:' + widget.patient.name.toString());
                final tempDir = await getTemporaryDirectory();
                File file = await File('${tempDir.path}/image.png').create();
                file.writeAsBytesSync(_savedImage);

                // Convert coordinates to JSON
                List<List<Map<String, dynamic>>> coordinatesJson = _controller.getCoordinatesList();

                // Upload image and coordinates
                await UploadService.uploadPaint(
                  widget.patient.patientId ?? "",
                  file,
                  "three",
                  coordinatesJson,
                );
                
                EasyLoading.dismiss();
                Navigator.of(context).pop(true);
                gotoPaintSpiralPage(widget.patient);
              },
            ),
          ]);
        });
  }
  void gotoPaintSpiralPage(Patient patient) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PaintSpiralRightHandPage(patient: patient)),
    );
  }
}

class HandwrittenSignatureController {
  Function? _reset;
  Future<Uint8List?> Function()? _saveImage;
  List<List<Offset>> Function()? _getCoordinatesList;

  void reset() {
    _reset?.call();
  }

  Future<Uint8List?> saveImage() {
    return _saveImage?.call() ?? Future.value(null);
  }

  List<List<Offset>> getCoordinatesList() {
    return _getCoordinatesList?.call() ?? [];
  }
}

class HandwrittenSignatureWidget extends StatefulWidget {
  final HandwrittenSignatureController? controller;

  const HandwrittenSignatureWidget({Key? key, this.controller})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _HandwrittenSignatureWidgetState();
}

class _HandwrittenSignatureWidgetState
    extends State<HandwrittenSignatureWidget> {
  Path? _path;
  Offset? _previousOffset;
  final List<Path?> _pathList = [];
  final List<List<Map<String, dynamic>>> _coordinatesList = []; 


  @override
  void initState() {
    super.initState();
    widget.controller?._reset = () {
      setState(() {
        _pathList.clear();
        _coordinatesList.clear();
      });
    };
    widget.controller?._saveImage = () => _generateImage();
    widget.controller?._getCoordinatesList = () => _coordinatesList;

  }

  Future<Uint8List?> _generateImage() async {
    var paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2
      ..isAntiAlias = true;

    Rect? bound;
    for (Path? path in _pathList) {
      if (path != null) {
        var rect = path.getBounds();
        if (bound == null) {
          bound = rect;
        } else {
          bound = bound.expandToInclude(rect);
        }
      }
    }
    if (bound == null) {
      return null;
    }

    final size = bound.size;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, bound);

    for (Path? path in _pathList) {
      if (path != null) {
        var offsetPath = path.shift(Offset(20 - bound.left, 20 - bound.top));
        canvas.drawPath(offsetPath, paint);
      }
    }

    final picture = recorder.endRecording();
    ui.Image img = await picture.toImage(
        size.width.toInt() + 40, size.height.toInt() + 40);
    var bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List();
  }

  Path createSpiralPath(Size size) {
    double radius = 0, angle = 0;
    Path path = Path();
    path.moveTo(size.width/2, size.height/2);
    for (int n = 0; n < 200; n++) {
      radius += 0.75;
      angle += (math.pi * 2) / 50;
      var x = size.width / 2 + radius * math.cos(angle);
      var y = size.height / 2 + radius * math.sin(angle);
      path.lineTo(x, y);
    }
    return path;
  }

  List<Path> getCirclePath() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double centerWidth = width / 2;
    double centerHeight = height / 2;
    List<Path> ans = [];
    ans.add(createSpiralPath(Size(math.min(width, height), math.min(width, height))));
    // var range = List<int>.generate(4, (i) => i + 1);
    // for (int i in range) {
    //   var path = Path()
    //   ..addOval(Rect.fromCircle(
    //     center: Offset(centerWidth, centerHeight),
    //     radius: i * 40.0,
    //   ));
    //   ans.add(path);
    // }
    return ans;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        var position = details.localPosition;
        var timestamp = DateTime.now().millisecondsSinceEpoch;

        setState(() {
          _path = Path()..moveTo(position.dx, position.dy);
          _previousOffset = position;
          _coordinatesList.add([
            {"x": position.dx, "y": position.dy, "t": timestamp} // Add timestamp
          ]);
        });
      },
      onPanUpdate: (details) {
        var position = details.localPosition;
        var timestamp = DateTime.now().millisecondsSinceEpoch;
        var dx = position.dx;
        var dy = position.dy;

        setState(() {
          final previousOffset = _previousOffset;
          if (previousOffset == null) {
            _path?.lineTo(dx, dy);
          } else {
            var previousDx = previousOffset.dx;
            var previousDy = previousOffset.dy;
            _path?.quadraticBezierTo(
              previousDx,
              previousDy,
              (previousDx + dx) / 2,
              (previousDy + dy) / 2,
            );
          }
          _previousOffset = position;
          _coordinatesList.last.add({
            "x": position.dx,
            "y": position.dy,
            "t": timestamp // Add timestamp
          });
        });
      },
      onPanEnd: (details) {
        setState(() {
          _pathList.add(_path);
          _previousOffset = null;
          _path = null;
        });
      },
      child: CustomPaint(
        size: Size.infinite,
        painter: SignaturePainter(_pathList, getCirclePath(), _path),
      ),
    );
  }

}

class SignaturePainter extends CustomPainter {
  final List<Path?> pathList;
  final List<Path> circleList;

  final Path? currentPath;

  SignaturePainter(this.pathList, this.circleList, this.currentPath);

  final _paint = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = 2
    ..isAntiAlias = true;

  final _circlePaint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = 10
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    // for (Path path in circleList) {
    //   canvas.drawPath(path, _circlePaint);
    // }
    for (Path? path in pathList) {
      _drawLine(canvas, path);
    }
    _drawLine(canvas, currentPath);
  }

  void _drawLine(Canvas canvas, Path? path) {
    if (path == null) return;
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
