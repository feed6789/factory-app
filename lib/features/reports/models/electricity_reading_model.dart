class ElectricityReading {
  final String id;
  final String cabinetId;
  final double readingValue;
  final DateTime recordedAt;

  ElectricityReading({
    required this.id,
    required this.cabinetId,
    required this.readingValue,
    required this.recordedAt,
  });

  factory ElectricityReading.fromJson(Map<String, dynamic> json) {
    return ElectricityReading(
      id: json['id'],
      cabinetId: json['cabinet_id'],
      readingValue: (json['reading_value'] as num).toDouble(),
      recordedAt: DateTime.parse(json['recorded_at']),
    );
  }
}
