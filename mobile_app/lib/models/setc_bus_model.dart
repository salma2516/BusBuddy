class SetcBusModel {

  final String from;
  final String to;
  final String routeNo;
  final String departure;
  final String type;

  SetcBusModel({

    required this.from,
    required this.to,
    required this.routeNo,
    required this.departure,
    required this.type,
  });

  factory SetcBusModel.fromJson(
      Map<String, dynamic> json) {

    return SetcBusModel(

      from: json["From"] ?? "",

      to: json["To"] ?? "",

      routeNo:
          json["Route No."] ?? "",

      departure:
          json["Departure Timings"]
              .toString(),

      type: json["Type"] ?? "",
    );
  }
}