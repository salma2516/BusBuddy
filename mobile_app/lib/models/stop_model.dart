class StopModel {

  final int id;

  final String stopName;

  final String latitude;

  final String longitude;

  StopModel({

    required this.id,

    required this.stopName,

    required this.latitude,

    required this.longitude,
  });

  factory StopModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return StopModel(

      id: json["id"],

      stopName: json["stop_name"],

      latitude:
          json["latitude"].toString(),

      longitude:
          json["longitude"].toString(),
    );
  }
}