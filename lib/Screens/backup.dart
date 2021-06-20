import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show File, Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:maulajimessenger/Screens/chatThread.dart';
import 'package:maulajimessenger/Screens/logged_in_home.dart';
import 'package:maulajimessenger/Screens/user_sector.dart';

import 'package:maulajimessenger/services/Signal.dart';
import 'package:maulajimessenger/streams/buttonStreams.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sdp_transform/sdp_transform.dart';

// import 'package:flutter_webrtc/web/rtc_session_description.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

dynamic lastAnswer;

dynamic lastOffer;

Future<FirebaseApp> customInitialize() {
  return Firebase.initializeApp();
}

var ownCandidateID = null;

class SimpleWebCallb extends StatefulWidget {
  List streams = [];
  bool showAllFriends = false;

  dynamic ownCandidateID;
  String appbart = "";
  String appbart2 = "";
  String callDuration = "Connecting...";

  int callDurationSecond = 0;

  bool isAudioMuted = false;
  bool isScreenSharing = false;

  bool isVideoMuted = false;
  bool hasCountDownStartedOnce = false;

  bool hasCallOffered = false;

  String callerID = "0";

  String ownID = "0";
  String partnerid = "0";
  bool isCaller = false;
  bool isRecording = false;


  bool didOpositConnected = false;

  String partnerPair;

  String localStreamId;
  String shareScreenId;
  bool anyRemoteVideoStrem = false;
  String room;
  String ownName;
  String partnerName;
  String ownPhoto;
  FirebaseAuth auth;

  dynamic offer;
  String title = "t";

  bool containsVideo;
  bool isPartNerAudioMuted = false;
  bool isCameraShowing = false;
  String appbart3 = "";
  bool isRingTonePlaying = false;
  bool selfChat = false;
  IO.Socket socket;

  void Function() callback;
  void Function() callStartedNotify;
  void Function() callUserIsNoAvailable;

  chatWidgetUpdate(Widget wid) {
    print("widget founD ");
    WidgetReadyStream.getInstance().dataReload(wid);

    // setState(() {
    //   widget.chatBodyWidget = wid;
    // });
  }

  SimpleWebCallb(
      {this.partnerPair,
        this.ownID,
        this.partnerid,
        this.socket,
        this.isCaller,
        this.containsVideo,
        this.callback,
        this.callStartedNotify,
        this.callUserIsNoAvailable,
        this.ownName,
        this.partnerName,
        this.auth,this.ownPhoto});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<SimpleWebCallb>
    with WidgetsBindingObserver {
  //String get sdpSemantics => WebRTC.platformIsWindows ? 'plan-b' : 'unified-plan';
  String get sdpSemantics => kIsWeb ? "plan-b" : "unified-plan";
  Timer timer;
  bool _offer = false;
  RTCPeerConnection pc;
  MediaStream _localStream;
  MediaStream _localStreamVideo;
  MediaStream _localStreamScreenShare;

  MediaStream _localStreamForShare;
  MediaStream _primaryStreem;
  RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();
  RTCVideoRenderer _remoteRendererAudio = new RTCVideoRenderer();
  String remoteShowingStreamID;

  MediaRecorder _mediaRecorder;

  bool get _isRec => _mediaRecorder != null;
  final sdpController = TextEditingController();
  List<RTCVideoRenderer> remoteRenderList = [];
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
          await audioPlayer.setUrl("assets/assets/passive.mp3", isLocal: true);
          audioPlayer.play("assets/assets/passive.mp3",isLocal: true);
        } else {
          const kUrl1 = "assets/ring.mp3";
          final bytes = await  rootBundle.load('assets/passive.mp3');
          //final bytes = await rootBundle.load('assets/ring.mp3');
          final dir = await getApplicationDocumentsDirectory();
          final file = File('${dir.path}/passive.mp3');
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
  // playLocal() async {
  //   // audioPlayer.resume();
  //
  //   if (widget.isRingTonePlaying == false) {
  //     setState(() {
  //       widget.isRingTonePlaying = true;
  //     });
  //     audioPlayer.resume();
  //   }
  // }

  StopRing() async {
    // audioPlayer.resume();

    if (true) {
      audioPlayer.pause();
      setState(() {
        widget.isRingTonePlaying = false;
      });
    }
  }

  initAudio() async {
    audioPlayer = await AudioPlayer();
    if (kIsWeb) {
      await audioPlayer.setUrl("assets/assets/connecting.mp3", isLocal: true);
    } else {
      final byteData = await rootBundle.load('assets/connecting.mp3');

      final file = File('${(await getTemporaryDirectory()).path}/connecting.mp3');
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      //  audioPlayer.play(file.path,isLocal: true);
      audioPlayer.setUrl(file.path, isLocal: true);
    }

    // await audioPlayer.setUrl("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3");
  }

  @override
  dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _remoteRendererAudio.dispose();
    sdpController.dispose();
    timer?.cancel();
    pc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    initRenderers();
    initAudio();
    endCallListener();
    // socket = IO.io('http://localhost:3000');
    // socket.onConnect((_) {
    //   print('connect');
    //   socket.emit('msg', 'test');
    // });
    List ids = [widget.ownID, widget.partnerid];
    ids.sort();

    setState(() {
      widget.partnerPair = ids.first + "-" + ids.last;
    });

    try {
      if (widget.isCaller) {
        widget.socket.emit("calldial", {
          "partner": widget.partnerid,
          "callerName": widget.ownName,
          "callerId": widget.ownID,
          "photo":widget.ownPhoto,
          "time": DateTime.now().millisecondsSinceEpoch
        });

        // Timer.periodic(Duration(milliseconds: 500), (timer) {
        //   if (mounted) {
        //     if(widget.didOpositConnected == false){
        //       widget.socket.emit("calldial", {
        //         "partner": widget.partnerid,
        //         "callerName": "X",
        //         "callerId": widget.ownID,
        //         "time":DateTime.now().millisecondsSinceEpoch
        //       });
        //     }
        //
        //   }else{
        //     timer.cancel();
        //   }
        // });

        try {
          widget.socket.on("accept" + widget.partnerid, (data) {
            print("accepted on other side");

            workAsCaller();
          });
        } catch (e) {
          print(e.toString());
        }
        try {
          widget.socket.on("reject" + widget.partnerid, (data) {
            print("reject on other side");
            if (mounted) {
              StopRing();
              Navigator.pop(context);

              widget.callback();
            }
          });
        } catch (e) {
          print(e.toString());
        }

        try {
          widget.socket.on("ringing" + widget.partnerid, (data) {
            print("Ringing");
            if (mounted) {
              playLocal();
              setState(() {
                widget.callDuration = "Ringing";
              });
            }
          });
        } catch (e) {}
      } else {
        print("receiver here ");
        workNowasRec();
      }
    } catch (e) {}
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    await _remoteRendererAudio.initialize();
  }

