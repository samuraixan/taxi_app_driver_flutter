import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_clone_driver/Assistants/mapKitAssistant.dart';
import 'package:uber_clone_driver/configMaps.dart';

import '../AllWidgets/CollectFareDialog.dart';
import '../AllWidgets/progressDialog.dart';
import '../Assistants/assistantMethods.dart';
import '../Models/rideDetails.dart';
import '../main.dart';

class NewRideScreen extends StatefulWidget {
  const NewRideScreen({super.key, this.rideDetails});

  final RideDetails? rideDetails;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  State<NewRideScreen> createState() => _NewRideScreenState();
}

class _NewRideScreenState extends State<NewRideScreen> {
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newRideGoogleMapController;
  Set<Marker> markersSet = Set<Marker>();
  Set<Circle> circleSet = Set<Circle>();
  Set<Polyline> polylineSet = Set<Polyline>();
  List<LatLng> polylineCorOrdinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  double mapPaddingFromBottom = 0;
  var geolocator = Geolocator();

  // var locationOptions = LocationOptions(accuracy: LocationAccuracy.bestForNavigation);
  BitmapDescriptor? animatingMarkerIcon;
  Position? myPosition;
  String status = 'accepted';
  String durationRide = '';
  bool isRequestingDirection = false;
  String btnTitle = 'Приехал';
  Color btnColor = Colors.blueAccent;
  Timer? timer;
  int durationCounter = 0;

  @override
  void initState() {
    super.initState();
    acceptRideRequest();
  }

