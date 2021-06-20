import 'dart:async';
import 'dart:typed_data';
import 'package:emojis/emojis.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:emojis/emoji.dart';
import 'package:http/http.dart' as http;
import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maulajimessenger/Screens/chatThread.dart';
import 'package:maulajimessenger/services/Settings.dart';
import 'package:maulajimessenger/services/Signal.dart';
import 'package:maulajimessenger/Screens/user_sector.dart';
import 'package:maulajimessenger/services/functions.dart';
import 'package:maulajimessenger/streams/buttonStreams.dart';
import 'dart:io';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/src/foundation/constants.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maulajimessenger/call/WebCallingSimple.dart';
import 'package:maulajimessenger/call/WebCallingSimpleConf.dart';
import 'package:maulajimessenger/login.dart';
import 'package:maulajimessenger/services/Auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:maulajimessenger/services/chat_data_stream.dart';

StreamSocket streamSocket = new StreamSocket();

HashMap onlineUser = new HashMap<String, int>();
HashMap busyUser = new HashMap<String, int>();
HashMap awayUser = new HashMap<String, int>();

String base = "https://talk.maulaji.com/";
bool selfIsOnline = true;

bool selfIsBusy = false;

bool selfIsAway = false;

class Home extends StatefulWidget {
  int selectedTabMenu = 0;
  Widget chatBodyWidget = Center(
      child: Image.asset(
    "assets/background.png",
    fit: BoxFit.cover,
  ));

  bool isSearchModeOn = false;
  bool isCallFullScreen = true;
  String userStatus = "free";
  int CallDuration = 0;

  double sectorOneContentWidth = 0 ;

  int selectedItem = 0;
  String partnerId;
  String partnerPhoto;
  String partnerName;

  final FirebaseAuth auth;
  dynamic chatBody;
  bool showEmojiList = false;
  bool showEmojiListSingle = false;
  SharedPreferences sharedPreferences;
  bool showMobileView = false;
  bool showProfileCompleteDialog = false;

  dynamic currentProfile;

  bool shouldShowIncomming = false;
  bool isRingTonePlaying = false;
  Widget callWidget = Text("");
  bool callWidgetShow = false;

  bool showMiniProfile = false;

  bool showSplash = true;
  String searchKey = "";

  int mobileViewLevel = 1;
  IO.Socket socket;
  Home({
    Key key,
    @required this.auth,
    @required this.socket,
    @required this.sharedPreferences,
  }) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<Home> {
  TextEditingController controller = new TextEditingController();
  TextEditingController controllerGrp = new TextEditingController();
  bool audioVolume = true;
  IO.Socket socket2;

  chatWidgetUpdate(Widget wid) {
    print("widget founD ");

    if(widget.showMobileView){
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>wid));

    }else{
      WidgetReadyStream.getInstance().dataReload(wid);

    }


