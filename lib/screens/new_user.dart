//This page should be used to set up different users/profiles
import 'package:bionic_interface/general_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

class NewUserPage extends StatefulWidget{
  const NewUserPage({super.key});

  @override
  State<NewUserPage> createState() => _NewUserPageState();
}

class _NewUserPageState extends State<NewUserPage>{
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  bool saveCurrentState = true;

  void acknowledgeNewUser(String username){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("New Profile created: $username")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      actions: [
        ForgotPasswordAction((context, email) {
          //This is taken from the codelab
          final uri = Uri(
            path: '/sign-in/forgot-password',
            queryParameters: <String, String?>{
              'email': email,
            },
          );
          //context.push(uri.toString()); //TODO THIS NEEDS FIXED
        }),
        AuthStateChangeAction(((context, state) {
          final user = switch (state) {
            SignedIn state => state.user,
            UserCreated state => state.credential.user,
            _ => null
          };
          if (user == null) {
            return;
          }
          if (state is UserCreated) {
            user.updateDisplayName(user.email!.split('@')[0]);
          }
          if (!user.emailVerified) {
            user.sendEmailVerification();
            const snackBar = SnackBar(
                content: Text(
                    'Please check your email to verify your email address'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
          // context.pushReplacement('/'); //TODO THIS NEEDS REPLACEMENT
        })),
      ],
    );
      /*
      Scaffold(
      appBar: AppBar(
        title: const Text("New User"),
        actions: [
          const SizedBox.shrink(),
          Image.asset('assets/images/logo.png', fit: BoxFit.contain, height: 50,),
          const SizedBox(width: 10,)
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // Add TextFormFields and ElevatedButton here.
              TextFormField(
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                controller: usernameController,
                decoration: const InputDecoration(label: Text("Username")),
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text("Apply current app settings to Profile"),
                  Switch.adaptive(
                      value: saveCurrentState,
                      onChanged: (bool newValue){
                        setState(() {
                          saveCurrentState = newValue;
                        });
                      }
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              ElevatedButton(
                onPressed: () async {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    await Provider.of<GeneralHandler>(context, listen: false).newUser(
                        username: usernameController.text,
                        saveCurrentSettings: saveCurrentState);
                    acknowledgeNewUser(usernameController.text);
                  }
                },
                child: const Text('Create Profile'),
              ),
            ],
          ),
        ),
      ),
    );

       */
  }
}