// medical_info_model.dart
class MedicalInfoModel {
  final String id;
  final String? bloodGroup;
  final List<String>? allergies;
  final List<String>? medications;
  final List<String>? conditions;
  final String? emergencyContact;
  final String? doctorName;
  final String? doctorPhone;
  final String? insuranceInfo;
  final String? additionalNotes;
  final DateTime? lastUpdated;
  final DateTime? createdAt;

  MedicalInfoModel({
    required this.id,
    this.bloodGroup,
    this.allergies,
    this.medications,
    this.conditions,
    this.emergencyContact,
    this.doctorName,
    this.doctorPhone,
    this.insuranceInfo,
    this.additionalNotes,
    this.lastUpdated,
    this.createdAt,
  });

  // Convert from Firebase document
  factory MedicalInfoModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MedicalInfoModel(
      id: documentId,
      bloodGroup: map['bloodGroup']?.toString(),
      allergies: map['allergies'] != null
          ? List<String>.from(map['allergies'])
          : null,
      medications: map['medications'] != null
          ? List<String>.from(map['medications'])
          : null,
      conditions: map['conditions'] != null
          ? List<String>.from(map['conditions'])
          : null,
      emergencyContact: map['emergencyContact']?.toString(),
      doctorName: map['doctorName']?.toString(),
      doctorPhone: map['doctorPhone']?.toString(),
      insuranceInfo: map['insuranceInfo']?.toString(),
      additionalNotes: map['additionalNotes']?.toString(),
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastUpdated'])
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : null,
    );
  }

  // Convert to Firebase document
  Map<String, dynamic> toMap() {
    return {
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'medications': medications,
      'conditions': conditions,
      'emergencyContact': emergencyContact,
      'doctorName': doctorName,
      'doctorPhone': doctorPhone,
      'insuranceInfo': insuranceInfo,
      'additionalNotes': additionalNotes,
      'lastUpdated': lastUpdated?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      'createdAt': createdAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
    };
  }

  // Create a copy with updated fields
  MedicalInfoModel copyWith({
    String? id,
    String? bloodGroup,
    List<String>? allergies,
    List<String>? medications,
    List<String>? conditions,
    String? emergencyContact,
    String? doctorName,
    String? doctorPhone,
    String? insuranceInfo,
    String? additionalNotes,
    DateTime? lastUpdated,
    DateTime? createdAt,
  }) {
    return MedicalInfoModel(
      id: id ?? this.id,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
      conditions: conditions ?? this.conditions,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      doctorName: doctorName ?? this.doctorName,
      doctorPhone: doctorPhone ?? this.doctorPhone,
      insuranceInfo: insuranceInfo ?? this.insuranceInfo,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'MedicalInfoModel(id: $id, bloodGroup: $bloodGroup, allergies: $allergies, medications: $medications, conditions: $conditions, emergencyContact: $emergencyContact, doctorName: $doctorName, doctorPhone: $doctorPhone, insuranceInfo: $insuranceInfo, additionalNotes: $additionalNotes, lastUpdated: $lastUpdated, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicalInfoModel &&
        other.id == id &&
        other.bloodGroup == bloodGroup &&
        other.emergencyContact == emergencyContact &&
        other.doctorName == doctorName &&
        other.doctorPhone == doctorPhone &&
        other.insuranceInfo == insuranceInfo &&
        other.additionalNotes == additionalNotes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    bloodGroup.hashCode ^
    emergencyContact.hashCode ^
    doctorName.hashCode ^
    doctorPhone.hashCode ^
    insuranceInfo.hashCode ^
    additionalNotes.hashCode;
  }
}