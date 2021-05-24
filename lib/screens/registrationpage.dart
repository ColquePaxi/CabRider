import 'package:cab_rider/screens/loginpage.dart';
import 'package:cab_rider/screens/mainpage.dart';
import 'package:cab_rider/widgets/progress_dialog.dart';
import 'package:cab_rider/widgets/taxi_button.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../brand_colors.dart';

class RegistrationPage extends StatefulWidget {
  static const String id = 'register';

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
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

  var fullNameController = TextEditingController();

  var phoneController = TextEditingController();

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  void registerUser() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Registering you...',
      ),
    );

    final FirebaseUser user = (await _auth
        .createUserWithEmailAndPassword(
        email: emailController.text, password: passwordController.text)
        .catchError((ex) {
      PlatformException thisEx = ex;
      showSnackBar(thisEx.message);
    }))
        .user;

    Navigator.pop(context);

    if (user != null) {
      DatabaseReference newUserRef =
      FirebaseDatabase.instance.reference().child('users/${user.uid}');
      Map userMap = {
        'fullname': fullNameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
      };
      newUserRef.set(userMap);
      showSnackBar('Registration successful');
      Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
    }

    ///
    /// Firebase and Flutter configuration
    /// https://firebase.flutter.dev/docs/auth/usage/
    ///
    /*
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Registering you...',
      ),
    );
    */
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
                  'Create a rider\'s account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontFamily: 'Brand-Bold'),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: fullNameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Full name',
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
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone number',
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
                          title: 'REGISTER',
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

                            if (fullNameController.text.length < 3) {
                              showSnackBar('Please provide a valid fullname');
                              return;
                            }

                            if (!emailController.text.contains('@')) {
                              showSnackBar(
                                  'Please provide a valid email address');
                              return;
                            }

                            if (phoneController.text.length < 11) {
                              showSnackBar(
                                  'Please provide a valid phone number (with área number)');
                              return;
                            }

                            if (passwordController.text.length < 8) {
                              showSnackBar(
                                  'Password must be at least 8 characteres');
                              return;
                            }

                            registerUser();
                          }),
                      FlatButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, LoginPage.id, (route) => false);
                        },
                        child: Text('Already have a RIDER account, Log in'),
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
