

import 'package:bustrack/const/color_pallet.dart';
import 'package:bustrack/const/spacing.dart';
import 'package:bustrack/view/auth/auth_controller.dart';
import 'package:bustrack/view/auth/login_screen.dart';
import 'package:bustrack/view/auth/student_sign_up_screen.dart';
import 'package:bustrack/widget/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentLoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            child: const Text(
              'Admin Login',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: Spacing.screenSpacing,
            width: double.infinity,
            child: IntrinsicHeight(
              // <-- Added this
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 2,
                    child: Container(),
                  ),
                  Text(
                    'Student Login',
                    style: TextStyle(fontSize: 30),
                  ),
                  const SizedBox(height: 64),
                  CustomTextField(
                    controller: _emailController,
                    hintText: 'Email Address',
                    textInputType: TextInputType.text,
                    isPass: false,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    textInputType: TextInputType.text,
                    isPass: true,
                  ),
                  const SizedBox(height: 24),
                  Consumer<AuthController>(builder: (context, value, child) {
                    return FilledButton(
                        onPressed: () async {
                          final authService = Provider.of<AuthController>(
                              context,
                              listen: false);
                          await authService.signInWithEmail(
                              _emailController.text,
                              _passwordController.text,
                              context);
                        },
                        child: value.isLoading == true
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryColor,
                                ),
                              )
                            : const Text('Submit'));
                  }),
                  Flexible(
                    flex: 2,
                    child: Container(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: TextStyle(color: AppColors.primaryColor),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StudentSignUpScreen()));
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 60,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
