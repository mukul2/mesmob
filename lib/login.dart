import 'dart:convert';
import 'dart:io';
import 'dart:math';


import 'package:country_list_pick/country_list_pick.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:maulajimessenger/Screens/create_account_page.dart';
import 'package:maulajimessenger/services/Auth.dart';
import 'package:http/http.dart' as http;
import 'package:maulajimessenger/services/Settings.dart';




class Login extends StatefulWidget {
  final FirebaseAuth auth;

   Login({
    Key key,
    @required this.auth,
  }) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController(text: "");
  final TextEditingController _passwordController = TextEditingController(text: "");
  var   _socket;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   // initSignaling();

  }


  Future<WebSocket> _connectForSelfSignedCert(url) async {
    try {
      Random r = new Random();
      String key = base64.encode(List<int>.generate(8, (_) => r.nextInt(255)));
      HttpClient client = HttpClient(context: SecurityContext());
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        print(
            'SimpleWebSocket: Allow self-signed certificate => $host:$port. ');
        return true;
      };

      HttpClientRequest request =
      await client.getUrl(Uri.parse(url)); // form the correct url here
      request.headers.add('Connection', 'Upgrade');
      request.headers.add('Upgrade', 'websocket');
      request.headers.add(
          'Sec-WebSocket-Version', '13'); // insert the correct version here
      request.headers.add('Sec-WebSocket-Key', key.toLowerCase());

      HttpClientResponse response = await request.close();
      // ignore: close_sinks
      Socket socket = await response.detachSocket();
      var webSocket = WebSocket.fromUpgradedSocket(
        socket,
        protocol: 'signaling',
        serverSide: false,
      );

      return webSocket;
    } catch (e) {
      throw e;
    }
  }
  // Initially password is obscure
  bool _obscureText = true;
  bool hidePass = true;
  String _password;

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
//assets/background.png
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: MediaQuery.of(context).size.width>500?  Row(mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        Container(width: MediaQuery.of(context).size.width-450,
          child: Image.asset(
            "assets/background.png",
            fit: BoxFit.cover,
          ),
        ),
        Container(width: 410,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 40,0),
            child: loginForm(),
          ),
        ),
      ],
    ):Center(child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: loginForm(),
    )),);
  }

 Widget loginForm() {
   FocusNode textSecondFocusNode = new FocusNode();
   FocusNode textFirstFocusNode = new FocusNode();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              height: 100,
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                "assets/maulaji_sqr.png",
                fit: BoxFit.cover,
              )),
          Container(
            child: Wrap(
              children: [
                Text("Read our"),
                Padding(
                  padding: const EdgeInsets.fromLTRB(3,0,3, 0),
                  child: Text("Privacy Policy.",style: TextStyle(color:Colors.blue)),
                ),
                Text("Tap Agree and Continue to accept the"),
                Padding(
                  padding: const EdgeInsets.fromLTRB(3,0,3, 0),
                  child: Text("Terms of Service",style: TextStyle(color:Colors.blue),),
                ),
              ],
            ),
          ),
          TextFormField(
            // focusNode: textFirstFocusNode,
            textAlign: TextAlign.left,
            autofocus: true,

            decoration:
            const InputDecoration(hintText: "Email"),
            controller: _emailController,
            onEditingComplete: () => FocusScope.of(context).nextFocus(),
            // onEditingComplete: (String value) {
            //   FocusScope.of(context).requestFocus(textSecondFocusNode);
            // },
          ),


          Container(height:50 ,width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [


                Positioned(
                  left: 0,
                  right: 0,

                  child: Container(
                    child: TextFormField(
                     // focusNode: textSecondFocusNode,
                      validator: (value) => validatePassword(value),
                      textAlign: TextAlign.left,
                      obscureText: hidePass,
                      decoration: const InputDecoration(hintText: "Password"),
                      controller: _passwordController,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(width: 50,height: 50,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          hidePass = ! hidePass;
                        });

                      },
                      child: Center(child: Icon(Icons.remove_red_eye)),
                    ),
                  ),
                ),
              ],
            ),
          ),






          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CreateAccount(
                                    auth: widget.auth,
                                  )),
                        );

                        //CreateAccount
                      },
                      child: Text(
                        "Create an Account with Email",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold),
                      )),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: RaisedButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: () async {
                      final String retVal =
                      await Auth(auth: widget.auth)
                          .signIn(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );
                      if (retVal == "Success") {
                        _emailController.clear();
                        _passwordController.clear();
                      } else {
                        Scaffold.of(context).showSnackBar(
                            SnackBar(
                                content: Text(retVal)));
                      }
                    },
                    child: const Text(
                      "SIGN IN",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 00,0),
            child: Container(decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(3)
            ),

              width: MediaQuery.of(context).size.width,
              // height: 400,
              child: InkWell(
                onTap: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PhoneVerificationWidget(
                          auth: widget.auth,
                        )),
                  );
                },
                child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Login with Phone",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    )),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 00,0),
            child: Container(decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(3)
            ),

              width: MediaQuery.of(context).size.width,
              // height: 400,
              child: InkWell(
                onTap: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PasswordForgetActivity(
                          auth: widget.auth,
                        )),
                  );
                },
                child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Forgot password ?",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PhoneVerificationWidget extends StatefulWidget {
  FirebaseAuth auth;


  String countryCode = "Select";

  PhoneVerificationWidget({this.auth});

  List allCountryCodes;

  @override
  _PhoneVerificationWidgetState createState() =>
      _PhoneVerificationWidgetState();
}

