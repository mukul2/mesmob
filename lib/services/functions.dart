import 'dart:collection';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:maulajimessenger/call/WebCallingSimple.dart';
import 'package:maulajimessenger/services/Settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
class CommonFunctions {
  String base = "https://talk.maulaji.com/";

  final FirebaseAuth auth;
  HashMap onlineUser;
  HashMap awayUser;
  HashMap busyUser;
  CommonFunctions({this.auth,this.onlineUser,this.busyUser,this.awayUser});
  String createRoomName(String uid, partner) {
    final List<String> ids = <String>[uid, partner];
    ids.sort();
    return ids.first + "-" + ids.last;
  }


  void sendMessage(IO.Socket socket,FirebaseAuth auth, String val, String type, String name,
      dynamic chatBody) async {
    print("sent " + type);
    String room = createRoomName(
        auth.currentUser.uid,
        chatBody["sender"] != null
            ? (chatBody["sender"] == auth.currentUser.uid
            ? chatBody["receiver"]
            : chatBody["sender"])
            : chatBody["uid"]);

    dynamic me = {
      "time": DateTime.now().millisecondsSinceEpoch,
      "message": val,
      "type": type,
      "fname": name,
      "sender": auth.currentUser.uid,
      "receiver": chatBody["sender"] != null
          ? (chatBody["sender"] == auth.currentUser.uid
          ? chatBody["receiver"]
          : chatBody["sender"])
          : chatBody["uid"]
    };

    socket.emit("saveMesage", {"fileName": room, "message": me});
    print({"fileName": room, "message": me});

    // await firestore.collection("last").doc(room).set({
    //   "message": val,
    //   "type": type,
    //   "fname": name,
    //   "sender": auth.currentUser.uid,
    //   "receiver": chatBody["sender"] != null
    //       ? (chatBody["sender"] == auth.currentUser.uid
    //           ? chatBody["receiver"]
    //           : chatBody["sender"])
    //       : chatBody["uid"]
    // });
    //
    // await firestore.collection(room).add(me);
  }


