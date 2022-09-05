class CircleRequest {
  String? id;
  String? senderId;
  String? receiverId;
  String? circleId;

  CircleRequest({this.id, this.senderId, this.receiverId, this.circleId});

  factory CircleRequest.fromJson(Map<String, Object?> json) {
    return CircleRequest(
      senderId: json["senderId"] as String,
      receiverId: json["receiverId"] as String,
      circleId: json["circleId"] as String,
    );
  }

  Map<String, Object?> toJson() {
    return {
      "senderId": senderId,
      "receiverId": receiverId,
      "circleId": circleId
    };
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
