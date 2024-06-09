import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:waterriderdemo/screens/pre_home_screen.dart';
import 'package:waterriderdemo/screens/profile_screen.dart';
import 'dart:math' as math;
import '../core/constants.dart';
import '../core/navigation_constants.dart';
import '../core/shared_preferences.dart';
import '../core/widgets/listTile_drawer.dart';
import 'booked_successfully.dart';
import 'cubit/location_cubit.dart';
import 'login_screen.dart';
import 'my_trips.dart';

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
  var scaffoldKey = GlobalKey <ScaffoldState> ();
  String city = '';
  CollectionReference trips = FirebaseFirestore.instance.collection('trips');

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
    city = '';
  }

  @override
  Widget build(BuildContext context) {
    LocationCubit locationCubit = BlocProvider.of<LocationCubit>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF00B4DA),
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white,),
          onPressed: (){
            scaffoldKey.currentState?.openDrawer ();
          },
        ),
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 40),
            ListTileDrawer(title: "Home", leadingWidget: const Icon(Icons.home_filled), onTap: (){
              scaffoldKey.currentState?.closeDrawer();
              navigateTo(context, PreHomeScreen());
            },),
            ListTileDrawer(title: "Profile", leadingWidget: const Icon(Icons.person), onTap: (){
              scaffoldKey.currentState?.closeDrawer();
              navigateTo(context, const ProfileScreen());
            },),
            ListTileDrawer(title: "My trips", leadingWidget: const Icon(Icons.directions_boat_outlined), onTap: (){
              scaffoldKey.currentState?.closeDrawer();
              navigateTo(context, const MyTripsScreen());
            },),
            ListTileDrawer(title: "Log Out", leadingWidget: const Icon(Icons.logout), onTap: () async {
              scaffoldKey.currentState?.closeDrawer();
              if(CacheHelper.getData(key: Constants.fromGoogle.toString()) == true){
                await signOut(context).then((value) => navigateAndRemove(context, LoginScreen()));
              }else{
                await FirebaseAuth.instance.signOut().then((value) => navigateAndRemove(context, LoginScreen()));
              }
            },),
          ],
        ),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
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
          Column(
            children: [
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: DropdownButtonFormField<CityDataModel>(
                  decoration: const InputDecoration(
                    labelText: 'Where to?', // Label text
                    fillColor: Colors.white, // Background color of the dropdown
                    filled: true, // Make sure the background color is applied
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey, width: 1)// Rounded corners
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Colors.blue,width: 1),
                    ),
                  ),

                  value: null, // Default value
                  onChanged: (newValue) {
                    setState(() {
                      city = newValue!.cityName;
                      cityDataModel = newValue;
                    });
                    print("gender = $city");
                  }, // Handle dropdown value change
                  items: cityList.map<DropdownMenuItem<CityDataModel>>((value) {
                    return DropdownMenuItem<CityDataModel>(
                      value: value, // Value of the dropdown item
                      child: Text(value.cityName),
                      onTap: (){
                        city = value.cityName ;
                      },// Display text
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select City'; // Validation message for unselected gender
                    }
                    return null;
                  },
                ),
              ),
              Spacer(),
              if(city != "")...[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.withOpacity(.3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    city,
                                    style: const TextStyle(
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
                                        cityDataModel!.kiloMeter,
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
                              padding: EdgeInsets.all(8),
                              alignment: Alignment.center,
                              child: Text(
                                "${cityDataModel!.price} \n EGP",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white),
                              padding: EdgeInsets.all(8),
                              alignment: Alignment.center,
                              child: Text(
                                "A-time \n ${cityDataModel!.arrivalTime}",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12,),
                        GestureDetector(
                          onTap: (){
                            trips.add({
                              'cityName': cityDataModel?.cityName ?? "",
                              'kiloMeter': cityDataModel?.kiloMeter ?? "",
                              'price': cityDataModel?.price ?? "",
                              'arrivalTime': cityDataModel?.arrivalTime ?? "",
                              'driverName': cityDataModel?.driverName ?? "",
                              'driverPhone': cityDataModel?.driverPhone ?? "",
                              'uid': FirebaseAuth.instance.currentUser?.uid,
                            }).then((value){
                              navigateAndReplace(context, const BookedSuccessfullyScreen());
                            }).catchError((error){
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(error.toString(), style: const TextStyle(color: Colors.red))),
                              );
                            });
                          },
                          child: Container(
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
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              city = "";
                            });
                          },
                          child: Container(
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
              ]
            ],
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

class CityDataModel{
  late final String cityName;
  late final String kiloMeter;
  late final String price;
  late final String arrivalTime;
  late final String driverName;
  late final String driverPhone;
  CityDataModel({
    required this.cityName,
    required this.kiloMeter,
    required this.price,
    required this.arrivalTime,
    required this.driverName,
    required this.driverPhone
  });
  CityDataModel.fromJson(json){
    cityName = json['cityName'];
    kiloMeter = json['kiloMeter'];
    price = json['price'];
    arrivalTime = json['arrivalTime'];
    driverName = json['driverName'];
    driverPhone = json['driverPhone'];
  }
}

CityDataModel? cityDataModel;
List <CityDataModel> cityList = [
  CityDataModel(
    cityName: "Zamalk",
    kiloMeter: "10 Km",
    price: "350",
    arrivalTime: "20 Mins",
    driverName: "Mohamed",
    driverPhone: "01028865544",
  ),
  CityDataModel(
    cityName: "Aswan",
    kiloMeter: "120 Km",
    price: "1200",
    arrivalTime: "11 Hours",
    driverName: "Osama",
    driverPhone: "01235566770",
  ),
  CityDataModel(
    cityName: "Qena",
    kiloMeter: "100 Km",
    price: "1100",
    arrivalTime: "10 Hours",
    driverName: "Ahmed",
    driverPhone: "01136675599",
  ),
  CityDataModel(
    cityName: "Giza",
    kiloMeter: "20 Km",
    price: "500",
    arrivalTime: "30 Mins",
    driverName: "Ali",
    driverPhone: "01122394455",
  ),
];

