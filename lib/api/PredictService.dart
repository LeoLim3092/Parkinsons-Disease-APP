import 'dart:io';
import 'package:pd_app/Constants.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:pd_app/prefs/SessionPrefs.dart';


class PredictService {
  static Future<http.StreamedResponse> predictModels(String pid) async {
    var url = Uri.http(Constants.BASE_HOST, "api/predict_model");
    var request = http.MultipartRequest("POST", url);
    var session = await SessionPrefs.getSession();
    request.headers['Authorization'] = "Bearer ${session!.access}";
    request.fields['pid'] = pid;
    return request.send();
  }
  static Future<http.Response> checkRecording(String pid) async {
    var url = Uri.http(Constants.BASE_HOST, "api/check_recording");
    var request = http.MultipartRequest("POST", url);
    var session = await SessionPrefs.getSession();
    request.headers['Authorization'] = "Bearer ${session!.access}";
    request.fields['pid'] = pid;

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return response;
  }
}