    // setState(() {
    //   widget.chatBodyWidget = wid;
    // });
  }

  doSomething(data) {
    startChatBodyViewCreate(data);
    // setState(() {
    //   widget.chatBody = data;
    //
    // });
  }

  final GlobalKey _menuKey = new GlobalKey();
  TextEditingController searchController = new TextEditingController();
  AudioPlayer audioPlayer;

  playLocal() async {
    if (true) {
      if (widget.isRingTonePlaying == false) {
        setState(() {
          widget.isRingTonePlaying = true;
        });
        //   audioPlayer.seek(Duration(seconds: 0)).then((value) {});
      //  audioPlayer.resume();

        audioPlayer = await AudioPlayer();
        if (kIsWeb) {
          await audioPlayer.setUrl("assets/assets/ring.mp3", isLocal: true);
          audioPlayer.play("assets/assets/ring.mp3",isLocal: true);
        } else {
          const kUrl1 = "assets/ring.mp3";
          final bytes = await  rootBundle.load('assets/ring.mp3');
          //final bytes = await rootBundle.load('assets/ring.mp3');
          final dir = await getApplicationDocumentsDirectory();
          final file = File('${dir.path}/audio.mp3');
          await file.writeAsBytes(bytes.buffer
              .asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
          //   await file.writeAsBytes(bytes);

          audioPlayer.play(file.path,isLocal: true);


        }




        // audioPlayer.onPlayerCompletion.listen((event) {
        //   audioPlayer.seek(Duration(seconds: 0)).then((value) {
        //     audioPlayer.resume();
        //   });
        //
        // });
      }
    }
  }

  StopRing() async {
    // audioPlayer.resume();

    if (widget.isRingTonePlaying) {
      audioPlayer.pause();
      setState(() {
        widget.isRingTonePlaying = false;
      });
    }
  }
  initAudioAndPlay() async {
    audioPlayer = await AudioPlayer();
    if (kIsWeb) {
      await audioPlayer.setUrl("assets/assets/ring.mp3", isLocal: true);
      audioPlayer.play("assets/assets/ring.mp3",isLocal: true);
    } else {
      const kUrl1 = "assets/ring.mp3";
      final bytes = await  rootBundle.load('assets/ring.mp3');
      //final bytes = await rootBundle.load('assets/ring.mp3');
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/audio.mp3');
      await file.writeAsBytes(bytes.buffer
          .asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
      //   await file.writeAsBytes(bytes);

      audioPlayer.play(file.path,isLocal: true);


    }

    // await audioPlayer.setUrl("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3");
  }
  initAudio() async {
    audioPlayer = await AudioPlayer();
    if (kIsWeb) {
      await audioPlayer.setUrl("assets/assets/ring.mp3", isLocal: true);
    } else {
      const kUrl1 = "assets/ring.mp3";
      final bytes = await  rootBundle.load('assets/ring.mp3');
      //final bytes = await rootBundle.load('assets/ring.mp3');
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/audio.mp3');
      await file.writeAsBytes(bytes.buffer
          .asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
   //   await file.writeAsBytes(bytes);

      audioPlayer.setUrl(file.path, isLocal: true);
      //audioPlayer.resume();


      // await audioPlayer.setUrl("assets/assets/ring.mp3", isLocal: true);
      // await audioPlayer.setReleaseMode(ReleaseMode.STOP); // set release mode so that it never releases
      //
      // // on button click
      // await audioPlayer.resume();


      //
      // final byteData = await rootBundle.load('assets/ring.mp3');
      //
      // final file = File('${(await getTemporaryDirectory()).path}/ring.mp3');
      // await file.writeAsBytes(byteData.buffer
      //     .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      // //  audioPlayer.play(file.path,isLocal: true);
      // audioPlayer.setUrl(file.path, isLocal: true);
    }

    // await audioPlayer.setUrl("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3");
  }

  @override
  void initState() {
    initSignaling();
    callReceiveSignal();

    if (!kIsWeb) {
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          widget.showSplash = false;
        });
      });
    }

    initAudio();
    // TODO: implement initState
    super.initState();

    startChatBodyViewCreate(null);
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > 500) {
      // DeviceModeMobile.getInstance().dataReload();

      setState(() {
        widget.showMobileView = false;
        widget.sectorOneContentWidth = 349;
        //widget.isCallFullScreen = false;
      });
    } else {
      //DeviceModeDesktop.getInstance().dataReload();
      setState(() {
        widget.showMobileView = true;
        widget.sectorOneContentWidth = MediaQuery.of(context).size.width;
      });
    }


    if(widget.shouldShowIncomming)
      return Scaffold(body: showIncommingScreen(widget.socket),);
    else return Scaffold(body: SectorOne(socket: widget.socket,
        width: widget.sectorOneContentWidth,
        isMobileView: widget.showMobileView,
        auth: widget.auth,
        chatWidgetUpdate: chatWidgetUpdate),);

    return widget.shouldShowIncomming?Scaffold(body: showIncommingScreen(widget.socket),): Scaffold(
      body: !widget.showMobileView
          ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectorOne(socket: widget.socket,width: widget.sectorOneContentWidth,
                    isMobileView: widget.showMobileView,
                    auth: widget.auth,
                    chatWidgetUpdate: chatWidgetUpdate),
                Container(
                  color: Colors.grey,
                  width: 1,
                  height: MediaQuery.of(context).size.height,
                ),
                getBody(),
              ],
            )
          : SectorOne(socket: widget.socket,
          width: widget.sectorOneContentWidth,
          isMobileView: widget.showMobileView,
          auth: widget.auth,
          chatWidgetUpdate: chatWidgetUpdate),
    );

    return Scaffold(
      backgroundColor: Color.fromARGB(5, 0, 0, 0),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, kIsWeb ? 0 : 30, 0, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Padding(
            //   padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            //   child: widget.callWidgetShow && widget.showMobileView
            //       ? Container(height: widget.isCallFullScreen
            //               ? MediaQuery.of(context).size.height
            //               : 50,
            //           width: MediaQuery.of(context).size.width,
            //           color: Colors.redAccent,
            //           child: Stack(
            //             children: [
            //               Align(
            //                 alignment: Alignment.center,
            //                 child: Container(
            //                     height: MediaQuery.of(context).size.height - 70,
            //                     child: widget.callWidget),
            //               ),
            //               Align(
            //                 alignment: Alignment.topCenter,
            //                 child: InkWell(
            //                     onTap: () {
            //                       setState(() {
            //                         widget.isCallFullScreen =
            //                             !widget.isCallFullScreen;
            //                       });
            //                     },
            //                     child: Container(
            //                         height: 50,
            //                         width: MediaQuery.of(context).size.width,
            //                         color: Colors.redAccent,
            //                         child: Center(
            //                             child: Text(
            //                           widget.isCallFullScreen
            //                               ? "Back to Chat"
            //                               : "Back to Call",
            //                           style: TextStyle(color: Colors.white),
            //                         )))),
            //               ),
            //             ],
            //           ),
            //         )
            //       : Container(
            //           height: 0,
            //           width: 0,
            //         ),
            // ),
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: !widget.showMobileView
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  width: 349,
                                  child: SectorOne(
                                      auth: widget.auth,
                                      chatWidgetUpdate: chatWidgetUpdate)),
                              Container(
                                color: Colors.grey,
                                width: 1,
                                height: widget.showMobileView &&
                                        widget.callWidgetShow
                                    ? MediaQuery.of(context).size.height - 70
                                    : MediaQuery.of(context).size.height,
                              ),
                              getBody(),
                            ],
                          )
                        : widget.mobileViewLevel == 1
                            ? Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                        width: 349,
                                        child: SectorOne(
                                            auth: widget.auth,
                                            chatWidgetUpdate:
                                                chatWidgetUpdate)),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: !widget.showMobileView
                                        ? Align(
                                            alignment: Alignment.topRight,
                                            child: Visibility(
                                              visible: widget.callWidgetShow,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Card(
                                                  elevation: 10,
                                                  child: Container(
                                                    //color: Colors.grey,
                                                    height: widget
                                                            .isCallFullScreen
                                                        ? MediaQuery.of(context)
                                                            .size
                                                            .height
                                                        : 300,
                                                    width: widget
                                                            .isCallFullScreen
                                                        ? MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            0
                                                        : (300),
                                                    child: Stack(
                                                      children: [
                                                        Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child:
                                                              widget.callWidget,
                                                        ),
                                                        Align(
                                                          alignment: Alignment
                                                              .bottomLeft,
                                                          child: InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  widget.isCallFullScreen =
                                                                      !widget
                                                                          .isCallFullScreen;
                                                                });
                                                              },
                                                              child: Container(
                                                                  color: Colors
                                                                      .white,
                                                                  child: Icon(
                                                                    widget.isCallFullScreen
                                                                        ? Icons
                                                                            .fullscreen_exit
                                                                        : Icons
                                                                            .fullscreen_outlined,
                                                                    color: Colors
                                                                        .black,
                                                                  ))),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            width: 0,
                                            height: 0,
                                          ),
                                  ),
                                ],
                              )
                            : getBody(),
                  ),
                  widget.callWidgetShow && !widget.showMobileView
                      ? Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Container(
                              //color: Colors.grey,
                              height: widget.isCallFullScreen
                                  ? (MediaQuery.of(context).size.height)
                                  : (widget.showMobileView ? 70 : 0),
                              width: widget.isCallFullScreen
                                  ? (widget.showMobileView
                                      ? MediaQuery.of(context).size.width
                                      : MediaQuery.of(context).size.width - 0)
                                  : (500),
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: widget.callWidget,
                                  ),
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            widget.isCallFullScreen =
                                                !widget.isCallFullScreen;
                                          });
                                        },
                                        child: Container(
                                            color: Colors.white,
                                            child: Icon(
                                              widget.isCallFullScreen
                                                  ? Icons.fullscreen_exit
                                                  : Icons.fullscreen_outlined,
                                              color: Colors.black,
                                            ))),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(
                          width: 0,
                          height: 0,
                        ),
                  widget.shouldShowIncomming
                      ? showIncommingScreen(widget.socket)
                      : Container(
                          height: 0,
                          width: 0,
                        ),
                  !kIsWeb && widget.showSplash
                      ? Align(
                          child: Image.asset(
                            "assets/splash_app.jpg",
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                          ),
                        )
                      : Container(
                          height: 0,
                          width: 0,
                        )
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: Column(
        children: [
          widget.shouldShowIncomming
              ? Container(
                  color: Colors.redAccent,
                  height: 60,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: FloatingActionButton(
                                onPressed: () {
                                  String partnerID = widget.partnerId;
                                  if (partnerID != null) {}
                                },
                                child: Icon(Icons.call, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Container(
                  height: 0,
                  width: 0,
                ),
          !widget.showMobileView
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectorOne(
                        auth: widget.auth, chatWidgetUpdate: chatWidgetUpdate),
                    Container(
                      color: Colors.grey,
                      width: 1,
                      height: MediaQuery.of(context).size.height,
                    ),
                    getBody(),
                  ],
                )
              : SectorOne(
                  auth: widget.auth, chatWidgetUpdate: chatWidgetUpdate),
        ],
      ),
    );

    return Scaffold(
      body: widget.shouldShowIncomming
          ? Container(
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FloatingActionButton(
                            onPressed: () {
                              String partnerID = widget.partnerId;
                              if (partnerID != null) {}
                            },
                            child: Icon(Icons.call, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          : !widget.showMobileView
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectorOne(
                        auth: widget.auth, chatWidgetUpdate: chatWidgetUpdate),
                    Container(
                      color: Colors.grey,
                      width: 1,
                      height: MediaQuery.of(context).size.height,
                    ),
                    getBody(),
                  ],
                )
              : SectorOne(
                  auth: widget.auth, chatWidgetUpdate: chatWidgetUpdate),
    );
  }

  Widget getBody() {
    //WidgetReadyStream.getInstance()
    return StreamBuilder<Widget>(
        // Initialize FlutterFire:
        //  future: Firebase.initializeApp(),
        stream: WidgetReadyStream.getInstance().outData,
        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            print("a new widget should show");
            return Container(
              width: widget.showMobileView
                  ? MediaQuery.of(context).size.width
                  : MediaQuery.of(context).size.width - 358,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Container(color: Colors.white, child: snapshot.data),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  // Future<void> _handleCameraAndMic() async {
  //   await PermissionHandler().requestPermissions(
  //     [PermissionGroup.camera, PermissionGroup.microphone],
  //   );
  // }
  void initCallIntent(String callTYpe, String ownid, String partner,
      bool isCaller, BuildContext context, FirebaseAuth auth) async {
    //socket2.emit("calldial",{"partner":partner});
    NewIncommingCallBroadCaster.getInstance().dataReload(NewIncCallModel(status: false));
    setState(() {
      widget.shouldShowIncomming = false;
    });

    if (true) {
      if (!kIsWeb) {
        // await _handleCameraAndMic();
      }
/*
    QuerySnapshot callerNameQ = await firestore
        .collection("users")
        .where("uid", isEqualTo: isCaller ? ownid : partner)
        .get();
    String callerName = callerNameQ.docs.first.data()["name"];

    QuerySnapshot targetNameQ = await firestore
        .collection("users")
        .where("uid", isEqualTo: isCaller ? partner : ownid)
        .get();
    String targetName = targetNameQ.docs.first.data()["name"];
    await firestore.collection("callQue").doc(ownid).set({
      "caller": isCaller ? ownid : partner,
      "target": isCaller ? partner : ownid,
      "callerName": callerName,
      "targetName": targetName
    });
    await firestore.collection("callQue").doc(partner).set({
      "caller": isCaller ? ownid : partner,
      "target": isCaller ? partner : ownid,
      "callerName": callerName,
      "targetName": targetName
    });
    await firestore.collection("refresh").doc(ownid).delete();
    await firestore.collection("refresh").doc(partner).delete();
    firestore
        .collection("callQue")
        .doc(ownid)
        .snapshots()
        .listen((valueCaller) {
      if (valueCaller.exists &&
          valueCaller.data() != null &&
          valueCaller.data()["active"] == null) {} else {
        setState(() {
          widget.callWidgetShow = false;
          widget.userStatus = "incall";
        });
      }
    });

 */
      List ids = [];
      ids.add(ownid);
      ids.add(partner);
      ids.sort();

      doSomething() {
        setState(() {
          widget.callWidgetShow = false;
          widget.userStatus = "free";
          widget.CallDuration = 0;
        });
        //   Navigator.pop(context);
      }

      callUserIsNoAvailable() {
        setState(() {
          widget.callWidgetShow = false;
        });
        // Navigator.pop(context);
      }
      // firestore.collection("callHistory").add({
      //   "caller": isCaller ? ownid : partner,
      //   "target": isCaller ? partner : ownid,
      //   "time":DateTime.now().millisecondsSinceEpoch
      // }).then((value) {
      //
      // });

      callStartedNotify() {
        // setState(() {
        //   widget.CallDuration = widget.CallDuration + 1 ;
        // });
        if (false) {
          setState(() {
            widget.CallDuration = widget.CallDuration + 1;
          });

          Timer.periodic(Duration(milliseconds: 1000), (timer) {
            if (mounted) {
              setState(() {
                widget.CallDuration = widget.CallDuration + 1;
              });
            } else {
              timer.cancel();
            }
          });
        }
      }

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WillPopScope(
                    onWillPop: () async => false,
                    child: SimpleWebCall(
                      containsVideo: false,
                      ownID: ownid,
                      partnerid: partner,
                      isCaller: isCaller,
                      partnerPair: ids.first + "-" + ids.last,
                      callback: doSomething,
                      callStartedNotify: callStartedNotify,
                      callUserIsNoAvailable: callUserIsNoAvailable,
                      auth: auth,
                    ),
                  )));

      if (widget.showMobileView) {}
    }
  }

  void initCallIntentMobile(String callTYpe, String ownid, String partner,
      bool isCaller, BuildContext context) async {
    print("found");
    if (!kIsWeb) {
      // await _handleCameraAndMic();
    }

/*
    await firestore.collection("callQue").doc(ownid).set({
      "caller": isCaller ? ownid : partner,
      "target": isCaller ? partner : ownid
    });
    await firestore.collection("callQue").doc(partner).set({
      "caller": isCaller ? ownid : partner,
      "target": isCaller ? partner : ownid
    });
    await firestore.collection("refresh").doc(ownid).delete();
    await firestore.collection("refresh").doc(partner).delete();
    firestore
        .collection("callQue")
        .doc(ownid)
        .snapshots()
        .listen((valueCaller) {
      if (valueCaller.exists &&
          valueCaller.data() != null &&
          valueCaller.data()["active"] == null) {
      } else {
        setState(() {
          widget.callWidgetShow = false;
        });
      }

    });

 */
    List ids = [];
    ids.add(ownid);
    ids.add(partner);
    ids.sort();

    doSomething() {
      setState(() {
        widget.callWidgetShow = false;
      });
    }

/*
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WillPopScope(
                  onWillPop: () async => false,
                  child: SimpleWebCall(
                    containsVideo: callTYpe == false,
                    ownID: ownid,
                    partnerid: partner,
                    isCaller: isCaller,
                    firestore: firestore,
                    partnerPair: ids.first + "-" + ids.last,
                  ),
                )));

 */
  }

  Widget getEmailFromId(body) {
    return Text(
      "demo email",
      style: TextStyle(),
    );
  }

  Widget createLastChatList() {
    //return Text("Please wait") ;
    List oneS = [];
    List oneR = [];
    List Sum = [];

    Widget returnWidget = Text("Please wait");

    return returnWidget;

    /*

    StreamBuilder<QuerySnapshot>(
        stream: widget.firestore
            .collection("last")
            .where("sender", isEqualTo: widget.auth.currentUser.uid)
            .snapshots(),
        builder: (context, projectSnapSender) {
          List allHistory = [];
          if (projectSnapSender.hasData) {
            if (true || projectSnapSender.data.docs.length > 0)
              allHistory.addAll(projectSnapSender.data.docs);
            return StreamBuilder<QuerySnapshot>(
                stream: widget.firestore
                    .collection("last")
                    .where("receiver", isEqualTo: widget.auth.currentUser.uid)
                    .snapshots(),
                builder: (context, projectSnapReceiver) {
                  if (projectSnapReceiver.hasData) {
                    if (true|| projectSnapReceiver.data.docs.length > 0)
                      allHistory.addAll(projectSnapSender.data.docs);
                  } else {
                    return Text("Please wait");
                  }
                  List filteredData = [];
                  for (int i = 0; i < allHistory.length; i++) {
                    if ( allHistory[i].data()["sender"] != widget.auth.currentUser.uid) {
                      filteredData.add(allHistory[i]);
                    }
                    if ( allHistory[i].data()["receiver"] !=
                        widget.auth.currentUser.uid) {
                      filteredData.add(allHistory[i]);
                    }
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: (filteredData == null)
                        ? 0
                        : filteredData.length,
                    itemBuilder:
                        (BuildContext context, int index) {
                      return Container(
                        child: new InkWell(
                          onTap: () async {
                            setState(() {
                              widget.chatBody =
                                  filteredData[index]
                                      .data();
                              widget.selectedItem = index;
                            });
                          },
                          child: ListTile(
                            tileColor:
                            widget.selectedItem == index
                                ? Color.fromARGB(
                                255, 206, 231, 255)
                                : Color.fromARGB(
                                255, 249, 252, 255),
                            leading: CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(
                                    "https://st.depositphotos.com/2101611/4338/v/600/depositphotos_43381243-stock-illustration-male-avatar-profile-picture.jpg")),
                            // title: Text(filteredData[index].data()["receiver"]),
                            title: getNameFromId(filteredData[index].data(),false),
                            subtitle: Padding(
                              padding:
                              const EdgeInsets.all(5.0),
                              child: Text("Sub title"),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                });
          } else {
            return Text("No Chat history");
            return StreamBuilder<QuerySnapshot>(
                stream: widget.firestore
                    .collection("last")
                    .where("receiver",
                    isEqualTo:
                    widget.auth.currentUser.uid)
                    .snapshots(),
                builder: (context, projectSnapReceiver) {
                  if (projectSnapReceiver.hasData) {
                    if (projectSnapReceiver
                        .data.docs.length >
                        0)
                      allHistory.addAll(
                          projectSnapSender.data.docs);
                  } else {
                    return Text("Please wait");
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: (allHistory == null)
                        ? 0
                        : allHistory.length,
                    itemBuilder:
                        (BuildContext context, int index) {
                      return Container(
                        child: new InkWell(
                          onTap: () async {
                            setState(() {
                              widget.chatBody =
                                  allHistory[index].data();
                              widget.selectedItem = index;
                            });
                          },
                          child: ListTile(
                            tileColor:
                            widget.selectedItem == index
                                ? Color.fromARGB(
                                255, 206, 231, 255)
                                : Color.fromARGB(
                                255, 249, 252, 255),
                            leading: CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(
                                    "https://st.depositphotos.com/2101611/4338/v/600/depositphotos_43381243-stock-illustration-male-avatar-profile-picture.jpg")),
                            title: Text(allHistory[index]
                                .data()["receiver"]),
                            subtitle: Padding(
                              padding:
                              const EdgeInsets.all(5.0),
                              child: Text("Sub title"),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                });
            ;
          }
        })

     */
  }

  String getCallTime() {
    // return " 00:" + widget.CallDuration.toString();
  }

  getString() {}

  void initSignaling() async {
    Timer.periodic(Duration(milliseconds: 500), (timer) async {
      if (mounted) {
        SharedPreferences prefs;
        Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
        prefs = await _prefs;
        String userStatus = prefs.getString("uStatus");

        if (userStatus == "online") {
          widget.socket.emit('setOnline', {"userId": widget.auth.currentUser.uid});
        }
        if (userStatus == "away") {
          widget.socket.emit('setAway', {"userId": widget.auth.currentUser.uid});
        }
        if (userStatus == "busy") {
          widget.socket.emit('setBusy', {"userId": widget.auth.currentUser.uid});
        }
        if (userStatus == "offline") {}
      }
    });

    widget.socket.on("online", (data) {
      print("online users");
      // print(data.toString());
      onlineUser[data] = DateTime.now().millisecondsSinceEpoch;
      //print(onlineUser);
    });
    widget.socket.on("busy", (data) {
      print("busy users");
      // print(data.toString());
      busyUser[data] = DateTime.now().millisecondsSinceEpoch;
      //print(onlineUser);
    });
    widget.socket.on("away", (data) {
      print("away users");
      // print(data.toString());
      awayUser[data] = DateTime.now().millisecondsSinceEpoch;
      //print(onlineUser);
    });
    widget.socket.on(widget.auth.currentUser.uid, (data) {
      print("you have data income");
    });

    // Timer.periodic(Duration(milliseconds: 10000), (timer) {
    //   if (mounted) {
    //     onlineUser.clear();
    //   } else {
    //     timer.cancel();
    //   }
    // });

    // socket2.on('getOnline', (data) {
    //   List all = [];
    //  // all = jsonDecode(data.toString());
    //  // print(data);
    //   all.clear();
    //   jsonDecode(data.toString()).asMap().forEach((i, value) {
    //     print('index=$i, value=$value');
    //     all.add(value);
    //   });
    //   print(all.length.toString());
    // });
  }

  void callReceiveSignal() {
    try {
      widget.socket.on("callincome" + widget.auth.currentUser.uid,
          (data) {
        showIncome(data);
        print("call income hit");
        print(data);
        widget.socket.emit("ringing", {"id": widget.auth.currentUser.uid});
       // NewIncommingCallBroadCaster.getInstance().dataReload(true);
        NewIncommingCallBroadCaster.getInstance().dataReload(NewIncCallModel(status: true,body: data));
      });
    } catch (e) {}
    // Timer.periodic(Duration(milliseconds: 1000), (timer) {
    //   if (mounted) {
    //     if(lastSeenTime+3000>DateTime.now().millisecondsSinceEpoch){
    //
    //     }else{
    //       widget.shouldShowIncomming = false ;
    //
    //     }
    //     StopRing();
    //
    //   }else{
    //     timer.cancel();
    //   }
    // });
  }

  void sendMessage(String val, String type, String name) async {
    print("sent " + type);
    String room = createRoomName(
        widget.auth.currentUser.uid,
        widget.chatBody["sender"] != null
            ? (widget.chatBody["sender"] == widget.auth.currentUser.uid
                ? widget.chatBody["receiver"]
                : widget.chatBody["sender"])
            : widget.chatBody["uid"]);

    // await widget.firestore.collection("last").doc(room).set({
    //   "message": val,
    //   "type": type,
    //   "fname": name,
    //   "sender": widget.auth.currentUser.uid,
    //   "receiver": widget.chatBody["sender"] != null
    //       ? (widget.chatBody["sender"] == widget.auth.currentUser.uid
    //           ? widget.chatBody["receiver"]
    //           : widget.chatBody["sender"])
    //       : widget.chatBody["uid"]
    // });

    // await widget.firestore.collection(room).add({
    //   "time": DateTime.now().millisecondsSinceEpoch,
    //   "message": val,
    //   "type": type,
    //   "fname": name,
    //   "sender": widget.auth.currentUser.uid,
    //   "receiver": widget.chatBody["sender"] != null
    //       ? (widget.chatBody["sender"] == widget.auth.currentUser.uid
    //           ? widget.chatBody["receiver"]
    //           : widget.chatBody["sender"])
    //       : widget.chatBody["uid"]
    // });
  }

  void sendMessageGroup(
      String val, String type, String name, String groupID) async {
    print("sent " + type);
    print("sent " + type);

    dynamic me = {
      "time": DateTime.now().millisecondsSinceEpoch,
      "message": val,
      "type": type,
      "fname": name,
      "sender": widget.auth.currentUser.uid,
    };

    widget.socket.emit("saveMesageGroup", {"fileName": groupID, "message": me});
    print({"fileName": groupID, "message": me});
  }

  void showIncome(dynamic data) {
    //  int lastSeenTime = DateTime.now().millisecondsSinceEpoch;

    if (this.mounted) {
      widget.socket.on("callCanceled" + data["callerId"], (data) {
        print("callended on other side");
        Navigator.pop(context);

        setState(() {
          widget.shouldShowIncomming = false;
        });
        StopRing();
        NewIncommingCallBroadCaster.getInstance().dataReload(NewIncCallModel(status: false,));
      });
    }

    if (this.mounted) {
      setState(() {
        // Your state change code goes here
        playLocal();
        setState(() {
         // playLocal();
         // NewIncommingCallBroadCaster.getInstance().dataReload(true);
          NewIncommingCallBroadCaster.getInstance().dataReload(NewIncCallModel(status: true,body: data));
          widget.shouldShowIncomming = true;
          widget.partnerName =
              data["callerName"] != null ? data["callerName"] : "No Name";
          //widget.partnerName ="caller" ;
          widget.partnerId = data["callerId"];
          widget.partnerPhoto = data["photo"];
          //  lastSeenTime =  DateTime.now().millisecondsSinceEpoch;
          // widget.partnerId = "id" ;
        });
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) =>Scaffold(body: showIncommingScreen(widget.socket),)));
      });
    } else {
      print("income dialog stopped ");
    }
  }

  getSmallTab() {
    if (widget.selectedTabMenu == 0) {
      return LastChatHistoryWidget(
        //widgetparent: widget,
        callback: doSomething,

        firebaseAuth: widget.auth,
      );
    } else if (widget.selectedTabMenu == 1) {
    } else if (widget.selectedTabMenu == 2) {}
  }

  void startChatBodyViewCreate(dynamic bodyCreate) {
    setState(() {
      if (bodyCreate == null) {
        chatWidgetUpdate(Center(
            child: Image.asset(
          "assets/background.png",
          fit: BoxFit.cover,
        )));
      } else {
        call(dynamic data,String type) {
          print(data);
          try {
            // initCallIntent("v", widget.auth.currentUser.uid, data, true,
            //     widget.firestore, context, widget.auth);
          } catch (e) {
            print(e.toString());
          }
        }

        chatWidgetUpdate(Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChatThread(whileCall: false,
            chatBody: bodyCreate,
            auth: widget.auth,
            call: call,
          ),
        ));
      }
    });
  }

  Widget getListOfPeople(List users) {
    List<Widget> allnames = [];
    for (int i = 0; i < users.length; i++) {
      allnames.add(Padding(
        padding: const EdgeInsets.all(0.0),
        child: getNameFromIdR(
          users[i],
          false,
        ),
      ));
      allnames.add(Text(", "));
    }
    return Row(
      children: allnames,
    );
  }

  Widget showIncommingScreen(IO.Socket socket) {
    return Center(
      child: Container(
        height: widget.showMobileView
            ? MediaQuery.of(context).size.height
            : MediaQuery.of(context).size.height * 0.4,
        width: widget.showMobileView
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.width * 0.4,
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.blue,
                Colors.lightBlueAccent,
                Colors.blueAccent,
                Colors.lightBlue,
              ],
            )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Incomming Call",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                )),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: widget.partnerPhoto != null
                    ? CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                      base + widget.partnerPhoto),
                )
                    : Image.asset(
                    "assets/user_photo.png"),
              ),
            ),
            Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.partnerName,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                crossAxisAlignment:
                CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        audioPlayer.pause();

                        if (true) {
                          String partnerID =
                              widget.partnerId;
                          if (partnerID != null) {
                            try {
                             if(mounted){
                               CommonFunctions(
                                   auth: widget.auth)
                                   .initCallIntent(socket: socket,
                                   callTYpe: "v",
                                   ownid: widget
                                       .auth
                                       .currentUser
                                       .uid,
                                   partner: partnerID,
                                   isCaller: false,
                                   context: context);

                               NewIncommingCallBroadCaster.getInstance().dataReload(NewIncCallModel(status: false));
                               setState(() {
                                 widget.shouldShowIncomming =
                                 false;
                               });
                             }
                            } catch (e) {
                              print("exceptio of call");
                              print(e.toString());
                            }
                            // initCallIntent(
                            //     "a",
                            //     widget
                            //         .auth.currentUser.uid,
                            //     partnerID,
                            //     false,
                            //     widget.firestore,
                            //     context,
                            //     widget.auth);
                          }
                        }
                      },
                      child: Card(
                        color: Colors.greenAccent,
                        child: Center(
                            child: Padding(
                              padding:
                              const EdgeInsets.all(8.0),
                              child: Text(
                                "Answer",
                                style: TextStyle(
                                    color: Colors.white),
                              ),
                            )),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        StopRing();
                        socket.emit(
                            "reject", {
                          "id":
                          widget.auth.currentUser.uid
                        });
                        NewIncommingCallBroadCaster.getInstance().dataReload(NewIncCallModel(status: false));

                        setState(() {
                          widget.shouldShowIncomming =
                          false;
                        });
                        //Navigator.pop(context);
                        if (false) {}
                      },
                      child: Card(
                        color: Colors.redAccent,
                        child: Center(
                            child: Padding(
                              padding:
                              const EdgeInsets.all(8.0),
                              child: Text(
                                "Decline",
                                style: TextStyle(
                                    color: Colors.white),
                              ),
                            )),
                      ),
                    ),
                  )
                ],
              ),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.all(20.0),
            //       child: FloatingActionButton(
            //         backgroundColor: Colors.greenAccent,
            //         onPressed: () {
            //           String partnerID = widget.partnerId;
            //           if (partnerID != null) {
            //             initCallIntent(
            //                 "a",
            //                 widget.auth.currentUser.uid,
            //                 partnerID,
            //                 false,
            //                 widget.firestore,
            //                 context);
            //           }
            //         },
            //         child: Icon(Icons.call, color: Colors.white),
            //       ),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.all(20.0),
            //       child: FloatingActionButton(
            //         backgroundColor: Colors.redAccent,
            //         onPressed: () {
            //           widget.firestore
            //               .collection("callQue")
            //               .doc(widget.auth.currentUser.uid)
            //               .update({"active": false});
            //           widget.firestore
            //               .collection("callQue")
            //               .doc(widget.partnerId)
            //               .update({"active": false});
            //         },
            //         child:
            //             Icon(Icons.call_end, color: Colors.white),
            //       ),
            //     )
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}

