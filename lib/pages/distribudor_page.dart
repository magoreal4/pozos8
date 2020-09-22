import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
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
          prefs.precio = "";
          return NuevoRegistroPage();
        }
      default:
        return HomePage();
    }
  }
}
