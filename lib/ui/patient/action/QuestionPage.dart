import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pd_app/api/UploadService.dart';
import 'package:pd_app/model/Patient.dart';
import 'package:pd_app/ui/patient/action/VideoPage.dart';
import 'package:pd_app/ui/patient/action/QuestionResultPage.dart';
import 'dart:convert';



CalculateMarker _calculateMarker = CalculateMarker();
Map<int, Question> question = {
  1: Question(
      '請問您的年齡：',
      ['50-54', '55-59', '60-64', '65-69', '70-74', '75-79', '>=80'],
      [0.0040, 0.00750, 0.01250, 0.020, 0.0250, 0.0350, 0.040],
      'Prior Probability'),
  2: Question('(1)	您的性別：', ['男性', '女性'], [1.2, 0.8], 'Risk Markers'),
  3: Question('(2)	過去是否曾接觸殺蟲劑(Regular Pesticide Exposure)(例如：>=100次非職業性接觸)： ',
      ['是', '否', '不知道或是無法取得資訊'], [1.5, 1.0, 1.0], 'Risk Markers'),
  4: Question('(3)	職業或是居住環境是否會接觸到化學溶劑(Occupational Solvent Exposure)：',
      ['是', '否', '不知道或是無法取得資訊'], [1.5, 1.0, 1.0], 'Risk Markers'),
  5: Question(
      '(4)	是否長期攝取含咖啡因飲料(Consume Caffeinated Beverage)：',
      ['是 (每周大於3杯咖啡或是6杯紅茶)', '否 (每周小於3杯咖啡或是6杯紅茶)', '不知道或是無法取得資訊'],
      [0.88, 1.35, 1.0],
      'Risk Markers'),
  6: Question(
      '(5)	是否抽菸(Smoking)：',
      [
        '從未 (Never)',
        '已戒菸 (Former)',
        '仍在抽菸（Current）',
        '不知道或是無法取得資訊 (Not Available)'
      ],
      [1.2, 0.91, 0.51, 1.0],
      'Risk Markers'),
  7: Question('(6)	家族一等親(父母或是兄弟姊妹)是否有罹患巴金森症的患者：', ['是', '否', '不知道或是無法取得資訊'],
      [2.5, 1.0, 1.0], 'Risk Markers'),
  8: Question('a.	GBA基因變異 (Anheim 2012, Neurology)：', ['是', '否', '不知道或是無法取得資訊'],
      [20.0, 1.0, 1.0], 'Risk Markers'),
  9: Question('b.	LRRK2 (p.G2019S)基因變異(Lee 2017, Mov Disord)：',
      ['是', '否', '不知道或是無法取得資訊'], [2.5, 1.0, 1.0], 'Risk Markers'),
  10: Question(
      '(7-2) 多基因風險分數(Polygenetic Risk Score)：',
      [
        '高風險分數(例如: 分數在大型世代追蹤族群中的最前四分之一)',
        '低風險分數(例如: 分數在大型世代追蹤族群中的最後四分之一)',
        '不知道或是無法取得資訊'
      ],
      [1.57, 0.45, 1.0],
      'Risk Markers'),
  11: Question(
      '(8)	穿顱超音波檢查顯示黑質有高回聲訊號(Documented Substantia Nigra Hyperechogenicity on Transcranial Ultrasound)(例如：訊號強度大於90個百分比的參考樣本的單側或雙側黑質高回聲訊號)：',
      ['是', '否', '不知道或是無法取得資訊'],
      [3.4, 0.38, 1.0],
      'Risk Markers'),
  12: Question('(9)	是否具有第二型糖尿病：', ['是', '否', '不知道或是無法取得資訊'], [1.5, 0.97, 1.0],
      'Risk Markers'),
  13: Question('(10)	是否活動力不足(例如：每週進行能使呼吸及心跳速率上升/流汗的活動次數小於1小時)：',
      ['是', '否', '不知道或是無法取得資訊'], [1.3, 0.91, 1.0], 'Risk Markers'),
  14: Question('(11)	如果您是男性，血液中尿酸濃度是否偏低：', ['是', '否', '不知道或是無法取得資訊'],
      [1.8, 0.88, 1.0], 'Risk Markers'),
  15: Question(
      'A-1.1 您是否有睡眠多項生理檢查證實的快速動眼期睡眠動作障礙?(睡覺時會對夢境內容大喊大叫，甚至拳打腳踢)：',
      ['是', '否', '不知道或是無法取得資訊'],
      [130, 0.65, 1.0],
      'Clinical Non-motor Markers'),
  16: Question(
      'A-1.2 您的快速動眼期睡眠動作障礙 (睡覺時會對夢境內容大喊大叫，甚至拳打腳踢)是否可以排除其他的可能?\n(其他鑑別診斷、藥物誘發/猝睡症相關動作症狀需被排除)：',
      ['是', '否'],
      [1.0, 0.0],
      'Clinical Non-motor Markers'),
  17: Question(
      '快速動眼期睡眠動作障礙篩檢結果為：',
      ['陽性。無進一步檢驗確認', '陰性。無進一步檢驗確認', '不知道或是無法取得資訊'],
      [2.8, 0.89, 1.0],
      'Clinical Non-motor Markers'),
  18: Question('A-2 日間嗜睡(可能的藥物誘發嗜睡或是猝睡症相關症狀需被排除)：', ['是', '否', '不知道或是無法取得資訊'],
      [2.7, 0.86, 1.0], 'Clinical Non-motor Markers'),
  19: Question(
      'A-3 您的嗅覺功能是否下降或是喪失? (例如：量化嗅覺測驗，如：Sniffin’ Stick, UPSIT或B-SIT，總分低於年紀及性別調整後之閾值)：',
      ['是', '否', '不知道或是無法取得資訊'],
      [6.4, 0.4, 1.0],
      'Clinical Non-motor Markers'),
  20: Question(
      'A-4 您是否有便秘情況? (便秘症狀至少需要每週一次的吃軟便藥治療，或自然排便頻率低於兩天一次)：',
      ['是', '否', '不知道或是無法取得資訊'],
      [2.5, 0.82, 1.0],
      'Clinical Non-motor Markers'),
  21: Question('A-5 您是否有泌尿功能失調症狀? (排尿不順或是夜間頻尿)：', ['是', '否', '不知道或是無法取得資訊'],
      [2.0, 0.9, 1.0], 'Clinical Non-motor Markers'),
  22: Question(
      'A-6 若您是男性，是否有嚴重勃起障礙(Severe Erectile Dysfunction)：',
      ['是', '否', '不知道或是無法取得資訊', '女性病患'],
      [3.4, 0.87, 1.0, 1.0],
      'Clinical Non-motor Markers'),
  23: Question('A-7 是否有姿態性低血壓(Orthostatic Hypotension)：', ['是', '否'], [1, 0],
      'Clinical Non-motor Markers'),
  24: Question(
      '姿態性低血壓(Orthostatic Hypotension)結果：',
      [
        '姿態性低血壓，且經專家全面性評估後無其他可能原因',
        '有姿態性低血壓紀錄，但未經進一步檢查評估',
        '經專家全面性評估後無姿態性低血壓',
        '無姿態性低血壓紀錄，且無進一步檢查評估',
        '不知道或是無法取得資訊'
      ],
      [18.5, 3.2, 0.88, 0.80, 1.0],
      'Clinical Non-motor Markers'),
  25: Question(
      'A-8 是否有憂鬱症狀?(有/無合併焦慮症狀) (臨床診斷或是憂鬱量表/問卷達中等以上嚴重程度)：',
      ['是', '否', '不知道或是無法取得資訊'],
      [1.6, 0.88, 1.0],
      'Clinical Non-motor Markers'),
  26: Question('A-9 您是否有認知功能降低? (例如：被診斷輕度認知障礙)：', ['是', '否', '不知道或是無法取得資訊'],
      [1.8, 0.88, 1.0], 'Clinical Non-motor Markers'),
  27: Question('B-1 巴金森氏病量表(UPDRS)第三部分總分大於6分 (需排除動作誘發顫抖及其他潛在干擾因子，例如：關節炎)：',
      ['是', '否', '不知道或是無法取得資訊'], [9.6, 0.55, 1.0], 'Clinical Motor Markers'),
  28: Question(
      'B-2 量化動作測驗呈現異常結果 (Abnormal Quantitative Motor Testing) (異常結果應依據不同測試的閾值，低於其年紀調整後常模的1個標準差。選用的量化動作測驗應可清楚呈現巴金森氏病患者的異常，且相較於控制組有80%以上的專一性。若是選用多個量化動作測驗，個案應有超過一半的測驗結果呈現異常。不確定或於臨界值的結果皆不應納入計算)：',
      ['是', '否', '不知道或是無法取得資訊'],
      [3.5, 0.6, 1.0],
      'Clinical Motor Markers'),
  29: Question('C-1 多巴胺攝影影像結果呈現明顯異常 (TRODAT 核醫影像) (例如：小於65%的正常結果或是低於平均兩個標準差)：',
      ['是', '否', '不知道或是無法取得資訊'], [43.3, 0.66, 1], 'Clinical Biomarkers'),
};

