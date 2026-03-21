// electrical_cabinet_model.dart
class ElectricalCabinet {
  final String id;
  final String name;
  final String? location;
  final String? departmentId;

  ElectricalCabinet({
    required this.id,
    required this.name,
    this.location,
    this.departmentId,
  });

  factory ElectricalCabinet.fromJson(Map<String, dynamic> json) {
    return ElectricalCabinet(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      departmentId: json['department_id'],
    );
  }
}
