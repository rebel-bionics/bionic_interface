import 'package:bionic_interface/user/user.dart';
import 'package:flutter/cupertino.dart';
import 'app_database.dart';
import 'package:bionic_interface/grip_trigger_action.dart';
import 'package:drift/drift.dart' hide Trigger;
import 'package:bionic_interface/general_handler.dart';
import 'package:provider/provider.dart';
import 'package:bionic_interface/grip_trigger_action.dart';


/// a class to handle all interactions with the AppDb class,
/// so that it is only direct connection to the DB and this handles all else
class DbInterface{


  final _db = AppDb();

  //TODO: figure out good method to initialize and dispose of db
  //TODO: complete the class

  Future<bool> checkUsernameAvailability(String newUsername) async{
    """ Returns true if username is not in table, false otherwise """;
    
    return await _db.getUser(newUsername) == null;
  }


  Future<User?> constructUserFromDb(BuildContext context, String userName, String password) async{
    """ Returns an instance of User from the database. 
    Returns null if username and password do not match. 
    """;
    final generalHandler = Provider.of<GeneralHandler>(context, listen: false);
    final grips = generalHandler.gripPatterns;
    final triggers = generalHandler.triggers;
    final userData = await _db.getUser(userName);

    if(userData!=null){
      return User.fromDb(
          userName: userData.userName,
          password: userData.password,
          name: userData.name,
          email: userData.email,
          accessType: userData.accessType,
          combinedActions: convertStringToCombinedAction(grips, userData.combinedActions),
          unOpposedActions: convertStringToUnOpposedAction(grips, userData.opposedActions, userData.unopposedActions),
          directActions: convertStringToDirectAction(grips, triggers, userData.directActions),
          advancedSettings: AdvancedSettings(
            switchInputs: userData.switchInputs,
            useTwoSignals: userData.useTwoSignals,
            inputGainA: userData.inputGainA,
            inputGainB: userData.inputGainB,

            timeOpenOpen: userData.timeOpenOpen,
            timeHoldOpen: userData.timeHoldOpen,
            timeCoCon: userData.timeCoCon,
            useThumbTrigger: userData.useThumbTrigger,

            alternate: userData.alternate,
            timeAltSwitch: userData.timeAltSwitch,
            timeFastClose: userData.timeFastClose,
            levelFastClose: userData.levelFastClose,

            vibrate: userData.vibrate,
            buzzer: userData.buzzer,
          ),
          signalSettings: SignalSettings(
            signalAon: userData.signalAon,
            signalAmax: userData.signalAmax,
            signalBon: userData.signalBon,
            signalBmax: userData.signalBmax,
            signalAgain: userData.signalAgain,
            signalBgain: userData.signalBgain,
          ),
      );
    }
    return null;
  }

  Future<bool> updateUserData(User user) async {
    """ Update the UserData row with new data""";
    final newEntity = UserDataEntityCompanion(
      userName: Value(user.userName),
      password: Value(user.password),
      name: Value(user.name),
      email: Value(user.email),
      accessType: Value(user.accessType),

      //Grip Data
      combinedActions: Value(convertCombinedActionToString(user.combinedActions)),
      opposedActions: Value(convertOpposedActionToString(user.unOpposedActions)),
      unopposedActions: Value(convertUnopposedActionToString(user.unOpposedActions)),
      directActions: Value(convertDirectActionToString(user.directActions)),

      //advanced settings
      switchInputs: Value(user.advancedSettings.switchInputs),
      useTwoSignals: Value(user.advancedSettings.useTwoSignals),
      inputGainA: Value(user.advancedSettings.inputGainA),
      inputGainB: Value(user.advancedSettings.inputGainB),

      timeOpenOpen: Value(user.advancedSettings.timeOpenOpen),
      timeHoldOpen: Value(user.advancedSettings.timeHoldOpen),
      timeCoCon: Value(user.advancedSettings.timeCoCon),
      useThumbTrigger: Value(user.advancedSettings.useThumbTrigger),

      alternate: Value(user.advancedSettings.alternate),
      timeAltSwitch: Value(user.advancedSettings.timeAltSwitch),
      timeFastClose: Value(user.advancedSettings.timeFastClose),
      levelFastClose: Value(user.advancedSettings.levelFastClose),

      vibrate: Value(user.advancedSettings.vibrate),
      buzzer: Value(user.advancedSettings.buzzer),

      //Signal Settings
      signalAon: Value(user.signalSettings.signalAon),
      signalAmax: Value(user.signalSettings.signalAmax),
      signalBon: Value(user.signalSettings.signalBon),
      signalBmax: Value(user.signalSettings.signalBmax),

      signalAgain: Value(user.signalSettings.signalAgain),
      signalBgain: Value(user.signalSettings.signalBgain),
    );

    ;
    return await _db.updateUserData(newEntity);
  }

