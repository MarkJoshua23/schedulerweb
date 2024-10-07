
import 'package:flutter/material.dart';
import 'package:my_schedule/shared/constants.dart';

// class MyButton extends StatelessWidget {
//   const MyButton({super.key, required this.onTap, required this.buttonName});

//   final void Function()? onTap;
//   final String buttonName;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 21),
//         margin: const EdgeInsets.symmetric(horizontal: 30),
//         decoration: const BoxDecoration(
//           borderRadius: BorderRadius.all(Radius.circular(10)),
//           color: Color(0xFF9e0b0f)
//         ),
//         child: Center(
//           child: Text(
//             buttonName,
//             style: const TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.w700,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



class MyButton extends StatelessWidget {
  const MyButton({super.key, required this.onTap, required this.buttonName});

  final void Function()? onTap;
  final String buttonName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: onTap,
        style: ButtonStyle(
          padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 10)),
          backgroundColor: MaterialStatePropertyAll(MAROON),
          foregroundColor: MaterialStatePropertyAll(WHITE),
          shape: MaterialStateProperty.all(

            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              
            )
          )
        ),
        child: Text(buttonName, style: const TextStyle(fontSize: 18)),
        
      ),
    );
  }
}

//  Container(
//         padding: 
//         margin: const EdgeInsets.symmetric(horizontal: 30),
//         decoration: const BoxDecoration(
//           borderRadius: BorderRadius.all(Radius.circular(10)),
//           color: 
//         ),
//         child: Center(
//           child: Text(
//             buttonName,
//             style: const TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.w700,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),



