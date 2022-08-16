import 'package:flutter/material.dart';
import 'global.dart' as global;

// Shot Type Selector Chip

//
// To be switched to Shot Angle Selector Chip
//

class ShotAngleSelectorChip extends StatefulWidget {
  const ShotAngleSelectorChip({super.key});

  @override
  ShotAngleSelectorChipState createState() => ShotAngleSelectorChipState();
}

class ShotAngleSelectorChipState extends State<ShotAngleSelectorChip>
    with RestorationMixin {
  final RestorableInt _indexSelected = RestorableInt(global.shotAngle);

  @override
  String get restorationId => 'choice_chip_demo';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_indexSelected, 'choice_chip');
  }

  @override
  void dispose() {
    _indexSelected.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        children: [
          ChoiceChip(
            label: const Text("Hyzer"),
            selected: _indexSelected.value == 0,
            onSelected: (value) {
              setState(() {
                _indexSelected.value = value ? 0 : -1;
                global.shotAngle = 0;
              });
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text("Flat"),
            selected: _indexSelected.value == 1,
            onSelected: (value) {
              setState(() {
                _indexSelected.value = value ? 1 : -1;
                global.shotAngle = 1;
              });
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text("Anhyzer"),
            selected: _indexSelected.value == 2,
            onSelected: (value) {
              setState(() {
                _indexSelected.value = value ? 2 : -1;
                global.shotAngle = 2;
              });
            },
          ),
        ],
      ),
    );
  }
}

// Stance Selector Chip

class StanceSelectorChip extends StatefulWidget {
  const StanceSelectorChip({super.key});

  @override
  StanceSelectorChipState createState() => StanceSelectorChipState();
}

