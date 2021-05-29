import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:maulajimessenger/services/Settings.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';



class AppSignal {

   IO.Socket socket;

   AppSignal();
   IO.Socket initSignal(){
    if(socket==null){

      //socket = IO.io(AppSettings().Signal_link);
       socket = IO.io(AppSettings().Signal_link,
          OptionBuilder()
              //.setTransports(['websocket','polling', 'flashsocket']) // for Flutter or Dart VM
              .setTransports(['websocket']) // for Flutter or Dart VM

              .build(),);
      socket.onConnect((_) {
        print('connect');
        socket.emit('msg', 'test');
      });
      socket.on('event', (data) => print(data));
      socket.onDisconnect((_) => print('disconnect'));
      socket.on('fromServer', (_) => print(_));
      socket.on('mkl', (_) => print(_));

//{transports: ['websocket', 'polling', 'flashsocket']}


      print("trying with "+AppSettings().Signal_link);
      //socket = IO.io('https://signal1.maulaji.com');
      //socket = IO.io('http://localhost:3000');
      // socket = IO.io(AppSettings().Signal_link);
      // socket.onConnect((_) {
      //   print("connected with "+AppSettings().Signal_link);
      // });
      return socket;
    }else{

      return socket;
    }

  }




}
