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
import 'package:maulajimessenger/Screens/chatThread.dart';
import 'package:maulajimessenger/Screens/logged_in_home.dart';
import 'package:maulajimessenger/services/Settings.dart';
import 'package:maulajimessenger/services/Signal.dart';
import 'package:maulajimessenger/services/chat_data_stream.dart';
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
import 'package:audioplayers/audio_cache.dart';
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
import 'package:maulajimessenger/services/functions.dart';
import 'package:maulajimessenger/services/Auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;

class SectorOne extends StatefulWidget {
  FirebaseAuth auth;
  bool showMiniProfile = false;
  bool isSearchModeOn = false;
  String searchKey = "";
  int selectedTabMenu = 0;

  int selectedItem = 0;

  int mobileViewLevel = 0;

  dynamic chatBody;

  Widget chatBodyWidget;
  void Function(Widget) chatWidgetUpdate;
  List<String> allStatus = ["Online", "Away", "Busy", "Offline"];

  bool isMobileView;

  double width = 0;
  IO.Socket socket;

  SectorOne(
      {this.socket,
      this.width,
      this.isMobileView,
      this.auth,
      this.chatWidgetUpdate});

  @override
  _SectorOneState createState() => _SectorOneState();
}

class _SectorOneState extends State<SectorOne> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("user sector");

    // wiget.socket.emit("saveProfileData",{"uid":widget.auth.currentUser.uid,"name":"mukul"});
    widget.socket.emit("getUserProfile", {"uid": widget.auth.currentUser.uid});
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey _menuKey = new GlobalKey();
    TextEditingController searchController = new TextEditingController();
    final button = new PopupMenuButton(
      key: _menuKey,
      itemBuilder: (_) => <PopupMenuItem<String>>[
        //  new PopupMenuItem<String>(child: const Text('Plain Web'), value: 'web'),
        new PopupMenuItem<String>(child: const Text('Logout'), value: 'logout'),
      ],
      onSelected: (String choice) async {
        if (choice == "logout") {
          widget.auth.signOut();
        }
        if (choice == "profile") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfileUpdate(auth: widget.auth)));
        }
        if (choice == "grp") {
          //GroupCall

          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) =>  WillPopScope(
          //           onWillPop: () async => false,
          //           child: GroupCall(
          //               room_id: "grp",
          //               containsVideo: true,
          //               ownID: widget.auth.currentUser.uid,
          //               partnerid:"",
          //               isCaller:
          //               true,
          //               firestore:
          //               widget.firestore),
          //
          //         )));
          // }
          // if (choice == "web") {
          //   //GroupCall
          //   Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) =>  WillPopScope(
          //             onWillPop: () async => false,
          //             child: PlainWebCall(
          //                 containsVideo: true,
          //                 ownID:"p"+widget.sharedPreferences.getString("patient_id"),
          //                 partnerid:"d162",
          //                 isCaller:
          //                 true,
          //                 firestore:
          //                 widget.firestore),
          //
          //           )));
        }
      },
    );
    searchItemClicked(dynamic data) {
      startChatBodyViewCreate(data);
    }

    searchClosed() {
      setState(() {
        widget.isSearchModeOn = false;
      });
    }

    return Container(
      width: widget.width,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: MediaQuery.of(context).size.height,
              color: Color.fromARGB(255, 238, 246, 255),
              child: Wrap(
                //shrinkWrap: true,
                children: [
                  Container(
                    height: 70,
                    color: Color.fromARGB(255, 238, 246, 255),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                      child: Container(
                        height: 50,
                        child: Center(
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      widget.showMiniProfile = true;
                                    });
                                  },
                                  child: Center(
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 10, 0),
                                          // child: prePareUserPhoto(widget.auth,
                                          //     widget.auth.currentUser.uid),
                                          child: CommonFunctions(
                                                  auth: widget.auth,
                                                  onlineUser: onlineUser,
                                                  busyUser: busyUser,
                                                  awayUser: awayUser)
                                              .prePareUserPhotoSelf(
                                                  uid: widget
                                                      .auth.currentUser.uid),

                                          // child: CircleAvatar(radius: 18,backgroundImage: NetworkImage("https://images-na.ssl-images-amazon.com/images/I/71Y2Ov9rHaL._SL1500_.jpg",)),
                                        ),
                                        //getNameFromIdR
                                        FetchUserNameWidget(
                                          uid: widget.auth.currentUser.uid,
                                        ),

                                        // CommonFunctions(
                                        //         firestore: widget.firestore,
                                        //         auth: widget.auth,
                                        //         onlineUser: onlineUser)
                                        //     .getNameFromIdR(
                                        //         style: false,
                                        //         id: widget.auth.currentUser.uid)

                                        //Text(widget.sharedPreferences.get("uphoto")),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: button,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  widget.isSearchModeOn == false
                      ? Column(
                          children: [
                            InkWell(
                              onTap: () {
                                //pop up search box here
                                SimpleDialog d =     SimpleDialog(
                                  title: Text('Set backup account'),
                                  children: [
                                    SearchPeopleActivity(
                                      auth: widget.auth,
                                      clicked: searchItemClicked,
                                      searchClosed: searchClosed,
                                    )
                                  ],
                                );

                                AlertDialog alert = AlertDialog(
                                 // title: Text("Add New"),
                                  content: Container(width: MediaQuery.of(context).size.width>1000?400:MediaQuery.of(context).size.width,height: 400,
                                    child: SearchPeopleActivity(
                                      auth: widget.auth,
                                      clicked: searchItemClicked,
                                      searchClosed: searchClosed,
                                    ),
                                  ),

                                );
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return alert;
                                  },
                                );

                                // showDialog<void>(context: context, builder: (context) =>  Container(width: 400,height: 400,
                                //   child:d,
                                // ));
                                // showDialog<void>(context: context, builder: (context) =>  Container(width: 400,
                                //   child: SearchPeopleActivity(
                                //     auth: widget.auth,
                                //     clicked: searchItemClicked,
                                //     searchClosed: searchClosed,
                                //   ),
                                // ));
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) =>
                                //             SearchPeopleActivity(
                                //               auth: widget.auth,
                                //               clicked: searchItemClicked,
                                //               searchClosed: searchClosed,
                                //             )));

                                // setState(() {
                                //   widget.isSearchModeOn = true;
                                // });
                              },
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(7, 10, 7, 10),
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    3.0) //                 <--- border radius here
                                                ),
                                          ),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Row(
                                              children: [
                                                Center(
                                                    child: Icon(Icons.search)),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          10, 0, 0, 0),
                                                  child: Center(
                                                      child: Text("Search")),
                                                ),
                                              ],
                                            ),
                                          )),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: Container(
                                height: 50,
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                widget.selectedTabMenu = 0;
                                              });
                                            },
                                            child: Column(
                                              children: [
                                                Icon(Icons.chat,
                                                    color:
                                                        widget.selectedTabMenu ==
                                                                0
                                                            ? Theme.of(context)
                                                                .primaryColor
                                                            : Colors.grey),
                                                Center(
                                                    child: Text(
                                                  "Chat",
                                                  style: TextStyle(
                                                      color:
                                                          widget.selectedTabMenu ==
                                                                  0
                                                              ? Theme.of(
                                                                      context)
                                                                  .primaryColor
                                                              : Colors.grey),
                                                )),
                                              ],
                                            ))),
                                    Expanded(
                                        child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                widget.selectedTabMenu = 1;
                                              });
                                            },
                                            child: Column(
                                              children: [
                                                Icon(Icons.contacts,
                                                    color:
                                                        widget.selectedTabMenu ==
                                                                1
                                                            ? Theme.of(context)
                                                                .primaryColor
                                                            : Colors.grey),
                                                Center(
                                                    child: Text(
                                                  "Contacts",
                                                  style: TextStyle(
                                                      color:
                                                          widget.selectedTabMenu ==
                                                                  1
                                                              ? Theme.of(
                                                                      context)
                                                                  .primaryColor
                                                              : Colors.grey),
                                                )),
                                              ],
                                            ))),
                                    Expanded(
                                        child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                widget.selectedTabMenu = 2;
                                              });
                                            },
                                            child: Column(
                                              children: [
                                                Icon(Icons.group,
                                                    color:
                                                        widget.selectedTabMenu ==
                                                                2
                                                            ? Theme.of(context)
                                                                .primaryColor
                                                            : Colors.grey),
                                                Center(
                                                    child: Text(
                                                  "Group Chat",
                                                  style: TextStyle(
                                                      color:
                                                          widget.selectedTabMenu ==
                                                                  2
                                                              ? Theme.of(
                                                                      context)
                                                                  .primaryColor
                                                              : Colors.grey),
                                                )),
                                              ],
                                            ))),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 1,
                                color: Colors.grey,
                              ),
                            ),
                            getSmallTab(widget.width, widget.isMobileView),
                          ],
                        )
                      : Container(
                          width: widget.isMobileView
                              ? MediaQuery.of(context).size.width
                              : 349,
                          child: SearchPeopleActivity(
                            auth: widget.auth,
                            clicked: searchItemClicked,
                            searchClosed: searchClosed,
                          )),
                ],
              ),
            ),
          ),
          widget.showMiniProfile
              ? Positioned(
                  left: 0,
                  right: 0,
                  top: 60,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 15, 8, 15),
                    child: Card(
                      color: Colors.white,
                      elevation: 8,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 80,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Image.asset(
                                      "assets/talkapp.png",
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        widget.showMiniProfile = false;
                                      });
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Icon(Icons.close)),
                                  ),
                                )
                              ],
                            ),
                          ),
                          // ListTile(
                          //   title: Padding(
                          //     padding: EdgeInsets.all(0),
                          //     child: Image.asset(
                          //       "assets/maulaji_sqr.png",
                          //       height: 50,
                          //       width: ,
                          //       fit: BoxFit.cover,
                          //     ),
                          //   ),
                          //   onTap: () {
                          //     setState(() {
                          //       widget.showMiniProfile = false;
                          //     });
                          //   },
                          //   trailing: Icon(Icons.close),
                          // ),
                          Divider(),
                          Center(
                            child: Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 10, 0),
                                  child: CommonFunctions(
                                          auth: widget.auth,
                                          onlineUser: onlineUser,
                                          busyUser: busyUser,
                                          awayUser: awayUser)
                                      .prePareUserPhoto(
                                          uid: widget.auth.currentUser.uid),
                                  // child: prePareUserPhoto(widget.auth,
                                  //     widget.auth.currentUser.uid)
                                ),

                                // child: CircleAvatar(radius: 18,backgroundImage: NetworkImage("https://images-na.ssl-images-amazon.com/images/I/71Y2Ov9rHaL._SL1500_.jpg",)),

                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        getNameFromIdWithStyle(
                                            widget.auth.currentUser.uid,
                                            TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                            widget.auth),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 0, 0, 0),
                                          child: InkWell(
                                            onTap: () {
                                              showD(String n) {
                                                final AlertDialog dialog =
                                                    AlertDialog(
                                                  title: Text(
                                                      'Update display name'),
                                                  content: TextFormField(
                                                    onChanged: (val) async {
                                                      var url = Uri.parse(
                                                          AppSettings()
                                                                  .Api_link +
                                                              'editUserName?id=' +
                                                              widget
                                                                  .auth
                                                                  .currentUser
                                                                  .uid +
                                                              "&&name=" +
                                                              val);
                                                      var response = await http.get(url);
                                                    },
                                                    initialValue: "",
                                                    decoration: InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.all(10),
                                                    ),
                                                  ),
                                                  actions: [
                                                    FlatButton(
                                                      textColor:
                                                          Color(0xFF6200EE),
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child: Text('Done'),
                                                    ),
                                                  ],
                                                );

                                                //dialog
                                                showDialog<void>(context: context, builder: (context) => dialog);
                                              }

                                        //  dynamic  a = await    getUserInfo(widget.auth.currentUser.uid);
                                            //  showD(a["name"]);
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 0, 5, 0),
                                              child: Text(
                                                "Change",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                      child: Text(
                                          widget.auth.currentUser.email !=
                                                      null &&
                                                  widget.auth.currentUser.email
                                                          .length >
                                                      0
                                              ? (widget.auth.currentUser.email)
                                              : (widget.auth.currentUser
                                                  .phoneNumber)),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        FilePickerResult result =
                                            await FilePicker.platform
                                                .pickFiles();

                                        if (result != null) {
                                          PlatformFile file =
                                              result.files.first;

                                          print(file.name);
                                          // print(file.bytes);
                                          // _base64 = BASE64.encode(response.bodyBytes);
                                          String base =
                                              base64.encode(file.bytes);

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
                                          dynamic res =
                                              jsonDecode(response.body);
                                          if (res["status"]) {
                                            var url = Uri.parse(AppSettings()
                                                    .Api_link +
                                                'editUserPhoto?id=' +
                                                widget.auth.currentUser.uid +
                                                "&&photo=" +
                                                res["path"]);
                                            var response = await http.get(url);

                                            print(
                                                'Response body: ${response.body}');
                                            //res["path"]
                                            // widget.firestore
                                            //     .collection("users")
                                            //     .where("uid",
                                            //         isEqualTo: widget
                                            //             .auth.currentUser.uid)
                                            //     .get()
                                            //     .then((value) {
                                            //   widget.firestore
                                            //       .collection("users")
                                            //       .doc(value.docs.first.id)
                                            //       .update(
                                            //           {"photo": res["path"]});
                                            // });
                                          } else {
                                            print("could not save");
                                          }
                                        } else {
                                          // User canceled the picker
                                        }
                                      },
                                      child: Text(
                                        "Change Photo",
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                    ),
                                  ],
                                )

                                //Text(widget.sharedPreferences.get("uphoto")),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              SharedPreferences prefs;
                              Future<SharedPreferences> _prefs =
                                  SharedPreferences.getInstance();
                              prefs = await _prefs;
                              prefs.setString("uStatus", "online");
                              SelfStatusStream.getInstance()
                                  .dataReload("online");
                            },
                            child: Wrap(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Online"),
                                ),
                                StreamBuilder(
                                    stream:
                                        SelfStatusStream.getInstance().outData,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<String> snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        print("some stream");
                                        print(snapshot.data);
                                        return snapshot.data == "online"
                                            ? Icon(Icons.done)
                                            : Container(
                                                height: 0,
                                                width: 0,
                                              );
                                      } else
                                        return FutureBuilder(
                                            future: getUserStatus(),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<String>
                                                    snapshot) {
                                              if (snapshot.hasData &&
                                                  snapshot.data != null) {
                                                print("some stream");
                                                print(snapshot.data);
                                                return snapshot.data == "online"
                                                    ? Icon(Icons.done)
                                                    : Container(
                                                        height: 0,
                                                        width: 0,
                                                      );
                                              } else
                                                return Text("");
                                            });
                                    }),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              SharedPreferences prefs;
                              Future<SharedPreferences> _prefs =
                                  SharedPreferences.getInstance();
                              prefs = await _prefs;
                              prefs.setString("uStatus", "away");
                              SelfStatusStream.getInstance().dataReload("away");
                            },
                            child: Wrap(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Away"),
                                ),
                                StreamBuilder(
                                    stream:
                                        SelfStatusStream.getInstance().outData,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<String> snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        print("some stream");
                                        print(snapshot.data);
                                        return snapshot.data == "away"
                                            ? Icon(Icons.done)
                                            : Container(
                                                height: 0,
                                                width: 0,
                                              );
                                      } else
                                        return FutureBuilder(
                                            future: getUserStatus(),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<String>
                                                    snapshot) {
                                              if (snapshot.hasData &&
                                                  snapshot.data != null) {
                                                print("some stream");
                                                print(snapshot.data);
                                                return snapshot.data == "away"
                                                    ? Icon(Icons.done)
                                                    : Container(
                                                        height: 0,
                                                        width: 0,
                                                      );
                                              } else
                                                return Text("");
                                            });
                                    }),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              SharedPreferences prefs;
                              Future<SharedPreferences> _prefs =
                                  SharedPreferences.getInstance();
                              prefs = await _prefs;
                              prefs.setString("uStatus", "busy");
                              SelfStatusStream.getInstance().dataReload("busy");
                            },
                            child: Wrap(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Busy"),
                                ),
                                StreamBuilder(
                                    stream:
                                        SelfStatusStream.getInstance().outData,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<String> snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        print("some stream");
                                        print(snapshot.data);
                                        return snapshot.data == "busy"
                                            ? Icon(Icons.done)
                                            : Container(
                                                height: 0,
                                                width: 0,
                                              );
                                      } else
                                        return FutureBuilder(
                                            future: getUserStatus(),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<String>
                                                    snapshot) {
                                              if (snapshot.hasData &&
                                                  snapshot.data != null) {
                                                print("some stream");
                                                print(snapshot.data);
                                                return snapshot.data == "busy"
                                                    ? Icon(Icons.done)
                                                    : Container(
                                                        height: 0,
                                                        width: 0,
                                                      );
                                              } else
                                                return Text("");
                                            });
                                    }),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              SharedPreferences prefs;
                              Future<SharedPreferences> _prefs =
                                  SharedPreferences.getInstance();
                              prefs = await _prefs;
                              prefs.setString("uStatus", "offline");
                              SelfStatusStream.getInstance()
                                  .dataReload("offline");
                            },
                            child: Wrap(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Offline"),
                                ),
                                StreamBuilder(
                                    stream:
                                        SelfStatusStream.getInstance().outData,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<String> snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        print("some stream");
                                        print(snapshot.data);
                                        return snapshot.data == "offline"
                                            ? Icon(Icons.done)
                                            : Container(
                                                height: 0,
                                                width: 0,
                                              );
                                      } else
                                        return FutureBuilder(
                                            future: getUserStatus(),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<String>
                                                    snapshot) {
                                              if (snapshot.hasData &&
                                                  snapshot.data != null) {
                                                print("some stream");
                                                print(snapshot.data);
                                                return snapshot.data ==
                                                        "offline"
                                                    ? Icon(Icons.done)
                                                    : Container(
                                                        height: 0,
                                                        width: 0,
                                                      );
                                              } else
                                                return Text("");
                                            });
                                    }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
              : Container(
                  height: 0,
                  width: 0,
                ),
        ],
      ),
    );
  }

  getSmallTab(double width, bool isMobile) {
    doSomething(data) {
      print("dosomethingstart");
      print(data);
      print("dosomethingsend");

      startChatBodyViewCreate({"uid": data});
    }

    if (widget.selectedTabMenu == 0) {
      widget.socket.on(widget.auth.currentUser.uid, (data) {
        print(data.toString());
        if (data != "0" && data.toString() != "{}") {
          List dataL = [];
          data.forEach((k, v) {
            dataL.add({"uid": k, "data": v});
          });

          if (dataL != null && dataL.length > 0)
            LastMessagesStream.getInstance().dataReload(dataL);
          else {
            List em = [];
            LastMessagesStream.getInstance().dataReload(em);
          }
        }
      });

      widget.socket.emit("getLastMesage", {"id": widget.auth.currentUser.uid});

      Future getData() async {
        var url = Uri.parse(AppSettings().Api_link +
            'getLastMesage?id=' +
            widget.auth.currentUser.uid);
        var response = await http.get(url);
        List dataL = [];
        dynamic raw = jsonDecode(response.body);
        raw.forEach((k, v) {
          dataL.add({"uid": k, "data": v});
        });
        print(response.body);
        return dataL;
      }

      //  return  Text(MediaQuery.of(context).size.width.toString());

      return LastChatWIdgetStream(
        width: width,
        showMobileView: MediaQuery.of(context).size.width > 499 ? false : true,
        doSomething: doSomething,
      );

      return FutureBuilder<dynamic>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              // return Text(snapshot.data.toString());
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
                              doSomething(snapshot.data[index]["uid"]);
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
      return LastChatHistoryWidget(
        //  widgetparent: widget,
        callback: doSomething,

        firebaseAuth: widget.auth,
      );
    } else if (widget.selectedTabMenu == 1) {
      Future<List> getFndList() async {
        var url = Uri.parse(AppSettings().Api_link +
            'getMyFnds?id=' +
            widget.auth.currentUser.uid);
        var response = await http.get(url);
        return jsonDecode(response.body);
      }

      return Container(
        width: width,
        child: FutureBuilder<List>(
            future: getFndList(),
            builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
              if (snapshot.hasData &&
                  snapshot.data != null &&
                  snapshot.data.length > 0) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      child: new InkWell(
                        onTap: () async {
                          startChatBodyViewCreate(
                              {"uid": snapshot.data[index]});
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

      widget.socket.on(widget.auth.currentUser.uid + "_fnds", (data) {
        List fndIds = [];
        if (data.toString() != "{}") {
          data.forEach((k, v) {
            fndIds.add(k);
          });
          AllFndListStream.getInstance().dataReload(fndIds);
        }
      });
      AppSignal()
          .initSignal()
          .emit("getMyFnds", {"id": widget.auth.currentUser.uid});
      return StreamBuilder<List>(
          stream: AllFndListStream.getInstance().outData,
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (snapshot.hasData && snapshot.data.length > 0) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    child: new InkWell(
                      onTap: () async {
                        startChatBodyViewCreate({"uid": snapshot.data[index]});
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

                        subtitle: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(snapshot.data[index]),
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(child: Text("No Contacts"));
            }
          });
    } else if (widget.selectedTabMenu == 2) {
      return Container(
        width: width,
        child: Column(
          children: [
            InkWell(
              child: ListTile(
                onTap: () {
                  final SimpleDialog dialog1 = SimpleDialog(
                    title: Text('Add Participents'),
                    children: [
                      Container(
                        height: 400,
                        child: FutureBuilder<List>(
                            future: getMyFriends(),
                            builder: (BuildContext context,
                                AsyncSnapshot<List> snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data != null &&
                                  snapshot.data.length > 0) {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: snapshot.data.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return ListTile(
                                      onTap: () {
                                        setState(() {});
                                      },
                                      tileColor:
                                          Color.fromARGB(255, 249, 252, 255),
                                      leading: CommonFunctions(
                                              auth: widget.auth,
                                              onlineUser: onlineUser,
                                              busyUser: busyUser,
                                              awayUser: awayUser)
                                          .prePareUserPhoto(
                                              uid: snapshot.data[index]["fnd"]),
                                      // title: getNameFromIdR(
                                      //     snapshot.data.docs[index]["fnd"],
                                      //     false,
                                      //     widget.firestore,
                                      //     widget.auth),

                                      title: FetchUserNameWidget(
                                        uid: snapshot.data[index]["fnd"],
                                      ),

                                      subtitle: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text("Add"),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return Center(child: Text("No Friends"));
                              }
                            }),

                        // child: StreamBuilder<QuerySnapshot>(
                        //     stream: widget.firestore
                        //         .collection("fnd")
                        //         .where("self",
                        //             isEqualTo: widget.auth.currentUser.uid)
                        //         .snapshots(),
                        //     builder: (BuildContext context,
                        //         AsyncSnapshot<QuerySnapshot> snapshot) {
                        //       if (snapshot.hasData &&
                        //           snapshot.data.size > 0 &&
                        //           snapshot.data.docs.length > 0) {
                        //         return SizedBox(
                        //           height: 400,
                        //           child: ListView.builder(
                        //             shrinkWrap: true,
                        //             itemCount: snapshot.data.docs.length,
                        //             itemBuilder:
                        //                 (BuildContext context, int index) {
                        //               return ListTile(
                        //                 onTap: () {
                        //                   setState(() {});
                        //                 },
                        //                 tileColor:
                        //                     Color.fromARGB(255, 249, 252, 255),
                        //                 leading: CommonFunctions(
                        //                         firestore: widget.firestore,
                        //                         auth: widget.auth,
                        //                         onlineUser: onlineUser,
                        //                         busyUser: busyUser,
                        //                         awayUser: awayUser)
                        //                     .prePareUserPhoto(
                        //                         uid: snapshot.data.docs[index]
                        //                             ["fnd"]),
                        //                 // title: getNameFromIdR(
                        //                 //     snapshot.data.docs[index]["fnd"],
                        //                 //     false,
                        //                 //     widget.firestore,
                        //                 //     widget.auth),
                        //
                        //                 title: FetchUserNameWidget(
                        //                   uid: snapshot.data.docs[index]["fnd"],
                        //                 ),
                        //
                        //                 subtitle: Padding(
                        //                   padding: const EdgeInsets.all(5.0),
                        //                   child: Text("Add"),
                        //                 ),
                        //               );
                        //             },
                        //           ),
                        //         );
                        //
                        //         return Center(
                        //             child: Text("Total fnd " +
                        //                 snapshot.data.docs.length.toString()));
                        //       } else {
                        //         return Center(child: Text("No Contacts"));
                        //       }
                        //     }),
                      )
                    ],
                  );

                  done(List list) {
                    print("returned " + list.length.toString());
                    Navigator.pop(context);
                    grpCreated(String name) async {
                      //create group
                      List ids = [];
                      ids.add(widget.auth.currentUser.uid);
                      for (int i = 0; i < list.length; i++) {
                        ids.add(list[i]["uid"]);
                      }

                      http
                          .post(
                              Uri.parse(AppSettings().Api_link + 'createGroup'),
                              headers: <String, String>{
                                'Content-Type':
                                    'application/json; charset=UTF-8',
                              },
                              body: jsonEncode(<String, String>{
                                "admin": widget.auth.currentUser.uid,
                                "name": name,
                                "users": ids.toString()
                              }))
                          .then((value) {
                        Navigator.pop(context);
                      });
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => NameOfTheNewGrpChat(
                          Auth: widget.auth,
                          grpCreated: grpCreated,
                        ),
                        fullscreenDialog: true,
                      ),
                    );
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          ParticipentChooseForGrp(
                        auth: widget.auth,
                        callback: done,
                      ),
                      fullscreenDialog: true,
                    ),
                  );
                },
                leading: Icon(
                  Icons.group_add,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text("New Group"),
              ),
            ),
            FutureBuilder<List>(
                // Initialize FlutterFire:
                future: getMyGroups(),
                builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
                  if (snapshot.hasData && snapshot.data.length > 0) {
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            onTap: () {
                              print("grp clicked");
                              //widget.chatWidgetUpdate(Center(child: Text("show")));
                              widget.chatWidgetUpdate(GroupChatThread(
                                socket: widget.socket,
                                //widgetHome: widget,

                                auth: widget.auth,
                                grpInfo: snapshot.data[index],
                              ));

                              //
                            },
                            leading: Icon(Icons.group),
                            title: Text(snapshot.data[index]["body"]["name"]),
                            subtitle: getUsersCount(
                                snapshot.data[index]["body"]["users"]),
                          );
                        });
                  } else {
                    return Center(child: Text("No Groups"));
                  }
                }),
          ],
        ),
      );
    }
  }

  void startChatBodyViewCreate(dynamic cBody) {
    if (cBody == null) {
      widget.chatWidgetUpdate(Center(
          child: Image.asset(
        "assets/background.png",
        fit: BoxFit.cover,
      )));
    } else {
      call(dynamic data) {
        print(data);
        try {
          CommonFunctions(auth: widget.auth).initCallIntent(
              socket: widget.socket,
              callTYpe: "v",
              ownid: widget.auth.currentUser.uid,
              partner: data,
              isCaller: true,
              context: context);
        } catch (e) {
          print("exceptio of call");
          print(e.toString());
        }
      }

      String r = createRoomName(
          widget.auth.currentUser.uid,
          cBody["sender"] != null
              ? (cBody["sender"] == widget.auth.currentUser.uid
                  ? cBody["receiver"]
                  : cBody["sender"])
              : cBody["uid"]);
      // wiget.socket.on(r, (data) {
      //   ChatDataloadedStream.getInstance().dataReload(data);
      //
      //   print("downloaded");
      //   print(data.length.toString());
      // });
      //
      widget.socket.emit("getMesage", {"fileName": r});

      // Widget w = ChatMesageLit(
      //     auth: widget.auth,
      //     chatBody: cBody,
      //     firebaseFirestore: widget.firestore,
      //     room: r);
      //UserInfoBar
      Widget nameBar = UserInfoBar(
        auth: widget.auth,
        cBody: cBody,
      );
      String fndID = cBody["sender"] != null
          ? (cBody["sender"] == widget.auth.currentUser.uid
              ? cBody["receiver"]
              : cBody["sender"])
          : cBody["uid"];
      // Widget sad = Container(height: 125,
      //   child: Stack(
      //     children: [
      //       Positioned( top: 75,
      //           left: 0,
      //           right: 0,child: Container(height: 50,child: Center(child: AddFndWidget(fndID: fndID,uid: widget.auth.currentUser.uid,)),))
      //     ],
      //   ),
      // );
      widget.chatWidgetUpdate(Container(
        width: MediaQuery.of(context).size.width,
        child: SingleChatThread(
            whileCall: false,
            socket: widget.socket,
            showMobileView: widget.isMobileView,
            // messagebody: w,
            // showFndAddDlg: sad,
            chatBody: cBody,
            auth: widget.auth,
            call: call,
            room: r,
            nameBar: nameBar),
      ));
    }
  }

  Future<String> getUserStatus() async {
    SharedPreferences prefs;
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    prefs = await _prefs;
    return prefs.getString("uStatus");
  }

  Stream getUsrInfo(String uid) {
    print("Looking for " + uid);
    getUserDetailStream stream = getUserDetailStream.getInstance();
    widget.socket.on(uid + "_profile", (data) {
      print("donwload profile");
      print(data);

      stream.dataReload(data);
    });
    // wiget.socket.emit("saveProfileData",{"uid":widget.auth.currentUser.uid,"name":"mukul"});
    widget.socket.emit("getUserProfile", {"uid": uid});
    return stream.outData;
  }

  Future<List> getMyFriends() async {
    var url = Uri.parse(
        AppSettings().Api_link + 'getMyFnds?id=' + widget.auth.currentUser.uid);
    var response = await http.get(
      url,
    );
    return jsonDecode(response.body);
  }

  Future<List> getMyGroups() async {
    var url = Uri.parse(AppSettings().Api_link +
        'viewMyGroups?id=' +
        widget.auth.currentUser.uid);
    var response = await http.get(
      url,
    );
    return jsonDecode(response.body);
  }

  Widget getUsersCount(dynamic data) {
    String users = data.toString();
    List all = users.split(",");
    //  return Text( data.toString());
    return Text(all.length.toString() + " users");
  }
}

