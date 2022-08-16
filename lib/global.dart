import 'package:flutter/material.dart';

var version = 2.1;

// Set default values for initial run
var count = 0;
var name = "Janne";
var makes = 0;
var previousMake = 0;
var stackSize = 5;
var distance = 30;
var shotAngle = 1;
var stance = 'Normal';
var goal = 100;
var date = "";
var green = const Color.fromRGBO(152, 190, 100, 1);
var backgroundColor = Colors.transparent;
var startTab = 0;
var table = [];
var notes = "";

final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();

//values for approach shots
var appCount = 0;
var appName = "Janne";
var appMakes = 0;
var appPreviousMake = 0;
var appStackSize = 5;
var appDistance = 150;
var appTargetSize = 15;
var appShotAngle = 1;
var appShotType = "Backhand";
var appGoal = 30;
var appDate = "";
var appStartTab = 0;
var appTable = [];
var appNotes = "";