class _PhoneVerificationWidgetState extends State<PhoneVerificationWidget> {
  bool isLoading = false ;
  TextEditingController controllerDN = TextEditingController();
  TextEditingController controller = TextEditingController();
  TextEditingController controllerCode = TextEditingController();
  final GlobalKey _menuKey = new GlobalKey();
  var button;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    downloadCountryCodes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          // height: 400,
          child: Wrap(
            children: [
              Card(
                elevation: 10,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0),
                ),
                child: Column(
                  children: [
                    Container(
                      child: CountryListPick(
                          appBar: AppBar(
                            backgroundColor: Colors.blue,
                            title: Text('Choose Country'),
                          ),

                          // if you need custome picker use this
                          pickerBuilder: (context, CountryCode countryCode) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              // Add Your Code here.
                              setState(() {
                                controllerCode.text = countryCode.dialCode;
                              });
                            });

                            return Row(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                    countryCode.flagUri,
                                    package: 'country_list_pick',
                                    width: 30,
                                    height: 30,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(countryCode.name),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.all(8.0),
                                //   child: Text(countryCode.dialCode),
                                // ),
                              ],
                            );
                          },

                          // To disable option set to false
                          theme: CountryTheme(
                            isShowFlag: true,
                            isShowTitle: true,
                            isShowCode: true,
                            isDownIcon: true,
                            showEnglishName: true,
                          ),
                          // Set default value
                          //initialSelection: '+44',
                          // or
                           initialSelection: 'GB',
                          onChanged: (CountryCode code) {
                            print(code.name);
                            print(code.code);
                            print(code.dialCode);
                            print(code.flagUri);
                          },
                          // Whether to allow the widget to set a custom UI overlay
                          useUiOverlay: true,
                          // Whether the country list should be wrapped in a SafeArea
                          useSafeArea: false),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 50,
                            child: TextFormField(
                              enabled: false,
                              controller: controllerCode,
                              decoration: InputDecoration(hintText: ""),
                            ),
                          ),
                        ),
                        Container(
                          width: 300,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: controller,
                              decoration:
                                  InputDecoration(hintText: "Phone number"),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: controllerDN,
                        decoration:
                        InputDecoration(hintText: "Display Name"),
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                elevation: 10,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0),
                ),
                child: InkWell(
                  onTap: () async {





                    if (controllerCode.text.length > 0 &&
                        controller.text.length > 0&&
                        controllerDN.text.length > 0) {
                      setState(() {
                        isLoading = true ;
                      });
                      ConfirmationResult confirmationResult = await widget.auth
                          .signInWithPhoneNumber(
                              controllerCode.text + controller.text);
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ConfirmOTP(
                                  auth: widget.auth,
                                  displayname: controllerDN.text,

                                  confirmationResult: confirmationResult,
                                )),
                      );
                    }else{
                      setState(() {
                        isLoading = false ;
                      });
                    }

                  },
                  child: Container(
                    color: Theme.of(context).primaryColor,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          isLoading?"Please wait": "Send OTP",
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void initCountryCodes() {
    List allItem = [];
    for (int i = 0; i < widget.allCountryCodes.length; i++) {
      allItem.add(PopupMenuItem<String>(
          child: Text(widget.allCountryCodes[i]["name"] +
              " +" +
              widget.allCountryCodes[i]["callingCodes"].first),
          value: "+" + widget.allCountryCodes[i]["callingCodes"].first));
    }

    button = new PopupMenuButton(
      child: Center(child: Text(widget.countryCode)),
      key: _menuKey,
      itemBuilder: (context) {
        return List.generate(allItem.length, (i) {
          return PopupMenuItem<String>(
              child: Text(widget.allCountryCodes[i]["name"] +
                  " +" +
                  widget.allCountryCodes[i]["callingCodes"].first),
              value: "+" + widget.allCountryCodes[i]["callingCodes"].first);
        });
      },
      onSelected: (String choice) {
        setState(() {
          widget.countryCode = choice;

          button = new PopupMenuButton(
            child: Center(child: Text(widget.countryCode)),
            key: _menuKey,
            itemBuilder: (context) {
              return List.generate(allItem.length, (i) {
                return PopupMenuItem<String>(
                    child: Text(widget.allCountryCodes[i]["name"] +
                        " +" +
                        widget.allCountryCodes[i]["callingCodes"].first),
                    value:
                        "+" + widget.allCountryCodes[i]["callingCodes"].first);
              });
            },
            onSelected: (String choice) {
              setState(() {
                widget.countryCode = choice;
                button = new PopupMenuButton(
                  child: Center(child: Text(widget.countryCode)),
                  key: _menuKey,
                  itemBuilder: (context) {
                    return List.generate(allItem.length, (i) {
                      return PopupMenuItem<String>(
                          child: Text(widget.allCountryCodes[i]["name"] +
                              " +" +
                              widget.allCountryCodes[i]["callingCodes"].first),
                          value: "+" +
                              widget.allCountryCodes[i]["callingCodes"].first);
                    });
                  },
                  onSelected: (String choice) {
                    setState(() {
                      widget.countryCode = choice;
                    });
                  },
                );
              });
            },
          );
        });
      },
    );
  }

  Future<List> downloadCountryCodes() async {

    return null;
    // return jsonDecode(res.docs.first.data()["data"]);
    // widget.firestore.collection("country").get().then((value) {
    //   print("size " + value.docs.first.data()["data"]);
    //   if (value.size > 0 && value.docs.length > 0) {
    //
    //     return jsonDecode(value.docs.first.data()["data"]);
    //     setState(() {
    //       widget.allCountryCodes = jsonDecode(value.docs.first.data()["data"]);
    //     });
    //     print("size " + widget.allCountryCodes.length.toString());
    //     initCountryCodes();
    //   }else{
    //
    //   }
    // });
  }
}

