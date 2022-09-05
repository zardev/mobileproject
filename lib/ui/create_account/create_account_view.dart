import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mon_agenda_partage/api/fire_auth.dart';
import 'package:mon_agenda_partage/ui/calendar/month/month_view.dart';
import 'package:mon_agenda_partage/ui/create_account/create_account_viewmodel.dart';
import 'package:mon_agenda_partage/ui/shared/ui_helpers.dart';
import 'package:stacked/stacked.dart';

class CreateAccountView extends StatefulWidget {
  @override
  _CreateAccountViewState createState() => _CreateAccountViewState();
}

class _CreateAccountViewState extends State<CreateAccountView> {

  final _registerFormKey = GlobalKey<FormState>();

  final _nameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  final _focusName = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusName.unfocus();
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Register'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Form(
                    key: _registerFormKey,
                    child: Column(
                      children: <Widget>[
                        AuthenticationFormField(_nameTextController, _focusName, "Name"),
                        verticalSpaceRegular,
                        AuthenticationFormField(_emailTextController, _focusEmail, "Email"),
                        verticalSpaceRegular,
                        AuthenticationFormField(_passwordTextController, _focusPassword, "Password"),
                        verticalSpaceMedium,
                        _isProcessing
                            ? CircularProgressIndicator()
                            : Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    _isProcessing = true;
                                  });

                                  if (_registerFormKey.currentState!
                                      .validate()) {
                                    User? user = await FireAuth
                                        .registerUsingEmailPassword(
                                      name: _nameTextController.text,
                                      email: _emailTextController.text,
                                      password:
                                      _passwordTextController.text,
                                    );

                                    setState(() {
                                      _isProcessing = false;
                                    });

                                    if (user != null) {
                                      Navigator.of(context)
                                          .pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MonthView(),
                                        ),
                                        ModalRoute.withName('/'),
                                      );
                                    }
                                  }
                                },
                                child: Text(
                                  'Sign up',
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
            ),
          ),
        ),
      ),
    );
  }
}
