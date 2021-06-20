import 'dart:async';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:emojis/emoji.dart';
import 'package:http/http.dart' as http;
import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maulajimessenger/Screens/logged_in_home.dart';
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
import 'dart:math' as math;

class SingleChatThread extends StatefulWidget {
  dynamic chatBody;
  FirebaseAuth auth;
  void Function(dynamic, String) call;
  bool showEmojiListSingle = false;
  bool showMobileView = false;
  Widget messagebody = Text("");
  Widget nameBar = Text("");
  String room;
  Widget showFndAddDlg;
  IO.Socket socket;

  bool whileCall;

  var selectedEnojis = Emoji.byGroup(EmojiGroup.smileysEmotion).toList();

  SingleChatThread(
      {this.showMobileView,
      this.showFndAddDlg,
      this.room,
      this.whileCall,
      this.nameBar,
      this.messagebody,
      this.chatBody,
      this.auth,
      this.socket,
      this.call});

  @override
  _SingleChatThreadState createState() => _SingleChatThreadState();
}

class _SingleChatThreadState extends State<SingleChatThread> {
  TextEditingController controller = new TextEditingController();
  ScrollController _scrollController = new ScrollController();

  //List chatData = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // AppSignal().initSignal().emit("getMesage", {"fileName": widget.room});
    listenDisplayStatus();
    //AppSignal().initSignal().emit("getMesage", {"fileName":  widget.room});
    // setState(() {
    //   print("setting");
    //   widget.messagebody =ChatMesageLit(auth: widget.auth,chatBody: widget.chatBody,firebaseFirestore: widget.firestore,room:createRoomName(
    //       widget.auth.currentUser.uid,
    //       widget.chatBody["sender"] != null
    //           ? (widget.chatBody["sender"] ==
    //           widget.auth.currentUser.uid
    //           ? widget.chatBody["receiver"]
    //           : widget.chatBody["sender"])
    //           : widget.chatBody["uid"]));
    // });
  }

  @override
  Widget build(BuildContext context) {
    // return Text(widget.chatBody);

    return Scaffold(body: Padding(
      padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
      child: Stack(
        children: [
          Align( alignment: Alignment.topCenter,child:   StreamBuilder<NewIncCallModel>(
              stream:  NewIncommingCallBroadCaster.getInstance().outData,
              builder: (BuildContext context, AsyncSnapshot<NewIncCallModel> snapshot) {
                if(snapshot.hasData && snapshot.data.status == true){
                  return Container(width: MediaQuery.of(context).size.width,color: Colors.black,child: Row(mainAxisAlignment: MainAxisAlignment.end,children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton(backgroundColor: Colors.greenAccent,onPressed: (){
                        CommonFunctions(
                            auth: widget.auth)
                            .initCallIntent(socket: widget.socket,
                            callTYpe: "a",
                            ownid: widget
                                .auth
                                .currentUser
                                .uid,
                            partner: snapshot.data.body["callerId"],
                            isCaller: false,
                            context: context);
                        NewIncommingCallBroadCaster.getInstance().dataReload(NewIncCallModel(status: false));



                      },child: Icon(Icons.call),),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton(backgroundColor: Colors.greenAccent,onPressed: (){
                        CommonFunctions(
                            auth: widget.auth)
                            .initCallIntent(socket: widget.socket,
                            callTYpe: "v",
                            ownid: widget
                                .auth
                                .currentUser
                                .uid,
                            partner: snapshot.data.body["callerId"],
                            isCaller: false,
                            context: context);
                        NewIncommingCallBroadCaster.getInstance().dataReload(NewIncCallModel(status: false));



                      },child: Icon(Icons.videocam),),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton(backgroundColor: Colors.redAccent,onPressed: (){
                        widget.socket.emit(
                            "reject", {
                          "id":
                          widget.auth.currentUser.uid
                        });

                        NewIncommingCallBroadCaster.getInstance().dataReload(NewIncCallModel(status: false));
                      },child: Icon(Icons.call_end),),
                    ),
                  ],),);
                }else return   Container(
                  height: 70,
                  color: Color.fromARGB(255, 238, 246, 255),
                  child: Center(
                      child: Stack(
                        children: [
                          Positioned(
                              left: widget.showMobileView ? 50 : 0,
                              top: 0,
                              bottom: 0,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SimpleProfileView(room: widget.room,socket: widget.socket,
                                          auth: widget.auth,
                                          selfId: widget.auth.currentUser.uid,
                                          fndId: widget.chatBody["sender"] != null
                                              ? (widget.chatBody["sender"] ==
                                              widget.auth.currentUser.uid
                                              ? widget.chatBody["receiver"]
                                              : widget.chatBody["sender"])
                                              : widget.chatBody["uid"],
                                        )),
                                  );
                                },
                                child: Container(
                                  width: 300,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                    //child: prepare(widget.chatBody)
                                    // child:UserInfoBar(cBody: widget.chatBody,auth: widget.auth,call:  widget.call,),
                                    child:  UserInfoBar(
                                      auth: widget.auth,
                                      cBody: widget.chatBody,
                                    ),
                                    // child:Text(widget.chatBody.toString()),
                                    // child: Column(
                                    //   mainAxisAlignment: MainAxisAlignment.center,
                                    //   crossAxisAlignment: CrossAxisAlignment.start,
                                    //   children: [
                                    //     widget.chatBody["name"] != null
                                    //         ? Text(
                                    //             widget.chatBody["name"] == null
                                    //                 ? "No user Name"
                                    //                 : widget.chatBody["name"],
                                    //             style: TextStyle(
                                    //                 fontWeight: FontWeight.bold,
                                    //                 color: Colors.black,
                                    //                 fontSize: 20),
                                    //           )
                                    //         : getNameFromId(widget.chatBody, true,
                                    //             widget.firestore, widget.auth),
                                    //     widget.chatBody["email"] != null
                                    //         ? Text(widget.chatBody["email"])
                                    //         : getEmailFromId(widget.chatBody,
                                    //             widget.firestore, widget.auth),
                                    //   ],
                                    // ),
                                  ),
                                ),
                              )),
                          widget.whileCall
                              ? Container(
                            width: 0,
                            height: 0,
                          )
                              : Align(
                            alignment: Alignment.centerRight,
                            child:Wrap(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Container(
                                    width: 50,
                                    child: InkWell(
                                      onTap: () async {
                                        print("call button clicked");
                                        String partnerID;
                                        if (widget.chatBody["uid"] != null) {
                                          partnerID = widget.chatBody["uid"];
                                          // initCallIntent(
                                          //     "v",
                                          //     widget.homeWidget.auth.currentUser.uid,
                                          //     partnerID,
                                          //     true,
                                          //     widget.homeWidget.firestore,
                                          //     context);
                                          print(partnerID);
                                          widget.call(partnerID,"a");
                                        } else {
                                          if (widget.chatBody["sender"] ==
                                              widget.auth.currentUser.uid) {
                                            partnerID = widget.chatBody["receiver"];
                                          } else {
                                            partnerID = widget.chatBody["sender"];
                                          }

                                          print(partnerID);
                                          print("clicked call button");
                                          widget.call(partnerID,"v");
                                          // here add call button

                                        }
                                      },
                                      child: Container(
                                        height: 50,
                                        width: 50,
                                        child: Card(
                                          elevation: 1,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(35.0),
                                          ),
                                          //  color: Color.fromARGB(255, 241, 241, 241),
                                          color: Colors.grey.shade100,
                                          child: Icon(
                                            Icons.call_outlined,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Container(
                                    width: 50,
                                    child: InkWell(
                                      onTap: () async {
                                        print("call button clicked");
                                        String partnerID;
                                        if (widget.chatBody["uid"] != null) {
                                          partnerID = widget.chatBody["uid"];
                                          // initCallIntent(
                                          //     "v",
                                          //     widget.homeWidget.auth.currentUser.uid,
                                          //     partnerID,
                                          //     true,
                                          //     widget.homeWidget.firestore,
                                          //     context);
                                          print(partnerID);
                                          widget.call(partnerID,"v");
                                        } else {
                                          if (widget.chatBody["sender"] ==
                                              widget.auth.currentUser.uid) {
                                            partnerID = widget.chatBody["receiver"];
                                          } else {
                                            partnerID = widget.chatBody["sender"];
                                          }

                                          print(partnerID);
                                          print("clicked call button");
                                          widget.call(partnerID,"v");
                                          // here add call button

                                        }
                                      },
                                      child: Container(
                                        height: 50,
                                        width: 50,
                                        child: Card(
                                          elevation: 1,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(35.0),
                                          ),
                                          //  color: Color.fromARGB(255, 241, 241, 241),
                                          color: Colors.grey.shade100,
                                          child: Icon(
                                            Icons.videocam,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Visibility(
                              visible: widget.showMobileView,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: InkWell(
                                  onTap: () {
                                    print("pressed to go back");
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Icon(Icons.chevron_left),
                                  ),
                                ),
                              )),
                        ],
                      )),
                );

              }),),
          Positioned(
              top: 70,
              child: Container(
                color: Colors.grey,
                height: 0.5,
                width: MediaQuery.of(context).size.width,
              )),

          /*
            Positioned(
                top: 75,
                left: 0,
                right: 0,
                bottom: widget.showEmojiListSingle ? 370 : 70,
                child: StreamBuilder<QuerySnapshot>(
                    stream: widget.firestore
                        .collection(createRoomName(
                            widget.auth.currentUser.uid,
                            widget.chatBody["sender"] != null
                                ? (widget.chatBody["sender"] ==
                                        widget.auth.currentUser.uid
                                    ? widget.chatBody["receiver"]
                                    : widget.chatBody["sender"])
                                : widget.chatBody["uid"]))
                        .orderBy("time")
                        .snapshots(),
                    builder:
                        (BuildContext c, AsyncSnapshot<QuerySnapshot> snapshot) {
                      // _scrollController
                      //     .jumpTo(_scrollController.position.maxScrollExtent);

                      if (snapshot.hasData && snapshot.data.size > 0) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              curve: Curves.easeOut,
                              duration: const Duration(milliseconds: 300));
                        });

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                          child: ListView.builder(
                              controller: _scrollController,
                              shrinkWrap: true,
                              itemCount:
                                  snapshot.data == null ? 0 : snapshot.data.size,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: snapshot.data.docs[index]
                                                    .data()["sender"] ==
                                                widget.auth.currentUser.uid
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.all(0.0),
                                          child: snapshot.data.docs[index]
                                                      .data()["sender"] ==
                                                  widget.auth.currentUser.uid
                                              ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment: snapshot
                                                              .data.docs[index]
                                                              .data()["sender"] ==
                                                          widget.auth.currentUser
                                                              .uid
                                                      ? CrossAxisAlignment.end
                                                      : CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(0, 0, 5, 0),
                                                      child: Text(
                                                        DateFormat('hh:mm aa')
                                                            .format(DateTime
                                                                .fromMillisecondsSinceEpoch(
                                                                    snapshot
                                                                            .data
                                                                            .docs[
                                                                                index]
                                                                            .data()[
                                                                        "time"])),
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                    Card(
                                                      color: snapshot.data
                                                                      .docs[index]
                                                                      .data()[
                                                                  "sender"] ==
                                                              widget.auth
                                                                  .currentUser.uid
                                                          ? Colors.white
                                                          : Color.fromARGB(
                                                              255, 238, 246, 255),
                                                      child: Container(
                                                          child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                                8.0),
                                                        //   child: Text(snapshot.data.docs[index].data()["message"]),

                                                        child:
                                                            makeChatMessageHead1WithEmoji(
                                                                context,
                                                                snapshot.data
                                                                    .docs[index]
                                                                    .data()),
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
                                                            backgroundImage:
                                                                NetworkImage(widget
                                                                        .chatBody[
                                                                    "img"]),
                                                          ),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment: snapshot
                                                                      .data
                                                                      .docs[index]
                                                                      .data()[
                                                                  "sender"] ==
                                                              widget.auth
                                                                  .currentUser.uid
                                                          ? CrossAxisAlignment.end
                                                          : CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  5, 0, 0, 0),
                                                          child: Text(
                                                            DateFormat('hh:mm aa')
                                                                .format(DateTime
                                                                    .fromMillisecondsSinceEpoch(snapshot
                                                                            .data
                                                                            .docs[
                                                                                index]
                                                                            .data()[
                                                                        "time"])),
                                                            style: TextStyle(
                                                                fontSize: 12),
                                                          ),
                                                        ),
                                                        Card(
                                                          color: snapshot.data
                                                                          .docs[index]
                                                                          .data()[
                                                                      "sender"] ==
                                                                  widget
                                                                      .auth
                                                                      .currentUser
                                                                      .uid
                                                              ? Colors.white
                                                              : Color.fromARGB(
                                                                  255,
                                                                  238,
                                                                  246,
                                                                  255),
                                                          child: Container(
                                                              child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            // child: Text(snapshot.data.docs[index].data()["message"]),
                                                            child:
                                                                makeChatMessageHead1WithEmoji(
                                                                    context,
                                                                    snapshot
                                                                        .data
                                                                        .docs[
                                                                            index]
                                                                        .data()),
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
                          child: Text("Send your first message"),
                        );
                      }
                    })),
            */
          Positioned(
              top: 75,
              left: 0,
              right: 0,
              bottom: widget.showEmojiListSingle ? 370 : 70,
              child: getMessageBody(widget.socket)),

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
                                child:  TextField(
                                  onSubmitted: (val) async {
                                    CommonFunctions().sendMessage(
                                        widget.socket,
                                        widget.auth,
                                        val,
                                        "txt",
                                        "-",
                                        widget.chatBody);

                                    controller.clear();
                                  },
                                  controller: controller,
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
                                        CommonFunctions().sendMessage(
                                            widget.socket,
                                            widget.auth,
                                            res["path"],
                                            file.extension,
                                            file.name,
                                            widget.chatBody);
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
                              widget.whileCall == false
                                  ? Center(
                                child: new InkWell(
                                  onTap: () async {
                                    //widget.room
                                    setState(() {
                                      widget.showEmojiListSingle =
                                      !widget.showEmojiListSingle;
                                    });
                                    print("emoji " +
                                        widget.showEmojiListSingle
                                            .toString());
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: Text(
                                      Emoji.all().first.char,
                                      style: TextStyle(fontSize: 22),
                                    ),
                                  ),
                                ),
                              )
                                  : Container(
                                width: 0,
                                height: 0,
                              ),
                              Center(
                                child: new InkWell(
                                  onTap: () async {
                                    //widget.room
                                    CommonFunctions().sendMessage(
                                        widget.socket,
                                        widget.auth,
                                        Emoji.all()[139].char,
                                        "txt",
                                        "-",
                                        widget.chatBody);
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

                                    CommonFunctions().sendMessage(
                                        widget.socket,
                                        widget.auth,
                                        controller.text,
                                        "txt",
                                        "-",
                                        widget.chatBody);

                                    controller.clear();
                                    //widget.room
                                    // String text = controller.text;
                                    // if (text.length > 0) {
                                    //   String room = createRoomName(
                                    //       widget.auth.currentUser.uid,
                                    //       widget.chatBody["sender"] != null
                                    //           ? (widget.chatBody["sender"] ==
                                    //                   widget
                                    //                       .auth.currentUser.uid
                                    //               ? widget.chatBody["receiver"]
                                    //               : widget.chatBody["sender"])
                                    //           : widget.chatBody["uid"]);
                                    //
                                    //   await widget.firestore
                                    //       .collection("last")
                                    //       .doc(room)
                                    //       .set({
                                    //     "message": text,
                                    //     "sender": widget.auth.currentUser.uid,
                                    //     "receiver": widget.chatBody["sender"] !=
                                    //             null
                                    //         ? (widget.chatBody["sender"] ==
                                    //                 widget.auth.currentUser.uid
                                    //             ? widget.chatBody["receiver"]
                                    //             : widget.chatBody["sender"])
                                    //         : widget.chatBody["uid"]
                                    //   });
                                    //
                                    //   await widget.firestore
                                    //       .collection(room)
                                    //       .add({
                                    //     "time": DateTime.now()
                                    //         .millisecondsSinceEpoch,
                                    //     "message": text,
                                    //     "sender": widget.auth.currentUser.uid,
                                    //     "receiver": widget.chatBody["sender"] !=
                                    //             null
                                    //         ? (widget.chatBody["sender"] ==
                                    //                 widget.auth.currentUser.uid
                                    //             ? widget.chatBody["receiver"]
                                    //             : widget.chatBody["sender"])
                                    //         : widget.chatBody["uid"]
                                    //   });
                                    //   controller.clear();
                                    // }
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
                widget.showEmojiListSingle
                    ? Container(
                  height: 300,
                  // width: 500,
                  color: Colors.white,
                  child: GridView.builder(
                    itemCount: widget.selectedEnojis.length,
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                        MediaQuery.of(context).size.width > 700
                            ? 20
                            : 8),
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                          onTap: () {
                            controller.text = controller.text +
                                widget.selectedEnojis[index].char;
                          },
                          child: Center(
                              child: new Text(
                                  widget.selectedEnojis[index].char,
                                  style: TextStyle(fontSize: 22))));
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
          // widget.showProfileCompleteDialog
          //     ? Align(
          //   alignment: Alignment.center,
          //   child: Card(
          //     color: Color.fromARGB(255, 239, 247, 255),
          //     elevation: 20,
          //     child: Container(
          //         width: 400,
          //         height: 400,
          //         child: ProfileUpdateDialog(
          //           auth: widget.auth,
          //           firestore: widget.firestore,
          //           currentProfile: widget.currentProfile,
          //         )),
          //   ),
          // )
          //     : Container(
          //   width: 0,
          //   height: 0,
          // ),
          // showAddFndDialog(),

          // Positioned(
          //     top: 0,
          //     left: 0,
          //     right: 0,
          //     child: showAddFndDLG(widget.chatBody["sender"] != null
          //         ? (widget.chatBody["sender"] == widget.auth.currentUser.uid
          //         ? widget.chatBody["receiver"]
          //         : widget.chatBody["sender"])
          //         : widget.chatBody["uid"]))
        ],
      ),
    ),);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
      child: Stack(
        children: [
          Align( alignment: Alignment.topCenter,child:   StreamBuilder<NewIncCallModel>(
              stream:  NewIncommingCallBroadCaster.getInstance().outData,
              builder: (BuildContext context, AsyncSnapshot<NewIncCallModel> snapshot) {
                if(snapshot.hasData && snapshot.data.status == true){
                  return Container(width: MediaQuery.of(context).size.width,color: Colors.black,child: Row(mainAxisAlignment: MainAxisAlignment.end,children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton(backgroundColor: Colors.greenAccent,onPressed: (){
                        CommonFunctions(
                            auth: widget.auth)
                            .initCallIntent(socket: widget.socket,
                            callTYpe: "v",
                            ownid: widget
                                .auth
                                .currentUser
                                .uid,
                            partner: snapshot.data.body["callerId"],
                            isCaller: false,
                            context: context);
                        NewIncommingCallBroadCaster.getInstance().dataReload(NewIncCallModel(status: false));



                      },child: Icon(Icons.call),),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton(backgroundColor: Colors.redAccent,onPressed: (){
                        widget.socket.emit(
                            "reject", {
                          "id":
                          widget.auth.currentUser.uid
                        });

                        NewIncommingCallBroadCaster.getInstance().dataReload(NewIncCallModel(status: false));
                      },child: Icon(Icons.call_end),),
                    ),
                  ],),);
                }else return   Container(
                  height: 70,
                  color: Color.fromARGB(255, 238, 246, 255),
                  child: Center(
                      child: Stack(
                        children: [
                          Positioned(
                              left: widget.showMobileView ? 50 : 0,
                              top: 0,
                              bottom: 0,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SimpleProfileView(room: widget.room,socket: widget.socket,
                                          auth: widget.auth,
                                          selfId: widget.auth.currentUser.uid,
                                          fndId: widget.chatBody["sender"] != null
                                              ? (widget.chatBody["sender"] ==
                                              widget.auth.currentUser.uid
                                              ? widget.chatBody["receiver"]
                                              : widget.chatBody["sender"])
                                              : widget.chatBody["uid"],
                                        )),
                                  );
                                },
                                child: Container(
                                  width: 300,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                    //child: prepare(widget.chatBody)
                                    // child:UserInfoBar(cBody: widget.chatBody,auth: widget.auth,call:  widget.call,),
                                    child: widget.nameBar,
                                    // child:Text(widget.chatBody.toString()),
                                    // child: Column(
                                    //   mainAxisAlignment: MainAxisAlignment.center,
                                    //   crossAxisAlignment: CrossAxisAlignment.start,
                                    //   children: [
                                    //     widget.chatBody["name"] != null
                                    //         ? Text(
                                    //             widget.chatBody["name"] == null
                                    //                 ? "No user Name"
                                    //                 : widget.chatBody["name"],
                                    //             style: TextStyle(
                                    //                 fontWeight: FontWeight.bold,
                                    //                 color: Colors.black,
                                    //                 fontSize: 20),
                                    //           )
                                    //         : getNameFromId(widget.chatBody, true,
                                    //             widget.firestore, widget.auth),
                                    //     widget.chatBody["email"] != null
                                    //         ? Text(widget.chatBody["email"])
                                    //         : getEmailFromId(widget.chatBody,
                                    //             widget.firestore, widget.auth),
                                    //   ],
                                    // ),
                                  ),
                                ),
                              )),
                          widget.whileCall
                              ? Container(
                            width: 0,
                            height: 0,
                          )
                              : Align(
                            alignment: Alignment.centerRight,
                            child:Wrap(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Container(
                                    width: 50,
                                    child: InkWell(
                                      onTap: () async {
                                        print("call button clicked");
                                        String partnerID;
                                        if (widget.chatBody["uid"] != null) {
                                          partnerID = widget.chatBody["uid"];
                                          // initCallIntent(
                                          //     "v",
                                          //     widget.homeWidget.auth.currentUser.uid,
                                          //     partnerID,
                                          //     true,
                                          //     widget.homeWidget.firestore,
                                          //     context);
                                          print(partnerID);
                                          widget.call(partnerID,"a");
                                        } else {
                                          if (widget.chatBody["sender"] ==
                                              widget.auth.currentUser.uid) {
                                            partnerID = widget.chatBody["receiver"];
                                          } else {
                                            partnerID = widget.chatBody["sender"];
                                          }

                                          print(partnerID);
                                          print("clicked call button");
                                          widget.call(partnerID,"v");
                                          // here add call button

                                        }
                                      },
                                      child: Container(
                                        height: 50,
                                        width: 50,
                                        child: Card(
                                          elevation: 1,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(35.0),
                                          ),
                                          //  color: Color.fromARGB(255, 241, 241, 241),
                                          color: Colors.grey.shade100,
                                          child: Icon(
                                            Icons.call_outlined,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.all(5.0),
                                //   child: Container(
                                //     width: 50,
                                //     child: InkWell(
                                //       onTap: () async {
                                //         print("call button clicked");
                                //         String partnerID;
                                //         if (widget.chatBody["uid"] != null) {
                                //           partnerID = widget.chatBody["uid"];
                                //           // initCallIntent(
                                //           //     "v",
                                //           //     widget.homeWidget.auth.currentUser.uid,
                                //           //     partnerID,
                                //           //     true,
                                //           //     widget.homeWidget.firestore,
                                //           //     context);
                                //           print(partnerID);
                                //           widget.call(partnerID,"a");
                                //         } else {
                                //           if (widget.chatBody["sender"] ==
                                //               widget.auth.currentUser.uid) {
                                //             partnerID = widget.chatBody["receiver"];
                                //           } else {
                                //             partnerID = widget.chatBody["sender"];
                                //           }
                                //
                                //           print(partnerID);
                                //           print("clicked call button");
                                //           widget.call(partnerID,"v");
                                //           // here add call button
                                //
                                //         }
                                //       },
                                //       child: Container(
                                //         height: 50,
                                //         width: 50,
                                //         child: Card(
                                //           elevation: 1,
                                //           shape: RoundedRectangleBorder(
                                //             borderRadius: BorderRadius.circular(35.0),
                                //           ),
                                //           //  color: Color.fromARGB(255, 241, 241, 241),
                                //           color: Colors.grey.shade100,
                                //           child: Icon(
                                //             Icons.videocam,
                                //             color: Colors.black,
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                // )
                              ],
                            ),
                          ),
                          Visibility(
                              visible: widget.showMobileView,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: InkWell(
                                  onTap: () {
                                    print("pressed to go back");
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Icon(Icons.chevron_left),
                                  ),
                                ),
                              )),
                        ],
                      )),
                );

              }),),
          Positioned(
              top: 70,
              child: Container(
                color: Colors.grey,
                height: 0.5,
                width: MediaQuery.of(context).size.width,
              )),

          /*
            Positioned(
                top: 75,
                left: 0,
                right: 0,
                bottom: widget.showEmojiListSingle ? 370 : 70,
                child: StreamBuilder<QuerySnapshot>(
                    stream: widget.firestore
                        .collection(createRoomName(
                            widget.auth.currentUser.uid,
                            widget.chatBody["sender"] != null
                                ? (widget.chatBody["sender"] ==
                                        widget.auth.currentUser.uid
                                    ? widget.chatBody["receiver"]
                                    : widget.chatBody["sender"])
                                : widget.chatBody["uid"]))
                        .orderBy("time")
                        .snapshots(),
                    builder:
                        (BuildContext c, AsyncSnapshot<QuerySnapshot> snapshot) {
                      // _scrollController
                      //     .jumpTo(_scrollController.position.maxScrollExtent);

                      if (snapshot.hasData && snapshot.data.size > 0) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              curve: Curves.easeOut,
                              duration: const Duration(milliseconds: 300));
                        });

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                          child: ListView.builder(
                              controller: _scrollController,
                              shrinkWrap: true,
                              itemCount:
                                  snapshot.data == null ? 0 : snapshot.data.size,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: snapshot.data.docs[index]
                                                    .data()["sender"] ==
                                                widget.auth.currentUser.uid
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.all(0.0),
                                          child: snapshot.data.docs[index]
                                                      .data()["sender"] ==
                                                  widget.auth.currentUser.uid
                                              ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment: snapshot
                                                              .data.docs[index]
                                                              .data()["sender"] ==
                                                          widget.auth.currentUser
                                                              .uid
                                                      ? CrossAxisAlignment.end
                                                      : CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(0, 0, 5, 0),
                                                      child: Text(
                                                        DateFormat('hh:mm aa')
                                                            .format(DateTime
                                                                .fromMillisecondsSinceEpoch(
                                                                    snapshot
                                                                            .data
                                                                            .docs[
                                                                                index]
                                                                            .data()[
                                                                        "time"])),
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                    Card(
                                                      color: snapshot.data
                                                                      .docs[index]
                                                                      .data()[
                                                                  "sender"] ==
                                                              widget.auth
                                                                  .currentUser.uid
                                                          ? Colors.white
                                                          : Color.fromARGB(
                                                              255, 238, 246, 255),
                                                      child: Container(
                                                          child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                                8.0),
                                                        //   child: Text(snapshot.data.docs[index].data()["message"]),

                                                        child:
                                                            makeChatMessageHead1WithEmoji(
                                                                context,
                                                                snapshot.data
                                                                    .docs[index]
                                                                    .data()),
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
                                                            backgroundImage:
                                                                NetworkImage(widget
                                                                        .chatBody[
                                                                    "img"]),
                                                          ),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment: snapshot
                                                                      .data
                                                                      .docs[index]
                                                                      .data()[
                                                                  "sender"] ==
                                                              widget.auth
                                                                  .currentUser.uid
                                                          ? CrossAxisAlignment.end
                                                          : CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  5, 0, 0, 0),
                                                          child: Text(
                                                            DateFormat('hh:mm aa')
                                                                .format(DateTime
                                                                    .fromMillisecondsSinceEpoch(snapshot
                                                                            .data
                                                                            .docs[
                                                                                index]
                                                                            .data()[
                                                                        "time"])),
                                                            style: TextStyle(
                                                                fontSize: 12),
                                                          ),
                                                        ),
                                                        Card(
                                                          color: snapshot.data
                                                                          .docs[index]
                                                                          .data()[
                                                                      "sender"] ==
                                                                  widget
                                                                      .auth
                                                                      .currentUser
                                                                      .uid
                                                              ? Colors.white
                                                              : Color.fromARGB(
                                                                  255,
                                                                  238,
                                                                  246,
                                                                  255),
                                                          child: Container(
                                                              child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            // child: Text(snapshot.data.docs[index].data()["message"]),
                                                            child:
                                                                makeChatMessageHead1WithEmoji(
                                                                    context,
                                                                    snapshot
                                                                        .data
                                                                        .docs[
                                                                            index]
                                                                        .data()),
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
                          child: Text("Send your first message"),
                        );
                      }
                    })),
            */
          Positioned(
              top: 75,
              left: 0,
              right: 0,
              bottom: widget.showEmojiListSingle ? 370 : 70,
              child: getMessageBody(widget.socket)),

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
                                child:  TextField(
                                  onSubmitted: (val) async {
                                    CommonFunctions().sendMessage(
                                        widget.socket,
                                        widget.auth,
                                        val,
                                        "txt",
                                        "-",
                                        widget.chatBody);

                                    controller.clear();
                                  },
                                  controller: controller,
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
                                        CommonFunctions().sendMessage(
                                            widget.socket,
                                            widget.auth,
                                            res["path"],
                                            file.extension,
                                            file.name,
                                            widget.chatBody);
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
                              widget.whileCall == false
                                  ? Center(
                                child: new InkWell(
                                  onTap: () async {
                                    //widget.room
                                    setState(() {
                                      widget.showEmojiListSingle =
                                      !widget.showEmojiListSingle;
                                    });
                                    print("emoji " +
                                        widget.showEmojiListSingle
                                            .toString());
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: Text(
                                      Emoji.all().first.char,
                                      style: TextStyle(fontSize: 22),
                                    ),
                                  ),
                                ),
                              )
                                  : Container(
                                width: 0,
                                height: 0,
                              ),
                              Center(
                                child: new InkWell(
                                  onTap: () async {
                                    //widget.room
                                    CommonFunctions().sendMessage(
                                        widget.socket,
                                        widget.auth,
                                        Emoji.all()[139].char,
                                        "txt",
                                        "-",
                                        widget.chatBody);
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

                                    CommonFunctions().sendMessage(
                                        widget.socket,
                                        widget.auth,
                                        controller.text,
                                        "txt",
                                        "-",
                                        widget.chatBody);

                                    controller.clear();
                                    //widget.room
                                    // String text = controller.text;
                                    // if (text.length > 0) {
                                    //   String room = createRoomName(
                                    //       widget.auth.currentUser.uid,
                                    //       widget.chatBody["sender"] != null
                                    //           ? (widget.chatBody["sender"] ==
                                    //                   widget
                                    //                       .auth.currentUser.uid
                                    //               ? widget.chatBody["receiver"]
                                    //               : widget.chatBody["sender"])
                                    //           : widget.chatBody["uid"]);
                                    //
                                    //   await widget.firestore
                                    //       .collection("last")
                                    //       .doc(room)
                                    //       .set({
                                    //     "message": text,
                                    //     "sender": widget.auth.currentUser.uid,
                                    //     "receiver": widget.chatBody["sender"] !=
                                    //             null
                                    //         ? (widget.chatBody["sender"] ==
                                    //                 widget.auth.currentUser.uid
                                    //             ? widget.chatBody["receiver"]
                                    //             : widget.chatBody["sender"])
                                    //         : widget.chatBody["uid"]
                                    //   });
                                    //
                                    //   await widget.firestore
                                    //       .collection(room)
                                    //       .add({
                                    //     "time": DateTime.now()
                                    //         .millisecondsSinceEpoch,
                                    //     "message": text,
                                    //     "sender": widget.auth.currentUser.uid,
                                    //     "receiver": widget.chatBody["sender"] !=
                                    //             null
                                    //         ? (widget.chatBody["sender"] ==
                                    //                 widget.auth.currentUser.uid
                                    //             ? widget.chatBody["receiver"]
                                    //             : widget.chatBody["sender"])
                                    //         : widget.chatBody["uid"]
                                    //   });
                                    //   controller.clear();
                                    // }
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
                widget.showEmojiListSingle
                    ? Container(
                  height: 300,
                  // width: 500,
                  color: Colors.white,
                  child: GridView.builder(
                    itemCount: widget.selectedEnojis.length,
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                        MediaQuery.of(context).size.width > 700
                            ? 20
                            : 8),
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                          onTap: () {
                            controller.text = controller.text +
                                widget.selectedEnojis[index].char;
                          },
                          child: Center(
                              child: new Text(
                                  widget.selectedEnojis[index].char,
                                  style: TextStyle(fontSize: 22))));
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
          // widget.showProfileCompleteDialog
          //     ? Align(
          //   alignment: Alignment.center,
          //   child: Card(
          //     color: Color.fromARGB(255, 239, 247, 255),
          //     elevation: 20,
          //     child: Container(
          //         width: 400,
          //         height: 400,
          //         child: ProfileUpdateDialog(
          //           auth: widget.auth,
          //           firestore: widget.firestore,
          //           currentProfile: widget.currentProfile,
          //         )),
          //   ),
          // )
          //     : Container(
          //   width: 0,
          //   height: 0,
          // ),
          // showAddFndDialog(),

          // Positioned(
          //     top: 0,
          //     left: 0,
          //     right: 0,
          //     child: showAddFndDLG(widget.chatBody["sender"] != null
          //         ? (widget.chatBody["sender"] == widget.auth.currentUser.uid
          //         ? widget.chatBody["receiver"]
          //         : widget.chatBody["sender"])
          //         : widget.chatBody["uid"]))
        ],
      ),
    );



    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
        child: Stack(
          children: [
            Positioned(
                top: 70,
                child: Container(
                  color: Colors.grey,
                  height: 0.5,
                  width: MediaQuery.of(context).size.width,
                )),
            Container(
              height: 70,
              color: Color.fromARGB(255, 238, 246, 255),
              child: Center(
                  child: Stack(
                children: [
                  Positioned(
                      left: widget.showMobileView ? 50 : 0,
                      top: 0,
                      bottom: 0,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SimpleProfileView(room: widget.room,socket: widget.socket,
                                      auth: widget.auth,
                                      selfId: widget.auth.currentUser.uid,
                                      fndId: widget.chatBody["sender"] != null
                                          ? (widget.chatBody["sender"] ==
                                                  widget.auth.currentUser.uid
                                              ? widget.chatBody["receiver"]
                                              : widget.chatBody["sender"])
                                          : widget.chatBody["uid"],
                                    )),
                          );
                        },
                        child: Container(
                          width: 300,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                            //child: prepare(widget.chatBody)
                            // child:UserInfoBar(cBody: widget.chatBody,auth: widget.auth,call:  widget.call,),
                            child: widget.nameBar,
                            // child:Text(widget.chatBody.toString()),
                            // child: Column(
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: [
                            //     widget.chatBody["name"] != null
                            //         ? Text(
                            //             widget.chatBody["name"] == null
                            //                 ? "No user Name"
                            //                 : widget.chatBody["name"],
                            //             style: TextStyle(
                            //                 fontWeight: FontWeight.bold,
                            //                 color: Colors.black,
                            //                 fontSize: 20),
                            //           )
                            //         : getNameFromId(widget.chatBody, true,
                            //             widget.firestore, widget.auth),
                            //     widget.chatBody["email"] != null
                            //         ? Text(widget.chatBody["email"])
                            //         : getEmailFromId(widget.chatBody,
                            //             widget.firestore, widget.auth),
                            //   ],
                            // ),
                          ),
                        ),
                      )),
                  widget.whileCall
                      ? Container(
                          width: 0,
                          height: 0,
                        )
                      : Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                              width: 50,
                              child: InkWell(
                                onTap: () async {
                                  print("call button clicked");
                                  String partnerID;
                                  if (widget.chatBody["uid"] != null) {
                                    partnerID = widget.chatBody["uid"];
                                    // initCallIntent(
                                    //     "v",
                                    //     widget.homeWidget.auth.currentUser.uid,
                                    //     partnerID,
                                    //     true,
                                    //     widget.homeWidget.firestore,
                                    //     context);
                                    print(partnerID);
                                    widget.call(partnerID,"a");
                                  } else {
                                    if (widget.chatBody["sender"] ==
                                        widget.auth.currentUser.uid) {
                                      partnerID = widget.chatBody["receiver"];
                                    } else {
                                      partnerID = widget.chatBody["sender"];
                                    }

                                    print(partnerID);
                                    print("clicked call button");
                                    widget.call(partnerID,"a");
                                    // here add call button

                                  }
                                },
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  child: Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(35.0),
                                    ),
                                    //  color: Color.fromARGB(255, 241, 241, 241),
                                    color: Colors.greenAccent,
                                    child: Icon(
                                      Icons.call_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                  Visibility(
                      visible: widget.showMobileView,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          onTap: () {
                            print("pressed to go back");
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Icon(Icons.chevron_left),
                          ),
                        ),
                      )),
                ],
              )),
            ),
            /*
            Positioned(
                top: 75,
                left: 0,
                right: 0,
                bottom: widget.showEmojiListSingle ? 370 : 70,
                child: StreamBuilder<QuerySnapshot>(
                    stream: widget.firestore
                        .collection(createRoomName(
                            widget.auth.currentUser.uid,
                            widget.chatBody["sender"] != null
                                ? (widget.chatBody["sender"] ==
                                        widget.auth.currentUser.uid
                                    ? widget.chatBody["receiver"]
                                    : widget.chatBody["sender"])
                                : widget.chatBody["uid"]))
                        .orderBy("time")
                        .snapshots(),
                    builder:
                        (BuildContext c, AsyncSnapshot<QuerySnapshot> snapshot) {
                      // _scrollController
                      //     .jumpTo(_scrollController.position.maxScrollExtent);

                      if (snapshot.hasData && snapshot.data.size > 0) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              curve: Curves.easeOut,
                              duration: const Duration(milliseconds: 300));
                        });

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                          child: ListView.builder(
                              controller: _scrollController,
                              shrinkWrap: true,
                              itemCount:
                                  snapshot.data == null ? 0 : snapshot.data.size,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: snapshot.data.docs[index]
                                                    .data()["sender"] ==
                                                widget.auth.currentUser.uid
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.all(0.0),
                                          child: snapshot.data.docs[index]
                                                      .data()["sender"] ==
                                                  widget.auth.currentUser.uid
                                              ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment: snapshot
                                                              .data.docs[index]
                                                              .data()["sender"] ==
                                                          widget.auth.currentUser
                                                              .uid
                                                      ? CrossAxisAlignment.end
                                                      : CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(0, 0, 5, 0),
                                                      child: Text(
                                                        DateFormat('hh:mm aa')
                                                            .format(DateTime
                                                                .fromMillisecondsSinceEpoch(
                                                                    snapshot
                                                                            .data
                                                                            .docs[
                                                                                index]
                                                                            .data()[
                                                                        "time"])),
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                    Card(
                                                      color: snapshot.data
                                                                      .docs[index]
                                                                      .data()[
                                                                  "sender"] ==
                                                              widget.auth
                                                                  .currentUser.uid
                                                          ? Colors.white
                                                          : Color.fromARGB(
                                                              255, 238, 246, 255),
                                                      child: Container(
                                                          child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                                8.0),
                                                        //   child: Text(snapshot.data.docs[index].data()["message"]),

                                                        child:
                                                            makeChatMessageHead1WithEmoji(
                                                                context,
                                                                snapshot.data
                                                                    .docs[index]
                                                                    .data()),
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
                                                            backgroundImage:
                                                                NetworkImage(widget
                                                                        .chatBody[
                                                                    "img"]),
                                                          ),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment: snapshot
                                                                      .data
                                                                      .docs[index]
                                                                      .data()[
                                                                  "sender"] ==
                                                              widget.auth
                                                                  .currentUser.uid
                                                          ? CrossAxisAlignment.end
                                                          : CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  5, 0, 0, 0),
                                                          child: Text(
                                                            DateFormat('hh:mm aa')
                                                                .format(DateTime
                                                                    .fromMillisecondsSinceEpoch(snapshot
                                                                            .data
                                                                            .docs[
                                                                                index]
                                                                            .data()[
                                                                        "time"])),
                                                            style: TextStyle(
                                                                fontSize: 12),
                                                          ),
                                                        ),
                                                        Card(
                                                          color: snapshot.data
                                                                          .docs[index]
                                                                          .data()[
                                                                      "sender"] ==
                                                                  widget
                                                                      .auth
                                                                      .currentUser
                                                                      .uid
                                                              ? Colors.white
                                                              : Color.fromARGB(
                                                                  255,
                                                                  238,
                                                                  246,
                                                                  255),
                                                          child: Container(
                                                              child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            // child: Text(snapshot.data.docs[index].data()["message"]),
                                                            child:
                                                                makeChatMessageHead1WithEmoji(
                                                                    context,
                                                                    snapshot
                                                                        .data
                                                                        .docs[
                                                                            index]
                                                                        .data()),
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
                          child: Text("Send your first message"),
                        );
                      }
                    })),
            */
            Positioned(
                top: 75,
                left: 0,
                right: 0,
                bottom: widget.showEmojiListSingle ? 370 : 70,
                child: getMessageBody(widget.socket)),

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
                                      CommonFunctions().sendMessage(
                                          widget.socket,
                                          widget.auth,
                                          val,
                                          "txt",
                                          "-",
                                          widget.chatBody);

                                      controller.clear();
                                    },
                                    controller: controller,
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
                                          CommonFunctions().sendMessage(
                                              widget.socket,
                                              widget.auth,
                                              res["path"],
                                              file.extension,
                                              file.name,
                                              widget.chatBody);
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
                                widget.whileCall == false
                                    ? Center(
                                        child: new InkWell(
                                          onTap: () async {
                                            //widget.room
                                            setState(() {
                                              widget.showEmojiListSingle =
                                                  !widget.showEmojiListSingle;
                                            });
                                            print("emoji " +
                                                widget.showEmojiListSingle
                                                    .toString());
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(0.0),
                                            child: Text(
                                              Emoji.all().first.char,
                                              style: TextStyle(fontSize: 22),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: 0,
                                        height: 0,
                                      ),
                                Center(
                                  child: new InkWell(
                                    onTap: () async {
                                      //widget.room
                                      CommonFunctions().sendMessage(
                                          widget.socket,
                                          widget.auth,
                                          Emoji.all()[139].char,
                                          "txt",
                                          "-",
                                          widget.chatBody);
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
                                      // String text = controller.text;
                                      // if (text.length > 0) {
                                      //   String room = createRoomName(
                                      //       widget.auth.currentUser.uid,
                                      //       widget.chatBody["sender"] != null
                                      //           ? (widget.chatBody["sender"] ==
                                      //                   widget
                                      //                       .auth.currentUser.uid
                                      //               ? widget.chatBody["receiver"]
                                      //               : widget.chatBody["sender"])
                                      //           : widget.chatBody["uid"]);
                                      //
                                      //   await widget.firestore
                                      //       .collection("last")
                                      //       .doc(room)
                                      //       .set({
                                      //     "message": text,
                                      //     "sender": widget.auth.currentUser.uid,
                                      //     "receiver": widget.chatBody["sender"] !=
                                      //             null
                                      //         ? (widget.chatBody["sender"] ==
                                      //                 widget.auth.currentUser.uid
                                      //             ? widget.chatBody["receiver"]
                                      //             : widget.chatBody["sender"])
                                      //         : widget.chatBody["uid"]
                                      //   });
                                      //
                                      //   await widget.firestore
                                      //       .collection(room)
                                      //       .add({
                                      //     "time": DateTime.now()
                                      //         .millisecondsSinceEpoch,
                                      //     "message": text,
                                      //     "sender": widget.auth.currentUser.uid,
                                      //     "receiver": widget.chatBody["sender"] !=
                                      //             null
                                      //         ? (widget.chatBody["sender"] ==
                                      //                 widget.auth.currentUser.uid
                                      //             ? widget.chatBody["receiver"]
                                      //             : widget.chatBody["sender"])
                                      //         : widget.chatBody["uid"]
                                      //   });
                                      //   controller.clear();
                                      // }
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
                  widget.showEmojiListSingle
                      ? Container(
                          height: 300,
                          // width: 500,
                          color: Colors.white,
                          child: GridView.builder(
                            itemCount: widget.selectedEnojis.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        MediaQuery.of(context).size.width > 700
                                            ? 20
                                            : 8),
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                  onTap: () {
                                    controller.text = controller.text +
                                        widget.selectedEnojis[index].char;
                                  },
                                  child: Center(
                                      child: new Text(
                                          widget.selectedEnojis[index].char,
                                          style: TextStyle(fontSize: 22))));
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
            // widget.showProfileCompleteDialog
            //     ? Align(
            //   alignment: Alignment.center,
            //   child: Card(
            //     color: Color.fromARGB(255, 239, 247, 255),
            //     elevation: 20,
            //     child: Container(
            //         width: 400,
            //         height: 400,
            //         child: ProfileUpdateDialog(
            //           auth: widget.auth,
            //           firestore: widget.firestore,
            //           currentProfile: widget.currentProfile,
            //         )),
            //   ),
            // )
            //     : Container(
            //   width: 0,
            //   height: 0,
            // ),
            // showAddFndDialog(),

            // Positioned(
            //     top: 0,
            //     left: 0,
            //     right: 0,
            //     child: showAddFndDLG(widget.chatBody["sender"] != null
            //         ? (widget.chatBody["sender"] == widget.auth.currentUser.uid
            //         ? widget.chatBody["receiver"]
            //         : widget.chatBody["sender"])
            //         : widget.chatBody["uid"]))
          ],
        ),
      ),
    );
  }

  void listenDisplayStatus() {}

  String getExtention(String mime) {
    if (mime == "audio/aac") return "aac";
    if (mime == "video/x-msvideo") return "avi";
    if (mime == "image/bmp") return "bmp";
    if (mime == "text/csv") return "csv";
    if (mime == "application/msword") return "doc";
    if (mime ==
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document")
      return "docx";
    if (mime == "image/gif") return "gif";
    if (mime == "text/html") return "html";
    if (mime == "image/jpeg") return "jpeg";
    if (mime == "image/jpeg") return "bmp";
    if (mime == "image/jpg") return "jpeg";
    if (mime == "application/json") return "json";

    if (mime == "audio/mpeg") return "mp3";
    if (mime == "video/mp4") return "mp4";
    if (mime == "video/mpeg") return "mpeg";
    if (mime == "image/png") return "png";
    if (mime == "application/pdf") return "pdf";
    if (mime == "ppt") return "application/vnd.ms-powerpoint";
    if (mime == "pptx")
      return "application/vnd.openxmlformats-officedocument.presentationml.presentation";
    if (mime == "rar") return "application/vnd.rar";
    if (mime == "svg") return "image/svg+xml";
    if (mime == "txt") return "text/plain";
    if (mime == "webm") return "video/webm";
    if (mime == "zip") return "application/zip";
    if (mime == "3gp") return "video/3gpp";
    if (mime == "3gp") return "audio/3gpp";
  }

  Future getIfFriend(String fnd) async {
    var url = Uri.parse(AppSettings().Api_link +
        'checkMyFnd?id=' +
        widget.auth.currentUser.uid +
        "&&fnd=" +
        fnd);
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    dynamic res = jsonDecode(response.body);
    return res;
  }

  showAddFndDialog() {
    String fndID = widget.chatBody["sender"] != null
        ? (widget.chatBody["sender"] == widget.auth.currentUser.uid
            ? widget.chatBody["receiver"]
            : widget.chatBody["sender"])
        : widget.chatBody["uid"];
    return Container(
      height: 125,
      child: Stack(
        children: [
          Positioned(
              top: 75,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                child: Center(
                    child: AddFndWidget(
                  fndID: fndID,
                  uid: widget.auth.currentUser.uid,
                )),
              ))
        ],
      ),
    );
    return Stack(
      children: [
        Positioned(
            top: 75,
            left: 0,
            right: 0,
            child: Center(
                child: AddFndWidget(
              fndID: fndID,
              uid: widget.auth.currentUser.uid,
            )))
      ],
    );
    return AddFndWidget(
      fndID: fndID,
      uid: widget.auth.currentUser.uid,
    );
    return FutureBuilder<dynamic>(
        future: getIfFriend(fndID),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            if (snapshot.data["fnd"] == false) {
              return Positioned(
                  top: 75,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Wrap(
                      children: [
                        InkWell(
                          onTap: () async {
                            var url = Uri.parse(
                                'http://localhost:3001/addFnd?id=' +
                                    widget.auth.currentUser.uid +
                                    "&&fnd=" +
                                    fndID);
                            var response = await http.get(url);
                            setState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                                color: Theme.of(context).primaryColor,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
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
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
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
                    ),
                  ));
            } else {
              return Container(
                width: 0,
                height: 0,
              );
            }
          } else {
            return Container(
              width: 0,
              height: 0,
            );
          }
        });
  }

  fetchUserNameEmail() {
    dynamic data;
    String fndID = widget.chatBody["sender"] != null
        ? (widget.chatBody["sender"] == widget.auth.currentUser.uid
            ? widget.chatBody["receiver"]
            : widget.chatBody["sender"])
        : widget.chatBody["uid"];
    AppSignal().initSignal().on(fndID + "_profile", (data) {
      print("by second");
      print(data);
      if (mounted) {
        try {
          FetchUserInfoStream.getInstance().dataReload(data);
        } catch (e) {}
      }
    });
    // AppSignal().initSignal().emit("saveProfileData",{"uid":widget.auth.currentUser.uid,"name":"mukul"});
    AppSignal().initSignal().emit("getUserProfile", {"uid": fndID});

    return StreamBuilder<dynamic>(
        stream: FetchUserInfoStream.getInstance().outData,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          print("from stream");
          print(snapshot.data.toString());
          if (snapshot.hasData && snapshot.data != null) {
            return ListTile(
              title: Text(
                data["name"],
                style: TextStyle(),
              ),
              subtitle: Text(data["email"]),
            );
          } else {
            return Text("Please wait");
          }
        });
  }

  Widget getMessageBody(IO.Socket socket) {
    socket.on(widget.room, (data) {
      if (true && data["room"] == widget.room) {
        ChatDataloadedStream.getInstance().dataReload(data["data"]);
      } else {
        print("blocked");
      }

      print("downloaded");
      print(data.length.toString());
    });

    socket.emit("getMesage", {"fileName": widget.room});
    // Timer.periodic(Duration(milliseconds: 300), (timer) async {
    //   if (mounted) {
    //     var url = Uri.parse('https://api.maulaji.com/getMessage?id='+widget.room);
    //     var response = await http.get(url, );
    //     setState(() {
    //       chatData = jsonDecode(response.body);
    //     });
    //     WidgetsBinding.instance.addPostFrameCallback((_) {
    //       if(_scrollController.hasClients){
    //         _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.ease);
    //         //_scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    //       }
    //     });
    //   }});

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
                          alignment: snapshot.data[index]["sender"] ==
                                  widget.auth.currentUser.uid
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: snapshot.data[index]["sender"] ==
                                    widget.auth.currentUser.uid
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                          DateFormat('hh:mm aa').format(DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  snapshot.data[index]
                                                      ["time"])),
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      Wrap(
                                        //mainAxisAlignment: MainAxisAlignment.center,
                                        // crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              forwardThisMessage(
                                                  socket, snapshot.data[index]);
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Icon(Icons.reply_rounded,
                                                  color: Colors.grey),
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
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              //   child: Text(snapshot.data.docs[index].data()["message"]),

                                              child:
                                                  makeChatMessageHead1WithEmoji(
                                                      context,
                                                      snapshot.data[index]),
                                            )),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        crossAxisAlignment: snapshot.data[index]
                                                    ["sender"] ==
                                                widget.auth.currentUser.uid
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
                                          Wrap(
                                            //   mainAxisAlignment: MainAxisAlignment.center,
                                            // crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Card(
                                                color: snapshot.data[index]
                                                            ["sender"] ==
                                                        widget.auth.currentUser
                                                            .uid
                                                    ? Colors.white
                                                    : Color.fromARGB(
                                                        255, 238, 246, 255),
                                                child: Container(
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        // child: Text(snapshot.data.docs[index].data()["message"]),
                                                        child:
                                                            makeChatMessageHead1WithEmoji(
                                                                context,
                                                                snapshot.data[
                                                                    index]))),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  forwardThisMessage(socket,
                                                      snapshot.data[index]);
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Transform(
                                                    alignment: Alignment.center,
                                                    transform:
                                                        Matrix4.rotationY(
                                                            math.pi),
                                                    child: Icon(
                                                      Icons.reply_rounded,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  // child: new RotationTransition(
                                                  //   turns: new AlwaysStoppedAnimation(180/ 360),
                                                  //   child:  Icon(Icons.reply_rounded,color: Colors.grey,)
                                                  // ),
                                                  //  child: RotatedBox(child: Icon(Icons.reply_rounded,color: Colors.grey,),quarterTurns: 1,),
                                                  //  child: Transform.rotate(angle: 0,child: Icon(Icons.reply_rounded,color: Colors.grey,),),
                                                ),
                                              ),
                                            ],
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

    // return  Container(height: MediaQuery.of(context).size.height-(70+( widget.showEmojiListSingle ? 370 : 70)),
    //   child: ListView.builder(
    //       controller: _scrollController,
    //       shrinkWrap: true,
    //       itemCount:
    //       chatData == null ? 0 : chatData.length,
    //       itemBuilder: (BuildContext context, int index) {
    //         return Padding(
    //           padding: const EdgeInsets.all(8.0),
    //           child: Stack(
    //             children: [
    //               Align(
    //                 alignment:chatData[index]["sender"] ==
    //                     widget.auth.currentUser.uid
    //                     ? Alignment.centerRight
    //                     : Alignment.centerLeft,
    //                 child: Padding(
    //                   padding: const EdgeInsets.all(0.0),
    //                   child:chatData[index]
    //                   ["sender"] ==
    //                       widget.auth.currentUser.uid
    //                       ? Column(
    //                     mainAxisAlignment:
    //                     MainAxisAlignment.center,
    //                     crossAxisAlignment:chatData[index]
    //                     ["sender"] ==
    //                         widget.auth.currentUser
    //                             .uid
    //                         ? CrossAxisAlignment.end
    //                         : CrossAxisAlignment.start,
    //                     children: [
    //                       Padding(
    //                         padding: const EdgeInsets
    //                             .fromLTRB(0, 0, 5, 0),
    //                         child: Text(
    //                           DateFormat('hh:mm aa')
    //                               .format(DateTime
    //                               .fromMillisecondsSinceEpoch(
    //                               chatData[index]
    //                               [
    //                               "time"])),
    //                           style: TextStyle(
    //                               fontSize: 12),
    //                         ),
    //                       ),
    //                       Card(
    //                         color:chatData[index]
    //                         [
    //                         "sender"] ==
    //                             widget.auth
    //                                 .currentUser.uid
    //                             ? Colors.white
    //                             : Color.fromARGB(
    //                             255, 238, 246, 255),
    //                         child: Container(
    //                             child: Padding(
    //                               padding:
    //                               const EdgeInsets.all(
    //                                   8.0),
    //                               //   child: Text(snapshot.data.docs[index].data()["message"]),
    //
    //                               child:
    //                               makeChatMessageHead1WithEmoji(
    //                                   context,
    //                                   chatData[index]
    //                               ),
    //                             )),
    //                       ),
    //                     ],
    //                   )
    //                       : Row(
    //                     mainAxisAlignment:
    //                     MainAxisAlignment.start,
    //                     crossAxisAlignment:
    //                     CrossAxisAlignment.start,
    //                     children: [
    //                       widget.chatBody["img"] == null
    //                           ? CircleAvatar(
    //                         radius: 10,
    //                       )
    //                           : CircleAvatar(
    //                         radius: 10,
    //                         backgroundImage:
    //                         NetworkImage(widget
    //                             .chatBody[
    //                         "img"]),
    //                       ),
    //                       Column(
    //                         mainAxisAlignment:
    //                         MainAxisAlignment
    //                             .center,
    //                         crossAxisAlignment:chatData
    //
    //                         [index]
    //                         [
    //                         "sender"] ==
    //                             widget.auth
    //                                 .currentUser.uid
    //                             ? CrossAxisAlignment.end
    //                             : CrossAxisAlignment
    //                             .start,
    //                         children: [
    //                           Padding(
    //                             padding:
    //                             const EdgeInsets
    //                                 .fromLTRB(
    //                                 5, 0, 0, 0),
    //                             child: Text(
    //                               DateFormat('hh:mm aa')
    //                                   .format(DateTime
    //                                   .fromMillisecondsSinceEpoch(chatData[
    //                               index]
    //                               [
    //                               "time"])),
    //                               style: TextStyle(
    //                                   fontSize: 12),
    //                             ),
    //                           ),
    //                           Card(
    //                             color: chatData[index]
    //                             [
    //                             "sender"] ==
    //                                 widget
    //                                     .auth
    //                                     .currentUser
    //                                     .uid
    //                                 ? Colors.white
    //                                 : Color.fromARGB(
    //                                 255,
    //                                 238,
    //                                 246,
    //                                 255),
    //                             child: Container(
    //                                 child: Padding(
    //                                   padding:
    //                                   const EdgeInsets
    //                                       .all(8.0),
    //                                   // child: Text(snapshot.data.docs[index].data()["message"]),
    //                                   child:
    //                                   makeChatMessageHead1WithEmoji(
    //                                       context,
    //                                       chatData [
    //                                       index]
    //                                   ),
    //                                 )),
    //                           ),
    //                         ],
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               )
    //             ],
    //           ),
    //         );
    //       }),
    // );
  }

  Future getData(dynamic cBody) async {
    String id = cBody["uid"] != null
        ? cBody["uid"]
        : (cBody["receiver"] == widget.auth.currentUser.uid
            ? cBody["sender"]
            : cBody["receiver"]);

    var url = Uri.parse(AppSettings().Api_link + 'getUserDetail?id=' + id);
    var response = await http.get(url);
    return jsonDecode(response.body);
  }

  Widget prepare(dynamic cBody) {}

  showFND() {}

  Widget showAddFndDLG(String id) {
    // return Text("Add as fnd is disabled");
    return Container(
      height: 125,
      child: Stack(
        children: [
          Positioned(
              top: 75,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                child: Center(
                    child: AddFndWidget(
                  fndID: id,
                  uid: widget.auth.currentUser.uid,
                )),
              ))
        ],
      ),
    );
  }

  void forwardThisMessage(IO.Socket socket, dynamic data) {
    Future<List> getFndList() async {
      var url = Uri.parse(AppSettings().Api_link +
          'getMyFnds?id=' +
          widget.auth.currentUser.uid);
      var response = await http.get(url);
      return jsonDecode(response.body);
    }

    Widget allfnds = Container(
      width: 300,
      child: FutureBuilder<List>(
          future: getFndList(),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data.length > 0) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    child: new InkWell(
                      onTap: () async {
                        //startChatBodyViewCreate({"uid": snapshot.data[index]});
                      },
                      child: ListTile(
                        tileColor: Color.fromARGB(255, 249, 252, 255),
                        leading: CommonFunctions(
                                auth: widget.auth,
                                onlineUser: onlineUser,
                                busyUser: busyUser,
                                awayUser: awayUser)
                            .prePareUserPhoto(uid: snapshot.data[index]),
                        // leading: prePareUserPhotoOld(
                        //     snapshot.data.docs[index]["fnd"]),
                        // title: getNameFromIdR(snapshot.data[index], false,
                        //     widget.firestore, widget.auth),
                        title: FetchUserNameWidget(
                          uid: snapshot.data[index],
                        ),
                        trailing: InkWell(
                          onTap: () {
                            //send now
                            String uid = FirebaseAuth.instance.currentUser.uid;
                            String fnd = snapshot.data[index];

                            String room = createRoomName(uid, fnd);

                            dynamic me = {
                              "time": DateTime.now().millisecondsSinceEpoch,
                              "message": data["message"],
                              "type": data["type"],
                              "fname": data["fname"],
                              "sender": uid,
                              "receiver": fnd
                            };

                            socket.emit("saveMesage",
                                {"fileName": room, "message": me});
                            print({"fileName": room, "message": me});
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Send",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),

                        subtitle: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text("Send Message"),
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(child: Text("No Contacts"));
            }
          }),
    );
    Widget okButton = FlatButton(
      child: Text("Forward"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget cancelBtn = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Forward message"),
      content: allfnds,
      actions: [
        // okButton,
        cancelBtn
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    // showDialog<void>(context: context, builder: (context) => Scaffold(body: allfnds,));
  }
}

class SimpleProfileView extends StatefulWidget {
  String selfId;
  String fndId;
  FirebaseAuth auth;
  IO.Socket socket;
  String room ;

  SimpleProfileView({this.socket,this.room,this.auth, this.selfId, this.fndId});

  @override
  _SimpleProfileViewState createState() => _SimpleProfileViewState();
}

class _SimpleProfileViewState extends State<SimpleProfileView> {
  Future getData(String uid) async {
    String id = uid;
    var url = Uri.parse(AppSettings().Api_link+'getUserDetail?id=' + id);
    var response = await http.get(url);
    return jsonDecode(response.body);
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 00, 0, 0),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder(
                // Initialize FlutterFire:
                  future: getData(widget.fndId),
                  builder: (context, snapshot) {
                    Widget im ;
                    Widget name = Text("Please wait") ;
                    im =   Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child:Image.asset("assets/user_photo.jpg") ,
                    );
                    if (snapshot.hasData && snapshot.data != null && snapshot.data["photo"]!=null &&snapshot.data["photo"].toString().length>0) {

                      im =  Align(alignment: Alignment.center,
                        child: Container(
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          child:Image.network(base+snapshot.data["photo"],fit: BoxFit.cover,) ,
                        ),
                      );
                      name =   Align(alignment: Alignment.bottomLeft,
                        child:Container(width: MediaQuery.of(context).size.width,decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.5),
                                Colors.transparent,
                              ],
                            )),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(snapshot.data["name"],style: TextStyle(color: Colors.white),),
                          ),
                        ),
                      );


                    } else {


                    }
                    return Container( height: 200,
                      child: Stack(
                        children: [
                          im,


                          Align(alignment: Alignment.topLeft,
                            child:InkWell(onTap: (){
                              Navigator.pop(context);
                            },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 38, 8, 8),
                                child: Container(width: 50,height: 50,decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25)
                                ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(00.0),
                                      child: Icon(Icons.chevron_left),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        name,



                        ],
                      ),
                    );
                  }),
              Center(
                  child: AddFndWidget(
                    fndID: widget.fndId,
                    uid: widget.selfId,
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Shared Media",style: TextStyle(color: Theme.of(context).primaryColor),),
              ),
              getChatAllAttachments(socket: widget.socket,room: widget.room),
            ],
          ),
        ),
      ),
    );
  }
}