Widget getListOfPeople(List users) {
  List<Widget> allnames = [];
  for (int i = 0; i < users.length; i++) {
    allnames.add(Padding(
      padding: const EdgeInsets.all(0.0),
      child: getNameFromIdR(
        users[i],
        false,
      ),
    ));
    allnames.add(Text(", "));
  }
  return Row(
    children: allnames,
  );
}

class LastChatHistoryWidget extends StatefulWidget {
  String selectedItemId;

  void Function(dynamic) callback;

  FirebaseAuth firebaseAuth;
  List allData = [];

  List oneS = [];
  List oneR = [];
  List Sum = [];

  //Home widgetparent;
  IO.Socket socket;

  // Widget returnWidget = Scaffold(body: Center(child: Text("Please wait"),),);
  Widget returnWidget = Padding(
    padding: EdgeInsets.all(50),
    child: CircularProgressIndicator(),
  );

  LastChatHistoryWidget(
      {
      //this.widgetparent,
      this.firebaseAuth,
      this.callback,
      this.socket});

  @override
  _LastChatHistoryWidgetState createState() => _LastChatHistoryWidgetState();
}

class _LastChatHistoryWidgetState extends State<LastChatHistoryWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    downloadLastChatData();
/*
    Timer.periodic(Duration(milliseconds: 1000), (timer) {
      if (mounted) {
        widget.firestore
            .collection("last")
            .where("sender", isEqualTo: widget.firebaseAuth.currentUser.uid)
            .get()
            .then((value) {
          if (mounted) {
            setState(() {
              widget.oneS = value.docs;
              /* widget.Sum.clear();
                widget.Sum .addAll(widget.oneS);
                widget.Sum .addAll(widget.oneR);

                */
            });
          }

          widget.firestore
              .collection("last")
              .where("receiver", isEqualTo: widget.firebaseAuth.currentUser.uid)
              .get()
              .then((value) {
            if (mounted) {
              setState(() {
                widget.oneR = value.docs;
                widget.Sum.clear();
                widget.Sum.addAll(widget.oneS);
                widget.Sum.addAll(widget.oneR);
              });
              setState(() {
                widget.returnWidget = ListView.builder(
                    shrinkWrap: true,
                    itemCount: (widget.Sum == null || widget.Sum == null)
                        ? 0
                        : widget.Sum.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        tileColor: widget.selectedItemId != null &&
                                ((widget.selectedItemId ==
                                        widget.Sum[index].data()["receiver"]) |
                                    (widget.selectedItemId ==
                                        widget.Sum[index].data()["sender"]))
                            ? Color.fromARGB(255, 217, 236, 255)
                            : Color.fromARGB(255, 239, 247, 255),
                        onTap: () {
                          setState(() {
                            widget.selectedItemId =
                                widget.Sum[index].data()["receiver"] ==
                                        widget.firebaseAuth.currentUser.uid
                                    ? widget.Sum[index].data()["sender"]
                                    : widget.Sum[index].data()["receiver"];
                          });
                          widget.callback(widget.Sum[index].data());
                          // setState(() {
                          //   // widget.chatBody = filtereData[index];
                          //   widget.selectedItemId =
                          //       widget.Sum[index].data()["receiver"] ==
                          //               widget.firebaseAuth.currentUser.uid
                          //           ? widget.Sum[index].data()["sender"]
                          //           : widget.Sum[index].data()["receiver"];
                          // });

                          // setState(() {
                          //   //  widget.widgetparent.chatBody =  widget.Sum[index];
                          //   widget.widgetparent.selectedItem = index;
                          // });
                          // if (widget.widgetparent.showMobileView) {
                          //   setState(() {
                          //     widget.widgetparent.mobileViewLevel = 2;
                          //
                          //   });
                          // }
                        },
                        leading: CommonFunctions(
                                firestore: widget.firestore,
                                auth: FirebaseAuth.instance,
                                onlineUser: onlineUser,
                                busyUser: busyUser,
                                awayUser: awayUser)
                            .prePareUserPhoto(
                                uid: widget.Sum[index].data()["receiver"] ==
                                        widget.firebaseAuth.currentUser.uid
                                    ? widget.Sum[index].data()["sender"]
                                    : widget.Sum[index].data()["receiver"]),
                        // leading: prePareUserPhoto(
                        //     widget.firebaseAuth,
                        //     widget.Sum[index].data()["receiver"] ==
                        //             widget.firebaseAuth.currentUser.uid
                        //         ? widget.Sum[index].data()["sender"]
                        //         : widget.Sum[index].data()["receiver"]),
                        title: getNameFromIdR(
                            widget.Sum[index].data()["receiver"] ==
                                    widget.firebaseAuth.currentUser.uid
                                ? widget.Sum[index].data()["sender"]
                                : widget.Sum[index].data()["receiver"],
                            false,
                            widget.firestore,
                            widget.firebaseAuth),
                        subtitle: Text(widget.Sum[index].data()["message"]),
                      );
                    });
              });
            }
          });
        });
      }
    });

 */

