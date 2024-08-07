
import 'package:bionic_interface/general_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import 'data_plot.dart';
import 'package:bionic_interface/firebase_handler.dart';
import 'package:bionic_interface/data_handling/ble_interface.dart';

///A screen that includes both ways to change the current hand configurations
///as well as saving/loading ones related to the hand to/from the database
class ConfigScreen extends StatefulWidget{
  const ConfigScreen({super.key});


  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen>{

  late FirebaseHandler firebaseHandler;
  late GeneralHandler generalHandler;
  late BleInterface bleInterface;

  List<OnlineConfig> onlineConfigs = [];

  @override
  void initState() {
    super.initState();
    firebaseHandler = Provider.of<FirebaseHandler>(context, listen: false);
    generalHandler = Provider.of<GeneralHandler>(context, listen: false);
    bleInterface = Provider.of<BleInterface>(context, listen: false);
    if(bleInterface.connected){refreshConfigs();}
  }

  ///This refreshes the buffer used for displaying the available firebase configs
  void refreshConfigs() async{
    List<QueryDocumentSnapshot> tempList = await firebaseHandler.getHandConfigs(bleInterface.deviceSerialNumber!);
    onlineConfigs.clear();

    for(var item in tempList){
      dynamic tempData = item.data();
      onlineConfigs.add(OnlineConfig(
          documentID: item.id,
          userID: tempData["userID"],
          configName: tempData["configName"],
          config: tempData["config"],
          clinician: tempData["clinician"],
          dateSaved: tempData["date"]));
    }
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {

    if (!bleInterface.connected){
      return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: (){
              context.go("/");
            },
          ),
          title: const Text("Config"),
          actions: [
            const SizedBox.shrink(),
            IconButton(
                icon: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                iconSize: 50,
                padding: EdgeInsets.zero,
                onPressed: (){
                  if(Provider.of<FirebaseHandler>(context, listen: false).loggedIn){
                    context.go("/profile");
                  }
                  else{
                    context.go("/sign-in");
                  }
                }
            ),
            const SizedBox(width: 10,)
          ],
        ),
        body: const Text("No device connected, configs cannot be shown"),
      );
    }

    else if(!firebaseHandler.loggedIn){
      return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: (){
              context.go("/");
            },
          ),
          title: const Text("Config"),
          actions: [
            const SizedBox.shrink(),
            IconButton(
                icon: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                iconSize: 50,
                padding: EdgeInsets.zero,
                onPressed: (){
                  if(Provider.of<FirebaseHandler>(context, listen: false).loggedIn){
                    context.go("/profile");
                  }
                  else{
                    context.go("/sign-in");
                  }
                }
            ),            const SizedBox(width: 10,)
          ],
        ),
        body: const Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //Set configs manually
            AdvancedSettingsScreen(), // <this should only be available when logged in?
            //Firebase config interface
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("User not logged in, please click on the Icon in the top Right corner to log in"),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: (){
            context.go("/");
          },
        ),
        title: const Text("Config"),
        actions: [
          const SizedBox.shrink(),
          IconButton(
              icon: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
              iconSize: 50,
              padding: EdgeInsets.zero,
              onPressed: (){
                if(Provider.of<FirebaseHandler>(context, listen: false).loggedIn){
                  context.go("/profile");
                }
                else{
                  context.go("/sign-in");
                }
              }
          ),
          const SizedBox(width: 10,)
        ],
      ),
      body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Set configs manually
              const AdvancedSettingsScreen(), // <this should only be available when logged in?
              //Firebase config interface
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      onPressed: () async{
                        await showDialog(
                            context: context,
                            builder: (context) =>
                                addConfigDialog()
                        );
                        refreshConfigs();
                      },
                      icon: const Icon(Icons.add)
                  ),
                  const Text("Online Configs", style: TextStyle(fontSize: 30),),
                  IconButton(
                      onPressed: (){
                        refreshConfigs();
                      },
                      icon: const Icon(Icons.refresh)
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: onlineConfigs.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index){
                    OnlineConfig config = onlineConfigs[index];
                    return ListTile(
                      title: Column(
                        children: [
                          Text(config.configName, style: const TextStyle(fontSize: 20),),
                          Text(config.dateSaved.toDate().toString()),
                        ],
                      ),
                      leading: Image.asset('assets/images/logo.png', fit: BoxFit.contain, height: 50,),
                      //TODO: this should be used to indicate if a config is saved by the user or someone else
                      onTap: (){
                        print("Change name");
                      },
                      onLongPress: (){
                        print("Set as thing");
                      },
                    );
                  }
              ),
              // select one to override the current settings
                // or change the name of one?
                // or delete one, but thats only possible if you are the author
              // save current config and give it a name
              //
            ],
          )
      ),
    );
  }


  Dialog addConfigDialog(){
    var controller = TextEditingController();
    String defaultName = "Default Name";
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Config Name"),
            TextField(
              controller: controller,
              onSubmitted: (String value) async{
                if(value.isEmpty){
                  controller.text = defaultName;
                }
              },
            ),
            TextButton(
              onPressed: () {
                if(controller.text.isEmpty){
                  controller.text = defaultName;
                }
                firebaseHandler.saveNewConfig("0123456789", "newConfigJSON", controller.text);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

}

/// just an easier representation of the online configs
class OnlineConfig{

  OnlineConfig({
    required this.documentID,
    required this.userID,
    required this.configName,
    required this.config,
    required this.clinician,
    required this.dateSaved,
  });

  String documentID = "";
  String userID = "";
  bool clinician = false;
  String config = "";
  String configName = "";
  Timestamp dateSaved = Timestamp(0,0);
}