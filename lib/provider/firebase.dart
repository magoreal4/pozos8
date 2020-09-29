import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pozos8/utils/sharedP.dart';

class FirebaseProvider {
  static CollectionReference chofer =
      FirebaseFirestore.instance.collection('choferes');
  static CollectionReference tracking =
      FirebaseFirestore.instance.collection('tracking');

  static SharedP prefs = new SharedP();

  static Future<bool> verifyUser() async {
    return chofer
        .doc(prefs.nameUser)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        print("Existe el chofer");
        // print(documentSnapshot.data());
        return true;
      } else {
        print("No existe registro del chofer");
        return false;
      }
    });
  }

  static Future<void> addUser() {
    return chofer
        .doc(prefs.nameUser)
        .set({
          'telefono': prefs.telfUser,
          'userID_WP': prefs.userID,
          'tokenPN': prefs.tokenPN,
          'date': DateTime.now().toString(),
          'contPosition': true
        })
        .then((value) => print("Chofer Aceptado"))
        .catchError((error) => print("Fallo al aceptar chofer: $error"));
  }

  static Future<void> userUpdate() {
    return chofer
        .doc(prefs.nameUser)
        .update({'tokenPN': prefs.tokenPN, 'userID_WP': prefs.userID})
        .then((value) => print("Modificacion del chofer "))
        .catchError((error) => print("Fallo modificacion del chofer: $error"));
  }

  static Future<void> nuevoTracking({Map reporte}) {
    return tracking
        .doc(reporte['date'])
        .set(reporte)
        .then((_) => print("${reporte['title']} enviado"))
        .catchError((error) => print("Falla al enviar reporte: $error"));
  }

  static Future<void> nuevoRegistro({Map reporte}) {
    CollectionReference registros =
        FirebaseFirestore.instance.collection('registros');
    return registros
        .doc(reporte['date'])
        .set(reporte)
        .then((_) => print("Reporte enviado"))
        .catchError((error) => print("Falla al enviar reporte: $error"));
  }

  static Future<void> done({String key, Map reporte}) {
    CollectionReference programas =
        FirebaseFirestore.instance.collection('programas');
    return programas
        .doc(key)
        .update({'done': true, 'date': reporte['date']})
        .then((_) => print("Reporte atualizado"))
        .catchError((error) => print("Falla al actualizar reporte: $error"));
  }
}