/*

    widget.firestore
        .collection("last")
        .where("sender", isEqualTo: widget.firebaseAuth.currentUser.uid)
        .snapshots().listen((event) {
      if(event.size>0 && event.docs.length>0){


        widget.oneS = event.docs;
        widget.Sum.clear();
        widget.Sum .addAll(widget.oneS);
        widget.Sum .addAll(widget.oneR);



        setState(() {


        widget.oneS = event.docs;
        widget.Sum.clear();
        widget.Sum .addAll(widget.oneS);
        widget.Sum .addAll(widget.oneR);

        widget.returnWidget = ListView.builder(
            shrinkWrap: true,
            itemCount:
            (widget.Sum == null || widget.Sum == null)
                ? 0
                : widget.Sum.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(tileColor:  widget.selectedItemId!=null && ((widget.selectedItemId ==  widget.Sum[index].data()["receiver"]) |( widget.selectedItemId ==  widget.Sum[index].data()["sender"]))?Color.fromARGB(255, 217, 236, 255 ):Colors.white,onTap: (){
                setState(() {
                 // widget.chatBody = filtereData[index];
                  widget.selectedItemId =  widget.Sum[index].data()["receiver"]== widget.firebaseAuth.currentUser.uid? widget.Sum[index].data()["sender"]: widget.Sum[index].data()["receiver"];
                });
              },leading: CircleAvatar(radius: 18,),title:getNameFromIdR( widget.Sum[index].data()["receiver"]== widget.firebaseAuth.currentUser.uid? widget.Sum[index].data()["sender"]: widget.Sum[index].data()["receiver"] ,false,widget.firestore,widget.firebaseAuth) ,subtitle: Text(widget.Sum[index].data()["message"]),);

            });
        });

      }

    });
    widget.firestore
        .collection("last")
        .where("receiver", isEqualTo: widget.firebaseAuth.currentUser.uid)
        .snapshots().listen((event) {
      if(event.size>0 && event.docs.length>0){

        setState(() {


        widget.oneR = event.docs;
        widget.Sum.clear();
        widget.Sum .addAll(widget.oneS);
        widget.Sum .addAll(widget.oneR);

        widget.returnWidget =  ListView.builder(
            shrinkWrap: true,
            itemCount:
            (widget.Sum == null || widget.Sum == null)
                ? 0
                : widget.Sum.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(tileColor: widget.selectedItemId!=null && ((widget.selectedItemId ==  widget.Sum[index].data()["receiver"]) |( widget.selectedItemId ==  widget.Sum[index].data()["sender"]))?Color.fromARGB(255, 217, 236, 255 ):Colors.white,onTap: (){
                setState(() {
                 // widget.chatBody = filtereData[index];
                  widget.selectedItemId =  widget.Sum[index].data()["receiver"]== widget.firebaseAuth.currentUser.uid? widget.Sum[index].data()["sender"]: widget.Sum[index].data()["receiver"];
                });
              },leading: CircleAvatar(radius: 18,),title:getNameFromIdR( widget.Sum[index].data()["receiver"]== widget.firebaseAuth.currentUser.uid? widget.Sum[index].data()["sender"]: widget.Sum[index].data()["receiver"] ,false,widget.firestore,widget.firebaseAuth) ,subtitle: Text(widget.Sum[index].data()["message"]),);

            });
        });
      }

    });
    */
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Text(snapshot.data.length.toString());
            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  //  return Text(d[index]["uid"]);
                  return Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: ListTile(
                          onTap: () {
                            print(snapshot.data[index]["uid"]);
                            // setState(() {
                            //   widget.selectedItemId =d[index]["uid"];
                            // });
                            widget.callback(snapshot.data[index]["uid"]);
                            // setState(() {
                            //   // widget.chatBody = filtereData[index];
                            //   widget.selectedItemId =
                            //       widget.Sum[index].data()["receiver"] ==
                            //               widget.firebaseAuth.currentUser.uid
                            //           ? widget.Sum[index].data()["sender"]
                            //           : widget.Sum[index].data()["receiver"];
                            // });
                            //
                            // setState(() {
                            //   //  widget.widgetparent.chatBody =  widget.Sum[index];
                            //   widget.widgetparent.selectedItem = index;
                            // });
                            // if (widget.widgetparent.showMobileView) {
                            //   setState(() {
                            //     widget.widgetparent.mobileViewLevel = 2;
                            //
                            //   });
                            // }
                          },
                          subtitle:
                              Text(snapshot.data[index]["data"]["message"]),
                          leading: CommonFunctions(
                                  auth: FirebaseAuth.instance,
                                  onlineUser: onlineUser,
                                  busyUser: busyUser,
                                  awayUser: awayUser)
                              .prePareUserPhoto(
                                  uid: snapshot.data[index]["uid"]),
                          //  title: FetchUserNameWidget(uid: d[index]["uid"] ,)),
                          //  title: getUserName(d[index]["uid"])),
                          title: FetchUserNameWidget(
                            uid: snapshot.data[index]["uid"],
                          ))

                      // title:getNameFromIdR(
                      //   d[index]["uid"],
                      //   false,
                      //   widget.firestore,
                      //   widget.firebaseAuth) ,),
                      );
                });
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Future getData() async {
    var url = Uri.parse(AppSettings().Api_link +
        'getUserDetail?id=' +
        widget.firebaseAuth.currentUser.uid);
    var response = await http.get(url);
    print(response.body);
    return jsonDecode(response.body);
  }

  void downloadLastChatData() {
    Future getData() async {
      var url = Uri.parse(AppSettings().Api_link +
          'getUserDetail?id=' +
          widget.firebaseAuth.currentUser.uid);
      var response = await http.get(url);
      return jsonDecode(response.body);
    }

    setState(() {
      widget.returnWidget = FutureBuilder<List>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    //  return Text(d[index]["uid"]);
                    return Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: ListTile(
                            onTap: () {
                              print(snapshot.data[index]["uid"]);
                              // setState(() {
                              //   widget.selectedItemId =d[index]["uid"];
                              // });
                              widget.callback(snapshot.data[index]["uid"]);
                              // setState(() {
                              //   // widget.chatBody = filtereData[index];
                              //   widget.selectedItemId =
                              //       widget.Sum[index].data()["receiver"] ==
                              //               widget.firebaseAuth.currentUser.uid
                              //           ? widget.Sum[index].data()["sender"]
                              //           : widget.Sum[index].data()["receiver"];
                              // });
                              //
                              // setState(() {
                              //   //  widget.widgetparent.chatBody =  widget.Sum[index];
                              //   widget.widgetparent.selectedItem = index;
                              // });
                              // if (widget.widgetparent.showMobileView) {
                              //   setState(() {
                              //     widget.widgetparent.mobileViewLevel = 2;
                              //
                              //   });
                              // }
                            },
                            subtitle:
                                Text(snapshot.data[index]["data"]["message"]),
                            leading: CommonFunctions(
                                    auth: FirebaseAuth.instance,
                                    onlineUser: onlineUser,
                                    busyUser: busyUser,
                                    awayUser: awayUser)
                                .prePareUserPhoto(
                                    uid: snapshot.data[index]["uid"]),
                            //  title: FetchUserNameWidget(uid: d[index]["uid"] ,)),
                            //  title: getUserName(d[index]["uid"])),
                            title: FetchUserNameWidget(
                              uid: snapshot.data[index]["uid"],
                            ))

                        // title:getNameFromIdR(
                        //   d[index]["uid"],
                        //   false,
                        //   widget.firestore,
                        //   widget.firebaseAuth) ,),
                        );
                  });
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          });
    });

    List d = [];

    print("should download last chats");
    // widget.signal.on(widget.firebaseAuth.currentUser.uid, (data) {
    //  // print(data.toString());
    //
    //   data.forEach((k,v) {
    //     d.add({"uid":k,"data":v});
    //
    //   });
    //
    //   try{
    //     if(mounted){
    //       setState(() {
    //         widget.returnWidget = ListView.builder(
    //             shrinkWrap: true,
    //             itemCount:data.length,
    //             itemBuilder: (BuildContext context, int index) {
    //             //  return Text(d[index]["uid"]);
    //               return Padding(
    //                 padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
    //                 child: ListTile(    onTap: () {
    //                   print(d[index]["uid"]);
    //                   // setState(() {
    //                   //   widget.selectedItemId =d[index]["uid"];
    //                   // });
    //                   widget.callback(d[index]["uid"]);
    //                   // setState(() {
    //                   //   // widget.chatBody = filtereData[index];
    //                   //   widget.selectedItemId =
    //                   //       widget.Sum[index].data()["receiver"] ==
    //                   //               widget.firebaseAuth.currentUser.uid
    //                   //           ? widget.Sum[index].data()["sender"]
    //                   //           : widget.Sum[index].data()["receiver"];
    //                   // });
    //                   //
    //                   // setState(() {
    //                   //   //  widget.widgetparent.chatBody =  widget.Sum[index];
    //                   //   widget.widgetparent.selectedItem = index;
    //                   // });
    //                   // if (widget.widgetparent.showMobileView) {
    //                   //   setState(() {
    //                   //     widget.widgetparent.mobileViewLevel = 2;
    //                   //
    //                   //   });
    //                   // }
    //                 },subtitle: Text(d[index]["data"]["message"]),
    //                   leading: CommonFunctions(
    //                     firestore: widget.firestore,
    //                     auth: FirebaseAuth.instance,
    //                     onlineUser: onlineUser,
    //                     busyUser: busyUser,
    //                     awayUser: awayUser)
    //                     .prePareUserPhoto(
    //                     uid:d[index]["uid"]),
    //                //  title: FetchUserNameWidget(uid: d[index]["uid"] ,)),
    //                 //  title: getUserName(d[index]["uid"])),
    //                   title:  FetchUserNameWidget(uid:d[index]["uid"] ,))
    //
    //                   // title:getNameFromIdR(
    //                   //   d[index]["uid"],
    //                   //   false,
    //                   //   widget.firestore,
    //                   //   widget.firebaseAuth) ,),
    //               );
    //               return Text(d[index]["uid"]);
    //               return ListTile(
    //                 tileColor: widget.selectedItemId != null &&
    //                     ((widget.selectedItemId ==
    //                         data[index]["receiver"]) |
    //                     (widget.selectedItemId ==
    //                         data[index]["sender"]))
    //                     ? Color.fromARGB(255, 217, 236, 255)
    //                     : Color.fromARGB(255, 239, 247, 255),
    //                 onTap: () {
    //                   setState(() {
    //                     widget.selectedItemId =
    //                     data[index]["receiver"] ==
    //                         widget.firebaseAuth.currentUser.uid
    //                         ? data[index]["sender"]
    //                         : data[index]["receiver"];
    //                   });
    //                   widget.callback(data[index].data());
    //                   // setState(() {
    //                   //   // widget.chatBody = filtereData[index];
    //                   //   widget.selectedItemId =
    //                   //       widget.Sum[index].data()["receiver"] ==
    //                   //               widget.firebaseAuth.currentUser.uid
    //                   //           ? widget.Sum[index].data()["sender"]
    //                   //           : widget.Sum[index].data()["receiver"];
    //                   // });
    //
    //                   // setState(() {
    //                   //   //  widget.widgetparent.chatBody =  widget.Sum[index];
    //                   //   widget.widgetparent.selectedItem = index;
    //                   // });
    //                   // if (widget.widgetparent.showMobileView) {
    //                   //   setState(() {
    //                   //     widget.widgetparent.mobileViewLevel = 2;
    //                   //
    //                   //   });
    //                   // }
    //                 },
    //                 leading: CommonFunctions(
    //                     firestore: widget.firestore,
    //                     auth: FirebaseAuth.instance,
    //                     onlineUser: onlineUser,
    //                     busyUser: busyUser,
    //                     awayUser: awayUser)
    //                     .prePareUserPhoto(
    //                     uid:data[index].data()["receiver"] ==
    //                         widget.firebaseAuth.currentUser.uid
    //                         ?data[index].data()["sender"]
    //                         : data[index].data()["receiver"]),
    //                 // leading: prePareUserPhoto(
    //                 //     widget.firebaseAuth,
    //                 //     widget.Sum[index].data()["receiver"] ==
    //                 //             widget.firebaseAuth.currentUser.uid
    //                 //         ? widget.Sum[index].data()["sender"]
    //                 //         : widget.Sum[index].data()["receiver"]),
    //                 title: getNameFromIdR(
    //                     data[index].data()["receiver"] ==
    //                         widget.firebaseAuth.currentUser.uid
    //                         ? data[index].data()["sender"]
    //                         : data[index].data()["receiver"],
    //                     false,
    //                     widget.firestore,
    //                     widget.firebaseAuth),
    //                 subtitle: Text(data[index].data()["message"]),
    //               );
    //             });
    //       });
    //     }
    //
    //   }catch(e){
    //     print(e);
    //
    //   }
    //
    //
    //
    //
    //
    //   if(false) {
    //     setState(() {
    //       widget.returnWidget = ListView.builder(
    //           shrinkWrap: true,
    //           itemCount:data.length,
    //           itemBuilder: (BuildContext context, int index) {
    //             return ListTile(
    //               tileColor: widget.selectedItemId != null &&
    //                   ((widget.selectedItemId ==
    //                       data[index]["receiver"]) |
    //                   (widget.selectedItemId ==
    //                       data[index]["sender"]))
    //                   ? Color.fromARGB(255, 217, 236, 255)
    //                   : Color.fromARGB(255, 239, 247, 255),
    //               onTap: () {
    //                 setState(() {
    //                   widget.selectedItemId =
    //                   data[index]["receiver"] ==
    //                       widget.firebaseAuth.currentUser.uid
    //                       ? data[index]["sender"]
    //                       : data[index]["receiver"];
    //                 });
    //                 widget.callback(data[index].data());
    //                 // setState(() {
    //                 //   // widget.chatBody = filtereData[index];
    //                 //   widget.selectedItemId =
    //                 //       widget.Sum[index].data()["receiver"] ==
    //                 //               widget.firebaseAuth.currentUser.uid
    //                 //           ? widget.Sum[index].data()["sender"]
    //                 //           : widget.Sum[index].data()["receiver"];
    //                 // });
    //
    //                 // setState(() {
    //                 //   //  widget.widgetparent.chatBody =  widget.Sum[index];
    //                 //   widget.widgetparent.selectedItem = index;
    //                 // });
    //                 // if (widget.widgetparent.showMobileView) {
    //                 //   setState(() {
    //                 //     widget.widgetparent.mobileViewLevel = 2;
    //                 //
    //                 //   });
    //                 // }
    //               },
    //               leading: CommonFunctions(
    //                   firestore: widget.firestore,
    //                   auth: FirebaseAuth.instance,
    //                   onlineUser: onlineUser,
    //                   busyUser: busyUser,
    //                   awayUser: awayUser)
    //                   .prePareUserPhoto(
    //                   uid:data[index].data()["receiver"] ==
    //                       widget.firebaseAuth.currentUser.uid
    //                       ?data[index].data()["sender"]
    //                       : data[index].data()["receiver"]),
    //               // leading: prePareUserPhoto(
    //               //     widget.firebaseAuth,
    //               //     widget.Sum[index].data()["receiver"] ==
    //               //             widget.firebaseAuth.currentUser.uid
    //               //         ? widget.Sum[index].data()["sender"]
    //               //         : widget.Sum[index].data()["receiver"]),
    //               title: getNameFromIdR(
    //                   data[index].data()["receiver"] ==
    //                       widget.firebaseAuth.currentUser.uid
    //                       ? data[index].data()["sender"]
    //                       : data[index].data()["receiver"],
    //                   false,
    //                   widget.firestore,
    //                   widget.firebaseAuth),
    //               subtitle: Text(data[index].data()["message"]),
    //             );
    //           });
    //     });
    //   }else{
    //    // print("no history");
    //   }
    //
    //
    //
    // });
    //
    // widget.signal.emit("getLastMesage",{"id":widget.firebaseAuth.currentUser.uid});
  }

  // Widget getUserName(d) {
  //   // return Text(d);
  //   String fndID = d;
  //   widget.signal.on(fndID + "_profile", (data) {
  //     print("by second");
  //     print(data);
  //     if (mounted) {
  //       try {
  //         FetchUserInfoStream.getInstance().dataReload(data);
  //       } catch (e) {}
  //     }
  //   });
  //   // widget.signal.emit("saveProfileData",{"uid":widget.auth.currentUser.uid,"name":"mukul"});
  //   widget.signal.emit("getUserProfile", {"uid": fndID});
  //
  //   return StreamBuilder<dynamic>(
  //       stream: FetchUserInfoStream.getInstance().outData,
  //       builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
  //         print("from stream");
  //         print(snapshot.data.toString());
  //         if (snapshot.hasData && snapshot.data != null) {
  //           return Text(
  //             snapshot.data["name"],
  //             style: TextStyle(),
  //           );
  //         } else {
  //           return Text("Please wait");
  //         }
  //       });
  // }
}

