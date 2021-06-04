import 'package:cab_rider/brand_colors.dart';
import 'package:cab_rider/datamodels/directiondetails.dart';
import 'package:cab_rider/dataproviders/appdata.dart';
import 'package:cab_rider/helpers/helpermethods.dart';
import 'package:cab_rider/screens/searchpage.dart';
import 'package:cab_rider/secrets/globalvariables.dart';
import 'package:cab_rider/styles/styles.dart';
import 'package:cab_rider/widgets/brand_divider.dart';
import 'package:cab_rider/widgets/progress_dialog.dart';
import 'package:cab_rider/widgets/taxi_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  static const String id = 'mainpage';

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  DirectionDetails tripDirectionDetails;

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

  double searchSheetHeight = (Platform.isIOS) ? 300 : 275;
  double rideDetailSheetHeight = 0; // (Platform.isIOS) ? 235 : 260
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  double mapBottomPadding = 0;

  List<LatLng> polyLineCoordinates = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  var geoLocator = Geolocator();
  Position currentPosition;

  bool drawerCanOpen = true;

  void setupPositionLocator() async {
    Position position = await geoLocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = CameraPosition(target: pos, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));

    String address =
        await HelperMethods.findCoordinateAddress(position, context);
    print(address);
  }

  void showDetailSheet() async {
    await getDirection();

    setState(() {
      searchSheetHeight = 0;
      rideDetailSheetHeight = (Platform.isAndroid) ? 235 : 260;
      mapBottomPadding = (Platform.isAndroid) ? 240 : 230;
      drawerCanOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: (Container(
        width: 250,
        color: Colors.white,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.all(0),
            children: [
              Container(
                color: Colors.white,
                height: 160,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        'images/user_icon.png',
                        height: 60,
                        width: 60,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Colque',
                              style: TextStyle(
                                  fontSize: 20, fontFamily: 'Brand-bold')),
                          SizedBox(height: 5),
                          Text('View Profile'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              BrandDivider(),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(OMIcons.cardGiftcard),
                title: Text('Free Rides', style: kDrawerItemStyke),
              ),
              ListTile(
                leading: Icon(OMIcons.creditCard),
                title: Text('Payments', style: kDrawerItemStyke),
              ),
              ListTile(
                leading: Icon(OMIcons.history),
                title: Text('Ride History', style: kDrawerItemStyke),
              ),
              ListTile(
                leading: Icon(OMIcons.contactSupport),
                title: Text('Support', style: kDrawerItemStyke),
              ),
            ],
          ),
        ),
      )),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapBottomPadding),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: googlePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            // aplica o tracado do mapa aqui
            polylines: _polylines,
            // Aplica as marcas e cÌrculos no mapa
            markers: _markers,
            circles: _circles,

            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;
              setState(() {
                mapBottomPadding = (Platform.isAndroid) ? 280 : 270;
              });
              setupPositionLocator();
            },
          ),

          /// Menu button
          Positioned(
            top: 44,
            left: 20,
            child: GestureDetector(
              onTap: () {
                if (drawerCanOpen) {
                  scaffoldKey.currentState.openDrawer();
                } else {
                  resetApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        spreadRadius: 0.5,
                        offset: Offset(
                          0.7,
                          0.7,
                        ),
                      ),
                    ]),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: Icon(
                      (drawerCanOpen) ? Icons.menu_sharp : Icons.arrow_back),
                ),
              ),
            ),
          ),

          /// SearchSheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(microseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                height: searchSheetHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 15,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Nice to see you',
                        style: TextStyle(fontSize: 10),
                      ),
                      Text(
                        'Where are you going',
                        style:
                            TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () async {
                          var response = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchPage()));
                          // Essa string 'getDirection' vem l? da predictiontile.dart quando
                          // sai de l? e devolve para a mainpage esse "par?metro" de forma
                          // que ele possa ser um "gatilho" para acionar alguma a??o aqui
                          if (response == 'getDirection') {
                            //await getDirection();
                            showDetailSheet();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                spreadRadius: 0.5,
                                offset: Offset(0.7, 0.7),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_sharp,
                                  color: Colors.blueAccent,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('Serach destination'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 22,
                      ),
                      Row(
                        children: [
                          Icon(
                            OMIcons.home,
                            color: BrandColors.colorDimText,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Foi feito esse teste para ver se o provider est√° ok
                              Text(
                                  /*(Provider.of<AppData>(context).pickupAddress !=
                                      null)
                                  ? Provider.of<AppData>(context)
                                      .pickupAddress
                                      .placeName
                                  :*/
                                  'Add Home'),
                              SizedBox(height: 3),
                              Text(
                                'Your residential address',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: BrandColors.colorDimText),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      BrandDivider(),
                      SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: [
                          Icon(
                            OMIcons.workOutline,
                            color: BrandColors.colorDimText,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Add work'),
                              SizedBox(height: 3),
                              Text(
                                'Your office address',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: BrandColors.colorDimText),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// RideDetails Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(microseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      ),
                    ]),
                height: rideDetailSheetHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        color: BrandColors.colorAccent1,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: <Widget>[
                              Image.asset(
                                'images/taxi.png',
                                height: 70,
                                width: 70,
                              ),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Taxi',
                                    style: TextStyle(
                                        fontSize: 18, fontFamily: 'Brand-Bold'),
                                  ),
                                  Text(
                                      (tripDirectionDetails != null)
                                          ? tripDirectionDetails.distanceText
                                          : '',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: BrandColors.colorTextLight)),
                                ],
                              ),
                              Expanded(child: Container()),
                              Text(
                                (tripDirectionDetails != null)
                                    ? '\$${HelperMethods.estimateFares(tripDirectionDetails)}'
                                    : '',
                                style: TextStyle(
                                    fontSize: 18, fontFamily: 'Brand-Bold'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 22,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.moneyBillAlt,
                              size: 18,
                              color: BrandColors.colorTextLight,
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Text('Cash'),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: BrandColors.colorTextLight,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 22,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: TaxiButton(
                          title: 'REQUEST CAB',
                          color: BrandColors.colorGreen,
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getDirection() async {
    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;
    var pickLatLng = LatLng(pickup.latitude, pickup.longitude);
    var destLatLng = LatLng(destination.latitude, destination.longitude);

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext contex) =>
            ProgressDialog(status: 'Please waiting...'));

    var thisDetails =
        await HelperMethods.getDirectionDetails(pickLatLng, destLatLng);

    setState(() {
      tripDirectionDetails = thisDetails;
    });

    // Sair do Dialog e voltar para o contexto anteiror
    Navigator.pop(context);
    // print('RETORNOU ESSE encodedPoints');
    // print(thisDetails.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline(thisDetails.encodedPoints);

    polyLineCoordinates.clear();
    if (results.isNotEmpty) {
      results.forEach((PointLatLng points) {
        polyLineCoordinates.add(LatLng(points.latitude, points.longitude));
      });
    }

    _polylines.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),
        color: Color.fromARGB(255, 95, 109, 237),
        points: polyLineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      _polylines.add(polyline);
    });

    // Make polyline to fit into the map
    LatLngBounds bounds;

    if (pickLatLng.latitude > destLatLng.latitude &&
        pickLatLng.longitude > destLatLng.longitude) {
      bounds = LatLngBounds(southwest: destLatLng, northeast: pickLatLng);
    } else if (pickLatLng.longitude > destLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickLatLng.latitude, destLatLng.longitude),
          northeast: LatLng(destLatLng.latitude, pickLatLng.longitude));
    } else if (pickLatLng.latitude > destLatLng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destLatLng.latitude, pickLatLng.longitude),
          northeast: LatLng(pickLatLng.latitude, destLatLng.longitude));
    } else {
      bounds = LatLngBounds(southwest: pickLatLng, northeast: destLatLng);
    }

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: pickup.placeName, snippet: 'My Location'),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: destination.placeName, snippet: 'Destination'),
    );

    setState(() {
      _markers.add(pickupMarker);
      _markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
      circleId: CircleId('pickup'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 12,
      center: pickLatLng,
      fillColor: BrandColors.colorGreen,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId('destination'),
      strokeColor: BrandColors.colorAccentPurple,
      strokeWidth: 3,
      radius: 12,
      center: pickLatLng,
      fillColor: BrandColors.colorAccentPurple,
    );

    setState(() {
      _circles.add(pickupCircle);
      _circles.add(destinationCircle);
    });
  }

  resetApp() {
    setState(() {
      polyLineCoordinates.clear();
      _polylines.clear();
      _markers.clear();
      _circles.clear();
      rideDetailSheetHeight = 0;
      searchSheetHeight = (Platform.isAndroid) ? 275 : 300;
      mapBottomPadding = (Platform.isAndroid) ? 270 : 280;
      drawerCanOpen = true;
    });
    setupPositionLocator();
  }
}
