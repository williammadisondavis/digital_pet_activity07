import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const DigitalPetApp());
}

class DigitalPetApp extends StatelessWidget {
  const DigitalPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Pet',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const DigitalPetPage(),
    );
  }
}

class DigitalPetPage extends StatefulWidget {
  const DigitalPetPage({super.key});

  @override
  State<DigitalPetPage> createState() => _DigitalPetPageState();
}

class _DigitalPetPageState extends State<DigitalPetPage> {
  // Controller for changing the pet's name.
  final TextEditingController _nameController = TextEditingController(
    text: 'Pixel',
  );

  // Main pet state.
  String _petName = 'Pixel';
  int _happiness = 60;
  int _hunger = 40;

  // Game state.
  bool _gameOver = false;
  bool _hasWon = false;
  bool _isPaused = false;

  // Animation/reaction state.
  bool _isBouncing = false;
  int _bounceToken = 0;
  String? _reaction;

  // Timers.
  Timer? _hungerTimer;
  Timer? _highMoodTimer;
  Timer? _reactionTimer;

  @override
  void initState() {
    super.initState();

    // Start hunger timer when the app opens.
    _startHungerTimer();
  }

  // Keeps all meter values between 0 and 100.
  int _clampMeter(int value) {
    return value.clamp(0, 100).toInt();
  }

  // Mood label based on happiness.
  String get _moodLabel {
    if (_happiness > 70) {
      return 'Happy';
    } else if (_happiness >= 30) {
      return 'Content';
    } else {
      return 'Sad';
    }
  }

