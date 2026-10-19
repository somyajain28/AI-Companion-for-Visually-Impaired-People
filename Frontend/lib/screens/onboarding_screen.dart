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

      await _askRegisterOrLogin();
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
  // HELPERS: AFFIRMATION, NEGATION & SANITIZATION
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

  String _cleanPassword(String input) {
    var pass = input.trim();
    final prefixes = [
      'my password should be',
      'password should be',
      'my password will be',
      'password will be',
      'set password to',
      'the password is',
      'my password is',
      'password is',
      'it is',
      "it's",
      'my password',
      'password'
    ];
    for (final p in prefixes) {
      if (pass.toLowerCase().startsWith(p) && pass.length > p.length) {
        pass = pass.substring(p.length).trim();
        break;
      }
    }
    pass = pass.replaceAll(RegExp(r'[\.\,\!\?]+$'), '').trim();
    if (RegExp(r'^(\d\s*)+$').hasMatch(pass)) {
      pass = pass.replaceAll(RegExp(r'\s+'), '');
    }
    return pass;
  }

  String _cleanDob(String input) {
    var dob = input.trim();
    final prefixes = [
      'my date of birth should be',
      'date of birth should be',
      'my date of birth is',
      'date of birth is',
      'my dob is',
      'dob is',
      'i was born on',
      'it is',
      "it's",
      'date of birth',
      'dob'
    ];
    for (final p in prefixes) {
      if (dob.toLowerCase().startsWith(p) && dob.length > p.length) {
        dob = dob.substring(p.length).trim();
        break;
      }
    }
    return dob.replaceAll(RegExp(r'[\.\,\!\?]+$'), '').trim();
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
  // STATE MACHINE: REGISTER VS LOGIN ROUTING
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
      case OnboardingStep.askRegisterOrLogin:
        await _handleRegisterOrLoginChoice(text);
        break;

      // ----------------- LOGIN STEPS -----------------
      case OnboardingStep.askLoginUsername:
        await _handleLoginUsername(text);
        break;

      case OnboardingStep.confirmLoginUsername:
        await _handleLoginUsernameConfirmation(text);
        break;

      case OnboardingStep.askLoginPassword:
        await _handleLoginPassword(text);
        break;

      // ----------------- REGISTRATION STEPS -----------------
      case OnboardingStep.askRegisterName:
        await _handleRegisterName(text);
        break;

      case OnboardingStep.confirmRegisterName:
        await _handleRegisterNameConfirmation(text);
        break;

      case OnboardingStep.askRegisterEmail:
        await _handleRegisterEmail(text);
        break;

      case OnboardingStep.confirmRegisterEmail:
        await _handleRegisterEmailConfirmation(text);
        break;

      case OnboardingStep.askRegisterDob:
        await _handleRegisterDob(text);
        break;

      case OnboardingStep.confirmRegisterDob:
        await _handleRegisterDobConfirmation(text);
        break;

      case OnboardingStep.askRegisterPhone:
        await _handleRegisterPhone(text);
        break;

      case OnboardingStep.confirmRegisterPhone:
        await _handleRegisterPhoneConfirmation(text);
        break;

      case OnboardingStep.askRegisterPassword:
        await _handleRegisterPassword(text);
        break;

      case OnboardingStep.confirmRegisterPassword:
        await _handleRegisterPasswordConfirmation(text);
        break;

      // ----------------- EMERGENCY CONTACT STEPS -----------------
      case OnboardingStep.askEmergencyName:
        await _handleEmergencyName(text);
        break;

      case OnboardingStep.confirmEmergencyName:
        await _handleEmergencyNameConfirmation(text);
        break;

      case OnboardingStep.askEmergencyRelationship:
        await _handleEmergencyRelationship(text);
        break;

      case OnboardingStep.confirmEmergencyRelationship:
        await _handleEmergencyRelationshipConfirmation(text);
        break;

      case OnboardingStep.askEmergencyPhone:
        await _handleEmergencyPhone(text);
        break;

      case OnboardingStep.confirmEmergencyPhone:
        await _handleEmergencyPhoneConfirmation(text);
        break;

      // ----------------- LOCATION STEPS -----------------
      case OnboardingStep.askLocationName:
        await _handleLocationName(text);
        break;

      case OnboardingStep.confirmLocationName:
        await _handleLocationNameConfirmation(text);
        break;

      case OnboardingStep.askLocationType:
        await _handleLocationType(text);
        break;

      case OnboardingStep.confirmLocationType:
        await _handleLocationTypeConfirmation(text);
        break;

      case OnboardingStep.completed:
        await _handleAfterOnboarding(text);
        break;
    }
  }

  // ============================================================
  // STEP 0: ASK REGISTER OR LOGIN
  // ============================================================

  Future<void> _askRegisterOrLogin() async {
    if (!mounted) return;
    _flow.moveTo(OnboardingStep.askRegisterOrLogin);
    _isProcessing = false;
    await _speak('Welcome to AI Companion. Do you want to register or login?');
    await _startListening();
  }

  Future<void> _handleRegisterOrLoginChoice(String text) async {
    final lower = text.toLowerCase().trim();

    if (lower.contains('register') ||
        lower.contains('new') ||
        lower.contains('sign up') ||
        lower.contains('create')) {
      _flow.moveTo(OnboardingStep.askRegisterName);
      _isProcessing = false;
      await _speak('Let us register your account. Please tell me your full name.');
      await _startListening();
      return;
    }

    if (lower.contains('login') ||
        lower.contains('log in') ||
        lower.contains('sign in') ||
        lower.contains('existing')) {
      _flow.moveTo(OnboardingStep.askLoginUsername);
      _isProcessing = false;
      await _speak('Welcome back. Please tell me your user name.');
      await _startListening();
      return;
    }

    _isProcessing = false;
    await _speak('Please say register to create a new account, or login to sign in.');
    await _startListening();
  }

  // ============================================================
  // LOGIN FLOW (USERNAME & PASSWORD VALIDATION)
  // ============================================================

  Future<void> _handleLoginUsername(String text) async {
    final name = _cleanSpokenText(text);
    if (name.isEmpty) {
      _isProcessing = false;
      await _speak('I did not catch your user name. Please say it again.');
      await _startListening();
      return;
    }

    _flow.setLoginUsername(name);
    _flow.moveTo(OnboardingStep.confirmLoginUsername);
    _isProcessing = false;

    await _speak('Is your user name $name? Please say yes or no.');
    await _startListening();
  }

  Future<void> _handleLoginUsernameConfirmation(String text) async {
    if (_isAffirmative(text)) {
      _flow.moveTo(OnboardingStep.askLoginPassword);
      _isProcessing = false;
      await _speak('Please tell me your password.');
      await _startListening();
      return;
    }

    if (_isNegative(text)) {
      _flow.moveTo(OnboardingStep.askLoginUsername);
      _isProcessing = false;
      await _speak('Alright. Please tell me your user name again.');
      await _startListening();
      return;
    }

    _isProcessing = false;
    await _speak('Is your user name ${_flow.loginUsername}? Say yes or no.');
    await _startListening();
  }

  Future<void> _handleLoginPassword(String text) async {
    final password = _cleanPassword(text);
    _flow.setLoginPassword(password);

    _setStatus('Validating credentials with database...');
    final result = await _backendApiService.loginUser(
      userName: _flow.loginUsername ?? '',
      password: password,
    );

    _isProcessing = false;

    if (result['success'] == true) {
      final user = result['user'] as Map<String, dynamic>;
      final userId = user['user_id'] as int;
      _flow.setUserId(userId);
      _flow.setName(user['user_name'] ?? _flow.loginUsername ?? 'User');
      _flow.moveTo(OnboardingStep.completed);

      await _speak('Login successful! Welcome back, ${_flow.userName}. You can now talk to me, ask me to remember notes, or ask for help anytime.');
      await _startListening();
      return;
    }

    final errorType = result['error_type'];

    if (errorType == 'user_not_found') {
      await _speak('No user registered with this name. Please register.');
      _flow.moveTo(OnboardingStep.askRegisterName);
      await _speak('Let us create your account now. Please tell me your full name.');
      await _startListening();
      return;
    }

    if (errorType == 'incorrect_password') {
      await _speak('Incorrect password. Please try again.');
      _flow.moveTo(OnboardingStep.askLoginPassword);
      await _startListening();
      return;
    }

    // Generic error fallback
    await _speak('Login failed: ${result['message']}. Please try again.');
    await _startListening();
  }

  // ============================================================
  // REGISTRATION FLOW (ORDER: NAME, EMAIL, DOB, PHONE, PASSWORD)
  // ============================================================

  // 1. NAME
  Future<void> _handleRegisterName(String text) async {
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
    _flow.moveTo(OnboardingStep.confirmRegisterName);
    _isProcessing = false;

    await _speak('Is your name $name? Please say yes or no.');
    await _startListening();
  }

  Future<void> _handleRegisterNameConfirmation(String text) async {
    if (_isAffirmative(text)) {
      _flow.moveTo(OnboardingStep.askRegisterEmail);
      _isProcessing = false;
      await _speak('Great, ${_flow.userName}. Now please tell me your email address.');
      await _startListening();
      return;
    }

    if (_isNegative(text)) {
      _flow.moveTo(OnboardingStep.askRegisterName);
      _isProcessing = false;
      await _speak('Alright. Please tell me your name again.');
      await _startListening();
      return;
    }

    _isProcessing = false;
    await _speak('Is your name ${_flow.userName}? Please say yes or no.');
    await _startListening();
  }

  // 2. EMAIL
  Future<void> _handleRegisterEmail(String text) async {
    final email = _sanitizeEmail(text);
    _flow.setEmail(email);
    _flow.moveTo(OnboardingStep.confirmRegisterEmail);
    _isProcessing = false;

    await _speak('Is your email $email? Please say yes or no.');
    await _startListening();
  }

  Future<void> _handleRegisterEmailConfirmation(String text) async {
    if (_isAffirmative(text)) {
      _flow.moveTo(OnboardingStep.askRegisterDob);
      _isProcessing = false;
      await _speak('Thank you. Now please tell me your date of birth, for example: 15 August 2000.');
      await _startListening();
      return;
    }

    if (_isNegative(text)) {
      _flow.moveTo(OnboardingStep.askRegisterEmail);
      _isProcessing = false;
      await _speak('Please tell me your email address again.');
      await _startListening();
      return;
    }

    _isProcessing = false;
    await _speak('Is your email ${_flow.userEmail}? Please say yes or no.');
    await _startListening();
  }

  // 3. DATE OF BIRTH (DOB)
  Future<void> _handleRegisterDob(String text) async {
    final dob = _cleanDob(text);
    _flow.setDob(dob);
    _flow.moveTo(OnboardingStep.confirmRegisterDob);
    _isProcessing = false;

    await _speak('Is your date of birth $dob? Please say yes or no.');
    await _startListening();
  }

  Future<void> _handleRegisterDobConfirmation(String text) async {
    if (_isAffirmative(text)) {
      _flow.moveTo(OnboardingStep.askRegisterPhone);
      _isProcessing = false;
      await _speak('Got it. Now please tell me your 10-digit mobile phone number.');
      await _startListening();
      return;
    }

    if (_isNegative(text)) {
      _flow.moveTo(OnboardingStep.askRegisterDob);
      _isProcessing = false;
      await _speak('Please tell me your date of birth again.');
      await _startListening();
      return;
    }

    _isProcessing = false;
    await _speak('Is your date of birth ${_flow.dateOfBirth}? Say yes or no.');
    await _startListening();
  }

  // 4. PHONE NUMBER
  Future<void> _handleRegisterPhone(String text) async {
    final phone = _sanitizePhone(text);
    _flow.setPhone(phone);
    _flow.moveTo(OnboardingStep.confirmRegisterPhone);
    _isProcessing = false;

    await _speak('Is your phone number $phone? Please say yes or no.');
    await _startListening();
  }

  Future<void> _handleRegisterPhoneConfirmation(String text) async {
    if (_isAffirmative(text)) {
      _flow.moveTo(OnboardingStep.askRegisterPassword);
      _isProcessing = false;
      await _speak('Thank you. Please choose a password for your account.');
      await _startListening();
      return;
    }

    if (_isNegative(text)) {
      _flow.moveTo(OnboardingStep.askRegisterPhone);
      _isProcessing = false;
      await _speak('Please tell me your phone number again.');
      await _startListening();
      return;
    }

    _isProcessing = false;
    await _speak('Is your phone number ${_flow.phoneNumber}? Say yes or no.');
    await _startListening();
  }

  // 5. PASSWORD & USER TABLE INSERT
  Future<void> _handleRegisterPassword(String text) async {
    final pass = _cleanPassword(text);
    _flow.setPassword(pass);
    _flow.moveTo(OnboardingStep.confirmRegisterPassword);
    _isProcessing = false;

    await _speak('Is your password $pass? Please say yes or no.');
    await _startListening();
  }

  Future<void> _handleRegisterPasswordConfirmation(String text) async {
    if (_isAffirmative(text)) {
      _isProcessing = true;
      _setStatus('Registering user in MySQL database...');

      final regResult = await _backendApiService.registerUser(
        userName: _flow.userName ?? 'User',
        userEmail: _flow.userEmail ?? 'user@companion.local',
        dateOfBirth: _flow.dateOfBirth ?? '2000-01-01',
        phoneNumber: _flow.phoneNumber ?? '0000000000',
        password: _flow.password ?? '123456',
        preferredLanguage: 'English',
      );

      if (regResult['success'] == true) {
        final user = regResult['user'] as Map<String, dynamic>;
        _flow.setUserId(user['user_id'] as int);
      } else {
        debugPrint('Registration note: ${regResult['message']}');
      }

      // Move to emergency person details
      _flow.moveTo(OnboardingStep.askEmergencyName);
      _isProcessing = false;

      await _speak('Your profile is saved in the database. For your safety, let us add an emergency contact person. What is their name?');
      await _startListening();
      return;
    }

    if (_isNegative(text)) {
      _flow.moveTo(OnboardingStep.askRegisterPassword);
      _isProcessing = false;
      await _speak('Please tell me your password again.');
      await _startListening();
      return;
    }

    _isProcessing = false;
    await _speak('Is your password ${_flow.password}? Say yes or no.');
    await _startListening();
  }

  // ============================================================
  // EMERGENCY PERSON DETAILS (NAME, RELATIONSHIP, PHONE)
  // ============================================================

  // 6. EMERGENCY NAME
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
      _flow.moveTo(OnboardingStep.askEmergencyRelationship);
      _isProcessing = false;
      await _speak('What is their relationship with you, such as father, mother, spouse, or friend?');
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

  // 7. EMERGENCY RELATIONSHIP
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
      _flow.moveTo(OnboardingStep.askEmergencyPhone);
      _isProcessing = false;
      await _speak('What is ${_flow.emergencyContactName} phone number?');
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

  // 8. EMERGENCY PHONE NUMBER & SAVE TO MYSQL
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
      _isProcessing = true;
      _setStatus('Saving emergency contact to MySQL database...');

      try {
        await _backendApiService.addEmergencyContact(
          userId: _flow.userId ?? 1,
          name: _flow.emergencyContactName ?? 'Caregiver',
          relationship: _flow.emergencyContactRelationship ?? 'Family',
          phoneNumber: _flow.emergencyContactPhone ?? '9999999999',
        );
      } catch (e) {
        debugPrint('Emergency contact save error: $e');
      }

      _flow.moveTo(OnboardingStep.askLocationName);
      _isProcessing = false;

      await _speak('Emergency contact saved. Now let us save your location. What is your location name or address?');
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
  // LOCATION DETAILS (LOCATION NAME, LOCATION TYPE)
  // ============================================================

  // 9. LOCATION NAME
  Future<void> _handleLocationName(String text) async {
    final loc = _cleanSpokenText(text);
    _flow.setLocationName(loc);
    _flow.moveTo(OnboardingStep.confirmLocationName);
    _isProcessing = false;

    await _speak('Is your location $loc? Please say yes or no.');
    await _startListening();
  }

  Future<void> _handleLocationNameConfirmation(String text) async {
    if (_isAffirmative(text)) {
      _flow.moveTo(OnboardingStep.askLocationType);
      _isProcessing = false;
      await _speak('What is this location type, like Home or Office?');
      await _startListening();
      return;
    }

    if (_isNegative(text)) {
      _flow.moveTo(OnboardingStep.askLocationName);
      _isProcessing = false;
      await _speak('Please tell me your location address again.');
      await _startListening();
      return;
    }

    _isProcessing = false;
    await _speak('Is your location ${_flow.locationName}? Say yes or no.');
    await _startListening();
  }

  // 10. LOCATION TYPE & SAVE TO MYSQL
  Future<void> _handleLocationType(String text) async {
    final type = _cleanSpokenText(text);
    _flow.setLocationType(type);
    _flow.moveTo(OnboardingStep.confirmLocationType);
    _isProcessing = false;

    await _speak('Is this location type $type? Please say yes or no.');
    await _startListening();
  }

  Future<void> _handleLocationTypeConfirmation(String text) async {
    if (_isAffirmative(text)) {
      _isProcessing = true;
      _setStatus('Saving location to MySQL database...');

      try {
        await _backendApiService.addLocation(
          userId: _flow.userId ?? 1,
          locationName: _flow.locationName ?? 'My Place',
          locationType: _flow.locationType ?? 'home',
          address: _flow.locationName,
        );
      } catch (e) {
        debugPrint('Location save error: $e');
      }

      _flow.moveTo(OnboardingStep.completed);
      _isProcessing = false;

      await _speak('Setup is completely finished! All your profile, emergency contact, and location details have been saved in the database. You can now talk to me, ask me to remember notes, or ask for help anytime.');
      await _startListening();
      return;
    }

    if (_isNegative(text)) {
      _flow.moveTo(OnboardingStep.askLocationType);
      _isProcessing = false;
      await _speak('Please tell me your location type again, like Home or Office.');
      await _startListening();
      return;
    }

    _isProcessing = false;
    await _speak('Is your location type ${_flow.locationType}? Say yes or no.');
    await _startListening();
  }

  // ============================================================
  // AFTER ONBOARDING: COMMANDS & MEMORY VAULT
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
  // ACCESSIBLE UI
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
