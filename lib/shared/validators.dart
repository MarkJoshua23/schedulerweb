import 'package:flutter/material.dart';
class Validator {
  BuildContext context;
  Validator.of(this.context);
  

  // STUDENT NO.
  String? validateStudentNumber(String? studentNumber) {
    // RegExp studentNumberRegex = RegExp(r'^A\d{2}-\d{4}$');
    RegExp studentNumberRegex = RegExp(r'^A\d{2}-\d{4}$', caseSensitive: false);
    final isStudentNumberValid = studentNumberRegex.hasMatch(studentNumber ?? '');
    if (studentNumber.toString().isEmpty) {
      return 'Student number cannot be empty';
    }
    if (!isStudentNumberValid) {
      return 'Please enter a valid student number';
    }
    return null;
  }

  // EMAIL
  String? validateEmail(String? email) {
    RegExp emailRegex = RegExp(r'^[\w\.-]+@[\w-]+\w{2,3}(\.\w{2,3})?$');
    final isEmailValid = emailRegex.hasMatch(email ?? '');
    if( email.toString().isEmpty) {
      return 'Email cannot be empty';
    }
    if(!isEmailValid) {
      return 'Please enter a valid email';
    } 
    return null;
  }

  // CONFIRM EMAIL
  String? validateConfirmEmail(String? email, String? originalEmail) {
    RegExp emailRegex = RegExp(r'^[\w\.-]+@[\w-]+\w{2,3}(\.\w{2,3})?$');
    final isEmailValid = emailRegex.hasMatch(email ?? '');

    if(email.toString().isEmpty) {
      return 'Email cannot be empty';
    }
    if( email.toString() != originalEmail.toString()) {
      return 'Please ensure that both email addresses match. ';
    }
    if(!isEmailValid) {
      return 'Please enter a valid email';
    } 
    return null;
  }
  

  // VALIDATE NORMAL TEXT FIELD 
  String? validateTextField(String? value, String fieldName) {
    if(value.toString().isEmpty) {
      return '$fieldName cannot be empty';
    }
    if(value.toString().length <= 1) {
      return '$fieldName must be more than one character';
    }
    if(value.toString().isEmpty || value == null ) {
      return '$fieldName must be more than one character';
    }
    return null;
  }


}