class ConfirmOTP extends StatefulWidget {
  FirebaseAuth auth;
  bool isProgressing = false ;


  ConfirmationResult confirmationResult;

  String countryCode = "Select";
  String displayname = "";

  ConfirmOTP({this.displayname,this.auth, this.confirmationResult});

  @override
  _ConfirmOTPState createState() => _ConfirmOTPState();
}

class _ConfirmOTPState extends State<ConfirmOTP> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          // height: 400,
          child: Wrap(
            children: [
              Card(
                elevation: 10,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: controller,
                      decoration: InputDecoration(hintText: "OTP"),
                    ),
                  ),
                ),
              ),
              Card(
                elevation: 10,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0),
                ),
                child: InkWell(
                  onTap: ()  {
                    setState(() {
                      widget.isProgressing = true;
                    });
                    widget.confirmationResult
                        .confirm(controller.text)
                        .then((value)async {

                      // var url = Uri.parse(AppSettings().Api_link+'saveProfile?name='+widget.displayname+"&&uid="+FirebaseAuth.instance.currentUser.uid+"&&phone="+FirebaseAuth.instance.currentUser.phoneNumber.trim()+"&&email="+"");
                      // http.get(url).then((value) {
                      //   Navigator.of(context).pop();
                      //  // Navigator.of(context).pop();
                      //
                      // });




                      Navigator.of(context).pop();
                     // Navigator.of(context).pop();
                      getData(FirebaseAuth.instance.currentUser.uid).then((profiel)async {
                      if(profiel!=null && profiel["name"]!=null && profiel["uid"]!=null){

                        var url = Uri.parse(AppSettings()
                            .Api_link +
                            'editUserName?id=' +
                            FirebaseAuth.instance.currentUser.uid +
                            "&&name=" +
                            widget.displayname);
                        var response = await http.get(url);


                        //Navigator.of(context).pop();
                       // Navigator.of(context).pop();

                      }else{
                        var url = Uri.parse(AppSettings().Api_link+'saveProfile?name='+widget.displayname+"&&uid="+FirebaseAuth.instance.currentUser.uid+"&&phone="+FirebaseAuth.instance.currentUser.phoneNumber.trim()+"&&email="+"");
                         http.get(url).then((value) {
                          // Navigator.of(context).pop();
                          // Navigator.of(context).pop();

                         });
                      }

                      });



                      //  var url = Uri.parse(AppSettings().Api_link+'saveProfile?name='+""+"&&uid="+FirebaseAuth.instance.currentUser.uid+"&&email="+"");
                      //
                      //   dynamic profiel =  await getData(FirebaseAuth.instance.currentUser.uid);
                      //   print("Api response ");
                      //   print(profiel);
                      //   if(profiel!=null && profiel["name"]!=null && profiel["uid"]!=null){
                      //     print("old profile");
                      //
                      //
                      //   //  Navigator.pop(context);
                      //     // Navigator.push(
                      //     //   context,
                      //     //   MaterialPageRoute(
                      //     //       builder: (context) => CreateOrUpDateProfile(
                      //     //         auth: widget.auth,
                      //     //         profiel: profiel,
                      //     //
                      //     //       )),
                      //     // );
                      //
                      //   }else{
                      //     var url = Uri.parse(AppSettings().Api_link+'saveProfile?name='+FirebaseAuth.instance.currentUser.phoneNumber+"&&uid="+FirebaseAuth.instance.currentUser.uid+"&&phone="+FirebaseAuth.instance.currentUser.phoneNumber.trim()+"&&email="+"");
                      //     var response = await http.get(url);
                      //
                      //     //Navigator.pop(context);
                      //    // var response = await http.get(url);
                      //     print("new profile");
                      //
                      //     // Navigator.push(
                      //     //   context,
                      //     //   MaterialPageRoute(
                      //     //       builder: (context) => CreateOrUpDateProfile1(
                      //     //         auth: widget.auth,
                      //     //
                      //     //
                      //     //       )),
                      //     // );
                      //   }


                      //  Navigator.pop(context);
                      //  Navigator.pop(context);
                        /*      Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pop(context);

 */

                        //save users data as  new row

                        //TODO
                        // widget.firestore
                        //     .collection("users")
                        //     .where("uid", isEqualTo: value.user.uid)
                        //     .get()
                        //     .then((valueD) async {
                        //   if (valueD.size > 0 && valueD.docs.length > 0) {
                        //
                        //  //   CreateOrUpDateProfile
                        //   //  Navigator.pop(context);
                        //    // Navigator.pop(context);
                        //    //  Navigator.push(
                        //    //    context,
                        //    //    MaterialPageRoute(
                        //    //        builder: (context) => CreateOrUpDateProfile(
                        //    //          auth: widget.auth,
                        //    //          firestore: widget.firestore,queryDocumentSnapshot:valueD.docs.first ,
                        //    //        )),
                        //    //  );
                        //   } else {
                        //     // Navigator.push(
                        //     //   context,
                        //     //   MaterialPageRoute(
                        //     //       builder: (context) => CreateOrUpDateProfile(
                        //     //         auth: widget.auth,
                        //     //         firestore: widget.firestore,
                        //     //       )),
                        //     // );
                        //
                        //
                        //     // await widget.firestore.collection("users").add({
                        //     //   "name": "",
                        //     //   "uid": value.user.uid,
                        //     //   "email": "",
                        //     //   "phone": value.user.phoneNumber
                        //     // });
                        //     // Navigator.pop(context);
                        //     // Navigator.pop(context);
                        //     // widget.firestore.collection("users")
                        //     //     .where("uid", isEqualTo: value.user.uid)
                        //     //     .get().then((value) {
                        //     //   if(value.size>0 &&value.docs.length>0)  {
                        //     //     Navigator.push(
                        //     //       context,
                        //     //       MaterialPageRoute(
                        //     //           builder: (context) => OTPConfirmed(
                        //     //             auth: widget.auth,
                        //     //             firestore: widget.firestore,queryDocumentSnapshot:valueD.docs.first ,
                        //     //           )),
                        //     //     );
                        //     //   }
                        //     // });
                        //     // Navigator.push(
                        //     //   context,
                        //     //   MaterialPageRoute(
                        //     //       builder: (context) => OTPConfirmedNewProfile(
                        //     //         auth: widget.auth,
                        //     //         firestore: widget.firestore,
                        //     //       )),
                        //     // );
                        //   }
                        // });

                    });
                    // print(widget.countryCode+controller.text);
                    // ConfirmationResult confirmationResult = await widget.auth.signInWithPhoneNumber(widget.countryCode+controller.text);
                    // dfd
                  },
                  child: Container(
                    color: Theme.of(context).primaryColor,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:widget.isProgressing==false? Text("Verify",
                              style: TextStyle(color: Colors.white),
                            ):Text("Please wait",
                              style: TextStyle(color: Colors.white),
                            )
                          )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future getData(String id) async {

    var url = Uri.parse(AppSettings().Api_link+'getUserDetail?id=' + id);
    var response = await http.get(url);
    if(response!=null && response.statusCode == 200 && response.body!=null)
    return jsonDecode(response.body);
    else return null;
  }
}