_QuestionPageState? _globalState;

class QuestionPage extends StatefulWidget {
  final Patient patient;
  QuestionPage({Key? key, required this.patient}) : super(key: key);

  @override
  // State<StatefulWidget> createState() => _QuestionPageState();

  State<StatefulWidget> createState() =>
      (_globalState = new _QuestionPageState());
}

class _QuestionPageState extends State<QuestionPage> {
  bool _isButtonDisabled = true;
  double priorProb = 0;
  double RiskMarker = 0;
  double ProdromalMarkers = 0;
  double ClinicalNonMotorMarkers = 0;
  double ClinicalMotorMarkers = 0;
  double ClinicalBiomarkers = 0;
  double font_size = 28;

  @override
  void initState() {
    _isButtonDisabled = true;
    question.forEach((index, value) => value.response = '');
    super.initState();
  }

  void callbackButton() {
    setState(() {
      _isButtonDisabled = false;
    });
  }

  void callbackData() {
    setState(() {
      priorProb = _calculateMarker.PriorProb;
      RiskMarker = _calculateMarker.RiskMarker;
      ProdromalMarkers = _calculateMarker.prodromalMarker;
      ClinicalNonMotorMarkers = _calculateMarker.Non_Motor_Marker;
      ClinicalMotorMarkers = _calculateMarker.MotorMarker;
      ClinicalBiomarkers = _calculateMarker.BioMarker;
    });
  }

