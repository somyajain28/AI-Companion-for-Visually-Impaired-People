enum OnboardingStep {
  welcome,
  askRegisterOrLogin,

  // Login steps
  askLoginUsername,
  confirmLoginUsername,
  askLoginPassword,

  // Registration steps
  askRegisterName,
  confirmRegisterName,
  askRegisterEmail,
  confirmRegisterEmail,
  askRegisterDob,
  confirmRegisterDob,
  askRegisterPhone,
  confirmRegisterPhone,
  askRegisterPassword,
  confirmRegisterPassword,

  // Emergency contact steps (Name, Relationship, Phone)
  askEmergencyName,
  confirmEmergencyName,
  askEmergencyRelationship,
  confirmEmergencyRelationship,
  askEmergencyPhone,
  confirmEmergencyPhone,

  // Location steps (Name, Type)
  askLocationName,
  confirmLocationName,
  askLocationType,
  confirmLocationType,

  completed,
}

class OnboardingFlow {
  OnboardingStep currentStep = OnboardingStep.welcome;

  // Login data
  String? loginUsername;
  String? loginPassword;

  // Registration user data
  String? userName;
  String? userEmail;
  String? dateOfBirth;
  String? phoneNumber;
  String? password;

  // Emergency contact
  String? emergencyContactName;
  String? emergencyContactRelationship;
  String? emergencyContactPhone;

  // Location
  String? locationName;
  String? locationType;

  int? userId;

  void moveTo(OnboardingStep step) {
    currentStep = step;
  }

  void setLoginUsername(String name) {
    loginUsername = name;
  }

  void setLoginPassword(String pass) {
    loginPassword = pass;
  }

  void setName(String name) {
    userName = name;
  }

  void setEmail(String email) {
    userEmail = email;
  }

  void setDob(String dob) {
    dateOfBirth = dob;
  }

  void setPhone(String phone) {
    phoneNumber = phone;
  }

  void setPassword(String pass) {
    password = pass;
  }

  void setEmergencyName(String name) {
    emergencyContactName = name;
  }

  void setEmergencyRelationship(String relationship) {
    emergencyContactRelationship = relationship;
  }

  void setEmergencyPhone(String phone) {
    emergencyContactPhone = phone;
  }

  void setLocationName(String name) {
    locationName = name;
  }

  void setLocationType(String type) {
    locationType = type;
  }

  void setUserId(int id) {
    userId = id;
  }
}
