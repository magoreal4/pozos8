import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pozos8/provider/firebase.dart';
import 'package:pozos8/utils/dateFormat.dart';
import 'package:toast/toast.dart';

import 'package:pozos8/api/api_WP.dart';
import 'package:pozos8/utils/reporteModel.dart';
import 'package:pozos8/utils/sharedP.dart';

const PADDING_8 = EdgeInsets.all(8.0);
// const URL_POSTS = '$URL_WP_BASE/registros';

class NuevoRegistroPage extends StatefulWidget {
  static final String routeName = 'registro';

  @override
  _NuevoRegistroPageState createState() => _NuevoRegistroPageState();
}

class _NuevoRegistroPageState extends State<NuevoRegistroPage> {
  final prefs = new SharedP();
  final formKey = GlobalKey<FormState>();
  final ReporteModel repForm = new ReporteModel();
  final Fields repFormFields = new Fields();
  final WPAPI wordPress = new WPAPI();
  double _valorSlider;
  TextEditingController _precioController;

  Map<String, dynamic> reporte;
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    _valorSlider = prefs.nivelCamion.toDouble();
    _precioController = new TextEditingController(text: prefs.precio);
  }

  @override
  Widget build(BuildContext context) {
    // Informacion enviada desde HomePage
    String _id;
    final Map<String, dynamic> arguments =
        ModalRoute.of(context).settings.arguments;
    if (arguments == null) {
      _id = null;
      print('No Tiene argumentos');
    } else {
      prefs.precio = arguments['precio'].toString();
      _id = arguments['id'];
      print('Tiene argumentos: ${prefs.precio} -- $_id');
    }

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Nuevo Registro"),
        ),
        body: Form(
            key: formKey,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              children: <Widget>[
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      flex: 3,
                      child: Container(
                        child: _overlapped(),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        height: 240,
                        child: _crearSlider(),
                      ),
                    )
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      flex: 4,
                      child: (_id == null) ? _flete() : Center(),
                    ),
                    Flexible(
                        flex: 3,
                        child: SizedBox(
                          width: 100.0,
                          child: _precio(),
                        )),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Center(
                    child: _boton(_id),
                  ),
                )
              ],
            )));
  }

  Widget _overlapped() {
    final items = [
      Image.asset('assets/cam0.png', fit: BoxFit.contain, height: 260),
      Image.asset(
        'assets/cam${_valorSlider.toInt()}.png',
        fit: BoxFit.contain,
        height: 260,
      ),
    ];

    List<Widget> stackLayers = List<Widget>.generate(items.length, (index) {
      return Padding(
        padding: EdgeInsets.fromLTRB(30, 0, 20, 0),
        child: items[index],
      );
    });

    return Stack(children: stackLayers);
  }

  Widget _crearSlider() {
    String _label() {
      switch (_valorSlider.toInt()) {
        case 0:
          {
            return 'vacio';
          }
        case 1:
          {
            return '1/4';
          }
        case 2:
          {
            return 'medio';
          }
        case 3:
          {
            return '3/4';
          }
        case 4:
          {
            return 'lleno';
          }
      }
      return 'vacio';
    }

    return RotatedBox(
        quarterTurns: 3,
        child: Slider(
            value: _valorSlider,
            min: 0.0,
            max: 4.0,
            divisions: 4,
            onChanged: (valor) {
              setState(() {
                _valorSlider = valor;
              });
            },
            label: _label(),
            onChangeEnd: (valor) {
              repFormFields.nivel = valor.round();
            }));
  }

  Widget _flete() {
    return CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        title: Text('Flete'),
        activeColor: Theme.of(context).primaryColor,
        checkColor: Theme.of(context).canvasColor,
        value: repFormFields.flete ?? false,
        onChanged: (bool val) {
          setState(() {
            repFormFields.flete = val;
          });
        });
  }

  Widget _precio() {
    return TextField(
      // initialValue: 0,
      maxLength: 4,
      controller: _precioController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Precio',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      onChanged: (value) {
        prefs.precio = value;
      },
    );
    // return TextFormField(
    //   initialValue: (precio == null) ? '' : precio.toString(),
    //   decoration: InputDecoration(labelText: 'Precio'),
    //   onSaved: (value) =>
    //       repForm.title == null ? repForm.title = '---' : repForm.title = value,
    //   keyboardType: TextInputType.number,
    // );
  }

  Widget _boton(_id) {
    return Center(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RaisedButton(
              onPressed: _isValidating
                  ? () {}
                  : () {
                      formKey.currentState.save();
                      _submit(_id);
                    },
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              color: Theme.of(context).buttonColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: _isValidating
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      )
                    : Text('REGISTRAR', style: TextStyle(fontSize: 18)),
              ),
            ),
          ]),
    );
  }

  Future<void> _submit(_id) async {
    setState(() {
      _isValidating = true;
    });
    prefs.nivelCamion = repFormFields.nivel;

    Position _position = await getCurrentPosition(
      timeLimit: Duration(minutes: 1),
    );

    // print("3. Coordenadas");
    // print("Latitud ${_position.latitude}");
    // print("Longitud ${_position.longitude}");

    repForm.date = formatDate(dateTime: DateTime.now());

    Map<String, dynamic> repFields = {
      "lat": _position.latitude,
      "lon": _position.longitude,
      "estadia": 0,
      "nivel": prefs.nivelCamion,
      "flete": repFormFields.flete ?? false,
      "precio": (prefs.precio == '') ? 0 : int.parse(prefs.precio)
    };
    Map<String, dynamic> rep = {
      "title": "No name",
      "date": repForm.date,
      "status": "publish",
      "author": prefs.userID,
      "fields": repFields
    };

    (_id != null)
        ? await FirebaseProvider.done(key: _id, reporte: rep)
        : await FirebaseProvider.nuevoTracking(reporte: rep);

    prefs.precio = '';
    Toast.show("Reporte Enviado", context,
        duration: 4, gravity: Toast.CENTER, backgroundColor: Colors.green);

    setState(() {
      _isValidating = false;
    });
    Timer(Duration(seconds: 2),
        () => Navigator.pushNamed(context, 'distribuidor'));
  }
}