prePareUserPhoto(FirebaseAuth auth, String uid) {
  Widget statusWIdget;

  if (onlineUser.containsKey(uid) &&
      onlineUser[uid] + 3000 > DateTime.now().millisecondsSinceEpoch) {
    statusWIdget = Container(
      width: 10,
      height: 10,
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: Colors.greenAccent),
    );
  } else {
    statusWIdget = Container(
      width: 10,
      height: 10,
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent),
    );
  }

  return Container(
    height: 40,
    width: 40,
    child: Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: CircleAvatar(
              backgroundImage: AssetImage("assets/user_photo.jpg")),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: statusWIdget,
          ),
        )
      ],
    ),
  );
}

Widget getNameFromIdWithStyle(String id, TextStyle style, FirebaseAuth auth) {
  return FutureBuilder<dynamic>(
      future: getUserInfo(id),
      builder: (context, snapuserInfo) {
        if (snapuserInfo.hasData) {
          return Text(
            snapuserInfo.data["name"],
            style: style,
          );
        } else {
          return Text("Please wait");
        }
      });
}

Future getUserInfo(String id) async {
  var url = Uri.parse(AppSettings().Api_link + "getUserDetail?id=" + id);
  var response = await http.get(url);
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');
  return json.decode(response.body);
}

Widget getNameFromIdR(String id, bool style) {
  return FutureBuilder<dynamic>(
      future: getUserInfo(id),
      builder: (context, snapuserInfo) {
        if (snapuserInfo.hasData && snapuserInfo.data != null) {
          return Text(
            snapuserInfo.data["name"],
            style: style
                ? TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20)
                : TextStyle(),
          );
        } else {
          return Text("Please wait");
        }
      });
}

class ProfileUpdateDialog extends StatefulWidget {
  dynamic currentProfile;

  FirebaseAuth auth;

  ProfileUpdateDialog({this.currentProfile, this.auth});

  @override
  _ProfileUpdateDialogState createState() => _ProfileUpdateDialogState();
}

