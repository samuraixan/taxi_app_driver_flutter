import 'package:flutter/material.dart';
import 'package:uber_clone_driver/AllScreens/mainscreen.dart';
import 'package:uber_clone_driver/AllScreens/registrationScreen.dart';
import 'package:uber_clone_driver/configMaps.dart';
import 'package:uber_clone_driver/main.dart';
import '../AllWidgets/progressDialog.dart';


// ignore: must_be_immutable
class CarInfoScreen extends StatelessWidget {
  CarInfoScreen({super.key});

  static const String idScreen = 'carinfo';
  TextEditingController carModelController = TextEditingController();
  TextEditingController carNumberController = TextEditingController();
  TextEditingController carColorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 22),
              Image.asset('assets/images/logo.png', width: 390, height: 250),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 32, 22),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const Text('Введите данные об автомобиле', style: TextStyle(fontFamily: 'Rowdies', fontSize: 24),
                    ),
                    const SizedBox(height: 26),
                    TextField(
                      controller: carModelController,
                      decoration: const InputDecoration(
                        labelText: 'Модель автомобиля',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: carNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Номер автомобиля',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: carColorController,
                      decoration: const InputDecoration(
                        labelText: 'Цвет автомобиля',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 42),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                        onPressed: () {
                          if (carModelController.text.isEmpty) {
                            displayToastMessage('Пожалуйста,  введите модель автомобиля', context);
                          }
                          else if (carNumberController.text.isEmpty) {
                            displayToastMessage('Пожалуйста,  введите номер автомобиля', context);
                          }
                          else if (carColorController.text.isEmpty) {
                            displayToastMessage('Пожалуйста,  введите цвет автомобиля', context);
                          } else {
                            ProgressDialog(
                              message: 'Пожалуйста подождите...',
                            );
                            saveDriverCarInfo(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(17),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('СЛЕДУЮЩИЙ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
                              Icon(Icons.arrow_forward, color: Colors.white, size: 26,)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveDriverCarInfo(context) {
    String userId = currentfirebaseUser?.uid ?? '';

    Map carInfoMap = {
      'car_model': carModelController.text.trim(),
      'car_number': carNumberController.text.trim(),
      'car_color': carColorController.text.trim(),
    };

    driversRef.child(userId).child('car_details').set(carInfoMap);
    
    Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
  }
}
