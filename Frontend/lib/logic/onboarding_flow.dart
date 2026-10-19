enum OnboardingStep {
  welcome,
  askName,
  confirmName,
  askEmail,
  confirmEmail,
  askPhone,
  confirmPhone,
  askEmergencyName,
  confirmEmergencyName,
  askEmergencyPhone,
  confirmEmergencyPhone,
  askEmergencyRelationship,
  confirmEmergencyRelationship,
  askHomeLocation,
  confirmHomeLocation,
  completed,
}

class OnboardingFlow {
  OnboardingStep currentStep = OnboardingStep.welcome;

  String? userName;
  String? userEmail;
  String? phoneNumber;

  String? emergencyContactName;
  String? emergencyContactPhone;
  String? emergencyContactRelationship;

  String? homeLocation;

  int? userId;

  void setName(String name) {
    userName = name;
  }

  void setEmail(String email) {
    userEmail = email;
  }

  void setPhone(String phone) {
    phoneNumber = phone;
  }

  void setEmergencyName(String name) {
    emergencyContactName = name;
  }

  void setEmergencyPhone(String phone) {
    emergencyContactPhone = phone;
  }

  void setEmergencyRelationship(String relationship) {
    emergencyContactRelationship = relationship;
  }

  void setHomeLocation(String location) {
    homeLocation = location;
  }

  void setUserId(int id) {
    userId = id;
  }

  void moveTo(OnboardingStep step) {
    currentStep = step;
  }
}
