import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  StreamSubscription contPosFireSubscription;

  @override
  void initState() {
    super.initState();
    // Escucha cambios de firestore para enviarlo al background
    Stream<DocumentSnapshot> contPosFire = FirebaseFirestore.instance
        .collection('choferes')
        .doc(prefs.nameUser)
        .snapshots();
    contPosFireSubscription = contPosFire.listen(contPostData);
  }

  @override
  void dispose() {
    super.dispose();
    contPosFireSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: callPage(currenIndex),
      bottomNavigationBar: _bottomNavigationBar(context),
    );
  }

  // Escucha cambios de firestore para enviarlo al backcround
  void contPostData(dynamic data) async {
    //Si esta logueado recien escucha, porque antes de eso no existe usuario y causa error
    prefs.contPos = data.data()['contPosition'];
    FlutterBackgroundService().sendData({
      "contPosition": prefs.contPos,
    });
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
