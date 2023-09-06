// ignore_for_file: super-parameters
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pd_app/model/Patient.dart';
import 'package:pd_app/ui/patient/action/QuestionPage.dart';
import 'package:pd_app/ui/patient/action/VideoPageNew.dart';


class QuestionResultPage extends StatefulWidget {
  final Patient patient;
  final CalculateMarker calculateMarker;
  const QuestionResultPage(
      {Key? key, required this.patient, required this.calculateMarker})
      : super(key: key);

  @override
  State<QuestionResultPage> createState() => _QuestionResultPageState();
}

class _QuestionResultPageState extends State<QuestionResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("問卷評分及診斷結果", style: TextStyle(fontSize: 28)),
      ),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 30.0),
          ),
          DataRow(
              markerName: '您經由此模型預測到的得病風險為:',
              markerValue: widget.calculateMarker.PostProb),
          SizedBox(
            width: double.infinity,
            height: 15,
          ),
          SizedBox(
            width: double.infinity,
            // height: 100.0,
            child: Container(
              padding: EdgeInsetsDirectional.all(12.0),
              margin: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
              color: Colors.purple[500],
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('所以您目前可能為巴金森前驅症狀的風險:',
                        style: TextStyle(fontSize: 28, color: Colors.white),
                        textAlign: TextAlign.left),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 10.0,
                  ),
                  Container(
                    // height: 30,
                    width: double.infinity,
                    color: Colors.white,
                    padding: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(widget.calculateMarker.PPPD,
                          style: TextStyle(fontSize: 28, color: Colors.black),
                          textAlign: TextAlign.justify),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          Container(
              // margin: const EdgeInsetsDirectional.symmetric(horizontal: 8.0),
              // padding: const EdgeInsetsDirectional.all(12.0),
              // padding: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
              padding: EdgeInsetsDirectional.all(8.0),
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {
                    var count = 0;
                    Navigator.popUntil(context, (route) {
                      return count++ == 3;
                    });
                    gotoVideoPage(widget.patient);
                  },
                  child: Container(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Text(
                        '確認',
                        style: Theme.of(context).textTheme.headlineLarge,
                      )))),
        ]),
      ),
    );
  }

  void gotoVideoPage(Patient patient) async {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => VideoPage(patient: patient)));
  }
}

class DataRow extends StatelessWidget {
  final String markerName;
  final double markerValue;
  const DataRow(
      {super.key, required this.markerName, required this.markerValue});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      // height: 100.0,
      child: Container(
        padding: EdgeInsetsDirectional.all(12.0),
        margin: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
        color: Colors.purple[500],
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(markerName,
                  style: TextStyle(fontSize: 28, color: Colors.white),
                  textAlign: TextAlign.left),
            ),
            SizedBox(
              width: double.infinity,
              height: 10.0,
            ),
            Container(
              // height: 30,
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(markerValue.toStringAsFixed(5),
                    style: TextStyle(fontSize: 28, color: Colors.black),
                    textAlign: TextAlign.justify),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
