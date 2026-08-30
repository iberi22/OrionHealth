/// FEAT-022: Emergency contact
///
/// In Case of Emergency (ICE) contact. Shown on lock screen
/// alongside critical Medical ID fields.
library;

class EmergencyContact {
  final String name;
  final String relationship; // spouse, parent, friend, doctor...
  final String phone;
  final String? email;

  const EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phone,
    this.email,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'relationship': relationship,
        'phone': phone,
        'email': email,
      };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      EmergencyContact(
        name: json['name'] as String,
        relationship: json['relationship'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String?,
      );

  EmergencyContact copyWith({
    String? name,
    String? relationship,
    String? phone,
    String? email,
  }) =>
      EmergencyContact(
        name: name ?? this.name,
        relationship: relationship ?? this.relationship,
        phone: phone ?? this.phone,
        email: email ?? this.email,
      );
}