  prePareUserPhoto({String uid}) {
    Widget statusWIdget;

    for(int i = 0 ; i < 1 ; i++){
      if (onlineUser.containsKey(uid) &&
          onlineUser[uid] + 3000 > DateTime.now().millisecondsSinceEpoch) {
        statusWIdget = InkWell(onTap: ()async{
          // uid
          if(uid == auth.currentUser.uid ){




            SharedPreferences prefs;
            Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
            prefs = await _prefs;
            String userStatus = prefs.getString("uStatus");
            if(userStatus == null){
              prefs.setString("uStatus", "online");
              print(prefs.getString("uStatus"));
            }
            if(userStatus!= null && userStatus == "online" ){
              prefs.setString("uStatus", "away");
              print(prefs.getString("uStatus"));

            }
            if(userStatus!= null && userStatus == "away" ){
              prefs.setString("uStatus", "busy");
              print(prefs.getString("uStatus"));

            }
            if(userStatus!= null && userStatus == "busy" ){
              prefs.setString("uStatus", "offline");
              print(prefs.getString("uStatus"));

            }
            if(userStatus!= null && userStatus == "offline" ){
              prefs.setString("uStatus", "online");
              print(prefs.getString("uStatus"));

            }
          }
        },
          child: Container(
            width: 10,
            height: 10,
            decoration:
            BoxDecoration(shape: BoxShape.circle, color: Colors.greenAccent),
          ),
        );
      }else  if (awayUser.containsKey(uid) &&
          awayUser[uid] + 3000 > DateTime.now().millisecondsSinceEpoch) {
        statusWIdget = InkWell(onTap: ()async{
          // uid
          if(uid == auth.currentUser.uid ){
            SharedPreferences prefs;
            Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
            prefs = await _prefs;
            String userStatus = prefs.getString("uStatus");
            if(userStatus == null){
              prefs.setString("uStatus", "online");
              print(prefs.getString("uStatus"));
            }
            if(userStatus!= null && userStatus == "online" ){
              prefs.setString("uStatus", "away");
              print(prefs.getString("uStatus"));

            }
            if(userStatus!= null && userStatus == "away" ){
              prefs.setString("uStatus", "busy");
              print(prefs.getString("uStatus"));

            }
            if(userStatus!= null && userStatus == "busy" ){
              prefs.setString("uStatus", "offline");
              print(prefs.getString("uStatus"));

            }
            if(userStatus!= null && userStatus == "offline" ){
              prefs.setString("uStatus", "online");
              print(prefs.getString("uStatus"));

            }
          }
        },
          child: Container(
            width: 10,
            height: 10,
            decoration:
            BoxDecoration(shape: BoxShape.circle, color: Colors.yellow),
          ),
        );
      }else  if (busyUser.containsKey(uid) &&
          busyUser[uid] + 3000 > DateTime.now().millisecondsSinceEpoch) {
        statusWIdget = InkWell(onTap: ()async{
          // uid
          if(uid == auth.currentUser.uid ){
            SharedPreferences prefs;
            Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
            prefs = await _prefs;
            String userStatus = prefs.getString("uStatus");
            if(userStatus == null){
              prefs.setString("uStatus", "online");
              print(prefs.getString("uStatus"));
            }
            if(userStatus!= null && userStatus == "online" ){
              prefs.setString("uStatus", "away");print(prefs.getString("uStatus"));


            }
            if(userStatus!= null && userStatus == "away" ){
              prefs.setString("uStatus", "busy");
              print(prefs.getString("uStatus"));

            }
            if(userStatus!= null && userStatus == "busy" ){
              prefs.setString("uStatus", "offline");
              print(prefs.getString("uStatus"));

            }
            if(userStatus!= null && userStatus == "offline" ){
              prefs.setString("uStatus", "online");
              print(prefs.getString("uStatus"));

            }
          }
        },
          child: Container(
            width: 10,
            height: 10,
            decoration:
            BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent),
          ),
        );
      }else {
        statusWIdget = InkWell(onTap: ()async{
          //uid
          if(uid == auth.currentUser.uid ){
            SharedPreferences prefs;
            Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
            prefs = await _prefs;
            String userStatus = prefs.getString("uStatus");
            if(userStatus == null){
              prefs.setString("uStatus", "online");
              print(prefs.getString("uStatus"));
            }
            if(userStatus!= null && userStatus == "online" ){
              prefs.setString("uStatus", "away");
              print(prefs.getString("uStatus"));

            }
            if(userStatus!= null && userStatus == "away" ){
              prefs.setString("uStatus", "busy");
              print(prefs.getString("uStatus"));

            }
            if(userStatus!= null && userStatus == "busy" ){
              prefs.setString("uStatus", "offline");
              print(prefs.getString("uStatus"));

            }if(userStatus!= null && userStatus == "offline" ){
              prefs.setString("uStatus", "online");
              print(prefs.getString("uStatus"));

            }
          }
        },
          child: Container(
            width: 10,
            height: 10,
            decoration:
            BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
          ),
        );
      }

    }


