import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_schedule/auth/login.dart';
import 'package:my_schedule/box/boxes.dart';
import 'package:my_schedule/main.dart';
import 'package:my_schedule/model/section_model.dart';
import 'package:my_schedule/screens/schedule_screen.dart';
import 'package:my_schedule/screens/student_screen.dart';
import 'package:my_schedule/shared/alert.dart';
import 'package:my_schedule/shared/button.dart';
import 'package:my_schedule/shared/constants.dart';
import 'package:my_schedule/shared/text_field.dart';
import 'package:my_schedule/shared/validators.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterNewState();
}

class _RegisterNewState extends State<RegisterScreen> {

  @override
  initState() {
    // TODO: implement initState
    super.initState();
    getAllAvailableSections();
  }

  final _studentNumberController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _sectionController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _emailController = TextEditingController();
  final _confirmEmailController = TextEditingController();

  final registerFormKey = GlobalKey<FormState>();

  // FUNCTION TO CREATE A NEW ACCOUNT
  void registerAccount () async{
    
    if(registerFormKey.currentState!.validate()) {

      try{

        LoadingDialog.showLoading(context);
        await Future.delayed(const Duration(seconds: 2));

        final AuthResponse res = await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _birthDateController.text.trim(),
        );

        final User? user = res.user; // get authenticated user data object 
        final String userId = user!.id;  // get user id

        print("NEW USER UIID::: $userId");
        boxUserCredentials.put("userId", userId);
        
        await createUser(
          _studentNumberController.text.trim(),
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
          _sectionController.text.trim(),
          _birthDateController.text.trim(),
          _emailController.text.trim(), 
          userId
        );



        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScheduleScreen())
        );


      } on AuthException catch(e) {
        LoadingDialog.hideLoading(context);
        Alert.of(context).showError(e.message);
        print("ERROR ::: ${e.code}");

      }
    }

    
    

  }   

  // FUNCTION TO INSERT THE NEW USER INTO THE DB
  createUser(idNumber, firstName, lastName, section, birthdate, email, userId ) async {
    await Supabase.instance.client
    .from('tbl_users')
    .insert({
      'first_name': firstName,
      'last_name' : lastName,
      'email' : email,
      'section' : section,
      'id_number' : idNumber,
      'user_type' : 'student',
      'birthday' : birthdate,
      'auth_id' : userId
    });

    print("USER CREATED SUCCESSFULLY");
  }

  DateTime birthDay = DateTime.now();
  selectDate() async{

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: birthDay,
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      birthDay = picked;

      int year = birthDay.year;
      int month = birthDay.month;
      int day = birthDay.day;

      String formattedBirthDay = "$year-$month-$day"; 
      _birthDateController.text = formattedBirthDay;

      print('BIRTHDAYYYY $formattedBirthDay'); 
    }
  }



  // Function to show the section picker
  // List of sections

  final List<String> _sections = [];
  Future<void> getAllAvailableSections() async {
    
    try{
      
      final selectAllSection = await 
      Supabase.instance.client
      .from('tbl_section')
      .select();
      
      for(var s in selectAllSection) {
        var section = SectionModel(
          sectionName: s['section']
        );

        _sections.add(s['section']);
      }

      for(var s in _sections) {
        print("SECTION ::: $s");
      }
     
      
    } catch (e) {

      print("ERROR ::: $e");

    }

  }

  

  Future<void> selectSection() async {
    // Show the Cupertino modal popup
    await showCupertinoModalPopup<String>(
      context: context,
      builder: (_) {
        return SizedBox(
          width: double.infinity,
          height: 250,
          child: CupertinoPicker(
            onSelectedItemChanged: (int value) {
              
              setState(() {
                _sectionController.text = _sections[value];
              });
              print('SECTION :::: ${_sections[value]}'); 
            },
            backgroundColor: Colors.white,
            itemExtent: 30,
            scrollController: FixedExtentScrollController(
              initialItem: 0, 
            ),
            children: _sections.map((section) => Text(section)).toList(),
          ),
        );
      },
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: MAROON,
      body: SingleChildScrollView(
        child: Column(
          children: [
            
            // TOP WHITE CONTAINER
            Container(

              color: MAROON,
              height: MediaQuery.of(context).size.height * 0.2, 

              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,         
                children: [

                  SizedBox(height: 50),

                  Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 37,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
        
                  SizedBox(height: 10),
                ],
              ),
            ),
        
            // BOTTOM WHITE CONTAINER
            Container(
              
              height: MediaQuery.of(context).size.height * 0.8, 
              // padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              padding: const EdgeInsets.symmetric( horizontal: 20),
              
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
                key: registerFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      
                      const SizedBox(height: 40),

                      MyTextFormField(
                        controller: _studentNumberController,
                        hintText: "Student Number",
                        obscureText: false,
                        validator: Validator.of(context).validateStudentNumber,
                      ),
                  
                      const SizedBox(height: 20),
                  
                  
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          children: [
                            Expanded(
                              child: MyTextFormFieldForName(
                                controller: _firstNameController,
                                hintText: "First Name",
                                obscureText: false,
                                validator: (value)=> Validator.of(context).validateTextField(value, "First name"),
                              ),
                            ),
                  
                            const SizedBox(width: 5),
                  
                            Expanded(
                              child: MyTextFormFieldForName(
                                controller: _lastNameController,
                                hintText: "Last Name",
                                obscureText: false,
                                validator: (value)=> Validator.of(context).validateTextField(value, "Last name"),
                              ),
                            ),
                        
                        
                          ],
                        ),
                      ),
                  
                  
                      
                      const SizedBox(height: 20),
                  
                  
                  
                      ReadOnlyTextFormField(
                        onTap: selectSection,
                        controller: _sectionController,
                        hintText: "Section",
                        obscureText: false,
                        validator: (value)=> Validator.of(context).validateTextField(value, "Birth Date"),
                      ),
                      const SizedBox(height: 20),
                  
                      ReadOnlyTextFormField(
                        onTap: () => selectDate(),
                        controller: _birthDateController,
                        hintText: "Birthdate",
                        obscureText: false,
                        validator: (value)=> Validator.of(context).validateTextField(value, "Section"),
                      ),
                      const SizedBox(height: 20),
                      
                      MyTextFormField(
                        controller: _emailController,
                        hintText: "Email addres",
                        obscureText: false,
                        validator: Validator.of(context).validateEmail,
                      ),
                      const SizedBox(height: 20),
                      
                      MyTextFormField(
                        controller: _confirmEmailController,
                        hintText: "Confirm email address",
                        obscureText: false,
                        validator: (value)=> Validator.of(context).validateConfirmEmail(value, _emailController.text)
                      ),
                      const SizedBox(height: 20),
                  
                  
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? "),
                          const SizedBox(width: 18),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen())
                              );
                            },
                            child: const Text(
                              "Log in",
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
                        onTap: () {
                          registerAccount();
                        },
                        buttonName: "Create",
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}