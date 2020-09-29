import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pozos8/provider/firebase.dart';
import 'package:pozos8/utils/dateFormat.dart';
import 'package:provider/provider.dart';

import 'package:pozos8/pages/distribudor_page.dart';
import 'package:pozos8/pages/newreg_page.dart';
import 'package:pozos8/pages/firstlog_page.dart';
import 'package:pozos8/utils/sharedP.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = new SharedP();
  await prefs.initPrefs();
  await Firebase.initializeApp();
  await getPermission();

  // Inicia el servicio en un isolate aparte
  FlutterBackgroundService.initialize(onStart);

  runApp(ChangeNotifierProvider(
    create: (context) => SharedP(),
    child: MyApp(),
  ));
}

final prefs = new SharedP();
enum LocationStatus { UNKNOWN, RUNNING, STOPPED }
CollectionReference pos = FirebaseFirestore.instance.collection('tracking');
Stream<DocumentSnapshot> _request =
    FirebaseFirestore.instance.collection('All').doc('position').snapshots();

// Parametros para el posicionamiento continuo
Stream<Position> positionStream = getPositionStream(
    desiredAccuracy: LocationAccuracy.best,
    distanceFilter: 25,
    timeInterval: 120000); // cada 120 segundos
StreamSubscription<Position> positionStreamS;
LocationStatus _status = LocationStatus.UNKNOWN;

// --------Servicios en Background--------
void onStart() async {
  // Todos lo sparametros para se ejecuten en el otro isolate
  WidgetsFlutterBinding.ensureInitialized();
  final service = FlutterBackgroundService();
  await Firebase.initializeApp();
  final prefs2 = new SharedP();
  await prefs2.initPrefs();

  // Escucha cambios para todos los usuarios
  _request.listen(onData);
  positionStreamS = positionStream.listen(contPosition);

  // _contPos.listen((event) {
  //   if (event['contPosition']) {
  //     positionStreamS = positionStream.listen(contPosition);
  //   } else {
  //     inicial ? inicial = false : positionStreamS.cancel();
  //   }
  // });

  service.setNotificationInfo(
    title: "Servicio Pozo Séptico",
    content: "Hola",
  );

  // Position position0 = await getLastKnownPosition();

  // final service = FlutterBackgroundService();
  // final audioPlayer = AudioPlayer();

  // String url =
  //     "https://www.mediacollege.com/downloads/sound-effects/nature/forest/rainforest-ambient.mp3";

  // audioPlayer.onPlayerStateChanged.listen((event) {
  //   if (event == AudioPlayerState.COMPLETED) {
  //     audioPlayer.play(url);
  //   }
  // });

  // audioPlayer.play(url);

  // service.onDataReceived.listen((event) {
  //   print(event);
  // });

  // Timer.periodic(Duration(seconds: 1), (timer) {
  //   service.setNotificationInfo(
  //     title: "My App Service",
  //     content: "Updated at ${DateTime.now()}",
  //   );

  //   service.sendData(
  //     {"current_date": DateTime.now().toIso8601String()},
  //   );
  // });
}

// Funcion de background oara la localización continua
void contPosition(Position locationDto) async {
  final service = FlutterBackgroundService();
  // Todo lo que es prefs2 es porque esta en el background
  final prefs2 = new SharedP();

  if (_status == LocationStatus.UNKNOWN) {
    _status = LocationStatus.RUNNING;
  }
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

// Escucha en segundo plano para enviar la posicion instantanea
void onData(DocumentSnapshot data) async {
  // if (data.data()['location'] ?? false) {
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

  await pos
      .doc(_date)
      .set(rep)
      .then((value) => print("Position Encontrada"))
      .catchError((error) => print("No se pudo encontrar la posición: $error"));
  // }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final prefs = new SharedP();

  Stream contPos = FlutterBackgroundService().onDataReceived;
  StreamSubscription contPosSubscription;

  @override
  void initState() {
    super.initState();
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
      print(rep);

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
