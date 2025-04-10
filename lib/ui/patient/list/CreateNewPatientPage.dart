import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pd_app/model/Patient.dart';
import 'package:pd_app/ui/patient/gesture/GestureRecordingPageLeft.dart';
import 'package:pd_app/ui/patient/sound_recording/SoundRecordingPage.dart';
import 'package:pd_app/ui/patient/walk/WalkRecordingPage.dart';
import 'package:intl/intl.dart';
import 'package:pd_app/api/UploadService.dart';


class CreateNewPatientPage extends StatefulWidget {

  const CreateNewPatientPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateNewPatientPageState();
}


class _CreateNewPatientPageState extends State<CreateNewPatientPage> {

  TextEditingController ageInput = TextEditingController();
  TextEditingController dateInput = TextEditingController();
  TextEditingController emailInput = TextEditingController();
  TextEditingController usernameInput = TextEditingController();
  TextEditingController userpasswordInput = TextEditingController();
  TextEditingController phoneNumInput = TextEditingController();
  TextEditingController idNumInput = TextEditingController();
  String gender = '';
  String age = '';
  bool _isButtonDisabled = true;

  @override
  void initState() {
    usernameInput.text = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    userpasswordInput.text = "test1111" ;
    emailInput.text = "";
    dateInput.text = "";
    _isButtonDisabled = true;
    phoneNumInput.text = '';
    idNumInput.text = '';
    super.initState();
  }

  String? get _errorTextUserName{
    final usernameText = usernameInput.value.text;
    if(usernameText.isEmpty){
      return '病人流水号';
    }
    return null;
  }

  String? get _errorTextUserPassword{
    final userpasswordText = userpasswordInput.value.text;
    if(userpasswordText.isEmpty){
      return '請輸入密碼';
    }
    return null;
  }

  Text? get _errorTexGender{
    if(gender.isEmpty){
      return Text('請選擇性別',  style: TextStyle(color: Colors.red,),);
    }
    return null;
  }

  String? get _errorTextBirthday{
    final date_text = dateInput.value.text;
    if(date_text.isEmpty){
      return '出生日期';
    }
    return null;
  }

  void checkAllRequiredValueFilled(){
    
    final age_text = ageInput.value.text;
    final date_text = dateInput.value.text;
    final username = usernameInput.value.text;
    final userpassword = userpasswordInput.value.text;
    final name_text = username;

    //if(name_text.isNotEmpty && gender.isNotEmpty && age_text.isNotEmpty && date_text.isNotEmpty){
    if(name_text.isNotEmpty && gender.isNotEmpty && date_text.isNotEmpty && username.isNotEmpty && userpassword.isNotEmpty){
      //setState(() {
        _isButtonDisabled = false;
      //});
    }
    print(_isButtonDisabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("增加新病人以及註冊"),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/wallpaper.png"), // Replace with the path to your wallpaper image
              fit: BoxFit.cover,
            ),
          ),

        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin:
                const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                child: TextField(
                  controller: usernameInput,

                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '使用者名稱',
                    errorText: _errorTextUserName,
                  ),
                  onChanged: (text) => setState(() => checkAllRequiredValueFilled()),
                ),
              ),

              Container(
                margin:
                const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                child: TextField(
                  controller: userpasswordInput,

                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '密碼',
                    errorText: _errorTextUserPassword,
                  ),
                  onChanged: (text) => setState(() => checkAllRequiredValueFilled()),
                ),
              ),

              Text("您的性別", style: TextStyle( fontSize: 18),textAlign: TextAlign.justify),
              Divider(),

              RadioListTile(
                    title: Text("男"),
                    value: "1",
                    groupValue: gender,
                    subtitle: _errorTexGender,
                    onChanged: (value){
                        setState(() {
                        gender = value.toString();
                        checkAllRequiredValueFilled();
                    });
                    },
              ),

              RadioListTile(
                    title: Text("女"),
                    value: "2",
                    groupValue: gender,
                    subtitle: _errorTexGender,
                    onChanged: (value){
                        setState(() {
                        gender = value.toString();
                        checkAllRequiredValueFilled();
                    });
                    },
              ),

            Container(
              margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
              child: TextField(
                controller: dateInput,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "生日", // Label text for the field
                  errorText: _errorTextBirthday,
                ),
                onChanged: (text) {
                  setState(() {
                    checkAllRequiredValueFilled();
                    try {
                      // Try to parse the input text into a DateTime object
                      DateTime parsedDate = DateFormat('yyyy/MM/dd').parse(text);
                      age = calculateAge(parsedDate).toString(); // Calculate age
                    } catch (e) {
                      // Handle invalid date format
                      print("Invalid date format: $e");
                    }
                  });
                },
              ),
            ),

            Container(
               margin:
                const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                child: TextField(
                    controller: emailInput,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Email',
                    )),
            ),

            Container(
                  margin:
                  const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                  padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: _isButtonDisabled ? null : () {
                        // UploadService.createNewPatient(patientNameController.text, gender, ageInput.text);
                        //print(patientNameController.text + ', ' + gender.toString() + ', ' + ageInput.text + ', ' + dateInput.text + ', ' + emailInput.text);
                        //UploadService.createNewPatient(patientNameController.text, gender, ageInput.text, dateInput.text, emailInput.text);
                        createNewPatient();
                        createNewUser();
                        Navigator.pop(context);
                        //Navigator.popUntil(context, ModalRoute.withName('/'));
                      },
                      child: Container(
                          padding:
                          const EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: Text(
                            '新增',
                            style: Theme
                                .of(context)
                                .textTheme
                                .headlineSmall,
                          )))
                  ),

            ],
          ),
        )));
    }

    calculateAge(DateTime birthDate) {
      DateTime currentDate = DateTime.now();
      int age = currentDate.year - birthDate.year;
      int month1 = currentDate.month;
      int month2 = birthDate.month;

      if (month2 > month1) {
        age--;
      } else if (month1 == month2) {
        int day1 = currentDate.day;
        int day2 = birthDate.day;
        if (day2 > day1) {
          age--;
        }
      }

      return age;
    }

    Future<void> createNewPatient() async {
      var response;
      try{
        //await UploadService.createNewPatient(patientNameController.text, gender, ageInput.text, dateInput.text, emailInput.text);
        response = await UploadService.createNewPatient(usernameInput.text, usernameInput.text, gender, age, dateInput.text, emailInput.text, phoneNumInput.text, idNumInput.text);
        //print('upload');
        // Navigator.popUntil(context, ModalRoute.withName('/'));
      }catch(error){
        print('uploadError:' + error.toString());
      }

      return response;
    }

  Future<void> createNewUser() async {
    var response;
    try{
      response = await UploadService.createNewUser(usernameInput.text, userpasswordInput.text, emailInput.text);

    }catch(error){
      print('uploadError:' + error.toString());
    }

    return response;
  }
}