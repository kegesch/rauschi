import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/login_bloc.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

void _showError(String error) {
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _autoValidate = false;

  @override
  Widget build(BuildContext context) {
    final loginBloc = BlocProvider.of<LoginBloc>(context);

    onLoginButtonPressed() {
      if (_key.currentState != null && _key.currentState!.validate()) {
        loginBloc.add(LoginWithUserNameButtonPressed(
          userName: _usernameController.text,
        ));
      } else {
        setState(() {
          _autoValidate = true;
        });
      }
    }
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStateStatus.error) {
          _showError(state.error);
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          if (state.status == LoginStateStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Form(
            key: _key,
            autovalidateMode: _autoValidate
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                          hintText: "Dein Spitzname"),
                      controller: _usernameController,
                      autocorrect: false,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Bitte gebe einen Namen ein';
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(

                        onPressed: state.status == LoginStateStatus.loading
                            ? () {}
                            : onLoginButtonPressed,
                        child: const Text('Weiter'),
                      ),
                    ),
                  ],
                )
            ),
          );
        },
      ),
    );
  }
}