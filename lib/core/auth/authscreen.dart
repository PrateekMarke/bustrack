import 'package:bustrack/const/color_pallet.dart';
import 'package:bustrack/core/auth/authform.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(title: Text("Bus Application - Login/Signup"),backgroundColor: AppColors.appbarColor,),
          body: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: "Student"),
                  Tab(text: "Driver"),
                  Tab(text: "Admin"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    AuthForm(userType: "Student"),
                    AuthForm(userType: "Driver"),
                    AuthForm(userType: "Admin"),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