class ProfileUpdate extends StatefulWidget {
  FirebaseAuth auth;

  ProfileUpdate({
    this.auth,
  });

  @override
  _ProfileUpdateState createState() => _ProfileUpdateState();
}

class _ProfileUpdateState extends State<ProfileUpdate> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class SearchPeopleActivity extends StatefulWidget {
  FirebaseAuth auth;

  void Function(dynamic) clicked;
  String searchKey = "";
  void Function() searchClosed;
  List downloaded = [];

  List filtered = [];

  SearchPeopleActivity({this.clicked, this.auth, this.searchClosed});

  @override
  _SearchPeopleActivityState createState() => _SearchPeopleActivityState();
}

class _SearchPeopleActivityState extends State<SearchPeopleActivity> {
  TextEditingController searchController = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    downloadAlluser();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.blueAccent,
                    Colors.blue,
                    Colors.lightBlue,
                    Colors.lightBlue,
                  ],
                )),
            child: Container(
              height: 60,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        onChanged: (val) {
                          print(val);
                          // setState(() {
                          //   widget.searchKey = val;
                          // });
                          List localRes = [];
                          if (val.length > 0) {
                            for (int i = 0; i < widget.downloaded.length; i++) {
                              if (widget.downloaded[i]["name"]
                                  .toString()
                                  .toLowerCase()
                                  .startsWith(val.toLowerCase())) {
                                localRes.add(widget.downloaded[i]);
                              }
                            }
                            setState(() {
                              widget.filtered = localRes;
                            });
                          } else {
                            setState(() {
                              widget.filtered = [];
                            });
                          }
                        },
                        // controller: searchController,
                        cursorColor: Colors.white,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search People",
                          hintStyle: TextStyle(color: Colors.white),
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              widget.searchClosed();
                            },
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),

        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.filtered.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              onTap: () {
                Navigator.pop(context);
                widget.clicked(widget.filtered[index]);
              },
              tileColor: Color.fromARGB(255, 249, 252, 255),
              leading: CommonFunctions(
                  auth: widget.auth,
                  onlineUser: onlineUser,
                  busyUser: busyUser,
                  awayUser: awayUser)
                  .prePareUserPhoto(
                  uid: widget.filtered[index]["uid"] != null
                      ? widget.filtered[index]["uid"]
                      : (widget.filtered[index]["sender"] !=
                      widget.auth.currentUser.uid
                      ? widget.filtered[index]["sender"]
                      : widget.filtered[index]["receiver"])),
              title: Text(widget.filtered[index]["name"]),
              subtitle: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text("Send Message"),
              ),
            );
          },
        ),
        //searchController.text
      ],
    );
  }

  void downloadAlluser() async {
    //https://api.maulaji.com/getAllUsers
    var url = Uri.parse(AppSettings().Api_link + 'getAllUsers');
    var response = await http.get(url);
    print(response.body);
    List allData = jsonDecode(response.body);
    print(allData.length.toString());
    List all = [];

    setState(() {
      widget.downloaded = allData;
    });

    // wiget.socket.on("all_users"+widget.auth.currentUser.uid, (data){
    //   all.clear();
    //   print("downloaded peole "+data.length.toString());
    //   for (int i = 0; i < data.length; i++) {
    //     all.add(data[i]);
    //   }
    //   if(mounted){
    //     setState(() {
    //       widget.downloaded = all;
    //     });
    //   }
    // });
    // wiget.socket.emit("getAllUsers",{"uid":widget.auth.currentUser.uid});

    // widget.firestore.collection("users").get().then((value) {
    //   for (int i = 0; i < value.docs.length; i++) {
    //     all.add(value.docs[i].data());
    //   }
    //   setState(() {
    //     widget.downloaded = all;
    //   });
    // });
  }
}