class StanceSelectorChipState extends State<StanceSelectorChip>
    with RestorationMixin {
  final RestorableInt _indexSelected = RestorableInt(global.stance == "Normal"
      ? 0
      : (global.stance == "Straddle"
          ? 1
          : (global.stance == "Kneeling"
              ? 2
              : (global.stance == "Reaching Right" ? 3 : 4))));

  @override
  String get restorationId => 'choice_chip_demo';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_indexSelected, 'choice_chip');
  }

  @override
  void dispose() {
    _indexSelected.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        children: [
          ChoiceChip(
            label: const Text("Normal"),
            selected: _indexSelected.value == 0,
            onSelected: (value) {
              setState(() {
                _indexSelected.value = value ? 0 : -1;
                global.stance = "Normal";
              });
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text("Straddle"),
            selected: _indexSelected.value == 1,
            onSelected: (value) {
              setState(() {
                _indexSelected.value = value ? 1 : -1;
                global.stance = "Straddle";
              });
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text("Kneeling"),
            selected: _indexSelected.value == 2,
            onSelected: (value) {
              setState(() {
                _indexSelected.value = value ? 2 : -1;
                global.stance = "Kneeling";
              });
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text("Reaching Right"),
            selected: _indexSelected.value == 3,
            onSelected: (value) {
              setState(() {
                _indexSelected.value = value ? 3 : -1;
                global.stance = "Reaching Right";
              });
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text("Reaching Left"),
            selected: _indexSelected.value == 4,
            onSelected: (value) {
              setState(() {
                _indexSelected.value = value ? 4 : -1;
                global.stance = "Reaching Left";
              });
            },
          ),
        ],
      ),
    );
  }
}

// Putting Stack Slider

class StackSizeSliders extends StatefulWidget {
  const StackSizeSliders({Key? key}) : super(key: key);

  @override
  StackSizeSlidersState createState() => StackSizeSlidersState();
}

class StackSizeSlidersState extends State<StackSizeSliders>
    with RestorationMixin {
  final RestorableInt _continuousValue = RestorableInt(global.stackSize);

  @override
  String get restorationId => 'stackSize_slider';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_continuousValue, 'continuous_value');
  }

  @override
  void dispose() {
    _continuousValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                child: SizedBox(
                  width: 64,
                  height: 48,
                  child: TextField(
                    textAlign: TextAlign.center,
                    onSubmitted: (value) {
                      final newValue = int.tryParse(value);
                      if (newValue != null &&
                          newValue != _continuousValue.value) {
                        setState(() {
                          _continuousValue.value =
                              newValue.clamp(0, 20).truncate();
                          global.stackSize = newValue.clamp(0, 20).toInt();
                        });
                      }
                    },
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: _continuousValue.value.toStringAsFixed(0),
                    ),
                  ),
                ),
              ),
              Slider(
                value: _continuousValue.value.toDouble(),
                min: 0,
                max: 20,
                onChanged: (value) {
                  setState(() {
                    _continuousValue.value = value.toInt();
                    global.stackSize = value.toInt();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Approach Stack Size Slider

class AppStackSizeSliders extends StatefulWidget {
  const AppStackSizeSliders({Key? key}) : super(key: key);

  @override
  AppStackSizeSlidersState createState() => AppStackSizeSlidersState();
}

class AppStackSizeSlidersState extends State<AppStackSizeSliders>
    with RestorationMixin {
  final RestorableInt _continuousValue = RestorableInt(global.appStackSize);

  @override
  String get restorationId => 'appStackSize_slider';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_continuousValue, 'continuous_value');
  }

  @override
  void dispose() {
    _continuousValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                child: SizedBox(
                  width: 64,
                  height: 48,
                  child: TextField(
                    textAlign: TextAlign.center,
                    onSubmitted: (value) {
                      final newValue = int.tryParse(value);
                      if (newValue != null &&
                          newValue != _continuousValue.value) {
                        setState(() {
                          _continuousValue.value =
                              newValue.clamp(0, 20).truncate();
                          global.appStackSize = newValue.clamp(0, 20).toInt();
                        });
                      }
                    },
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: _continuousValue.value.toStringAsFixed(0),
                    ),
                  ),
                ),
              ),
              Slider(
                value: _continuousValue.value.toDouble(),
                min: 0,
                max: 20,
                onChanged: (value) {
                  setState(() {
                    _continuousValue.value = value.toInt();
                    global.appStackSize = value.toInt();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//
// Putting Distance Slider

class DistanceSliders extends StatefulWidget {
  const DistanceSliders({Key? key}) : super(key: key);

  @override
  DistanceSlidersState createState() => DistanceSlidersState();
}

class DistanceSlidersState extends State<DistanceSliders>
    with RestorationMixin {
  final RestorableInt _continuousValue = RestorableInt(global.distance);

  @override
  String get restorationId => 'distance_slider';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_continuousValue, 'continuous_value');
  }

  @override
  void dispose() {
    _continuousValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                child: SizedBox(
                  width: 64,
                  height: 48,
                  child: TextField(
                    textAlign: TextAlign.center,
                    onSubmitted: (value) {
                      final newValue = double.tryParse(value);
                      if (newValue != null &&
                          newValue != _continuousValue.value) {
                        setState(() {
                          _continuousValue.value =
                              newValue.clamp(0, 300).truncate();
                          global.distance = newValue.clamp(0, 300).toInt();
                        });
                      }
                    },
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: _continuousValue.value.toStringAsFixed(0),
                    ),
                  ),
                ),
              ),
              Slider(
                value: _continuousValue.value.toDouble(),
                min: 0,
                max: 300,
                onChanged: (value) {
                  setState(() {
                    _continuousValue.value = value.toInt();
                    global.distance = value.toInt();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Approach Distance Slider

class AppDistanceSliders extends StatefulWidget {
  const AppDistanceSliders({Key? key}) : super(key: key);

  @override
  AppDistanceSlidersState createState() => AppDistanceSlidersState();
}

class AppDistanceSlidersState extends State<AppDistanceSliders>
    with RestorationMixin {
  final RestorableInt _continuousValue = RestorableInt(global.appDistance);

  @override
  String get restorationId => 'distance_slider';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_continuousValue, 'continuous_value');
  }

  @override
  void dispose() {
    _continuousValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                child: SizedBox(
                  width: 64,
                  height: 48,
                  child: TextField(
                    textAlign: TextAlign.center,
                    onSubmitted: (value) {
                      final newValue = double.tryParse(value);
                      if (newValue != null &&
                          newValue != _continuousValue.value) {
                        setState(() {
                          _continuousValue.value =
                              newValue.clamp(0, 300).truncate();
                          global.appDistance = newValue.clamp(0, 300).toInt();
                        });
                      }
                    },
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: _continuousValue.value.toStringAsFixed(0),
                    ),
                  ),
                ),
              ),
              Slider(
                value: _continuousValue.value.toDouble(),
                min: 50,
                max: 300,
                onChanged: (value) {
                  setState(() {
                    _continuousValue.value = value.toInt();
                    global.appDistance = value.toInt();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Putting Goal Slider

class GoalSliders extends StatefulWidget {
  const GoalSliders({Key? key}) : super(key: key);

  @override
  GoalSlidersState createState() => GoalSlidersState();
}

class GoalSlidersState extends State<GoalSliders> with RestorationMixin {
  final RestorableInt _continuousValue = RestorableInt(global.goal);

  @override
  String get restorationId => 'goal_slider';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_continuousValue, 'continuous_value');
  }

  @override
  void dispose() {
    _continuousValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                child: SizedBox(
                  width: 64,
                  height: 48,
                  child: TextField(
                    textAlign: TextAlign.center,
                    onSubmitted: (value) {
                      final newValue = double.tryParse(value);
                      if (newValue != null &&
                          newValue != _continuousValue.value) {
                        setState(() {
                          _continuousValue.value =
                              newValue.clamp(0, 200).truncate();
                          global.goal = newValue.clamp(0, 200).toInt();
                        });
                      }
                    },
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: _continuousValue.value.toStringAsFixed(0),
                    ),
                  ),
                ),
              ),
              Slider(
                value: _continuousValue.value.toDouble(),
                min: 0,
                max: 200,
                onChanged: (value) {
                  setState(() {
                    _continuousValue.value = value.toInt();
                    global.goal = value.toInt();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Approach Goal Slider

class AppGoalSliders extends StatefulWidget {
  const AppGoalSliders({Key? key}) : super(key: key);

  @override
  AppGoalSlidersState createState() => AppGoalSlidersState();
}

class AppGoalSlidersState extends State<AppGoalSliders> with RestorationMixin {
  final RestorableInt _continuousValue = RestorableInt(global.appGoal);

  @override
  String get restorationId => 'appGoal_slider';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_continuousValue, 'continuous_value');
  }

  @override
  void dispose() {
    _continuousValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                child: SizedBox(
                  width: 64,
                  height: 48,
                  child: TextField(
                    textAlign: TextAlign.center,
                    onSubmitted: (value) {
                      final newValue = double.tryParse(value);
                      if (newValue != null &&
                          newValue != _continuousValue.value) {
                        setState(() {
                          _continuousValue.value =
                              newValue.clamp(0, 200).truncate();
                          global.appGoal = newValue.clamp(0, 200).toInt();
                        });
                      }
                    },
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: _continuousValue.value.toStringAsFixed(0),
                    ),
                  ),
                ),
              ),
              Slider(
                value: _continuousValue.value.toDouble(),
                min: 0,
                max: 200,
                onChanged: (value) {
                  setState(() {
                    _continuousValue.value = value.toInt();
                    global.appGoal = value.toInt();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Target Size Slider

class TargetSizeSliders extends StatefulWidget {
  const TargetSizeSliders({Key? key}) : super(key: key);

  @override
  TargetSizeSlidersState createState() => TargetSizeSlidersState();
}

class TargetSizeSlidersState extends State<TargetSizeSliders>
    with RestorationMixin {
  final RestorableInt _continuousValue = RestorableInt(global.appTargetSize);

  @override
  String get restorationId => 'TargetSize_slider';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_continuousValue, 'continuous_value');
  }

  @override
  void dispose() {
    _continuousValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                child: SizedBox(
                  width: 64,
                  height: 48,
                  child: TextField(
                    textAlign: TextAlign.center,
                    onSubmitted: (value) {
                      final newValue = int.tryParse(value);
                      if (newValue != null &&
                          newValue != _continuousValue.value) {
                        setState(() {
                          _continuousValue.value =
                              newValue.clamp(0, 50).truncate();
                          global.appTargetSize = newValue.clamp(0, 50).toInt();
                        });
                      }
                    },
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: _continuousValue.value.toStringAsFixed(0),
                    ),
                  ),
                ),
              ),
              Slider(
                value: _continuousValue.value.toDouble(),
                min: 0,
                max: 50,
                onChanged: (value) {
                  setState(() {
                    _continuousValue.value = value.toInt();
                    global.appTargetSize = value.toInt();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
