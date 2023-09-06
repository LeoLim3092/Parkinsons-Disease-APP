import 'dart:io';
import 'dart:convert';
import 'package:pd_app/Constants.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:pd_app/prefs/SessionPrefs.dart';


class GetResultService {
  static Future<Map<String, dynamic>> GetResult(String pid) async {
    var url = Uri.http(Constants.BASE_HOST, "api/get_results");
    var request = http.MultipartRequest("POST", url);
    var session = await SessionPrefs.getSession();
    request.headers['Authorization'] = "Bearer ${session!.access}";
    request.fields['pid'] = pid;
    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.toBytes();
      var data = json.decode(utf8.decode(responseData));
      return data;
    } else {
    throw Exception('Failed to load result');
    }
  }
}
