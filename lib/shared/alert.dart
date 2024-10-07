import 'package:flutter/material.dart';

class Alert {

  BuildContext context;
  Alert.of(this.context);

  // show an error message
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            
            const Icon(Icons.error, color: Colors.white),
      
            const SizedBox(width: 13),
      
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 11
                ),

              ),
            ),
          ],
        ),
        backgroundColor:  Colors.red.shade900,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14)
        ),
      ),
    );
  }

  // show success message
  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
      
            const SizedBox(width: 13),
      
            Expanded(
              child: Text(
                
                message,
                style: const TextStyle(
                  fontSize: 11,
                  
                  
                ),
              ),
            ),
          ],
        ),
        backgroundColor:  Colors.green,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14)
        ),
      ),
    );
  }
}