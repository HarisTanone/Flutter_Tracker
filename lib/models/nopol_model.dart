class NopolResponse {
  final String shipHeadLabelComment;

  NopolResponse({required this.shipHeadLabelComment});

  factory NopolResponse.fromJson(Map<String, dynamic> json) {
    return NopolResponse(
      shipHeadLabelComment: json['ShipHead_LabelComment'] ?? "",
    );
  }
}
