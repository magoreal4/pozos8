import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pozos8/utils/sharedP.dart';

class FirebaseProvider {
  static CollectionReference choferes =
      FirebaseFirestore.instance.collection('choferes');
  static SharedP prefs = new SharedP();

  static Future<bool> verifyUser() async {
    return choferes
        .doc(prefs.nameUser)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        print("hola existe el documento");
        // print(documentSnapshot.data());
        return true;
      } else {
        print("no existe el documento");
        // print(documentSnapshot.data());
        return false;
      }
    });
  }

  static Future<void> addUser() {
    return choferes
        .doc(prefs.nameUser)
        .set({
          'telefono': prefs.telfUser,
          'userID_WP': prefs.userID,
          'tokenPN': prefs.tokenPN,
          'date': DateTime.now().toString()
        })
        .then((value) => print("Chofer Aceptado"))
        .catchError((error) => print("Fallo al aceptar chofer: $error"));
  }

  static Future<void> userUpdate() {
    return choferes
        .doc(prefs.nameUser)
        .update({'tokenPN': prefs.tokenPN, 'userID_WP': prefs.userID})
        .then((value) => print("Modificacion del chofer "))
        .catchError((error) => print("Fallo modificacion del chofer: $error"));
  }

  static Future<void> nuevoRegistro({Map reporte, String childBD}) {
    CollectionReference registros =
        FirebaseFirestore.instance.collection(childBD);
    return registros
        .doc(reporte['date'])
        .set(reporte)
        .then((_) => print("$childBD enviado"))
        .catchError((error) => print("Falla al enviar reporte: $error"));
  }

  static Future<void> done({String key, String childBD}) {
    CollectionReference programas =
        FirebaseFirestore.instance.collection(childBD);
    return programas
        .doc(key)
        .update({'done': true})
        .then((_) => print("Reporte atualizado"))
        .catchError((error) => print("Falla al actualizar reporte: $error"));
  }
}

// class DatabaseRequest {
//   CollectionReference _request =
//       FirebaseFirestore.instance.collection('choferes');
//   get choferes {
//     return _request.doc('Camion').snapshots().listen((event) {
//       print("CCCCCAAAAMBBIOOO");
//     });
//   }
//   // return programas
//   //     .doc(key)
//   //     .update({'done': true})
//   //     .then((_) => print("Reporte atualizado"))
//   //     .catchError((error) => print("Falla al actualizar reporte: $error"));
// }

class DatabaseChofer {
  // final String name;
  // final int telefono;
  // final String tokenPN;
  // final int userID_WP;

  // DatabaseChofer({this.name, this.telefono, this.tokenPN, this.userID_WP});

  final CollectionReference choferCollection =
      FirebaseFirestore.instance.collection('choferes');

  Stream<DocumentSnapshot> get choferes {
    return choferCollection.doc('Camion').snapshots();
  }
}
