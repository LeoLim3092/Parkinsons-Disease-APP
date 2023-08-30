// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:pd_app/api/LoginService.dart';
// import 'package:pd_app/model/Session.dart';
// import 'package:pd_app/prefs/SessionPrefs.dart';
// import 'package:pd_app/ui/patient/list/PatientListPage.dart';
// import 'package:http/http.dart' as http;
//
//
// class MedicalStaffLoginPage extends StatefulWidget {
//   const MedicalStaffLoginPage({Key? key, required this.title}) : super(key: key);
//   final String title;
//
//   @override
//   State<MedicalStaffLoginPage> createState() => _MedicalStaffLoginPageState();
// }
//
// class _MedicalStaffLoginPageState extends State<MedicalStaffLoginPage> {
//   final TextEditingController usernameController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   GoogleSignIn _googleSignIn = GoogleSignIn(
//     scopes: [
//       'https://www.googleapis.com/auth/userinfo.email'
//     ],
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         // appBar: AppBar(
//         //   title: const Text("Login"),
//         // ),
//         body: Container(
//         // decoration: BoxDecoration(
//         // image: DecorationImage(
//         //   image: AssetImage("assets/images/wallpaper.png"),
//         //   fit: BoxFit.cover,
//         //   ),
//         // ),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//                 Container(
//               width: 190, // Adjust the width and height according to your needs
//               height: 92,
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage('assets/images/login.png'), // Replace with your image path
//                   fit: BoxFit.cover,
//                        ),),
//               ),
//               Container(
//                 margin:
//                 const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
//                 child: TextField(
//                     controller: usernameController,
//                     decoration: const InputDecoration(
//                       border: UnderlineInputBorder(),
//                       labelText: '輸入 帳號',
//                     )),
//               ),
//               Container(
//                 margin:
//                 const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
//                 child: TextField(
//                     controller: passwordController,
//                     decoration: const InputDecoration(
//                         border: UnderlineInputBorder(),
//                         labelText: '輸入 密碼'),
//                     obscureText: true
//                 ),
//
//
//               ),
//               Container(
//                   margin:
//                   const EdgeInsets.only(left: 150.0, right: 150.0, top: 20.0),
//                   padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
//                   width: double.infinity,
//                   child: ElevatedButton(
//                       onPressed: () {
//                         login(usernameController.text, passwordController.text);
//                       },
//                       child: Container(
//                           padding:
//                           const EdgeInsets.only(top: 10.0, bottom: 10.0),
//                           child: Text(
//                             '登錄',
//                             style: Theme
//                                 .of(context)
//                                 .textTheme
//                                 .headline6,
//                           )))),
//
//               Row(children: <Widget>[
//               Expanded(
//                 child: new Container(
//                     margin: const EdgeInsets.only(left: 10.0, right: 20.0),
//                     child: Divider(
//                       color: Colors.black,
//                       height: 36,
//                     )),
//               ),
//               Text("或是"),
//               Expanded(
//                 child: new Container(
//                     margin: const EdgeInsets.only(left: 20.0, right: 10.0),
//                     child: Divider(
//                       color: Colors.black,
//                       height: 36,
//                     )),
//               ),
//             ]),
//               Container(
//                   margin:
//                   const EdgeInsets.only(left: 100.0, right: 100.0, top: 10.0),
//                   padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
//                   width: double.infinity,
//                   child: ElevatedButton(
//                       onPressed: () {
//                         _handleSignIn();
//                       },
//                       style: ButtonStyle(
//                         backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFEB4033)), // Set the background color
//                         // You can customize other button properties here
//                       ),
//                       child: Container(
//                           padding:
//                           const EdgeInsets.only(top: 10.0, bottom: 10.0),
//                           child: Text(
//                             'Google 登入',
//                             style: Theme
//                                 .of(context)
//                                 .textTheme
//                                 .headline6,
//                           )))),
//             ],
//           ),
//         ),
//         ),
//     );
//   }
//
//   Future<void> login(String username, String password) async {
//     var session = await LoginService.staffLogin(username, password);
//
//     SessionPrefs.save(session);
//     gotoPatientListPage();
//   }
//
//   Future<void> _handleSignIn() async {
//     try {
//       var account = await _googleSignIn.signIn();
//       var authentication = await account?.authentication;
//       var token = authentication?.accessToken;
//       var session = await LoginService.google_login(token!);
//       SessionPrefs.save(session);
//       gotoPatientListPage();
//     } catch (error) {
//       print(error);
//     }
//   }
//
//   void gotoPatientListPage() {
//     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => PatientListPage()));
//   }
// }
