import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:waterriderdemo/core/navigation_constants.dart';
import 'package:waterriderdemo/core/shared_preferences.dart';
import 'package:waterriderdemo/screens/login_screen.dart';
import 'package:waterriderdemo/screens/pre_home_screen.dart';
import 'package:waterriderdemo/screens/profile_screen.dart';
import '../core/constants.dart';
import '../core/widgets/card_trip_widget.dart';
import '../core/widgets/listTile_drawer.dart';
import 'google_map_screen.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});
  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  var scaffoldKey = GlobalKey <ScaffoldState> ();

  List <CityDataModel> tripsDataList = [];
  getTripsListList() async {
    await FirebaseFirestore.instance.collection('trips').get().then((value){
      for(var i in value.docs){
        tripsDataList.add(CityDataModel.fromJson(i.data()));
      }
      setState(() {});
    }).catchError((error){});
  }

  @override
  void initState() {
    getTripsListList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFF00B4DA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('My Trips',
          style: TextStyle(
            color: Colors.white
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white,),
          onPressed: (){
            scaffoldKey.currentState?.openDrawer ();
          },
        ),
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
      body: tripsDataList.isNotEmpty ? Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) => CardTripWidget(
                  cityDataModel: tripsDataList[index],
                ),
                separatorBuilder: (context, index) => const SizedBox(height: 12,),
                itemCount: tripsDataList.length
              ),
            ),
          ],
        ),
      ) : const Center(child: CircularProgressIndicator(),),
    );
  }
}

//
// List <TripDataModel> myTrips= [
//   TripDataModel(
//     location: "cairo",
//     destination: "Giza",
//     price: "200.0 EGP",
//     establishTime: "10:00 pm",
//     arrivalTime: "11:00 pm",
//     riderName: "Mohamed",
//     riderPhone: "01025588798"
//   ),
//   TripDataModel(
//       location: "cairo",
//       destination: "Giza",
//       price: "200.0 EGP",
//       establishTime: "10:00 pm",
//       arrivalTime: "11:00 pm",
//       riderName: "Mohamed",
//       riderPhone: "01025588798"
//   ),
//   TripDataModel(
//       location: "cairo",
//       destination: "Giza",
//       price: "200.0 EGP",
//       establishTime: "10:00 pm",
//       arrivalTime: "11:00 pm",
//       riderName: "Mohamed",
//       riderPhone: "01025588798"
//   ),
//   TripDataModel(
//       location: "cairo",
//       destination: "Giza",
//       price: "200.0 EGP",
//       establishTime: "10:00 pm",
//       arrivalTime: "11:00 pm",
//       riderName: "Mohamed",
//       riderPhone: "01025588798"
//   ),
//   TripDataModel(
//       location: "cairo",
//       destination: "Giza",
//       price: "200.0 EGP",
//       establishTime: "10:00 pm",
//       arrivalTime: "11:00 pm",
//       riderName: "Mohamed",
//       riderPhone: "01025588798"
//   ),
//   TripDataModel(
//       location: "cairo",
//       destination: "Giza",
//       price: "200.0 EGP",
//       establishTime: "10:00 pm",
//       arrivalTime: "11:00 pm",
//       riderName: "Mohamed",
//       riderPhone: "01025588798"
//   ),
//   TripDataModel(
//       location: "cairo",
//       destination: "Giza",
//       price: "200.0 EGP",
//       establishTime: "10:00 pm",
//       arrivalTime: "11:00 pm",
//       riderName: "Mohamed",
//       riderPhone: "01025588798"
//   ),
//   TripDataModel(
//       location: "cairo",
//       destination: "Giza",
//       price: "200.0 EGP",
//       establishTime: "10:00 pm",
//       arrivalTime: "11:00 pm",
//       riderName: "Mohamed",
//       riderPhone: "01025588798"
//   ),
// ];
//
//
//
