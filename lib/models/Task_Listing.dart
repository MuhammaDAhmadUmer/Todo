// To parse this JSON data, do
//
//     final taskLIstingModel = taskLIstingModelFromJson(jsonString);

import 'dart:convert';
import "package:api_practice/models/task.dart";

TaskLIstingModel taskLIstingModelFromJson(String str) => TaskLIstingModel.fromJson(json.decode(str));

String taskLIstingModelToJson(TaskLIstingModel data) => json.encode(data.toJson());

class TaskLIstingModel {
  final List<Task>? tasks;
  final int? totalPages;
  final int? currentPage;
  final int? count;

  TaskLIstingModel({
    this.tasks,
    this.totalPages,
    this.currentPage,
    this.count,
  });

  factory TaskLIstingModel.fromJson(Map<String, dynamic> json) => TaskLIstingModel(
    tasks: json["tasks"] == null ? [] : List<Task>.from(json["tasks"]!.map((x) => Task.fromJson(x))),
    totalPages: json["totalPages"],
    currentPage: json["currentPage"],
    count: json["count"],
  );

  Map<String, dynamic> toJson() => {
    "tasks": tasks == null ? [] : List<dynamic>.from(tasks!.map((x) => x.toJson())),
    "totalPages": totalPages,
    "currentPage": currentPage,
    "count": count,
  };
}

