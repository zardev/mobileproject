import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:mon_agenda_partage/api/fire_auth.dart';
import 'package:mon_agenda_partage/ui/calendar/month/month_view.dart';
import 'package:mon_agenda_partage/ui/create_account/create_account_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mon_agenda_partage/ui/shared/ui_helpers.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {

  final _formKey = GlobalKey<FormState>();

  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  bool _isProcessing = false;

  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MonthView(),
        ),
      );
    }

    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Firebase Authentication'),
        ),
        body: SingleChildScrollView(
          child: FutureBuilder(
            future: _initializeFirebase(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Padding(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Text(
                          'Login',
                          style: Theme.of(context).textTheme.headline1,
                        ),
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            AuthenticationFormField(_emailTextController, _focusEmail, "Email"),
                            SizedBox(height: 8.0),
                            AuthenticationFormField(_passwordTextController, _focusPassword, "Password"),
                            SizedBox(height: 24.0),
                            _isProcessing
                                ? CircularProgressIndicator()
                                : Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      _focusEmail.unfocus();
                                      _focusPassword.unfocus();

                                      if (_formKey.currentState!
                                          .validate()) {
                                        setState(() {
                                          _isProcessing = true;
                                        });

                                        User? user = await FireAuth
                                            .signInUsingEmailPassword(
                                          email: _emailTextController.text,
                                          password:
                                          _passwordTextController.text,
                                        );

                                        setState(() {
                                          _isProcessing = false;
                                        });

                                        if (user != null) {
                                          Navigator.of(context)
                                              .pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MonthView(),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: Text(
                                      'Sign In',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 24.0),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CreateAccountView(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Register',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }

              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
    );
  }
}
