import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:maulajimessenger/Screens/logged_in_home.dart';
import 'package:maulajimessenger/login.dart';
import 'package:maulajimessenger/services/Auth.dart';
import 'package:maulajimessenger/services/Signal.dart';

import 'package:maulajimessenger/services/soc_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
void main() async{
  //socket.connect();
  // IO.Socket socket = IO.io('http://localhost:3000',
  //     OptionBuilder()
  //         .setTransports(['websocket']) // for Flutter or Dart VM
  //         .setExtraHeaders({'foo': 'bar'}) // optional
  //         .build());
  //
  // socket.connect();

// add this line

  // Dart client
//   IO.Socket socket = IO.io('http://localhost:3000', <String, dynamic>{
//     'transports': ['websocket'],
//     'autoConnect': false,
//   });
// //, 'polling', 'flashsocket'
// // Dart client
//   socket.on('connect', (_) {
//     print('connect');
//   });
//   socket.on('event', (data) => print(data));
//   socket.on('disconnect', (_) => print('disconnect'));
//   socket.on('fromServer', (_) => print(_));
//
// // add this line
//   socket.connect();

  // IO.Socket socket = IO.io('http://localhost:3000', <String, dynamic>{
  //   'transports': ['websocket', 'polling'],
  // });

  // IO.Socket socket = IO.io('http://localhost:3000');
  // socket.onConnect((_) {
  //   print('connect');
  //   socket.emit('msg', 'test');
  // });
  // socket.on('event', (data) => print(data));
  // socket.onDisconnect((_) => print('disconnect'));
  // socket.on('fromServer', (_) => print(_));
 runApp(MyApp());
 // runApp(MaterialApp(home: Soc2(),));
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maulaji Talk',
      theme: ThemeData(
        fontFamily: 'Poppins',

        primarySwatch: Colors.blue,
      ),
      home:  FutureBuilder(
        // Initialize FlutterFire:
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(
                child: Text("Error"),
              ),
            );
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return Root();
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return Scaffold(
            body: Center(
              child: Text("Loading..."),
            ),
          );
        },
      ),
    );
  }
}

class Root extends StatefulWidget {
  Root({Key key}) : super(key: key);
  dynamic userData;

  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  final FirebaseAuth _auth = FirebaseAuth.instance;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (_auth != null &&
        _auth.currentUser != null &&
        _auth.currentUser.uid != null) {
      // fetchuser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth(auth: _auth).user,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData == false ||
              snapshot.data == null ||
              snapshot.data.uid == null) {
            // login screen
            return Login(
              auth: _auth,

            );
          } else {
            // home screen

            return  FutureBuilder<SharedPreferences>(
                future: SharedPreferences.getInstance(), builder: (BuildContext context,AsyncSnapshot<SharedPreferences> projectSnap) {
              if(projectSnap.hasData && projectSnap.data!=null){

               // projectSnap.data.setString("uStatus", "online");
                return    Padding(
                  padding: const EdgeInsets.fromLTRB(0, 30,0, 0),
                  child: Home(socket:  AppSignal().initSignal(),
                    auth: FirebaseAuth.instance,

                    sharedPreferences: projectSnap.data,
                  ),
                );
              }else {
                return Scaffold(
                  body: Center(
                      child: CircularProgressIndicator()
                  ),
                );
              }

            });

          }
        } else {
          return const Scaffold(
            body: Center(
              child: Text("Loading..."),
            ),
          );
        }
      },
    );
  }
}
class MyAppSoc extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'WebSocket Demo';
    return MaterialApp(
      title: title,
      home: MyHomePage2(
        title: title,
        channel: IOWebSocketChannel.connect('wss://echo.websocket.org'),
      ),
    );
  }
}

class MyHomePage2 extends StatefulWidget {
  final String title;
  final WebSocketChannel channel;

  MyHomePage2({Key key, @required this.title, @required this.channel})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage2> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Form(
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(labelText: 'Send a message'),
              ),
            ),
            StreamBuilder(
              stream: widget.channel.stream,
              builder: (context, snapshot) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(snapshot.hasData ? '${snapshot.data}' : ''),
                );
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Send message',
        child: Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      widget.channel.sink.add(_controller.text);
    }
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }
}
class  Soc2 extends StatefulWidget {

  @override
  _Soc2State createState() => _Soc2State();
}

class _Soc2State extends State< Soc2> {
  Socket socket;
  IO.Socket socket2;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //connectToServer();
    connect2();
  }
  void connectToServer() {
    try {

      // Configure socket transports must be sepecified
      socket = io('http://127.0.0.1:3000', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });

      // Connect to websocket
      socket.connect();

      // Handle socket events
      socket.on('connect', (_) => print('connect: ${socket.id}'));
      socket.on('location', handleLocationListen);
      socket.on('typing', handleTyping);
     // socket.on('message', (data)=>print("mkl"));
      socket.on('disconnect', (data) => print('disconnect'));
      socket.on('fromServer', (dynamic) => print("er"));
      socket.on('message', (data) => print(data.toString()));
      socket.on("mkl", (data) => print("ok"));


    } catch (e) {
      print(e.toString());
    }


  }

  // Send Location to Server
  sendLocation(Map<String, dynamic> data) {
    socket.emit("location", data);
  }

  // Listen to Location updates of connected usersfrom server
  handleLocationListen(Map<String, dynamic> data) async {
    print(data);
  }

  // Send update of user's typing status
  sendTyping(bool typing) {
    socket.emit("typing",
        {
          "id": socket.id,
          "typing": typing,
        });
  }

  // Listen to update of typing status from connected users
  void handleTyping(Map<String, dynamic> data) {
    print(data);
  }

  // Send a Message to the server
  sendMessage(String message) {
    socket.emit("message",
      {
        "id": socket.id,
        "message": message, // Message to be sent
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // Listen to all message events from connected users
  void handleMessage(Map<String, dynamic> data) {
    print(data.toString());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SingleChildScrollView(
      child: InkWell(onTap: (){
        socket2.emit("mkl","dada");
        socket2.emit("mkl",{"dada":124});
        //sendMessage("mm");
      },child: Container(child: Text("Send"),),),
    ),);
  }

  void connect2() {
    // Dart client
    socket2 = IO.io('http://localhost:3000');
    socket2.onConnect((_) {
      print('connect');
      socket2.emit('msg', 'test');
    });
    socket2.on('event', (data) => print(data));
    socket2.onDisconnect((_) => print('disconnect'));
    socket2.on('fromServer', (_) => print(_));
  }
}
