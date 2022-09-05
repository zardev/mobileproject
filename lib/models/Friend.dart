class Friend {
  String? id;
  String? userId;
  String? friendId;

  Friend({this.id, this.userId, this.friendId});

  factory Friend.fromJson(Map<String, Object?> json) {
    return Friend(
      userId: json["userId"] as String,
      friendId: json["friendId"] as String,
    );
  }

  Map<String, Object?> toJson() {
    return {"userId": userId, "friendId": friendId};
  }

  void setId(String _id) {
    this.id = _id;
  }

  void setUserId(String _userId) {
    this.userId = _userId;
  }

  void setFriendId(String _friendId) {
    this.friendId = _friendId;
  }
}
