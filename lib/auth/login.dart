import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_schedule/auth/register.dart';
import 'package:my_schedule/box/boxes.dart';
import 'package:my_schedule/main.dart';
import 'package:my_schedule/model/user_model.dart';
import 'package:my_schedule/screens/schedule_screen.dart';
import 'package:my_schedule/shared/alert.dart';
import 'package:my_schedule/shared/button.dart';
import 'package:my_schedule/shared/constants.dart';
import 'package:my_schedule/shared/text_field.dart';
import 'package:my_schedule/shared/validators.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final studentNumberController = TextEditingController();
  final passwordController = TextEditingController();

  final loginFormKey = GlobalKey<FormState>();

  void login() async {
    
    if(loginFormKey.currentState!.validate()) {

      try {

        LoadingDialog.showLoading(context);
        await Future.delayed(const Duration(seconds: 3));
        
        final AuthResponse res = await supabase.auth.signInWithPassword(
          email: studentNumberController.text.toString(),
          password: passwordController.text.toString(),
        );

        final User? user = res.user; // get authenticated user data object 
        final String userId = user!.id;  // get user id

        print("USER UIID::: $userId");
        print("USER ID IN HIVEEE::: ${boxUserCredentials.get("userId")}"); 
        boxUserCredentials.put("userId", userId);

        LoadingDialog.hideLoading(context);
        
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScheduleScreen())
        );


      } on AuthException catch(e) {
        
        Alert.of(context).showError(e.message);
        print("ERROR ::: ${e.code}");
        Navigator.pop(context);

      }
    }
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor: MAROON,
      body: SingleChildScrollView(
        
        child: Column(
          children: [
        
            Container(
              
              // TOP MAROON CONTAINER
              color: MAROON,
              height: MediaQuery.of(context).size.height * 0.5, 


              child: const Column(

                mainAxisAlignment: MainAxisAlignment.center,
                
                children: [
        
                  Text(
                    "Welcome back!",
                    style: TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
        
                  SizedBox(height: 10),
                  
                  Text(
                    "Login in to Continue!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            
            // BOTTOM MAROON CONTAINER
            Container(
              height: MediaQuery.of(context).size.height * 0.6, 
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30)
                ),
                color: Colors.white,
                boxShadow: [

                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.23),
                    blurRadius: 6,
                    spreadRadius: 0,
                    offset: Offset(0, 3),
                  ),
                ],
              ),

              child: Form(
                key: loginFormKey,
                child: Column(
                
                  children: [
                
                    MyTextFormField(
                      controller: studentNumberController,
                      hintText: "Email address",
                      obscureText: false,
                      validator:  Validator.of(context).validateEmail
                    ),
                
                    const SizedBox(height: 20),
                
                    MyTextFormField(
                      controller: passwordController,
                      hintText: "Password",
                      obscureText: false,
                      validator: (value)=> Validator.of(context).validateTextField(value, "Password"),
                    ),
                
                    const SizedBox(height: 20),
                
                    Row(
                
                      mainAxisAlignment: MainAxisAlignment.center,
                
                      children: [
                
                        const Text("Don't have an account? "),
                
                        const SizedBox(width: 18),
                
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterScreen())
                            );
                          },
                          child: const Text(
                            "Register",
                            style: TextStyle(
                              color: MAROON,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                
                        ),
                      ],
                    ),
                
                    const SizedBox(height: 25),
                        
                    MyButton(
                      onTap: () async{
                        login();
                      },
                      buttonName: "Login",
                    ),
                        
                    const SizedBox(height: 15),
                        
                    const Text(
                      "Your initial password is your birthdate\nin this format YYYY-MM-DD",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
