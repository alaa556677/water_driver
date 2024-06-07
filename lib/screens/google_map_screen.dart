import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:math' as math;
import 'cubit/location_cubit.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key, this.determineToMap = false});

  final bool determineToMap;

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  var myMarkers = HashSet<Marker>();
  List<Marker> markers = [];
  GoogleMapController? mapController;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  static CameraPosition? _currentLocation;
  BitmapDescriptor? myLocationIcon;
  static double currentZoom = 17.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    LocationCubit locationCubit = BlocProvider.of<LocationCubit>(context);
    _currentLocation ??= CameraPosition(
        target: LatLng(locationCubit.position!.latitude,
            locationCubit.position!.longitude),
        zoom: currentZoom);
    _controller.future.then((value) {
      mapController = value;
      onTapMap(_currentLocation!.target);
    });
    BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(600, 600)),
      'images/user_marker.png',
    ).then((onValue) {
      myLocationIcon = onValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    LocationCubit locationCubit = BlocProvider.of<LocationCubit>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF00B4DA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Location',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(

        children: [

          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(locationCubit.position!.latitude,
                  locationCubit.position!.longitude),
              zoom: currentZoom,
            ),
            markers: Set.from(markers),
            trafficEnabled: false,
            tiltGesturesEnabled: false,
            zoomControlsEnabled: false,

            onTap: (lat) => changeMarkerByTapping(lat),
            onCameraMove: (c) {
              currentZoom = c.zoom;
            },
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              markers.add(
                Marker(
                  icon: myLocationIcon!,
                  markerId: const MarkerId('1'),
                  position: LatLng(locationCubit.position!.latitude,
                      locationCubit.position!.longitude),
                  infoWindow: InfoWindow(
                      title: "",
                      snippet: '',
                      onTap: () {
                        //debugPrint('my tap');
                      }),
                ),
              );
              setState(() {
                controller.setMapStyle('''
        [
  {
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#f5f5f5"
          }
        ]
  },
  {
        "elementType": "labels.icon",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
  },
  {
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#616161"
          }
        ]
  },
  {
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#f5f5f5"
          }
        ]
  },
  {
        "featureType": "administrative.land_parcel",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#bdbdbd"
          }
        ]
  },
  {
        "featureType": "poi",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#eeeeee"
          }
        ]
  },
  {
        "featureType": "poi",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
  },
  {
        "featureType": "poi.park",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#e5e5e5"
          }
        ]
  },
  {
        "featureType": "poi.park",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#9e9e9e"
          }
        ]
  },
  {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#ffffff"
          }
        ]
  },
  {
        "featureType": "road.arterial",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
  },
  {
        "featureType": "road.highway",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#dadada"
          }
        ]
  },
  {
        "featureType": "road.highway",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#616161"
          }
        ]
  },
  {
        "featureType": "road.local",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#9e9e9e"
          }
        ]
  },
  {
        "featureType": "transit.line",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#e5e5e5"
          }
        ]
  },
  {
        "featureType": "transit.station",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#eeeeee"
          }
        ]
  },
  {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#c9c9c9"
          }
        ]
  },
  {
        "featureType": "water",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#9e9e9e"
          }
        ]
  }
]
        ''');

                ///  my Location
              });
            },
            // zoomControlsEnabled: true,
          ),
          Positioned(
              top: 40,
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  decoration:  InputDecoration(
                      labelText: 'Sadat academy',
                      filled: true,
                      fillColor: Colors.white,
                    errorStyle: TextStyle(
                        fontSize: 18,
                        color: Colors.transparent,
                       ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.transparent
                      )
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),

                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),

                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                ),
              )
          ),
          SizedBox(height: 20,),
          Positioned(
              top: 120,
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  decoration:  InputDecoration(
                    labelText: 'Zamalek',
                    filled: true,
                    fillColor: Colors.white,
                    errorStyle: TextStyle(
                      fontSize: 18,
                      color: Colors.transparent,
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                            color: Colors.transparent
                        )
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),

                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),

                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                ),
              )
          ),
          Positioned(
            bottom: 0,
            top: 0,
            right: 0,
            left: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 250,
                alignment: Alignment.bottomRight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.withOpacity(.3),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Zamalek",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Via Nile .",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    SizedBox(
                                      width: 6,
                                    ),
                                    Text(
                                      "10.6 km",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white),
                            child: const Text(
                              "Fair \n 35EGP",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white),
                            child: const Text(
                              "Approx.arrival time \n 15 MINS",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 80),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 2,
                              child: Container(
                                height: 90,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            "https://www.tripsavvy.com/thmb/G4UFgAsY-Yb0zuBFcC9IYMJjwCc=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/GettyImages-96869652-f6700d0efa8c4efb8031043af8ccaf8e.jpg"),
                                        fit: BoxFit.cover)),
                              )),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: 45,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              "https://www.tripsavvy.com/thmb/G4UFgAsY-Yb0zuBFcC9IYMJjwCc=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/GettyImages-96869652-f6700d0efa8c4efb8031043af8ccaf8e.jpg"),
                                          fit: BoxFit.cover)),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  height: 38,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              "https://www.tripsavvy.com/thmb/G4UFgAsY-Yb0zuBFcC9IYMJjwCc=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/GettyImages-96869652-f6700d0efa8c4efb8031043af8ccaf8e.jpg"),
                                          fit: BoxFit.cover)),
                                )
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  changeMarkerByTapping(
    LatLng latLng,
  ) async {
    Map<String, double> locationData = Map();
    locationData["latitude"] = latLng.latitude;
    locationData["longitude"] = latLng.longitude;
    debugPrint("xxxxxxxxxxxxxx");

    LocationData locationDataValue = LocationData.fromMap(locationData);
    LocationCubit locationCubit = BlocProvider.of<LocationCubit>(context);
    await changeMarkerPosition(latLng);

    setState(() {});
    mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: latLng,
          zoom: currentZoom,
        ),
      ),
    );
  }

  changeMarkerPosition(LatLng latLng) async {
    markers = [];
    markers.add(
      Marker(
        icon: myLocationIcon!,
        markerId: const MarkerId('1'),
        position: LatLng(latLng.latitude, latLng.longitude),
        infoWindow: InfoWindow(
            title: "",
            snippet: '',
            onTap: () {
              //debugPrint('my tap');
            }),
      ),
    );
    setState(() {});
  }

  void onTapMap(LatLng latLng) async {
    Marker marker = Marker(
      markerId: MarkerId(latLng.toString()),
      position: latLng,
    );
    changeMarkerByTapping(latLng);
    if (markers.isEmpty) markers.add(marker);
    if (markers.isNotEmpty) markers[0] = marker;
    // location = place?.description.toString()??"nolocationinformation".tr();
    setState(() {});
  }
}