class FetchUserNameWidget extends StatefulWidget {
  FirebaseAuth auth;
  String uid;

  FetchUserNameWidget({this.uid});

  String name = "Please wait";

  @override
  _FetchUserNameWidgetState createState() => _FetchUserNameWidgetState();
}

class _FetchUserNameWidgetState extends State<FetchUserNameWidget> {
  Future getData() async {
    String id = widget.uid;
    var url = Uri.parse(AppSettings().Api_link + 'getUserDetail?id=' + id);
    var response = await http.get(url);
    return jsonDecode(response.body);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //  return Text("Ana or Nadia");
    return FutureBuilder(
        // Initialize FlutterFire:
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Text(snapshot.data["name"]);
          } else {
            return Text("Please wait");
          }
        });
  }
}

class FetchUserNameEmailLIsttileWidget extends StatefulWidget {
  FirebaseAuth auth;
  String uid;

  FetchUserNameEmailLIsttileWidget({this.uid});

  String name = "Please wait";

  @override
  _FetchUserNameEmailLIsttileWidgetState createState() =>
      _FetchUserNameEmailLIsttileWidgetState();
}

class _FetchUserNameEmailLIsttileWidgetState
    extends State<FetchUserNameEmailLIsttileWidget> {
  Future getData() async {
    String id = widget.uid;
    var url = Uri.parse(AppSettings().Api_link + 'getUserDetail?id=' + id);
    var response = await http.get(url);
    return jsonDecode(response.body);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //  return Text("Ana or Nadia");
    return FutureBuilder(
        // Initialize FlutterFire:
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return ListTile(
              title: Text(snapshot.data["name"]),
              subtitle: Text(snapshot.data["email"]),
              leading: CircleAvatar(),
            );
          } else {
            return Text("Please wait");
          }
        });
  }
}

