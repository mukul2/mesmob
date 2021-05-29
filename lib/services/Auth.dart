import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:maulajimessenger/services/Settings.dart';
import 'package:maulajimessenger/services/Signal.dart';
import 'package:http/http.dart' as http;



class Auth {

  final FirebaseAuth auth;

  Auth({this.auth});

  Stream<User> get user => auth.authStateChanges();

  Future<bool> createAccount({String name,String email, String password,BuildContext context}) async {
    try {
      UserCredential result = await auth.createUserWithEmailAndPassword(email: email, password: password);
      User user = result.user;
     // await user.updateProfile(displayName: name);





      //AppSignal().initSignal().emit("saveProfileData",{"name":name,"uid":user.uid,"email":user.email});


      var url = Uri.parse(AppSettings().Api_link+'saveProfile?name='+name+"&&uid="+user.uid+"&&email="+user.email);
      Navigator.of(context).pop();
      var response = await http.get(url,);



     // await firestore.collection("users").add({"name":name,"uid":user.uid,"email":user.email});




      return Future.value(true);
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return false;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }





  Future<String> signIn({String email, String password}) async {
    try {
      await auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> signOut() async {
    try {
      await auth.signOut();
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      rethrow;
    }
  }
}