class _ProfileUpdateDialogState extends State<ProfileUpdateDialog> {
  TextEditingController textEditingControllerName = TextEditingController();
  TextEditingController textEditingControllerEmail = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    textEditingControllerName.text = widget.currentProfile["name"];
    textEditingControllerEmail.text = widget.currentProfile["email"];
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 400,
        height: 400,
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.blue,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Profile Update",
                    style: TextStyle(
                        backgroundColor: Colors.blue,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
                child: Text(
                  "Display Name",
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: TextField(
                  controller: textEditingControllerName,
                  decoration:
                      InputDecoration(contentPadding: EdgeInsets.all(10)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
                child: Text(
                  "Email",
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: TextField(
                  controller: textEditingControllerEmail,
                  decoration:
                      InputDecoration(contentPadding: EdgeInsets.all(10)),
                ),
              ),
              InkWell(
                onTap: () {},
                child: Card(
                  elevation: 0,
                  color: Theme.of(context).primaryColor,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                          child: Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      )),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget getNameFromId(dynamic body, bool style, FirebaseAuth auth) {
  return FetchUserNameWidget(
    uid: body["uid"] != null
        ? body["uid"]
        : (body["receiver"] == auth.currentUser.uid
            ? body["sender"]
            : body["receiver"]),
  );
}

class ProfileUpdate extends StatefulWidget {
  FirebaseAuth auth;

  ProfileUpdate({this.auth});

  @override
  _ProfileUpdateState createState() => _ProfileUpdateState();
}

class _ProfileUpdateState extends State<ProfileUpdate> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class StreamSocket {
  final _socketResponse = StreamController<dynamic>();

  void Function(dynamic) get addResponse => _socketResponse.sink.add;

  Stream<dynamic> get getResponse => _socketResponse.stream;

  void dispose() {
    _socketResponse.close();
  }
}

class ParticipentChooseForGrp extends StatefulWidget {
  List downloaded = [];

  FirebaseAuth auth;
  void Function(List) callback;

  ParticipentChooseForGrp({this.auth, this.callback});

  @override
  _ParticipentChooseForGrpState createState() =>
      _ParticipentChooseForGrpState();
}

class _ParticipentChooseForGrpState extends State<ParticipentChooseForGrp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    downloadFriends();
    // widget.firestore
    //     .collection("fnd")
    //     .where("self", isEqualTo: widget.auth.currentUser.uid)
    //     .get()
    //     .then((value) {
    //   if (value.size > 0 && value.docs.length > 0) {
    //     for (int i = 0; i < value.docs.length; i++) {
    //       setState(() {
    //         dynamic da = value.docs[i].data();
    //         da["selected"] = false;
    //         widget.downloaded.add(da);
    //       });
    //     }
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(
            onTap: () {
              List newList = [];
              for (int i = 0; i < widget.downloaded.length; i++) {
                if (widget.downloaded[i]["selected"] == true) {
                  newList.add(widget.downloaded[i]);
                }
              }
              widget.callback(newList);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.done),
            ),
          )
        ],
        title: Text("Add participants"),
      ),
      //body: createFndListForAdd(),
      body: widget.downloaded.length > 0
          ? ListView.builder(
              shrinkWrap: true,
              itemCount: widget.downloaded.length,
              itemBuilder: (BuildContext context, int index) {
                // return ListTile(leading:  prePareUserPhoto( widget.downloaded[index]
                // ["fnd"],FirebaseAuth.instance.currentUser.uid),title:  getNameFromIdR(
                //     widget.downloaded[index]["fnd"],
                //     false,
                //     widget.firestore,
                //     widget.auth),);
                return InkWell(
                  onTap: () {
                    setState(() {
                      widget.downloaded[index]["selected"] =
                          !widget.downloaded[index]["selected"];
                    });
                  },
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FetchUserNameEmailLIsttileWidget(
                            uid: widget.downloaded[index]["uid"]),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Checkbox(
                            onChanged: (value) {
                              setState(() {
                                widget.downloaded[index]["selected"] =value;
                              });
                              // setState(() {
                              //   widget.downloaded[index]["selected"] = value ;
                              // });
                            },
                            value: widget.downloaded[index]["selected"],
                          ),
                        ),
                      )
                    ],
                  ),
                );
                // return ListTile(trailing: Checkbox(value: true,),
                //   tileColor: Color.fromARGB(
                //       255, 249, 252, 255),
                //   leading: prePareUserPhoto(
                //       snapshot.data
                //           .docs[index]
                //       ["fnd"]),
                //   title: getNameFromIdR(
                //       snapshot.data
                //           .docs[index]["fnd"],
                //       false,
                //       widget.firestore,
                //       widget.auth),
                //   subtitle: Padding(
                //     padding:
                //     const EdgeInsets.all(
                //         5.0),
                //     child:
                //     Text("Add"),
                //   ),
                // );
              },
            )
          : Center(
              child: Text("No friends"),
            ),
    );
  }

  createFndListForAdd() async {
    List fndIds = [];

    var url = Uri.parse(
        AppSettings().Api_link + 'getMyFnds?id=' + widget.auth.currentUser.uid);
    var response = await http.get(
      url,
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    fndIds.addAll(jsonDecode(response.body));

    return ListView.builder(
      shrinkWrap: true,
      itemCount: fndIds.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          child: new InkWell(
            onTap: () async {},
            child: ListTile(
              tileColor: Color.fromARGB(255, 249, 252, 255),
              leading: CommonFunctions(
                      auth: widget.auth,
                      onlineUser: onlineUser,
                      busyUser: busyUser,
                      awayUser: awayUser)
                  .prePareUserPhoto(uid: fndIds[index]),
              // leading: prePareUserPhotoOld(
              //     snapshot.data.docs[index]["fnd"]),
              // title: getNameFromIdR(snapshot.data[index], false,
              //     widget.firestore, widget.auth),
              title: FetchUserNameWidget(
                uid: fndIds[index],
              ),

              subtitle: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(fndIds[index]),
              ),
            ),
          ),
        );
      },
    );
  }

  void downloadFriends() async {
    List fndIds = [];
    List temp = [];

    var url = Uri.parse(
        AppSettings().Api_link + 'getMyFnds?id=' + widget.auth.currentUser.uid);
    var response = await http.get(
      url,
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    fndIds.addAll(jsonDecode(response.body));
    if (fndIds.length > 0) {
      for (int i = 0; i < fndIds.length; i++) {
        dynamic da = {"uid": fndIds[i], "selected": false};
        //da["selected"] = false;
        temp.add(da);
      }
      setState(() {
        widget.downloaded = temp;
      });
    }
  }
}

class NameOfTheNewGrpChat extends StatefulWidget {
  FirebaseAuth Auth;

  void Function(String) grpCreated;

  NameOfTheNewGrpChat({this.Auth, this.grpCreated});

  @override
  _NameOfTheNewGrpChatState createState() => _NameOfTheNewGrpChatState();
}

class _NameOfTheNewGrpChatState extends State<NameOfTheNewGrpChat> {
  TextEditingController controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Group Discription"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Group Name',
                //errorText: 'Please give  a name',
                border: OutlineInputBorder(),
                suffixIcon: Icon(
                  Icons.title,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              widget.grpCreated(controller.text);
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
              child: Container(
                color: Theme.of(context).primaryColor,
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Create",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                )),
              ),
            ),
          )
        ],
      ),
    );
  }
}



class ChatMesageLit extends StatefulWidget {
  FirebaseAuth auth;

  dynamic chatBody;
  String room;
  List data = [];
  IO.Socket socket;

  ChatMesageLit({
    this.chatBody,
    this.room,
    this.socket,
    this.auth,
  });

  @override
  _ChatMesageLitState createState() => _ChatMesageLitState();
}

class _ChatMesageLitState extends State<ChatMesageLit> {
  List allData = [];

  Future download() {
    String room = createRoomName(
        widget.auth.currentUser.uid,
        widget.chatBody["sender"] != null
            ? (widget.chatBody["sender"] == widget.auth.currentUser.uid
                ? widget.chatBody["receiver"]
                : widget.chatBody["sender"])
            : widget.chatBody["uid"]);
    print("room " + DateTime.now().toString());
    widget.socket.on(room, (data) {
      try {
        //print("got");
        setState(() {
          allData = data;
        });
      } catch (e) {
        // print("neeed clear");
        print(e.toString());
        setState(() {
          allData = [];
        });
      }
    });

    widget.socket.emit("getMesage", {"fileName": room});
    return Future.value();
  }

  void initDownloadMessage() {
    ChatDataloadedStream.getInstance().outData.listen((event) {
      print("by  listener");
      print(event.length.toString());
      try {
        //print("got");
        setState(() {
          allData = event;
        });
      } catch (e) {
        // print("neeed clear");
        print(e.toString());
        setState(() {
          allData = [];
        });
      }
    });

    widget.socket.emit("getMesage", {"fileName": widget.room});
  }

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    print("in bidy");
    super.initState();
    // initDownloadMessage();
  }

  @override
  Widget build(BuildContext context) {
    ChatDataloadedStream.getInstance().outData.listen((event) {
      print("by  listener");
      print(event.length.toString());
      try {
        //print("got");
        setState(() {
          allData = event;
        });
      } catch (e) {
        // print("neeed clear");
        print(e.toString());
        setState(() {
          allData = [];
        });
      }
    });

    widget.socket.emit("getMesage", {"fileName": widget.room});
    return StreamBuilder<List>(
        stream: ChatDataloadedStream.getInstance().outData,
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (snapshot.hasData && snapshot.data.length > 0) {
            print(snapshot.data.length.toString());
            //_scrollController.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.ease);
                //_scrollController.jumpTo(_scrollController.position.maxScrollExtent);
              }
            });
            return Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: snapshot.data == null ? 0 : snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          Align(
                            alignment: snapshot.data[index]["sender"] ==
                                    widget.auth.currentUser.uid
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: snapshot.data[index]["sender"] ==
                                      widget.auth.currentUser.uid
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment: snapshot.data[index]
                                                  ["sender"] ==
                                              widget.auth.currentUser.uid
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 5, 0),
                                          child: Text(
                                            DateFormat('hh:mm aa').format(
                                                DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        snapshot.data[index]
                                                            ["time"])),
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        Card(
                                          color: snapshot.data[index]
                                                      ["sender"] ==
                                                  widget.auth.currentUser.uid
                                              ? Colors.white
                                              : Color.fromARGB(
                                                  255, 238, 246, 255),
                                          child: Container(
                                              child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            //   child: Text(snapshot.data.docs[index].data()["message"]),

                                            child:
                                                makeChatMessageHead1WithEmoji(
                                                    context,
                                                    snapshot.data[index]),
                                          )),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        widget.chatBody["img"] == null
                                            ? CircleAvatar(
                                                radius: 10,
                                              )
                                            : CircleAvatar(
                                                radius: 10,
                                                backgroundImage: NetworkImage(
                                                    widget.chatBody["img"]),
                                              ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment: snapshot
                                                      .data[index]["sender"] ==
                                                  widget.auth.currentUser.uid
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      5, 0, 0, 0),
                                              child: Text(
                                                DateFormat('hh:mm aa').format(
                                                    DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                            snapshot.data[index]
                                                                ["time"])),
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ),
                                            Card(
                                              color: snapshot.data[index]
                                                          ["sender"] ==
                                                      widget
                                                          .auth.currentUser.uid
                                                  ? Colors.white
                                                  : Color.fromARGB(
                                                      255, 238, 246, 255),
                                              child: Container(
                                                  child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                // child: Text(snapshot.data.docs[index].data()["message"]),
                                                child:
                                                    makeChatMessageHead1WithEmoji(
                                                        context,
                                                        snapshot.data[index]),
                                              )),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                            ),
                          )
                        ],
                      ),
                    );
                  }),
            );
          } else {
            return Center(
              child: Text("Type your first message"),
            );
          }
        });

    return StreamBuilder<List>(
        stream: ChatDataloadedStream.getInstance().outData,
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (snapshot.hasData && snapshot.data.length > 0) {
            print(snapshot.data.length.toString());
            return Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: snapshot.data == null ? 0 : snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          Align(
                            alignment: snapshot.data[index]["sender"] ==
                                    widget.auth.currentUser.uid
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: snapshot.data[index]["sender"] ==
                                      widget.auth.currentUser.uid
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment: snapshot.data[index]
                                                  ["sender"] ==
                                              widget.auth.currentUser.uid
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 5, 0),
                                          child: Text(
                                            DateFormat('hh:mm aa').format(
                                                DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        snapshot.data[index]
                                                            ["time"])),
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        Card(
                                          color: snapshot.data[index]
                                                      ["sender"] ==
                                                  widget.auth.currentUser.uid
                                              ? Colors.white
                                              : Color.fromARGB(
                                                  255, 238, 246, 255),
                                          child: Container(
                                              child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            //   child: Text(snapshot.data.docs[index].data()["message"]),

                                            child:
                                                makeChatMessageHead1WithEmoji(
                                                    context,
                                                    snapshot.data[index]),
                                          )),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        widget.chatBody["img"] == null
                                            ? CircleAvatar(
                                                radius: 10,
                                              )
                                            : CircleAvatar(
                                                radius: 10,
                                                backgroundImage: NetworkImage(
                                                    widget.chatBody["img"]),
                                              ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment: snapshot
                                                      .data[index]["sender"] ==
                                                  widget.auth.currentUser.uid
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      5, 0, 0, 0),
                                              child: Text(
                                                DateFormat('hh:mm aa').format(
                                                    DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                            snapshot.data[index]
                                                                ["time"])),
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ),
                                            Card(
                                              color: snapshot.data[index]
                                                          ["sender"] ==
                                                      widget
                                                          .auth.currentUser.uid
                                                  ? Colors.white
                                                  : Color.fromARGB(
                                                      255, 238, 246, 255),
                                              child: Container(
                                                  child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                // child: Text(snapshot.data.docs[index].data()["message"]),
                                                child:
                                                    makeChatMessageHead1WithEmoji(
                                                        context,
                                                        snapshot.data[index]),
                                              )),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                            ),
                          )
                        ],
                      ),
                    );
                  }),
            );
          } else {
            return Center(
              child: Text("Type your first message"),
            );
          }
        });
  }

  getChatbar() {
    String fndID = widget.chatBody["sender"] != null
        ? (widget.chatBody["sender"] == widget.auth.currentUser.uid
            ? widget.chatBody["receiver"]
            : widget.chatBody["sender"])
        : widget.chatBody["uid"];
    widget.socket.on(fndID + "_profile", (data) {
      print("by second");
      print(data);
      if (mounted) {
        try {
          FetchUserInfoStream.getInstance().dataReload(data);
        } catch (e) {}
      }
    });
    // widget.signal.emit("saveProfileData",{"uid":widget.auth.currentUser.uid,"name":"mukul"});
    widget.socket.emit("getUserProfile", {"uid": fndID});

    return StreamBuilder<dynamic>(
        stream: FetchUserInfoStream.getInstance().outData,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          print("from stream");
          print(snapshot.data.toString());
          if (snapshot.hasData && snapshot.data != null) {
            return ListTile(
              title: Text(
                snapshot.data["name"],
                style: TextStyle(),
              ),
              subtitle: Text(snapshot.data["email"]),
            );
          } else {
            return Text("Please wait");
          }
        });
  }
}



