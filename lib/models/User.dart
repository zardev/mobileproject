class User {

  String id;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? familyId;
  String? selectedCircle;
  bool? privateCalendar;

  User({
    required this.id,
    this.name,
    this.email,
    this.phoneNumber,
    this.familyId,
    this.selectedCircle,
    this.privateCalendar
  });

  User.fromJson(Map<String, Object?> json) :
        this(
        id: json["id"] as String,
        name: json["name"] as String,
        email: json["email"]! as String,
        phoneNumber: json["phoneNumber"]! as String,
        familyId: json["familyId"]! as String,
        selectedCircle: json["selectedCircle"]! as String,
        privateCalendar: json["privateCalendar"]! as bool,
      );

  Map<String, Object?> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "phoneNumber": phoneNumber,
      "familyId": familyId,
      "selectedCircle": selectedCircle,
      "privateCalendar": privateCalendar
    };
  }
}
