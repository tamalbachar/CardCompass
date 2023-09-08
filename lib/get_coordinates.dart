//Mixin to Get the Geopoint and other details of atms and branches
import 'package:card_compass/data/data_handler.dart';
import 'package:card_compass/models/custom_marker.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

mixin GetCoordinates {
  final List<CustomMarkerData> customMarkers = [];
  final List<CustomMarkerData> hello = [];

  //get atm data
  final List<GeoPoint> atmCoordinates = [];
  Future<void> fetchATMData() async {
    final List<dynamic> atmData =
        await DataHandler().fetchATMDataFromMapModuleApp();
    for (var i = 0; i < atmData.length; i++) {
      var atmName = atmData.elementAt(i)['atm'];
      var atmAddress = atmData.elementAt(i)['address'];
      var atmPincode = atmData.elementAt(i)['pincode'];
      var atmLat = double.parse(atmData.elementAt(i)['latitude']);
      var atmLong = double.parse(atmData.elementAt(i)['longitude']);
      customMarkers.add(CustomMarkerData(
          position: GeoPoint(latitude: atmLat, longitude: atmLong),
          name: atmName,
          address: atmAddress,
          pincode: atmPincode));
      atmCoordinates.add(GeoPoint(latitude: atmLat, longitude: atmLong));
    }
  }

  //get atm coordinates
  Future<List<GeoPoint>> fetchATMLatLng() async {
    await fetchATMData();
    return atmCoordinates;
  }

  //get branch data
  final List<GeoPoint> branchesCoordinates = [];
  Future<void> fetchBranchesData() async {
    final List<dynamic> branchesData =
        await DataHandler().fetchBranchDataFromMapModuleApp();
    for (var i = 0; i < branchesData.length; i++) {
      var branchName = branchesData.elementAt(i)['Branch'];
      var branchAddress = branchesData.elementAt(i)['Address'];
      var branchPincode = branchesData.elementAt(i)['Pincode'];
      var branchLat = double.parse(branchesData.elementAt(i)['latitude']);
      var branchLong = double.parse(branchesData.elementAt(i)['longitude']);
      customMarkers.add(CustomMarkerData(
          position: GeoPoint(latitude: branchLat, longitude: branchLong),
          name: branchName,
          address: branchAddress,
          pincode: branchPincode));
      branchesCoordinates
          .add(GeoPoint(latitude: branchLat, longitude: branchLong));
    }
  }

//get branch coordinates
  Future<List<GeoPoint>> fetchBranchLatLng() async {
    await fetchBranchesData();
    return branchesCoordinates;
  }
}
