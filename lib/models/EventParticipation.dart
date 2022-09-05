class EventParticipation {
  String? id;
  String? userId;
  String? eventId;

  EventParticipation({
    this.id,
    this.userId,
    this.eventId,
  });

  factory EventParticipation.fromJson(Map<String, Object?> json) {
    return EventParticipation(
        userId: json["userId"] as String,
        eventId: json["eventId"] as String,
    );
  }

  Map<String, Object?> toJson() {
    return {
      "id": id,
      "userId": userId,
      "eventId": eventId,
    };
  }

  void setId(String id) {
    this.id = id;
  }
}