// import 'dart:async';
// import 'dart:convert';
// // import 'dart:html' as html;
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:maulajimessenger/call/CallUnitGrp.dart';
// import 'package:maulajimessenger/streams/buttonStreams.dart';
// import 'dart:math';
// // import 'package:flutter_webrtc/web/rtc_session_description.dart';
//
// import 'package:sdp_transform/sdp_transform.dart';
//
// Future<FirebaseApp> customInitialize() {
//   return Firebase.initializeApp();
// }
//
// class App extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.light(),
//       home: FutureBuilder(
//         // Initialize FlutterFire:
//         //  future: Firebase.initializeApp(),
//         future: customInitialize(),
//         builder: (context, snapshot) {
//           // Check for errors
//           if (snapshot.hasError) {
//             return const Scaffold(
//               body: Center(
//                 child: Text("Error"),
//               ),
//             );
//           }
//
//           // Once complete, show your application
//           if (snapshot.connectionState == ConnectionState.done) {
//             //  FirebaseFirestore.instance.collection("9feb").add({"data":"data7"});
//
//             return MyApp();
//           }
//
//           // Otherwise, show something whilst waiting for initialization to complete
//           return const Scaffold(
//             body: Center(
//               child: Text("Loading..."),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// var ownCandidateID = null;
//
// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Maulaji Talk',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: Login(),
//     );
//   }
// }
//
// class GroupCall extends StatefulWidget {
//   Widget grids = Center(
//     child: Text("Please wait"),
//   );
//   List<Widget> allWidgs = [];
//
//   Wrap screen;
//
//   Widget self;
//
//   bool isScreenSharing = false;
//
//   List streams = [];
//
//   dynamic ownCandidateID;
//   String appbart = "";
//
//   bool isAudioMuted = false;
//
//   bool isVideoMuted = false;
//
//   bool hasCallOffered = false;
//
//   String callerID = "0";
//
//   String ownID = "0";
//   String partnerid = "0";
//   bool isCaller = false;
//   bool isRecording = false;
//
//   FirebaseFirestore firestore;
//
//   bool didOpositConnected = false;
//
//   dynamic offer;
//   String title = "t";
//   String room_id = "";
//
//   List<String> peerIds = [];
//
//   bool containsVideo = false;
//
//   GroupCall(
//       {this.ownID,
//       this.partnerid,
//       this.isCaller,
//       this.firestore,
//       this.containsVideo,
//       this.room_id});
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<GroupCall> with WidgetsBindingObserver {
//   bool started = false;
//
//   Timer timer;
//   bool _offer = false;
//   List<RTCPeerConnection> allPeers = [];
//   RTCPeerConnection _peerConnection;
//   MediaStream _localStream;
//   RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
//   RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();
//
//   MediaRecorder _mediaRecorder;
//
//   bool get _isRec => _mediaRecorder != null;
//   final sdpController = TextEditingController();
//   List<RTCVideoRenderer> remoteRenderList = [];
//
//   @override
//   dispose() {
//     _localRenderer.dispose();
//     _remoteRenderer.dispose();
//     sdpController.dispose();
//     timer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   void initState() {
//     setState(() {
//       widget.grids = Wrap(
//         children: widget.allWidgs,
//       );
//     });
//
//     initWorkLoad();
//
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // return Scaffold(body: Text(widget.ownID+"  "+widget.partnerid+"  "+widget.isCaller.toString()),);
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           Positioned(
//             left: 20,
//             bottom: 100,
//             child: Container(
//               height: 320,
//               child: Row(
//                 children: widget.allWidgs,
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//               width: MediaQuery.of(context).size.width,
//               height: 70,
//               child: Center(
//                 child: Container(
//                   height: 70,
//                   child: Center(
//                     child: Wrap(
//                       children: [
//                         // Padding(
//                         //   padding: const EdgeInsets.all(8.0),
//                         //   child: FloatingActionButton(
//                         //
//                         //     onPressed: () {
//                         //       if (widget.isCaller == true) {
//                         //         setState(() {
//                         //           widget.callerID = widget.ownID;
//                         //         });
//                         //         try {
//                         //           _createOffer();
//                         //         } catch (e) {
//                         //           setState(() {
//                         //             widget.appbart = "One exxecption from catch";
//                         //           });
//                         //           print("One exxecption from catch");
//                         //           print(e.toString());
//                         //         }
//                         //       } else {
//                         //         setState(() {
//                         //           widget.callerID = widget.partnerid;
//                         //         });
//                         //       }
//                         //     },
//                         //     child: Icon(Icons.audiotrack_outlined),
//                         //   ),
//                         // ),
//                         Padding(
//                           padding: const EdgeInsets.all(4.0),
//                           child: InkWell(
//                             onTap: () {
//                               handelScreenShaing();
//                             },
//                             child: Card(
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(22.0),
//                               ),
//                               color: Colors.redAccent,
//                               child: Container(
//                                 width: 44,
//                                 height: 44,
//                                 child: Center(
//                                   child: Icon(
//                                     !widget.isScreenSharing
//                                         ? Icons.stop_screen_share
//                                         : Icons.screen_share,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         // Padding(
//                         //   padding: const EdgeInsets.all(8.0),
//                         //   child: FloatingActionButton(
//                         //     backgroundColor: widget.isCaller
//                         //         ? Colors.redAccent
//                         //         : Colors.greenAccent,
//                         //     onPressed: () {
//                         //       for (int i = 0;
//                         //       i < _localStream.getAudioTracks().length;
//                         //       i++) {
//                         //         //_localStream.getVideoTracks()[i].(widget.isCameraOn);
//                         //         _localStream.getAudioTracks()[i].enabled =
//                         //         !(_localStream
//                         //             .getAudioTracks()[i]
//                         //             .enabled);
//                         //       }
//                         //       setState(() {
//                         //         widget.isAudioMuted = !widget.isAudioMuted;
//                         //       });
//                         //     },
//                         //     child: Icon(widget.isAudioMuted
//                         //         ? Icons.volume_off
//                         //         : Icons.volume_up_rounded),
//                         //   ),
//                         // ),
//                         Padding(
//                           padding: const EdgeInsets.all(4.0),
//                           child: InkWell(
//                             onTap: () async {
//                               try {
//                                 _peerConnection.close().then((value) async {
//                                   _peerConnection.dispose().then((value) async {
//                                     // Navigator.pop(context);
//
//                                     await widget.firestore
//                                         .collection("callQue")
//                                         .doc(widget.ownID)
//                                         .update({"active": false});
//                                     await widget.firestore
//                                         .collection("callQue")
//                                         .doc(widget.partnerid)
//                                         .update({"active": false});
//                                     // widget.callback();
//                                   });
//                                 });
//                               } catch (e) {
//                                 // widget.callback();
//                               }
//                             },
//                             child: Card(
//                               color: Colors.redAccent,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(22.0),
//                               ),
//                               child: Container(
//                                   width: 44,
//                                   height: 44,
//                                   child: Center(
//                                       child: Icon(
//                                     Icons.call_end,
//                                     color: Colors.white,
//                                   ))),
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(4.0),
//                           child: InkWell(
//                             onTap: () {
//                               handleCameraToggle();
//                             },
//                             child: Card(
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(22.0),
//                               ),
//                               color: Colors.redAccent,
//                               child: Container(
//                                 width: 44,
//                                 height: 44,
//                                 child: Center(
//                                   child: Icon(
//                                     !widget.containsVideo
//                                         ? Icons.videocam_off_outlined
//                                         : Icons.videocam,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         // Padding(
//                         //   padding: const EdgeInsets.all(8.0),
//                         //   child: FloatingActionButton(
//                         //     backgroundColor: widget.isCaller
//                         //         ? Colors.redAccent
//                         //         : Colors.greenAccent,
//                         //     onPressed: () {
//                         //       // _startRecording();
//                         //       widget.isRecording == true
//                         //           ? _stopRecording()
//                         //           : _startRecording();
//                         //     },
//                         //     child: Icon(widget.isRecording == true
//                         //         ? Icons.fiber_manual_record_rounded
//                         //         : Icons.fiber_manual_record_outlined),
//                         //   ),
//                         // ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void initWorkLoad() {
//     int currentParticipents = 0;
//     Timer.periodic(Duration(milliseconds: 1000), (timer) {
//       if (mounted) {
//         widget.firestore.collection(widget.room_id).doc(widget.ownID).set({
//           "uid": widget.ownID,
//           "time": new DateTime.now().millisecondsSinceEpoch
//         });
//       } else
//         timer.cancel();
//     });
//     widget.firestore.collection(widget.room_id).snapshots().listen((event) {
//       setState(() {
//         widget.appbart = "0";
//       });
//       if (event.size > 0 && event.docs.length > 0) {
//         currentParticipents = 0;
//         setState(() {
//           widget.appbart = currentParticipents.toString();
//         });
//         for (int i = 0; i < event.docs.length; i++) {
//           if (event.docs[i].data()["uid"] != widget.ownID &&
//               event.docs[i].data()["time"] + 3000 >
//                   DateTime.now().millisecondsSinceEpoch) {
//             currentParticipents++;
//             if (widget.peerIds.contains(event.docs[i].id)) {
//             } else {
//               setState(() {
//                 Random random = new Random();
//                 int randomNumber = random.nextInt(9999);
//                 String peerID = "peerId" +
//                     randomNumber.toString() +
//                     DateTime.now().millisecondsSinceEpoch.toString();
//                 talkWithHim(event.docs[i].id, peerID);
//                 widget.peerIds.add(event.docs[i].id);
//               });
//             }
//
//             // talkWithHim(event.docs[i].id);
//
//           }
//         }
//         setState(() {
//           widget.appbart = currentParticipents.toString();
//         });
//       }
//     });
//
//     widget.firestore.collection(widget.room_id).get().then((value) {});
//   }
//
//   // void initCallIntent(String callTYpe,String ownid, String partner, bool isCaller, FirebaseFirestore firestore,BuildContext context) async{
//   //
//   //   ownid.replaceAll("dd", "d");
//   //   ownid.replaceAll("pp", "p");
//   //
//   //   partner.replaceAll("dd", "d");
//   //   partner.replaceAll("pp", "p");
//   //
//   //
//   //
//   //   await  firestore.collection("callQue").doc(ownid).set(  {"caller":isCaller?ownid:partner, "target": isCaller?partner:ownid});
//   //   await firestore.collection("callQue").doc(partner).set( {"caller":isCaller?ownid:partner, "target": isCaller?partner:ownid});
//   //   await firestore.collection("refresh").doc(ownid).delete();
//   //   await  firestore.collection("refresh").doc(partner).delete();
//   //
//   //   Navigator.push(
//   //       context,
//   //       MaterialPageRoute(
//   //           builder: (context) =>  WillPopScope(
//   //             onWillPop: () async => false,
//   //             child: GrpUnit(
//   //                 containsVideo: false,
//   //                 ownID:ownid,
//   //                 partnerid:partner,
//   //                 isCaller:
//   //                 isCaller,
//   //                 firestore:
//   //                 firestore),
//   //
//   //           )));
//   // }
//
//   void talkWithHim(String id, String peerID) async {
//     List<String> allids = [id, widget.ownID];
//     allids.sort();
//
//     bool isCaller = allids.last == id ? true : false;
//     //first user is the caller
//
//     Function() callbackCamera;
//     await widget.firestore.collection("callQue").doc(widget.ownID).set({
//       "caller": isCaller ? widget.ownID : id,
//       "target": isCaller ? id : widget.ownID
//     });
//     await widget.firestore.collection("callQue").doc(id).set({
//       "caller": isCaller ? widget.ownID : id,
//       "target": isCaller ? id : widget.ownID
//     });
//     await widget.firestore.collection("refresh").doc(widget.ownID).delete();
//     await widget.firestore.collection("refresh").doc(id).delete();
//
//     setState(() {
//       //  widget.grids = Text(allids.first+" "+allids.last+"  "+id+"  "+widget.ownID);
//
//       //  widget.allWidgs.add(Text("new scre"));
//       // widget.allWidgs.clear();
//
//       widget.allWidgs.add(Padding(
//         padding: const EdgeInsets.all(2.0),
//         child: Card(
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(0.0),
//           ),
//           child: Container(
//             color: Colors.white,
//             width: 320,
//             child: Wrap(
//               children: [
//                 Center(
//                   child: FutureBuilder<QuerySnapshot>(
//                       // Initialize FlutterFire:
//                       //  future: Firebase.initializeApp(),
//                       future: widget.firestore
//                           .collection("users")
//                           .where("uid", isEqualTo: id)
//                           .get(),
//                       builder: (context, snapshot) {
//                         if (snapshot.hasData &&
//                             snapshot.data.size > 0 &&
//                             snapshot.data.docs.length > 0) {
//                           return Text(snapshot.data.docs.first.data()["name"]);
//                         } else {
//                           return Text("Please wait");
//                         }
//                       }),
//                 ),
//                 Container(
//                   width: 320,
//                   height: 240,
//                   child: GrpUnit(
//                     containsVideo: false,
//                     ownID: widget.ownID,
//                     partnerid: id,
//                     isCaller: isCaller,
//                     firestore: widget.firestore,
//                     partnerPair: allids.first + "-" + allids.last,
//                     callbackCamera: callbackCamera,
//                     isScreenSharing: widget.isScreenSharing,
//                     cameraALlreadyOpen: !widget.containsVideo,
//
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ));
//
// /*
//       widget.allWidgs.add(Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Card(shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(0.0),
//         ),color: Colors.white,
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child:Container(
//               width: 320,height: 240,
//               child: GrpGridMyWebCall(peerID:peerID,
//                   containsVideo:true,
//                   ownID:widget.ownID,
//                   partnerid:id,
//                   isCaller:
//                   isCaller,
//                   firestore:
//                   widget.firestore),
//             ),
//           ),
//         ),
//       ));
//       */
//       /*
//       widget.allWidgs.add( Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Container(width: 320,height: 240,
//           child: GrpGridMyWebCall(
//               containsVideo:true,
//               ownID:widget.ownID,
//               partnerid:id,
//               isCaller:
//               isCaller,
//               firestore:
//               widget.firestore),
//         ),
//       ));
//       */
//     });
//
//     // widget.firestore.collection(widget.room_id).doc(widget.ownID).
//   }
//
//   void handleCameraToggle() {
//     print("should show");
//     CallButonsClickStreamCamera.getInstance().dataReload(widget.containsVideo);
//     setState(() {
//       setState(() {
//         widget.containsVideo = !widget.containsVideo;
//       });
//
//     });
//   }
//
//   void handelScreenShaing() {
//     //CallButonsClickStreamScreen
//
//     print("should show");
//     CallButonsClickStreamScreen.getInstance().dataReload(widget.isScreenSharing);
//     setState(() {
//       setState(() {
//         widget.isScreenSharing = !widget.isScreenSharing;
//       });
//
//     });
//   }
// }
//
// String makeRoomName(int one, int two) {
//   if (one > two)
//     return "" + one.toString() + "-" + two.toString();
//   else
//     return "" + two.toString() + "-" + one.toString();
// }
//
// class MainHomePage extends StatefulWidget {
//   @override
//   _MainHomePageState createState() => _MainHomePageState();
// }
//
// class _MainHomePageState extends State<MainHomePage> {
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     CallButonsClickStreamCamera.getInstance().outData.listen((event) {
//       print("camera click found");
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Row(
//           children: [
//             Container(
//               width: 300,
//               height: MediaQuery.of(context).size.height,
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
