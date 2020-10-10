import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'package:pozos8/pages/home_page.dart';
import 'package:pozos8/pages/newreg_page.dart';
import 'package:pozos8/pages/settings_page.dart';

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
  final service = FlutterBackgroundService();
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
    service.sendData(
      {"nameUser": prefs.nameUser},
    );
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

  // // Escucha cambios de firestore para enviarlo al backcround
  // void contPostData(dynamic data) async {
  //   //Si esta logueado recien escucha, porque antes de eso no existe usuario y causa error
  //   prefs.contPos = data.data()['contPosition'];
  //   FlutterBackgroundService().sendData({
  //     "contPosition": prefs.contPos,
  //   });
  // }

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