  void createIconMarker() {
    if (animatingMarkerIcon == null) {
      ImageConfiguration imageConfiguration =
      createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, 'assets/images/car_android.png').then((value) {
        animatingMarkerIcon = value;
        setState(() {});
      });
    }
  }

  void getRideLiveLocationUpdates() {
    LatLng oldPos = const LatLng(0, 0);

    rideStreamSubscription = Geolocator.getPositionStream().listen((Position position) async {
          currentPosition = position;
          myPosition = position;
          LatLng mPosition = LatLng(position.latitude, position.longitude);

          var rot = MapKitAssistant.getMarkerRotation(oldPos.latitude, oldPos.longitude, myPosition?.latitude, myPosition?.longitude);

          Marker animatingMarker = Marker(
              markerId: const MarkerId('animating'),
              position: mPosition,
              icon: animatingMarkerIcon!,
              rotation: rot,
              infoWindow: const InfoWindow(title: 'Current Location'));

          setState(() {
            CameraPosition cameraPosition =
            CameraPosition(target: mPosition, zoom: 17);
            newRideGoogleMapController
                ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

            markersSet
                .removeWhere((marker) => marker.markerId.value == 'animating');
            markersSet.add(animatingMarker);
          });
          oldPos = mPosition;
          updateRideDetails();

          String rideRequestId = widget.rideDetails!.ride_request_id!;
          Map locMap = {
            'latitude': currentPosition?.latitude.toString(),
            'longitude': currentPosition?.longitude.toString(),
          };
          newRequestsRef.child(rideRequestId).child('driver_location').set(locMap);
        });
  }

  @override
  Widget build(BuildContext context) {
    createIconMarker();
    return Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(bottom: mapPaddingFromBottom),
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              initialCameraPosition: NewRideScreen._kGooglePlex,
              myLocationEnabled: true,
              markers: markersSet,
              circles: circleSet,
              polylines: polylineSet,
              onMapCreated: (GoogleMapController controller) async {
                _controllerGoogleMap.complete(controller);
                newRideGoogleMapController = controller;

                setState(() {
                  mapPaddingFromBottom = 265;
                });
                print(widget.rideDetails);
                // var currentLatLng = LatLng(currentPosition!.latitude, currentPosition!.longitude);
                var currentLatLng = LatLng(widget.rideDetails!.pickup!.latitude, widget.rideDetails!.pickup!.longitude);
                var pickupLatLng = LatLng(widget.rideDetails!.dropoff!.latitude, widget.rideDetails!.dropoff!.longitude);;
                await getPlaceDirection(currentLatLng, pickupLatLng);
                getRideLiveLocationUpdates();
              },
            ),
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 16,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      ),
                    ],
                  ),
                  height: 270,
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 19),
                    child: Column(
                      children: [
                        Text(durationRide,
                            style: const TextStyle(
                                fontSize: 15,
                                fontFamily: 'Rowdies',
                                color: Colors.deepPurple)),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.rideDetails!.rider_name!,
                                style:
                                const TextStyle(fontFamily: 'Rowdies', fontSize: 24)),
                            const Padding(
                              padding: EdgeInsets.only(right: 10.0),
                              child: Icon(Icons.phone_android),
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        Row(
                          children: [
                            Image.asset('assets/images/pickicon.png',
                                height: 16, width: 16),
                            const SizedBox(height: 19),
                            Expanded(
                                child: Container(
                                    child: Text(
                                      widget.rideDetails!.pickup_address!,
                                      style: const TextStyle(fontSize: 19),
                                      overflow: TextOverflow.ellipsis,
                                    )))
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Image.asset('assets/images/desticon.png',
                                height: 16, width: 16),
                            const SizedBox(height: 19),
                            Expanded(
                                child: Container(
                                    child: Text(
                                      widget.rideDetails!.dropoff_address!,
                                      style: const TextStyle(fontSize: 19),
                                      overflow: TextOverflow.ellipsis,
                                    )))
                          ],
                        ),
                        const SizedBox(height: 26),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (status == 'accepted') {
                                status = 'arrived';
                                String rideRequestId = widget.rideDetails!.ride_request_id!;
                                newRequestsRef.child(rideRequestId).child('status').set(status);
                                setState(() {
                                  btnTitle = 'Начать поездку';
                                  btnColor = Colors.purple;
                                });

                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) => ProgressDialog(message: 'Пожалуйста подождите...'));

                                await getPlaceDirection(widget.rideDetails!.pickup, widget.rideDetails!.dropoff);

                                Navigator.pop(context);
                              }
                              else if (status == 'arrived') {
                                status = 'onride';
                                String rideRequestId = widget.rideDetails!.ride_request_id!;
                                newRequestsRef.child(rideRequestId).child('status').set(status);
                                setState(() {
                                  btnTitle = 'Конец поездки';
                                  btnColor = Colors.redAccent;
                                });
                                initTimer();
                              }

                              else if(status == 'onride') {
                                endTheTrip();
                              }
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: btnColor),
                            child: Padding(
                              padding: const EdgeInsets.all(17.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(btnTitle,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  const Icon(Icons.directions_car,
                                      color: Colors.white, size: 26),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
    );
  }

  Future<void> getPlaceDirection(LatLng? pickUpLatLng, LatLng? dropOffLatLng) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(message: 'Пожалуйста подождите...'));

    var details = await AssistantMethods.obtainDirectionDetails(pickUpLatLng!, dropOffLatLng!);

    Navigator.pop(context);

    print('Это точки кодирования :: ${details?.encodePoints}');

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePolyLinePointResult = polylinePoints.decodePolyline(details?.encodePoints ?? '');

    polylineCorOrdinates.clear();

    if (decodePolyLinePointResult.isNotEmpty) {
      decodePolyLinePointResult.forEach((PointLatLng pointLatLng) {
        polylineCorOrdinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: Colors.pink,
        polylineId: const PolylineId('PolylineId'),
        jointType: JointType.round,
        points: polylineCorOrdinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }

    newRideGoogleMapController?.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      position: pickUpLatLng,
      markerId: const MarkerId('pickUpId'),
    );
    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      position: dropOffLatLng,
      markerId: const MarkerId('dropOffId'),
    );
    setState(() {
      markersSet.add(pickUpLocMarker);
      markersSet.add(dropOffLocMarker);
    });

    Circle pickUpLocCircle = Circle(
      fillColor: Colors.blueAccent,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.blueAccent,
      circleId: const CircleId('pickUpId'),
    );

    Circle dropOffLocCircle = Circle(
      fillColor: Colors.deepPurple,
      center: dropOffLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.deepPurple,
      circleId: const CircleId('dropOffId'),
    );

    setState(() {
      circleSet.add(pickUpLocCircle);
      circleSet.add(dropOffLocCircle);
    });
  }

  void acceptRideRequest() {
    String rideRequestId = widget.rideDetails!.ride_request_id!;
    newRequestsRef.child(rideRequestId).child('status').set('accepted');
    newRequestsRef.child(rideRequestId).child('driver_name').set(driversInformation?.name);
    newRequestsRef.child(rideRequestId).child('driver_phone').set(driversInformation?.phone);
    newRequestsRef.child(rideRequestId).child('driver_id').set(driversInformation?.id);
    newRequestsRef.child(rideRequestId).child('car_details').set('${driversInformation?.car_color} - ${driversInformation?.car_model} - ${driversInformation?.car_number}');

    Map locMap = {
      'latitude': currentPosition?.latitude.toString(),
      'longitude': currentPosition?.longitude.toString(),
    };
    newRequestsRef.child(rideRequestId).child('driver_location').set(locMap);

    driversRef.child(currentfirebaseUser!.uid).child('history').child(rideRequestId).set(true);
  }

  void updateRideDetails() async {
    if (isRequestingDirection == false) {
      isRequestingDirection = true;

      if (myPosition == null) {
        return;
      }

      var posLatLng = LatLng(myPosition!.latitude, myPosition!.longitude);
      LatLng? destinationLatLng;

      if (status == 'accepted') {
        destinationLatLng = widget.rideDetails?.pickup;
      } else {
        destinationLatLng = widget.rideDetails?.dropoff;
      }
      var directionDetails = await AssistantMethods.obtainDirectionDetails(posLatLng, destinationLatLng!);
      if (directionDetails != null) {
        setState(() {
          durationRide = directionDetails.durationText!;
        });
      }

      isRequestingDirection = false;
    }
  }

  void initTimer() {
    const interval = Duration(seconds: 1);
    timer = Timer.periodic(interval, (timer) {
      durationCounter = durationCounter + 1;
    });
  }

  void endTheTrip() async {
    timer!.cancel();

    showDialog(context: context, builder: (BuildContext context) => ProgressDialog(message: 'Пожалуйста подождите...'));

    var currentLatLng = LatLng(myPosition!.latitude, myPosition!.longitude);

    var directionDetails = await AssistantMethods.obtainDirectionDetails(widget.rideDetails!.pickup!, currentLatLng);
    Navigator.pop(context);

    int fareAmount = AssistantMethods.calculateFares(directionDetails!);

    String rideRequestId = widget.rideDetails!.ride_request_id!;
    newRequestsRef.child(rideRequestId).child('fares').set(fareAmount.toString());
    newRequestsRef.child(rideRequestId).child('status').set('ended');
    rideStreamSubscription!.cancel();

    // ignore: use_build_context_synchronously
    showDialog(context: context, builder: (BuildContext context) => CollectFareDialog(paymentMethod: widget.rideDetails!.payment_method!, fareAmount: fareAmount));
    saveEarnings(fareAmount);

  }

  void saveEarnings(int fareAmount) {
    driversRef.child(currentfirebaseUser!.uid).child('earnings').once().then((DatabaseEvent event) {
      DataSnapshot dataSnapshot = event.snapshot;
      if (dataSnapshot.value != null) {
        double oldEarnings = double.parse(dataSnapshot.value.toString());
        double totalEarnings = fareAmount + oldEarnings;
        driversRef.child(currentfirebaseUser!.uid).child('earnings').set(totalEarnings.toStringAsFixed(2));
      } else {
        double totalEarnings = fareAmount.toDouble();
        driversRef.child(currentfirebaseUser!.uid).child('earnings').set(totalEarnings.toStringAsFixed(2));
      }
    });
  }
}