class SimpleGrpView extends StatefulWidget {
  String selfId;
  String fndId;
  FirebaseAuth auth;
  IO.Socket socket;
  String room ;

  SimpleGrpView({this.socket,this.room,this.auth, this.selfId, this.fndId});

  @override
  _SimpleGrpViewState createState() => _SimpleGrpViewState();
}

class _SimpleGrpViewState extends State<SimpleGrpView> {
  Future getData(String uid) async {
    String id = uid;
    var url = Uri.parse(AppSettings().Api_link+'getUserDetail?id=' + id);
    var response = await http.get(url);
    return jsonDecode(response.body);
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 00, 0, 0),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder(
                // Initialize FlutterFire:
                  future: getData(widget.fndId),
                  builder: (context, snapshot) {
                    Widget im ;
                    Widget name = Text("Please wait") ;
                    im =   Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child:Image.asset("assets/user_photo.jpg") ,
                    );
                    if (snapshot.hasData && snapshot.data != null && snapshot.data["photo"]!=null &&snapshot.data["photo"].toString().length>0) {

                      im =  Align(alignment: Alignment.center,
                        child: Container(
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          child:Image.network(base+snapshot.data["photo"],fit: BoxFit.cover,) ,
                        ),
                      );
                      name =   Align(alignment: Alignment.bottomLeft,
                        child:Container(width: MediaQuery.of(context).size.width,decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.5),
                                Colors.transparent,
                              ],
                            )),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(snapshot.data["name"],style: TextStyle(color: Colors.white),),
                          ),
                        ),
                      );


                    } else {


                    }
                    return Container( height: 200,
                      child: Stack(
                        children: [
                          im,


                          Align(alignment: Alignment.topLeft,
                            child:InkWell(onTap: (){
                              Navigator.pop(context);
                            },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 38, 8, 8),
                                child: Container(width: 50,height: 50,decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25)
                                ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(00.0),
                                      child: Icon(Icons.chevron_left),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          name,



                        ],
                      ),
                    );
                  }),
              Center(
                  child: AddFndWidget(
                    fndID: widget.fndId,
                    uid: widget.selfId,
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Shared Media",style: TextStyle(color: Theme.of(context).primaryColor),),
              ),
              getChatAllAttachments(socket: widget.socket,room: widget.room),
            ],
          ),
        ),
      ),
    );
  }
}


