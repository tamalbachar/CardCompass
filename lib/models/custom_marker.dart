import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class CustomMarkerData {
  final GeoPoint position;
  final String name;
  final String address;
  final int pincode;

  CustomMarkerData({
    required this.position,
    required this.name,
    required this.address,
    required this.pincode,
  });
}