  void _createOfferSignal() async {
    if (true) {
      try {
        RTCSessionDescription description = await pc
            .createOffer({'offerToReceiveVideo': 1, 'offerToReceiveAudio': 1});

        var session = parse(description.sdp);
        print("cerate off");
        print(json.encode(session));
        _offer = true;

        await pc.setLocalDescription(description);

        widget.socket.emit("offer", {
          "id": widget.partnerid,
          "offer": {
            "type": description.type,
            "sdp": description.sdp,
          }
        });

        widget.socket.on("answer" + widget.ownID, (data) async {
          dynamic ss = data;

          RTCSessionDescription description =
          new RTCSessionDescription(ss["sdp"], ss["type"]);
          await pc.setRemoteDescription(description);

          lastAnswer = data;
        });

        widget.socket.on("calleeCandidates" + widget.ownID,
                (data) async {
              dynamic candidate = new RTCIceCandidate(
                data["candidate"],
                data["sdpMid"],
                data["sdpMLineIndex"],
              );
              pc.addCandidate(candidate);

              if (widget.hasCountDownStartedOnce == false) {
                startCallStartedCount();
              }
            });
      } catch (e) {}
    }
    // print("writing my own des end of ");
  }

  Future<RTCPeerConnection> _createPeerConnectionSignal() async {
    print("going to create peer");
    // Map<String, dynamic> configuration = {
    //   "iceServers": [
    //     {"url": "stun:stun.l.google.com:19302"},
    //   ]
    // };

    Map<String, dynamic> configuration333 = {
      'iceServers': [
        {
          'url': 'stun:global.stun.twilio.com:3478?transport=udp',
          'urls': 'stun:global.stun.twilio.com:3478?transport=udp'
        },
        {
          'url': 'turn:global.turn.twilio.com:3478?transport=udp',
          'username':
          '3f926f4477b772f4a60860bdb437393c678caed6bda265137c9f25ccabe7d7f3',
          'urls': 'turn:global.turn.twilio.com:3478?transport=udp',
          'credential': 'C0yrr3LLqUn35Yo3VTyPGQn84q8mLAgQO0xfspErp4g='
        },
        {
          'url': 'turn:global.turn.twilio.com:3478?transport=tcp',
          'username':
          '3f926f4477b772f4a60860bdb437393c678caed6bda265137c9f25ccabe7d7f3',
          'urls': 'turn:global.turn.twilio.com:3478?transport=tcp',
          'credential': 'C0yrr3LLqUn35Yo3VTyPGQn84q8mLAgQO0xfspErp4g='
        },
        {
          'url': 'turn:global.turn.twilio.com:443?transport=tcp',
          'username':
          '3f926f4477b772f4a60860bdb437393c678caed6bda265137c9f25ccabe7d7f3',
          'urls': 'turn:global.turn.twilio.com:443?transport=tcp',
          'credential': 'C0yrr3LLqUn35Yo3VTyPGQn84q8mLAgQO0xfspErp4g='
        }
      ]
    };

    Map<String, dynamic> configuration = {
      'iceServers': [
        {'urls': 'stun:stun.nextcloud.com:443'},
        {'urls': 'stun:relay.webwormhole.io'},
        {'urls': 'stun:stun.services.mozilla.com'},
        {'urls': 'stun:stun.l.google.com:19302'},
        {
          'url': 'stun:global.stun.twilio.com:3478?transport=udp',
          'urls': 'stun:global.stun.twilio.com:3478?transport=udp'
        },
        {
          'urls': 'turn:86.11.136.36:3478',
          'credential': '%Welcome%4\$12345',
          'username': 'administrator'
        }
      ],
      //   "sdpSemantics": kIsWeb ? "plan-b" : "unified-plan"
      "sdpSemantics":sdpSemantics
    };
    Map<String, dynamic> configuration33 = {
      'iceServers': [
        {"url": "stun:stun.l.google.com:19302"},
        {
          'urls': 'turn:numb.viagenie.ca',
          'credential': '01620645499mkl',
          'username': 'saidur.shawon@gmail.com'
        }
      ]
    };
    Map<String, dynamic> configuration220 = {
      'iceServers': [
        {'urls': 'stun:stun.services.mozilla.com'},
        {'urls': 'stun:stun.l.google.com:19302'},
        {
          'urls': 'turn:numb.viagenie.ca',
          'credential': '01620645499mkl',
          'username': 'saidur.shawon@gmail.com'
        }
      ]
    };
    final Map<String, dynamic> offerSdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": true,
      },
      "optional": [],
    };

    _primaryStreem = await _getUserMedia();
    //   _localStreamScreenShare = await _getUserMedia();