class OTPConfirmed extends StatefulWidget {
  FirebaseAuth auth;


  String countryCode = "Select";

  OTPConfirmed({this.auth,});

  @override
  _state createState() => _state();
}

class _state extends State<OTPConfirmed> {
  TextEditingController controller = TextEditingController();
  TextEditingController controllerName = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // controllerName.text = widget.queryDocumentSnapshot.data()["name"].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [

            CircleAvatar(
              radius: 40,
            ),
            TextFormField(
              controller: controllerName,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class OTPConfirmedNewProfile extends StatefulWidget {
  FirebaseAuth auth;


  OTPConfirmedNewProfile({this.auth, });

  @override
  _stateNewProfile createState() => _stateNewProfile();
}

class _stateNewProfile extends State<OTPConfirmedNewProfile> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("Verified"),
    );
  }
}

class CountryCodeSlectedtor extends StatefulWidget {
  List allCoutry = [];
  List FilteredallCountry = [];


  CountryCodeSlectedtor();

  @override
  _CountryCodeSlectedtorState createState() => _CountryCodeSlectedtorState();
}

class _CountryCodeSlectedtorState extends State<CountryCodeSlectedtor> {
  TextEditingController co = TextEditingController();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return CountryListPick(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text('Choisir un pays'),
        ),

