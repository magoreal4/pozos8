import 'package:flutter/material.dart';
import 'package:pozos8/utils/sharedP.dart';

class SettingsPage extends StatefulWidget {
  static final String routeName = 'settings';

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _modoOscuro;
  TextEditingController _nameController, _telfController;
  final prefs = new SharedP();

  @override
  void initState() {
    super.initState();
    _modoOscuro = prefs.modoOscuro ?? false;
    _nameController = new TextEditingController(text: prefs.nameUser);
    _telfController = new TextEditingController(text: prefs.telfUser);
    // _modoOscuro = false;
    // _nameController = new TextEditingController(text: '');
    // _telfController = new TextEditingController(text: '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Ajustes'),
        ),
        body: ListView(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(10),
                child: Text(
                  'Preferencias',
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                )),
            Divider(),
            SwitchListTile(
              activeColor: Theme.of(context).primaryColor,
              value: _modoOscuro,
              title: Text('Modo Oscuro'),
              onChanged: (bool value) {
                setState(() {
                  _modoOscuro = value;
                  prefs.modoOscuro = value;
                });
              },
            ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      readOnly: true,
                      decoration: InputDecoration(
                          labelText: 'Nombre',
                          helperText: 'Unicamente el nombre'),
                      onChanged: (value) {
                        prefs.nameUser = value;
                      },
                    ),
                    TextField(
                      controller: _telfController,
                      readOnly: true,
                      decoration: InputDecoration(labelText: 'Teléfono'),
                      onChanged: (value) {
                        prefs.telfUser = value;
                      },
                    ),
                  ],
                )),
          ],
        ));
  }
}
