import 'dart:convert';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io' show Platform;

import '../Models/rideDetails.dart';
import '../SnapshotData.dart';
import '../configMaps.dart';
import '../main.dart';
import 'notificationDialog.dart';

class PushNotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future initialize(context) async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      retrieveRideRequestInfo(getRideRequestId(message), context);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      retrieveRideRequestInfo(getRideRequestId(message), context);
    });
  }

  Future<void> getToken() async {
    await _firebaseMessaging.requestPermission();
    String? token = await _firebaseMessaging.getToken();
    print('This is token :: $token');
    driversRef.child(currentfirebaseUser!.uid).child('token').set(token);

    _firebaseMessaging.subscribeToTopic('alldrivers');
    _firebaseMessaging.subscribeToTopic('allusers');
  }

  String getRideRequestId(RemoteMessage message) {
    String rideRequestId = '';
    if (Platform.isAndroid) {
      rideRequestId = message.data['ride_request_id'];
    } else {
      rideRequestId = message.data['ride_request_id'];
    }
    return rideRequestId;
  }


  void retrieveRideRequestInfo(String rideRequestId, BuildContext context) {

    newRequestsRef.child(rideRequestId).once().then((event) {
      final dataSnapshot = event.snapshot;
      if (dataSnapshot.value != null) {
        print('QANIIIIIIIIIIIIi =======-         ${dataSnapshot.value}');
        SnapshotData snapshotData = SnapshotData.fromJson(jsonDecode(jsonEncode(dataSnapshot.value)));
        assetsAudioplayer.open(Audio('assets/sounds/alert.mp3'));
        assetsAudioplayer.play();

        String rider_name = snapshotData.riderName!;
        String rider_phone = snapshotData.riderPhone!;


        RideDetails rideDetails = RideDetails();
        rideDetails.ride_request_id = rideRequestId;
        rideDetails.pickup_address = snapshotData.pickupAddress;
        rideDetails.dropoff_address = snapshotData.dropoffAddress;
        rideDetails.pickup = LatLng(double.parse(snapshotData.pickup!.latitude!), double.parse(snapshotData.pickup!.longitude!));
        rideDetails.dropoff = LatLng(double.parse(snapshotData.dropoff!.latitude!), double.parse(snapshotData.dropoff!.longitude!));
        rideDetails.payment_method = snapshotData.paymentMethod;
        rideDetails.rider_name = snapshotData.riderName;
        rideDetails.rider_phone = snapshotData.riderPhone;

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => NotificationDialog(rideDetails: rideDetails));
      }
    }
    );
  }
}
