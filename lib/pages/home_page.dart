import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:pozos8/utils/sharedP.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  final String routeName = 'home';
  final prefs = new SharedP();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black12,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverSafeArea(
              // top: false,
              sliver: SliverList(
                  delegate: SliverChildListDelegate([
                Container(
                  height: 220,
                  padding: EdgeInsets.symmetric(horizontal: 50.0),
                  margin:
                      EdgeInsets.symmetric(vertical: 24.0, horizontal: 48.0),
                  child: Stack(
                    children: [
                      Image.asset('assets/cam0.png'),
                      Image.asset('assets/cam${prefs.nivelCamion}.png'),
                    ],
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                ),
              ])),
            ),
            // SliverToBoxAdapter(
            //   child: Center(
            //     child: RaisedButton(
            //       shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(30.0)),
            //       padding: EdgeInsets.symmetric(horizontal: 30.0),
            //       color: Theme.of(context).buttonColor,
            //       // onPressed: () => Navigator.pushNamed(context, 'registro'),
            //       onPressed: () {},
            //       child: Text("NUEVO REGISTRO", style: TextStyle(fontSize: 18)),
            //     ),
            //   ),
            // ),
            ListProgs()
          ],
        ),
      ),
    );
  }
}

class ListProgs extends StatefulWidget {
  ListProgs({Key key}) : super(key: key);

  @override
  _ListProgsState createState() => _ListProgsState();
}

class _ListProgsState extends State<ListProgs> {
  final prefs = new SharedP();
  String distancia;
  GeoPoint locCamion;

  StreamController<String> _controller = StreamController();

  @override
  void initState() {
    super.initState();
    _controller.stream.listen((String data) {
      print("data $data");
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = Provider.of<SharedP>(context);
    locCamion = GeoPoint((json.decode(loc.pos)['fields']['lat']),
        (json.decode(loc.pos)['fields']['lon']));
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('programas').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            List<DocumentSnapshot> docss = snapshot.data.docs;
            return SliverList(
                delegate: SliverChildBuilderDelegate((_, index) {
              Map<String, dynamic> data = docss[index].data();
              // Agrega el key de cada base de datos al mapa para depsues borrarlos
              data.addAll({'id': docss[index].id});

              bool done = data['done'];
              GeoPoint punto = data['fields']['geopoint'];
              DateTime fecha =
                  DateTime.parse(data['dateTimestamp'].toDate().toString());
              String hora = (fecha.minute < 10)
                  ? '${fecha.hour.toString()}:0${fecha.minute}'
                  : '${fecha.hour.toString()}:${fecha.minute}';
              String convertedDateTime =
                  "${fecha.day.toString().padLeft(2, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.year.toString()}";
              dist(locCamion, punto);

              // Para desplegar solo los programas para ese camion
              if (data['author'] == prefs.userID) {
                return Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    // height: 200,
                    width: double.maxFinite,
                    child: Card(
                      color: done ? Colors.grey[400] : Colors.white,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                      child: Stack(
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      (!done)
                                          ? Icon(Icons.album, size: 30)
                                          : Center(),
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                      ),
                                      Text(
                                        data['fields']['name'],
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 20,
                                        width: 45,
                                      ),
                                      Icon(
                                        Icons.phone,
                                        color: Colors.black,
                                      ),
                                      FlatButton(
                                          onPressed: () {
                                            _launchWhatsApp(
                                                phone:
                                                    '+591${data['fields']['phone']}',
                                                message: done
                                                    ? 'Somos de la empresa de limpieza de pozos, estamos en camino'
                                                    : '');
                                          },
                                          child: Text(
                                            data['fields']['phone'].toString(),
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.blue[700],
                                                fontWeight: FontWeight.bold),
                                          )),
                                      Spacer(),
                                      Text(
                                        'Bs.',
                                        style: TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        '${data['fields']['price']}',
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 25,
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 45,
                                      ),
                                      Icon(
                                        Icons.timer,
                                        color: Colors.black,
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        hora,
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Spacer(),
                                      Text(
                                        convertedDateTime,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  ),
                                  (!done)
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: _comentario(
                                              data['fields']['comment']),
                                          //
                                        )
                                      : Center(),
                                  (!done) ? Divider() : Center(),
                                  (!done)
                                      ? Row(
                                          // mainAxisAlignment permite alinear el contenido dentro de Row
                                          // en este caso le digo que use spaceBetwee, esto hara que
                                          // cualquier espacio horizontal que no se haya asignado dentro de children
                                          // se divida de manera uniforme y se coloca entre los elementos secundarios.
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            // Agregamos los botones de tipo Flat, un icono, un texto y un evento
                                            new FlatButton.icon(
                                              // Un icono puede recibir muchos atributos, aqui solo usaremos icono, tamaño y color
                                              icon: const Icon(
                                                  Icons.add_location,
                                                  color: Colors.red,
                                                  size: 28.0),
                                              label: const Text('Mapa'),
                                              // Esto mostrara 'Me encanta' por la terminal
                                              onPressed: () {
                                                MapsLauncher.launchCoordinates(
                                                    punto.latitude,
                                                    punto.longitude);
                                              },
                                            ),
                                            StreamBuilder(
                                              builder: (context, snapshot) {
                                                return Text(
                                                  'Km. $distancia',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                );
                                              },
                                            ),
                                            new FlatButton(
                                                color: Theme.of(context)
                                                    .buttonColor,
                                                child: Text('Ejecutado',
                                                    style: TextStyle(
                                                        fontSize: 18)),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30.0)),
                                                // textColor: Colors.white,
                                                onPressed: () {
                                                  prefs.precio = data['fields']
                                                          ['price']
                                                      .toString();

                                                  print(prefs.precio);
                                                  Navigator.pushNamed(
                                                      context, 'registro',
                                                      arguments: {
                                                        'precio': data['fields']
                                                            ['price'],
                                                        'id': data['id']
                                                      });
                                                })
                                          ],
                                        )
                                      : Center(),
                                ],
                              ))
                        ],
                      ),
                    ));
              }
            }, childCount: docss.length));
          } else {
            return SliverToBoxAdapter(child: CircularProgressIndicator());
          }
        });
  }

  void dist(GeoPoint locCamion, GeoPoint locCliente) {
    double distanceInMeters;
    distanceInMeters = distanceBetween(locCliente.latitude,
        locCliente.longitude, locCamion.latitude, locCamion.longitude);

    // print('==================================XXXX');

    distancia = ((distanceInMeters / 1000)).toStringAsFixed(1);
    _controller.add(distancia);
  }

  _launchWhatsApp({
    @required String phone,
    @required String message,
  }) async {
    String url = "whatsapp://send?phone=$phone&text=${Uri.parse(message)}";
    // if (Platform.isIOS) {
    //   return "whatsapp://wa.me/$phone/?text=${Uri.parse(message)}";
    // } else {
    // return "whatsapp://send?phone=$phone&text=${Uri.parse(message)}";
    // }

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _comentario(data) {
    if (data == null) {
      return null;
    } else {
      return Row(
        children: <Widget>[
          Flexible(
            child: Text(
              '$data',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 20.0, color: Colors.red),
            ),
          )
        ],
      );
    }
  }
}
