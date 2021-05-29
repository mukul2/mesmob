import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _baseUrl = "https://api.callgpnow.com/api/";
String _baseUrl_image = "https://api.callgpnow.com/";

class CallButonsClickStreamCamera {
  static CallButonsClickStreamCamera model = null;
  final StreamController<bool> _Controller = StreamController<bool>.broadcast();

  Stream<bool> get outData => _Controller.stream;

  Sink<bool> get inData => _Controller.sink;

  dataReload(bool status) {
    fetch().then((value) => inData.add(status));
  }

  void dispose() {
    _Controller.close();
  }

  static CallButonsClickStreamCamera getInstance() {
    if (model == null) {
      model = new CallButonsClickStreamCamera();
      return model;
    } else {
      return model;
    }
  }

  Future<void> fetch() async {
    return;
  }
}

class CallButonsClickStreamScreen{
  static CallButonsClickStreamScreen model = null;
  final StreamController<bool> _Controller = StreamController<bool>.broadcast();

  Stream<bool> get outData => _Controller.stream;

  Sink<bool> get inData => _Controller.sink;

  dataReload(bool status) {
    fetch().then((value) => inData.add(status));
  }

  void dispose() {
    _Controller.close();
  }

  static CallButonsClickStreamScreen getInstance() {
    if (model == null) {
      model = new CallButonsClickStreamScreen();
      return model;
    } else {
      return model;
    }
  }

  Future<void> fetch() async {
    return;
  }
}


class WidgetReadyStream{
  static WidgetReadyStream model = null;
  final StreamController<Widget> _Controller = StreamController<Widget>.broadcast();

  Stream<Widget> get outData => _Controller.stream;

  Sink<Widget> get inData => _Controller.sink;

  dataReload(Widget status) {
    fetch().then((value) => inData.add(status));
  }

  void dispose() {
    _Controller.close();
  }

  static WidgetReadyStream getInstance() {
    if (model == null) {
      model = new WidgetReadyStream();
      return model;
    } else {
      return model;
    }
  }

  Future<void> fetch() async {
    return;
  }
}



class SelfStatusStream{
  static SelfStatusStream model = null;
  final StreamController<String> _Controller = StreamController<String>.broadcast();

  Stream<String> get outData => _Controller.stream;

  Sink<String> get inData => _Controller.sink;

  dataReload(String status) {
    fetch().then((value) => inData.add(status));
  }

  void dispose() {
    _Controller.close();
  }

  static SelfStatusStream getInstance() {
    if (model == null) {
      model = new SelfStatusStream();
      return model;
    } else {
      return model;
    }
  }

  Future<void> fetch() async {
    return;
  }
}


class CheckFndIsAdded{
  static CheckFndIsAdded model = null;
  final StreamController<bool> _Controller = StreamController<bool>.broadcast();

  Stream<bool> get outData => _Controller.stream;

  Sink<bool> get inData => _Controller.sink;

  dataReload(bool status) {
    fetch().then((value) => inData.add(status));
  }

  void dispose() {
    _Controller.close();
  }

  static CheckFndIsAdded getInstance() {
    if (model == null) {
      model = new CheckFndIsAdded();
      return model;
    } else {
      return model;
    }
  }

  Future<void> fetch() async {
    return;
  }
}





class AllFndListStream{
  static AllFndListStream model = null;
  final StreamController<List> _Controller = StreamController<List>.broadcast();

  Stream<List> get outData => _Controller.stream;

  Sink<List> get inData => _Controller.sink;

  dataReload(List status) {
    fetch().then((value) => inData.add(status));
  }

  void dispose() {
    _Controller.close();
  }

  static AllFndListStream getInstance() {
    if (model == null) {
      model = new AllFndListStream();
      return model;
    } else {
      return model;
    }
  }

  Future<void> fetch() async {
    return;
  }
}



class getUserDetailStream{
  static getUserDetailStream model = null;
  final StreamController<dynamic> _Controller = StreamController<dynamic>.broadcast();

  Stream<dynamic> get outData => _Controller.stream;

  Sink<dynamic> get inData => _Controller.sink;

  dataReload(dynamic status) {
    fetch().then((value) => inData.add(status));
  }

  void dispose() {
    _Controller.close();
  }

  static getUserDetailStream getInstance() {
    if (model == null) {
      model = new getUserDetailStream();
      return model;
    } else {
      return model;
    }
  }

  Future<void> fetch() async {
    return;
  }
}



class FetchUserInfoStream{
  static FetchUserInfoStream model = null;
  final StreamController<dynamic> _Controller = StreamController<dynamic>.broadcast();

  Stream<dynamic> get outData => _Controller.stream;

  Sink<dynamic> get inData => _Controller.sink;

  dataReload(dynamic status) {
    fetch().then((value) => inData.add(status));
  }

  void dispose() {
    _Controller.close();
  }

  static FetchUserInfoStream getInstance() {
    if (model == null) {
      model = new FetchUserInfoStream();
      return model;
    } else {
      return model;
    }
  }

  Future<void> fetch() async {
    return;
  }
}


class LastMessagesStream{
  static LastMessagesStream model = null;
  final StreamController<List> _Controller = StreamController<List>.broadcast();

  Stream<List> get outData => _Controller.stream;

  Sink<List> get inData => _Controller.sink;

  dataReload(List status) {
    fetch().then((value) => inData.add(status));
  }

  void dispose() {
    _Controller.close();
  }

  static LastMessagesStream getInstance() {
    if (model == null) {
      model = new LastMessagesStream();
      return model;
    } else {
      return model;
    }
  }

  Future<void> fetch() async {
    return;
  }
}