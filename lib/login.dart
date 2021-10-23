import 'package:flutter/material.dart';
import 'package:rauschmelder/drink_selection.dart';
import 'package:rauschmelder/user_state.dart';

class LoginPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final UserModel model;

  LoginPage({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                    hintText: "Dein Spitzname"
                ),
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
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => DrinkSelectionPage(model: model)
                      ));
                    }
                  },
                  child: const Text('Weiter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
