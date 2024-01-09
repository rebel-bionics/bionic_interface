# Rebel Bionics Prosthetic Interface

Interface for a prosthetic hand developed by [Rebel Bionics](https://rebelbionics.com/)

## Functions 

The main functions of this app are to:
1. Visually plot the Electromyographic (EMG) data from two sensors sent wirelessly via bluetooth
2. Allow the user to change the rules/muscle activation patterns associated with a grip

More functions possibly to come

## Code structure

While this may change, the main components of this app will be:

### General Operations Handler

Contains methods, functions, objects which are necessary for general functioning. May be unnecessary, we will see.
This would also be the class which carries data between screens in cases where direct data transfers are not possible.

### Data Handler
Contains all handling and passing of data between classes

### BLE Handler
Handles all direct BLE interaction of the app. This class/file should be the only one with any references to the BLE packages

### Route Handler 
Creates and manages moving between screens

### Test Interface / Generator
Creates any necessary inputs for using the app without having a physical device to test with

# Things that still need to be added:
- [] have the grip settings pop up wrap to fit the number of items available
- [] Ability to remove things from the grip settings listview
- [] Popups for changing trigger settings ->  though this may be better to be in the emg page rather than grip settings?
- [] Adding ability to login + dealing with different account types 
- [] Figuring out best way to persist data between sessions (incl user data )
- [] Functionality of other features on emg signal page beyond just the slider 
- [] All of the Bluetooth integration -> still needs the protocols from the firmware, i don't think those exist yet


