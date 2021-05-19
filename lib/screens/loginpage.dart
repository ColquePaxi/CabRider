import 'dart:ui';
import 'package:cab_rider/brand_colors.dart';
import 'package:cab_rider/screens/mainpage.dart';
import 'package:cab_rider/screens/registrationpage.dart';
import 'package:cab_rider/widgets/progress_dialog.dart';
import 'package:cab_rider/widgets/taxi_button.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  static const String id = 'login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  void login() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Loggin you in',
      ),
    );

    final FirebaseUser user = (await _auth
            .signInWithEmailAndPassword(
                email: emailController.text, password: passwordController.text)
            .catchError((ex) {
      PlatformException thisEx = ex;
      showSnackBar(thisEx.message);
    }))
        .user;

    //Navigator.pop(context);

    if (user != null) {
      // Verify login
      DatabaseReference userRef =
          FirebaseDatabase.instance.reference().child('users/${user.uid}');

      userRef.once().then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          Navigator.pushNamedAndRemoveUntil(
              context, MainPage.id, (route) => false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  height: 70,
                ),
                Image(
                  image: AssetImage('images/logo.png'),
                  alignment: Alignment.center,
                  height: 100,
                  width: 100,
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  'Sign in as a rider',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontFamily: 'Brand-Bold'),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email address',
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      TaxiButton(
                          title: 'LOGIN',
                          color: BrandColors.colorGreen,
                          onPressed: () async {
                            // Check network availability
                            var connectivityResult =
                                await Connectivity().checkConnectivity();
                            if (connectivityResult !=
                                    ConnectivityResult.mobile &&
                                connectivityResult != ConnectivityResult.wifi) {
                              showSnackBar('No internet connectivity');
                              return;
                            }

                            if (!emailController.text.contains('@')) {
                              showSnackBar(
                                  'Please provide a valid email address');
                              return;
                            }

                            if (passwordController.text.length < 8) {
                              showSnackBar(
                                  'Password must be at least 8 characteres');
                              return;
                            }

                            login();
                          }),
                      FlatButton(
                        onPressed: () {
                          print('chamou registration page');
                          Navigator.pushNamedAndRemoveUntil(
                              context, RegistrationPage.id, (route) => false);
                        },
                        child: Text('Don\'t have an account, sign up here'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
