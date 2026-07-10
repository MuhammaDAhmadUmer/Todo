import 'dart:convert';

import 'package:api_practice/models/Task_Listing.dart';
import 'package:api_practice/models/task.dart';
import 'package:http/http.dart' as http;

class TaskServices {
  Future<TaskModel> createTask({
    required String token,
    required String description,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse("{{TODO_URL}}/todos/add"),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"description": description}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return TaskModel.fromJson(jsonDecode(response.body));
      } else {
        throw response.reasonPhrase.toString();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<TaskLIstingModel> getAllTasks(String token) async {
    try {
      http.Response response = await http.get(
        Uri.parse("{{TODO_URL}}/todos/get"),
        headers: {'Authorization': token},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return TaskLIstingModel.fromJson(jsonDecode(response.body));
      } else {
        throw response.reasonPhrase.toString();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<TaskLIstingModel> getCompletedTasks(String token) async {
    try {
      http.Response response = await http.get(
        Uri.parse("{{TODO_URL}}/todos/completed"),
        headers: {'Authorization': token},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return TaskLIstingModel.fromJson(jsonDecode(response.body));
      } else {
        throw response.reasonPhrase.toString();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<TaskLIstingModel> getInCompletedTasks(String token) async {
    try {
      http.Response response = await http.get(
        Uri.parse("{{TODO_URL}}/todos/incomplete"),
        headers: {'Authorization': token},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return TaskLIstingModel.fromJson(jsonDecode(response.body));
      } else {
        throw response.reasonPhrase.toString();
      }
    } catch (e) {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------
  // Confirmed against the real Postman collection.
  // ---------------------------------------------------------------------

  Future<TaskModel> getTaskById({
    required String token,
    required String id,
  }) async {
    try {
      http.Response response = await http.get(
        Uri.parse("{{TODO_URL}}/todos/gettodobyid/$id"),
        headers: {'Authorization': token},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return TaskModel.fromJson(jsonDecode(response.body));
      } else {
        throw response.reasonPhrase.toString();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// PATCH /todos/update/:id — this single endpoint handles both editing
  /// the description AND toggling complete; only send the fields you
  /// want to change.
  Future<bool> updateTask({
    required String token,
    required String id,
    String? description,
    bool? complete,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (description != null) body['description'] = description;
      if (complete != null) body['complete'] = complete;

      http.Response response = await http.patch(
        Uri.parse("{{TODO_URL}}/todos/update/$id"),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
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

  /// Convenience wrapper over [updateTask] for the checkbox toggle —
  /// same endpoint, just sends only the `complete` field.
  Future<bool> toggleComplete({
    required String token,
    required String id,
    required bool complete,
  }) {
    return updateTask(token: token, id: id, complete: complete);
  }

  Future<bool> deleteTask({
    required String token,
    required String id,
  }) async {
    try {
      http.Response response = await http.delete(
        Uri.parse("{{TODO_URL}}/todos/delete/$id"),
        headers: {'Authorization': token},
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

  Future<TaskLIstingModel> filterTasksByDate({
    required String token,
    required String startDate, // format: yyyy-MM-dd
    required String endDate,
  }) async {
    try {
      http.Response response = await http.get(
        Uri.parse(
          "{{TODO_URL}}/todos/filter?startDate=$startDate&endDate=$endDate",
        ),
        headers: {'Authorization': token},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return TaskLIstingModel.fromJson(jsonDecode(response.body));
      } else {
        throw response.reasonPhrase.toString();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<TaskLIstingModel> searchTasks({
    required String token,
    required String keyword,
  }) async {
    try {
      http.Response response = await http.get(
        Uri.parse("{{TODO_URL}}/todos/search?keywords=$keyword"),
        headers: {'Authorization': token},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return TaskLIstingModel.fromJson(jsonDecode(response.body));
      } else {
        throw response.reasonPhrase.toString();
      }
    } catch (e) {
      rethrow;
    }
  }
}
