// Model for the shipping documents by customer ID
class ShippingDocumentsByCustomerResponse {
  final int totalSJ;
  final List<ShippingDocument> data;

  ShippingDocumentsByCustomerResponse({
    required this.totalSJ,
    required this.data,
  });

  factory ShippingDocumentsByCustomerResponse.fromJson(
      Map<String, dynamic> json) {
    return ShippingDocumentsByCustomerResponse(
      totalSJ: json['totalSJ'],
      data: (json['data'] as List)
          .map((item) => ShippingDocument.fromJson(item))
          .toList(),
    );
  }
}

class ShippingDocument {
  final String legalNumber;

  ShippingDocument({
    required this.legalNumber,
  });

  factory ShippingDocument.fromJson(Map<String, dynamic> json) {
    return ShippingDocument(
      legalNumber: json['ShipHead_LegalNumber'],
    );
  }
}

// Model for shipping document details
class ShippingDocumentDetailsResponse {
  final String odataMetadata;
  final List<ShippingDocumentDetail> value;

  ShippingDocumentDetailsResponse({
    required this.odataMetadata,
    required this.value,
  });

  factory ShippingDocumentDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ShippingDocumentDetailsResponse(
      odataMetadata: json['odata.metadata'],
      value: (json['value'] as List)
          .map((item) => ShippingDocumentDetail.fromJson(item))
          .toList(),
    );
  }
}

class ShippingDocumentDetail {
  final int packLine;
  final String partNum;
  final String lineDesc;
  final String inventoryShipQty;
  final String inventoryShipUOM;

  ShippingDocumentDetail({
    required this.packLine,
    required this.partNum,
    required this.lineDesc,
    required this.inventoryShipQty,
    required this.inventoryShipUOM,
  });

  factory ShippingDocumentDetail.fromJson(Map<String, dynamic> json) {
    return ShippingDocumentDetail(
      packLine: json['ShipDtl_PackLine'],
      partNum: json['ShipDtl_PartNum'],
      lineDesc: json['ShipDtl_LineDesc'],
      inventoryShipQty: json['ShipDtl_OurInventoryShipQty'],
      inventoryShipUOM: json['ShipDtl_InventoryShipUOM'],
    );
  }
}