  // Mood color based on happiness.
  Color get _moodColor {
    if (_happiness > 70) {
      return Colors.green;
    } else if (_happiness >= 30) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  // Slightly changes pet size depending on mood.
  double get _moodScale {
    if (_happiness > 70) {
      return 1.06;
    } else if (_happiness < 30) {
      return 0.94;
    }

    return 1.0;
  }

  // Pet message is calculated from the current state.
  String get _petMessage {
    if (_gameOver) {
      return 'I need a rest...';
    }

    if (_hasWon) {
      return 'Best day ever!';
    }

    if (_isPaused) {
      return 'Game paused. I will wait here!';
    }

    if (_hunger > 80) {
      return "I'm really hungry!";
    }

    if (_happiness <= 30) {
      return 'Will you play with me?';
    }

    return "Hi, I'm $_petName!";
  }

  // Starts the hunger timer.
  void _startHungerTimer() {
    // Cancel an old timer first so two timers cannot run.
    _hungerTimer?.cancel();

    if (_gameOver || _hasWon || _isPaused) {
      return;
    }

    _hungerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_gameOver || _hasWon) {
        timer.cancel();
        return;
      }

      if (_isPaused) {
        return;
      }

      setState(() {
        // Moving from 95 to 100 does not decrease happiness.
        // The next timer tick while already at 100 does.
        if (_hunger + 5 > 100) {
          _hunger = 100;
          _happiness = _clampMeter(_happiness - 20);
        } else {
          _hunger = _clampMeter(_hunger + 5);
        }
      });

      _updateOutcome();
    });
  }

  // Checks whether the player has won or lost.
  void _updateOutcome() {
    if (_gameOver || _hasWon || _isPaused) {
      return;
    }

    // Loss condition.
    if (_hunger == 100 && _happiness <= 10) {
      _highMoodTimer?.cancel();
      _highMoodTimer = null;

      _hungerTimer?.cancel();

      setState(() {
        _gameOver = true;
      });

      return;
    }

    // Happiness has to stay strictly ABOVE 80.
    if (_happiness <= 80) {
      _highMoodTimer?.cancel();
      _highMoodTimer = null;
      return;
    }

    // Start the win timer only if one is not already running.
    _highMoodTimer ??= Timer(const Duration(minutes: 3), () {
      _highMoodTimer = null;

      if (!mounted || _gameOver || _isPaused || _happiness <= 80) {
        return;
      }

      setState(() {
        _hasWon = true;
      });

      _hungerTimer?.cancel();
    });
  }

  // Feed button.
  void _feedPet() {
    if (_gameOver || _hasWon || _isPaused) {
      return;
    }

    final int nextHunger = _clampMeter(_hunger - 10);

    // Feeding when the pet is already very full lowers happiness.
    final int happinessChange = nextHunger < 30 ? -20 : 10;

    final int nextHappiness = _clampMeter(_happiness + happinessChange);

    setState(() {
      _hunger = nextHunger;
      _happiness = nextHappiness;
    });

    _showReaction('🍖');
    _triggerBounce();
    _updateOutcome();
  }

  // Play button.
  void _playWithPet() {
    if (_gameOver || _hasWon || _isPaused) {
      return;
    }

    setState(() {
      _happiness = _clampMeter(_happiness + 15);
      _hunger = _clampMeter(_hunger + 10);
    });

    _showReaction('🎾');
    _triggerBounce();
    _updateOutcome();
  }

  // Shows a short reaction emoji.
  void _showReaction(String reaction) {
    _reactionTimer?.cancel();

    setState(() {
      _reaction = reaction;
    });

    _reactionTimer = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _reaction = null;
      });
    });
  }

  // Small pet bounce after Feed or Play.
  void _triggerBounce() {
    _bounceToken++;

    final int currentToken = _bounceToken;

    setState(() {
      _isBouncing = true;
    });

    Future.delayed(const Duration(milliseconds: 220), () {
      if (!mounted || currentToken != _bounceToken) {
        return;
      }

      setState(() {
        _isBouncing = false;
      });
    });
  }

  // Confirms the pet's new name.
  void _confirmName() {
    final String enteredName = _nameController.text.trim();

    if (enteredName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a pet name.')));

      return;
    }

    setState(() {
      _petName = enteredName;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Your pet is now named $_petName!')));
  }

  // Advanced Feature #1:
  // Pause and resume session controls.
  void _togglePause() {
    if (_gameOver || _hasWon) {
      return;
    }

    if (!_isPaused) {
      setState(() {
        _isPaused = true;
      });

      _hungerTimer?.cancel();

      _highMoodTimer?.cancel();
      _highMoodTimer = null;
    } else {
      setState(() {
        _isPaused = false;
      });

      _startHungerTimer();
      _updateOutcome();
    }
  }

  // Resets the entire game.
  void _resetGame() {
    _hungerTimer?.cancel();
    _highMoodTimer?.cancel();
    _reactionTimer?.cancel();

    _highMoodTimer = null;
    _reaction = null;

    _bounceToken++;

    setState(() {
      _happiness = 60;
      _hunger = 40;

      _gameOver = false;
      _hasWon = false;
      _isPaused = false;
      _isBouncing = false;
    });

    _startHungerTimer();
  }

  // Creates one animated meter.
  Widget _buildMeter(String title, int value, bool reduceMotion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: $value / 100',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),

        // Advanced Feature #2:
        // Animated meter.
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: value / 100),
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          builder: (context, animatedValue, child) {
            return LinearProgressIndicator(
              value: animatedValue,
              minHeight: 12,
              borderRadius: BorderRadius.circular(10),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Allows animations to be removed if the device
    // has reduced-motion accessibility enabled.
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;

    double scale = _moodScale;

    if (_isBouncing && !reduceMotion) {
      scale *= 1.08;
    }

    final bool careDisabled = _gameOver || _hasWon || _isPaused;

    return Scaffold(
      appBar: AppBar(title: const Text('My Digital Pet'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  // Pet name.
                  Text(
                    _petName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),

                  const SizedBox(height: 10),

                  // Mood is shown with text so color is not
                  // the only mood indicator.
                  Text(
                    'Mood: $_moodLabel',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Pet image and reaction.
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: Semantics(
                          label: '$_petName is currently $_moodLabel',
                          child: AnimatedScale(
                            scale: scale,
                            duration: reduceMotion
                                ? Duration.zero
                                : const Duration(milliseconds: 180),
                            curve: Curves.easeOutBack,
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                _moodColor,
                                BlendMode.modulate,
                              ),
                              child: Image.asset(
                                'assets/pet.png',
                                height: 220,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),

                      AnimatedOpacity(
                        opacity: _reaction == null ? 0 : 1,
                        duration: reduceMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 180),
                        child: Text(
                          _reaction ?? '',
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Pet speech.
                  AnimatedSwitcher(
                    duration: reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 300),
                    child: Text(
                      _petMessage,
                      key: ValueKey(_petMessage),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Happiness meter.
                  _buildMeter('Happiness', _happiness, reduceMotion),

                  const SizedBox(height: 20),

                  // Hunger meter.
                  _buildMeter('Hunger', _hunger, reduceMotion),

                  const SizedBox(height: 28),

                  // Pet name input.
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Pet Name',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: _confirmName,
                    child: const Text('Confirm Name'),
                  ),

                  const SizedBox(height: 25),

                  // Main controls.
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        onPressed: careDisabled ? null : _feedPet,
                        icon: const Icon(Icons.restaurant),
                        label: const Text('Feed'),
                      ),

                      ElevatedButton.icon(
                        onPressed: careDisabled ? null : _playWithPet,
                        icon: const Icon(Icons.sports_tennis),
                        label: const Text('Play'),
                      ),

                      ElevatedButton.icon(
                        onPressed: (_gameOver || _hasWon) ? null : _togglePause,
                        icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                        label: Text(_isPaused ? 'Resume' : 'Pause'),
                      ),

                      OutlinedButton.icon(
                        onPressed: _resetGame,
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Restart'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Win message.
                  if (_hasWon)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          '🏆 YOU WIN! Your pet stayed happy for three minutes!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Game over message.
                  if (_gameOver)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          '💤 GAME OVER! Your pet became too hungry and unhappy.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up timers and controller when leaving the page.
    _hungerTimer?.cancel();
    _highMoodTimer?.cancel();
    _reactionTimer?.cancel();
    _nameController.dispose();

    super.dispose();
  }
}