class FetchUserEmailWidget extends StatefulWidget {
  FirebaseAuth auth;
  String uid;

  FetchUserEmailWidget({this.uid});

  String name = "Please wait";

  @override
  _FetchUserEmailWidgetState createState() => _FetchUserEmailWidgetState();
}

class _FetchUserEmailWidgetState extends State<FetchUserEmailWidget> {
  getUsrInfo(String uid) {
    print("Looking for " + uid);
    //
    // widget.socket.on(uid + "_profile", (data) {
    //   print("donwload profile");
    //   print(data);
    //   if (mounted) {
    //     try {
    //       setState(() {
    //         widget.name = data["email"];
    //       });
    //     } catch (e) {}
    //   }
    // });
    // // wiget.socket.emit("saveProfileData",{"uid":widget.auth.currentUser.uid,"name":"mukul"});
    // widget.socket.emit("getUserProfile", {"uid": uid});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUsrInfo(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Container(height: 40, child: Text(widget.name));
  }
}

class UserInfoBar extends StatefulWidget {
  FirebaseAuth auth;
  dynamic cBody;
  String name = "";
  void Function(String) call;

  UserInfoBar({this.cBody, this.auth, this.call});

  String id;

  @override
  _UserInfoBarState createState() => _UserInfoBarState();
}

