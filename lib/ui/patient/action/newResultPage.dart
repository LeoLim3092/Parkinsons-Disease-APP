import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pd_app/api/GetResultService.dart';
import 'package:flutter/material.dart';
import 'package:pd_app/model/Patient.dart';
import 'package:pd_app/ui/patient/action/PatientActionPage.dart';


class newResultPage extends StatefulWidget {
  final Patient patient;
  const newResultPage({Key? key, required this.patient}) : super(key: key);
  @override
  _newResultPageState createState() => _newResultPageState();
}


class _newResultPageState extends State<newResultPage> {
  String _patient = '沒有之前的資料';
  String _uploadTime = '沒有之前的資料';
  String _gaitResult = '0.0';
  String _voiceResult = '0.0';
  String _handResult = '0.0';
  String _multimodalResults = '0.0';
  List<double> values = [0.0, 0.0, 0.0, 0.0];
  List<double> thresholds = [0.0, 0.0, 0.0, 0.0];

  List<String> imgPaths = [
          "assets/images/APP009.png",
          "assets/images/APP011.png",
          "assets/images/APP013.png",
          "assets/images/APP015.png",
  ];

  List<String> img_texts = [
    "手指運動",
    "聲音分析",
    "步態分析",
    "綜合分析",
  ];

  Future<void> _getLatestResult() async {
    var data = await GetResultService.GetResult(widget.patient.patientId ?? "");
    setState(() {
      _patient = data['patient'] ?? '沒有之前的資料';
      _uploadTime = data['upload_time'] ?? '沒有之前的資料';
      _gaitResult = data['gait'] ?? '0.0';
      _voiceResult = data['voice'] ?? '0.0';
      _handResult = data['hand'] ?? '0.0';
      _multimodalResults = data['all'] ?? '0.0';

      values = [
        double.parse(_handResult),
        double.parse(_voiceResult),
        double.parse(_gaitResult),
        double.parse(_multimodalResults)
      ];
      thresholds = (data["thre"] as List<dynamic>).map((e) => double.parse(e.toString())).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _getLatestResult();
  }

  // Function to generate a single cell in the grid
  Widget _buildGridCell(String img_path, String img_text, double value, double threshold) {
    Color color = Color(0xFFF05454);
    String text = "正常";
    if (value > threshold) {
      color = Color(0xFFF05454);
      text = '高風險';
    } else {
      color = Color(0xFF6CF0B7);
      text = '正常';
    }
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(8), // Add some padding inside the container
      child: Column(
        // Use a Column to layout the image and text vertically
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            // First Row
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                img_path,
                width: 70,
                height: 70,
              ),
              SizedBox(width: 8), // Provides spacing between the image and text
              Expanded(
                child: Text(
                  img_text,
                  style: TextStyle(fontSize: 20, color: Color(0xFF004A2A)), // Fixed missing parenthesis here
                ),
              ),
            ],
          ),
          SizedBox(height: 8), // Provides spacing between the rows
          Text( // You do not need a Row here since there's only one Text widget
            text,
            textAlign: TextAlign.center, // Center the text
            style: TextStyle(fontSize: 28, color: Color(0xFF004A2A)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        centerTitle: true,
        title: Text(
                '最近一次結果',
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
      body: Container(
//          decoration: const BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage("assets/images/APP001.jpg"), // Replace with the path to your wallpaper image
//               fit: BoxFit.cover,
//             ),
//           ),
        child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
               Container(
                    decoration: BoxDecoration(
                            color: Color(0xFF0c8ecf),
                            borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8.0), // Add padding if needed
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('姓名: $_patient', style: const TextStyle(fontSize: 20,  color: Colors.white)),
                        Text('分析日期: $_uploadTime', style: const TextStyle(fontSize: 20,  color: Colors.white)),
                      ],
                    ),
               ),

               const SizedBox(height: 16),

               GridView.builder(
                   shrinkWrap: true, // Use it to prevent infinite height error
                   physics: const NeverScrollableScrollPhysics(), // to disable GridView's scrolling
                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                     crossAxisCount: 2, // Creates a 2x2 grid
                     crossAxisSpacing: 10, // Space between cells horizontally
                     mainAxisSpacing: 10, // Space between cells vertically
                   ),
                   itemCount: 4, // Adjust the number of items if necessary
                   itemBuilder: (BuildContext context, int index) {
                     // Ensure imgPaths and values have the correct number of elements
                     return _buildGridCell(imgPaths[index], img_texts[index], values[index], thresholds[index]);
                   },
               ),

              const SizedBox(height: 16),

              Container(
                  decoration: BoxDecoration(
                          color: Color(0xFF0c8ecf),
                          borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8.0), // Add padding if needed
                  child:  const Text(
                     "如果顯示高風險，請無過於擔心，請您找專業神經科醫生，進一步檢查",
                     style: TextStyle(fontSize: 28, color: Colors.white),
                   ),
              ),
            ],
        ),
      ),
    );
  }
}
