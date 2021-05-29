import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:maulajimessenger/login.dart';
import 'package:maulajimessenger/services/Auth.dart';

class CreateAccount extends StatefulWidget {
  final FirebaseAuth auth;
  bool hidePass = true ;

   CreateAccount({
    Key key,
    @required this.auth,
  }) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<CreateAccount> {
  bool isBusy = false ;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          color: Colors.white,
          child: Container(
            width: 400,
            // height: 400,
            child: Padding(
              padding: const EdgeInsets.all(60.0),
              child: Builder(builder: (BuildContext context) {
                return Wrap(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Image.asset(
                    //   "assets/stahtlogogreen.jpg",
                    //   height: 100,
                    // ),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          "Maulaji Talk - Create Account",
                          style: TextStyle(fontSize: 20),
                        )),
                    TextFormField(
                      textAlign: TextAlign.left,
                      decoration:
                          const InputDecoration(hintText: "Display Name"),
                      controller: _displayNameController,
                    ),
                    TextFormField(
                      textAlign: TextAlign.left,
                      decoration: const InputDecoration(hintText: "Email"),
                      controller: _emailController,
                    ),
                    Container(height:50 ,width: 280,
                      child: Stack(
                        children: [


                          Positioned(
                            left: 0,
                            right: 0,

                            child: Container(
                              child: TextFormField(
                                validator: (value) => validatePassword(value),
                                textAlign: TextAlign.left,
                                obscureText: widget.hidePass,
                                decoration:
                                const InputDecoration(hintText: "Password"),
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
                                    widget.hidePass = ! widget.hidePass;
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
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        color: Theme.of(context).primaryColor,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: InkWell(
                                onTap: () async {
                                  //TODO
                                  setState(() {
                                    isBusy = true ;
                                  });
                                  final bool retVal = await Auth(
                                          auth: widget.auth)
                                      .createAccount(
                                          email: _emailController.text,
                                          password: _passwordController.text,
                                          name: _displayNameController.text,
                                          context: context);

                                  if (retVal) {
                                    _emailController.clear();
                                    _passwordController.clear();
                                    _displayNameController.clear();

                                    // await widget.auth.currentUser.updateProfile(displayName: _displayNameController.text);
                                    Navigator.of(context).pop();
                                  } else {
                                    setState(() {
                                      isBusy = true ;
                                    });
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                        content: Text("Sign up failed.Email is allready used.Try login or forget password")));
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    isBusy?"Please wait": "Create an Account",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
