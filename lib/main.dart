import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
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

// --------Servicios en Background--------
void onStart() async {
  // Todos lo sparametros para se ejecuten en el otro isolate
  WidgetsFlutterBinding.ensureInitialized();
  print("Iniciando en Background");
  final service = FlutterBackgroundService();
  final prefs2 = new SharedP();
  await prefs2.initPrefs();

  service.setNotificationInfo(
    title: "Servicio Pozo Séptico",
    content: "Hola",
  );
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
