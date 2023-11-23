import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../AllScreens/newRideScreen.dart';
import '../AllScreens/registrationScreen.dart';
import '../Assistants/assistantMethods.dart';
import '../Models/rideDetails.dart';
import '../configMaps.dart';
import '../main.dart';


// ignore: must_be_immutable
class NotificationDialog extends StatelessWidget {
  const NotificationDialog({super.key, this.rideDetails});

  final RideDetails? rideDetails;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.transparent,
      elevation: 1,
      child: Container(
        margin: const EdgeInsets.all(5),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 30),
            Image.asset('assets/images/taxi.png', width: 120),
            const SizedBox(height: 19),
            const Text('Новый запрос на поездку',
                style: TextStyle(fontFamily: 'Rowdies', fontSize: 19)),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(19.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/pickicon.png',
                          height: 16, width: 16),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(rideDetails?.pickup_address ?? '',
                            style: const TextStyle(fontSize: 19)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/desticon.png',
                          height: 16, width: 16),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(rideDetails?.dropoff_address ?? '',
                            style: const TextStyle(fontSize: 19)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(height: 2, color: Colors.black, thickness: 2),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(19),
                              side: const BorderSide(color: Colors.red)),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red),
                      onPressed: () async {
                        await assetsAudioplayer.stop();
                        Navigator.pop(context);
                      },
                      child: Text('Отмена'.toUpperCase(),
                          style: const TextStyle(fontSize: 14))),
                  const SizedBox(width: 25),
                  TextButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(19),
                              side: const BorderSide(color: Colors.green)),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white),
                      onPressed: () async {
                        await assetsAudioplayer.stop();
                        checkAvailabilityOfRide(context);
                      },
                      child: Text('Принимать'.toUpperCase(),
                          style: const TextStyle(fontSize: 14))),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }


  void checkAvailabilityOfRide(context) {
    rideRequestRef?.once().then((DatabaseEvent event) {
      String theRideId = '';
      if (event.snapshot.value != null) {
        theRideId = event.snapshot.value.toString();
      } else {
        displayToastMessage('Поездка не существует.', context);
        Navigator.pop(context);
      }
      if (theRideId == rideDetails?.ride_request_id) {
        rideRequestRef?.set('accepted');
        AssistantMethods.disableHomeTabLiveLocationUpdates();
        Navigator.push(context, MaterialPageRoute(builder: (context) => NewRideScreen(rideDetails: rideDetails)));
      } else if(theRideId == 'canceled') {
        displayToastMessage('Поездка была отменена', context);
        Navigator.pop(context);
      } else if(theRideId == 'timeout') {
        displayToastMessage('У поездки есть тайм-аут', context);
        Navigator.pop(context);
      } else {
        displayToastMessage('Поездка не существует.', context);
        Navigator.pop(context);
      }
    });
  }
}