class _UserInfoBarState extends State<UserInfoBar> {
  Future getData() async {
    String id = widget.cBody["uid"] != null
        ? widget.cBody["uid"]
        : (widget.cBody["receiver"] == widget.auth.currentUser.uid
            ? widget.cBody["sender"]
            : widget.cBody["receiver"]);
    setState(() {
      widget.id = id;
    });
    var url = Uri.parse(AppSettings().Api_link + 'getUserDetail?id=' + id);
    var response = await http.get(url);
    return jsonDecode(response.body);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getUsrInfo(widget.cBody["uid"]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        // Initialize FlutterFire:
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot.data["name"],
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  snapshot.data["email"],
                )
              ],
            );
          } else {
            return Text("Please wait");
          }
        });
  }
}

class LastChatWIdgetStream extends StatefulWidget {
  // List data = [];
  void Function(dynamic) doSomething;
  bool showMobileView;
  double width;

  LastChatWIdgetStream({this.width, this.showMobileView, this.doSomething});

  @override
  _LastChatWIdgetStreamState createState() => _LastChatWIdgetStreamState();
}

//LastMessagesStream.getInstance()
class _LastChatWIdgetStreamState extends State<LastChatWIdgetStream> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      child: StreamBuilder<List>(
          stream: LastMessagesStream.getInstance().outData,
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data.length > 0) {
              return ListView.builder(
                physics: ClampingScrollPhysics(),
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

                              widget.doSomething(snapshot.data[index]["uid"]);
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
                child: Text("No Chat history"),
              );
            }
          }),
    );
  }
}
