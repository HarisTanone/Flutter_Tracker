class UsageCar {
  final int? id;
  final String username;
  final String noKendaraan;
  final int km;
  final String fotoKm;
  final String lat;
  final String lng;
  final String tanggal;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  UsageCar({
    this.id,
    required this.username,
    required this.noKendaraan,
    required this.km,
    required this.fotoKm,
    required this.lat,
    required this.lng,
    required this.tanggal,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory UsageCar.fromJson(Map<String, dynamic> json) {
    return UsageCar(
      id: json['id'],
      username: json['username'],
      noKendaraan: json['no_kendaraan'],
      km: json['km'],
      fotoKm: json['foto_km'],
      lat: json['lat'],
      lng: json['lng'],
      tanggal: json['tanggal'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "no_kendaraan": noKendaraan,
      "km": km,
      "foto_km": fotoKm,
      "lat": lat,
      "lng": lng,
      "tanggal": tanggal,
      "status": status,
    };
  }
}
