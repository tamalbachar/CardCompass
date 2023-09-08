// ignore_for_file: prefer_const_constructors

import 'package:card_compass/arScene/ar_scene.dart';
import 'package:card_compass/data/data_handler.dart';
import 'package:card_compass/models/custom_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

void main() {
  final myWidget = MyWidget();
  myWidget.fetchATMData();
  myWidget.fetchBranchesData();
  runApp(MaterialApp(home: MyMap()));
}

//Mixin to Get the Geopoint and other details of atms and branches
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

class MyMap extends StatefulWidget {
  MyMap({Key? key}) : super(key: key);
  @override
  MyWidget createState() => MyWidget();
}

class MyWidget extends State<MyMap> with GetCoordinates {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isBottomSheetOpen = false;
  CustomMarkerData? currentCustomMarker;

  void openBottomSheet(CustomMarkerData customMarker) {
    setState(() {
      isBottomSheetOpen = true;
      currentCustomMarker = customMarker;
    });
    _scaffoldKey.currentState!.showBottomSheet((context) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    customMarker.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const Divider(
                    thickness: 1,
                  ),
                  Text(
                    customMarker.address,
                  ),
                  const Divider(
                    thickness: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showDirections(customMarker.position);
                          Navigator.pop(context);
                        },
                        child: Text('Get Directions'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (c) => ARScene()));
                        },
                        child: Text('Start AR View'),
                      ),
                    ],
                  )
                ],
              )),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.clear),
              )
            ],
          ),
        ),
      );
    });
  }

  void closeBottomSheet() {
    setState(() {
      isBottomSheetOpen = false;
    });
    Navigator.of(context).pop();
  }

  late MapController controller; //declaring map controller

  List<StaticPositionGeoPoint> staticPoints =
      []; //to store the atm and branch coordinates as staticpoints on the map

  //initial state when map opens
  @override
  void initState() {
    super.initState();

    controller = MapController.withUserPosition(
        trackUserLocation: UserTrackingOption(
      enableTracking: true,
      unFollowUser: true,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.listenerMapSingleTapping.addListener(() async {
        var position = controller.listenerMapSingleTapping.value;
        if (position != null) {
          for (var customMarker in customMarkers) {
            await controller.addMarker(customMarker.position,
                markerIcon: MarkerIcon(
                  icon: Icon(
                    Icons.atm_rounded,
                    color: Colors.red,
                    size: 0,
                  ),
                ));
          }
        }
      });
    });
  }

//to show the 2D directions on the map from user location to selected destination
  Future<void> showDirections(GeoPoint destination) async {
    await controller.removeLastRoad();
    GeoPoint geoPoint = await controller.myLocation();
    RoadInfo roadInfo = await controller.drawRoad(
      GeoPoint(latitude: geoPoint.latitude, longitude: geoPoint.longitude),
      GeoPoint(
          latitude: destination.latitude, longitude: destination.longitude),
      roadType: RoadType.car,
      roadOption: RoadOption(
        roadWidth: 10,
        roadColor: Colors.blue,
        zoomInto: true,
      ),
    );
    // print("${roadInfo.distance}km");
    // print("${roadInfo.duration}sec");
    // print("${roadInfo.instructions}");
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

//Building main widget
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text('Powered by Xerago', textDirection: TextDirection.ltr),
            //textDirection: TextDirection.ltr
          ),
          body: FutureBuilder<List<List<GeoPoint>>>(
            future: Future.wait([fetchATMLatLng(), fetchBranchLatLng()]),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                staticPoints = [
                  StaticPositionGeoPoint(
                    'ATM ',
                    const MarkerIcon(
                      icon: Icon(
                        Icons.atm_rounded,
                        color: Color.fromARGB(255, 196, 86, 26),
                        size: 48,
                      ),
                    ),
                    snapshot.data![0],
                  ),
                  StaticPositionGeoPoint(
                    'Branches',
                    const MarkerIcon(
                      icon: Icon(
                        Icons.currency_rupee_rounded,
                        color: Color.fromARGB(255, 196, 26, 26),
                        size: 48,
                      ),
                    ),
                    snapshot.data![1],
                  ),
                ];
                return Center(
                  child: OSMFlutter(
                    controller: controller,
                    osmOption: OSMOption(
                      showZoomController: true,
                      staticPoints: staticPoints,

                      zoomOption: ZoomOption(
                        initZoom: 15,
                        minZoomLevel: 3,
                        maxZoomLevel: 19,
                        stepZoom: 1.0,
                      ),
                      userLocationMarker: UserLocationMaker(
                        personMarker: MarkerIcon(
                          icon: Icon(
                            Icons.person_2,
                            color: Colors.black,
                            size: 72,
                          ),
                        ),
                        directionArrowMarker: MarkerIcon(
                          icon: Icon(
                            Icons.double_arrow,
                            size: 48,
                          ),
                        ),
                      ),
                      roadConfiguration: RoadOption(
                        roadColor: const Color.fromARGB(255, 124, 59, 238),
                      ),
                      markerOption: MarkerOption(
                          defaultMarker: MarkerIcon(
                        icon: Icon(
                          Icons.currency_rupee_rounded,
                          color: Colors.blue,
                          size: 56,
                        ),
                      )),
                      // onStaticPointTapped :
                    ),
                    onGeoPointClicked: (geoPoint) {
                      var customMarker = customMarkers.firstWhere((marker) =>
                          marker.position.latitude == geoPoint.latitude &&
                          marker.position.longitude == geoPoint.longitude);
                      // var key = '${geoPoint.latitude}_${geoPoint.longitude}';
                      openBottomSheet(customMarker);
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('Error fetching ATM data');
              } else {
                return CircularProgressIndicator();
              }
            },
          )),
      onWillPop: () async {
        if (isBottomSheetOpen) {
          closeBottomSheet();
          return false;
        } else {
          // Handle other cases if needed (e.g., app exit or navigation)
          // Return true to exit the app, or navigate to a different screen.
          return true;
        }
      },
    );
  }
}
