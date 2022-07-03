import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rauschmelder/pages/drink_selection.dart';
import 'package:rauschmelder/widgets/user/user_state.dart';

import '../widgets/user/bloc/user_bloc.dart';

class LoginPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final UserModel model;

  LoginPage({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            context.read<UserBloc>().stream.listen((state) {
              if(state.status == UserStateStatus.success) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            DrinkSelectionPage(model: model)));
              }
            });
            return Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(hintText: "Dein Spitzname"),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte gebe einen Namen ein';
                    }
                    return null;
                  },
                  onSaved: (value) => model.setUserName(value),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Validate will return true if the form is valid, or false if
                      // the form is invalid.
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        context.read<UserBloc>().add(RegisterUser(userName: model.userName));
                      }
                    },
                    child: const Text('Weiter'),
                  ),
                ),
              ],
            ),
          );
          }
        ),
      ),
    );
  }
}
