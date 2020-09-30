import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

import 'package:pozos8/pages/home_page.dart';
import 'package:pozos8/pages/newreg_page.dart';
import 'package:pozos8/pages/settings_page.dart';
import 'package:pozos8/utils/dateFormat.dart';
import 'package:pozos8/utils/sharedP.dart';

class DistribuidorPage extends StatefulWidget {
  final String routeName = 'distribuidor';
  const DistribuidorPage({Key key}) : super(key: key);

  @override
  _DistribuidorPageState createState() => _DistribuidorPageState();
}

class _DistribuidorPageState extends State<DistribuidorPage> {
  int currenIndex = 0;
  final prefs = new SharedP();
  // StreamSubscription contPosFireSubscription;

  // Stream<DocumentSnapshot> _request =
  //     FirebaseFirestore.instance.collection('All').doc('position').snapshots();

  // CollectionReference pos = FirebaseFirestore.instance.collection('tracking');

  // // Parametros para el posicionamiento continuo
  // Stream<Position> positionStream = getPositionStream(
  //     desiredAccuracy: LocationAccuracy.best,
  //     distanceFilter: 25,
  //     timeInterval: 120000); // cada 120 segundos
  // StreamSubscription<Position> positionStreamS;

  @override
  void initState() {
    super.initState();
    getPermission();
    // Inicia el servicio en un isolate aparte

    // Escucha cambios de firestore para enviarlo al background
    // Stream<DocumentSnapshot> contPosFire = FirebaseFirestore.instance
    //     .collection('choferes')
    //     .doc(prefs.nameUser)
    //     .snapshots();
    // contPosFireSubscription = contPosFire.listen(contPostData);

    // // Escucha cambios para todos los usuarios
    // _request.listen(onData);
    // positionStreamS = positionStream.listen(contPosition);
  }

  @override
  void dispose() {
    super.dispose();

    // contPosFireSubscription.cancel();
    // positionStreamS.cancel();
  }

  Future<void> getPermission() async {
    // Verificar el estado de permisos y conexión
    LocationPermission permission = await checkPermission();
    if (permission != LocationPermission.always) {
      LocationPermission permission = await requestPermission();
      if (permission != LocationPermission.always) {
        await openLocationSettings();
      }
    }
  }

  void onData(DocumentSnapshot data) async {
    print("Request location: ${data.data()}");
    Position _position =
        await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    var _date = formatDate(dateTime: DateTime.now());

    Map<String, dynamic> repFields = {
      "lat": _position.latitude,
      "lon": _position.longitude,
      "speed": _position.speed.round(),
      "heading": _position.heading.round()
    };
    Map<String, dynamic> rep = {
      "title": "track",
      "date": _date,
      "status": "publish",
      "author": prefs.userID,
      "fields": repFields
    };

    // await pos
    //     .doc(_date)
    //     .set(rep)
    //     .then((value) => print("Position Encontrada"))
    //     .catchError(
    //         (error) => print("No se pudo encontrar la posición: $error"));
  }

// Funcion de background oara la localización continua
  void contPosition(Position locationDto) async {
    final service = FlutterBackgroundService();
    // Todo lo que es prefs2 es porque esta en el background
    final prefs2 = new SharedP();

    // if (_status == LocationStatus.UNKNOWN) {
    //   _status = LocationStatus.RUNNING;
    // }
    Map<String, dynamic> _time0;
    Map<String, dynamic> _time1 = locationDto.toJson();
    (prefs2.location == '')
        ? _time0 = _time1
        : _time0 = json.decode(prefs2.location);
    prefs2.location = json.encode(_time1);
    final int difference =
        ((_time1['timestamp'] - _time0['timestamp']) / 1000).round();

    print('Segundos $difference');

    (difference > 300) // si se queda mas de xxx segundos
        ? _time0.addAll({'estadia': difference.toString(), 'title': 'stop'})
        : _time0.addAll({'estadia': '0', 'title': 'track'});

    // Envia al hilo principal para ser enviado a firebase
    service.sendData(_time0);
  }

  // Escucha cambios de firestore para enviarlo al backcround
  void contPostData(dynamic data) async {
    //Si esta logueado recien escucha, porque antes de eso no existe usuario y causa error
    prefs.contPos = data.data()['contPosition'];
    FlutterBackgroundService().sendData({
      "contPosition": prefs.contPos,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: callPage(currenIndex),
      bottomNavigationBar: _bottomNavigationBar(context),
    );
  }

  Widget _bottomNavigationBar(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.grey[800],
        textTheme: Theme.of(context)
            .textTheme
            .copyWith(caption: TextStyle(color: Colors.white)),
      ),
      child: BottomNavigationBar(
          currentIndex: currenIndex,
          onTap: (index) {
            setState(() {
              currenIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), title: Text('Inicio')),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), title: Text('Ajustes')),
            BottomNavigationBarItem(
                icon: Icon(Icons.send), title: Text('Registro'))
          ]),
    );
  }

  Widget callPage(int paginaActual) {
    switch (paginaActual) {
      case 0:
        return HomePage();
      case 1:
        return SettingsPage();
      case 2:
        {
          prefs.precio = '';
          return NuevoRegistroPage();
        }
      default:
        return HomePage();
    }
  }
}
