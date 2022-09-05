class FriendRequest {
  String? id;
  String? senderId;
  String? receiverId;

  FriendRequest({this.id, this.senderId, this.receiverId});

  factory FriendRequest.fromJson(Map<String, Object?> json) {
    return FriendRequest(
      senderId: json["senderId"] as String,
      receiverId: json["receiverId"] as String,
    );
  }

  Map<String, Object?> toJson() {
    return {"senderId": senderId, "receiverId": receiverId};
  }

  void setId(String _id) {
    this.id = _id;
  }

  void setSenderId(String _senderId) {
    this.senderId = _senderId;
  }

  void setReceiverId(String _receiverId) {
    this.receiverId = _receiverId;
  }
}