    return FutureBuilder(
      // Initialize FlutterFire:
        future: getData(uid),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null && snapshot.data["photo"]!=null &&snapshot.data["photo"].toString().length>0) {
            return Container(
              height: 40,
              width: 40,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: CircleAvatar( backgroundImage:NetworkImage(base+snapshot.data["photo"]),),

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

          } else {
            return Container(
              height: 40,
              width: 40,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: CircleAvatar( backgroundImage: AssetImage("assets/user_photo.jpg"),),

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
        });

    return Container(
      height: 40,
      width: 40,
      child: Stack(
        children: [
          // Align(
          //   alignment: Alignment.center,
          //   child: CircleAvatar( backgroundImage: AssetImage("assets/user_photo.jpg"),),
          //
          // ),
          Align(
            alignment: Alignment.center,
            child: Text("P"),

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
  prePareUserPhotoSelf({String uid}) {

    Widget w  = StreamBuilder<dynamic>(
        stream:getSt().asStream(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
          if(snapshot.hasData){
            Widget statusWIdget = Container(
                width: 10,
                height: 10,
                decoration:
                BoxDecoration(shape: BoxShape.circle, color:prepareColor(snapshot.data)));
            return FutureBuilder(
              // Initialize FlutterFire:
                future: getData(uid),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null && snapshot.data["photo"]!=null &&snapshot.data["photo"].toString().length>0) {
                    return Container(
                      height: 40,
                      width: 40,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: CircleAvatar( backgroundImage:NetworkImage(base+snapshot.data["photo"]),),

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

                  } else {
                    return Container(
                      height: 40,
                      width: 40,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: CircleAvatar( backgroundImage: AssetImage("assets/user_photo.jpg"),),

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
                });
          }


        });
        Widget statusWIdget = Container(
        width: 10,
        height: 10,
        decoration:
        BoxDecoration(shape: BoxShape.circle, color: Colors.greenAccent));
        return w;


        for(int i = 0 ; i < 1 ; i++){
      if (onlineUser.containsKey(uid) &&
          onlineUser[uid] + 3000 > DateTime.now().millisecondsSinceEpoch) {
        statusWIdget = InkWell(onTap: ()async{
          // uid
          if(uid == auth.currentUser.uid ){




            SharedPreferences prefs;
            Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
            prefs = await _prefs;
            String userStatus = prefs.getString("uStatus");
            if(userStatus == null){
              prefs.setString("uStatus", "online");
              print(prefs.getString("uStatus"));
            }
            if(userStatus!= null && userStatus == "online" ){
              prefs.setString("uStatus", "away");
              print(prefs.getString("uStatus"));

            }
            if(userStatus!= null && userStatus == "away" ){
              prefs.setString("uStatus", "busy");
              print(prefs.getString("uStatus"));

            }
            if(userStatus!= null && userStatus == "busy" ){
              prefs.setString("uStatus", "offline");
              print(prefs.getString("uStatus"));

            }
            if(userStatus!= null && userStatus == "offline" ){
              prefs.setString("uStatus", "online");
              print(prefs.getString("uStatus"));

            }
          }
        },
          child: Container(
            width: 10,
            height: 10,
            decoration:
            BoxDecoration(shape: BoxShape.circle, color: Colors.greenAccent),
          ),
        );
      }else  if (awayUser.containsKey(uid) &&
          awayUser[uid] + 3000 > DateTime.now().millisecondsSinceEpoch) {
        statusWIdget = InkWell(onTap: ()async{
          // uid
          if(uid == auth.currentUser.uid ){
            SharedPreferences prefs;
            Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
            prefs = await _prefs;
            String userStatus = prefs.getString("uStatus");
            if(userStatus == null){
              prefs.setString("uStatus", "online");
              print(prefs.getString("uStatus"));
            }
            if(userStatus!= null && userStatus == "online" ){
              prefs.setString("uStatus", "away");
              print(prefs.getString("uStatus"));

            }
            if(userStatus!= null && userStatus == "away" ){
              prefs.setString("uStatus", "busy");
              print(prefs.getString("uStatus"));

            }
            if(userStatus!= null && userStatus == "busy" ){
              prefs.setString("uStatus", "offline");
              print(prefs.getString("uStatus"));

            }
            if(userStatus!= null && userStatus == "offline" ){
              prefs.setString("uStatus", "online");
              print(prefs.getString("uStatus"));

            }
          }
        },
          child: Container(
            width: 10,
            height: 10,
            decoration:
            BoxDecoration(shape: BoxShape.circle, color: Colors.yellow),
          ),
        );
      }else  if (busyUser.containsKey(uid) &&
          busyUser[uid] + 3000 > DateTime.now().millisecondsSinceEpoch) {
        statusWIdget = InkWell(onTap: ()async{
          // uid
          if(uid == auth.currentUser.uid ){
            SharedPreferences prefs;
            Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
            prefs = await _prefs;
            String userStatus = prefs.getString("uStatus");
            if(userStatus == null){
              prefs.setString("uStatus", "online");
              print(prefs.getString("uStatus"));
            }
            if(userStatus!= null && userStatus == "online" ){
              prefs.setString("uStatus", "away");print(prefs.getString("uStatus"));


            }
            if(userStatus!= null && userStatus == "away" ){
              prefs.setString("uStatus", "busy");
              print(prefs.getString("uStatus"));

            }
            if(userStatus!= null && userStatus == "busy" ){
              prefs.setString("uStatus", "offline");
              print(prefs.getString("uStatus"));

            }
            if(userStatus!= null && userStatus == "offline" ){
              prefs.setString("uStatus", "online");
              print(prefs.getString("uStatus"));

            }
          }
        },
          child: Container(
            width: 10,
            height: 10,
            decoration:
            BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent),
          ),
        );
      }else {
        statusWIdget = InkWell(onTap: ()async{
          //uid
          if(uid == auth.currentUser.uid ){
            SharedPreferences prefs;
            Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
            prefs = await _prefs;
            String userStatus = prefs.getString("uStatus");
            if(userStatus == null){
              prefs.setString("uStatus", "online");
              print(prefs.getString("uStatus"));
            }
            if(userStatus!= null && userStatus == "online" ){
              prefs.setString("uStatus", "away");
              print(prefs.getString("uStatus"));

            }
            if(userStatus!= null && userStatus == "away" ){
              prefs.setString("uStatus", "busy");
              print(prefs.getString("uStatus"));

            }
            if(userStatus!= null && userStatus == "busy" ){
              prefs.setString("uStatus", "offline");
              print(prefs.getString("uStatus"));

            }if(userStatus!= null && userStatus == "offline" ){
              prefs.setString("uStatus", "online");
              print(prefs.getString("uStatus"));

            }
          }
        },
          child: Container(
            width: 10,
            height: 10,
            decoration:
            BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
          ),
        );
      }

    }


    return FutureBuilder(
      // Initialize FlutterFire:
        future: getData(uid),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null && snapshot.data["photo"]!=null &&snapshot.data["photo"].toString().length>0) {
            return Container(
              height: 40,
              width: 40,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: CircleAvatar( backgroundImage:NetworkImage(base+snapshot.data["photo"]),),

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

          } else {
            return Container(
              height: 40,
              width: 40,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: CircleAvatar( backgroundImage: AssetImage("assets/user_photo.jpg"),),

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
        });

    return Container(
      height: 40,
      width: 40,
      child: Stack(
        children: [
          // Align(
          //   alignment: Alignment.center,
          //   child: CircleAvatar( backgroundImage: AssetImage("assets/user_photo.jpg"),),
          //
          // ),
          Align(
            alignment: Alignment.center,
            child: Text("P"),

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
  // Widget getNameFromIdR(
  // {String id, bool style}) {
  //   return FutureBuilder<QuerySnapshot>(
  //       future: firestore.collection("users").where("uid", isEqualTo: id).get(),
  //       builder: (context, snapuserInfo) {
  //         if (snapuserInfo.hasData) {
  //           return Text(
  //             snapuserInfo.data.docs.first.data()["name"],
  //             style: style
  //                 ? TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.black,
  //                 fontSize: 20)
  //                 : TextStyle(),
  //           );
  //         } else {
  //           return Text("Please wait");
  //         }
  //       });
  // }

  void initCallIntent({IO.Socket socket,String callTYpe, String ownid, String partner,
      bool isCaller, BuildContext context}) async {
    //socket2.emit("calldial",{"partner":partner});
    // setState(() {
    //   widget.shouldShowIncomming = false;
    // });

    if (true) {


      List ids = [];
      ids.add(ownid);
      ids.add(partner);
      ids.sort();

      doSomething() {
        // setState(() {
        //   widget.callWidgetShow = false;
        //   widget.userStatus = "free";
        //   widget.CallDuration = 0;
        // });
        //   Navigator.pop(context);
      }

      callUserIsNoAvailable() {
        // setState(() {
        //   widget.callWidgetShow = false;
        //
        // });
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

      }



      print("came here fpr caol");

      var url = Uri.parse(AppSettings().Api_link+'getUserDetail?id='+partner);
      var response = await http.get(url);
      print(response.body);
      dynamic partnerN =  jsonDecode(response.body)["name"];

      var url1 = Uri.parse(AppSettings().Api_link+'getUserDetail?id='+ownid);
      var response1 = await http.get(url1);
      dynamic OwnN =  jsonDecode(response1.body)["name"];
      dynamic OwnP =  jsonDecode(response1.body)["photo"];



      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>WillPopScope(
                onWillPop: () async => false,
                child: SimpleWebCall(socket:socket ,
                  containsVideo: false,
                  ownID: ownid,
                  partnerid: partner,
                  isCaller: isCaller,

                  partnerPair: ids.first + "-" + ids.last,
                  callback: doSomething,
                  callStartedNotify: callStartedNotify,
                  callUserIsNoAvailable: callUserIsNoAvailable,
                  partnerName: partnerN,
                  ownName: OwnN,
                  ownPhoto: OwnP,

                ),
              )));


      // firestore.collection("users").where("uid",isEqualTo: partner).get().then((value){
      //   String partnerName = value.docs.first.data()["name"];
      //   firestore.collection("users").where("uid",isEqualTo: ownid).get().then((value){
      //     String ownName = value.docs.first.data()["name"];
      //     Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //             builder: (context) =>WillPopScope(
      //               onWillPop: () async => false,
      //               child: SimpleWebCall(
      //                 containsVideo: false,
      //                 ownID: ownid,
      //                 partnerid: partner,
      //                 isCaller: isCaller,
      //                 firestore: firestore,
      //                 partnerPair: ids.first + "-" + ids.last,
      //                 callback: doSomething,
      //                 callStartedNotify: callStartedNotify,
      //                 callUserIsNoAvailable: callUserIsNoAvailable,
      //                 partnerName: partnerName,
      //                 ownName: ownName,
      //
      //               ),
      //             )));
      //     // setState(() {
      //     //   widget.callWidget = WillPopScope(
      //     //     onWillPop: () async => false,
      //     //     child: SimpleWebCall(
      //     //       containsVideo: false,
      //     //       ownID: ownid,
      //     //       partnerid: partner,
      //     //       isCaller: isCaller,
      //     //       firestore: firestore,
      //     //       partnerPair: ids.first + "-" + ids.last,
      //     //       callback: doSomething,
      //     //       callStartedNotify: callStartedNotify,
      //     //       callUserIsNoAvailable: callUserIsNoAvailable,
      //     //       partnerName: partnerName,
      //     //       ownName: ownName,
      //     //
      //     //     ),
      //     //   );
      //     //   widget.callWidgetShow = true;
      //     // });
      //   });
      // });









    }
  }

  Future getData(String uid) async {
    String id = uid;
    var url = Uri.parse(AppSettings().Api_link+'getUserDetail?id=' + id);
    var response = await http.get(url);
    return jsonDecode(response.body);
  }

  Future getSt() async{
    SharedPreferences prefs;
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    prefs = await _prefs;
    String userStatus = prefs.getString("uStatus");
    if(userStatus==null) return "online";else
    return userStatus;

  }

Color  prepareColor(userStatus) {
    Color col = Colors.greenAccent;
  if(userStatus == null){
    col = Colors.greenAccent;
  }
  if(userStatus!= null && userStatus == "online" ){
    col = Colors.greenAccent;

  }
  if(userStatus!= null && userStatus == "away" ){
    col = Colors.yellow;

  }
  if(userStatus!= null && userStatus == "busy" ){
    col = Colors.redAccent;

  }
  if(userStatus!= null && userStatus == "offline" ){
    col = Colors.grey;

  }
  return col;

}


}