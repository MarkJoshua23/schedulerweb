import 'package:flutter/material.dart';
import 'package:my_schedule/auth/auth.dart';
import 'package:my_schedule/main.dart';
import 'package:my_schedule/shared/button.dart';
import 'package:my_schedule/shared/text_field.dart';

class StudentScreen extends StatefulWidget {
  
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {

  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              "STUDENT'S SCREEN",
              style: TextStyle(fontSize: 30),
            ),

            const SizedBox(height: 20),
            
            MyTextFormField(
              controller: _emailController,
              hintText: "Email",
              obscureText: false
            ),
            const SizedBox(height: 20),

            MyButton(
              onTap: () async{
                
              },
              buttonName: "Reset Password"
            ),

            const SizedBox(height: 20),

            MyButton(
              onTap: () async{

                await supabase.auth.signOut();

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen())
                );
                
              },
              buttonName: "Log out"
            )
            
          ],
        ),
      ),
    );
  }
}