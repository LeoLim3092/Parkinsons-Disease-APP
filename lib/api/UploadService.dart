import 'dart:io';
import 'dart:convert';
import 'package:pd_app/Constants.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:pd_app/prefs/SessionPrefs.dart';


bool hasContent(String filePath) {
  var file = File(filePath);
  var fileSize = file.lengthSync();
  return fileSize > 0;
}


class UploadService {
  static Future<http.StreamedResponse> uploadSoundRecording(String pid, String filePath) async {
    var url = Uri.http(Constants.BASE_HOST, "api/upload_sound_record");
    var request = http.MultipartRequest("POST", url);
    var session = await SessionPrefs.getSession();
    request.headers['Authorization'] = "Bearer ${session!.access}";
    request.fields['pid'] = pid;
    var file = File(filePath);
    var fileSize = file.lengthSync();
    print("file size: $fileSize bytes");
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      filePath,
      contentType: MediaType("audio", "aac")
    ));
    return request.send();
  }

  static Future<http.StreamedResponse> uploadWalkRecording(String pid, String filePath) async {
    var url = Uri.http(Constants.BASE_HOST, "api/upload_walk_record");
    var request = http.MultipartRequest("POST", url);
    var session = await SessionPrefs.getSession();
    request.headers['Authorization'] = "Bearer ${session!.access}";
    request.fields['pid'] = pid;
    request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType("video", "mp4")
    ));
    return request.send();
  }

  static Future<http.StreamedResponse> uploadGestureRecording(String pid, String filePath, String type) async {
    var url = Uri.http(Constants.BASE_HOST, "api/upload_gesture_record");
    var request = http.MultipartRequest("POST", url);
    var session = await SessionPrefs.getSession();
    request.headers['Authorization'] = "Bearer ${session!.access}";
    request.fields['pid'] = pid;
    request.fields['type'] = type;
    request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType("video", "mp4")
    ));
    return request.send();
  }

  static Future<http.StreamedResponse> uploadMedicineRecord(String pid, String medicine, String medicine_3hr) async {
    var url = Uri.http(Constants.BASE_HOST, "api/upload_medicine_record");
    var request = http.MultipartRequest("POST", url);
    var session = await SessionPrefs.getSession();
    request.headers['Authorization'] = "Bearer ${session!.access}";
    request.fields['pid'] = pid;
    request.fields['medicine'] = medicine;
    request.fields['medicine_3hr'] = medicine_3hr;
    return request.send();
  }

  static Future<http.StreamedResponse> uploadExerciseRecord(String pid, String exercise) async {
    var url = Uri.http(Constants.BASE_HOST, "api/upload_exercise_record");
    var request = http.MultipartRequest("POST", url);
    var session = await SessionPrefs.getSession();
    request.headers['Authorization'] = "Bearer ${session!.access}";
    request.fields['pid'] = pid;
    request.fields['exercise'] = exercise;
    return request.send();
  }

  static Future<http.StreamedResponse> uploadPaint(String pid, File value, String type, List<List<Map<String, double>>> coordinates) async {
    var url = Uri.http(Constants.BASE_HOST, "api/upload_paint");
    var request = http.MultipartRequest("POST", url);
    var session = await SessionPrefs.getSession();
    request.headers['Authorization'] = "Bearer ${session!.access}";
    request.fields['pid'] = pid;
    request.fields['type'] = type;
    request.files.add(await http.MultipartFile.fromPath(
        'file',
        value.path,
        contentType: MediaType("image", "png")
    ));
    request.fields['coordinates'] = jsonEncode(coordinates); // Add coordinates to the request

    return request.send();
  }

  static Future<http.StreamedResponse> uploadQuestion(String pid, double riskMarker, double PLR, double TELR, double PostProb, String PPPD, String response) async {
    var url = Uri.http(Constants.BASE_HOST, "api/upload_questionaire_record");
    var request = http.MultipartRequest("POST", url);
    var session = await SessionPrefs.getSession();
    request.headers['Authorization'] = "Bearer ${session!.access}";
    request.fields['pid'] = pid;
    request.fields['riskMarker'] = riskMarker.toString();
    request.fields['PLR'] = PLR.toString();
    request.fields['TELR'] = TELR.toString();
    request.fields['PostProb'] = PostProb.toString();
    request.fields['PPPD'] = PPPD;
    request.fields['response'] = response;
    return request.send();
  }

  static Future<http.StreamedResponse> createNewPatient(String name,
      String username, String gender, String age, String birthday,
      String email, String phoneNum, String idNum) async {
    var url = Uri.http(Constants.BASE_HOST, "api/create_new_patient");
    var request = http.MultipartRequest("POST", url);
    var session = await SessionPrefs.getSession();

    request.headers['Authorization'] = "Bearer ${session!.access}";
    request.fields['name'] = name;
    request.fields['user_name'] = username;
    request.fields['gender'] = gender;
    request.fields['age'] = age;
    request.fields['birthday'] = birthday;
    request.fields['email'] = email;
    request.fields['phone_no'] = phoneNum;
    request.fields['id_no'] = idNum;

    return request.send();
  }

  static Future<http.StreamedResponse> createNewUser(String user_name, String user_pw, String user_email) async {
    var url = Uri.http(Constants.BASE_HOST, "api/create_new_user");
    var request = http.MultipartRequest("POST", url);
    var session = await SessionPrefs.getSession();

    request.headers['Authorization'] = "Bearer ${session!.access}";
    request.fields['user_name'] = user_name;
    request.fields['user_pw'] = user_pw;
    request.fields['user_email'] = user_email;

    return request.send();
  }
}
