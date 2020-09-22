import 'dart:async';
import 'dart:convert';

import 'package:carp_background_location/carp_background_location.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:provider/provider.dart';

import 'package:pozos8/pages/distribudor_page.dart';
import 'package:pozos8/pages/newreg_page.dart';
import 'package:pozos8/provider/firebase.dart';
import 'package:pozos8/pages/firstlog_page.dart';
import 'package:pozos8/utils/sharedP.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = new SharedP();
  await prefs.initPrefs();
  await Firebase.initializeApp();
  FlutterBackgroundService.initialize(onStart);

  runApp(ChangeNotifierProvider(
    create: (context) => SharedP(),
    child: MyApp(),
  ));
}

void onStart() {
  WidgetsFlutterBinding.ensureInitialized();
  final service = FlutterBackgroundService();
  service.onDataReceived.listen((event) {
    print(event);
  });

  Timer.periodic(Duration(seconds: 2), (timer) {
    service.setNotificationInfo(
      title: "My App Service",
      content: "Updated at ${DateTime.now()}",
    );

    service.sendData(
      {"current_date": DateTime.now().toIso8601String()},
    );
  });
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

enum LocationStatus { UNKNOWN, RUNNING, STOPPED }

String dtoToString(LocationDto dto) =>
    'Location ${dto.latitude}, ${dto.longitude} at ${DateTime.fromMillisecondsSinceEpoch(dto.time ~/ 1)}';

class MyAppState extends State<MyApp> {
  final prefs = new SharedP();
  bool isRunning;
  LocationDto lastLocation;
  DateTime lastTimeLocation;
  LocationManager locationManager = LocationManager.instance;
  Stream<LocationDto> dtoStream;
  StreamSubscription<LocationDto> dtoSubscription;
  LocationStatus _status = LocationStatus.UNKNOWN;
  Map<String, dynamic> repStore;

  @override
  void initState() {
    super.initState();
    locationManager.interval = 20;
    locationManager.distanceFilter = 25;
    locationManager.notificationTitle = 'CARP Location Example';
    locationManager.notificationMsg = 'CARP is tracking your location';
    dtoStream = locationManager.dtoStream;
    dtoSubscription = dtoStream.listen(onData);
    //start();
  }

  @override
  void dispose() {
    super.dispose();
    dtoSubscription.cancel();
    locationManager.stop();
  }

  void start() async {
    // Subscribe if it hasnt been done already
    if (dtoSubscription != null) {
      dtoSubscription.cancel();
    }
    dtoSubscription = dtoStream.listen(onData);
    await locationManager.start();

    _status = LocationStatus.RUNNING;

    // Obtener coordenadas y colocarles en shared prefs. para que no cause error
  }

  void stop() async {
    // setState(() {
    _status = LocationStatus.STOPPED;
    // });
    dtoSubscription.cancel();
    await locationManager.stop();
  }

  void onData(LocationDto dto) async {
    if (_status == LocationStatus.UNKNOWN) {
      _status = LocationStatus.RUNNING;
    }
    if (_status == LocationStatus.RUNNING && prefs.log == true && dto != null) {
      Map<String, dynamic> repFields = {
        "lat": dto.latitude,
        "lon": dto.longitude,
        "estadia": 0,
        "speed": dto.speed.round(),
        "heading": dto.heading.round()
      };
      Map<String, dynamic> rep = {
        "title": "tracking",
        "date": dto.time.round().toString(),
        // "date": DateTime.fromMicrosecondsSinceEpoch(dto.time.round() * 1000)
        //     .toString(),
        "status": "publish",
        "author": "1",
        "fields": repFields
      };

      (prefs.location != '')
          ? repStore = json.decode(prefs.location)
          : repStore = rep;
      prefs.location = json.encode(rep);

      // print(repStore['date']);
      // print(dto.time.round());

      final int difference =
          ((dto.time.round() - int.parse(repStore['date'])) / 1000).round();

      print('Segundos $difference');

      if (difference > 65) {
        repStore['title'] = 'stopping';
        repStore['fields']['estadia'] = difference.toString();
        repStore['date'] = DateTime.fromMicrosecondsSinceEpoch(
                int.parse(repStore['date']) * 1000)
            .toString();
        await FirebaseProvider.nuevoRegistro(
            reporte: repStore, childBD: 'tracking');
        print('-------------------------------------------------');
        print('$repStore');
      } else {
        rep['date'] =
            DateTime.fromMicrosecondsSinceEpoch(int.parse(rep['date']) * 1000)
                .toString();
        await FirebaseProvider.nuevoRegistro(reporte: rep, childBD: 'tracking');
        print('-------------------------------------------------');
        print('$rep');
      }
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
      // initialRoute: 'firstlog',r
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
