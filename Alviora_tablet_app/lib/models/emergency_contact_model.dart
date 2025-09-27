class EmergencyContactModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String priority; // High, Medium, Low
  final bool isAvailable24h;
  final String relationship;
  final String? email;
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmergencyContactModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.priority = 'Medium',
    this.isAvailable24h = false,
    required this.relationship,
    this.email,
    this.isPrimary = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert from Firestore document
  factory EmergencyContactModel.fromMap(Map<String, dynamic> map, String id) {
    return EmergencyContactModel(
      id: id,
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      priority: map['priority'] ?? 'Medium',
      isAvailable24h: map['isAvailable24h'] ?? false,
      relationship: map['relationship'] ?? '',
      email: map['email'],
      isPrimary: map['isPrimary'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'priority': priority,
      'isAvailable24h': isAvailable24h,
      'relationship': relationship,
      'email': email,
      'isPrimary': isPrimary,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create a copy with updated fields
  EmergencyContactModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? priority,
    bool? isAvailable24h,
    String? relationship,
    String? email,
    bool? isPrimary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmergencyContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      priority: priority ?? this.priority,
      isAvailable24h: isAvailable24h ?? this.isAvailable24h,
      relationship: relationship ?? this.relationship,
      email: email ?? this.email,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'EmergencyContactModel(id: $id, name: $name, phone: $phoneNumber, priority: $priority, 24h: $isAvailable24h)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmergencyContactModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
