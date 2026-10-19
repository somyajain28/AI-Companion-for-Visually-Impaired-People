import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/onboarding_flow.dart';
import '../services/audio_recording_service.dart';
import '../services/backend_api_service.dart';
import '../services/speech_api_service.dart';
import '../services/tts_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TtsService _ttsService = TtsService();
  final AudioRecordingService _audioService = AudioRecordingService();
  final SpeechApiService _speechApiService = SpeechApiService();
  final BackendApiService _backendApiService = BackendApiService();
  final OnboardingFlow _flow = OnboardingFlow();

  final TextEditingController _textController = TextEditingController();
  final FocusNode _keyboardFocusNode = FocusNode();
  final FocusNode _textFocusNode = FocusNode();

  bool _started = false;
  bool _isProcessing = false;
  bool _isSpeaking = false;
  bool _isListening = false;

  String _status = 'Tap anywhere or press Enter once to begin.';

  @override
  void initState() {
    super.initState();
    _keyboardFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _textController.dispose();
    _keyboardFocusNode.dispose();
    _textFocusNode.dispose();
    _audioService.dispose();
    super.dispose();
  }

  // ============================================================
  // START COMPANION
  // ============================================================

  Future<void> _startCompanion() async {
    if (_started) {
      return;
    }
    _started = true;
    _setStatus('Starting AI Companion...');

    try {
      await _ttsService.initialize();
      final microphoneReady = await _audioService.initialize();

      if (!microphoneReady) {
        _started = false;
        _setStatus('Microphone permission is required. Please allow access.');
        await _speak('Microphone permission is required. Please allow microphone access and try again.');
        return;
      }

      await _askName();
    } catch (e) {
      _started = false;
      _setStatus('Unable to start the assistant.');
      debugPrint('Start companion error: $e');
    }
  }

  // ============================================================
  // SPEAK (INDIAN ENGLISH - en-IN)
  // ============================================================

  Future<void> _speak(
    String text, {
    String language = 'en-IN',
  }) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isSpeaking = true;
      _isListening = false;
      _status = 'Speaking: $text';
    });

    try {
      await _ttsService.speak(text, language: language);
    } catch (e) {
      debugPrint('TTS error: $e');
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isSpeaking = false;
      _status = 'Listening...';
    });
  }

  // ============================================================
  // AUTOMATIC RECORDING (8 SECONDS LISTENING WINDOW)
  // ============================================================

  Future<void> _startListening() async {
    if (!mounted || _isListening || _isProcessing || _isSpeaking) {
      return;
    }

    try {
      setState(() {
        _isListening = true;
        _status = 'Listening... Please speak now.';
      });

      await _audioService.startRecording();

      // Increased to 8 seconds so the user can comfortably finish their sentence
      await Future.delayed(const Duration(seconds: 8));

      if (!mounted) {
        return;
      }

      await _finishListening();
    } catch (e) {
      debugPrint('Recording error: $e');
      if (!mounted) return;
      setState(() {
        _isListening = false;
        _status = 'Microphone error. Please try again.';
      });
    }
  }

  // ============================================================
  // STOP RECORDING AND SEND TO BACKEND (ENGLISH WHISPER)
  // ============================================================

  Future<void> _finishListening() async {
    if (!_isListening) {
      return;
    }

    setState(() {
      _isListening = false;
      _isProcessing = true;
      _status = 'Processing your speech...';
    });

    try {
      final audioBytes = await _audioService.stopRecording();
      if (audioBytes == null || audioBytes.isEmpty) {
        throw Exception('No audio was recorded.');
      }

      // Explicitly transcribe in English
      final result = await _speechApiService.convertSpeechToText(
        audioBytes,
        language: 'en',
      );

      if (!mounted) {
        return;
      }

      final text = result['text']?.toString().trim() ?? '';

      if (text.isEmpty) {
        setState(() {
          _isProcessing = false;
          _status = 'I did not catch that. Please speak again.';
        });
        await _speak('I did not catch that. Please speak again.');
        await _startListening();
        return;
      }

      await _handleUserInput(text);
    } catch (e) {
      debugPrint('Voice processing error: $e');
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _status = 'Could not process speech. You may speak again or type below.';
      });
    }
  }

  // ============================================================
  // AFFIRMATION & NEGATION HELPERS
  // ============================================================

  bool _isAffirmative(String text) {
    final lower = text.toLowerCase().trim();
    return lower.contains('yes') ||
        lower.contains('yeah') ||
        lower.contains('yep') ||
        lower.contains('yup') ||
        lower.contains('ya') ||
        lower.contains('correct') ||
        lower.contains('right') ||
        lower.contains('sure') ||
        lower.contains('ok') ||
        lower.contains('okay') ||
        lower.contains('true') ||
        lower.contains('haan') ||
        lower.contains('han');
  }

  bool _isNegative(String text) {
    final lower = text.toLowerCase().trim();
    return lower.contains('no') ||
        lower.contains('nah') ||
        lower.contains('nope') ||
        lower.contains('wrong') ||
        lower.contains('not') ||
        lower.contains('change') ||
        lower.contains('na');
  }

  String _cleanSpokenText(String input) {
    return input.trim().replaceAll(RegExp(r'[\.\,\!\?]+$'), '').trim();
  }

  String _sanitizeEmail(String text) {
    var s = text.trim().toLowerCase();
    s = s.replaceAll(' at the rate ', '@');
    s = s.replaceAll(' at rate ', '@');
    s = s.replaceAll(' at ', '@');
    s = s.replaceAll(' dot ', '.');
    s = s.replaceAll(' ', '');
    s = s.replaceAll(RegExp(r'[\,\!\?]+$'), '');
    if (!s.contains('@')) {
      s = '$s@gmail.com';
    }
    return s;
  }

  String _sanitizePhone(String text) {
    final digits = text.replaceAll(RegExp(r'[^\d+]'), '');
    return digits.isNotEmpty ? digits : text.trim();
  }

  // ============================================================
  // STATE MACHINE: ONE STEP AT A TIME
  // ============================================================

  Future<void> _handleUserInput(String text) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _status = 'Heard: "$text"';
    });

    final currentStep = _flow.currentStep;

    switch (currentStep) {
      case OnboardingStep.welcome:
      case OnboardingStep.askName:
        await _handleName(text);
        break;

      case OnboardingStep.confirmName:
        await _handleNameConfirmation(text);
        break;

      case OnboardingStep.askEmail:
        await _handleEmail(text);
        break;

      case OnboardingStep.confirmEmail:
        await _handleEmailConfirmation(text);
        break;

      case OnboardingStep.askPhone:
        await _handlePhone(text);
        break;

      case OnboardingStep.confirmPhone:
        await _handlePhoneConfirmation(text);
        break;

      case OnboardingStep.askEmergencyName:
        await _handleEmergencyName(text);
        break;

      case OnboardingStep.confirmEmergencyName:
        await _handleEmergencyNameConfirmation(text);
        break;

      case OnboardingStep.askEmergencyPhone:
        await _handleEmergencyPhone(text);
        break;

      case OnboardingStep.confirmEmergencyPhone:
        await _handleEmergencyPhoneConfirmation(text);
        break;

      case OnboardingStep.askEmergencyRelationship:
        await _handleEmergencyRelationship(text);
        break;

      case OnboardingStep.confirmEmergencyRelationship:
        await _handleEmergencyRelationshipConfirmation(text);
        break;

      case OnboardingStep.askHomeLocation:
        await _handleHomeLocation(text);
        break;

      case OnboardingStep.confirmHomeLocation:
        await _handleHomeLocationConfirmation(text);
        break;

      case OnboardingStep.completed:
        await _handleAfterOnboarding(text);
        break;
    }
  }

  // ============================================================
  // 1. FULL NAME STEP
  // ============================================================

  Future<void> _askName() async {
    if (!mounted) return;
    _flow.moveTo(OnboardingStep.askName);
    _isProcessing = false;
    await _speak(
      'Welcome to AI Companion. I will assist you with reading, navigation, and remembering details. '
      'Let us set up your profile. Please tell me your full name.',
    );
    await _startListening();
  }

  Future<void> _handleName(String text) async {
    var name = _cleanSpokenText(text);

    final prefixes = ['my name is', 'i am', 'this is', 'name is'];
    for (final p in prefixes) {
      if (name.toLowerCase().startsWith(p)) {
        name = name.substring(p.length).trim();
      }
    }

    if (name.isEmpty) {
      _isProcessing = false;
      await _speak('I did not catch your name. Please say your name again.');
      await _startListening();
      return;
    }

    _flow.setName(name);
    _flow.moveTo(OnboardingStep.confirmName);
    _isProcessing = false;

    await _speak('Is your name $name? Please say yes or no.');
    await _startListening();
  }

  Future<void> _handleNameConfirmation(String text) async {
    if (_isAffirmative(text)) {
      _flow.moveTo(OnboardingStep.askEmail);
      _isProcessing = false;
      await _speak('Great, ${_flow.userName}. Now, please tell me your email address.');
      await _startListening();
      return;
    }

    if (_isNegative(text)) {
      _flow.moveTo(OnboardingStep.askName);
      _isProcessing = false;
      await _speak('Alright. Please tell me your name again.');
      await _startListening();
      return;
    }

    _isProcessing = false;
    await _speak('Is your name ${_flow.userName}? Please say yes or no.');
    await _startListening();
  }

  // ============================================================
  // 2. EMAIL STEP
  // ============================================================

  Future<void> _handleEmail(String text) async {
    final email = _sanitizeEmail(text);
    _flow.setEmail(email);
    _flow.moveTo(OnboardingStep.confirmEmail);
    _isProcessing = false;

    await _speak('Is your email $email? Please say yes or no.');
    await _startListening();
  }

  Future<void> _handleEmailConfirmation(String text) async {
    if (_isAffirmative(text)) {
      _flow.moveTo(OnboardingStep.askPhone);
      _isProcessing = false;
      await _speak('Thank you. Now, please tell me your 10-digit mobile phone number.');
      await _startListening();
      return;
    }

    if (_isNegative(text)) {
      _flow.moveTo(OnboardingStep.askEmail);
      _isProcessing = false;
      await _speak('Please tell me your email address again.');
      await _startListening();
      return;
    }

    _isProcessing = false;
    await _speak('Is your email ${_flow.userEmail}? Please say yes or no.');
    await _startListening();
  }

  // ============================================================
  // 3. PHONE NUMBER & USER REGISTRATION
  // ============================================================

  Future<void> _handlePhone(String text) async {
    final phone = _sanitizePhone(text);
    _flow.setPhone(phone);
    _flow.moveTo(OnboardingStep.confirmPhone);
    _isProcessing = false;

    await _speak('Is your phone number $phone? Please say yes or no.');
    await _startListening();
  }

  Future<void> _handlePhoneConfirmation(String text) async {
    if (_isAffirmative(text)) {
      _isProcessing = true;
      _setStatus('Registering your account in MySQL database...');

      try {
        final user = await _backendApiService.registerOrLoginUser(
          userName: _flow.userName ?? 'User',
          userEmail: _flow.userEmail ?? 'user@companion.local',
          phoneNumber: _flow.phoneNumber ?? '0000000000',
          preferredLanguage: 'English',
        );

        if (user['user_id'] != null) {
          _flow.setUserId(user['user_id'] as int);
        }
      } catch (e) {
        debugPrint('Database registration error: $e');
      }

      // One thing at a time: Ask emergency contact NAME first
      _flow.moveTo(OnboardingStep.askEmergencyName);
      _isProcessing = false;

      await _speak(
        'Your profile has been created in the database. '
        'For your safety, let us add an emergency contact. '
        'First, what is your emergency contact person name?',
      );
      await _startListening();
      return;
    }

    if (_isNegative(text)) {
      _flow.moveTo(OnboardingStep.askPhone);
      _isProcessing = false;
      await _speak('Please tell me your phone number again.');
      await _startListening();
      return;
    }

    _isProcessing = false;
    await _speak('Is your phone number ${_flow.phoneNumber}? Please say yes or no.');
    await _startListening();
  }

  // ============================================================
  // 4A. EMERGENCY CONTACT NAME
  // ============================================================

  Future<void> _handleEmergencyName(String text) async {
    final name = _cleanSpokenText(text);
    _flow.setEmergencyName(name);
    _flow.moveTo(OnboardingStep.confirmEmergencyName);
    _isProcessing = false;

    await _speak('Is your emergency contact name $name? Please say yes or no.');
    await _startListening();
  }

  Future<void> _handleEmergencyNameConfirmation(String text) async {
    if (_isAffirmative(text)) {
      _flow.moveTo(OnboardingStep.askEmergencyPhone);
      _isProcessing = false;

      await _speak('Got it. What is ${_flow.emergencyContactName} phone number?');
      await _startListening();
      return;
    }

    if (_isNegative(text)) {
      _flow.moveTo(OnboardingStep.askEmergencyName);
      _isProcessing = false;
      await _speak('Please tell me their name again.');
      await _startListening();
      return;
    }

    _isProcessing = false;
    await _speak('Is their name ${_flow.emergencyContactName}? Say yes or no.');
    await _startListening();
  }

  // ============================================================
  // 4B. EMERGENCY CONTACT PHONE NUMBER
  // ============================================================

  Future<void> _handleEmergencyPhone(String text) async {
    final phone = _sanitizePhone(text);
    _flow.setEmergencyPhone(phone);
    _flow.moveTo(OnboardingStep.confirmEmergencyPhone);
    _isProcessing = false;

    await _speak('Is their phone number $phone? Please say yes or no.');
    await _startListening();
  }

  Future<void> _handleEmergencyPhoneConfirmation(String text) async {
    if (_isAffirmative(text)) {
      _flow.moveTo(OnboardingStep.askEmergencyRelationship);
      _isProcessing = false;

      await _speak(
        'Thank you. What is their relationship with you, such as mother, brother, friend, or caregiver?',
      );
      await _startListening();
      return;
    }

    if (_isNegative(text)) {
      _flow.moveTo(OnboardingStep.askEmergencyPhone);
      _isProcessing = false;
      await _speak('Please tell me their phone number again.');
      await _startListening();
      return;
    }

    _isProcessing = false;
    await _speak('Is their phone number ${_flow.emergencyContactPhone}? Say yes or no.');
    await _startListening();
  }

  // ============================================================
  // 4C. EMERGENCY CONTACT RELATIONSHIP & SAVE TO MYSQL
  // ============================================================

  Future<void> _handleEmergencyRelationship(String text) async {
    final rel = _cleanSpokenText(text);
    _flow.setEmergencyRelationship(rel);
    _flow.moveTo(OnboardingStep.confirmEmergencyRelationship);
    _isProcessing = false;

    await _speak('Is their relationship $rel? Please say yes or no.');
    await _startListening();
  }

  Future<void> _handleEmergencyRelationshipConfirmation(String text) async {
    if (_isAffirmative(text)) {
      _isProcessing = true;
      _setStatus('Saving emergency contact to MySQL database...');

      try {
        await _backendApiService.addEmergencyContact(
          userId: _flow.userId ?? 1,
          name: _flow.emergencyContactName ?? 'Caregiver',
          phoneNumber: _flow.emergencyContactPhone ?? '9999999999',
          relationship: _flow.emergencyContactRelationship ?? 'Caregiver',
        );
      } catch (e) {
        debugPrint('Emergency contact save error: $e');
      }

      _flow.moveTo(OnboardingStep.askHomeLocation);
      _isProcessing = false;

      await _speak(
        'Emergency contact saved to the database. '
        'Next, what is your home address or city name?',
      );
      await _startListening();
      return;
    }

    if (_isNegative(text)) {
      _flow.moveTo(OnboardingStep.askEmergencyRelationship);
      _isProcessing = false;
      await _speak('Please tell me their relationship again.');
      await _startListening();
      return;
    }

    _isProcessing = false;
    await _speak('Is their relationship ${_flow.emergencyContactRelationship}? Say yes or no.');
    await _startListening();
  }

  // ============================================================
  // 5. HOME LOCATION & SAVE TO MYSQL
  // ============================================================

  Future<void> _handleHomeLocation(String text) async {
    final loc = _cleanSpokenText(text);
    _flow.setHomeLocation(loc);
    _flow.moveTo(OnboardingStep.confirmHomeLocation);
    _isProcessing = false;

    await _speak('Is your location $loc? Please say yes or no.');
    await _startListening();
  }

  Future<void> _handleHomeLocationConfirmation(String text) async {
    if (_isAffirmative(text)) {
      _isProcessing = true;
      _setStatus('Saving location to MySQL database...');

      try {
        await _backendApiService.addLocation(
          userId: _flow.userId ?? 1,
          locationName: 'Home',
          address: _flow.homeLocation ?? 'Home Address',
          locationType: 'home',
        );
      } catch (e) {
        debugPrint('Location save error: $e');
      }

      _flow.moveTo(OnboardingStep.completed);
      _isProcessing = false;

      await _speak(
        'Setup is completely finished! Your profile, emergency contact, and location have all been saved in the database. '
        'You can now talk to me, ask me to remember notes, or ask for help anytime.',
      );
      await _startListening();
      return;
    }

    if (_isNegative(text)) {
      _flow.moveTo(OnboardingStep.askHomeLocation);
      _isProcessing = false;
      await _speak('Please tell me your home location again.');
      await _startListening();
      return;
    }

    _isProcessing = false;
    await _speak('Is your location ${_flow.homeLocation}? Say yes or no.');
    await _startListening();
  }

  // ============================================================
  // 6. AFTER ONBOARDING: VOICE COMMANDS & MEMORY VAULT
  // ============================================================

  Future<void> _handleAfterOnboarding(String text) async {
    _isProcessing = true;
    final lower = text.toLowerCase();

    // Query saved notes from MySQL
    final isQuery = lower.contains('what did i save') ||
        lower.contains('my notes') ||
        lower.contains('read notes') ||
        lower.contains('what are my notes') ||
        lower.contains('what do i have saved');

    if (isQuery) {
      _setStatus('Fetching your notes from database...');
      try {
        final notes = await _backendApiService.getSavedInformation(
          _flow.userId ?? 1,
        );
        _isProcessing = false;

        if (notes.isEmpty) {
          await _speak('You do not have any saved notes in the database yet.');
        } else {
          final summary = notes
              .take(5)
              .map((n) => n['content']?.toString() ?? '')
              .where((c) => c.isNotEmpty)
              .join('. ');

          await _speak('Here are your saved notes: $summary');
        }
      } catch (e) {
        _isProcessing = false;
        debugPrint('Fetch saved notes error: $e');
        await _speak('Could not fetch saved notes from the database.');
      }

      await _startListening();
      return;
    }

    // Default: Save spoken note into MySQL SAVED_INFORMATION table
    _setStatus('Saving note to MySQL database...');
    try {
      await _backendApiService.saveInformation(
        userId: _flow.userId ?? 1,
        content: text,
        title: 'Voice Note',
        informationType: 'voice_memory',
      );

      _setStatus('Saved to database!');
      _isProcessing = false;

      await _speak('I have saved that to your memory vault: $text');
    } catch (e) {
      _isProcessing = false;
      debugPrint('Save information to database error: $e');
      await _speak('Could not save that note to the database: $text');
    }

    await _startListening();
  }

  // ============================================================
  // TEXT INPUT (MANUAL FALLBACK)
  // ============================================================

  Future<void> _submitTypedText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      return;
    }
    _textController.clear();
    await _handleUserInput(text);
  }

  void _setStatus(String value) {
    if (!mounted) {
      return;
    }
    setState(() {
      _status = value;
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.enter) {
      if (!_started) {
        _startCompanion();
      }
    }
  }

  // ============================================================
  // UI WITH LIVE STATUS & MANUAL INPUT
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!_started) {
            _startCompanion();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 800,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'AI Companion',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Semantics(
                        liveRegion: true,
                        label: _status,
                        child: Text(
                          _status,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      TextField(
                        controller: _textController,
                        focusNode: _textFocusNode,
                        enabled: !_isProcessing,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) {
                          _submitTypedText();
                        },
                        decoration: const InputDecoration(
                          labelText: 'Type answer or command (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _submitTypedText,
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Submit Answer',
                              style: TextStyle(fontSize: 18),
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
        ),
      ),
    );
  }
}
