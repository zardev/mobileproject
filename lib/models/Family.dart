import 'User.dart';

class Family {
  String? id;
  String name;
  String ownerId;

  Family({
    required this.name,
    required this.ownerId
  });

  factory Family.fromJson(Map<String, Object?> json) {
    return Family(
      name: json["name"] as String,
      ownerId: json["ownerId"] as String,
    );
  }

  Map<String, Object?> toJson() {
    return {
      "id": id,
      "name": name,
      "ownerId": ownerId
    };
  }

  void setId(String id) {
    this.id = id;
  }

  void setOwnerId(String ownerId) {
    this.ownerId = ownerId;
  }
}