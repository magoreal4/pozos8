// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SharedP with ChangeNotifier {
  static final SharedP _instancia = new SharedP._internal();

  factory SharedP() {
    return _instancia;
  }
  SharedP._internal();

  SharedPreferences _prefs;

  initPrefs() async {
    this._prefs = await SharedPreferences.getInstance();
  }

  // GET y SET modo oscuro
  get modoOscuro {
    return _prefs.getBool('modoOscuro') ?? false;
  }

  set modoOscuro(bool value) {
    _prefs.setBool('modoOscuro', value);
    notifyListeners();
  }

  // GET y SET nivel Camion
  get nivelCamion {
    return _prefs.getInt('nivelCamion') ?? 0;
  }

  set nivelCamion(int value) {
    _prefs.setInt('nivelCamion', value);
  }

  // GET y SET nombre ususario
  get nameUser {
    return _prefs.getString('nameUser') ?? '';
  }

  set nameUser(String value) {
    _prefs.setString('nameUser', value);
  }

  // GET y SET telefono ususario
  get telfUser {
    return _prefs.getString('telfUser') ?? '';
  }

  set telfUser(String value) {
    _prefs.setString('telfUser', value);
  }

  // GET y SET Posición
  get pos {
    return _prefs.getString('pos') ?? '';
  }

  set pos(value) {
    _prefs.setString('pos', value);
    notifyListeners();
  }

  // GET y SET primer logueo
  get log {
    return _prefs.getBool('firstLog') ?? false;
  }

  set log(bool value) {
    _prefs.setBool('firstLog', value);
    // notifyListeners();
  }

  // GET y SET userID
  get userID {
    return _prefs.getInt('userid') ?? false;
  }

  set userID(int value) {
    _prefs.setInt('userid', value);
    // notifyListeners();
  }

  // GET y SET tokenPN
  get tokenPN {
    return _prefs.getString('tokenPN') ?? false;
  }

  set tokenPN(String value) {
    _prefs.setString('tokenPN', value);
    // notifyListeners();
  }

  // GET y SET precio
  get precio {
    return _prefs.getString('precio') ?? '';
  }

  set precio(String value) {
    _prefs.setString('precio', value);
  }

  // ----------------------PARA EL BACKGROUND----------------------

  // GET y SET coordenadas para el background
  get location {
    return _prefs.getString('location') ?? '';
  }

  set location(String value) {
    _prefs.setString('location', value);
  }

  // GET y SET configuracion de posición continua
  get cPos {
    return _prefs.getBool('contPosition') ?? true;
  }

  set cPos(bool value) {
    _prefs.setBool('contPosition', value);
  }

  // GET y SET configuracion de Solo Stop
  get sStop {
    return _prefs.getBool('sStop') ?? true;
  }

  set sStop(bool value) {
    _prefs.setBool('sStop', value);
  }

  // // GET y SET configuracion de Intervalo de tiempo para posicion continua
  // get timeInter {
  //   return _prefs.getInt('timeInterval') ?? 120000;
  // }

  // set timeInter(int value) {
  //   _prefs.setInt('timeInterval', value);
  // }
}
