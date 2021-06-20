import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:maulajimessenger/Screens/logged_in_home.dart';
import 'package:maulajimessenger/login.dart';
import 'package:maulajimessenger/services/Auth.dart';
import 'package:maulajimessenger/services/Signal.dart';
import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
const _kShouldTestAsyncErrorOnInit = true;
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
 // runApp(MyApp2());
 // FirebaseCrashlytics.instance.recordError;


 // runZonedGuarded(()async {
 //
 //
 // }, FirebaseCrashlytics.instance.recordError);
 // runApp(MaterialApp(home: Soc2(),));
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(

        body:MaterialApp(debugShowCheckedModeBanner: false,
          title: 'Maulaji Talk',
          theme: ThemeData(
            fontFamily: 'Poppins',

            primarySwatch: Colors.blue,
          ),
          home: FutureBuilder(
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
        ),
      ),
    );
  }
}

/*
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  Future<void> _initializeFlutterFireFuture;

  Future<void> _testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(seconds: 2), () {
      final List<int> list = <int>[];
      print(list[100]);
    });
  }

  // Define an async function to initialize FlutterFire
  Future<void> _initializeFlutterFire() async {
    // Wait for Firebase to initialize

    if (true) {
      // Force enable crashlytics collection enabled if we're testing it.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      // Else only enable it in non-debug builds.
      // You could additionally extend this to allow users to opt-in.
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
    }

    // Pass all uncaught errors to Crashlytics.
    Function originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails errorDetails) async {
      await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      // Forward to original handler.
      originalOnError(errorDetails);
    };

    if (_kShouldTestAsyncErrorOnInit) {
      await _testAsyncErrorOnInit();
    }

    @override
    Widget build(BuildContext context) {
      return MaterialApp(debugShowCheckedModeBanner: false,
        title: 'Maulaji Talk',
        theme: ThemeData(
          fontFamily: 'Poppins',

          primarySwatch: Colors.blue,
        ),
        home: FutureBuilder(
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
}


*/

class Root extends StatefulWidget {
  Root({Key key}) : super(key: key);
  dynamic userData;

  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
 // final FirebaseAuth _auth = FirebaseAuth.instance;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration(seconds: 2), () {
      // 5s over, navigate to a new page
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>Root_afterSplach()));


     // Navigator.pushNamed(context, MaterialPageRoute(builder: (_) => Screen2()));
    });
    // if (_auth != null &&
    //     _auth.currentUser != null &&
    //     _auth.currentUser.uid != null) {
    //   // fetchuser();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset("assets/splash_app.jpg",fit: BoxFit.cover,);
    return Scaffold(body: Image.asset("assets/splash_app.jpg",fit: BoxFit.fill,),);
    // return StreamBuilder(
    //   stream: Auth(auth: _auth).user,
    //   builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
    //     if (snapshot.connectionState == ConnectionState.active) {
    //       if (snapshot.hasData == false ||
    //           snapshot.data == null ||
    //           snapshot.data.uid == null) {
    //         // login screen
    //         return Login(
    //           auth: _auth,
    //
    //         );
    //       } else {
    //         // home screen
    //
    //         return  FutureBuilder<SharedPreferences>(
    //             future: SharedPreferences.getInstance(), builder: (BuildContext context,AsyncSnapshot<SharedPreferences> projectSnap) {
    //           if(projectSnap.hasData && projectSnap.data!=null){
    //
    //            // projectSnap.data.setString("uStatus", "online");
    //             return MaterialApp(  theme: ThemeData(
    //               fontFamily: 'Poppins',
    //
    //               primarySwatch: Colors.blue,
    //             ),debugShowCheckedModeBanner: false,home:Padding(
    //               padding:  EdgeInsets.fromLTRB(0, 30,0, 0),
    //               child: Home(socket:  AppSignal().initSignal(),
    //                 auth: FirebaseAuth.instance,
    //
    //                 sharedPreferences: projectSnap.data,
    //               ),
    //             ) ,);
    //             return    Padding(
    //               padding: const EdgeInsets.fromLTRB(0, 0,0, 0),
    //               child: Home(socket:  AppSignal().initSignal(),
    //                 auth: FirebaseAuth.instance,
    //
    //                 sharedPreferences: projectSnap.data,
    //               ),
    //             );
    //           }else {
    //             return Scaffold(
    //               body: Center(
    //                   child: CircularProgressIndicator()
    //               ),
    //             );
    //           }
    //
    //         });
    //
    //       }
    //     } else {
    //       return const Scaffold(
    //         body: Center(
    //           child: Text("Loading..."),
    //         ),
    //       );
    //     }
    //   },
    // );
  }
}

class Root_afterSplach extends StatefulWidget {
  Root_afterSplach({Key key}) : super(key: key);
  dynamic userData;

  @override
  _RootStateSp createState() => _RootStateSp();
}

class _RootStateSp extends State<Root_afterSplach> {
  final FirebaseAuth _auth = FirebaseAuth.instance;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  //  FirebaseCrashlytics.instance.crash();
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
                return MaterialApp(  theme: ThemeData(
                  fontFamily: 'Poppins',

                  primarySwatch: Colors.blue,
                ),debugShowCheckedModeBanner: false,home:Padding(
                  padding:  EdgeInsets.fromLTRB(0, 30,0, 0),
                  child: Home(socket:  AppSignal().initSignal(),
                    auth: FirebaseAuth.instance,

                    sharedPreferences: projectSnap.data,
                  ),
                ) ,);
                return    Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0,0, 0),
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

class MyApp2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Field Focus',
      home: MyCustomForm(),
    );
  }
}

// Define a custom Form widget.
class MyCustomForm extends StatefulWidget {
  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

// Define a corresponding State class.
// This class holds data related to the form.
class _MyCustomFormState extends State<MyCustomForm> {
  // Define the focus node. To manage the lifecycle, create the FocusNode in
  // the initState method, and clean it up in the dispose method.
   FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();

    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text Field Focus'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // The first text field is focused on as soon as the app starts.
            TextField(
              autofocus: true,
            ),
            // The second text field is focused on when a user taps the
            // FloatingActionButton.
            TextField(
              focusNode: myFocusNode,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // When the button is pressed,
        // give focus to the text field using myFocusNode.
        onPressed: () => myFocusNode.requestFocus(),
        tooltip: 'Focus Second Text Field',
        child: Icon(Icons.edit),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}