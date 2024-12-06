// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

Welcome welcomeFromJson(String str) => Welcome.fromJson(json.decode(str));

String welcomeToJson(Welcome data) => json.encode(data.toJson());

class Welcome {
  List<Task>? tasks;
  int? pageNumber;
  int? totalPages;

  Welcome({
    this.tasks,
    this.pageNumber,
    this.totalPages,
  });

  factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
        tasks: json["tasks"] == null
            ? []
            : List<Task>.from(json["tasks"]!.map((x) => Task.fromJson(x))),
        pageNumber: json["pageNumber"],
        totalPages: json["totalPages"],
      );

  Map<String, dynamic> toJson() => {
        "tasks": tasks == null
            ? []
            : List<dynamic>.from(tasks!.map((x) => x.toJson())),
        "pageNumber": pageNumber,
        "totalPages": totalPages,
      };
}

class Task {
  String? id;
  String? title;
  String? description;
  DateTime? createdAt;
  Status? status;

  Task({
    this.id,
    this.title,
    this.description,
    this.createdAt,
    this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        status: statusValues.map[json["status"]]!,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "createdAt": createdAt?.toIso8601String(),
        "status": statusValues.reverse[status],
      };
}

enum Status { DOING, DONE, TODO }

final statusValues = EnumValues(
    {"DOING": Status.DOING, "DONE": Status.DONE, "TODO": Status.TODO});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