        // if you need custome picker use this
        pickerBuilder: (context, CountryCode countryCode) {
          return Row(
            children: [
              Image.asset(
                countryCode.flagUri,
                package: 'country_list_pick',
              ),
              Text(countryCode.code),
              Text(countryCode.dialCode),
            ],
          );
        },

        // To disable option set to false
        theme: CountryTheme(
          isShowFlag: true,
          isShowTitle: true,
          isShowCode: true,
          isDownIcon: true,
          showEnglishName: true,
        ),
        // Set default value
        initialSelection: '+44',
        // or
        // initialSelection: 'US'
        onChanged: (CountryCode code) {
          print(code.name);
          print(code.code);
          print(code.dialCode);
          print(code.flagUri);
        },
        // Whether to allow the widget to set a custom UI overlay
        useUiOverlay: true,
        // Whether the country list should be wrapped in a SafeArea
        useSafeArea: false);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        backgroundColor: Colors.white,
        title: TextFormField(
          controller: co,
          onChanged: (value) {
            //widget.allCoutry.length > 0 && co.text.length > 0
            if (true) {
              //FilteredallCountry
              print("ggg");
              print(co.text);
              print(widget.allCoutry.length.toString());
              // print(widget.allCoutry[0]["name"]);

              for (int i = 0; i < widget.allCoutry.length; i++) {
                setState(() {
                  widget.FilteredallCountry.add(widget.allCoutry.first);
                });
                if (false &&
                    widget.allCoutry[i]["name"]
                        .toString()
                        .toLowerCase()
                        .startsWith(co.text.toLowerCase())) {
                  setState(() {
                    widget.FilteredallCountry.add(widget.allCoutry[i]);
                  });
                }
              }
              print(co.text);
              print("filtered sixe " +
                  widget.FilteredallCountry.length.toString());
            } else {
              setState(() {
                widget.FilteredallCountry.clear();
                widget.FilteredallCountry.addAll(widget.allCoutry);
              });
            }
          },
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10), hintText: "Search Country"),
        ),
      ),
      body: widget.FilteredallCountry.length > 0
          ? ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: (widget.FilteredallCountry == null)
                  ? 0
                  : widget.FilteredallCountry.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(widget.FilteredallCountry[index]["name"] +
                        " +" +
                        widget.FilteredallCountry[index]["callingCodes"].first),
                  ),
                );
              })
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
class CreateOrUpDateProfile1 extends StatefulWidget {
  FirebaseAuth auth;

