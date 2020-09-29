import 'package:dio/dio.dart';
import 'package:pozos8/utils/sharedP.dart';

class WPAPI {
  final Dio _dio = new Dio();
  final prefs = new SharedP();
  String loginURL = 'http://www.pozos.xyz/wp-json/jwt-auth/v1/token';
  String postURL = 'http://www.pozos.xyz/wp-json/wp/v2/tracking';

  Future<dynamic> login({String username, String password}) async {
    try {
      Response response = await this._dio.post(loginURL,
          data: {"username": prefs.nameUser, "password": prefs.telfUser},
          options: Options(
            headers: {'Content-type': 'application/json'},
          ));
      print("Codigo Log: ${response.statusCode}");
      return response;
    } on DioError catch (e) {
      print("Codigo Log: ${e.response.statusCode}");
      return e.response;
    }
  }

  Future post({dynamic data, String token}) async {
    try {
      Response response = await this._dio.post(postURL,
          data: data,
          options: Options(
            headers: {
              'Content-type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ));
      print("Codigo Post: ${response.statusCode}");
      return response;
    } catch (e) {
      print("Codigo Post: ${e.response.statusCode}");
      return e.response;
    }
  }
}
