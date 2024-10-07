import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:my_schedule/model/user_model.dart';
import 'package:my_schedule/screens/student_screen.dart';
import 'package:my_schedule/screens/teacher_screen.dart';
import 'package:my_schedule/shared/button.dart';
import 'package:my_schedule/shared/constants.dart';
import 'package:my_schedule/shared/text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final studentNumberController = TextEditingController();
  final passwordController = TextEditingController();
  List<UserModel> listOfUsers = [];

  Future<void>fetchData() async{

    try{

      final response =  await Supabase.instance.client
      .from('tbl_schedule')
      .select();
      
      print(response);

 
      print("FETCH DONE");


    } catch(e) {

      print("ERROR ::: $e");

    }
 
  }

  void logIn(String idNumber, String password) async{
    
    bool isStudent = true;
    try{
      
      showDialog(
        context: context,
        builder: (context) {
          Future.delayed(const Duration(seconds: 3));
          return  Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: const Color.fromARGB(255, 170, 0, 0),
                size: 60,
              )
            );
        },
      );
      
      // query specific user
      final checkUser =  await Supabase.instance.client
      .from('tbl_users')
      .select()
      .eq('id_number', idNumber)
      .eq('birthday', password);
  
      // check the user type
      // if section has value "isStudent" variable stays true
      for(var u in checkUser) {
        u['section']!= null ? isStudent : isStudent = false;
      }

      Navigator.pop(context);
      
      print("USER ::: $checkUser");
      // go to specified screen
      isStudent ? 
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StudentScreen())
        )
      :
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TeacherScreen())
        );
      print("LOGGED IN SUCESSFULLY");
    

    }catch(e) {

      Navigator.pop(context);
      print("ERROR ::: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid student number or password")),
      );

    }

  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome Back!",
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w700,
                color: MAROON
              ),
            ),

            const Text(
              "Sign in to Continue!",
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w700,
                color: MAROON
              ),
            ),

            const SpacerClass(height: 50, width: 0),
            const Text(
              "I.D Number",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: GRAY
              ),
            ),

            const SpacerClass(height: 5, width: 0),
            MyTextFormField(
              controller: studentNumberController, 
              hintText: "Student Number", 
              obscureText: false,
            ),

            const SpacerClass(height: 30, width: 0),

            const Text(
              "Password",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: GRAY
              ),
            ),

            const SpacerClass(height: 5, width: 0),

            MyTextFormField(
              controller: passwordController, 
              hintText: "Password", 
              obscureText: false,
            ),
            

            const SpacerClass(height: 15, width: 0),

            const Text(
              "Your initial password is your birthdate\nin this format YYYY-MM-DD",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black
              ),
              textAlign: TextAlign.center,
            ),

            const SpacerClass(height: 10, width: 0),

            GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context, 
                //   MaterialPageRoute(builder: (context) => const ForgotPasswordPage())
                // );
              },
              child: const Text(
                'Forgot Password ?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: MAROON
                ),
                
              ),
            ),

            const SpacerClass(height: 15, width: 0),
            
            MyButton(
              onTap: () async {
                logIn(
                  studentNumberController.text,
                  passwordController.text
                ); 

              },
              buttonName: "Login"
            ),

            const SpacerClass(height: 15, width: 0),

            Column(
              children: [
        
                const Text(
                  "Don't have an account? ",
                  style: TextStyle(
                    fontSize: 12
                  ),
                ),
        
                const SizedBox(width: 30),
        
                GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => const RegisterNew()) //signup
                    // );
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
            )

          ],
        ),
      ),
    );
  }
}