Widget getChatAllAttachments({IO.Socket socket,String room}) {
  socket.on(room, (data) {
    if (true && data["room"] == room) {
      ChatDataloadedStream.getInstance().dataReload(data["data"]);
    } else {
      print("blocked");
    }

    print("downloaded");
    print(data.length.toString());
  });

  socket.emit("getMesage", {"fileName": room});
  // Timer.periodic(Duration(milliseconds: 300), (timer) async {
  //   if (mounted) {
  //     var url = Uri.parse('https://api.maulaji.com/getMessage?id='+widget.room);
  //     var response = await http.get(url, );
  //     setState(() {
  //       chatData = jsonDecode(response.body);
  //     });
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if(_scrollController.hasClients){
  //         _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.ease);
  //         //_scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  //       }
  //     });
  //   }});

  return StreamBuilder<List>(
    // Initialize FlutterFire:
    //  future: Firebase.initializeApp(),
      stream: ChatDataloadedStream.getInstance().outData,
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data.length > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // if (_scrollController.hasClients) {
            //   _scrollController.animateTo(
            //       _scrollController.position.maxScrollExtent,
            //       duration: Duration(milliseconds: 300),
            //       curve: Curves.ease);
            //   //_scrollController.jumpTo(_scrollController.position.maxScrollExtent);
            // }
          });
          List<Widget> widgets = [];
          for(int i = 0 ; i< snapshot.data.length ; i ++){
            if(snapshot.data[i]["type"]!=null && snapshot.data[i]["type"]!="txt"){
              widgets.add(Padding(padding: EdgeInsets.all(5),child: makeChatMessageAttachmentHead(context,snapshot.data[i]),));
            }
           // widgets.add(Container(width: 70,height: 70,child: Center(child: Text(snapshot.data[i]["type"]),),));
          }

          return Wrap(children: widgets,);
        } else {
          return Center(child: Text("Send  your first message"));
        }
      });

  // return  Container(height: MediaQuery.of(context).size.height-(70+( widget.showEmojiListSingle ? 370 : 70)),
  //   child: ListView.builder(
  //       controller: _scrollController,
  //       shrinkWrap: true,
  //       itemCount:
  //       chatData == null ? 0 : chatData.length,
  //       itemBuilder: (BuildContext context, int index) {
  //         return Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Stack(
  //             children: [
  //               Align(
  //                 alignment:chatData[index]["sender"] ==
  //                     widget.auth.currentUser.uid
  //                     ? Alignment.centerRight
  //                     : Alignment.centerLeft,
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(0.0),
  //                   child:chatData[index]
  //                   ["sender"] ==
  //                       widget.auth.currentUser.uid
  //                       ? Column(
  //                     mainAxisAlignment:
  //                     MainAxisAlignment.center,
  //                     crossAxisAlignment:chatData[index]
  //                     ["sender"] ==
  //                         widget.auth.currentUser
  //                             .uid
  //                         ? CrossAxisAlignment.end
  //                         : CrossAxisAlignment.start,
  //                     children: [
  //                       Padding(
  //                         padding: const EdgeInsets
  //                             .fromLTRB(0, 0, 5, 0),
  //                         child: Text(
  //                           DateFormat('hh:mm aa')
  //                               .format(DateTime
  //                               .fromMillisecondsSinceEpoch(
  //                               chatData[index]
  //                               [
  //                               "time"])),
  //                           style: TextStyle(
  //                               fontSize: 12),
  //                         ),
  //                       ),
  //                       Card(
  //                         color:chatData[index]
  //                         [
  //                         "sender"] ==
  //                             widget.auth
  //                                 .currentUser.uid
  //                             ? Colors.white
  //                             : Color.fromARGB(
  //                             255, 238, 246, 255),
  //                         child: Container(
  //                             child: Padding(
  //                               padding:
  //                               const EdgeInsets.all(
  //                                   8.0),
  //                               //   child: Text(snapshot.data.docs[index].data()["message"]),
  //
  //                               child:
  //                               makeChatMessageHead1WithEmoji(
  //                                   context,
  //                                   chatData[index]
  //                               ),
  //                             )),
  //                       ),
  //                     ],
  //                   )
  //                       : Row(
  //                     mainAxisAlignment:
  //                     MainAxisAlignment.start,
  //                     crossAxisAlignment:
  //                     CrossAxisAlignment.start,
  //                     children: [
  //                       widget.chatBody["img"] == null
  //                           ? CircleAvatar(
  //                         radius: 10,
  //                       )
  //                           : CircleAvatar(
  //                         radius: 10,
  //                         backgroundImage:
  //                         NetworkImage(widget
  //                             .chatBody[
  //                         "img"]),
  //                       ),
  //                       Column(
  //                         mainAxisAlignment:
  //                         MainAxisAlignment
  //                             .center,
  //                         crossAxisAlignment:chatData
  //
  //                         [index]
  //                         [
  //                         "sender"] ==
  //                             widget.auth
  //                                 .currentUser.uid
  //                             ? CrossAxisAlignment.end
  //                             : CrossAxisAlignment
  //                             .start,
  //                         children: [
  //                           Padding(
  //                             padding:
  //                             const EdgeInsets
  //                                 .fromLTRB(
  //                                 5, 0, 0, 0),
  //                             child: Text(
  //                               DateFormat('hh:mm aa')
  //                                   .format(DateTime
  //                                   .fromMillisecondsSinceEpoch(chatData[
  //                               index]
  //                               [
  //                               "time"])),
  //                               style: TextStyle(
  //                                   fontSize: 12),
  //                             ),
  //                           ),
  //                           Card(
  //                             color: chatData[index]
  //                             [
  //                             "sender"] ==
  //                                 widget
  //                                     .auth
  //                                     .currentUser
  //                                     .uid
  //                                 ? Colors.white
  //                                 : Color.fromARGB(
  //                                 255,
  //                                 238,
  //                                 246,
  //                                 255),
  //                             child: Container(
  //                                 child: Padding(
  //                                   padding:
  //                                   const EdgeInsets
  //                                       .all(8.0),
  //                                   // child: Text(snapshot.data.docs[index].data()["message"]),
  //                                   child:
  //                                   makeChatMessageHead1WithEmoji(
  //                                       context,
  //                                       chatData [
  //                                       index]
  //                                   ),
  //                                 )),
  //                           ),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               )
  //             ],
  //           ),
  //         );
  //       }),
  // );
}
makeChatMessageAttachmentHead(BuildContext context, dynamic data) {
  double w = MediaQuery.of(context).size.width;
  double w2 = w/4;
  // return Text(data["message"]);

  String base = "https://talk.maulaji.com/";
  if (data["type"] == null) {
    return SelectableText(data["message"]);
  } else if (data["type"] != null && data["type"] == "txt")
    return SelectableText(data["message"]);
  else if (data["type"] != null) if (data["type"] == "img" ||
      data["type"] == "png" ||
      data["type"] == "bmp" ||
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
        height: w2-10,
        width: w2-10,fit: BoxFit.cover,
      ),
    );
  else if (data["type"] != null) if (data["type"] == "vdo" ||
      data["type"] == "mp4" ||
      data["type"] == "mov" ||
      data["type"] == "avi" ||
      data["type"] == "3gp" ||
      data["type"] == "mpeg4")
    return Container(
        width: w2-10,
        height: w2-10,
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
        height: w2-10,
        width: w2-10,
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