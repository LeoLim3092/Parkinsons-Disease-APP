import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pd_app/api/LoginService.dart';
import 'package:pd_app/model/Session.dart';
import 'package:pd_app/prefs/SessionPrefs.dart';
import 'package:pd_app/ui/patient/list/PatientListPage.dart';
import 'package:http/http.dart' as http;


class MedicalStaffLoginPage extends StatefulWidget {
  const MedicalStaffLoginPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MedicalStaffLoginPage> createState() => _MedicalStaffLoginPageState();
}

class _MedicalStaffLoginPageState extends State<MedicalStaffLoginPage> {
  final TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/userinfo.email'
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text("Login"),
        // ),
        body: Container(
        // decoration: BoxDecoration(
        // image: DecorationImage(
        //   image: AssetImage("assets/images/wallpaper.png"),
        //   fit: BoxFit.cover,
        //   ),
        // ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                Container(
              width: 190, // Adjust the width and height according to your needs
              height: 92,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/login.png'), // Replace with your image path
                  fit: BoxFit.cover,
                       ),),
              ),
              Container(
                margin:
                const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                child: TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: '輸入 帳號',
                    )),
              ),
              Container(
                margin:
                const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                child: TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: '輸入 密碼'),
                    obscureText: true
                ),


              ),
              Container(
                  margin:
                  const EdgeInsets.only(left: 150.0, right: 150.0, top: 20.0),
                  padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () {
                        login(usernameController.text, passwordController.text);
                      },
                      child: Container(
                          padding:
                          const EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: Text(
                            '登錄',
                            style: Theme
                                .of(context)
                                .textTheme
                                .headlineSmall,
                          )))),
            ],
          ),
        ),
        ),
    );
  }

  Future<void> login(String username, String password) async {
    var session = await LoginService.staffLogin(username, password);

    SessionPrefs.save(session);
    gotoPatientListPage();
  }

  Future<void> _handleSignIn() async {
    try {
      var account = await _googleSignIn.signIn();
      var authentication = await account?.authentication;
      var token = authentication?.accessToken;
      gotoPatientListPage();
    } catch (error) {
      print(error);
    }
  }

  void gotoPatientListPage() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => PatientListPage()));
  }
}
