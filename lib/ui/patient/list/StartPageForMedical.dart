import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:pd_app/model/Patient.dart';

import 'package:pd_app/ui/patient/action/PatientActionPage.dart';
import 'package:pd_app/ui/patient/walk/WalkRecordingPage.dart';

class StartPageForMedical extends StatelessWidget {
  final Patient patient;

  const StartPageForMedical({Key? key, required this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${patient.name ?? ""} 的 Start Page",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.green],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/APP001.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  // Navigate to next step/page
                  gotoWalkPage(context, patient);
                },

                child: Image.asset(
                  "assets/images/APP_start.png", // Replace with your "Start" button image
                  width: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  // Navigate back to main menu
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => PatientActionPage(patient: patient)),
                  );
                },
                child: Image.asset(
                  "assets/images/APP_home.png", // Replace with your "Main Menu" button image
                  width: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void gotoWalkPage(BuildContext context, Patient patient) {
    EasyLoading.show(status: 'start camera');
    availableCameras().then((cameras) {
      EasyLoading.dismiss();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => WalkRecordingPage(
          cameras: cameras,
          patient: patient,
        ),
      ));
    });
  }

}
