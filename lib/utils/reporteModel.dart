// To parse this JSON data, do
//
//     final reporteModel = reporteModelFromJson(jsonString);
// https://app.quicktype.io/?share=4Ik8Upww0mN33e2CBVmq

// {
//     "date": "2020-07-20T17:53:22",
//     "status": "publish",
//     "title": 200,
//     "fields": {
//         "lat": -17.3332,
//         "lon": -62.223,
//         "nivel": 2,
//         "flete": false
//     }
// }

import 'dart:convert';

ReporteModel reporteModelFromJson(String str) =>
    ReporteModel.fromJson(json.decode(str));

String reporteModelToJson(ReporteModel data) => json.encode(data.toJson());

class ReporteModel {
  ReporteModel({
    this.date,
    this.status,
    this.title,
    this.fields,
  });

  String date;
  String status;
  String title;
  Fields fields;

  factory ReporteModel.fromJson(Map<String, dynamic> json) => ReporteModel(
        date: json["date"],
        status: json["status"],
        title: json["title"],
        fields: Fields.fromJson(json["fields"]),
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "status": status,
        "title": title,
        "fields": fields.toJson(),
      };
}

class Fields {
  Fields(
      {this.lat,
      this.lon,
      this.nivel,
      this.flete,
      this.estadia,
      this.heading,
      this.speed});

  double lat;
  double lon;
  int nivel;
  bool flete;
  bool estadia;
  int speed;
  int heading;

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        lat: json["lat"].toDouble(),
        lon: json["lon"].toDouble(),
        nivel: json["nivel"],
        flete: json["flete"],
        estadia: json["flete"],
        speed: json["speed"],
        heading: json["heading"],
      );

  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lon": lon,
        "nivel": nivel,
        "flete": flete,
        "estadia": estadia,
        "speed": speed,
        "heading": heading
      };
}
