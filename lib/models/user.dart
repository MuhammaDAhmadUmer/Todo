// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  final User? user;
  final bool? status;

  UserModel({
    this.user,
    this.status,
  });

  // NOTE: the real API's GET /users/profile returns the user fields
  // flat (e.g. {"_id": ..., "name": ..., "email": ...}) rather than
  // wrapped in a "user" key. This handles both shapes so the model
  // works whether the response is wrapped or flat.
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    user: json["user"] != null
        ? User.fromJson(json["user"])
        : (json["_id"] != null || json["email"] != null
            ? User.fromJson(json)
            : null),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "user": user?.toJson(),
    "status": status,
  };
}

class User {
  final String? id;
  final String? name;
  final String? email;

  User({
    this.id,
    this.name,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"],
    name: json["name"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "email": email,
  };
}
