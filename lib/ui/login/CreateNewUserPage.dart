import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pd_app/api/UploadService.dart';
import 'package:pd_app/ui/login/LoginPage.dart';


class CreateNewUserPage extends StatefulWidget {

  const CreateNewUserPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateNewUserPageState();
}


class _CreateNewUserPageState extends State<CreateNewUserPage> {

  final TextEditingController patientNameController = TextEditingController();
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
    usernameInput.text = "" ;
    userpasswordInput.text = "" ;
    ageInput.text = "";
    emailInput.text = "";
    patientNameController.text = "";
    dateInput.text = "";
    phoneNumInput.text = '';
    idNumInput.text = '';
    _isButtonDisabled = true;
    super.initState();
  }

  String? get _errorTextPhoneNo{
    final phoneNumText = phoneNumInput.value.text;
    if(phoneNumText.isEmpty){
      return '請輸入電話號碼';
    }
    return null;
  }


  String? get _errorTextIDNo{
    final idNumText = idNumInput.value.text;
    if(idNumText.isEmpty){
      return '請輸入身分證字號';
    }
    Map<String, int> cityMap = {
      'A': 10, 'B': 11, 'C': 12, 'D': 13, 'E': 14, 'F': 15,
      'G': 16, 'H': 17, 'I': 34, 'J': 18, 'K': 19, 'L': 20,
      'M': 21, 'N': 22, 'O': 35, 'P': 23, 'Q': 24, 'R': 25,
      'S': 26, 'T': 27, 'U': 28, 'V': 29, 'W': 32, 'X': 30,
      'Y': 31, 'Z': 33
    };

    if (idNumText.length != 10) {
      return "身分證字號長度不正確";
    }

    String firstChar = idNumText.substring(0, 1);
    if (!cityMap.containsKey(firstChar)) {
      return "第一個字號必須為 A-Z.";
    }

    int genderCode = int.parse(idNumText.substring(1, 2));
    if (genderCode != 1 && genderCode != 2) {
      return "第二個字必須為 1 或 2" ;
    }

    int totalSum = 0;
    totalSum += (cityMap[firstChar]! ~/ 10) + (cityMap[firstChar]! % 10) * 9;
    totalSum += genderCode * 8;
    for (int i = 2; i <= 8; i++) {
      int digit = int.parse(idNumText.substring(i, i + 1));
      totalSum += digit * (9 - i);
    }
    totalSum += int.parse(idNumText.substring(9, 10));

    if (totalSum % 10 != 0) {
      return "字號錯誤請重新輸入!";
    }
    return null;
  }


  String? get _errorTextUserName{
    final usernameText = usernameInput.value.text;
    if(usernameText.isEmpty){
      return '請輸入使用者名字';
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

  String? get _errorTextName{
    final name_text = patientNameController.value.text;
    if(name_text.isEmpty){
      return '請輸入名字';
    }
    return null;
  }

  Text? get _errorTexGender{
    if(gender.isEmpty){
      return const Text('請選擇性別',  style: TextStyle(color: Colors.red,),);
    }
    return null;
  }

  String? get _errorTextAge{
    final age_text = ageInput.value.text;
    if(age_text.isEmpty){
      return '請輸入年齡';
    }
    return null;
  }

  String? get _errorTextBirthday{
    final date_text = dateInput.value.text;
    if(date_text.isEmpty){
      return '請選擇出生日期';
    }
    return null;
  }

  void checkAllRequiredValueFilled(){
    final name_text = patientNameController.value.text;
    final age_text = ageInput.value.text;
    final date_text = dateInput.value.text;
    final username = usernameInput.value.text;
    final userpassword = userpasswordInput.value.text;
    final phoneNum = phoneNumInput.value.text;
    final idNum = idNumInput.value.text;

    //if(name_text.isNotEmpty && gender.isNotEmpty && age_text.isNotEmpty && date_text.isNotEmpty){
    if(name_text.isNotEmpty && gender.isNotEmpty && date_text.isNotEmpty && username.isNotEmpty && userpassword.isNotEmpty && phoneNum.isNotEmpty && idNum.isNotEmpty){
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
          title: const Text("註冊"),
        ),
        body: Container(
          decoration: const BoxDecoration(
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
                const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),
                child: TextField(
                  controller: usernameInput,
                  decoration: InputDecoration(
                    border:  const UnderlineInputBorder(),
                    labelText: '使用者名稱',
                    labelStyle: const TextStyle(fontSize: 24, color: Colors.black54),
                    errorText: _errorTextUserName,
                    errorStyle: const TextStyle(fontSize: 14), // Custom error text style
                    contentPadding: const EdgeInsets.only(bottom: 8),
                    errorMaxLines: 2,
                    errorBorder: _errorTextUserName != null
                        ? const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    )
                        : null,
                    focusedErrorBorder: _errorTextUserName != null
                        ? const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    )
                        : null,

                  ),
                  onChanged: (text) => setState(() => checkAllRequiredValueFilled()),
                ),
              ),

              Container(
                margin:
                const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),
                child: TextField(
                  controller: userpasswordInput,

                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: '密碼',
                    labelStyle: const TextStyle(fontSize: 24, color: Colors.black54),
                    errorText: _errorTextUserPassword,
                    errorStyle: const TextStyle(fontSize: 14), // Custom error text style
                    contentPadding: const EdgeInsets.only(bottom: 8),
                    errorBorder: _errorTextUserName != null
                        ? const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    )
                        : null,
                    focusedErrorBorder: _errorTextUserName != null
                        ? const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    )
                        : null,
                  ),
                  onChanged: (text) => setState(() => checkAllRequiredValueFilled()),
                ),
              ),

              Container(
                margin:
                const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),
                child: TextField(
                    controller: patientNameController,

                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      labelText: '姓名',
                      labelStyle: const TextStyle(fontSize: 24, color: Colors.black54),
                      errorText: _errorTextName,
                      errorStyle: const TextStyle(fontSize: 14), // Custom error text style
                      contentPadding: const EdgeInsets.only(bottom: 8),
                      errorBorder: _errorTextUserName != null
                          ? const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      )
                          : null,
                      focusedErrorBorder: _errorTextUserName != null
                          ? const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      )
                          : null,
                    ),
                    onChanged: (text) => setState(() => checkAllRequiredValueFilled()),
                  ),
              ),

              Align(
                  alignment: Alignment.centerLeft,
                child: Container(
                  margin:
                  const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),

                  child: const Text(
                  "您的性別",
                  style: TextStyle(fontSize: 24, color: Colors.black54),
                ),
              )),

              const Divider(),


            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),
                child: Row(
                  children: [
                    Row(
                      children: [
                        Radio<String>(
                          value: "1",
                          groupValue: gender,
                          onChanged: (value) {
                            setState(() {
                              gender = value.toString();
                              checkAllRequiredValueFilled();
                            });
                          },
                        ),
                        const Text("男", style: TextStyle(fontSize: 24,
                            color: Colors.black54)),
                      ],
                    ),

                    Row(
                      children: [
                        Radio<String>(
                          value: "2",
                          groupValue: gender,
                          onChanged: (value) {
                            setState(() {
                              gender = value.toString();
                              checkAllRequiredValueFilled();
                            });
                          },
                        ),
                        const Text("女", style: TextStyle(fontSize: 24,
                            color: Colors.black54)),
                      ],
                    ),
                  ],
              ))),


              Container(
                margin:
                const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),
                child: TextField(
                  controller: phoneNumInput,

                  decoration: InputDecoration(
                    border:  const UnderlineInputBorder(),
                    labelText: '電話號碼',
                    labelStyle: const TextStyle(fontSize: 24, color: Colors.black54),
                    errorText: _errorTextPhoneNo,
                    errorStyle: const TextStyle(fontSize: 14), // Custom error text style
                    contentPadding: const EdgeInsets.only(bottom: 8),
                    errorBorder: _errorTextUserName != null
                        ? const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    )
                        : null,
                    focusedErrorBorder: _errorTextUserName != null
                        ? const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    )
                        : null,
                  ),
                  onChanged: (text) => setState(() => checkAllRequiredValueFilled()),
                ),
              ),

              Container(
                margin:
                const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),
                child: TextField(
                  controller: idNumInput,

                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: '身分證字號',
                    labelStyle: const TextStyle(fontSize: 24, color: Colors.black54),
                    errorText: _errorTextIDNo,
                    errorStyle: const TextStyle(fontSize: 14), // Custom error text style
                    contentPadding: const EdgeInsets.only(bottom: 8),
                    errorBorder: _errorTextUserName != null
                        ? const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    )
                        : null,
                    focusedErrorBorder: _errorTextUserName != null
                        ? const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    )
                        : null,
                  ),
                  onChanged: (text) => setState(() => checkAllRequiredValueFilled()),
                ),
              ),

            Container(
              margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),

              child: TextField(
              controller: dateInput,
              //editing controller of this TextField
              decoration: InputDecoration(
                  icon: const Icon(Icons.calendar_today), //icon of text field
                  labelText: "生日",
                  labelStyle: const TextStyle(fontSize: 24, color: Colors.black54),//label text of field
                  errorText: _errorTextBirthday,
                  errorStyle: const TextStyle(fontSize: 14), // Custom error text style
                  contentPadding: const EdgeInsets.only(bottom: 8),
                  errorBorder: _errorTextUserName != null
                      ? const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  )
                      : null,
                  focusedErrorBorder: _errorTextUserName != null
                      ? const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2),
                  )
                      : null,
                  ),
              readOnly: true,
              onChanged: (text) => setState(() => checkAllRequiredValueFilled()),
              //set it true, so that user will not able to edit text
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    //DateTime.now() - not to allow to choose before today.
                    lastDate: DateTime.now());

                if (pickedDate != null) {
                  print(
                      pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                  String formattedDate =
                      DateFormat('yyyy-MM-dd').format(pickedDate);
                  print(
                      formattedDate); //formatted date output using intl package =>  2021-03-16
                  //print('ageCal: '+ calculateAge(pickedDate).toString());
                  age = calculateAge(pickedDate).toString();
                  setState(() {
                    dateInput.text = formattedDate; //set output date to TextField value.
                    checkAllRequiredValueFilled();
                  });
                }
                else {}
              },
            )),

              Container(
               margin:
                const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),
                child: TextField(
                    controller: emailInput,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Email',
                      labelStyle: TextStyle(fontSize: 24, color: Colors.black54),
                    )),
            ),

            Container(
                  margin:
                  const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),
                  padding: const EdgeInsets.only(top: 20.0, bottom: 5.0),
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: _isButtonDisabled ? null : () {
                        // UploadService.createNewPatient(patientNameController.text, gender, ageInput.text);
                        //print(patientNameController.text + ', ' + gender.toString() + ', ' + ageInput.text + ', ' + dateInput.text + ', ' + emailInput.text);
                        //UploadService.createNewPatient(patientNameController.text, gender, ageInput.text, dateInput.text, emailInput.text);
                        createNewPatient();
                        createNewUser();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage(title: "NTU PD")));
                        //Navigator.popUntil(context, ModalRoute.withName('/'));
                        //Navigator.popUntil(context, ModalRoute.withName('/'));
                      },
                      child: Container(
                          padding:
                          const EdgeInsets.only(top: 10.0, bottom: 5.0),
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
        response = await UploadService.createNewPatient(patientNameController.text,
            usernameInput.text, gender, age, dateInput.text, emailInput.text, phoneNumInput.text, idNumInput.text);
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