import 'dart:convert' as convert;
import 'dart:io';

import 'package:http/http.dart' as http;

import 'ResponseMovieDetail.dart';
import 'ResponseMovieSearch.dart';
import 'ResponseMovieCategory.dart';
import 'apiKey.dart';

Future fetchMovieList(int fetchPage, Function(ResponseMovieSearch res) action) async {
  await fetch(baseUrl + "discover/movie?page=" + fetchPage.toString() + "&" + apiKey, ApiContext.common((json) {
    action(ResponseMovieSearch.fromJson(json));
  }));
}

Future fetchMovieCategoryList(Function(ResponseMovieCategory res) action) async {
  await fetch(baseUrl + "/genre/movie/list?&" + apiKey, ApiContext.common((json) {
    action(ResponseMovieCategory.fromJson(json));
  }));
}

Future fetchMovieDetail(
    int id, Function(ResponseMovieDetail res) action) async {
  await fetch(baseUrl + "movie/" + id.toString() + "?&" + apiKey,
      ApiContext.common((json) {
    action(ResponseMovieDetail.fromJson(json));
  }));
}

Future fetch(String url, ApiContext apiContext) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      print(url + "  APIレスポンス::" + response.body);
      final parsed = convert.jsonDecode(response.body) as Map<String, dynamic>;
      apiContext.callback(parsed);
    }
  } catch (e) {
    if (e is SocketException) {
      print("ネットワークの接続がありません");
    } else if (e is Exception) {
      apiContext.fallback(e);
    }
  }
}

class ApiContext {
  ApiContext(this.callback, this.fallback);

  static ApiContext common(Function(Map<String, dynamic> json) callback) {
    return ApiContext((json) => {callback(json)}, (p0) => {});
  }

  final Function(Map<String, dynamic> json) callback;
  final Function(Exception) fallback;
}

const baseUrl = "https://api.themoviedb.org/3/";

double checkDouble(dynamic value) {
  if (value is String) {
    return double.parse(value);
  } else if (value is int) {
    return value.toDouble();
  } else {
    return value;
  }
}
