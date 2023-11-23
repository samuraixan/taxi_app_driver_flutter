import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../Models/directDetails.dart';
import '../configMaps.dart';
import 'requestAssistant.dart';

class AssistantMethods {
  // static Future<String> searchCoordinateAddress(Position position, context) async {
  //   String placeAddress = '';
  //   String st1, st2, st3;
  //   String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
  //   var response = await RequestAssistant.getRequest(url);
  //
  //   if (response != 'Провал') {
  //     if (response['results'].isNotEmpty) {
  //       st1 = response['results'][0]['address_components'][1]['long_name'];
  //       st2 = response['results'][0]['address_components'][2]['long_name'];
  //       st3 = response['results'][0]['address_components'][3]['long_name'];
  //       // st4 = response['results'][0]['address_components'][4]['long_name'];
  //
  //       placeAddress = '$st1, $st2, $st3';
  //     }
  //
  //     Address userPickUpAddress = Address();
  //     userPickUpAddress.longitude = position.longitude;
  //     userPickUpAddress.latitude = position.latitude;
  //     userPickUpAddress.placeName = placeAddress;
  //
  //     Provider.of<AppData>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
  //   } else {
  //     return 'Местоположение';
  //   }
  //   return placeAddress;
  // }

  static Future<DirectionDetails?> obtainDirectionDetails(LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude}, ${initialPosition.longitude}&destination=${finalPosition.latitude}, ${finalPosition.longitude}&key=$mapKey";
    var res = await RequestAssistant.getRequest(directionUrl);
    if(res == 'Провал') {
      return null;
    }

    if(res['routes'].isEmpty) {
      return null;
    } else {
      DirectionDetails directionDetails = DirectionDetails();
      directionDetails.encodePoints = res['routes'][0]['overview_polyline']['points'];
      directionDetails.distanceText = res['routes'][0]['legs'][0]['distance']['text'];
      directionDetails.distanceValue = res['routes'][0]['legs'][0]['distance']['value'];
      directionDetails.durationText = res['routes'][0]['legs'][0]['duration']['text'];
      directionDetails.durationValue = res['routes'][0]['legs'][0]['duration']['value'];

      return directionDetails;
    }
  }

  static int calculateFares(DirectionDetails directionDetails)  {
    // in terms USD
    double timeTraveledFare = (directionDetails.durationValue! / 60) * 0.20;
    double distancTraveledFare = (directionDetails.distanceValue! / 1000) * 0.20;
    double totalFareAmount = timeTraveledFare + distancTraveledFare;
    //   Местная валюта
    // 1$ = 10120 so`m
    // double totalLocalAmount = totalFareAmount * 10120

    return totalFareAmount.truncate();
  }

  // static void getCurrentOnlineUserInfo() async {
  //   firebaseUser = await FirebaseAuth.instance.currentUser;
  //   String userId = firebaseUser?.uid ?? '';
  //   DatabaseReference reference = FirebaseDatabase.instance.ref().child('users').child(userId);
  //
  //   reference.once().then((event) {
  //     final dataSnapshot = event.snapshot;
  //     if(dataSnapshot.value != null) {
  //       userCurrentInfo = Users.fromSnapshot(dataSnapshot);
  //     }
  //   });
  // }

static void disableHomeTabLiveLocationUpdates() {
    homeTabPageStreamSubscription?.pause();
    Geofire.removeLocation(currentfirebaseUser!.uid);
}

static void enableHomeTabLiveLocationUpdates() {
    homeTabPageStreamSubscription?.resume();
    Geofire.setLocation(currentfirebaseUser!.uid, currentPosition!.latitude, currentPosition!.longitude);
}
}