  CreateOrUpDateProfile1({this.auth,});
  @override
  _CreateOrUpDateProfileState2 createState() => _CreateOrUpDateProfileState2();
}

class _CreateOrUpDateProfileState2 extends State<CreateOrUpDateProfile1> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // if(widget.queryDocumentSnapshot!=null && widget.queryDocumentSnapshot.exists && widget.queryDocumentSnapshot.data()!=null){
    //   setState(() {
    //     controller.text = widget.queryDocumentSnapshot.data()["name"];
    //   });
    //  }
  }
  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController(text:"");

    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          // height: 400,
          child: Card( elevation: 10,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3.0),
            ),

            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Welcome to Maulaji Talk",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                ),
                // Stack(
                //   children: [
                //     Align(
                //       alignment:Alignment.center,
                //       child: InkWell(onTap: (){
                //
                //       },child: CircleAvatar(radius: 30,)),
                //     )
                //   ],
                // ),
                TextFormField(controller: controller,
                  decoration: InputDecoration(
                      hintText: "Display name",
                      contentPadding: EdgeInsets.fromLTRB(0, 10, 0,0)
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0,0),
                  child: InkWell(onTap: ()async{
                  //  var url = Uri.parse(AppSettings().Api_link+'editUserName?id='+widget.auth.currentUser.uid+"&&name="+controller.text);
                    var url = Uri.parse(AppSettings().Api_link+'saveProfile?name='+controller.text+"&&uid="+FirebaseAuth.instance.currentUser.uid+"&&email="+"");
                    var response = await http.get(url);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);

                    //update profilr
                  },
                    child: Card( shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0),
                    ),color: Theme.of(context).primaryColor,
                      child: Container(width: MediaQuery.of(context).size.width,
                        child: Center(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Done",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                        )),
                      ),
                    ),
                  ),
                )


              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CreateOrUpDateProfile extends StatefulWidget {
  FirebaseAuth auth;
  dynamic profiel;

  CreateOrUpDateProfile({this.profiel,this.auth,});
  @override
  _CreateOrUpDateProfileState createState() => _CreateOrUpDateProfileState();
}

