import 'package:pd_app/model/Session.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SessionPrefs {
  static const String access_key = "access";
  static const String refresh_key = "refresh";
  static const String username_key = "username";

  static void save(Session session) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(access_key, session.access);
    prefs.setString(refresh_key, session.refresh);
    prefs.setString(username_key, session.refresh);
  }

  static Future<Session?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return Session(
        refresh: prefs.getString(refresh_key)!,
        access: prefs.getString(access_key)!,
        username: prefs.getString(username_key)!
    );
  }
}