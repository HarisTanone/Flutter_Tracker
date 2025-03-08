class FailCode {
  final int id;
  final String keterangan;
  final int point;
  final int active;
  final DateTime createdAt;
  final DateTime updatedAt;

  FailCode({
    required this.id,
    required this.keterangan,
    required this.point,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FailCode.fromJson(Map<String, dynamic> json) {
    return FailCode(
      id: json['id'],
      keterangan: json['keterangan'],
      point: json['point'],
      active: json['active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
