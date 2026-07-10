import 'dart:convert';

import 'package:api_practice/models/login.dart';
import 'package:api_practice/models/user.dart';
import 'package:http/http.dart' as http;

import '../models/register.dart';

class AuthServices {
  Future<LoginModel> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse('{{TODO_URL}}/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "email": email,
          "password": password,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoginModel.fromJson(jsonDecode(response.body));
      } else {
        throw response.reasonPhrase.toString();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<RegisterModel> registerUSer({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse('{{TODO_URL}}/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "name": name,
          "email": email,
          "password": password,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return RegisterModel.fromJson(jsonDecode(response.body));
      } else {
        throw response.reasonPhrase.toString();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getProfile(
    String token,
  ) async {
    try {
      http.Response response = await http.get(
        Uri.parse('{{TODO_URL}}/users/profile'),
        headers: {'Authorization': token},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        throw response.reasonPhrase.toString();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> UpdateProfile({
    required String token,
    required String name,
  }) async {
    try {
      http.Response response = await http.put(
        Uri.parse('{{TODO_URL}}/users/profile'),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
        body: json.encode({"name": name}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw response.reasonPhrase.toString();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> logoutUser(String token) async {
    try {
      http.Response response = await http.post(
        Uri.parse('{{TODO_URL}}/users/logout'),
        headers: {'Authorization': token},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // Logout is best-effort — local session is cleared regardless.
      return false;
    }
  }
}