class GroupChatThread extends StatefulWidget {
  //Home widgetHome;
  bool showEmojiList = false;

  FirebaseAuth auth;
  dynamic grpInfo;
  IO.Socket socket;
  var selectedEnojis =Emoji.byGroup(EmojiGroup.smileysEmotion).toList();


  GroupChatThread({this.socket,this.grpInfo, this.auth});

  @override
  _GroupChatThreadState createState() => _GroupChatThreadState();
}

class _GroupChatThreadState extends State<GroupChatThread> {
  TextEditingController controllerGrp = TextEditingController();
  ScrollController _scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
                top: 75,
                left: 0,
                right: 0,
                bottom: 70,
                child: CreateMessageStream(widget.socket,
                    widget.grpInfo["id"], widget.auth.currentUser.uid)),
            Align(
              alignment: Alignment.bottomCenter,
              child: Wrap(
                children: [
                  Container(
                    height: 60,
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 10,
                          left: 10,
                          right: 130,
                          child: Container(
                            height: 60,
                            child: Center(
                              child: Card(
                                elevation: 0,
                                color: Color.fromARGB(255, 238, 246, 255),
                                child: Container(
                                  child: new TextField(
                                    onSubmitted: (val) async {
                                      sendMessageGroup(widget.socket,
                                          val, "txt", "-", widget.grpInfo["id"]);

                                      controllerGrp.clear();
                                    },
                                    controller: controllerGrp,
                                    textAlign: TextAlign.left,
                                    decoration: new InputDecoration(
                                      hintText: "Type your message",
                                      contentPadding: EdgeInsets.all(10),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            height: 60,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: new InkWell(
                                    onTap: () async {
                                      //widget.room
                                      FilePickerResult result =
                                          await FilePicker.platform.pickFiles();

                                      if (result != null) {
                                        PlatformFile file = result.files.first;

                                        print(file.name);
                                        // print(file.bytes);
                                        // _base64 = BASE64.encode(response.bodyBytes);
                                        String base = base64.encode(file.bytes);

                                        String url =
                                            "https://talk.maulaji.com/uploadfilemessenger.php";

                                        print(file.size);
                                        print(file.extension);
                                        print(file.path);
                                        //print("base");
                                        // print(base);

                                        var response = await http.post(
                                            Uri.parse(url),
                                            body: jsonEncode({
                                              'name': file.name,
                                              'file': base,
                                              'ex': file.extension
                                            }));
                                        print(
                                            'Response status: ${response.statusCode}');
                                        print(response.body);
                                        dynamic res = jsonDecode(response.body);
                                        if (res["status"]) {
                                          // sendMessageGroup(
                                          //     widget.firestore,
                                          //     widget.auth,
                                          //     res["path"],
                                          //     file.extension,
                                          //     file.name,
                                          //     widget.documentSnapshot.id);
                                        } else {
                                          print("could not save");
                                        }
                                      } else {
                                        // User canceled the picker
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.attach_file,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: new InkWell(
                                    onTap: () async {
                                      //widget.room

                                      setState(() {
                                        widget.showEmojiList =
                                            !widget.showEmojiList;
                                      });
                                      print("emoji " +
                                          widget.showEmojiList.toString());
                                    },
                                    child:Padding(
                                      padding: const EdgeInsets.all(0.0),
                                      child: Text(
                                        Emoji.all().first.char,
                                        style: TextStyle(fontSize: 22),
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: new InkWell(
                                    onTap: () async {
                                      //widget.room
                                      sendMessageGroup(widget.socket,
                                          Emoji.all()[139].char, "txt", "-", widget.grpInfo["id"]);

                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(0.0),
                                      child: Text(
                                        Emoji.all()[139].char,
                                        style: TextStyle(fontSize: 22),
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: new InkWell(
                                    onTap: () async {
                                      //widget.room
                                      String text = controllerGrp.text;
                                      // sendMessageGroup(
                                      //     widget.firestore,
                                      //     widget.auth,
                                      //     text,
                                      //     "txt",
                                      //     "-",
                                      //     widget.documentSnapshot.id);
                                      controllerGrp.clear();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.send,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  widget.showEmojiList
                      ? Container(
                          height: 300,
                          color: Colors.white,
                          // width: 500,
                          child: GridView.builder(
                            itemCount:widget.selectedEnojis.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: MediaQuery.of(context).size.width>700?20:8),
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                  onTap: () {
                                    controllerGrp.text = controllerGrp.text +
                                        widget.selectedEnojis[index].char;
                                  },
                                  child: Center(
                                      child: new Text(
                                        widget.selectedEnojis[index].char,
                                    style: TextStyle(fontSize: 18),
                                  )));
                            },
                          ),
                        )
                      : Container(
                          width: 0,
                          height: 0,
                        )
                ],
              ),
            ),
            Positioned(
                top: 70,
                child: Container(
                  color: Colors.grey,
                  height: 0.5,
                  width: MediaQuery.of(context).size.width,
                )),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 70,
                // width: MediaQuery.of(context).size.height,
                color: Colors.white,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: InkWell(onTap: (){
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => SimpleGrpView(room: widget.room,socket: widget.socket,
                              //         auth: widget.auth,
                              //         selfId: widget.auth.currentUser.uid,
                              //         fndId: widget.chatBody["sender"] != null
                              //             ? (widget.chatBody["sender"] ==
                              //             widget.auth.currentUser.uid
                              //             ? widget.chatBody["receiver"]
                              //             : widget.chatBody["sender"])
                              //             : widget.chatBody["uid"],
                              //       )),
                              // );
                            },
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(8, 8, 15, 8),
                                    child: Icon(Icons.supervised_user_circle),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(widget.grpInfo["body"]["name"]!=null?widget.grpInfo["body"]["name"]:"No Name",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 20),
                                      ),
                                      getUsersCount(widget.grpInfo["body"]["users"]),

                                      // getListOfPeople(
                                      //     widget.documentSnapshot.data()["users"]),
                                      // Text(groupChatSnaps.data.docs[index].data()["users"].length.toString()+" users"),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                      ),
                      Align(alignment: Alignment.centerRight,
                        child: InkWell(onTap: (){
                          // show all users and seaech and add to group
                          //addtogrp

                          done(List list) {
                            print("returned " + list.length.toString());
                            Navigator.pop(context);
                            List ids = [];
                            ids.add(widget.auth.currentUser.uid);
                            String ii="";
                            for (int i = 0; i < list.length; i++) {
                              //  ids.add(list[i]["uid"]);
                              ii = ii+list[i]["uid"];
                            }

                            http
                                .post(
                                Uri.parse(AppSettings().Api_link + 'addMember'),
                                headers: <String, String>{
                                  'Content-Type':
                                  'application/json; charset=UTF-8',
                                },
                                body: jsonEncode(<String, String>{
                                  //"admin": widget.auth.currentUser.uid,
                                  "grp":widget. grpInfo["id"],
                                  "peoples":ii
                                }))
                                .then((value) {
                                  print(value.body);
                             // Navigator.pop(context);
                            });

                          }

                     Widget addParticipents =   ParticipentChooseForGrp(
                            auth: widget.auth,
                            callback: done,
                          );

                     AlertDialog alert = AlertDialog(
                       // title: Text("Add New"),
                       content: Container(width: MediaQuery.of(context).size.width>1000?400:MediaQuery.of(context).size.width,height: 400,
                         child:addParticipents,
                       ),

                     );
                     showDialog(
                       context: context,
                       builder: (BuildContext context) {
                         return alert;
                       },
                     );



                        },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.person_add),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  createListofPeoplesName(grpInfo) {
    //Text("getListOfPeople")
    return Text("List of peoples");
  }

  getUsersCount(grpInfo) {
    List<Widget> allWidg = [];
    String users = grpInfo.toString();
    List all  = users.split(",");
  //  return Text(all.length.toString()+" users");
    Future getData(String uid) async {
      String id = uid;
      var url = Uri.parse(AppSettings().Api_link+'getUserDetail?id=' + id);
      var response = await http.get(url);
      print(response.body);
      return jsonDecode(response.body);
    }
    // for(int i = 0 ; i <all.length ; i ++  ){
    //   allWidg.add(Padding(
    //     padding: const EdgeInsets.all(1.0),
    //    // child: Text(all[i].toString()),
    //   ));
    // }
    for(int i = 0 ; i <1 ; i ++  ){allWidg.add(FetchUserNameWidget(
        uid: all[i]),);
    /*  allWidg.add(Padding(padding: EdgeInsets.all(1),child:  FutureBuilder<dynamic>(
          future: getData(all[i]),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData && snapshot.data != null) {

              print(snapshot.data.toString());
              return Text(snapshot.data["name"]);
              // allWidg.add(Padding(
              //   padding: const EdgeInsets.all(1.0),
              //   child: Text(snapshot.data["name"]),
              // ));
             // return Text(snapshot.data["name"]);
            //  return Text(snapshot.data["name"]);


            }else{
              return Text("Name not found");
            }
          }),
    */



     // ));
    }



    //  return Text( data.toString());
    return Row(children: allWidg,);
    return ListView.builder(scrollDirection: Axis.horizontal,
      itemCount: allWidg.length,
      itemBuilder: (context, position) {
        return allWidg[position];
      },
    );
  //  return Row(children: allWidg,);
  }
}

Widget CreateMessageStream(IO.Socket socket,String id, String uid) {
  // return Text("");



  socket.on(id, (data) {
    if (true && data["room"] == id) {
      ChatDataloadedStream.getInstance().dataReload(data["data"]);
    } else {
      print("blocked");
    }

    print("downloaded");
    print(data.length.toString());
  });

  socket.emit("getMesageGroup", {"fileName": id});
  ScrollController _scrollController = ScrollController();

  return StreamBuilder<List>(
      // Initialize FlutterFire:
      //  future: Firebase.initializeApp(),
      stream: ChatDataloadedStream.getInstance().outData,
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data.length > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.ease);
              //_scrollController.jumpTo(_scrollController.position.maxScrollExtent);
            }
          });

          return ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              itemCount: snapshot.data == null ? 0 : snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      Align(
                        alignment: snapshot.data[index]["sender"] == uid
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: snapshot.data[index]["sender"] == uid
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      snapshot.data[index]["sender"] == uid
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                      child: Text(
                                        DateFormat('hh:mm aa').format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                snapshot.data[index]["time"])),
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    Card(
                                      color: snapshot.data[index]["sender"] ==
                                              uid
                                          ? Colors.white
                                          : Color.fromARGB(255, 238, 246, 255),
                                      child: Container(
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        //   child: Text(snapshot.data.docs[index].data()["message"]),

                                        child: makeChatMessageHead1WithEmoji(
                                            context, snapshot.data[index]),
                                      )),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    snapshot.data[index]["img"] == null
                                        ? CircleAvatar(
                                            radius: 10,
                                          )
                                        : CircleAvatar(
                                            radius: 10,
                                            backgroundImage: NetworkImage(
                                                snapshot.data[index]["img"]),
                                          ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          snapshot.data[index]["sender"] == uid
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 0, 0, 0),
                                          child: Text(
                                            DateFormat('hh:mm aa').format(
                                                DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        snapshot.data[index]
                                                            ["time"])),
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        Card(
                                          color: snapshot.data[index]
                                                      ["sender"] ==
                                                  uid
                                              ? Colors.white
                                              : Color.fromARGB(
                                                  255, 238, 246, 255),
                                          child: Container(
                                              child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            // child: Text(snapshot.data.docs[index].data()["message"]),
                                            child:
                                                makeChatMessageHead1WithEmoji(
                                                    context,
                                                    snapshot.data[index]),
                                          )),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                      )
                    ],
                  ),
                );
              });
        } else {
          return Center(child: Text("Send  your first message"));
        }
      });
}

void sendMessageGroup(IO.Socket socket,
    String val, String type, String name, String groupID) async {
  print("sent " + type);
  print("sent " + type);

  dynamic me = {
    "time": DateTime.now().millisecondsSinceEpoch,
    "message": val,
    "type": type,
    "fname": name,
    "sender": FirebaseAuth.instance.currentUser.uid,
  };

  socket.emit("saveMesageGroup", {"fileName": groupID, "message": me});
  print({"fileName": groupID, "message": me});
}

class ImageDialog extends StatelessWidget {
  String path;

  ImageDialog({this.path});

  @override
  Widget build(BuildContext context) {
    String base = "https://talk.maulaji.com/";
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Image.network(
        base + path,
        height: MediaQuery.of(context).size.height,
      ),
    );
  }
}

makeChatMessageHead1WithEmoji(BuildContext context, dynamic data) {
  // return Text(data["message"]);

  String base = "https://talk.maulaji.com/";
  if (data["type"] == null) {
    return SelectableText(data["message"]);
  } else if (data["type"] != null && data["type"] == "txt")
    return SelectableText(data["message"]);
  else if (data["type"] != null) if (data["type"] == "img" ||
      data["type"] == "png" ||
      data["type"] == "PNG" ||
      data["type"] == "jpg" ||
      data["type"] == "JPG" ||
      data["type"] == "jpeg" ||
      data["type"] == "JPEG")
    return InkWell(
      onTap: () async {
        await showDialog(
            context: context,
            builder: (_) => ImageDialog(
                  path: data["message"],
                ));
      },
      child: Image.network(
        base + data["message"],
        height: 200,
        width: 200,
      ),
    );
  else if (data["type"] != null) if (data["type"] == "vdo" ||
      data["type"] == "mp4" ||
      data["type"] == "mov" ||
      data["type"] == "avi" ||
      data["type"] == "3gp" ||
      data["type"] == "mpeg4")
    return Container(
        width: 200,
        height: 200,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(PageRouteBuilder(
                opaque: false,
                pageBuilder: (BuildContext context, _, __) =>
                    PlayVideoFullScrean(
                      link: base + data["message"],
                    )));
          },
          child: VideoApp(
            link: data["message"],
          ),
        ));
  else if (data["type"] != null) if (data["type"] == "mp3" ||
      data["type"] == "acc")
    return Container(
        height: 50,
        width: 50,
        child: AudioTestAid(
          audio: data["message"],
        ));
  // return Container(
  //     width: 200,
  //     height: 200,
  //     child:  );
  else
    return InkWell(

      child: Text(data["message"]),
    );
}

Future<AudioPlayer> initAudio(String link) async {
  AudioPlayer audioPlayer = await AudioPlayer();
  if (kIsWeb) {
    await audioPlayer.setUrl(base + link);
  }
  return audioPlayer;
}

makeChatMessageHead1(BuildContext context, dynamic data) {
  if (data["type"] != null && data["type"] == "txt")
    return Text(data["message"]);
  else if (data["type"] != null) if (data["type"] == "img" ||
      data["type"] == "png" ||
      data["type"] == "PNG" ||
      data["type"] == "jpg" ||
      data["type"] == "JPG" ||
      data["type"] == "jpeg" ||
      data["type"] == "JPEG")
    return InkWell(
      onTap: () async {
        await showDialog(
            context: context,
            builder: (_) => ImageDialog(
                  path: data["message"],
                ));
      },
      child: Image.network(
        base + data["message"],
        height: 200,
        width: 200,
      ),
    );
  else if (data["type"] != null) if (data["type"] == "vdo" ||
      data["type"] == "mp4" ||
      data["type"] == "mov" ||
      data["type"] == "avi" ||
      data["type"] == "3gp" ||
      data["type"] == "mpeg4")
    return Container(
        width: 200,
        height: 200,
        child: VideoApp(
          link: data["message"],
        ));
  else
    return InkWell(
      onTap: () {

      },
      child: Text(data["message"]),
    );
}

class VideoApp extends StatefulWidget {
  String link;

  VideoApp({this.link});

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.link)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      home: Scaffold(
        body: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Center(
                child: _controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                    : Container(),
              ),
            ),
            Align(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}



String createRoomName(String uid, partner) {
  final List<String> ids = <String>[uid, partner];
  ids.sort();
  return ids.first + "-" + ids.last;
}

Widget getEmailFromId(dynamic body, FirebaseAuth auth) {
  // return FetchUserEmailWidget(uid:body["uid"] != null
  //     ? body["uid"]
  //     : (body["receiver"] == auth.currentUser.uid
  //     ? body["sender"]
  //     : body["receiver"]) ,);
  String id = body["uid"] != null
      ? body["uid"]
      : (body["receiver"] == auth.currentUser.uid
          ? body["sender"]
          : body["receiver"]);

  Future getData() async {
    var url = Uri.parse(AppSettings().Api_link + 'getUserDetail?id=' + id);
    var response = await http.get(url);
    return jsonDecode(response.body);
  }

  return FutureBuilder<dynamic>(
      future: getData(),
      builder: (context, snapuserInfo) {
        if (snapuserInfo.hasData) {
          return Text(
            snapuserInfo.data.docs.first.data()["email"],
            style: TextStyle(),
          );
        } else {
          return Text("No Email address found");
        }
      });
}

class MyAudioPLayer extends StatefulWidget {
  String link;
  bool isPlaying = false;

  MyAudioPLayer({this.link});

  @override
  _MyAudioPLayerState createState() => _MyAudioPLayerState();
}

class _MyAudioPLayerState extends State<MyAudioPLayer> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AudioPlayer>(

        // Initialize FlutterFire:
        //  future: Firebase.initializeApp(),
        future: initAudio(widget.link),
        builder: (BuildContext context, AsyncSnapshot<AudioPlayer> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            try {
              // snapshot.data.resume();
            } catch (e) {
              print("failed while audio playing");
              print(e.toString());
            }
            return InkWell(
                onTap: () {
                  if (widget.isPlaying) {
                    snapshot.data.stop();
                    setState(() {
                      widget.isPlaying = false;
                    });
                  } else {
                    snapshot.data.play(base + widget.link);
                    setState(() {
                      widget.isPlaying = true;
                    });
                  }
                },
                child: Icon(widget.isPlaying ? Icons.pause : Icons.play_arrow));
          } else {
            return Text("Audio loading");
          }
        });
  }
}

