import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pozos8/utils/dateFormat.dart';
import 'package:toast/toast.dart';

import 'package:pozos8/api/api_WP.dart';
import 'package:pozos8/provider/firebase.dart';
import 'package:pozos8/utils/sharedP.dart';

class FirstLogPage extends StatefulWidget {
  static final String routeName = 'settings';
  // final LocationManager locationManager;

  const FirstLogPage({
    Key key,
  }) : super(key: key);
  // const FirstLogPage({Key key, this.locationManager}) : super(key: key);

  @override
  _FirstLogPageState createState() => _FirstLogPageState();
}

class _FirstLogPageState extends State<FirstLogPage> {
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  // final controller = TextEditingController();
  // LocationService myLocation = LocationService();
  final prefs = new SharedP();
  final WPAPI wordPress = new WPAPI();

  var icon;

  bool _isValidating = false;
  TextEditingController _nameController, _telfController;
  var _log;
  bool exist;

  @override
  void initState() {
    super.initState();
    _nameController = new TextEditingController(text: prefs.nameUser);
    _telfController = new TextEditingController(text: prefs.telfUser);
    // main.MyAppState().stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Align(
                //     alignment: Alignment.centerLeft,
                //     child: Padding(
                //       padding: const EdgeInsets.all(10.0),
                //       child: Text(
                //         'Limpieza de Pozos',
                //         style: Theme.of(context).textTheme.headline6,
                //       ),
                //     )),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'CREDENCIALES',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    // maxLength: 10,
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      suffixIcon: Icon(
                        Icons.person,
                        color: Colors.black,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    onChanged: (value) {
                      prefs.nameUser = value;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    maxLength: 8,
                    controller: _telfController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Teléfono',
                      suffixIcon: Icon(
                        Icons.dialpad,
                        color: Colors.black,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    onChanged: (value) {
                      prefs.telfUser = value;
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                      elevation: 5,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 2.0),
                      color: Theme.of(context).buttonColor,
                      onPressed: _isValidating ? () {} : _ingresar,
                      // onPressed: () => Navigator.pushNamed(context, 'registro'),
                      child: _isValidating
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            )
                          : Text(
                              "INGRESAR",
                              style: TextStyle(fontSize: 20),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _ingresar() async {
    setState(() {
      _isValidating = true;
    });

    _log = await wordPress.login();
    if (_log.statusCode == 200) {
      Position _position = await getCurrentPosition(
        timeLimit: Duration(minutes: 1),
      );
      print('============POSITION==============');
      print(_position);

      // await _firebaseMessaging.requestNotificationPermissions();
      // final token = await _firebaseMessaging.getToken();
      print('============userID==============');
      prefs.userID = int.parse(_log.data['user_id']);
      print(prefs.userID);

      // print('===========tokenPN==============');
      // prefs.tokenPN = token;
      // print(prefs.tokenPN);

      Map<String, dynamic> repFields = {
        "lat": _position.latitude ?? 0,
        "lon": _position.longitude ?? 0,
      };
      Map<String, dynamic> rep = {
        "title": "stop",
        "date": formatDate(dateTime: DateTime.now()),
        "status": "publish",
        "author": prefs.userID,
        "fields": repFields
      };
      prefs.pos = json.encode(rep);
      // Enviar a firebase verificar usuario
      exist = await FirebaseProvider.verifyUser();
      if (exist) {
        // Actualiza token de PN
        FirebaseProvider.userUpdate();
      } else {
        // Enviar a firebase usuario
        FirebaseProvider.addUser();
      }

      // Enviar a registro posicion
      FirebaseProvider.nuevoTracking(reporte: rep);
      prefs.log = true;

      setState(() {
        _isValidating = false;
      });
      Navigator.popAndPushNamed(context, 'distribuidor');
    } else {
      Toast.show("Credenciales inválidas. Revise Nombre y/o teléfono", context,
          duration: 4, gravity: Toast.CENTER, backgroundColor: Colors.red[400]);
      setState(() {
        _isValidating = false;
      });
    }
  }
}
