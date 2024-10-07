import 'package:flutter/material.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:my_schedule/auth/auth.dart';
import 'package:my_schedule/box/boxes.dart';
import 'package:my_schedule/main.dart';

const MAROON = Color(0xFF862349);
const WHITE = Color(0xFFFFFFFF);
const LIGHTGRAY = Color(0xFFECECEC);
const GRAY = Color(0xFF8F8E8E);
Widget vSpacerWidth(double width) {

  return SizedBox(

    height: width,

  );
}

class SpacerClass extends StatelessWidget {
  const SpacerClass({super.key, required this.height, required this.width});

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
    );
  }
}


class LoadingDialog {
  static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents dismissing by tapping outside
      builder: (context) {
        return Center(
          child: LoadingAnimationWidget.fourRotatingDots(
            color: MAROON,
            size: 60,
          ),
        );
      },
    );
  }

  static void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop(); // Dismiss the dialog
  }
}

class DrawerClass extends StatelessWidget {
  const DrawerClass({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset('assets/images/emoji.png'),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Developers'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help_center_rounded),
            title: const Text('FAQ'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout_outlined  ),
            title: const Text('Sign Out'),
            onTap: () async{
              await supabase.auth.signOut();
              boxUserCredentials.clear();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen())
              );
            },
          ),
        ],
      ),
    );
  }
}