class CircleUser {
  String? id;
  String? userId;
  String? circleId;

  CircleUser({this.id, this.userId, this.circleId});

  factory CircleUser.fromJson(Map<String, Object?> json) {
    return CircleUser(
      userId: json["userId"] as String,
      circleId: json["circleId"] as String,
    );
  }

  Map<String, Object?> toJson() {
    return {
      "id": id,
      "userId": userId,
      "circleId": circleId,
    };
  }

  void setId(String id) {
    this.id = id;
  }
}
