class EpicorData {
  final int totalData;
  final List<CustomerData> customers;

  EpicorData({required this.totalData, required this.customers});

  factory EpicorData.fromJson(Map<String, dynamic> json) {
    return EpicorData(
      totalData: json['TotalData'],
      customers:
          (json['value'] as List).map((e) => CustomerData.fromJson(e)).toList(),
    );
  }
}

class CustomerData {
  final String custID;
  final String shipLog;
  final String shipDate;
  final String name;
  final String address;
  final String city;
  final String state;
  final String labelComment;
  final String salesRep;
  final String? lat;
  final String? lng;
  final String status;
  final int legalNumberCount;
  final double distanceKm;

  CustomerData({
    required this.custID,
    required this.shipLog,
    required this.shipDate,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.labelComment,
    required this.salesRep,
    required this.lat,
    required this.lng,
    required this.status,
    required this.legalNumberCount,
    required this.distanceKm,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      custID: json['Customer_CustID'],
      shipLog: json['ShipHead_ShipLog'],
      shipDate: json['ShipHead_ShipDate'],
      name: json['Customer_Name'],
      address: json['Customer_Address1'],
      city: json['Customer_City'],
      state: json['Customer_State'],
      labelComment: json['ShipHead_LabelComment'],
      salesRep: json['OrderHed_SalesRepList'],
      lat: json['Customer_Lat'],
      lng: json['Customer_Lng'],
      status: json['Status'],
      legalNumberCount: json['LegalNumberCount'],
      distanceKm: (json['Distance_km'] as num).toDouble(),
    );
  }
}
