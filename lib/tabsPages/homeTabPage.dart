import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../AllScreens/registrationScreen.dart';
import '../Models/drivers.dart';
import '../Notifications/pushNotificationService.dart';
import '../configMaps.dart';
import '../main.dart';



// ignore: must_be_immutable
class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  GoogleMapController? newGoogleMapController;



  var geolocator = Geolocator();


  LocationPermission? permission;

  // String driverStatusText = 'Сейчас оффлайн - Выходи в Интернет';
  String driverStatusText = 'Вы не в сети - войти в сеть';

  Color driverStatusColor = Colors.black;

  bool isDriverAvailable = false;

  @override
  void initState() {
    super.initState();
    getCurretDriverInfo();
  }

  void locatePosition() async {
    permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition = CameraPosition(target: latLatPosition, zoom: 15);
    newGoogleMapController?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    // String address = await AssistantMethods.searchCoordinateAddress(position, context);
    // print('Ваше местоположение :: $address');
  }

  void getCurretDriverInfo() async {
    currentfirebaseUser = await FirebaseAuth.instance.currentUser;

    driversRef.child(currentfirebaseUser!.uid).once().then((DatabaseEvent event) {
      DataSnapshot dataSnapshot = event.snapshot;
      if (dataSnapshot.value != null) {
        driversInformation = Drivers.fromSnapshot(dataSnapshot);
      }
    });

    PushNotificationService pushNotificationService = PushNotificationService();

    // ignore: use_build_context_synchronously
    pushNotificationService.initialize(context);
    pushNotificationService.getToken();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          initialCameraPosition: HomeTabPage._kGooglePlex,
          myLocationEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;

            locatePosition();
          },
        ),

        //   Водитель онлайн или оффлайн Контейнер
        Container(
          height: 140,
          width: double.infinity,
          color: Colors.black54,
        ),
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: driverStatusColor
                          ),
                          onPressed: () {
                            if (isDriverAvailable != true) {
                              makeDriverOnlineNow();
                              getLocationLiveUpdates();

                              setState(() {
                                driverStatusColor = Colors.green;
                                driverStatusText = 'Сейчас онлайн';
                                isDriverAvailable = true;
                              });
                              displayToastMessage('Вы в сети', context);
                            } else {
                              makeDriverOfflineNow();
                              displayToastMessage('Вы не в сети', context);
                              setState(() {
                                driverStatusColor = Colors.black;
                                // driverStatusText = 'Сейчас оффлайн - Выходи в Интернет';
                                driverStatusText = 'Вы не в сети - войти в сеть';
                                isDriverAvailable = false;
                              });
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(driverStatusText, style: const TextStyle(fontSize: 20,
                                  fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const Icon(Icons.phone_android, color: Colors.white, size: 26,)
                            ],
                          ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void makeDriverOnlineNow() async {
    permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    Geofire.initialize('availableDrivers');
    await Geofire.setLocation(currentfirebaseUser!.uid, currentPosition!.latitude, currentPosition!.longitude);

    rideRequestRef?.set('searching');
    rideRequestRef?.onValue.listen((event) { });

    rideRequestRef?.onValue.listen((event) {

    });
  }

  void getLocationLiveUpdates() async {
    homeTabPageStreamSubscription = Geolocator.getPositionStream().listen((Position position) async {
      currentPosition = position;
      if (isDriverAvailable == true)   {
        await Geofire.setLocation(currentfirebaseUser!.uid, position.latitude, position.longitude);
      }
      LatLng latLng = LatLng(position.latitude, position.longitude);
      newGoogleMapController?.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  void makeDriverOfflineNow() {
    Geofire.removeLocation(currentfirebaseUser!.uid);
    rideRequestRef?.onDisconnect();
    rideRequestRef?.remove();
    rideRequestRef = null;
  }
}
