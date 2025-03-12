
import 'package:bustrack/const/color_pallet.dart';
import 'package:bustrack/const/spacing.dart';
import 'package:bustrack/view/auth/auth_controller.dart';
import 'package:bustrack/widget/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: Spacing.screenSpacing.copyWith(top: 50),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Admin SignUp',
                  style: TextStyle(fontSize: 30),
                ),
                const SizedBox(height: 64),
                CustomTextField(
                  controller: nameController,
                  hintText: 'Name',
                  textInputType: TextInputType.text,
                  isPass: false,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: emailController,
                  hintText: 'Email Address',
                  textInputType: TextInputType.text,
                  isPass: false,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: passController,
                  hintText: 'Password',
                  textInputType: TextInputType.text,
                  isPass: true,
                ),
                const SizedBox(height: 24),
                Consumer<AuthController>(builder: (context, value, child) {
                  return FilledButton(
                      onPressed: () async {
                        value.createAccount(
                            nameController.text,
                            emailController.text,
                            passController.text,
                            context,
                            'Admin',
                            '');
                      },
                      child: value.isLoading == true
                          ? Center(
                              child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ))
                          : const Text('Sign Up'));
                }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 60,
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
