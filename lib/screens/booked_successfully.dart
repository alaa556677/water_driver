import 'package:flutter/material.dart';
import 'package:waterriderdemo/core/navigation_constants.dart';
import 'package:waterriderdemo/screens/google_map_screen.dart';

class BookedSuccessfullyScreen extends StatelessWidget{
  const BookedSuccessfullyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00B4DA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 60,),
          Image.asset(
            "images/water_rider_logo.png",
            width: 250,
            height: 250,
          ),
          SizedBox(height: 40,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Ride Booked Successfully",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontFamily: "Pacifico"
                ),
              ),
            ],
          ),
          SizedBox(height: 40,),
        SizedBox(
          width: MediaQuery.of(context).size.width * .8,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue, // Text color
                backgroundColor: Colors.white, // Background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                padding: const EdgeInsets.symmetric(vertical: 20), // Button padding
              ),
              onPressed: () => navigateAndReplace(context, const GoogleMapScreen()), // Handle sign up button press
              child: const Text('Get Back To Booking Service', style: TextStyle(color: Colors.blue, fontSize: 16, fontFamily: "Pacifico")), // Button text
            ),
          ),
        ],
      ),
    );
  }
}