import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pd_app/api/LoginService.dart';
import 'package:pd_app/api/PatientService.dart';
import 'package:pd_app/model/Patient.dart';
import 'package:pd_app/prefs/SessionPrefs.dart';
import 'package:pd_app/ui/login/CreateNewUserPage.dart';
import 'package:pd_app/ui/patient/list/MedicalStaffLoginPage.Dart';
import 'package:pd_app/ui/patient/action/PatientActionPage.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/userinfo.email'
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        // appBar: AppBar(
        //   title: const Text("Login"),
        // ),
        body: SafeArea(
        child: Container(
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
              decoration: const BoxDecoration(
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
                      labelStyle: TextStyle(fontSize: 28),
                    )),
              ),
              Container(
                margin:
                const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                child: TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: '輸入 密碼',
                        labelStyle: TextStyle(fontSize: 28)),
                    obscureText: true

                ),


              ),
              Container(
                  margin:
                  const EdgeInsets.only(left: 100.0, right: 100.0, top: 20.0),
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
                                .headlineMedium,
                          )))),

              Container(
                  margin:
                  const EdgeInsets.only(left: 100.0, right: 100.0, top: 5.0),
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () {
                        gotoSignUpPage();
                      },
                      child: Container(
                          padding:
                          const EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: Text(
                            '註冊帳號',
                            style: Theme
                                .of(context)
                                .textTheme
                                .headlineMedium,
                          )))),
            //
            //   Row(children: <Widget>[
            //   Expanded(
            //     child: Container(
            //         margin: const EdgeInsets.only(left: 10.0, right: 20.0),
            //         child: const Divider(
            //           color: Colors.black,
            //           height: 36,
            //         )),
            //   ),
            //   const Text("或是"),
            //   Expanded(
            //     child: Container(
            //         margin: const EdgeInsets.only(left: 20.0, right: 10.0),
            //         child: const Divider(
            //           color: Colors.black,
            //           height: 36,
            //         )),
            //   ),
            // ]),
            //   Container(
            //       margin:
            //       const EdgeInsets.only(left: 100.0, right: 100.0, top: 10.0),
            //       padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
            //       width: double.infinity,
            //       child: ElevatedButton(
            //           onPressed: () {
            //             _handleSignIn();
            //           },
            //           style: ButtonStyle(
            //             backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFEB4033)), // Set the background color
            //             // You can customize other button properties here
            //           ),
            //           child: Container(
            //               padding:
            //               const EdgeInsets.only(top: 10.0, bottom: 10.0),
            //               child: Text(
            //                 'Google 登入',
            //                 style: Theme
            //                     .of(context)
            //                     .textTheme
            //                     .titleLarge,
            //               )))),
              Container(
                  margin:
                  const EdgeInsets.only(left: 100.0, right: 100.0, top: 20.0),
                  padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () {
                        gotoMedicalStaffLogin();
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue), // Set the background color
                        // You can customize other button properties here
                      ),
                      child: Container(
                          padding:
                          const EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: Text(
                            '醫療人員登入',
                            style: Theme
                                .of(context)
                                .textTheme
                                .headlineSmall,
                          )))),
            ],
          ),
        ),
        ),
        )
    );
  }

  Future<void> login(String username, String password) async {
    var session = await LoginService.login(username, password);
    SessionPrefs.save(session);

    var patient = await PatientService.getPatientData(username);
    gotoUserPage(patient);
  }

  Future<void> _handleSignIn() async {
    try {
      var account = await _googleSignIn.signIn();
      var authentication = await account?.authentication;
      var token = authentication?.accessToken;
      var session = await LoginService.google_login(token!);
      SessionPrefs.save(session);
      String username = session.username;
      var patient = await PatientService.getPatientData(username);
      gotoUserPage(patient);
    } catch (error) {
      print(error);
    }
  }

  void gotoSignUpPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateNewUserPage()));
  }

  void gotoMedicalStaffLogin() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MedicalStaffLoginPage(title: 'NTUH Staff Login')));
  }

  void gotoUserPage(Patient patient) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => PatientActionPage(patient: patient)));
  }
}