//widget.containsVideo == false
//     if( widget.containsVideo == false){
//       for(int i = 0 ; i <_localStream.getVideoTracks().length ; i ++){
//         //_localStream.getVideoTracks()[i].(widget.isCameraOn);
//         _localStream.getVideoTracks()[i].enabled = !(_localStream.getVideoTracks()[i].enabled);
//       }
//       setState(() {
//         widget.isVideoMuted =  ! widget.isVideoMuted;
//       });
//     }

    pc = await createPeerConnection(configuration, offerSdpConstraints);

    pc.onRenegotiationNeeded = () {
      if (widget.didOpositConnected) {
        print("renego called");
        setState(() {
          widget.appbart3 = "nego";
        });

        if (widget.isCaller) {
          // _createOfferNego(roomID);
          MakeNewOfferNegoX();
        } else {
          MakeNewANswerNego();
        }

        setState(() {
          // widget.appbart = "renegotionation";
        });
      }
    };

    if (pc != null) {
      print(pc);
      print("not null");
    } else {
      print("null");
    }
    if (kIsWeb) {
      // running on the web!

      final Map<String, dynamic> mediaConstraintsScreen = {
        'audio': true,
        'video': {
          'width': {'ideal': 1280},
          'height': {'ideal': 720}
        }
      };
      // MediaStream streamScreenShare = await navigator.mediaDevices.getDisplayMedia(mediaConstraintsScreen);
      //await pc.addStream(streamScreenShare);

      await pc.addStream(_primaryStreem);

      //  await  pc.addStream(_localStreamScreenShare);
      // await  pc.addStream(_localStream.);

    } else {
      _primaryStreem.getTracks().forEach((track) {
        pc.addTrack(track, _primaryStreem);
      });
    }

    pc.onRemoveStream = (e) async {
      // setState(() {
      //   _remoteRenderer.srcObject = _remoteRendererAudio.srcObject;
      // });

      setState(() {
        widget.anyRemoteVideoStrem = false;
      });

      // setState(() {
      //   widget.anyRemoteVideoStrem = false;
      //
      //   List filtredStream = [] ;
      //   //filtredStream.addAll(widget.streams);
      //   for(int i = 0 ; i < widget.streams.length ; i++){
      //     if( widget.streams[i]["id"] != e.id){
      //       filtredStream.add(widget.streams[i]);
      //     }
      //     widget.streams.clear();
      //     widget.streams.addAll(filtredStream);
      //   }
      //
      // });
      //
      //
      // setState(() {
      //   remoteRenderList.clear();
      // });
      //
      // for(int i = 0 ; i < widget.streams.length ; i++){
      //   RTCVideoRenderer  _re = new RTCVideoRenderer();
      //   await _re.initialize();
      //   _re.srcObject = widget.streams[i]["stream"];
      //   setState(() {
      //     remoteRenderList.add(_re);
      //
      //   });
      // }
      // setState(() {
      //   _remoteRenderer =remoteRenderList.last;
      // });
    };

    pc.onIceCandidate = (e) {
      setState(() {
        //  widget.appbart = e.toString();
      });
      if (e.candidate != null) {
        print("supecrt 7");

        dynamic data = ({
          'candidate': e.candidate.toString(),
          'sdpMid': e.sdpMid.toString(),
          'sdpMLineIndex': e.sdpMlineIndex,
        });
        print(data);
        if (ownCandidateID == null) {
          ownCandidateID = data;
        }
        // FirebaseFirestore.instance
        //     .collection("rooms")
        //     .doc(roomID)
        //     .collection(
        //     widget.isCaller ? "callerCandidates" : "calleeCandidates")
        //     .add(data);

        widget.socket.emit(
            widget.isCaller ? "callerCandidates" : "calleeCandidates",
            {"id": widget.partnerid, "cand": data});

        print("supecrt 7 end");
      }
    };
    pc.onSignalingState = (e) {
      setState(() {
        widget.appbart2 = pc.iceConnectionState.toString();
      });
      if (pc.iceConnectionState ==
          RTCIceConnectionState.RTCIceConnectionStateConnected) {
        widget.callStartedNotify();
        print("call conncted");

        if (mounted) StopRing();
        setState(() {
          widget.didOpositConnected = true;
          //  widget.appbart = "connected";
        });
      }
      //
      // if (widget.didOpositConnected = true) {
      //   if (pc.iceConnectionState ==
      //       RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
      //     pc.close().then((value) {
      //       pc.dispose().then((value) {
      //         Navigator.pop(context);
      //       });
      //     });
      //   }
      // }

      if (pc.iceConnectionState == 'disconnected') {}
    };
    pc.onAddStream = (stream) async {
      print("new stream mkl" + stream.id);


    };

    switch (sdpSemantics) {
      case 'plan-b':
        pc.onAddStream = (stream) async {
          // if(stream.getVideoTracks().length>0){
          //   setState(() {
          //     _remoteRenderer.srcObject = stream;
          //     widget.anyRemoteVideoStrem = true;
          //     remoteShowingStreamID = stream.id;
          //     _remoteRenderer.srcObject = stream;
          //   });
          //
          // }else{
          //   _remoteRendererAudio.srcObject = stream;
          // }

          if (_remoteRendererAudio.srcObject == null) {
            setState(() {
              _remoteRendererAudio.srcObject = stream;
            });
          } else
            setState(() {
              widget.anyRemoteVideoStrem = true;
              _remoteRenderer.srcObject = stream;
            });

        };
        break;
      case 'unified-plan':
        pc.onTrack = (event) {

          // if (event.track.kind == 'video' && event.streams.isNotEmpty) {
          //   print('New stream: ' + event.streams[0].id);
          //   _remoteRenderer.srcObject = event.streams[0];
          // }



//event.track.kind == 'video' && event.streams.isNotEmpty
          if (true ) {
            _remoteRenderer.srcObject = event.streams.first;
            event.streams.first.getTracks().forEach((track) {
              if (_remoteRendererAudio.srcObject == null) {
                setState(() {
                  _remoteRendererAudio.srcObject = event.streams.first;
                });
              } else
                setState(() {
                  widget.anyRemoteVideoStrem = true;
                  _remoteRenderer.srcObject = event.streams.first;
                });
            });
          }
        };
        break;
    }


    if (false) {
      if (kIsWeb) {
        // running on the web!
        pc.onAddStream = (stream) async {
          // if(stream.getVideoTracks().length>0){
          //   setState(() {
          //     _remoteRenderer.srcObject = stream;
          //     widget.anyRemoteVideoStrem = true;
          //     remoteShowingStreamID = stream.id;
          //     _remoteRenderer.srcObject = stream;
          //   });
          //
          // }else{
          //   _remoteRendererAudio.srcObject = stream;
          // }

          if (_remoteRendererAudio.srcObject == null) {
            setState(() {
              _remoteRendererAudio.srcObject = stream;
            });
          } else
            setState(() {
              widget.anyRemoteVideoStrem = true;
              _remoteRenderer.srcObject = stream;
            });

          //
          //
          // setState(() {
          //   widget.streams.add({"id":stream.id,"stream":stream});
          //   // widget.appbart = pc.getRemoteStreams().length.toString()+" "+ pc.getLocalStreams().length.toString()+" "+ pc.getRemoteStreams().first.getVideoTracks().toString()+" "+ pc.getLocalStreams().first.getVideoTracks().toString();
          //   // widget.appbart =widget.streams.length.toString();
          // });
          //
          // setState(() {
          //   // _remoteRenderer.srcObject = widget.streams.last["stream"];
          //
          //   remoteRenderList.clear();
          //   // widget.streams.clear();
          // });
          //
          // for(int i = 0 ; i < widget.streams.length ; i++){
          //   RTCVideoRenderer  _re = new RTCVideoRenderer();
          //   await _re.initialize();
          //
          //   setState(() {
          //
          //     _re.srcObject = widget.streams[i]["stream"];
          //     remoteRenderList.add(_re);
          //
          //   });
          // }
          // setState(() {
          //   _remoteRenderer =remoteRenderList.last;
          // });
        };
      } else {


        pc.onTrack = (event) {

          // if (event.track.kind == 'video' && event.streams.isNotEmpty) {
          //   print('New stream: ' + event.streams[0].id);
          //   _remoteRenderer.srcObject = event.streams[0];
          // }



//event.track.kind == 'video' && event.streams.isNotEmpty
          if (true ) {
            _remoteRenderer.srcObject = event.streams.first;
            event.streams.first.getTracks().forEach((track) {
              if (_remoteRendererAudio.srcObject == null) {
                setState(() {
                  _remoteRendererAudio.srcObject = event.streams.first;
                });
              } else
                setState(() {
                  widget.anyRemoteVideoStrem = true;
                  _remoteRenderer.srcObject = event.streams.first;
                });
            });
          }
        };
      }
    }

    // ownOffer(pc);

    //
    return pc;
  }

  void _startRecording() async {
    // customStream.addTrack(_localStream.);

    // for(int i = 0 ; i < _localStream.getTracks() .length ; i ++){
    //   customStream.addTrack(_localStream.getTracks()[i]);
    // }

    // for(int i = 0 ; i < _remoteRenderer.srcObject.getTracks() .length ; i ++){
    //   customStream.addTrack(_remoteRenderer.srcObject.getTracks()[i]);
    // }

    _mediaRecorder = MediaRecorder();
    setState(() {
      widget.isRecording = true;
    });

    _mediaRecorder.startWeb(_remoteRenderer.srcObject);
  }

  void _stopRecording() async {
    // final objectUrl = await _mediaRecorder?.stop();
    // setState(() {
    //   _mediaRecorder = null;
    //   widget.isRecording = false;
    // });
    // print(objectUrl);
    // html.window.open(objectUrl, '_blank');
    // downloadFile(objectUrl);
  }

  void downloadFile(String url) {
    // html.AnchorElement anchorElement = new html.AnchorElement(href: url);
    // anchorElement.download = url;
    // anchorElement.click();
  }

  _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': false
    };

    MediaStream stream =
    await navigator.mediaDevices.getUserMedia(mediaConstraints);
    //MediaStream streamScreenShare = await navigator.mediaDevices.getDisplayMedia(mediaConstraintsScreen);
    // MediaStream stream   = await navigator.mediaDevices.getDisplayMedia(mediaConstraints);

    // _localStream = stream;

    //_localRenderer.srcObject = stream;
    // _localRenderer.mirror = true;

    //  RTCVideoRenderer  _re = new RTCVideoRenderer();
    // await _re.initialize();
    //// _re.srcObject = stream;
    setState(() {
      // remoteRenderList.add(_re);
    });

    // pc.addStream(stream);

    return stream;
  }

  SizedBox videoRenderers() => SizedBox(
      height: 500,
      child: Row(children: [
        Flexible(
          child: new Container(
              key: new Key("local"),
              margin: new EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
              decoration: new BoxDecoration(color: Colors.black),
              child: new RTCVideoView(_localRenderer)),
        ),
        Flexible(
          child: new Container(
              key: new Key("remote"),
              margin: new EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
              decoration: new BoxDecoration(color: Colors.black),
              child: new RTCVideoView(_remoteRenderer)),
        )
      ]));

  Widget screenView() {
    return Center(
      child: Container(
        color: Color.fromARGB(255, 23, 32, 42),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Align(
                alignment: Alignment.center,
                child: new RTCVideoView(
                  _remoteRendererAudio,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                )),
            Align(
                alignment: Alignment.bottomCenter,
                child: widget.anyRemoteVideoStrem == true
                    ? new RTCVideoView(
                  _remoteRenderer,
                  objectFit:
                  RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                )
                    : Center(
                  child: Text(
                    widget.partnerName,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 50),
                  ),
                )),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black,
                width: MediaQuery.of(context).size.width,
                height: 100,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Center(
                        child: Container(
                          height: 100,
                          child: Center(
                            child: Wrap(
                              children: [
                                // Padding(
                                //   padding: const EdgeInsets.all(8.0),
                                //   child: FloatingActionButton(
                                //
                                //     onPressed: () {
                                //       if (widget.isCaller == true) {
                                //         setState(() {
                                //           widget.callerID = widget.ownID;
                                //         });
                                //         try {
                                //           _createOffer();
                                //         } catch (e) {
                                //           setState(() {
                                //             widget.appbart = "One exxecption from catch";
                                //           });
                                //           print("One exxecption from catch");
                                //           print(e.toString());
                                //         }
                                //       } else {
                                //         setState(() {
                                //           widget.callerID = widget.partnerid;
                                //         });
                                //       }
                                //     },
                                //     child: Icon(Icons.audiotrack_outlined),
                                //   ),
                                // ),
                                kIsWeb
                                    ? Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: FloatingActionButton(
                                    heroTag: "5",
                                    onPressed: handelScreenShaing,

                                    //  color: Colors.white,
                                    backgroundColor: Colors.redAccent,

                                    child: Icon(
                                      !widget.isScreenSharing
                                          ? Icons.stop_screen_share
                                          : Icons.screen_share,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                                    : Container(
                                  height: 0,
                                  width: 0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: FloatingActionButton(
                                    heroTag: "4",
                                    onPressed: (){
                                      for (int i = 0;
                                      i < _remoteRendererAudio.srcObject.getAudioTracks().length; i++) {
                                        //_localStream.getVideoTracks()[i].(widget.isCameraOn);
                                        _remoteRendererAudio.srcObject.getAudioTracks()[i].enabled =
                                        !(_remoteRendererAudio.srcObject.getAudioTracks()[i].enabled);
                                      }
                                      setState(() {
                                        widget.isPartNerAudioMuted = !widget.isPartNerAudioMuted;
                                      });
                                    },
                                    backgroundColor: Colors.redAccent,
                                    child: Icon(
                                      widget.isPartNerAudioMuted
                                          ? Icons.volume_off
                                          : Icons.volume_up_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: FloatingActionButton(
                                    heroTag: "3",
                                    onPressed: (){
                                      for (int i = 0;
                                      i < _primaryStreem.getAudioTracks().length;
                                      i++) {
                                        //_localStream.getVideoTracks()[i].(widget.isCameraOn);
                                        _primaryStreem.getAudioTracks()[i].enabled =
                                        !(_primaryStreem
                                            .getAudioTracks()[i]
                                            .enabled);
                                      }
                                      setState(() {
                                        widget.isAudioMuted = !widget.isAudioMuted;
                                      });
                                    },
                                    backgroundColor: Colors.redAccent,
                                    child: Icon(
                                      widget.isAudioMuted
                                          ? Icons.mic_off_rounded
                                          : Icons.mic_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: FloatingActionButton(
                                    heroTag: "2",
                                    onPressed: handleCameraToggle,
                                    backgroundColor: Colors.redAccent,
                                    child: Icon(
                                      !widget.containsVideo
                                          ? Icons.videocam_off_outlined
                                          : Icons.videocam,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: FloatingActionButton(
                                    heroTag: "1",
                                    onPressed: () {
                                      StopRing();
                                      endCall();
                                      try {
                                        pc.close().then((value) async {
                                          pc.dispose().then((value) async {
                                            if (mounted) {
                                              widget.callback();
                                              Navigator.pop(context);
                                            }

                                            //dispose();
                                          });
                                        });
                                      } catch (e) {
                                        widget.callback();
                                        Navigator.pop(context);
                                      }
                                    },
                                    backgroundColor: Colors.redAccent,
                                    child: Icon(
                                      Icons.call_end,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.all(8.0),
                                //   child: FloatingActionButton(
                                //     backgroundColor: widget.isCaller
                                //         ? Colors.redAccent
                                //         : Colors.greenAccent,
                                //     onPressed: () {
                                //       // _startRecording();
                                //       widget.isRecording == true
                                //           ? _stopRecording()
                                //           : _startRecording();
                                //     },
                                //     child: Icon(widget.isRecording == true
                                //         ? Icons.fiber_manual_record_rounded
                                //         : Icons.fiber_manual_record_outlined),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    MediaQuery.of(context).size.width>1000?    Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        children: [
                          InkWell(onTap: (){
                            setState(() {
                              widget. selfChat = !widget. selfChat;
                            });

                            Future.delayed(Duration(seconds: 1), () {
                              widget.socket.emit("getMesage", {"fileName": widget.room});
                            });

                          },
                            child: Padding(
                              padding:EdgeInsets.fromLTRB(8, 8, 20, 8),
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle, color:widget.selfChat? Colors.white:Colors.black),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                                  child: Icon(Icons.chat,color:widget.selfChat? Colors.black:Colors.white),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ):Container(
                      height: 0,
                      width: 0,
                    ),
                  ],
                ),
              ),
            ),
            _localRenderer.srcObject != null
                ? Positioned(
              right: 5,
              top: 5,
              child: Container(
                height: 100,
                width: 100,
                child: Container(
                    key: new Key("local"),
                    margin: new EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                    decoration: new BoxDecoration(color: Colors.black),
                    child: new RTCVideoView(
                      _localRenderer,
                      objectFit: RTCVideoViewObjectFit
                          .RTCVideoViewObjectFitCover,
                    )),
              ),
            )
                : Container(
              width: 0,
              height: 0,
            ),
            Align(
                alignment: Alignment.topLeft,
                child: Container(
                  height: 106,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: remoteRenderList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Container(
                            width: 100,
                            height: 100,
                            child: false
                                ? Center(
                              child: Icon(
                                Icons.volume_up_rounded,
                                color: Colors.redAccent,
                              ),
                            )
                                : new RTCVideoView(
                              remoteRenderList[index],
                              objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitCover,
                            ),
                            // child: new RTCVideoView( remoteRenderList[index],),//remoteRenderList[index].srcObject.getVideoTracks().length== 0
                          ),
                        ),
                      );
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Padding sdpCandidatesTF() => Padding(
    padding: const EdgeInsets.all(16.0),
    child: TextField(
      controller: sdpController,
      keyboardType: TextInputType.multiline,
      maxLines: 4,
      maxLength: TextField.noMaxLength,
    ),
  );

  @override
  Widget build(BuildContext context) {
    // return Scaffold(body: Text(widget.ownID+"  "+widget.partnerid+"  "+widget.isCaller.toString()),);
    // List<RTCVideoRenderer> remoteRenderListFiltered = [];
    // for(int i =  0 ; i < remoteRenderList.length; i++){
    //   if(remoteRenderList[i].srcObject.active){
    //     remoteRenderListFiltered.add(remoteRenderList[i]);
    //   }
    //   setState(() {
    //     remoteRenderList.clear();
    //     remoteRenderList.addAll(remoteRenderListFiltered);
    //   });
    // }
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        //appBar: AppBar(title: Text(widget.appbart3),),
        // appBar: AppBar(title: Text(widget.ownID+"  "+widget.partnerid+"  "+widget.isCaller.toString()),),
          backgroundColor: Colors.black,
          body: Row(
            children: [
              widget.showAllFriends
                  ? Container(
                color: Colors.white,
                width: 350,
                height: MediaQuery.of(context).size.height,
                child: SectorOne(

                  auth: FirebaseAuth.instance,
                  chatWidgetUpdate: widget.chatWidgetUpdate,
                ),
              )
                  : Container(
                height: 0,
                width: 0,
              ),
              Container(
                width: widget.showAllFriends && widget.selfChat
                    ? MediaQuery.of(context).size.width - 700
                    :((widget.showAllFriends || widget.selfChat? MediaQuery.of(context).size.width - 450:(MediaQuery.of(context).size.width))),
                color: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ListTile(
                      leading: InkWell(
                          onTap: () {
                            // setState(() {
                            //   widget.showAllFriends = !widget.showAllFriends;
                            // });
                          },
                          child: Icon(
                            Icons.menu,
                            color: Colors.white,
                          )),
                      title: Text(
                        widget.partnerName,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        widget.callDuration,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Container(
                        height: MediaQuery.of(context).size.height - 64,
                        width: widget.showAllFriends
                            ? MediaQuery.of(context).size.width - 350
                            : MediaQuery.of(context).size.width,
                        child: screenView()),
                  ],

                ),
              ),
              widget.selfChat?Container(width: 450,child: SingleChatThread(socket: widget.socket,showMobileView: false,whileCall: true,
                //homeWidget: widget,
                chatBody: {
                  "uid": widget.partnerid
                },
                auth: FirebaseAuth.instance,

                //call: call,
              ),): Container(
                height: 0,
                width: 0,
              )
            ],
          )),
    );
  }





  void lookForOfferSignal() async {
    print("looking for offer");

    try {
      widget.socket.on("offer" + widget.ownID, (data) async {
        print(data);

        dynamic ss = data;
        lastOffer = data;
        print("found offer");
        RTCSessionDescription description =
        new RTCSessionDescription(ss["sdp"], ss["type"]);
        await pc.setRemoteDescription(description);
        RTCSessionDescription descriptionLocal = await pc
            .createAnswer({'offerToReceiveVideo': 1, 'offerToReceiveAudio': 1});
        await pc.setLocalDescription(descriptionLocal);
        widget.socket.emit("answer", {
          "id": widget.partnerid,
          "answer": {
            "type": descriptionLocal.type,
            "sdp": descriptionLocal.sdp,
          }
        });
        //callerCandidates
        try {
          widget.socket.on("callerCandidates" + widget.ownID,
                  (data) async {
                dynamic candidate = new RTCIceCandidate(
                  data["candidate"],
                  data["sdpMid"],
                  data["sdpMLineIndex"],
                );
                pc.addCandidate(candidate);
                if (widget.hasCountDownStartedOnce == false) {
                  startCallStartedCount();
                }
              });
        } catch (e) {}
      });
    } catch (e) {}

    //FirebaseFirestore.instance.collection("queu").doc(widget.partnerPair).set({"room":room});
  }


  void MakeNewANswerNego() async {
    print("receiver tries to renego");

    await pc.setRemoteDescription(
        RTCSessionDescription(lastOffer["sdp"], lastOffer["type"]));
    RTCSessionDescription descriptionLocal = await pc
        .createAnswer({'offerToReceiveVideo': 1, 'offerToReceiveAudio': 1});
    try {
      // await pc.setLocalDescription(descriptionLocal);
    } catch (e) {
      print("here is an exceptions");
      print(e.toString());
    }
    widget.socket.emit("answerNeedOffer", {
      "id": widget.partnerid,
      "answer": {
        "type": descriptionLocal.type,
        "sdp": descriptionLocal.sdp,
      }
    });

    // widget.socket.on("offerNasResponse" + widget.ownID,
    //         (data) async {
    //       print(data);
    //
    //       dynamic ss = data;
    //       print("found offer");
    //       RTCSessionDescription description =
    //       new RTCSessionDescription(ss["sdp"], ss["type"]);
    //       await pc.setRemoteDescription(description);
    //     });
  }

  void MakeNewOfferNegoX() async {
    print("caller tries to renego");
    RTCSessionDescription description = await pc
        .createOffer({'offerToReceiveVideo': 1, 'offerToReceiveAudio': 1});
    await pc.setLocalDescription(description);

    widget.socket.emit("offerNneedAnswer", {
      "id": widget.partnerid,
      "offer": {
        "type": description.type,
        "sdp": description.sdp,
      }
    });

    // try {
    //   widget.socket.on("answerNasResponse" + widget.ownID,
    //           (data) async {
    //         dynamic ss = data;
    //
    //         RTCSessionDescription description =
    //         new RTCSessionDescription(ss["sdp"], ss["type"]);
    //         try {
    //           //  await pc.setRemoteDescription(description);
    //         } catch (e) {
    //           print("own excepriom");
    //           print(e.toString());
    //         }
    //       });
    // } catch (e) {}
  }

  void handelScreenShaing() async {
    setState(() {
      widget.isScreenSharing = !widget.isScreenSharing;
    });
    if (widget.isScreenSharing == true) {
      final Map<String, dynamic> mediaConstraintsScreen = {
        'audio': true,
        'video': {
          'width': {'ideal': 1980},
          'height': {'ideal': 1280}
        }
      };
      MediaStream newStream =
      await navigator.mediaDevices.getDisplayMedia(mediaConstraintsScreen);
      setState(() {
        _localStreamScreenShare = newStream;
        // widget.containsVideo = false ;

        if (widget.isCameraShowing) {
          pc.removeStream(_localStreamVideo).then((value) {
            setState(() {
              _localRenderer.srcObject = null;
            });
          });
          widget.isCameraShowing = false;
        }

        if (kIsWeb) {
          pc.addStream(_localStreamScreenShare).then((value) {
            setState(() {
              _localRenderer.srcObject = _localStreamScreenShare;
            });
          });
        } else {
          _localStreamScreenShare.getTracks().forEach((track) {
            pc.addTrack(track, _localStreamScreenShare);
          });
        }


        widget.isScreenSharing = true;
      });
    } else {
      setState(() {
        pc.removeStream(_localStreamScreenShare).then((value) {
          setState(() {
            _localRenderer.srcObject = null;
          });
        });
        widget.isScreenSharing = false;
      });
    }
  }

  void handleCameraToggle() async {

    setState(() {
      widget.  containsVideo = false ;
      widget.containsVideo = !widget.containsVideo;
    });
    //   widget.isCameraShowing == false && widget.containsVideo == false && _localStreamVideo == null
    if ( widget. containsVideo == true) {
      print("tyring to add camera feed");
      final Map<String, dynamic> mediaConstraintsScreen = {
        'audio': false,
        'video': {
          'mandatory': {
            'minWidth':
            '640', // Provide your own width, height and frame rate here
            'minHeight': '480',
            'minFrameRate': '15',
          },
          'facingMode': 'user',
          'optional': [],
        }
      };
      MediaStream newStream = await navigator.mediaDevices.getUserMedia(mediaConstraintsScreen);
      setState(() {
        _localStreamVideo = newStream;
        if (widget.isScreenSharing == true) {
          pc.removeStream(_localStreamScreenShare).then((value) {
            widget.isScreenSharing = false;
            setState(() {
              _localRenderer.srcObject = null;
            });
          });
        }
        void _onTrack(RTCTrackEvent event) {
          print('onTrack');

        }
        switch (sdpSemantics) {
          case 'plan-b':
            pc.addStream(newStream);
            break;
          case 'unified-plan':
            pc.onTrack = _onTrack;
            newStream.getTracks().forEach((track) {
              pc.addTrack(track, newStream);
            });
            break;
        }



/*
          if (kIsWeb) {
            pc.addStream(_localStreamVideo).then((value) {
              setState(() {
                _localRenderer.srcObject = _localStreamVideo;
              });
            });
          } else {
            _localStreamVideo.getTracks().forEach((track) {
              pc.addTrack(track, _localStreamVideo);
            });
          }

 */



        widget.isCameraShowing = true;
      });
    } else {
      print("tyring to remove camera feed");
      if (false) {
        setState(() {
          pc.removeStream(_localStreamVideo).then((value) {
            setState(() {
              _localRenderer.srcObject = null;
            });
          });
          setState(() {
            widget.isCameraShowing = false;
            _localStreamVideo = null;
          });
        });
      } else {
        setState(() {
          widget.isCameraShowing = false;
          _localStreamVideo = null;
        });

        if(_localStreamVideo!=null && _localStreamVideo.getTracks()!=null && _localStreamVideo.getTracks().length>0){
          _localStreamVideo.getTracks().forEach((track) {
            track.stop();
          });

        }


      }
    }
  }

  void lookForAnsweerNego(String id, dynamic answer) async {
    RTCSessionDescription descriptionl = await pc
        .createOffer({'offerToReceiveVideo': 1, 'offerToReceiveAudio': 1});

    var session = parse(descriptionl.sdp);
    print("cerate off");
    print(json.encode(session));
    _offer = true;

    // print(json.encode({
    //       'sdp': description.sdp.toString(),
    //       'type': description.type.toString(),
    //     }));
    //FirebaseFirestore.instance.collection(widget.ownID).add(session);
    // print("writing my own des");

    await pc.setLocalDescription(descriptionl);
    // await FirebaseFirestore.instance.collection("rooms").doc(room).set({
    //   'roolId': room,
    //   'offer': {
    //     "type": description.type,
    //     "sdp": description.sdp,
    //   }
    // });

    dynamic ss = answer;
    setState(() {
      widget.appbart = "gdr " + ss["type"];
    });
    RTCSessionDescription description =
    new RTCSessionDescription(ss["sdp"], ss["type"]);

    print("my suspect");
    print(description.toMap());
    print("my suspect ends");
    setState(() {
      widget.appbart = widget.appbart + ss["type"];
    });
    pc.setRemoteDescription(description);
    setState(() {
      widget.appbart = "reached fbinish ";
    });
  }

  void lookForAnsweerNegoRev(String id, dynamic offer) async {
    dynamic ss = offer;
    setState(() {
      widget.appbart = "gdr " + ss["type"];
    });
    RTCSessionDescription description =
    new RTCSessionDescription(ss["sdp"], ss["type"]);

    print("my suspect");
    print(description.toMap());
    print("my suspect ends");
    setState(() {
      widget.appbart = widget.appbart + ss["type"];
    });
    // await  pc.setLocalDescription(null);
    await pc.setRemoteDescription(description);

    RTCSessionDescription descriptionl = await pc
        .createOffer({'offerToReceiveVideo': 1, 'offerToReceiveAudio': 1});

    var session = parse(descriptionl.sdp);
    print("cerate off");
    print(json.encode(session));
    _offer = true;

    // print(json.encode({
    //       'sdp': description.sdp.toString(),
    //       'type': description.type.toString(),
    //     }));
    //FirebaseFirestore.instance.collection(widget.ownID).add(session);
    // print("writing my own des");

    //await pc.setLocalDescription(descriptionl);
    // await FirebaseFirestore.instance.collection("rooms").doc(room).set({
    //   'roolId': room,
    //   'offer': {
    //     "type": description.type,
    //     "sdp": description.sdp,
    //   }
    // });

    setState(() {
      widget.appbart = "reached fbinish ";
    });
  }

  void startCallStartedCount() {
    if (mounted) {
      StopRing();

      setState(() {
        widget.hasCountDownStartedOnce = true;
        widget.didOpositConnected = true;
      });

      widget.callStartedNotify();
    }


    Timer.periodic(Duration(milliseconds: 1000), (timer) {
      if (mounted) {
        setState(() {
          widget.callDurationSecond = widget.callDurationSecond + 1;
          String se = widget.callDurationSecond < 10
              ? "0" + widget.callDurationSecond.toString()
              : widget.callDurationSecond.toString();
          if (widget.callDurationSecond < 60) {
            widget.callDuration = "00:" + widget.callDurationSecond.toString();
          } else {
            int minutes = (widget.callDurationSecond / 60).truncate();
            String minutesStr = (minutes % 60).toString().padLeft(2, '0');

            //   int  minute =int.parse(( widget.callDurationSecond/60).toString());
            int second = widget.callDurationSecond % 60;
            String se =
            second < 10 ? "0" + second.toString() : second.toString();
            widget.callDuration = minutesStr + ":" + se;
          }
        });
      } else {
        timer.cancel();
      }
    });


  }

  void endCallListener() {
    widget.socket.on("callEnd" + widget.partnerid, (data) {
      print("callended on other side");

      if (mounted) {
        widget.callback();
        Navigator.pop(context);
      }
    });
  }

  void endCall() {
    widget.socket.emit("callEnd", {"id": widget.ownID});
    //widget.socket.emit("callCanceled",{"id":widget.ownID});
  }

  void renegoForOffer(RTCPeerConnection peerConnectionX) {
    //im the receiver, only take offer and give answer

    widget.socket.on("offerNneedAnswer" + widget.ownID,
            (data) async {
          // print(data);
          print("nego offer found");
          dynamic ss = data;
          print("found offer");
          lastOffer = data;
          RTCSessionDescription description = new RTCSessionDescription(ss["sdp"], ss["type"]);
          if(description.type == "offer"){



            await pc.setRemoteDescription(description);

            RTCSessionDescription descriptionLocal = await pc.createAnswer({'offerToReceiveVideo': 1, 'offerToReceiveAudio': 1});
            try {
              print(descriptionLocal.type);
              if (descriptionLocal.type == "answer") {
                await pc.setLocalDescription(descriptionLocal);
              } else {
                print("stopped because it was not an anwwer 1");
              }
            } catch (e) {
              print("my exception 3");
              print(e.toString());
            }

            widget.socket.emit("answerNasResponse", {
              "id": widget.partnerid,
              "answer": {
                "type": descriptionLocal.type,
                "sdp": descriptionLocal.sdp,
              }
            });



            widget.socket.on("offerNasResponse" + widget.ownID,
                    (data) async {
                  // print(data);
                  print("nego offer found");
                  dynamic ss = data;
                  lastOffer = data;
                  print("found offer");
                  RTCSessionDescription description =
                  new RTCSessionDescription(ss["sdp"], ss["type"]);
                  await pc.setRemoteDescription(description);

                  //now work here


                  RTCSessionDescription descriptionLocal = await pc
                      .createAnswer({'offerToReceiveVideo': 1, 'offerToReceiveAudio': 1});
                  await pc.setLocalDescription(descriptionLocal);

                  // RTCSessionDescription descriptionLastOffer = new RTCSessionDescription(lastOffer["sdp"], lastOffer["type"]);
                  //
                  // try {
                  //   print(descriptionLastOffer.type);
                  //   if (descriptionLastOffer.type == "offer" ) {
                  //     //
                  //     await pc.setLocalDescription(descriptionLastOffer);
                  //   } else {
                  //     print("stopped because it was not an anwwer");
                  //   }
                  // } catch (e) {
                  //   print("my exception 4");
                  //   print(e.toString());
                  // }
                });



          }
        });



    // try{
    //   widget.socket.on("offerN"+widget.ownID, (data) async{
    //     // print(data);
    //     print("nego offer found");
    //     dynamic ss =data;
    //     print("found offer");
    //     RTCSessionDescription description =
    //     new RTCSessionDescription(ss["sdp"], ss["type"]);
    //     await pc.setRemoteDescription(description);
    //     RTCSessionDescription descriptionLocal = await pc
    //         .createAnswer({'offerToReceiveVideo': 1, 'offerToReceiveAudio': 1});
    //     await pc.setLocalDescription(descriptionLocal);
    //     widget.socket.emit("answerN", {"id": widget.partnerid, "answer": {
    //       "type": descriptionLocal.type,
    //       "sdp": descriptionLocal.sdp,
    //     }});
    //
    //   });
    // }catch(e){
    //
    // }
  }

  void renegoForAnswer(RTCPeerConnection peerConnectionX) {
    //im am caller, i always do offer and receive answer

    widget.socket.on("answerNeedOffer" + widget.ownID, (data) async {
      RTCSessionDescription descriptionL = await pc
          .createOffer({'offerToReceiveVideo': 1, 'offerToReceiveAudio': 1});
      await pc.setLocalDescription(descriptionL);
      dynamic ss = data;
      lastAnswer = data;
      RTCSessionDescription description =
      new RTCSessionDescription(ss["sdp"], ss["type"]);
      try {
        await pc.setRemoteDescription(description);
      } catch (e) {
        print("my exception 1");
        print(e.toString());
      }
      lastOffer = description;

      widget.socket.emit("offerNasResponse", {
        "id": widget.partnerid,
        "offer": {
          "type": descriptionL.type,
          "sdp": descriptionL.sdp,
        }
      });
    });

    widget.socket.on("answerNasResponse" + widget.ownID,
            (data) async {
          lastAnswer = data;
          dynamic ss = data;
          if (false) {
            RTCSessionDescription descriptionLastOffer =
            new RTCSessionDescription(ss["sdp"], ss["type"]);
            if(descriptionLastOffer.type == "answer")
              await pc.setLocalDescription(descriptionLastOffer);
          }

          RTCSessionDescription description =
          new RTCSessionDescription(ss["sdp"], ss["type"]);

          try {
            await pc.setRemoteDescription(description);
          } catch (e) {
            print("my exception 2");
            print(e.toString());
          }

          // RTCSessionDescription descriptionL = await pc
          //     .createOffer({'offerToReceiveVideo': 1, 'offerToReceiveAudio': 1});
          // await pc.setLocalDescription(descriptionL);
        });

    // try {
    //   widget.socket.on("answerN"+widget.ownID, (data) async{
    //     print("nego answer found");
    //
    //     dynamic ss =data;
    //     setState(() {
    //       widget.appbart = "gdr " + ss["type"];
    //     });
    //     RTCSessionDescription description =
    //     new RTCSessionDescription(ss["sdp"], ss["type"]);
    //     await pc.setRemoteDescription(description);
    //
    //     RTCSessionDescription descriptionL = await pc
    //         .createOffer({'offerToReceiveVideo': 1, 'offerToReceiveAudio': 1});
    //     await pc.setLocalDescription(descriptionL);
    //
    //
    //     //temp turned off
    //
    //     widget.socket.emit("offerN", {"id": widget.partnerid, "offer": {
    //       "type": descriptionL.type,
    //       "sdp": descriptionL.sdp,
    //     }});
    //
    //
    //
    //
    //   });
    //
    //
    // } catch (e) {
    //
    // }
  }

  void workNowasRec()async {

    RTCPeerConnection rtcPeerConnection =await _createPeerConnectionSignal();
    pc = rtcPeerConnection;
    if (widget.isCaller == true) {
    } else {
      lookForOfferSignal();
      if (widget.isCaller == false) {
        widget.socket.emit("accept", {"id": widget.ownID});
      }
      renegoForOffer(rtcPeerConnection);
    }
  }

  void workAsCaller() async{
    RTCPeerConnection rtcPeerConnection = await _createPeerConnectionSignal();
    pc = rtcPeerConnection;
    if (widget.isCaller == true) {
      _createOfferSignal();
      //listen for nego as caller

      renegoForAnswer(rtcPeerConnection);
    } else {
      //lookForOfferSignal();
    }
  }
}

String makeRoomName(int one, int two) {
  if (one > two)
    return "" + one.toString() + "-" + two.toString();
  else
    return "" + two.toString() + "-" + one.toString();
}
