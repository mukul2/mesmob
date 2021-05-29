// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'dart:io' show Platform;
// import 'package:flutter/foundation.dart' show kIsWeb;
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
// class Conf extends StatefulWidget {
//   List streams = [];
//
//
//   dynamic ownCandidateID;
//   String appbart = "";
//
//   bool isAudioMuted = false;
//   bool isScreenSharing = false;
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
//   String partnerPair;
//
//   String localStreamId;
//   String shareScreenId;
//   bool anyRemoteVideoStrem = false;
//   String room;
//
//
//
//   dynamic offer;
//   String title = "t";
//   List <Widget> allBody = [];
//   Widget body = Text("") ;
//
//   bool containsVideo;
//   bool isCameraShowing = false ;
//   String room_id = "grp";
//   void Function() callback;
//   List<String>peerIds = [] ;
//   Conf(
//       {this.partnerPair,
//         this.ownID,
//         this.partnerid,
//         this.isCaller,
//         this.firestore,
//         this.containsVideo,this.callback});
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<Conf>
//     with WidgetsBindingObserver {
//   Timer timer;
//   bool _offer = false;
//   RTCPeerConnection _peerConnection;
//   MediaStream _localStream;
//   MediaStream _localStreamVideo;
//   MediaStream _localStreamScreenShare ;
//   MediaStream _localStreamForShare ;
//   RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
//   RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();
//   RTCVideoRenderer _remoteRendererAudio = new RTCVideoRenderer();
//   String remoteShowingStreamID ;
//
//   MediaRecorder _mediaRecorder;
//
//   bool get _isRec => _mediaRecorder != null;
//   final sdpController = TextEditingController();
//   List<RTCVideoRenderer> remoteRenderList = [];
//   RTCPeerConnection pc;
//   @override
//   dispose() {
//     _localRenderer.dispose();
//     _remoteRenderer.dispose();
//     _remoteRendererAudio.dispose();
//     sdpController.dispose();
//     timer?.cancel();
//     super.dispose();
//   }
//   void LookForparticipents() {
//
//     int currentParticipents = 0 ;
//     Timer.periodic(Duration(milliseconds: 1000), (timer) {
//       if (mounted) {
//         widget.firestore.collection(widget.room_id).doc(widget.ownID).set({"uid":widget.ownID,"time":new DateTime.now().millisecondsSinceEpoch});
//
//
//       }else  timer.cancel();
//
//     });
//     widget.firestore.collection(widget.room_id).snapshots().listen((event) {
//       setState(() {
//         widget.appbart = "0";
//       });
//       if(event.size>0 && event.docs.length>0) {
//         currentParticipents = 0;
//         setState(() {
//           widget.appbart =currentParticipents.toString();
//         });
//         for(int i = 0 ; i <  event.docs.length;i++){
//           if(event.docs[i].data()["uid"]!=widget.ownID &&  event.docs[i].data()["time"]+3000>DateTime.now().millisecondsSinceEpoch){
//             currentParticipents++;
//             if(widget.peerIds.contains(event.docs[i].id)){
//
//             }else{
//               setState(() {
//                 Random random = new Random();
//                 int randomNumber = random.nextInt(9999);
//                 String peerID = "peerId"+randomNumber.toString()+DateTime.now().millisecondsSinceEpoch.toString();
//
//                 widget.peerIds.add(event.docs[i].id);
//                 createPeer(event.docs[i].id,peerID);
//
//               });
//
//             }
//
//             // talkWithHim(event.docs[i].id);
//
//
//
//
//
//           }
//         }
//         setState(() {
//           widget.appbart =currentParticipents.toString();
//         });
//
//
//       }
//     });
//
//     widget.firestore.collection(widget.room_id).get().then((value) {
//
//     });
//
//
//
//
//   }
//   @override
//   void initState() {
//     startGeneratingPeer();
//
//
//   }
//
//   initRenderers() async {
//     await _localRenderer.initialize();
//     await _remoteRenderer.initialize();
//     await _remoteRendererAudio.initialize();
//   }
//
//   void _createOffer(String room) async {
//     RTCSessionDescription description = await _peerConnection
//         .createOffer({'offerToReceiveVideo': 1, 'offerToReceiveAudio': 1});
//
//     var session = parse(description.sdp);
//     print("cerate off");
//     print(json.encode(session));
//     _offer = true;
//
//     // print(json.encode({
//     //       'sdp': description.sdp.toString(),
//     //       'type': description.type.toString(),
//     //     }));
//     //FirebaseFirestore.instance.collection(widget.ownID).add(session);
//     // print("writing my own des");
//
//     await _peerConnection.setLocalDescription(description);
//     await FirebaseFirestore.instance.collection("rooms").doc(room).set({
//       'roolId': room,
//       'offer': {
//         "type": description.type,
//         "sdp": description.sdp,
//       }
//     });
//
//     // FirebaseFirestore.instance.collection("callQue").doc(widget.partnerid).set(
//     //     {"caller": widget.ownID, "target": widget.partnerid});
//     // FirebaseFirestore.instance.collection("callQue").doc(widget.ownID).set(
//     //     {"caller": widget.ownID, "target": widget.partnerid});
//
//     setState(() {
//       widget.hasCallOffered = true;
//     });
//     if(true){
//
//
//       FirebaseFirestore.instance
//           .collection("rooms")
//           .doc(room)
//           .snapshots()
//           .listen((event) async {
//         if ( event.exists && event.data()["answer"] != null) {
//           //mkl
//
//           print("remote des below");
//           print(event.data()["answer"]);
//
//           dynamic ss = event.data()["answer"];
//           setState(() {
//             widget.appbart = "gdr " + ss["type"];
//           });
//           RTCSessionDescription description =
//           new RTCSessionDescription(ss["sdp"], ss["type"]);
//
//           print("my suspect");
//           print(description.toMap());
//           print("my suspect ends");
//           setState(() {
//             widget.appbart = widget.appbart + ss["type"];
//           });
//           await _peerConnection.setRemoteDescription(description);
//           setState(() {
//             widget.appbart = "  remote des added ";
//           });
//
//           FirebaseFirestore.instance
//               .collection("rooms")
//               .doc(room)
//               .collection("calleeCandidates")
//               .snapshots()
//               .listen((event) async {
//             if (event.docs.length > 0) {
//               setState(() {
//                 widget.appbart = widget.appbart +
//                     " candidate side " +
//                     event.docs.length.toString() +
//                     " ";
//               });
//               for (int i = 0; i < event.docs.length; i++) {
//                 dynamic candidate = new RTCIceCandidate(
//                   event.docs[i].data()["candidate"],
//                   event.docs[i].data()["sdpMid"],
//                   event.docs[i].data()["sdpMLineIndex"],
//                 );
//                 print("one candidate added");
//
//                 // dynamic session = event.docs[i].data();
//
//                 //dynamic candidate = new RTCIceCandidate(session['candidate'], session['sdpMid'], session['sdpMLineIndex']);
//                 _peerConnection.addCandidate(candidate).then((value) {
//                   setState(() {
//                     widget.appbart = widget.appbart + "  ca" + i.toString() + " ";
//                   });
//                 });
//               }
//             } else {
//               setState(() {
//                 widget.appbart = widget.appbart + "  no candidate " + " ";
//               });
//             }
//           });
//         } else {
//           setState(() {
//             widget.appbart = widget.appbart + " no AF";
//           });
//         }
//       });
//
//       FirebaseFirestore.instance
//           .collection("queu")
//           .doc(widget.partnerPair)
//           .set({"room": room}).then((value) {
//         submitCallReceiverPush(widget.isCaller, widget.partnerid,room);
//         submitCallReceiverPushReverse(widget.isCaller, widget.partnerid,room);
//       });
//     }
//     // print("writing my own des end of ");
//   }
//   void _createOfferNego(String room) async {
//     RTCSessionDescription description = await _peerConnection.createOffer({'offerToReceiveVideo': 1, 'offerToReceiveAudio': 1});
//
//     var session = parse(description.sdp);
//
//
//     await _peerConnection.setLocalDescription(description);
//
//     await FirebaseFirestore.instance.collection("changes").add({
//
//       'offer': {
//         "type": description.type,
//         "sdp": description.sdp,
//       }
//     }).then((value) {
//         try{
//         FirebaseFirestore.instance
//             .collection("nego")
//             .doc(room)
//             .set({"id":value.id,"time":DateTime.now().millisecondsSinceEpoch,"type":"o"}).then((value) {
//
//         });
//         }catch(e){
//       FirebaseFirestore.instance
//           .collection("nego")
//           .doc(room)
//           .update({"id":value.id,"time":DateTime.now().millisecondsSinceEpoch,"type":"o"}).then((value) {
//
//       });
//     }
//
//     });
//
//
//
//
//
//     // print("writing my own des end of ");
//   }
//   void _createAnswer() async {
//     RTCSessionDescription description = await _peerConnection
//         .createAnswer({'offerToReceiveVideo': 1, 'offerToReceiveAudio': 1});
//
//     var session = parse(description.sdp);
//     print("for " + widget.ownID);
//     print(json.encode(session));
//     print("for " + widget.ownID + " ends");
//     // print(json.encode({
//     //       'sdp': description.sdp.toString(),
//     //       'type': description.type.toString(),
//     //     }));
//     FirebaseFirestore.instance
//         .collection("offer")
//         .doc(widget.ownID)
//         .set({"offer": json.encode(session)});
//     _peerConnection.setLocalDescription(description);
//
//     print("answer done");
//     FirebaseFirestore.instance.collection("refresh").doc(widget.partnerid).set({
//       "time": new DateTime.now().millisecondsSinceEpoch,
//     });
//   }
//
//   void _createAnswerfb(String id) async {
//     try {
//       RTCSessionDescription description =
//       await _peerConnection.createAnswer({'offerToReceiveVideo': 1});
//
//       var session = parse(description.sdp);
//       print("what is this");
//       // print(json.encode(session));
//       print("what is this end ");
//
//       print(json.encode({
//         'sdp': description.sdp.toString(),
//         'type': description.type.toString(),
//       }));
//       print("trying start");
//       // print(description.toMap().toString());
//
//       _peerConnection.setLocalDescription(description);
//       print("trying 2");
//       //  print(_peerConnection.defaultSdpConstraints.toString());
//       print("trying ends");
//       // FirebaseFirestore.instance
//       //     .collection("offer")
//       //     .doc(widget.ownID)
//       //     .set({"offer":json.encode(session)});
//     } catch (e) {
//       print("catch her e");
//       print(e.toString());
//     }
//   }
//
//   void _createAnswerFB(String id) async {
//     RTCSessionDescription description =
//     await _peerConnection.createAnswer({'offerToReceiveVideo': 1});
//
//     var session = parse(description.sdp);
//     //  print(json.encode(session));
//     // print(json.encode({
//     //       'sdp': description.sdp.toString(),
//     //       'type': description.type.toString(),
//     //     }));
//     FirebaseFirestore.instance
//         .collection("candidate")
//         .doc(widget.ownID)
//         .collection("d")
//         .add({"candidate": json.encode(session)});
//
//     //callerCandidates
//
//     _peerConnection.setLocalDescription(description);
//
//     print("addint candidate info ");
//
//     //FirebaseFirestore.instance.collection("callQue").doc(makeRoomName(int.parse(widget.ownID), int.parse(widget.partnerid))).update({"candidate":session});
//   }
//
//   void _setRemoteDescription() async {
//     String jsonString = sdpController.text;
//     dynamic session = await jsonDecode('$jsonString');
//
//     String sdp = write(session, null);
//
//     // RTCSessionDescription description =
//     //     new RTCSessionDescription(session['sdp'], session['type']);
//     RTCSessionDescription description =
//     new RTCSessionDescription(sdp, _offer ? 'answer' : 'offer');
//
//     print("my suspect");
//     print(description.toMap());
//     print("my suspect ends");
//
//     await _peerConnection.setRemoteDescription(description);
//   }
//
//   void _setRemoteDescriptionFB(String data) async {
//     String jsonString = data;
//     dynamic session = await jsonDecode('$jsonString');
//
//     String sdp = write(session, null);
//
//     // RTCSessionDescription description =
//     //     new RTCSessionDescription(session['sdp'], session['type']);
//     RTCSessionDescription description =
//     new RTCSessionDescription(sdp, _offer ? 'answer' : 'offer');
//     print("my suspect 1");
//     print(description.toMap());
//     print("my suspect 2 end");
//
//     await _peerConnection.setRemoteDescription(description);
//
//     print("now going for answer");
//     //  _createAnswerfb(widget.ownID);
//
//     _createAnswer();
//   }
//
//   void _setRemoteDescriptionNoAnswer(String data, String targetid) async {
//     String jsonString = data;
//     dynamic session = await jsonDecode('$jsonString');
//
//     String sdp = write(session, null);
//
//     // RTCSessionDescription description =
//     //     new RTCSessionDescription(session['sdp'], session['type']);
//     RTCSessionDescription description =
//     new RTCSessionDescription(sdp, _offer ? 'answer' : 'offer');
//     print("my suspect 3");
//     print(description.toMap());
//     print("my suspect 3 ends");
//
//     await _peerConnection.setRemoteDescription(description);
//     FirebaseFirestore.instance
//         .collection("candidate")
//         .doc(targetid)
//         .collection("d")
//         .get()
//         .then((value) {
//       for (int i = 0; i < value.docs.length; i++) {
//         _addCandidateFB(value.docs[i].data()["candidate"]);
//       }
//       print("downloaded candidate");
//     });
//   }
//
//   void _addCandidate() async {
//     String jsonString = sdpController.text;
//     dynamic session = await jsonDecode('$jsonString');
//     print("my suspect 4");
//     print(session['candidate']);
//     print("my suspecr 5 ends");
//     dynamic candidate = new RTCIceCandidate(
//         session['candidate'], session['sdpMid'], session['sdpMlineIndex']);
//     await _peerConnection.addCandidate(candidate);
//   }
//
//   void _addCandidateFB(String can) async {
//     String jsonString = can;
//     dynamic session = await jsonDecode('$jsonString');
//     print("my suspect 4");
//     print(session['candidate']);
//     print("my suspecr 5 ends");
//     dynamic candidate = new RTCIceCandidate(
//         session['candidate'], session['sdpMid'], session['sdpMlineIndex']);
//     await _peerConnection.addCandidate(candidate);
//   }
//
//   _createPeerConnection(String roomID) async {
//     // Map<String, dynamic> configuration = {
//     //   "iceServers": [
//     //     {"url": "stun:stun.l.google.com:19302"},
//     //   ]
//     // };
//
//     Map<String, dynamic> configuration333 = {
//       'iceServers': [
//         {
//           'url': 'stun:global.stun.twilio.com:3478?transport=udp',
//           'urls': 'stun:global.stun.twilio.com:3478?transport=udp'
//         },
//         {
//           'url': 'turn:global.turn.twilio.com:3478?transport=udp',
//           'username':
//           '3f926f4477b772f4a60860bdb437393c678caed6bda265137c9f25ccabe7d7f3',
//           'urls': 'turn:global.turn.twilio.com:3478?transport=udp',
//           'credential': 'C0yrr3LLqUn35Yo3VTyPGQn84q8mLAgQO0xfspErp4g='
//         },
//         {
//           'url': 'turn:global.turn.twilio.com:3478?transport=tcp',
//           'username':
//           '3f926f4477b772f4a60860bdb437393c678caed6bda265137c9f25ccabe7d7f3',
//           'urls': 'turn:global.turn.twilio.com:3478?transport=tcp',
//           'credential': 'C0yrr3LLqUn35Yo3VTyPGQn84q8mLAgQO0xfspErp4g='
//         },
//         {
//           'url': 'turn:global.turn.twilio.com:443?transport=tcp',
//           'username':
//           '3f926f4477b772f4a60860bdb437393c678caed6bda265137c9f25ccabe7d7f3',
//           'urls': 'turn:global.turn.twilio.com:443?transport=tcp',
//           'credential': 'C0yrr3LLqUn35Yo3VTyPGQn84q8mLAgQO0xfspErp4g='
//         }
//       ]
//     };
//
//     Map<String, dynamic> configuration = {
//       'iceServers': [
//         {'urls': 'stun:stun.nextcloud.com:443'},
//         {'urls': 'stun:relay.webwormhole.io'},
//         {'urls': 'stun:stun.services.mozilla.com'},
//         {'urls': 'stun:stun.l.google.com:19302'},
//         {
//           'url': 'stun:global.stun.twilio.com:3478?transport=udp',
//           'urls': 'stun:global.stun.twilio.com:3478?transport=udp'
//         },
//         {
//           'urls': 'turn:86.11.136.36:3478',
//           'credential': '%Welcome%4\$12345',
//           'username': 'administrator'
//         }
//       ],
//       "sdpSemantics": kIsWeb ? "plan-b" : "unified-plan"
//     };
//     Map<String, dynamic> configuration33 = {
//       'iceServers': [
//         {"url": "stun:stun.l.google.com:19302"},
//         {
//           'urls': 'turn:numb.viagenie.ca',
//           'credential': '01620645499mkl',
//           'username': 'saidur.shawon@gmail.com'
//         }
//       ]
//     };
//     Map<String, dynamic> configuration220 = {
//       'iceServers': [
//         {'urls': 'stun:stun.services.mozilla.com'},
//         {'urls': 'stun:stun.l.google.com:19302'},
//         {
//           'urls': 'turn:numb.viagenie.ca',
//           'credential': '01620645499mkl',
//           'username': 'saidur.shawon@gmail.com'
//         }
//       ]
//     };
//     final Map<String, dynamic> offerSdpConstraints = {
//       "mandatory": {
//         "OfferToReceiveAudio": true,
//         "OfferToReceiveVideo": true,
//       },
//       "optional": [],
//     };
//
//     MediaStream  _primaryStreem = await _getUserMedia();
//     //   _localStreamScreenShare = await _getUserMedia();
//
// //widget.containsVideo == false
// //     if( widget.containsVideo == false){
// //       for(int i = 0 ; i <_localStream.getVideoTracks().length ; i ++){
// //         //_localStream.getVideoTracks()[i].(widget.isCameraOn);
// //         _localStream.getVideoTracks()[i].enabled = !(_localStream.getVideoTracks()[i].enabled);
// //       }
// //       setState(() {
// //         widget.isVideoMuted =  ! widget.isVideoMuted;
// //       });
// //     }
//
//     pc = await createPeerConnection(configuration, offerSdpConstraints);
//
//     pc.onRenegotiationNeeded = (){
//
//
//       if(widget.didOpositConnected){
//         if(widget.isCaller){
//          // _createOfferNego(roomID);
//           MakeNewOfferNegoX(roomID);
//         }else{
//           MakeNewANswerNego(roomID);
//         }
//         setState(() {
//           widget.appbart = "renegotionation";
//         });
//       }
//
//
//     };
//
//
//
//     if (pc != null) {
//       print(pc);
//       print("yess error ");
//     }
//     if (kIsWeb) {
//       // running on the web!
//
//
//       final Map<String, dynamic> mediaConstraintsScreen = {
//         'audio': true,
//         'video': {
//           'width': {'ideal': 1280},
//           'height': {'ideal': 720}
//         }
//       };
//       // MediaStream streamScreenShare = await navigator.mediaDevices.getDisplayMedia(mediaConstraintsScreen);
//       //await pc.addStream(streamScreenShare);
//
//       await  pc.addStream(_primaryStreem);
//
//       //  await  pc.addStream(_localStreamScreenShare);
//       // await  pc.addStream(_localStream.);
//
//
//     } else {
//       _localStream.getTracks().forEach((track) {
//         pc.addTrack(track, _localStream);
//       });
//     }
//
//
//
//     pc.onRemoveStream = (e)async {
//
//       // setState(() {
//       //   _remoteRenderer.srcObject = _remoteRendererAudio.srcObject;
//       // });
//
//       setState(() {
//         widget.anyRemoteVideoStrem = false ;
//       });
//
//       // setState(() {
//       //   widget.anyRemoteVideoStrem = false;
//       //
//       //   List filtredStream = [] ;
//       //   //filtredStream.addAll(widget.streams);
//       //   for(int i = 0 ; i < widget.streams.length ; i++){
//       //     if( widget.streams[i]["id"] != e.id){
//       //       filtredStream.add(widget.streams[i]);
//       //     }
//       //     widget.streams.clear();
//       //     widget.streams.addAll(filtredStream);
//       //   }
//       //
//       // });
//       //
//       //
//       // setState(() {
//       //   remoteRenderList.clear();
//       // });
//       //
//       // for(int i = 0 ; i < widget.streams.length ; i++){
//       //   RTCVideoRenderer  _re = new RTCVideoRenderer();
//       //   await _re.initialize();
//       //   _re.srcObject = widget.streams[i]["stream"];
//       //   setState(() {
//       //     remoteRenderList.add(_re);
//       //
//       //   });
//       // }
//       // setState(() {
//       //   _remoteRenderer =remoteRenderList.last;
//       // });
//
//
//
//
//
//
//     };
//
//     pc.onIceCandidate = (e) {
//       setState(() {
//         //  widget.appbart = e.toString();
//       });
//       if (e.candidate != null) {
//         print("supecrt 7");
//
//         dynamic data = ({
//           'candidate': e.candidate.toString(),
//           'sdpMid': e.sdpMid.toString(),
//           'sdpMLineIndex': e.sdpMlineIndex,
//         });
//
//         if (ownCandidateID == null) {
//           ownCandidateID = data;
//         }
//         FirebaseFirestore.instance
//             .collection("rooms")
//             .doc(roomID)
//             .collection(
//             widget.isCaller ? "callerCandidates" : "calleeCandidates")
//             .add(data);
//
//         print(json.encode({
//           'candidate': e.candidate.toString(),
//           'sdpMid': e.sdpMid.toString(),
//           'sdpMlineIndex': e.sdpMlineIndex,
//         }));
//         print("supecrt 7 end");
//       }
//     };
//     pc.onSignalingState = (e) {
//       if (pc.iceConnectionState ==
//           RTCIceConnectionState.RTCIceConnectionStateConnected) {
//         setState(() {
//           widget.didOpositConnected = true;
//           widget.appbart = "connected";
//         });
//       }
//
//       if (widget.didOpositConnected = true) {
//         if (pc.iceConnectionState ==
//             RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
//           _peerConnection.close().then((value) {
//             _peerConnection.dispose().then((value) {
//               Navigator.pop(context);
//             });
//           });
//         }
//       }
//
//
//
//       if (pc.iceConnectionState == 'disconnected') {}
//     };
//     if (kIsWeb) {
//       // running on the web!
//       pc.onAddStream = (stream) async {
//
//         // if(stream.getVideoTracks().length>0){
//         //   setState(() {
//         //     _remoteRenderer.srcObject = stream;
//         //     widget.anyRemoteVideoStrem = true;
//         //     remoteShowingStreamID = stream.id;
//         //     _remoteRenderer.srcObject = stream;
//         //   });
//         //
//         // }else{
//         //   _remoteRendererAudio.srcObject = stream;
//         // }
//
//         if(_remoteRendererAudio.srcObject == null ){
//           setState(() {
//             _remoteRendererAudio.srcObject = stream ;
//           });
//         }else
//
//
//           setState(() {
//             widget.anyRemoteVideoStrem = true ;
//             _remoteRenderer.srcObject = stream ;
//           });
//
//
//
//         //
//         //
//         // setState(() {
//         //   widget.streams.add({"id":stream.id,"stream":stream});
//         //   // widget.appbart = pc.getRemoteStreams().length.toString()+" "+ pc.getLocalStreams().length.toString()+" "+ pc.getRemoteStreams().first.getVideoTracks().toString()+" "+ pc.getLocalStreams().first.getVideoTracks().toString();
//         //   // widget.appbart =widget.streams.length.toString();
//         // });
//         //
//         // setState(() {
//         //   // _remoteRenderer.srcObject = widget.streams.last["stream"];
//         //
//         //   remoteRenderList.clear();
//         //   // widget.streams.clear();
//         // });
//         //
//         // for(int i = 0 ; i < widget.streams.length ; i++){
//         //   RTCVideoRenderer  _re = new RTCVideoRenderer();
//         //   await _re.initialize();
//         //
//         //   setState(() {
//         //
//         //     _re.srcObject = widget.streams[i]["stream"];
//         //     remoteRenderList.add(_re);
//         //
//         //   });
//         // }
//         // setState(() {
//         //   _remoteRenderer =remoteRenderList.last;
//         // });
//
//
//
//       };
//     } else {
//       pc.onTrack = (event) {
//         if (event.track.kind == 'video') {
//           _remoteRenderer.srcObject = event.streams.first;
//           // event.streams.first.getTracks().forEach((track) {
//           //
//           //
//           // });
//
//         }
//       };
//     }
//
//     // ownOffer(pc);
//
//     //
//     return pc;
//   }
//
//   void _startRecording() async {
//     // customStream.addTrack(_localStream.);
//
//     // for(int i = 0 ; i < _localStream.getTracks() .length ; i ++){
//     //   customStream.addTrack(_localStream.getTracks()[i]);
//     // }
//
//     // for(int i = 0 ; i < _remoteRenderer.srcObject.getTracks() .length ; i ++){
//     //   customStream.addTrack(_remoteRenderer.srcObject.getTracks()[i]);
//     // }
//
//     _mediaRecorder = MediaRecorder();
//     setState(() {
//       widget.isRecording = true;
//     });
//
//     _mediaRecorder.startWeb(_remoteRenderer.srcObject);
//   }
//
//   void _stopRecording() async {
//     // final objectUrl = await _mediaRecorder?.stop();
//     // setState(() {
//     //   _mediaRecorder = null;
//     //   widget.isRecording = false;
//     // });
//     // print(objectUrl);
//     // html.window.open(objectUrl, '_blank');
//     // downloadFile(objectUrl);
//   }
//
//   void downloadFile(String url) {
//     // html.AnchorElement anchorElement = new html.AnchorElement(href: url);
//     // anchorElement.download = url;
//     // anchorElement.click();
//   }
//
//   _getUserMedia() async {
//     final Map<String, dynamic> mediaConstraints = {
//       'audio': true,
//       'video':  false
//     };
//
//
//     MediaStream stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
//     //MediaStream streamScreenShare = await navigator.mediaDevices.getDisplayMedia(mediaConstraintsScreen);
//     // MediaStream stream   = await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
//
//     // _localStream = stream;
//
//     //_localRenderer.srcObject = stream;
//     // _localRenderer.mirror = true;
//
//     //  RTCVideoRenderer  _re = new RTCVideoRenderer();
//     // await _re.initialize();
//     //// _re.srcObject = stream;
//     setState(() {
//       // remoteRenderList.add(_re);
//
//     });
//
//
//
//     // _peerConnection.addStream(stream);
//
//     return stream;
//   }
//
//   SizedBox videoRenderers() => SizedBox(
//       height: 500,
//       child: Row(children: [
//         Flexible(
//           child: new Container(
//               key: new Key("local"),
//               margin: new EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
//               decoration: new BoxDecoration(color: Colors.black),
//               child: new RTCVideoView(_localRenderer)),
//         ),
//         Flexible(
//           child: new Container(
//               key: new Key("remote"),
//               margin: new EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
//               decoration: new BoxDecoration(color: Colors.black),
//               child: new RTCVideoView(_remoteRenderer)),
//         )
//       ]));
//
//   Widget screenView() {
//     return Center(
//       child: Container(
//         color: Colors.black,
//         width: MediaQuery.of(context).size.width,
//         height: MediaQuery.of(context).size.height,
//         child: Stack(
//           children: [
//             Align(
//                 alignment: Alignment.center,
//                 child:new RTCVideoView(
//                   _remoteRendererAudio,
//                   objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
//                 )),
//             Align(
//                 alignment: Alignment.bottomCenter,
//                 child:widget.anyRemoteVideoStrem == true ? new RTCVideoView(
//                   _remoteRenderer,
//                   objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
//                 ):Center(child: Text("Maulaji Talk",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 50),),)),
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 width: MediaQuery.of(context).size.width,
//                 height: 70,
//                 child: Center(
//                   child: Container(
//                     height: 70,
//
//
//                     child: Center(
//                       child: Wrap(
//                         children: [
//                           // Padding(
//                           //   padding: const EdgeInsets.all(8.0),
//                           //   child: FloatingActionButton(
//                           //
//                           //     onPressed: () {
//                           //       if (widget.isCaller == true) {
//                           //         setState(() {
//                           //           widget.callerID = widget.ownID;
//                           //         });
//                           //         try {
//                           //           _createOffer();
//                           //         } catch (e) {
//                           //           setState(() {
//                           //             widget.appbart = "One exxecption from catch";
//                           //           });
//                           //           print("One exxecption from catch");
//                           //           print(e.toString());
//                           //         }
//                           //       } else {
//                           //         setState(() {
//                           //           widget.callerID = widget.partnerid;
//                           //         });
//                           //       }
//                           //     },
//                           //     child: Icon(Icons.audiotrack_outlined),
//                           //   ),
//                           // ),
//                           Padding(
//                             padding: const EdgeInsets.all(4.0),
//                             child: InkWell(onTap: (){
//                               handelScreenShaing();
//                             },
//                               child: Card(
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(22.0),
//                                 ),
//                                 color:Colors.redAccent,
//
//                                 child: Container(width: 44,height:44,
//                                   child: Center(
//                                     child: Icon(!widget.isScreenSharing
//                                         ? Icons.stop_screen_share
//                                         : Icons.screen_share,color: Colors.white,),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           // Padding(
//                           //   padding: const EdgeInsets.all(8.0),
//                           //   child: FloatingActionButton(
//                           //     backgroundColor: widget.isCaller
//                           //         ? Colors.redAccent
//                           //         : Colors.greenAccent,
//                           //     onPressed: () {
//                           //       for (int i = 0;
//                           //       i < _localStream.getAudioTracks().length;
//                           //       i++) {
//                           //         //_localStream.getVideoTracks()[i].(widget.isCameraOn);
//                           //         _localStream.getAudioTracks()[i].enabled =
//                           //         !(_localStream
//                           //             .getAudioTracks()[i]
//                           //             .enabled);
//                           //       }
//                           //       setState(() {
//                           //         widget.isAudioMuted = !widget.isAudioMuted;
//                           //       });
//                           //     },
//                           //     child: Icon(widget.isAudioMuted
//                           //         ? Icons.volume_off
//                           //         : Icons.volume_up_rounded),
//                           //   ),
//                           // ),
//                           Padding(
//                             padding: const EdgeInsets.all(4.0),
//                             child: InkWell(onTap: ()async{
//
//                                 try {
//                                   _peerConnection.close().then((value) async{
//                                     _peerConnection.dispose().then((value) async{
//                                       // Navigator.pop(context);
//
//
//
//                                   await    widget.firestore
//                                           .collection("callQue")
//                                           .doc(widget.ownID).update({"active":false});
//                                   await    widget.firestore
//                                           .collection("callQue")
//                                           .doc(widget.partnerid).update({"active":false});
//                                       widget.callback();
//
//                                     });
//                                   });
//                                 } catch (e) {
//                                   widget.callback();
//                                 }
//                               },
//
//                               child: Card(
//                                 color: Colors.redAccent,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(22.0),
//                                 ),
//
//
//                                 child: Container(width: 44,height:44,
//                                     child: Center(child: Icon(Icons.call_end,color: Colors.white,))),
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(4.0),
//                             child: InkWell(onTap: (){
//                               handleCameraToggle();
//                             },
//                               child: Card(
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(22.0),
//                                 ),
//                                 color:Colors.redAccent,
//
//                                 child: Container(width: 44,height:44,
//                                   child: Center(
//                                     child: Icon(!widget.containsVideo
//                                         ? Icons.videocam_off_outlined
//                                         : Icons.videocam,color: Colors.white,),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           // Padding(
//                           //   padding: const EdgeInsets.all(8.0),
//                           //   child: FloatingActionButton(
//                           //     backgroundColor: widget.isCaller
//                           //         ? Colors.redAccent
//                           //         : Colors.greenAccent,
//                           //     onPressed: () {
//                           //       // _startRecording();
//                           //       widget.isRecording == true
//                           //           ? _stopRecording()
//                           //           : _startRecording();
//                           //     },
//                           //     child: Icon(widget.isRecording == true
//                           //         ? Icons.fiber_manual_record_rounded
//                           //         : Icons.fiber_manual_record_outlined),
//                           //   ),
//                           // ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             _localRenderer.srcObject !=null?   Positioned(
//               right: 5,
//               top: 5,
//               child: Container(
//                 height: 100,
//                 width: 100,
//                 child: Container(
//                     key: new Key("local"),
//                     margin: new EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
//                     decoration: new BoxDecoration(color: Colors.black),
//                     child: new RTCVideoView(
//                       _localRenderer,
//                       objectFit:
//                           RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
//                     )),
//               ),
//             ):Container(width: 0,height: 0,),
//
//             Align(
//                 alignment: Alignment.topLeft,
//                 child: Container(
//                   height: 106,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: remoteRenderList.length,
//                     itemBuilder: (context, index) {
//                       return Container(
//                         color: Colors.white,
//                         child: Padding(
//                           padding: const EdgeInsets.all(3.0),
//                           child: Container(
//                             width: 100,
//                             height: 100,
//                             child:false? Center(child: Icon(Icons.volume_up_rounded,color: Colors.redAccent,),) :new RTCVideoView(remoteRenderList[index],objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,),
//                             // child: new RTCVideoView( remoteRenderList[index],),//remoteRenderList[index].srcObject.getVideoTracks().length== 0
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 )),
//
//
//           ],
//         ),
//       ),
//     );
//   }
//
//   Row offerAndAnswerButtons() =>
//       Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
//         new RaisedButton(
//           // onPressed: () {
//           //   return showDialog(
//           //       context: context,
//           //       builder: (context) {
//           //         return AlertDialog(
//           //           content: Text(sdpController.text),
//           //         );
//           //       });
//           // },
//           // onPressed: _createOffer,
//           child: Text('Offer'),
//           color: Colors.amber,
//         ),
//         RaisedButton(
//           onPressed: _createAnswer,
//           child: Text('Answer'),
//           color: Colors.amber,
//         ),
//       ]);
//
//   Row sdpCandidateButtons() =>
//       Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
//         RaisedButton(
//           onPressed: _setRemoteDescription,
//           child: Text('Set Remote Desc'),
//           color: Colors.amber,
//         ),
//         RaisedButton(
//           onPressed: _addCandidate,
//           child: Text('Add Candidate'),
//           color: Colors.amber,
//         )
//       ]);
//
//   Padding sdpCandidatesTF() => Padding(
//     padding: const EdgeInsets.all(16.0),
//     child: TextField(
//       controller: sdpController,
//       keyboardType: TextInputType.multiline,
//       maxLines: 4,
//       maxLength: TextField.noMaxLength,
//     ),
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     // return Scaffold(body: Text(widget.ownID+"  "+widget.partnerid+"  "+widget.isCaller.toString()),);
//     // List<RTCVideoRenderer> remoteRenderListFiltered = [];
//     // for(int i =  0 ; i < remoteRenderList.length; i++){
//     //   if(remoteRenderList[i].srcObject.active){
//     //     remoteRenderListFiltered.add(remoteRenderList[i]);
//     //   }
//     //   setState(() {
//     //     remoteRenderList.clear();
//     //     remoteRenderList.addAll(remoteRenderListFiltered);
//     //   });
//     // }
//
//     return Scaffold(body:  widget.body,);
//     return WillPopScope(
//       onWillPop: () async => false,
//       child: Scaffold(
//          // appBar: AppBar(title: Text(widget.appbart),),
//           // appBar: AppBar(title: Text(widget.ownID+"  "+widget.partnerid+"  "+widget.isCaller.toString()),),
//           backgroundColor: Colors.black,
//           body: screenView()),
//     );
//   }
//
//   void submitCallReceiverPush(bool isCaller, String partnerid,String room) {
//     if (isCaller != null && partnerid != null) {
//       if (true) {
//         Timer.periodic(Duration(milliseconds: 500), (timer) {
//           if (mounted) {
//             try {
//               widget.firestore
//                   .collection("incomming")
//                   .doc(partnerid)
//                   .update({"time": new DateTime.now().millisecondsSinceEpoch,"room":room});
//             } catch (e) {
//               widget.firestore
//                   .collection("incomming")
//                   .doc(partnerid)
//                   .set({"time": new DateTime.now().millisecondsSinceEpoch,"room":room});
//             }
//           } else
//             timer.cancel();
//         });
//       }
//     } else {
//       // Navigator.pop(context);
//     }
//   }
//
//   void submitCallReceiverPushReverse(bool isCaller, String partnerid,String room) {
//     if (isCaller != null && partnerid != null) {
//       if (true) {
//         Timer.periodic(Duration(milliseconds: 500), (timer) {
//           if (mounted) {
//             try {
//               widget.firestore
//                   .collection("incomming")
//                   .doc(partnerid)
//                   .set({"time": new DateTime.now().millisecondsSinceEpoch,"room":room});
//             } catch (e) {
//               widget.firestore
//                   .collection("incomming")
//                   .doc(partnerid)
//                   .update({"time": new DateTime.now().millisecondsSinceEpoch,"room":room});
//             }
//           } else
//             timer.cancel();
//         });
//       }
//     } else {
//       // Navigator.pop(context);
//     }
//   }
//
//   void submitCallEngaggePush(String ownID) {
//     Timer.periodic(Duration(milliseconds: 1000), (timer) {
//       if (mounted) {
//         try {
//           widget.firestore
//               .collection("incall")
//               .doc(ownID)
//               .set({"time": new DateTime.now().millisecondsSinceEpoch});
//         } catch (e) {
//           widget.firestore
//               .collection("incall")
//               .doc(ownID)
//               .update({"time": new DateTime.now().millisecondsSinceEpoch});
//         }
//       } else
//         timer.cancel();
//     });
//   }
//
//   void submitCallEngaggePushReverse(String ownID) {
//     Timer.periodic(Duration(milliseconds: 1000), (timer) {
//       if (mounted) {
//         try {
//           widget.firestore
//               .collection("incall")
//               .doc(ownID)
//               .update({"time": new DateTime.now().millisecondsSinceEpoch});
//         } catch (e) {
//           widget.firestore
//               .collection("incall")
//               .doc(ownID)
//               .set({"time": new DateTime.now().millisecondsSinceEpoch});
//         }
//       } else
//         timer.cancel();
//     });
//   }
//
//   void initWorkLoad(String roomId) {
//     initRenderers();
//     _createPeerConnection(roomId).then((pc) {
//       _peerConnection = pc;
//
//       if (widget.isCaller == true) {
//         _createOffer(roomId);
//       } else {
//         lookForOffer(roomId);
//       }
//
//       // ownOffer();
// /*
//       Future.delayed(Duration(seconds: 2), () {
//         for (int i = 0; i < 1; i ++) {
//           Future.delayed(Duration(seconds: 1 + (i)), () {
//             setState(() {
//               // widget.appbart = "going one round " + i.toString();
//             });
//             print("going one round");
//             if (widget.isCaller == true) {
//               setState(() {
//                 widget.callerID = widget.ownID;
//               });
//               try {
//                _createOffer(roomId);
//               } catch (e) {
//                 setState(() {
//                   // widget.appbart = "One exxecption from catch";
//                 });
//                 print("One exxecption from catch");
//                 print(e.toString());
//               }
//             } else {
//               setState(() {
//                 widget.callerID = widget.partnerid;
//               });
//             }
//           });
//         }
//       });
//       */
//     });
//   }
//
//   void lookForOffer(String roomId) async {
//     FirebaseFirestore.instance
//         .collection("rooms")
//         .doc(roomId)
//         .get()
//         .then((event) async {
//       if (event.exists && event.data()["offer"] != null) {
//         //mkl
//         setState(() {
//           widget.appbart = " offer fo";
//         });
//
//         print("remote des below");
//         print(event.data()["offer"]);
//
//         dynamic offer = event.data()["offer"];
//         setState(() {
//           widget.appbart = "gdr " + offer["type"];
//         });
//
//         RTCSessionDescription description =
//         new RTCSessionDescription(offer["sdp"], offer["type"]);
//
//         print("my suspect");
//         // print(description.toMap());
//         print("my suspect ends");
//
//         await _peerConnection.setRemoteDescription(description);
//         setState(() {
//           widget.appbart = "remote des added ";
//         });
//
//         setState(() {
//           widget.appbart = widget.appbart + " answering";
//         });
//         RTCSessionDescription descriptionLocal = await _peerConnection
//             .createAnswer({'offerToReceiveVideo': 1, 'offerToReceiveAudio': 1});
//         setState(() {
//           widget.appbart = widget.appbart + " anser done";
//         });
//         //var session = parse(description.sdp);
//         print("cerate off");
//         // print(json.encode(session));
//         _offer = false;
//
//         // print(json.encode({
//         //       'sdp': description.sdp.toString(),
//         //       'type': description.type.toString(),
//         //     }));
//         //FirebaseFirestore.instance.collection(widget.ownID).add(session);
//         // print("writing my own des");
//
//         await _peerConnection.setLocalDescription(descriptionLocal);
//         setState(() {
//           widget.appbart = " set ld done";
//         });
//         await FirebaseFirestore.instance
//             .collection("rooms")
//             .doc(roomId)
//             .update({
//           'roolId': roomId,
//           'answer': {
//             "type": descriptionLocal.type,
//             "sdp": descriptionLocal.sdp,
//           }
//         });
//
//         setState(() {
//           widget.hasCallOffered = true;
//         });
//
//         FirebaseFirestore.instance
//             .collection("rooms")
//             .doc(roomId)
//             .collection("callerCandidates")
//             .get()
//             .then((event) {
//           if (event.docs.length > 0) {
//             setState(() {
//               widget.appbart =
//                   " candidate side " + event.docs.length.toString() + " ";
//             });
//
//             for (int i = 0; i < event.docs.length; i++) {
//               dynamic candidate = new RTCIceCandidate(
//                 event.docs[i].data()["candidate"],
//                 event.docs[i].data()["sdpMid"],
//                 event.docs[i].data()["sdpMLineIndex"],
//               );
//               print("one candidate added");
//
//               // dynamic session = event.docs[i].data();
//
//               //dynamic candidate = new RTCIceCandidate(session['candidate'], session['sdpMid'], session['sdpMLineIndex']);
//               _peerConnection.addCandidate(candidate).then((value) {});
//             }
//           } else {
//             setState(() {
//               widget.appbart = widget.appbart + "  no candidate " + " ";
//             });
//           }
//         });
//       } else {
//         setState(() {
//           widget.appbart = widget.appbart + " no offer";
//         });
//       }
//     });
//
//     //FirebaseFirestore.instance.collection("queu").doc(widget.partnerPair).set({"room":room});
//   }
//
//   void MakeNewANswerNego(String roomId) async {
// /*
//     RTCSessionDescription descriptionLocal = await _peerConnection.createAnswer({'offerToReceiveVideo': 1, 'offerToReceiveAudio': 1});
//     await _peerConnection.setLocalDescription(descriptionLocal);
//     await FirebaseFirestore.instance.collection("rooms").doc(roomId).delete();
//
//     await FirebaseFirestore.instance
//         .collection("rooms")
//         .doc(roomId)
//         .set({
//       'roolId': roomId,
//       'answer': {
//         "type": descriptionLocal.type,
//         "sdp": descriptionLocal.sdp,
//       }
//     });
//     try{
//       FirebaseFirestore.instance
//           .collection("nego")
//           .doc(roomId)
//           .set({"time":DateTime.now().millisecondsSinceEpoch,"type":"a"}).then((value) {
//
//       });
//     }catch(e){
//       FirebaseFirestore.instance
//           .collection("nego")
//           .doc(roomId)
//           .update({"time":DateTime.now().millisecondsSinceEpoch,"type":"a"}).then((value) {
//
//       });
//     }
//     */
// if(true) {
//   FirebaseFirestore.instance
//       .collection("rooms")
//       .doc(roomId)
//       .get()
//       .then((event) async {
//     if (event.exists && event.data()["offer"] != null) {
//       //mkl
//       setState(() {
//         widget.appbart = " offer fo";
//       });
//
//       print("remote des below");
//       print(event.data()["offer"]);
//
//       dynamic offer = event.data()["offer"];
//       setState(() {
//         widget.appbart = "gdr " + offer["type"];
//       });
//
//       RTCSessionDescription description = new RTCSessionDescription(
//           offer["sdp"], offer["type"]);
//
//       print("my suspect");
//       // print(description.toMap());
//       print("my suspect ends");
//
//       await _peerConnection.setRemoteDescription(description);
//       setState(() {
//         widget.appbart = "remote des added ";
//       });
//
//       setState(() {
//         widget.appbart = widget.appbart + " answering";
//       });
//       RTCSessionDescription descriptionLocal = await _peerConnection.createAnswer({'offerToReceiveVideo': 1, 'offerToReceiveAudio': 1});
//       setState(() {
//         widget.appbart = widget.appbart + " anser done";
//       });
//       //var session = parse(description.sdp);
//       print("cerate off");
//       // print(json.encode(session));
//       _offer = false;
//
//       // print(json.encode({
//       //       'sdp': description.sdp.toString(),
//       //       'type': description.type.toString(),
//       //     }));
//       //FirebaseFirestore.instance.collection(widget.ownID).add(session);
//       // print("writing my own des");
//
//       await _peerConnection.setLocalDescription(descriptionLocal);
//       setState(() {
//         widget.appbart = " set ld done";
//       });
//
//       //  await FirebaseFirestore.instance.collection("rooms").doc(roomId).delete();
//       await FirebaseFirestore.instance
//           .collection("changes").add({
//         'roolId': roomId,
//         'answer': {
//           "type": descriptionLocal.type,
//           "sdp": descriptionLocal.sdp,
//         }
//       }).then((value) {
//         try {
//           FirebaseFirestore.instance
//               .collection("nego")
//               .doc(roomId)
//               .set({"id":value.id,"time": DateTime
//               .now()
//               .millisecondsSinceEpoch, "type": "a"}).then((value) {
//
//           });
//         } catch (e) {
//           FirebaseFirestore.instance
//               .collection("nego")
//               .doc(roomId)
//               .update({"id":value.id,"time": DateTime
//               .now()
//               .millisecondsSinceEpoch, "type": "a"}).then((value) {
//
//           });
//         }
//       });
//       // await FirebaseFirestore.instance
//       //     .collection("rooms")
//       //     .doc(roomId)
//       //     .update({
//       //   'roolId': roomId,
//       //   'answer': {
//       //     "type": descriptionLocal.type,
//       //     "sdp": descriptionLocal.sdp,
//       //   }
//       // });
//
//
//
//
//
//       setState(() {
//         widget.hasCallOffered = true;
//       });
//     } else {
//       setState(() {
//         widget.appbart = widget.appbart + " no offer";
//       });
//     }
//   });
// }
//
//
//     //FirebaseFirestore.instance.collection("queu").doc(widget.partnerPair).set({"room":room});
//   }
//   void MakeNewOfferNegoX(String roomId) async {
//
//     RTCSessionDescription descriptionLocalForOffer = await _peerConnection.createOffer({'offerToReceiveVideo': 1, 'offerToReceiveAudio': 1});
//     await _peerConnection.setLocalDescription(descriptionLocalForOffer);
//
//
//     await FirebaseFirestore.instance
//         .collection("changes").add({
//       'roolId': roomId,
//       'offer': {
//         "type": descriptionLocalForOffer.type,
//         "sdp": descriptionLocalForOffer.sdp,
//       }
//     }).then((value) {
//       try {
//         FirebaseFirestore.instance
//             .collection("nego")
//             .doc(roomId)
//             .set({"id":value.id,"time": DateTime
//             .now()
//             .millisecondsSinceEpoch, "type": "o"}).then((value) {
//
//         });
//       } catch (e) {
//         FirebaseFirestore.instance
//             .collection("nego")
//             .doc(roomId)
//             .update({"id":value.id,"time": DateTime
//             .now()
//             .millisecondsSinceEpoch, "type": "o"}).then((value) {
//
//         });
//       }
//     });
//
//
//
//
//     if(false) {
//       FirebaseFirestore.instance
//           .collection("rooms")
//           .doc(roomId)
//           .get()
//           .then((event) async {
//         if (event.exists && event.data()["answer"] != null) {
//           //mkl
//           setState(() {
//             widget.appbart = " offer fo";
//           });
//
//           print("remote des below");
//           print(event.data()["answer"]);
//
//           dynamic answer = event.data()["answer"];
//           setState(() {
//             widget.appbart = "gdr " + answer["type"];
//           });
//
//           RTCSessionDescription description = new RTCSessionDescription(answer["sdp"], answer["type"]);
//
//           print("my suspect");
//           // print(description.toMap());
//           print("my suspect ends");
//           RTCSessionDescription descriptionLocalForOffer = await _peerConnection.createOffer({'offerToReceiveVideo': 1, 'offerToReceiveAudio': 1});
//           await _peerConnection.setLocalDescription(descriptionLocalForOffer);
//
//           await _peerConnection.setRemoteDescription(description);//just
//           setState(() {
//             widget.appbart = "remote des added ";
//           });
//
//           setState(() {
//             widget.appbart = widget.appbart + " answering";
//           });
//           setState(() {
//             widget.appbart = widget.appbart + " anser done";
//           });
//           //var session = parse(description.sdp);
//           print("cerate off");
//           // print(json.encode(session));
//           _offer = false;
//
//           // print(json.encode({
//           //       'sdp': description.sdp.toString(),
//           //       'type': description.type.toString(),
//           //     }));
//           //FirebaseFirestore.instance.collection(widget.ownID).add(session);
//           // print("writing my own des");
//
//           setState(() {
//             widget.appbart = " set ld done";
//           });
//
//           //  await FirebaseFirestore.instance.collection("rooms").doc(roomId).delete();
//            FirebaseFirestore.instance
//               .collection("changes").add({
//             'roolId': roomId,
//             'offer': {
//               "type": descriptionLocalForOffer.type,
//               "sdp": descriptionLocalForOffer.sdp,
//             }
//           }).then((value) async{
//
//            // await  FirebaseFirestore.instance
//            //       .collection("changes").add({
//            //   'roolId': roomId,
//            //   'offer': {
//            //   "type": descriptionLocalForOffer.type,
//            //   "sdp": descriptionLocalForOffer.sdp,
//            //   }});
//
//
//
//             try {
//               FirebaseFirestore.instance
//                   .collection("nego")
//                   .doc(roomId)
//                   .set({"id":value.id,"time": DateTime
//                   .now()
//                   .millisecondsSinceEpoch, "type": "o"}).then((value) {
//
//               });
//             } catch (e) {
//               FirebaseFirestore.instance
//                   .collection("nego")
//                   .doc(roomId)
//                   .update({"id":value.id,"time": DateTime
//                   .now()
//                   .millisecondsSinceEpoch, "type": "o"}).then((value) {
//
//               });
//             }
//           });
//           // await FirebaseFirestore.instance
//           //     .collection("rooms")
//           //     .doc(roomId)
//           //     .update({
//           //   'roolId': roomId,
//           //   'answer': {
//           //     "type": descriptionLocal.type,
//           //     "sdp": descriptionLocal.sdp,
//           //   }
//           // });
//
//
//
//
//
//           setState(() {
//             widget.hasCallOffered = true;
//           });
//         } else {
//           setState(() {
//             widget.appbart = widget.appbart + " no offer";
//           });
//         }
//       });
//     }
//
//
//     //FirebaseFirestore.instance.collection("queu").doc(widget.partnerPair).set({"room":room});
//   }
//   void lookForOfferNego(String roomId, dynamic offer) async {
//     setState(() {
//       widget.appbart = "gdr " + offer["type"];
//     });
//
//     RTCSessionDescription description = new RTCSessionDescription(offer["sdp"], offer["type"]);
//
//     print("my suspect");
//     // print(description.toMap());
//     print("my suspect ends");
//
//     await _peerConnection.setRemoteDescription(description);
//
//     setState(() {
//       widget.appbart = widget.appbart + " answering";
//     });
//     RTCSessionDescription descriptionLocal = await _peerConnection.createAnswer({'offerToReceiveVideo': 1, 'offerToReceiveAudio': 1});
//
//     await _peerConnection.setLocalDescription(descriptionLocal);
//
//     await FirebaseFirestore.instance
//         .collection("changes").add({
//       'roolId': roomId,
//       'answer': {
//         "type": descriptionLocal.type,
//         "sdp": descriptionLocal.sdp,
//       }
//     }).then((value) {
//       try {
//         FirebaseFirestore.instance
//             .collection("nego")
//             .doc(roomId)
//             .set({"id":value.id,"time": DateTime
//             .now()
//             .millisecondsSinceEpoch, "type": "a"}).then((value) {
//
//         });
//       } catch (e) {
//         FirebaseFirestore.instance
//             .collection("nego")
//             .doc(roomId)
//             .update({"id":value.id,"time": DateTime
//             .now()
//             .millisecondsSinceEpoch, "type": "a"}).then((value) {
//
//         });
//       }
//     });
//
//     // print(json.encode({
//     //       'sdp': description.sdp.toString(),
//     //       'type': description.type.toString(),
//     //     }));
//     //FirebaseFirestore.instance.collection(widget.ownID).add(session);
//     // print("writing my own des");
//
//     // await _peerConnection.setLocalDescription(descriptionLocal);
//
//
//     setState(() {
//       widget.hasCallOffered = true;
//     });
//     setState(() {
//       widget.appbart = "reached finish";
//     });
//
//     //FirebaseFirestore.instance.collection("queu").doc(widget.partnerPair).set({"room":room});
//   }
//   void handelScreenShaing() async{
//     setState(() {
//       widget.isScreenSharing = !widget.isScreenSharing;
//     });
//     if(widget.isScreenSharing == true) {
//       final Map<String, dynamic> mediaConstraintsScreen = {
//         'audio': true,
//         'video': {
//           'width': {'ideal': 1980},
//           'height': {'ideal': 1280}
//         }
//       };
//       MediaStream newStream   = await navigator.mediaDevices.getDisplayMedia(mediaConstraintsScreen);
//       setState(() {
//         _localStreamScreenShare = newStream;
//         // widget.containsVideo = false ;
//
//         if(widget.isCameraShowing){
//           pc.removeStream(_localStreamVideo).then((value) {
//             setState(() {
//               _localRenderer.srcObject = null;
//             });
//           });
//           widget.isCameraShowing = false ;
//
//         }
//         pc.addStream(_localStreamScreenShare).then((value) {
//          setState(() {
//            _localRenderer.srcObject = _localStreamScreenShare;
//          });
//         });
//         widget.isScreenSharing = true ;
//       });
//
//
//     }else{
//       setState(() {
//         pc.removeStream(_localStreamScreenShare).then((value) {
//           setState(() {
//             _localRenderer.srcObject = null;
//           });
//         });
//         widget.isScreenSharing = false ;
//       });
//
//
//
//     }
//
//
//   }
//   void handleCameraToggle()async {
//
//     setState(() {
//       widget.containsVideo = !widget.containsVideo;
//     });
//     if(widget.isCameraShowing == false && widget.containsVideo == true && _localStreamVideo == null) {
//       final Map<String, dynamic> mediaConstraintsScreen = {
//         'audio': false,
//         'video': {
//           'width': {'ideal': 1280},
//           'height': {'ideal': 720}
//         }
//       };
//       MediaStream newStream = await navigator.mediaDevices.getUserMedia(mediaConstraintsScreen);
//       setState(() {
//         _localStreamVideo = newStream;
//         if(widget.isScreenSharing == true){
//           pc.removeStream(_localStreamScreenShare).then((value) {
//             widget.isScreenSharing = false;
//             setState(() {
//               _localRenderer.srcObject = null;
//             });
//
//           });
//
//         }
//
//         pc.addStream(_localStreamVideo).then((value) {
//           setState(() {
//             _localRenderer.srcObject = _localStreamVideo;
//           });
//
//         });
//         widget.isCameraShowing = true;
//       });
//
//
//     }else{
//
//       setState(() {
//
//         pc.removeStream(_localStreamVideo).then((value) {
//           setState(() {
//             _localRenderer.srcObject = null;
//           });
//
//         });
//         setState(() {
//           widget.isCameraShowing = false;
//           _localStreamVideo  = null;
//         });
//       });
//
//
//
//     }
//
//
//
//   }
//   void lookForAnsweerNego(String id,dynamic answer) async{
//
//     RTCSessionDescription descriptionl = await _peerConnection.createOffer({'offerToReceiveVideo': 1, 'offerToReceiveAudio': 1});
//
//     var session = parse(descriptionl.sdp);
//     print("cerate off");
//     print(json.encode(session));
//     _offer = true;
//
//     // print(json.encode({
//     //       'sdp': description.sdp.toString(),
//     //       'type': description.type.toString(),
//     //     }));
//     //FirebaseFirestore.instance.collection(widget.ownID).add(session);
//     // print("writing my own des");
//
//     await _peerConnection.setLocalDescription(descriptionl);
//     // await FirebaseFirestore.instance.collection("rooms").doc(room).set({
//     //   'roolId': room,
//     //   'offer': {
//     //     "type": description.type,
//     //     "sdp": description.sdp,
//     //   }
//     // });
//
//
//
//
//     dynamic ss = answer;
//     setState(() {
//       widget.appbart = "gdr " + ss["type"];
//     });
//     RTCSessionDescription description = new RTCSessionDescription(ss["sdp"], ss["type"]);
//
//     print("my suspect");
//     print(description.toMap());
//     print("my suspect ends");
//     setState(() {
//       widget.appbart = widget.appbart + ss["type"];
//     });
//      _peerConnection.setRemoteDescription(description);
//     setState(() {
//       widget.appbart = "reached fbinish ";
//     });
//
//
//
//
//   }
//   void lookForAnsweerNegoRev(String id,dynamic offer) async{
//
//     dynamic ss = offer;
//     setState(() {
//       widget.appbart = "gdr " + ss["type"];
//     });
//     RTCSessionDescription description = new RTCSessionDescription(ss["sdp"], ss["type"]);
//
//     print("my suspect");
//     print(description.toMap());
//     print("my suspect ends");
//     setState(() {
//       widget.appbart = widget.appbart + ss["type"];
//     });
//    // await  _peerConnection.setLocalDescription(null);
//     await  _peerConnection.setRemoteDescription(description);
//
//
//     RTCSessionDescription descriptionl = await _peerConnection.createOffer({'offerToReceiveVideo': 1, 'offerToReceiveAudio': 1});
//
//     var session = parse(descriptionl.sdp);
//     print("cerate off");
//     print(json.encode(session));
//     _offer = true;
//
//     // print(json.encode({
//     //       'sdp': description.sdp.toString(),
//     //       'type': description.type.toString(),
//     //     }));
//     //FirebaseFirestore.instance.collection(widget.ownID).add(session);
//     // print("writing my own des");
//
//     //await _peerConnection.setLocalDescription(descriptionl);
//     // await FirebaseFirestore.instance.collection("rooms").doc(room).set({
//     //   'roolId': room,
//     //   'offer': {
//     //     "type": description.type,
//     //     "sdp": description.sdp,
//     //   }
//     // });
//
//
//
//
//
//     setState(() {
//       widget.appbart = "reached fbinish ";
//     });
//
//
//
//
//   }
//   void reNego() {
//     if(widget.isCaller){
//       _createOfferNego(widget.room);
//     }else{
//       MakeNewANswerNego(widget.room);
//     }
//   }
//
//   void startGeneratingPeer() {
//
//
//
//
//
//
//
//
//
//
//
//
//     List ids = [widget.ownID, widget.partnerid];
//     ids.sort();
//
//     setState(() {
//       widget.partnerPair = ids.first + "-" + ids.last;
//     });
//
//     if (widget.partnerPair != null) {
//       if (widget.isCaller) {
//         submitCallEngaggePush(widget.ownID);
//         submitCallEngaggePushReverse(widget.ownID);
//         FirebaseFirestore.instance
//             .collection("rooms")
//             .add({"roomId": "sample"}).then((value) {
//           FirebaseFirestore.instance
//               .collection("rooms")
//               .doc(value.id)
//               .update({"roomId": value.id});
//           setState(() {
//             widget.appbart = value.id;
//             widget.room = value.id;
//
//           });
//
//           FirebaseFirestore.instance
//               .collection("nego")
//               .doc(value.id).snapshots().listen((event) {
//
//             // List<RTCVideoRenderer> filteredList = remoteRenderList;
//             //     for(int i = 0 ; i < remoteRenderList.length; i++){
//             //       if(remoteRenderList[i].)
//             //     }
//
//             if(event.data()["type"]=="a"){
//               FirebaseFirestore.instance.collection("changes").doc(event.data()["id"]).get().then((valueC) {
//                 lookForAnsweerNego(value.id,valueC.data()["answer"]);
//               });
//
//
//             }
//
//
//           });
//
//
//           initWorkLoad(value.id);
//         });
//       } else {
//
//
//         submitCallEngaggePush(widget.ownID);
//         submitCallEngaggePushReverse(widget.ownID);
//         FirebaseFirestore.instance
//             .collection("queu")
//             .doc(widget.partnerPair)
//             .get()
//             .then((value) {
//           if (value.exists &&
//               value.data() != null &&
//               value.data()["room"] != null) {
//
//             //nego
//
//
//             FirebaseFirestore.instance
//                 .collection("nego")
//                 .doc(value.data()["room"]).snapshots().listen((event) {
//
//               // List<RTCVideoRenderer> filteredList = remoteRenderList;
//               //     for(int i = 0 ; i < remoteRenderList.length; i++){
//               //       if(remoteRenderList[i].)
//               //     }
//
//               if(event.data()["type"]=="o") {
//                 FirebaseFirestore.instance.collection("changes").doc(event.data()["id"]).get().then((valueC) {
//                   lookForOfferNego(value.data()["room"],valueC.data()["offer"]);
//                   // lookForAnsweerNegoRev(value.data()["room"],valueC.data()["offer"]);
//                 });
//
//
//               }
//
//             });
//
//             setState(() {
//               widget.appbart = value.data()["room"];
//               widget.room = value.data()["room"];
//             });
//             initWorkLoad(value.data()["room"]);
//           }
//         });
//       }
//
//       widget.partnerid.replaceAll("dd", "d");
//       widget.partnerid.replaceAll("pp", "p");
//
//       widget.ownID.replaceAll("dd", "d");
//       widget.ownID.replaceAll("pp", "p");
//
//       if (widget.isCaller == true) {
//         setState(() {
//           widget.callerID = widget.ownID;
//         });
//       } else {
//         setState(() {
//           widget.callerID = widget.partnerid;
//         });
//       }
//
//       super.initState();
//
//       widget.partnerid.replaceAll("dd", "d");
//       widget.partnerid.replaceAll("pp", "p");
//
//       widget.ownID.replaceAll("dd", "d");
//       widget.ownID.replaceAll("pp", "p");
//
//       //listen for other party call reject status
//
//       if (widget.isCaller) {
//         if (widget.didOpositConnected) {
//           widget.firestore
//               .collection("incall")
//               .doc(widget.partnerid)
//               .get()
//               .then((value) {
//             if (value.exists) {
//               if ((value.data()["time"] + 5000) >
//                   DateTime.now().millisecondsSinceEpoch) {
//               } else {
//                 Navigator.pop(context);
//               }
//             } else {
//               Navigator.pop(context);
//             }
//           });
//         }
//       } else {
//         widget.firestore
//             .collection("incall")
//             .doc(widget.partnerid)
//             .get()
//             .then((value) {
//           if (value.exists) {
//             if ((value.data()["time"] + 5000) >
//                 DateTime.now().millisecondsSinceEpoch) {
//             } else {
//               Navigator.pop(context);
//             }
//           } else {
//             Navigator.pop(context);
//           }
//         });
//       }
//     } else {
//       Navigator.pop(context);
//     }
//
// /*
//     timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
//       if (widget.isCaller == true) {
//         widget.firestore
//             .collection("online")
//             .doc(widget.ownID)
//             .update({"calltime": new DateTime.now().millisecondsSinceEpoch});
//
//
//
//       } else {
//         widget.firestore
//             .collection("online")
//             .doc(widget.partnerid)
//             .update({"calltime": new DateTime.now().millisecondsSinceEpoch});
//       }
//     });
//
//  */
//
//   }
//
//   void createPeer(String id, String peerID) {
//
//     setState(() {
//       widget.allBody.add(Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Text(id,style: TextStyle(color: Colors.white),),
//       ));
//       widget.body = Column(
//         children: widget.allBody,
//       );
//     });
//   }
//
//
// }
//
// String makeRoomName(int one, int two) {
//   if (one > two)
//     return "" + one.toString() + "-" + two.toString();
//   else
//     return "" + two.toString() + "-" + one.toString();
// }
//
// class Login extends StatefulWidget {
//   String ownID, partnerid;
//
//   @override
//   _LoginState createState() => _LoginState();
// }
//
// class _LoginState extends State<Login> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Card(
//           color: Colors.white,
//           child: Container(
//             height: 250,
//             width: 300,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Container(
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: TextFormField(
//                       decoration: InputDecoration(
//                         hintText: "Your Name",
//                         contentPadding: EdgeInsets.all(10),
//                       ),
//                       onChanged: (value) {
//                         setState(() {
//                           widget.ownID = value;
//                         });
//                       },
//                     ),
//                   ),
//                 ),
//                 Container(
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: TextFormField(
//                       decoration: InputDecoration(
//                         hintText: "partner Name",
//                         contentPadding: EdgeInsets.all(10),
//                       ),
//                       onChanged: (value) {
//                         setState(() {
//                           widget.partnerid = value;
//                         });
//                       },
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: RaisedButton(
//                     onPressed: () {
//                       // FirebaseFirestore.instance
//                       //     .collection("refresh")
//                       //     .doc(widget.ownID)
//                       //     .delete();
//                       // FirebaseFirestore.instance
//                       //     .collection("refresh")
//                       //     .doc(widget.partnerid)
//                       //     .delete();
//                       // Navigator.push(
//                       //   context,
//                       //   MaterialPageRoute(builder: (context) => MyWebCall(widget.ownID,widget.partnerid)),
//                       // );
//                     },
//                     child: Text("Login"),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class MainHomePage extends StatefulWidget {
//   @override
//   _MainHomePageState createState() => _MainHomePageState();
// }
//
// class _MainHomePageState extends State<MainHomePage> {
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
