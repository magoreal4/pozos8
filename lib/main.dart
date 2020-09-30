import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'package:pozos8/provider/firebase.dart';
import 'package:pozos8/pages/distribudor_page.dart';
import 'package:pozos8/pages/newreg_page.dart';
import 'package:pozos8/pages/firstlog_page.dart';
import 'package:pozos8/utils/sharedP.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterBackgroundService.initialize(onStart);
  final prefs = new SharedP();
  await prefs.initPrefs();
  // await Firebase.initializeApp();

  runApp(ChangeNotifierProvider(
    create: (context) => SharedP(),
    child: MyApp(),
  ));
}

// enum LocationStatus { UNKNOWN, RUNNING, STOPPED }
// LocationStatus _status = LocationStatus.UNKNOWN;

// Parametros para el posicionamiento continuo
Stream<Position> positionStream = getPositionStream(
    desiredAccuracy: LocationAccuracy.best,
    distanceFilter: 25,
    timeInterval: 120000); // cada 120 segundos
StreamSubscription<Position> positionStreamS;

// --------Servicios en Background--------
void onStart() async {
  // Todos lo sparametros para se ejecuten en el otro isolate
  WidgetsFlutterBinding.ensureInitialized();
  print("Iniciando en Background");
  final service = FlutterBackgroundService();
  final prefs2 = new SharedP();
  await prefs2.initPrefs();
  await Firebase.initializeApp();

  // _request.listen(onData);
  positionStreamS = positionStream.listen(contPosition);

  service.setNotificationInfo(
    title: "Servicio Pozo Séptico",
    content: "Hola",
  );
}

// Funcion de background oara la localización continua
void contPosition(Position locationDto) async {
  final service = FlutterBackgroundService();
  final prefs2 = new SharedP();

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

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final prefs = new SharedP();

  Stream contPos = FlutterBackgroundService().onDataReceived;
  StreamSubscription contPosSubscription;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print("Ocurrio un error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    initializeFlutterFire();

    // Recibe los datos de la posición contínua del background
    contPosSubscription = contPos.listen(onData);
  }

  @override
  void dispose() {
    super.dispose();
    contPosSubscription.cancel();
  }

// Recibe los datos de la posición contínua del background
  void onData(dynamic data) async {
    if (data != null && prefs.log) {
      Map<String, dynamic> repFields = {
        "lat": data['latitude'],
        "lon": data['longitude'],
        "estadia": int.parse(data['estadia']),
        "speed": data['speed'].round(),
        "heading": data['heading'].round()
      };
      Map<String, dynamic> rep = {
        "title": data['title'],
        "date":
            DateTime.fromMillisecondsSinceEpoch(data['timestamp']).toString(),
        "status": "publish",
        // "author": 4,
        "author": prefs.userID,
        "fields": repFields
      };
      print('-------------------------------------------------');
      print('$rep');
      prefs.pos = json.encode(rep);

      prefs.contPos ? await FirebaseProvider.nuevoTracking(reporte: rep) : null;
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final modo = Provider.of<SharedP>(context);
    return MaterialApp(
      title: 'Pozos',
      theme: modo.modoOscuro
          ? ThemeData(
              fontFamily: 'oswald',
              brightness: Brightness.dark,
              primaryColor: Colors.amber[300],
              accentColor: Colors.amber[100],
              buttonColor: Colors.amber[400],
              buttonTheme: ButtonTheme.of(context),
              sliderTheme: SliderThemeData.fromPrimaryColors(
                  primaryColor: Colors.amber[300],
                  primaryColorDark: Colors.black87,
                  primaryColorLight: Colors.black87,
                  valueIndicatorTextStyle: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              iconTheme: IconThemeData(color: Colors.amber[300]))
          : ThemeData(
              canvasColor: Colors.amber[50],
              brightness: Brightness.light,
              primaryColor: Colors.amber[300],
              accentColor: Colors.amber[300],
              buttonColor: Colors.amber[400],
              buttonTheme: ButtonTheme.of(context),
              sliderTheme: SliderThemeData.fromPrimaryColors(
                  primaryColor: Colors.amber[300],
                  primaryColorDark: Colors.black87,
                  primaryColorLight: Colors.black87,
                  valueIndicatorTextStyle: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              iconTheme: IconThemeData(color: Colors.amber[300])),
      // initialRoute: 'firstlog',
      initialRoute: prefs.log ? 'distribuidor' : 'firstlog',
      routes: {
        // 'prueba': (context) => PruebaPage(
        //       value: locationManager,
        //     ),
        'distribuidor': (context) => DistribuidorPage(),
        'registro': (context) => NuevoRegistroPage(),
        // 'firstlog': (context) => FirstLogPage(locationManager: locationManager),
        'firstlog': (context) => FirstLogPage(),
      },
    );
  }
}
