import 'dart:convert';

Session sessionFromJson(String str) => Session.fromJson(json.decode(str));

String sessionToJson(Session data) => json.encode(data.toJson());

class Session {
  Session({
    required this.refresh,
    required this.access,
    required this.username,
  });

  String refresh;
  String access;
  String username;

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    refresh: json["refresh"],
    access: json["access"],
    username: json["username"]
  );

  Map<String, dynamic> toJson() => {
    "refresh": refresh,
    "access": access,
    'username': username
  };
}