class _CreateOrUpDateProfileState extends State<CreateOrUpDateProfile> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // if(widget.queryDocumentSnapshot!=null && widget.queryDocumentSnapshot.exists && widget.queryDocumentSnapshot.data()!=null){
    //   setState(() {
    //     controller.text = widget.queryDocumentSnapshot.data()["name"];
    //   });
    //  }
  }
  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController(text: widget.profiel["name"].toString());

    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          // height: 400,
          child: Card( elevation: 10,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3.0),
            ),

            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Welcome  Back to Maulaji Talk",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                ),
                // Stack(
                //   children: [
                //     Align(
                //       alignment:Alignment.center,
                //       child: InkWell(onTap: (){
                //
                //       },child: CircleAvatar(radius: 30,)),
                //     )
                //   ],
                // ),
                TextFormField(controller: controller,
                  decoration: InputDecoration(
                      hintText: "Display name",
                      contentPadding: EdgeInsets.fromLTRB(0, 10, 0,0)
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0,0),
                  child: InkWell(onTap: ()async{
                    var url = Uri.parse(AppSettings().Api_link+'editUserName?id='+widget.auth.currentUser.uid+"&&name="+controller.text);
                    var response = await http.get(url);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);

                    //update profilr
                  },
                    child: Card( shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0),
                    ),color: Theme.of(context).primaryColor,
                      child: Container(width: MediaQuery.of(context).size.width,
                        child: Center(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Done",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                        )),
                      ),
                    ),
                  ),
                )


              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordForgetActivity extends StatefulWidget {
  FirebaseAuth   auth;
  PasswordForgetActivity({this.auth});
  @override
  _PasswordForgetActivityState createState() => _PasswordForgetActivityState();
}

class _PasswordForgetActivityState extends State<PasswordForgetActivity> {
  TextEditingController controller = new TextEditingController();
  // Initially password is obscure
  bool _obscureText = true;

  String _password;

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(
      child: Container(width: 600,

        child: Padding(
          padding: const EdgeInsets.all(60.0),
          child: Wrap(
           // mainAxisAlignment: MainAxisAlignment.center,
           // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Change Password",style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold),),

              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: "Email",
                    contentPadding: EdgeInsets.all(10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 0,0),
                child: Container(decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(3)
                ),

                  width: MediaQuery.of(context).size.width,
                  // height: 400,
                  child: InkWell(
                    onTap: () {

                      widget.auth.sendPasswordResetEmail(email: controller.text,).then((value) {


                        showAlertDialog(context);

                      });

                    },
                    child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Send Email",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        )),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    ),);
  }
}
showAlertDialog(BuildContext context) {

  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      Navigator.pop(context);
     // Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Email Sent"),
    content: Text("Password reset email has been sent to your inbox."),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

String validatePassword(String value) {
  if (!(value.length > 5) && value.isNotEmpty) {
    return "Password should contain more than 5 characters";
  }
  return null;
}