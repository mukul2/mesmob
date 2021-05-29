
import 'dart:async';

import 'package:maulajimessenger/services/Signal.dart';
class ChatDataloadedStream{
  static ChatDataloadedStream model = null;
  final StreamController<List> _Controller = StreamController<List>.broadcast();

  Stream<List> get outData => _Controller.stream;

  Sink<List> get inData => _Controller.sink;

  dataReload(List status) {
    print("data pushed");
    fetch().then((value) => inData.add(status));
  }

  void dispose() {
    _Controller.close();
  }

  static ChatDataloadedStream getInstance() {
    if (model == null) {
      model = new ChatDataloadedStream();
      return model;
    } else {
      return model;
    }
  }

  Future<void> fetch() async {
    return;
  }
}
class ChatData {
  String room;



  ChatData();
  Stream<List> getConversation({String room}){

    AppSignal().initSignal().on(room, (data) {
      print(data);
      ChatDataloadedStream.getInstance().dataReload(data);


    });

  }





}