class AudioTestAid extends StatefulWidget {
  String audio;

  bool isPlaying = false;

  String audioCurrentLength = "00";
  String fullLength = "00";

  AudioTestAid({this.audio});

  @override
  _AudioTestAidState createState() => _AudioTestAidState();
}

class _AudioTestAidState extends State<AudioTestAid> {
  AudioPlayer audioPlayer;

  initAudio(String link) async {
    audioPlayer = await AudioPlayer();
    await audioPlayer.setUrl(link);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAudio(base + widget.audio);

    // initAudio();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: true
            ? InkWell(
                onTap: () {
                  print("clicked");

                  if (widget.isPlaying) {
                    audioPlayer.pause().then((value) {
                      setState(() {
                        widget.isPlaying = false;
                      });
                    });
                  } else {
                    //initA


                    audioPlayer.resume().then((value) {
                      setState(() {
                        widget.isPlaying = true;
                      });
                    });
                  }
                },
                child: Icon(widget.isPlaying ? Icons.pause : Icons.play_arrow))
            : Text("Please wait"),
      ),
    );
  }
}

class PlayVideoFullScrean extends StatefulWidget {
  String link;

  PlayVideoFullScrean({this.link});

  @override
  _PlayVideoFullScreanState createState() => _PlayVideoFullScreanState();
}

class _PlayVideoFullScreanState extends State<PlayVideoFullScrean> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Back"),
      ),
      backgroundColor: Colors.black,
      body: VideoApp(
        link: widget.link,
      ),
    );
  }
}

class AddFndWidget extends StatefulWidget {
  String fndID;
  String uid;
  bool status = true;

  bool prevent = true;

  AddFndWidget({this.fndID, this.uid});

  @override
  _AddFndWidgetState createState() => _AddFndWidgetState();
}

class _AddFndWidgetState extends State<AddFndWidget> {
  Future getIfFriend() async {
    var url = Uri.parse(AppSettings().Api_link +
        'checkMyFnd?id=' +
        widget.uid +
        "&&fnd=" +
        widget.fndID);
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    dynamic res = jsonDecode(response.body);

    setState(() {
      widget.status = res["fnd"];
    });
    return res;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("show add fnd wid");
   // getIfFriend();
  }

  @override
  Widget build(BuildContext context) {
  //  return Text("");#



    return FutureBuilder(
        // Initialize FlutterFire:
        future: getIfFriend(),
        builder: (context, snapshot) {
          if (widget.prevent == true &&
              snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data["fnd"] == false)
            return Wrap(
              children: [
                InkWell(
                  onTap: () async {
                    var url = Uri.parse(AppSettings().Api_link +
                        'addFnd?id=' +
                        widget.uid +
                        "&&fnd=" +
                        widget.fndID);
                    var response = await http.get(url);
                    // getIfFriend();
                    setState(() {
                      widget.prevent = !widget.prevent;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                        color: Theme.of(context).primaryColor,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: Text(
                            "Add to Contact",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        )),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      widget.prevent = !widget.prevent;
                    });
                    // widget.firestore.collection("fnd").add({
                    //   "self": widget.auth.currentUser.uid,
                    //   "fnd": fndID,
                    //   "active": false
                    // });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: Text(
                            "Don't add to Contact",
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold),
                          ),
                        )),
                  ),
                )
              ],
            );
          else {
            return Container(
              width: 0,
              height: 0,
            );
          }
        });

    return Container(
        child: !widget.status
            ? Wrap(
                children: [
                  InkWell(
                    onTap: () async {
                      var url = Uri.parse(AppSettings().Api_link +
                          'addFnd?id=' +
                          widget.uid +
                          "&&fnd=" +
                          widget.fndID);
                      var response = await http.get(url);
                      getIfFriend();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                          color: Theme.of(context).primaryColor,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child: Text(
                              "Add to Contact",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          )),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // widget.firestore.collection("fnd").add({
                      //   "self": widget.auth.currentUser.uid,
                      //   "fnd": fndID,
                      //   "active": false
                      // });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child: Text(
                              "Don't add to Contact",
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold),
                            ),
                          )),
                    ),
                  )
                ],
              )
            : Container(
                width: 0,
                height: 0,
              ));
  }
}
