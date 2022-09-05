class Circle {
  String? id;
  String? name;
  String? ownerId;

  Circle({
    this.id,
    this.name,
    this.ownerId,
  });

  factory Circle.fromJson(Map<String, Object?> json) {
    return Circle(
      name: json["name"] as String,
      ownerId: json["ownerId"] as String,
    );
  }

  Map<String, Object?> toJson() {
    return {
      "id": id,
      "name": name,
      "ownerId": ownerId,
    };
  }

  void setId(String id) {
    this.id = id;
  }
}
