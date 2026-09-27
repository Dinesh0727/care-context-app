class HomeNetworkModel {
  final UserNetworkModel user;
  final List<MedicineNetworkModel> medicines;
  final List<PrescriptionNetworkModel> prescriptions;
  final InsuranceNetworkModel insurance;
  final List<AppointmentNetworkModel> appointments;

  const HomeNetworkModel({
    required this.user,
    required this.medicines,
    required this.prescriptions,
    required this.insurance,
    required this.appointments,
  });

  factory HomeNetworkModel.fromJson(Map<String, dynamic> json) {
    return HomeNetworkModel(
      user: UserNetworkModel.fromJson(json['user'] as Map<String, dynamic>),
      medicines: (json['medicines'] as List<dynamic>)
          .map((e) => MedicineNetworkModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      prescriptions: (json['prescriptions'] as List<dynamic>)
          .map((e) => PrescriptionNetworkModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      insurance: InsuranceNetworkModel.fromJson(json['insurance'] as Map<String, dynamic>),
      appointments: (json['appointments'] as List<dynamic>)
          .map((e) => AppointmentNetworkModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class UserNetworkModel {
  final String name;
  final String? abhaId;
  final String abhaStatus;

  const UserNetworkModel({
    required this.name,
    required this.abhaId,
    required this.abhaStatus,
  });

  factory UserNetworkModel.fromJson(Map<String, dynamic> json) {
    return UserNetworkModel(
      name: json['name'] ?? '',
      abhaId: json['abhaId'] as String?,
      abhaStatus: json['abhaStatus'] ?? 'not_linked',
    );
  }
}

class ReminderTimeNetworkModel {
  final String? slotId;
  final String time;
  final String? scheduledAt;
  final String? status;

  const ReminderTimeNetworkModel({
    this.slotId,
    required this.time,
    this.scheduledAt,
    this.status,
  });

  factory ReminderTimeNetworkModel.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return ReminderTimeNetworkModel(
        slotId: json['slotId'] as String?,
        time: json['time'] ?? '',
        scheduledAt: json['scheduledAt'] as String?,
        status: json['status'] as String?,
      );
    }
    if (json is String) {
      return ReminderTimeNetworkModel(time: json);
    }
    return const ReminderTimeNetworkModel(time: '');
  }

  dynamic toJson() {
    if (slotId == null && scheduledAt == null && status == null) {
      return time;
    }
    return {
      if (slotId != null) 'slotId': slotId,
      'time': time,
      if (scheduledAt != null) 'scheduledAt': scheduledAt,
      if (status != null) 'status': status,
    };
  }
}

class MedicineNetworkModel {
  final String? id;
  final String name;
  final String dosage;
  final String frequency;
  final String? frequencyType;
  final String? dayOfWeek;
  final String duration;
  final List<ReminderTimeNetworkModel> reminderTimes;

  const MedicineNetworkModel({
    this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    this.frequencyType,
    this.dayOfWeek,
    required this.duration,
    required this.reminderTimes,
  });

  factory MedicineNetworkModel.fromJson(Map<String, dynamic> json) {
    return MedicineNetworkModel(
      id: (json['medicineId'] ?? json['id']) as String?,
      name: json['medicineName'] ?? json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency']?.toString() ?? '',
      frequencyType: json['frequencyType'] as String?,
      dayOfWeek: json['dayOfWeek'] as String?,
      duration: json['duration'] ?? '',
      reminderTimes: (json['reminderTimes'] as List<dynamic>?)
              ?.map((e) => ReminderTimeNetworkModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicineName': name,
      'dosage': dosage,
      'frequency': frequency,
      if (frequencyType != null) 'frequencyType': frequencyType,
      if (dayOfWeek != null) 'dayOfWeek': dayOfWeek,
      'duration': duration,
      'reminderTimes': reminderTimes.map((e) => e.toJson()).toList(),
    };
  }
}

class PrescriptionNetworkModel {
  final String id;
  final String? status;
  final String? uploadedAt;
  final String? doctorName;
  final String? title;
  final String? date;
  final int? medicationCount;
  final List<String>? imageUrls;
  final List<String>? thumbnailUrls;
  final List<MedicineNetworkModel> medicines;

  const PrescriptionNetworkModel({
    required this.id,
    this.status,
    this.uploadedAt,
    this.doctorName,
    this.title,
    this.date,
    this.medicationCount,
    this.imageUrls,
    this.thumbnailUrls,
    this.medicines = const [],
  });

  factory PrescriptionNetworkModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionNetworkModel(
      id: json['id'] ?? json['prescriptionId'] ?? '',
      status: json['status'] as String?,
      uploadedAt: json['uploadedAt'] ?? json['date'] as String?,
      doctorName: json['doctorName'] as String?,
      title: json['title'] as String?,
      date: json['date'] as String?,
      medicationCount: json['medicationCount'] as int?,
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : null,
      thumbnailUrls: json['thumbnailUrls'] != null
          ? List<String>.from(json['thumbnailUrls'])
          : null,
      medicines: json['medicines'] != null
          ? (json['medicines'] as List<dynamic>)
              .map((e) => MedicineNetworkModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

class PrescriptionsPageNetworkModel {
  final List<PrescriptionNetworkModel> content;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  const PrescriptionsPageNetworkModel({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  factory PrescriptionsPageNetworkModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final prescriptions = data['prescriptions'] as List<dynamic>?
        ?? json['content'] as List<dynamic>?
        ?? [];
    final pagination = data['pagination'] as Map<String, dynamic>? ?? {};

    return PrescriptionsPageNetworkModel(
      content: prescriptions
          .map((e) => PrescriptionNetworkModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: pagination['totalRecords'] ?? json['totalElements'] ?? 0,
      totalPages: pagination['totalPages'] ?? json['totalPages'] ?? 0,
      currentPage: pagination['currentPage'] ?? json['number'] ?? 0,
    );
  }
}

class InsuranceNetworkModel {
  final bool hasInsurance;
  final String providerName;
  final String status;
  final String policyNumber;

  const InsuranceNetworkModel({
    required this.hasInsurance,
    required this.providerName,
    required this.status,
    required this.policyNumber,
  });

  factory InsuranceNetworkModel.fromJson(Map<String, dynamic> json) {
    return InsuranceNetworkModel(
      hasInsurance: json['hasInsurance'] ?? false,
      providerName: json['providerName'] ?? '',
      status: json['status'] ?? '',
      policyNumber: json['policyNumber'] ?? '',
    );
  }
}

class AppointmentNetworkModel {
  final String doctorName;
  final String speciality;
  final String date;
  final String time;
  final String clinic;
  final String status;

  const AppointmentNetworkModel({
    required this.doctorName,
    required this.speciality,
    required this.date,
    required this.time,
    required this.clinic,
    required this.status,
  });

  factory AppointmentNetworkModel.fromJson(Map<String, dynamic> json) {
    return AppointmentNetworkModel(
      doctorName: json['doctorName'] ?? '',
      speciality: json['speciality'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      clinic: json['clinic'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
