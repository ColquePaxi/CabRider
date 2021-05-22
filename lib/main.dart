import 'dart:io';
import 'package:cab_rider/dataproviders/appdata.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cab_rider/screens/registrationpage.dart';
import 'package:cab_rider/screens/loginpage.dart';
import 'package:cab_rider/screens/mainpage.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'db2',
    options: Platform.isIOS
        ? const FirebaseOptions(
            googleAppID: '1:230627451097:ios:2d11f50f50b4de972adec8',
            gcmSenderID: '230627451097',
            databaseURL: 'https://geetaxi-3af1e-default-rtdb.firebaseio.com',
          )
        : const FirebaseOptions(
            googleAppID: '1:230627451097:android:4c94826d394e30532adec8',
            apiKey: 'AIzaSyCiphrCWNTWobxV6FV8vs-4ElPyTsqR3Zs',
            databaseURL: 'https://geetaxi-3af1e-default-rtdb.firebaseio.com',
          ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          fontFamily: 'Brand-Regular',
          primarySwatch: Colors.blue,
        ),
        //initialRoute: RegistrationPage.id,
        initialRoute: MainPage.id,
        routes: {
          RegistrationPage.id: (context) => RegistrationPage(),
          LoginPage.id: (context) => LoginPage(),
          MainPage.id: (context) => MainPage(),
        },
      ),
    );
  }
}
