class UpdateStatusResponse {
  final String success;
  final dynamic data;

  UpdateStatusResponse({
    required this.success,
    required this.data,
  });

  factory UpdateStatusResponse.fromJson(Map<String, dynamic> json) {
    return UpdateStatusResponse(
      success: json['success'],
      data: json['data'],
    );
  }
}
