import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'Models/allUsers.dart';
import 'Models/drivers.dart';


String mapKey = 'YOU_API_KEY';

User? firebaseUser;

Users? userCurrentInfo;

User? currentfirebaseUser;

StreamSubscription<Position>? homeTabPageStreamSubscription;

StreamSubscription<Position>? rideStreamSubscription;


final assetsAudioplayer = AssetsAudioPlayer();

Position? currentPosition;

Drivers? driversInformation;

