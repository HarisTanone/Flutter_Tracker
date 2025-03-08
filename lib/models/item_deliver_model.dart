class ItemDeliver {
  final String usernameDriver;
  final String imgDelivery;
  final String? codeGagal;
  final String keterangan;
  final String tujuanLat;
  final String tujuanLng;
  final String custID;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int id;

  ItemDeliver({
    required this.usernameDriver,
    required this.imgDelivery,
    required this.codeGagal,
    required this.keterangan,
    required this.tujuanLat,
    required this.tujuanLng,
    required this.custID,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
  });

  factory ItemDeliver.fromJson(Map<String, dynamic> json) {
    return ItemDeliver(
      usernameDriver: json['username_driver'],
      imgDelivery: json['img_delivery'],
      codeGagal: json['code_gagal'],
      keterangan: json['keterangan'],
      tujuanLat: json['tujuan_lat'],
      tujuanLng: json['tujuan_lng'],
      custID: json['custID'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      id: json['id'],
    );
  }
}
