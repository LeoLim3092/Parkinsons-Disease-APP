import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pd_app/api/GetResultService.dart';
import 'package:flutter/material.dart';
import 'package:pd_app/model/Patient.dart';
import 'package:pd_app/ui/patient/action/PatientActionPage.dart';


class ResultPage extends StatefulWidget {
  final Patient patient;
  const ResultPage({Key? key, required this.patient}) : super(key: key);
  @override
  _ResultPageState createState() => _ResultPageState();
}


class _ResultPageState extends State<ResultPage> {
  String _patient = '沒有之前的資料';
  String _uploadTime = '沒有之前的資料';
  String _gaitResult = '0.0';
  String _voiceResult = '0.0';
  String _handResult = '0.0';
  String _multimodalResults = '0.0';

  Future<void> _getLatestResult() async {
    var data = await GetResultService.GetResult(widget.patient.patientId ?? "");
    setState(() {
      _patient = data['patient'] ?? '沒有之前的資料';
      _uploadTime = data['upload_time'] ?? '沒有之前的資料';
      _gaitResult = data['gait'] ?? '0.0';
      _voiceResult = data['voice'] ?? '0.0';
      _handResult = data['hand'] ?? '0.0';
      _multimodalResults = data['all'] ?? '0.0';
    });
  }

  @override
  void initState() {
    super.initState();
    _getLatestResult();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('最近一次結果', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/wallpaper.png"), // Replace with the path to your wallpaper image
          fit: BoxFit.cover,
        ),
      ),
        child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Text('姓名: $_patient', style: const TextStyle(fontSize: 28),),
          Text('分析日期: $_uploadTime', style: const TextStyle(fontSize: 28),),
          Row(
            children: [
              const Text('手指運動分析結果:', style: TextStyle(fontSize: 28)),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: getScore(double.parse(_handResult), 70)
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text('聲音分析結果:', style: TextStyle(fontSize: 28)),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: getScore(double.parse(_voiceResult), 70),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text('步態分析結果:', style: TextStyle(fontSize: 28)),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: getScore(double.parse(_gaitResult), 70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('綜合上述您的手指運動聲音分析及步態分析結果您的預測結果是:', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          getScore(double.parse(_multimodalResults), 70),
          const SizedBox(height: 16),
          const Text(
          "如果顯示高風險，請無過於擔心，請您找專業神經科醫生，進一步檢查",
          style: TextStyle(fontSize: 28), ),
          Container(
              margin:
              const EdgeInsets.only(left: 100.0, right: 100.0, top: 2.0),
              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {
                    gotoMainPage(widget.patient);
                  },
                  child: Container(
                      padding:
                      const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Text(
                        '返回',
                        style: Theme
                            .of(context)
                            .textTheme
                            .headlineSmall,
                      )))),
        ],
      ),
      ));
  }

  Text getScore(double value, int threshold){
    if (value != 0.0){
       if (value < threshold){
         return const Text("正常", style: TextStyle(fontSize: 28, color: Colors.green));
       }
       else{
         return const Text("高風險", style: TextStyle(fontSize: 28, color: Colors.redAccent));
       }
    }
     else{
       return const Text('查無之前的資料', style: TextStyle(fontSize: 28));
    }
  }
  void gotoMainPage(Patient patient) async {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder:
        (context) => PatientActionPage(patient: patient)));
  }
}

