/// Entidad de Colegio/Escuela
class School {
  final int id;
  final String name;
  final String? address;
  final String? phone;
  final String status;

  const School({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.status = 'ACTIVE',
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      'status': status,
    };
  }

  @override
  String toString() => 'School(id: $id, name: $name)';
}
