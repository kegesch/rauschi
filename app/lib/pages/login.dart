import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rauschmelder/pages/drink_selection.dart';
import 'package:rauschmelder/widgets/login/login_form.dart';
import 'package:rauschmelder/widgets/user/user_state.dart';

import '../widgets/user/bloc/user_bloc.dart';

class LoginPage extends StatelessWidget {
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
            return const LoginForm();
          }
        ),
      ),
    );
  }
}