  void callbackPriorPro() {
    setState(() {
      priorProb = _calculateMarker.PriorProb;
    });
  }

  void callbackRiskMarker() {
    setState(() {
      RiskMarker = _calculateMarker.RiskMarker;
    });
  }

  void callbackProdromalMarkers() {
    setState(() {
      ProdromalMarkers = _calculateMarker.prodromalMarker;
    });
  }

  void callbackClinicalNonMotorMarkers() {
    setState(() {
      ClinicalNonMotorMarkers = _calculateMarker.Non_Motor_Marker;
    });
  }

  void callbackClinicalMotorMarkers() {
    setState(() {
      ClinicalMotorMarkers = _calculateMarker.MotorMarker;
    });
  }

  void callbackClinicalBiomarkers() {
    setState(() {
      ClinicalBiomarkers = _calculateMarker.BioMarker;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("問卷"),
        ),
        body: SingleChildScrollView(
            child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: 30.0),
              ),
              SizedBox(
                width: double.infinity,
                height: 110.0,
                child: Container(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                  margin: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                  color: Colors.purple[500],
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '1. 前導機率 (Prior Probability):  ',
                          style: TextStyle(fontSize: font_size, color: Colors.white),
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        height: 80,
                        width: 100,
                        color: Colors.white,
                        padding: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            priorProb.toStringAsFixed(3),
                            style: TextStyle(fontSize: font_size, color: Colors.black),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: double.infinity, height: 20.0),
              QuestionWidget(aQuestion: question[1]),
              SizedBox(
                width: double.infinity,
                height: 110.0,
                child: Container(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                  margin: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                  color: Colors.purple[500],
                  child: Row(
                    children: [
                      Expanded( child: Text('2.	風險指標 (Risk Markers):  ',
                          style: TextStyle(fontSize: font_size, color: Colors.white),
                          textAlign: TextAlign.left)),
                      Container(
                        height: 80,
                        width: 100,
                        color: Colors.white,
                        padding:
                            EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(RiskMarker.toStringAsFixed(3),
                              style:
                                  TextStyle(fontSize: font_size, color: Colors.black),
                              textAlign: TextAlign.justify),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: double.infinity, height: 20.0),
              QuestionWidget(aQuestion: question[2]),
              QuestionWidget(aQuestion: question[3]),
              QuestionWidget(aQuestion: question[4]),
              QuestionWidget(aQuestion: question[5]),
              QuestionWidget(aQuestion: question[6]),
              QuestionWidget(aQuestion: question[7]),
              SizedBox(
                width: double.infinity,
                height: 10,
              ),
              SizedBox(
                  width: double.infinity,
                  child: Container(
                    padding: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                    child: Text('(7-1)	您是否帶有巴金森氏症致病基因?',
                        style: TextStyle(fontSize: font_size),
                        textAlign: TextAlign.left),
                  )),
              SizedBox(
                width: double.infinity,
                height: 10,
              ),
              SizedBox(
                  width: double.infinity,
                  child: Container(
                    padding: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                    child: Text('與巴金森氏病相關的基因變異:',
                        style: TextStyle(fontSize: font_size),
                        textAlign: TextAlign.left),
                  )),
              SizedBox(
                width: double.infinity,
                height: 10,
              ),
              QuestionWidget(aQuestion: question[8]),
              QuestionWidget(aQuestion: question[9]),
              QuestionWidget(aQuestion: question[10]),
              QuestionWidget(aQuestion: question[11]),
              QuestionWidget(aQuestion: question[12]),
              QuestionWidget(aQuestion: question[13]),
              QuestionWidget(aQuestion: question[14]),
              SizedBox(
                width: double.infinity,
                height: 110.0,
                child: Container(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                  margin: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                  color: Colors.purple[500],
                  child: Row(
                    children: [
                      Expanded( child: Text('3.	前驅症狀指標:  ',
                          style: TextStyle(fontSize: font_size, color: Colors.white),
                          textAlign: TextAlign.left)),
                      Container(
                        height: 80,
                        width: 100,
                        color: Colors.white,
                        padding:
                            EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(ProdromalMarkers.toStringAsFixed(3),
                              style:
                                  TextStyle(fontSize: font_size, color: Colors.black),
                              textAlign: TextAlign.justify),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: double.infinity, height: 20.0),
              SizedBox(
                width: double.infinity,
                height: 110.0,
                child: Container(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                  margin: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                  color: Colors.purple[500],
                  child: Row(
                    children: [
                      Expanded( child: Text('A.	非動作症狀指標:  ',
                          style: TextStyle(fontSize: font_size, color: Colors.white),
                          textAlign: TextAlign.left)),
                      Container(
                        height: 80,
                        width: 100,
                        color: Colors.white,
                        padding:
                            EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              ClinicalNonMotorMarkers.toStringAsFixed(3),
                              style:
                                  TextStyle(fontSize: font_size, color: Colors.black),
                              textAlign: TextAlign.justify),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: double.infinity, height: 20.0),
              QuestionWidget(aQuestion: question[15]),
              QuestionWidget(aQuestion: question[16]),
              QuestionWidget(aQuestion: question[17]),
              QuestionWidget(aQuestion: question[18]),
              QuestionWidget(aQuestion: question[19]),
              QuestionWidget(aQuestion: question[20]),
              QuestionWidget(aQuestion: question[21]),
              QuestionWidget(aQuestion: question[22]),
              QuestionWidget(aQuestion: question[23]),
              QuestionWidget(aQuestion: question[24]),
              QuestionWidget(aQuestion: question[25]),
              QuestionWidget(aQuestion: question[26]),
              SizedBox(
                width: double.infinity,
                height: 110.0,
                child: Container(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                  margin: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                  color: Colors.purple[500],
                  child: Row(
                    children: [
                      Expanded( child: Text('B.	臨床動作症狀指標:  ',
                          style: TextStyle(fontSize: font_size, color: Colors.white),
                          textAlign: TextAlign.left)),
                      Container(
                        height: 80,
                        width: 100,
                        color: Colors.white,
                        padding:
                            EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(ClinicalMotorMarkers.toStringAsFixed(3),
                              style:
                                  TextStyle(fontSize: font_size, color: Colors.black),
                              textAlign: TextAlign.justify),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: double.infinity, height: 20.0),
              QuestionWidget(aQuestion: question[27]),
              QuestionWidget(aQuestion: question[28]),
              SizedBox(
                width: double.infinity,
                height: 50.0,
                child: Container(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                  margin: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                  color: Colors.purple[500],
                  child: Row(
                    children: [
                      Text('C.	臨床生物標記:  ',
                          style: TextStyle(fontSize: font_size, color: Colors.white),
                          textAlign: TextAlign.left),
                      Container(
                        height: 30,
                        width: 100,
                        color: Colors.white,
                        padding:
                            EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(ClinicalBiomarkers.toStringAsFixed(3),
                              style:
                                  TextStyle(fontSize: font_size, color: Colors.black),
                              textAlign: TextAlign.justify),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: double.infinity, height: 20.0),
              QuestionWidget(aQuestion: question[29]),
              SizedBox(
                  width: double.infinity,
                  child: Container(
                    padding: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                    child: Text(
                        'Reference: Heinzel S, Berg D, Gasser T, et al. Update of the MDS Research Criteria for Prodromal PD. Mov Disord 2019',
                        style: TextStyle(fontSize: font_size-5),
                        textAlign: TextAlign.left),
                  )),
              Divider(),
              Container(
                  // margin: const EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                  // padding: const EdgeInsetsDirectional.all(12.0),
                  // padding: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                  padding: EdgeInsetsDirectional.all(8.0),
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: _isButtonDisabled
                          ? null
                          : () {
                              // uploadQuestion(question);
                              showUpload();
                            },
                      child: Container(
                          padding:
                              const EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: Text(
                            '送出',
                            style: Theme.of(context).textTheme.headlineSmall,
                          )))),
            ])));
  }

  Future<void> uploadQuestion(Map<int, Question> patientQuestion) async {
    String responseJson = '';
    var response;
    Map<String, dynamic> toMap(int questionKey, Question questionValue) {
      return {
        'question': questionKey,
        'response':
            questionValue.dropdownMenuList.indexOf(questionValue.response) + 1,
      };
    }

    List<Map<String, dynamic>> questionResponseList = [];
    patientQuestion.forEach((key, value) {
      questionResponseList.add(toMap(key, value));
    });
    responseJson = json.encode(questionResponseList);
    // print('$responseJson');
    if (responseJson.isNotEmpty) {
      try {
        response = await UploadService.uploadQuestion(
            widget.patient.patientId ?? "",
            _calculateMarker.riskMarker,
            _calculateMarker.PLR,
            _calculateMarker.result0,
            _calculateMarker.PostProb,
            _calculateMarker.PPPD,
            responseJson);
        // .then((value) => Navigator.of(context).push(MaterialPageRoute(
        //     builder: (context) => QuestionResultPage(
        //         patient: widget.patient,
        //         calculateMarker: _calculateMarker))));
      } catch (error) {
        print('uploadError: $error');
      }
    }
    return response;
  }

  void showUpload() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
              title: Text("送出", style:
                  TextStyle(fontSize: font_size)),
              content: Text("請問您是否要送出問卷", style:
                  TextStyle(fontSize: font_size)),
              actions: <Widget>[
                TextButton(
                  child: Text("取消", style:
                  TextStyle(fontSize: font_size)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text("送出", style:
                  TextStyle(fontSize: font_size)),
                  onPressed: () async {
                    EasyLoading.show(status: '上傳中');

                    // await UploadService.uploadPaint(widget.patient.name ?? "", File.fromRawPath(_savedImage), "circle");
                    await uploadQuestion(question).then((value) {
                      EasyLoading.dismiss();
                      // Navigator.of(context).pop(true);
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder:
                          (context) => QuestionResultPage(
                              patient: widget.patient,
                              calculateMarker: _calculateMarker)));
                    });
                  },
                ),
              ]);
        });
  }
}

class Question {
  String question;
  List<String> dropdownMenuList;
  List<double> values;
  String question_class = '';
  String response = '';
  double? response_val = 1.0;


  Question(
      this.question, this.dropdownMenuList, this.values, this.question_class);
}

class QuestionWidget extends StatefulWidget {
  Question? aQuestion;

  QuestionWidget({required this.aQuestion});

  @override
  State<QuestionWidget> createState() =>
      _QuestionWidgetState(aQuestion: aQuestion);
}

class _QuestionWidgetState extends State<QuestionWidget> {
  Question? aQuestion;
  String? dropdownValue = null;
  bool isChosen = false;
  double font_size = 28;

  _QuestionWidgetState({required this.aQuestion}) {
    if (aQuestion!.dropdownMenuList.last == '不知道或是無法取得資訊') {
      dropdownValue = aQuestion!.dropdownMenuList.last;
      isChosen = true;
      aQuestion!.response = dropdownValue!;
      aQuestion!.response_val = aQuestion!
          .values[aQuestion!.dropdownMenuList.indexOf(aQuestion!.response)];
      _calculateMarker.processingData();
      // _globalState!.callbackData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Container(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
            child: Text(aQuestion!.question,
                style: TextStyle(fontSize: font_size), textAlign: TextAlign.left),
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
          child: DropdownButton<String>(
            itemHeight: null,
            isDense: false, // Allow the dropdown to expand vertically for long text
            isExpanded: true,
            value: dropdownValue,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: isChosen ? Colors.deepPurpleAccent : Colors.red,
            ),
            onChanged: (String? value) {
              // This is called when the user selects an item.
              setState(() {
                dropdownValue = value!;
                aQuestion!.response = dropdownValue!;
                aQuestion!.response_val = aQuestion!.values[
                    aQuestion!.dropdownMenuList.indexOf(aQuestion!.response)];
                isChosen = true;

                _calculateMarker.processingData();
                _globalState!.callbackData();

                print('checkAllQuestionSelected: ' +
                    checkAllQuestionSelected().toString());
                if (checkAllQuestionSelected()) {
                  _globalState!.callbackButton();
                }
              });
            },
            items: aQuestion!.dropdownMenuList
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(fontSize: font_size)),
              );
            }).toList(),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 15,
        ),
        Divider(),
        SizedBox(
          width: double.infinity,
          height: 15,
        ),
      ],
    );
  }

  bool checkAllQuestionSelected() {
    bool allSelected = false;
    bool hasFalse = false;

    question.forEach((index, value) {
      if (value.response!.isEmpty) {
        hasFalse = true;
      }
    });

    if (hasFalse) {
      allSelected = false;
    } else {
      allSelected = true;
    }

    return allSelected;
  }
}

class CalculateMarker {
  double agePro = 0;
  double priorProb = 0;
  double ageLR = 0;
  double riskMarker = 0;
  double prodromalMarker = 0;
  double non_Motor_Marker = 0;
  double motorMarker = 0;
  double bioMarker = 0;

  double sexLR = 0;
  double PesticideLR = 0;
  double OccupationLR = 0;
  double CaffeineLR = 0;
  double SmokingLR = 0;
  double RelativeLR = 0;
  double GBALR = 0;
  double LRRK2LR = 0;
  double GBALR_Age = 1.0;
  double LRRK2LR_Age = 1.0;
  double GeneLR = 1.0;
  double PRSLR = 0;
  double HeriatageLR = 1.0;
  double HyperSNLR = 0;
  double DMIILR = 0;
  double Inactivity_LR = 0;
  double PUrate_LR = 0;

  double PSGLR = 0;
  double RBD_QLR = 0;
  double SomnolenceLR = 0;
  double HypotensionLR = 0;
  double HyposmiaLR = 0;
  double ConstipationLR = 0;
  double UrinationLR = 0;
  double EDLR = 0;
  double DepressionLR = 0;
  double DementiaLR = 0;
  double RSWALRm = 0;

  double UPDRS_IIILR = 0;
  double BradykinesiaLR = 0;
  double Motor_RiskLR = 0;

  double DaTLR = 0;

  double PLR = 0;
  double result0 = 0;
  double Preodds = 0;
  double Final_LR = 0;
  double Postodds = 0;
  double PostProb = 0;
  String PPPD = '';

  double get PriorProb {
    return priorProb;
  }

  double get RiskMarker {
    return riskMarker;
  }

  double get ProdromalMarker {
    return prodromalMarker;
  }

  double get Non_Motor_Marker {
    return non_Motor_Marker;
  }

  double get MotorMarker {
    return motorMarker;
  }

  double get BioMarker {
    return bioMarker;
  }

  void processingData() {
    agePro = 0;
    if (question[1]!.response.isNotEmpty) {
      agePro = question[1]!.response_val!;
      priorProb = agePro / (1 - agePro);
    }
    if (agePro == 0.004) {
      ageLR = 1000;
    } else if (agePro == 0.0075) {
      ageLR = 515;
    } else if (agePro == 0.0125) {
      ageLR = 300;
    } else if (agePro == 0.02) {
      ageLR = 180;
    } else if (agePro == 0.025) {
      ageLR = 155;
    } else if (agePro == 0.035) {
      ageLR = 110;
    } else if (agePro == 0.04) {
      ageLR = 95;
    }

    sexLR = question[2]!.response_val!;
    PesticideLR = question[3]!.response_val!;
    OccupationLR = question[4]!.response_val!;
    CaffeineLR = question[5]!.response_val!;
    SmokingLR = question[6]!.response_val!;
    RelativeLR = question[7]!.response_val!;
    GBALR = question[8]!.response_val!;
    LRRK2LR = question[9]!.response_val!;
    PRSLR = question[10]!.response_val!;
    HyperSNLR = question[11]!.response_val!;
    DMIILR = question[12]!.response_val!;
    Inactivity_LR = question[13]!.response_val!;
    PUrate_LR = question[14]!.response_val!;

    GBALR_Age = 1.0;
    LRRK2LR_Age = 1.0;

    if (agePro == 0.004 && GBALR == 20) {
      GBALR_Age = 20;
    } else if (agePro == 0.0075 && GBALR == 20) {
      GBALR_Age = 14.7;
    } else if (agePro == 0.0125 && GBALR == 20) {
      GBALR_Age = 11.2;
    } else if (agePro == 0.02 && GBALR == 20) {
      GBALR_Age = 9;
    } else if (agePro == 0.025 && GBALR == 20) {
      GBALR_Age = 8.4;
    } else if (agePro == 0.035 && GBALR == 20) {
      GBALR_Age = 7.1;
    } else if (agePro == 0.04 && GBALR == 20) {
      GBALR_Age = 7.5;
    }

    if (agePro == 0.004 && LRRK2LR == 2.5) {
      LRRK2LR_Age = 2.5;
    } else if (agePro == 0.0075 && LRRK2LR == 2.5) {
      LRRK2LR_Age = 4;
    } else if (agePro == 0.0125 && LRRK2LR == 2.5) {
      LRRK2LR_Age = 5.6;
    } else if (agePro == 0.02 && LRRK2LR == 2.5) {
      LRRK2LR_Age = 7.5;
    } else if (agePro == 0.025 && LRRK2LR == 2.5) {
      LRRK2LR_Age = 11.6;
    } else if (agePro == 0.035 && LRRK2LR == 2.5) {
      LRRK2LR_Age = 9.1;
    } else if (agePro == 0.04 && LRRK2LR == 2.5) {
      LRRK2LR_Age = 10.5;
    }

    GeneLR = GBALR_Age * LRRK2LR_Age;
    HeriatageLR = 1;

    PSGLR = question[15]!.response_val!;
    RBD_QLR = question[17]!.response_val!;
    SomnolenceLR = question[18]!.response_val!;
    HypotensionLR = question[24]!.response_val!;
    HyposmiaLR = question[19]!.response_val!;
    ConstipationLR = question[20]!.response_val!;
    UrinationLR = question[21]!.response_val!;
    EDLR = question[22]!.response_val!;
    DepressionLR = question[25]!.response_val!;
    DementiaLR = question[26]!.response_val!;
    RSWALRm = math.max(RBD_QLR, PSGLR);

    UPDRS_IIILR = question[27]!.response_val!;
    BradykinesiaLR = question[28]!.response_val!;
    Motor_RiskLR = math.max(UPDRS_IIILR, BradykinesiaLR);
    motorMarker = Motor_RiskLR;

    DaTLR = question[29]!.response_val!;
    bioMarker = DaTLR;

    if (RelativeLR > 1 || PRSLR > 1 || GeneLR > 1) {
      HeriatageLR = math.max(RelativeLR, math.max(PRSLR, GeneLR));
    }
    if (RelativeLR < 1.1 && PRSLR < 1.0 && GeneLR == 1) {
      HeriatageLR = math.min(RelativeLR, math.min(PRSLR, GeneLR));
    }

    if (UPDRS_IIILR < 1.1 && BradykinesiaLR < 1.1) {
      Motor_RiskLR = math.min(UPDRS_IIILR, BradykinesiaLR);
      motorMarker = Motor_RiskLR;
    }

    if (PSGLR < 1.1 && RBD_QLR < 1.1) {
      RSWALRm = math.min(RBD_QLR, PSGLR);
    }

    non_Motor_Marker = RSWALRm *
        SomnolenceLR *
        HypotensionLR *
        HyposmiaLR *
        ConstipationLR *
        UrinationLR *
        EDLR *
        DepressionLR *
        DementiaLR;
    riskMarker = sexLR *
        PesticideLR *
        OccupationLR *
        CaffeineLR *
        SmokingLR *
        HeriatageLR *
        HyperSNLR *
        DMIILR *
        Inactivity_LR *
        PUrate_LR;
    prodromalMarker = RSWALRm *
        DaTLR *
        Motor_RiskLR *
        HyposmiaLR *
        ConstipationLR *
        SomnolenceLR *
        HypotensionLR *
        EDLR *
        UrinationLR *
        DepressionLR *
        DementiaLR;
    PLR = ageLR;
    result0 = sexLR *
        PesticideLR *
        OccupationLR *
        CaffeineLR *
        SmokingLR *
        HeriatageLR *
        HyperSNLR *
        DMIILR *
        Inactivity_LR *
        PUrate_LR *
        RSWALRm *
        DaTLR *
        Motor_RiskLR *
        HyposmiaLR *
        ConstipationLR *
        SomnolenceLR *
        HypotensionLR *
        EDLR *
        UrinationLR *
        DepressionLR *
        DementiaLR;
    Preodds = PriorProb;
    Final_LR = sexLR *
        PesticideLR *
        OccupationLR *
        CaffeineLR *
        SmokingLR *
        HeriatageLR *
        DMIILR *
        Inactivity_LR *
        PUrate_LR *
        HyperSNLR *
        RSWALRm *
        DaTLR *
        Motor_RiskLR *
        HyposmiaLR *
        ConstipationLR *
        SomnolenceLR *
        HypotensionLR *
        EDLR *
        UrinationLR *
        DepressionLR *
        DementiaLR;
    Postodds = Preodds * Final_LR;
    PostProb = (Postodds / (1 + Postodds));

    if (ageLR > Final_LR) {
      PPPD = "極低";
    } else if (ageLR == Final_LR) {
      PPPD = "可能患有";
    } else if (ageLR < Final_LR) {
      PPPD = "偏高";
    }
  }
}