  //#region conversion functions

  String convertCombinedActionToString(Map<String,HandAction> combinedActionsSetting){
    String combinedActions = "";
    for(var value in combinedActionsSetting.values){
      combinedActions += value.gripName;
      combinedActions += ",";
    }
    return combinedActions;
  }

  String convertOpposedActionToString(Map<String,HandAction> unOpposedActionsSetting){
    String opposedActions = "";
    for(var entry in unOpposedActionsSetting.entries){
      if(!entry.key.contains("Unopposed")){
        opposedActions += entry.value.gripName;
        opposedActions += ",";
      }
    }
    return opposedActions;
  }

  String convertUnopposedActionToString(Map<String,HandAction> unOpposedActionsSetting){
    String unopposedActions = "";
    for(var entry in unOpposedActionsSetting.entries){
      if(entry.key.contains("Unopposed")){
        unopposedActions += entry.value.gripName;
        unopposedActions += ",";
      }
    }
    return unopposedActions;
  }

  String convertDirectActionToString(Map<String, HandAction> directActionsSetting){
    String directActions = "";
    for(var entry in directActionsSetting.entries){
      directActions += "${entry.key}:${entry.value.triggerName},";
    }
    return directActions;
  }


  Map<String, HandAction> convertStringToUnOpposedAction(
      Map<String, Grip> grips,
      String opposedActions,
      String unopposedActions,){
    """
    This returns all of the actions in the right time
    Specifically only returns the combined, opposed, and unopposed actions
    """;
    final tempListOpposedActions = opposedActions.split(",");
    final tempListUnopposedActions = unopposedActions.split(",");
    final listOpposedActions = tempListOpposedActions.sublist(0, tempListOpposedActions.length-1);
    final listUnopposedActions = tempListUnopposedActions.sublist(0,tempListUnopposedActions.length-1);

    Map<String, HandAction> unOpposedActionsMap = {};

    for(var (index, action) in listOpposedActions.indexed){
      unOpposedActionsMap["Opposed Position ${index+1}"] = HandAction(grip: grips[action]);
    }
    for(var (index, action) in listUnopposedActions.indexed){
      unOpposedActionsMap["Unopposed Position ${index+1}"] = HandAction(grip: grips[action]);
    }

    return unOpposedActionsMap;
  }

  Map<String, HandAction> convertStringToCombinedAction(Map<String, Grip> grips, String combinedActions,){
    final tempListCombinedAction = combinedActions.split(",");
    // from the conversion, the last item in the string list is empty and must be removed
    final listCombinedAction = tempListCombinedAction.sublist(0,tempListCombinedAction.length-1);
    Map<String, HandAction> combinedActionsMap = {};
    for(var (index, action) in listCombinedAction.indexed){
      combinedActionsMap["Position ${index+1}"] = HandAction(grip: grips[action]);
    }
    return combinedActionsMap;
  }


  Map<String, HandAction> convertStringToDirectAction(Map<String, Grip> grips, Map<String, Trigger> triggers, String directActions){
    List<String> listDirectActions = directActions.split(",");
    Map<String, HandAction> directActionsMap = {};
    for(var action in listDirectActions.sublist(0,listDirectActions.length-1)){
      var dAction = action.split(":");
      directActionsMap[dAction[0]] = HandAction(
          trigger: triggers[dAction[0]],
          grip: grips[dAction[1]],
      );
    }
    return directActionsMap;
  }

  //#endregion

}