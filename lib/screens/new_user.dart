//This page should be used to set up different users/profiles
import 'package:flutter/material.dart';

class NewUserPage extends StatefulWidget{
  const NewUserPage({super.key});

  @override
  State<NewUserPage> createState() => _NewUserPageState();
}

class _NewUserPageState extends State<NewUserPage>{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: (){
            Navigator.popAndPushNamed(context, "/home");
          },
        ),
        title: const Text("New User"),
        actions: [
          const SizedBox.shrink(),
          Image.asset('assets/images/logo.png', fit: BoxFit.contain, height: 50,),
          const SizedBox(width: 10,)
        ],
      ),
      body: const Text("Nothing here yet"),
    );
  }
}