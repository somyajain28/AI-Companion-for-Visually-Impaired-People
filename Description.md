
# AI Companion for Visually Impaired People
### Intelligent Navigation and Assistance System

An AI-powered accessibility assistant designed to help blind and visually impaired people interact with their surroundings through voice, camera input, conversational AI, and accessible audio feedback.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Problem Statement](#2-problem-statement)
3. [Objectives](#3-objectives)
4. [Target Users](#4-target-users)
5. [Core Design Principles](#5-core-design-principles)
6. [Key Features](#6-key-features)
7. [User Interaction Model](#7-user-interaction-model)
8. [System Workflow](#8-system-workflow)
9. [Speech-to-Text](#9-speech-to-text)
10. [Conversational AI and Intent Processing](#10-conversational-ai-and-intent-processing)
11. [OCR and Automatic Image Quality Assessment](#11-ocr-and-automatic-image-quality-assessment)
12. [Currency Recognition](#12-currency-recognition)
13. [Object Detection and Scene Understanding](#13-object-detection-and-scene-understanding)
14. [Navigation and Location Services](#14-navigation-and-location-services)
15. [Multilingual Support and Translation](#15-multilingual-support-and-translation)
16. [Text-to-Speech](#16-text-to-speech)
17. [Emergency Assistance](#17-emergency-assistance)
18. [Frontend Architecture](#18-frontend-architecture)
19. [Backend Architecture](#19-backend-architecture)
20. [Database Design](#20-database-design)
21. [API Integration](#21-api-integration)
22. [Technology Stack](#22-technology-stack)
23. [Project Structure](#23-project-structure)
24. [Online and Offline Operation](#24-online-and-offline-operation)
25. [Security and Privacy](#25-security-and-privacy)
26. [Reliability and Error Handling](#26-reliability-and-error-handling)
27. [Development Roadmap](#27-development-roadmap)
28. [Testing and Verification](#28-testing-and-verification)
29. [Limitations](#29-limitations)
30. [Future Scope](#30-future-scope)
31. [Expected Outcome](#31-expected-outcome)
32. [Getting Started](#32-getting-started)
33. [Team Development and GitHub Workflow](#33-team-development-and-github-workflow)
34. [Viva Explanation](#34-viva-explanation)

---

## 1. Project Overview

AI Companion for Visually Impaired People is an accessibility-focused software system intended to bring several assistive technologies together in one application.

The system is designed primarily for blind and visually impaired users who need accessible ways to read printed information, identify objects, recognize currency, understand their surroundings, ask questions, and access navigation assistance.

Instead of relying entirely on a graphical interface, the application prioritizes voice interaction and spoken responses. Text input and visual controls are also available for partially sighted users, family members, and caregivers.

The system combines speech processing, computer vision, conversational AI, location services, external APIs, and database-backed user information.

### Core concept

**Voice or text input → Request understanding → Appropriate AI/service module → Result processing → Text and/or spoken response**

The project follows a hybrid architecture. Features that have suitable local models can work offline, while services that depend on external providers require an Internet connection.

---

## 2. Problem Statement

Blind and visually impaired people may encounter difficulties when reading printed documents, identifying currency, understanding unfamiliar environments, accessing location information, and interacting with conventional applications.

Many assistive applications focus on only one task, requiring users to switch between multiple tools. Camera-based applications can also be difficult to use when a person cannot visually determine whether the camera is correctly positioned or whether an image is suitable for text recognition.

The proposed system addresses these challenges by combining multiple assistive functions into a single accessible application.

A central technical focus is automatic image-quality assessment before OCR. The system should assess whether a captured image is suitable for text extraction and provide spoken guidance when the image needs improvement.

The system aims to make assistance more accessible and context-aware without claiming to replace a white cane, guide dog, trained mobility support, or dedicated safety equipment.

---

## 3. Objectives

The main objectives are:

- Develop a voice-first interface for visually impaired users.
- Provide text/manual interaction for users who prefer it.
- Integrate Speech-to-Text and Text-to-Speech.
- Implement OCR for reading text from camera images.
- Evaluate image quality automatically before OCR.
- Provide audio guidance when an image is unsuitable.
- Integrate currency recognition.
- Use YOLO-based object detection.
- Provide basic scene understanding and relevant-object assistance.
- Integrate conversational AI for general questions.
- Support multilingual interaction and translation.
- Provide location and navigation assistance.
- Maintain user information, preferences, emergency contacts, and saved information in a database.
- Support local processing where suitable models and hardware are available.
- Keep the architecture modular so that features can be developed and tested independently.
- Explore wearable integration and improved navigation assistance as future work.

---

## 4. Target Users

### 4.1 Visually impaired users

The primary interface is designed around voice input, spoken feedback, camera-assisted features, and accessible controls.

### 4.2 Partially sighted users

These users may use voice interaction, text input, readable interface elements, and visual controls according to their needs.

### 4.3 Family members and caregivers

The system can provide a visual/manual mode for configuring preferences, maintaining relevant user information, and managing emergency contacts.

All modes are intended to use the same backend services and shared application logic.

---

## 5. Core Design Principles

### 5.1 Assist, Don't Overwhelm

The system should provide relevant information instead of continuously announcing every detected object.

### 5.2 Voice-first accessibility

Important instructions and results should be available through speech. The user should not need to visually inspect a screen to understand the result of an accessibility task.

### 5.3 Modular architecture

Speech processing, OCR, object detection, currency recognition, navigation, and user management should be separated into logical modules.

### 5.4 Privacy by design

Camera frames and sensitive information should not be permanently stored unless required by a specific feature and permitted by the user.

### 5.5 Honest safety boundaries

Object detection alone does not provide reliable real-world distance or guarantee a safe walking route. Navigation assistance should be described according to the capabilities actually implemented and tested.

### 5.6 Hybrid operation

Locally supported features should not depend unnecessarily on Internet connectivity. Online features should handle unavailable connections gracefully.

---

## 6. Key Features

| Feature | Purpose | Main technology |
|---|---|---|
| Voice interaction | Accept spoken requests | STT and TTS |
| Text interaction | Accept typed requests | Flutter interface |
| Onboarding | Collect initial preferences and identity information | Conversation state machine |
| Speech-to-Text | Convert speech into text | Whisper / compatible STT |
| Conversational AI | Answer general questions | Local LLM / compatible runtime |
| OCR | Extract text from images | EasyOCR or Tesseract |
| Image-quality assessment | Check image suitability before OCR | OpenCV and image analysis |
| Currency recognition | Identify currency notes | Image classification/detection model |
| Object detection | Identify visible objects | YOLOv8 |
| Scene understanding | Describe a broader environment | Vision model / contextual processing |
| Translation | Translate supported text | Google translation service or equivalent |
| Navigation | Provide directions to a destination | Maps and navigation APIs |
| Location | Retrieve current or last-known location | Device location services |
| User management | Register and authenticate users | Flask and MySQL |
| Preferences | Save language and audio settings | MySQL |
| Emergency contacts | Maintain relevant contact details | MySQL |
| Emergency assistance | Support an appropriate emergency workflow | Application services and permitted contact/location access |

The table describes the intended functionality. Each feature should be marked implemented only after its integration and tests have been completed.

---

## 7. User Interaction Model

The application supports two interaction modes.

### 7.1 Voice-first mode

Intended flow:

1. The user opens the application.
2. The application requests any required permissions.
3. The user performs the initial activation gesture required by the browser or device.
4. The assistant welcomes the user.
5. The user speaks.
6. Speech is converted into text.
7. The request is interpreted and routed to the appropriate module.
8. The result is converted into speech.
9. The application continues the conversation when the required microphone and audio permissions remain available.

A web browser may require an initial user gesture before microphone capture or audio playback. Continuous listening must not be assumed to work without permissions or platform restrictions.

### 7.2 Text/manual mode

The interface should provide text input and accessible controls.

Example:

```text
+---------------------------------------+
|             AI Companion              |
|                                       |
|  Assistant: How can I help you?       |
|                                       |
|  [ Type your request here...       ]  |
|  [ Send ]                             |
|                                       |
|  Voice interaction                    |
|  Preferences                          |
+---------------------------------------+
```

The visual layout is illustrative. Actual controls should be accessible through screen readers, keyboard navigation, appropriate contrast, and meaningful labels.

### 7.3 User roles

- **Visually impaired user:** voice-first assistance and accessible audio feedback.
- **Family member/caregiver:** visual/manual interaction and relevant information management.

Role selection should only be added to the onboarding process when required by the application's implemented permissions and features.

---

## 8. System Workflow

```text
                  APPLICATION
                       |
                       v
              Initial Activation
                       |
                       v
                  Onboarding
                       |
                       v
              Voice / Text Input
                       |
                       v
             STT, if voice input
                       |
                       v
           Request / Intent Processing
                       |
        +--------------+--------------+
        |              |              |
        v              v              v
      Vision           AI          Navigation
        |              |              |
        v              v              v
   OCR / YOLO        Local LLM     Maps / GPS
   Currency          Conversation   Services
   Scene
        |              |              |
        +--------------+--------------+
                       |
                       v
               Result Processing
                       |
                       v
                Text / TTS Output
                       |
                       v
                     USER
```

Not every request uses every module. The request-processing layer selects the relevant functionality.

For example, an OCR request should activate the OCR pipeline rather than automatically running every available vision feature.

---

## 9. Speech-to-Text

Speech-to-Text (STT) converts the user's speech into text that can be processed by the application.

### Intended technology

- Whisper or faster-whisper, depending on the selected implementation and hardware.

### Workflow

```text
User speaks
    |
    v
Flutter records audio
    |
    v
Audio converted to bytes
    |
    v
SpeechApiService
    |
    v
POST /api/speech-to-text
    |
    v
Flask backend
    |
    v
Whisper / STT model
    |
    v
Recognized text
    |
    v
Application request processing
```

### Example

User says:

> "What is written here?"

The STT component returns recognized text. The request-processing component then identifies the OCR intent.

### Important implementation details

- The frontend and backend must agree on the audio request format.
- Supported formats and sample rates must be documented.
- The API must return a predictable response.
- Audio should not be stored permanently unless a specific requirement calls for it.
- Large speech models may require substantial installation space, memory, and processing resources.
- Local inference and cloud inference have different connectivity, privacy, and performance implications.

---

## 10. Conversational AI and Intent Processing

After speech is converted to text—or a user submits text directly—the system needs to understand what action is being requested.

The application should not use a separate hard-coded answer for every possible user question.

Instead, the architecture should separate:

1. Input processing
2. Request/intent identification
3. Feature selection
4. Module execution
5. Result handling
6. Response generation
7. Text-to-Speech

### Example request routing

| User request | Intended module |
|---|---|
| "Read this document." | OCR |
| "What note is this?" | Currency recognition |
| "What is in front of me?" | Object detection and contextual analysis |
| "Explain machine learning." | Conversational AI |
| "Translate this into Hindi." | Translation |
| "How do I reach the railway station?" | Navigation |
| "What is my last known location?" | Location service, subject to permission and available data |

A fixed state machine is appropriate for onboarding, but normal conversation should use a more general request-processing architecture.

### Local LLM

A local language model can be integrated through Ollama or another compatible runtime.

The exact model should be selected after evaluating:

- Hardware capacity
- Memory requirements
- Response quality
- Inference speed
- Supported languages
- Offline operation requirements

The project should not claim a specific model has been integrated until it has actually been selected and tested.

---

## 11. OCR and Automatic Image Quality Assessment

OCR (Optical Character Recognition) extracts text from an image.

Potential use cases include:

- Printed documents
- Books
- Signs
- Menus
- Product labels
- Notices
- Packaging
- Other visible text

### 11.1 Main accessibility requirement

A visually impaired user should not have to inspect a camera preview to decide whether the image is suitable for OCR.

The system should evaluate image quality automatically and provide audio instructions when the image needs improvement.

### 11.2 Image-quality checks

The intended checks include:

- Blur
- Brightness
- Focus/sharpness
- Text presence
- Text visibility
- Overall suitability for OCR

These checks can combine conventional image processing, text detection, and model-based assessment.

### 11.3 Complete OCR workflow

```text
User: "Read this."
          |
          v
     Speech-to-Text
          |
          v
      OCR Intent
          |
          v
      Camera Capture
          |
          v
  Automatic Image Quality Check
          |
          v
   Is image suitable?
       /         \
     NO           YES
     |             |
     v             v
Audio guidance    OCR
     |             |
     v             v
User adjusts    Extracted text
camera              |
     |              v
     +----------> Text-to-Speech
                    |
                    v
               User hears text
```

### 11.4 Audio camera guidance

Examples of appropriate feedback:

| Condition | Example audio instruction |
|---|---|
| Blurry image | "Hold the camera steady." |
| Text appears too far away | "Move closer." |
| Image too dark | "Try to improve the lighting." |
| Text not detected | "Point the camera toward the text." |
| Text only partly visible | "Move the camera slightly." |

The exact message should depend on the condition detected. The system should not repeatedly tell the user to change the lighting when the actual problem is blur.

### 11.5 OCR implementation flow

```text
Camera Image
     |
     v
OpenCV / Image Analysis
     |
     +--> Blur Assessment
     |
     +--> Brightness Assessment
     |
     +--> Sharpness Assessment
     |
     +--> Text Presence / Visibility
     |
     v
Image Suitability Decision
     |
     +--> Unsuitable: Spoken guidance and recapture
     |
     +--> Suitable: Preprocessing and OCR
                              |
                              v
                       Extracted text
                              |
                              v
                       Optional translation
                              |
                              v
                            TTS
```

Possible OCR engines include EasyOCR and Tesseract. The final choice should be based on accuracy, language support, installation requirements, and hardware performance.

**The automatic image-quality feedback loop is a central technical highlight of this project.**

---

## 12. Currency Recognition

The currency-recognition module uses a camera image to identify a currency note.

### Example workflow

```text
User: "What note is this?"
             |
             v
        Speech-to-Text
             |
             v
      Currency Recognition
             |
             v
       Model prediction
             |
             v
       Result validation
             |
             v
       Text-to-Speech
             |
             v
     "This appears to be a
      five-hundred-rupee note."
```

The model should return a confidence value or uncertainty indication when supported.

If the image is unclear or the model is uncertain, the system should ask the user to recapture the image rather than state an unreliable denomination as fact.

Currency recognition must be evaluated against representative images, lighting conditions, note orientations, and visually similar examples.

---

## 13. Object Detection and Scene Understanding

### 13.1 Object detection

YOLOv8 is a potential object-detection technology for identifying objects in camera images.

Examples of detectable categories depend on the model:

- People
- Chairs
- Tables
- Doors
- Bottles
- Vehicles
- Other supported objects

### 13.2 Object detection is not complete navigation

YOLOv8 identifies and locates objects within an image. It does not independently provide reliable real-world distance or determine a complete safe walking path.

The system must not infer an exact distance solely from a bounding box.

### 13.3 Relevant-object assistance

The project follows the principle of providing relevant information instead of announcing every detection.

Potential contextual signals include:

- The user's request
- The object's position in the image
- The detected object class
- Available scene context
- Additional sensor information, if implemented

Example:

```text
Camera image
     |
     v
YOLO object detection
     |
     v
Detected objects
     |
     v
Context / relevance processing
     |
     v
Select useful information
     |
     v
Spoken response
```

A possible response is:

> "A chair is visible ahead."

Such a statement should only be generated when the detected object's location supports it. It should not imply reliable collision prediction without suitable supporting sensors and logic.

### 13.4 Scene understanding

Scene understanding aims to describe the broader environment rather than listing only individual objects.

For example, a scene model might describe an image as an indoor office or a street containing pedestrians and vehicles.

Scene descriptions should be based on the actual capabilities and evaluation of the chosen model.

### 13.5 Future depth and obstacle assistance

More advanced obstacle assistance may require:

- Depth estimation
- Stereo or depth cameras
- Free-space detection
- Motion/activity sensing
- Additional spatial sensors
- Risk assessment
- Path-planning logic

These capabilities belong to future work unless implemented and tested in the current prototype.

---

## 14. Navigation and Location Services

### 14.1 Navigation assistance

The navigation module accepts a destination and uses available location and mapping services to obtain directions.

```text
User requests a destination
          |
          v
Speech-to-Text / Text Input
          |
          v
Navigation intent
          |
          v
Destination confirmation, if needed
          |
          v
Permitted location access
          |
          v
Maps / Navigation API
          |
          v
Route and instructions
          |
          v
Text-to-Speech
```

Online maps and navigation services may require an Internet connection.

### 14.2 Location management

Location functionality may support:

- Current location
- Last-known location
- Relevant location history, where permitted
- Location information for navigation
- Location information for an authorized emergency workflow

Useful fields can include latitude, longitude, timestamp, and accuracy.

Location history must not be treated as proof of a user's current location.

GPS can be unavailable, inaccurate, outdated, or affected by environmental conditions.

### 14.3 Location privacy

Location access should be permission-based. The system should collect and retain only the location information required for its features.

Access to stored location data must be restricted to authorized users and operations.

---

## 15. Multilingual Support and Translation

The application is intended to support multilingual interaction.

A multilingual request may follow this flow:

```text
User speaks
     |
     v
Speech recognition
     |
     v
Request processing
     |
     v
Required feature
     |
     v
Result
     |
     v
Translation, when required
     |
     v
TTS in the selected language
```

Google Language Translation is a proposed option for translation functionality.

The exact language coverage depends on the selected speech-recognition, translation, and speech-synthesis components.

Translation may require Internet access when an external translation API is used. Locally available language models may support selected offline workflows, but offline language support must be verified for the actual model and languages.

---

## 16. Text-to-Speech

Text-to-Speech converts textual results into spoken responses.

TTS is important because the user should be able to access information without relying on visual output.

Potential TTS output includes:

- OCR results
- Currency recognition results
- Object and scene descriptions
- Conversational AI responses
- Translation results
- Navigation instructions
- Image-quality guidance
- System notifications
- Emergency-related messages

The TTS implementation should support appropriate language selection, speech-rate preferences where available, interruption of outdated messages, and understandable audio feedback.

---

## 17. Emergency Assistance

The database can store emergency-contact information for use by an implemented emergency workflow.

A possible future workflow is:

```text
User activates emergency assistance
               |
               v
       Emergency workflow
               |
               v
  Obtain permitted available information
               |
               v
    Prepare an appropriate alert
               |
               v
 Contact or notification service
               |
               v
      Report delivery status
```

Actual message delivery, calling, notifications, and emergency integrations must be implemented separately.

The system should not claim that storing an emergency contact alone provides automatic emergency calling or guarantees rescue.

Emergency actions should use explicit permissions, suitable confirmation rules, and secure access to user and location data.

---

## 18. Frontend Architecture

### Technology

- Flutter

### Responsibilities

- Accessible user interface
- Voice interaction
- Audio recording
- Text input
- Camera interaction
- Text-to-Speech playback
- Onboarding
- Login and registration interfaces
- Preference controls
- API communication
- Displaying responses and errors

### Speech integration

The intended frontend flow is:

```text
Microphone
    |
    v
Audio recording
    |
    v
Audio data / Uint8List
    |
    v
SpeechApiService
    |
    v
Flask API
    |
    v
Recognized text
    |
    v
Conversation processing
```

The Flutter client must send audio in the format expected by the backend.

### API configuration

The address `http://127.0.0.1:5000` refers to the loopback interface of the machine making the request.

Consequently:

- On a laptop running both Flutter and Flask, loopback may be appropriate.
- On a different laptop, `127.0.0.1` refers to that other laptop, not the machine hosting Flask.
- For a device or browser accessing a backend on another machine, the API address must be configured for the actual network and deployment environment.
- A production deployment should use an appropriate secure URL.

The API base URL should be configurable instead of being scattered across the application.

---

## 19. Backend Architecture

### Technology

- Python
- Flask
- Flask-CORS, configured for the intended frontend origin
- MySQL

Flask is the central API layer between the frontend, AI modules, external services, and database.

### Responsibilities

- Receive API requests
- Validate input
- Manage user authentication
- Route requests to appropriate services
- Integrate Whisper/STT
- Integrate OCR and computer-vision modules
- Integrate conversational AI
- Communicate with external APIs
- Read and write persistent information
- Return consistent JSON responses
- Handle service errors

### Conceptual architecture

```text
                Flutter Frontend
                       |
                       v
                   Flask API
                       |
       +---------------+----------------+
       |               |                |
       v               v                v
  Speech Services  AI / Vision      User Services
       |               |                |
       v               v                v
     Whisper       OCR / YOLO          MySQL
                   Currency
                   Scene
                       |
                       v
              Maps / Translation
              when required
                       |
                       v
                Response Handler
                       |
                       v
                 Flutter / TTS
```

The backend should keep HTTP routes, business logic, model inference, and database access in separate modules where practical.

---

## 20. Database Design

The intended relational database is named `ai_companion`.

The design uses five main entities:

1. USER
2. USER_PREFERENCES
3. LOCATION
4. EMERGENCY_CONTACT
5. SAVED_INFORMATION

### 20.1 USER

| Column | Purpose |
|---|---|
| `user_id` | Primary key |
| `name` | User's name |
| `email` | Account email |
| `password_hash` | Secure password hash |
| `date_of_birth` | Date of birth |
| `phone_number` | Phone number |

Passwords must be stored as secure hashes, not plain text.

### 20.2 USER_PREFERENCES

| Column | Purpose |
|---|---|
| `preference_id` | Primary key |
| `user_id` | Foreign key referencing USER |
| `preferred_language` | Preferred application language |
| `voice_language` | Preferred speech language |
| `speech_rate` | Preferred speech rate |
| `audio_guidance` | Audio guidance preference |

A UNIQUE constraint on `user_id` enforces the intended one-to-one relationship.

### 20.3 LOCATION

| Column | Purpose |
|---|---|
| `location_id` | Primary key |
| `user_id` | Foreign key referencing USER |
| `location_name` | Name associated with the location |
| `location_type` | Type of location |
| `address` | Address, when available |
| `latitude` | Latitude |
| `longitude` | Longitude |

Location timestamps and accuracy should be included where needed by the implementation.

### 20.4 EMERGENCY_CONTACT

| Column | Purpose |
|---|---|
| `contact_id` | Primary key |
| `user_id` | Foreign key referencing USER |
| `name` | Contact name |
| `phone_number` | Contact phone number |
| `relationship` | Relationship to user |

### 20.5 SAVED_INFORMATION

| Column | Purpose |
|---|---|
| `saved_info_id` | Primary key |
| `user_id` | Foreign key referencing USER |
| `information` | Saved information |
| `information_type` | Information category |
| `saved_date` | Date/time saved |

### 20.6 Relationships

```text
USER
 |
 +---- 1:1 ---- USER_PREFERENCES
 |
 +---- 1:M ---- LOCATION
 |
 +---- 1:M ---- EMERGENCY_CONTACT
 |
 +---- 1:M ---- SAVED_INFORMATION
```

### 20.7 Normalization

The database design aims to follow the principles of First, Second, and Third Normal Forms (1NF, 2NF, and 3NF).

Separate tables help avoid unnecessary duplication and represent one-to-many relationships correctly.

Temporary camera frames and transient model outputs should not be permanently stored by default. Additional tables may be introduced if a future, documented feature requires persistent OCR history, detection history, or conversation history.

---

## 21. API Integration

Frontend and backend development should follow documented API contracts.

Every endpoint should specify:

- HTTP method
- Path
- Request format
- Required fields
- Success response
- Error response
- Authentication requirements
- Whether information is persisted

The following endpoints are proposed API contracts. Their availability must be confirmed against the actual backend implementation.

### 21.1 Speech-to-Text

**Endpoint:** `POST /api/speech-to-text`

The exact request format depends on the implemented audio-upload contract. For example, the endpoint may accept multipart form data containing an audio file.

Illustrative response:

```json
{
  "success": true,
  "text": "What is written here?"
}
```

Illustrative error response:

```json
{
  "success": false,
  "message": "Audio processing failed."
}
```

### 21.2 Registration

**Endpoint:** `POST /api/register`

Illustrative JSON request:

```json
{
  "name": "Example User",
  "email": "user@example.com",
  "password": "replace-with-a-real-password",
  "date_of_birth": "2005-05-10",
  "phone_number": "REPLACE_WITH_PHONE_NUMBER"
}
```

Illustrative response:

```json
{
  "success": true,
  "message": "Registration successful."
}
```

The backend must validate the request, hash the password, and enforce appropriate uniqueness constraints.

### 21.3 Login

**Endpoint:** `POST /api/login`

Illustrative request:

```json
{
  "email": "user@example.com",
  "password": "replace-with-a-real-password"
}
```

The backend should verify credentials and return the authentication/session information required by the chosen authentication design.

### 21.4 Preferences

**Example endpoint:** `PUT /api/preferences`

Illustrative request:

```json
{
  "preferred_language": "Hindi",
  "voice_language": "Hindi",
  "speech_rate": 0.8,
  "audio_guidance": true
}
```

The endpoint and field names must match the actual backend contract.

### 21.5 API development rule

Do not assume an endpoint exists simply because it is documented in this README. Verify the Flask route, request schema, response schema, and database behavior before integrating it into Flutter.

---

## 22. Technology Stack

| Layer | Technology / option | Purpose |
|---|---|---|
| Frontend | Flutter | Accessible user interface |
| Backend | Python, Flask | API and application logic |
| API configuration | Flask-CORS | Cross-origin access where required |
| Database | MySQL | Persistent user data |
| Speech-to-Text | Whisper / faster-whisper | Speech recognition |
| Text-to-Speech | Suitable TTS engine | Spoken responses |
| Image processing | OpenCV | Preprocessing and quality checks |
| OCR | EasyOCR / Tesseract | Text extraction |
| Object detection | YOLOv8 | Object identification |
| Currency recognition | Suitable vision model | Currency classification |
| Conversational AI | Local LLM / compatible runtime | General question answering |
| Translation | Google Language Translation or equivalent | Language translation |
| Navigation | Maps / Navigation API | Route information |
| Location | Device location services | Location information |
| Version control | Git and GitHub | Source management and collaboration |

The final model and library versions should be documented once selected and tested.

---

## 23. Project Structure

A modular structure is recommended so teammates can work on separate features.

Illustrative structure:

```text
ai-companion/
|
+-- frontend/
|   +-- lib/
|   |   +-- main.dart
|   |   +-- screens/
|   |   +-- widgets/
|   |   +-- services/
|   |   +-- models/
|   |   +-- utils/
|   +-- test/
|   +-- pubspec.yaml
|
+-- backend/
|   +-- app.py
|   +-- config/
|   +-- routes/
|   |   +-- speech_routes.py
|   |   +-- auth_routes.py
|   |   +-- preference_routes.py
|   |   +-- location_routes.py
|   |
|   +-- services/
|   |   +-- speech_service.py
|   |   +-- conversation_service.py
|   |   +-- translation_service.py
|   |
|   +-- whisper/
|   +-- ocr/
|   +-- yolo/
|   +-- currency/
|   +-- navigation/
|   +-- ai/
|   +-- database/
|   +-- authentication/
|   +-- tests/
|   +-- requirements.txt
|   +-- .env.example
|
+-- docs/
|   +-- architecture.md
|   +-- api-contracts.md
|   +-- database-design.md
|   +-- testing.md
|
+-- .gitignore
+-- README.md
```

This is a recommended logical organization, not a claim that every directory or file already exists in the repository.

The actual repository structure should be checked and updated as implementation progresses.

---

## 24. Online and Offline Operation

The project follows a hybrid online/offline approach.

### 24.1 Potential local features

Depending on model availability and device capability:

- OCR
- Image-quality assessment
- Currency recognition
- Basic object detection
- Basic scene understanding
- Local conversational AI
- Local speech recognition
- Local text-to-speech

### 24.2 Potential online features

- External translation APIs
- Online maps and navigation
- Real-time traffic services
- Cloud-based AI
- Remote synchronization
- Other external APIs

### 24.3 Connectivity workflow

```text
User request
     |
     v
Identify required feature
     |
     v
Can it run locally?
    /          \
  YES           NO
   |             |
   v             v
Local model   Check required
processing    online service
                 |
                 v
          Internet available?
              /       \
            YES        NO
             |          |
             v          v
       Call service   Explain limitation
             |
             v
           Result
```

Offline operation is only available for features whose required models, libraries, and data are installed locally.

No fixed bandwidth requirement should be presented as a measured fact unless it has been tested. Connectivity needs depend on the external service and the type of data being transferred.

---

## 25. Security and Privacy

The system may process personal, audio, camera, and location data. Appropriate protections are therefore essential.

### Security requirements

- Hash passwords with an appropriate password-hashing algorithm.
- Validate API inputs.
- Restrict database access.
- Use authentication and authorization.
- Protect authentication/session credentials.
- Configure CORS for intended origins rather than allowing arbitrary origins in production.
- Keep secrets out of source control.
- Use HTTPS in production.
- Restrict access to emergency contacts and location information.
- Avoid returning internal exception details to clients.

### Privacy requirements

- Request permissions before using sensitive device features.
- Collect only the information required for a feature.
- Avoid storing camera frames by default.
- Define retention rules for location and other sensitive data.
- Do not expose one user's records to another user.
- Provide clear feedback when a feature needs location, microphone, or camera access.

### Configuration

Use environment variables or an appropriate secret-management method for database credentials, API keys, and deployment-specific settings.

A `.env.example` file may document required variable names without containing real secrets.

---

## 26. Reliability and Error Handling

The system should handle failures without crashing unnecessarily or misleading the user.

| Failure | Expected behavior |
|---|---|
| Microphone permission denied | Explain that microphone access is required for voice input |
| Audio recording fails | Show or speak a useful error |
| STT processing fails | Ask the user to retry |
| Backend unavailable | Report that the service cannot be reached |
| Database unavailable | Return a controlled error and log diagnostic details securely |
| Camera unavailable | Explain that camera access is unavailable |
| OCR image unsuitable | Provide relevant audio guidance |
| Currency recognition uncertain | Ask for a clearer image or report uncertainty |
| Internet unavailable | Continue available local functions and explain online limitations |
| GPS unavailable | Explain that current location cannot be determined reliably |
| Translation service unavailable | Report the service failure and preserve available input |
| AI model unavailable | Provide a controlled failure response |

### Localhost integration note

If Flutter reports:

```text
ClientException: Failed to fetch
http://127.0.0.1:5000/api/speech-to-text
```

first verify that Flask is running and reachable from the machine where the frontend is executing.

A loopback address points to the local machine. It does not automatically connect a teammate's laptop to another laptop's backend.

---

## 27. Development Roadmap

The development sequence prioritizes integration and verification before adding every advanced module.

### Phase 1: Backend foundation

- Set up Flask.
- Configure the required CORS policy.
- Connect Flask to MySQL.
- Create the `ai_companion` database.
- Create and verify the five main tables.
- Add a database connectivity/test endpoint.
- Verify error handling and configuration.

### Phase 2: Speech-to-Text integration

- Integrate Whisper or the selected STT implementation.
- Implement `POST /api/speech-to-text`.
- Define the audio request format.
- Return recognized text in a predictable response.
- Test the endpoint independently.
- Connect Flutter to the actual backend.
- Verify the complete Flutter → Flask → STT → Flutter flow.

### Phase 3: Onboarding and conversation flow

- Implement the fixed onboarding state machine.
- Ask for the language.
- Confirm and set the language.
- Ask for the user's name.
- Confirm the name.
- Complete onboarding.
- Implement general request processing after onboarding.
- Connect TTS and text input.

### Phase 4: Authentication and user data

- Implement registration.
- Implement login.
- Hash passwords securely.
- Add session/authentication handling.
- Implement user-profile APIs.
- Implement preference APIs.
- Implement location and emergency-contact management.
- Add saved-information functionality when required.

### Phase 5: OCR and image quality

- Implement camera capture.
- Implement image-quality checks.
- Add audio camera guidance.
- Integrate OCR.
- Add preprocessing where useful.
- Test text extraction under different conditions.
- Connect results to TTS.

### Phase 6: Vision modules

- Integrate currency recognition.
- Integrate YOLO-based object detection.
- Implement relevant-object assistance.
- Add scene understanding if the selected model supports it.
- Evaluate uncertainty and incorrect predictions.

### Phase 7: Online services

- Integrate translation.
- Integrate maps/navigation.
- Implement location-permission handling.
- Add online-service failure handling.

### Phase 8: Conversational AI

- Select a compatible local LLM.
- Evaluate hardware requirements.
- Integrate the selected runtime.
- Test response quality and latency.
- Add controlled fallback behavior.

### Phase 9: Emergency functionality

- Finalize the emergency workflow.
- Implement the necessary APIs and permissions.
- Verify contact and location access controls.
- Test success, failure, and cancellation paths.

### Phase 10: Integration and evaluation

- Test the complete application.
- Resolve cross-device API configuration issues.
- Verify privacy and security behavior.
- Document measured performance.
- Update the README to match the verified implementation.

### Priority order

```text
Flask
  ↓
MySQL connection
  ↓
Database and tables
  ↓
CORS and API verification
  ↓
Whisper / Speech-to-Text
  ↓
Flutter ↔ Flask ↔ Whisper
  ↓
Onboarding
  ↓
Registration and Login
  ↓
Profile and Preferences
  ↓
Location and Emergency Contacts
  ↓
OCR and Image Quality Assessment
  ↓
YOLO / Object Detection
  ↓
Currency Recognition
  ↓
Scene Understanding
  ↓
Translation
  ↓
Navigation
  ↓
Local LLM
  ↓
Emergency workflow
  ↓
Full-system testing
```

This is the intended development sequence, not a statement that all these phases have already been completed.

---

## 28. Testing and Verification

Each feature should be tested independently before end-to-end integration.

### Frontend tests

- Widget and screen tests
- Input validation
- Audio recording
- Permission handling
- API request construction
- JSON response parsing
- TTS behavior
- Error and loading states

### Backend tests

- API request validation
- Speech endpoint behavior
- Authentication and password hashing
- Database connectivity
- CRUD operations
- Error responses
- CORS configuration
- Authorization checks

### OCR tests

- Clear and focused text
- Blurry images
- Low-light images
- Images containing no text
- Partially visible text
- Different text sizes
- Supported languages
- Repeated quality-check and recapture flow

### Vision tests

- Supported object classes
- Detection under different lighting
- False detections
- Uncertain predictions
- Relevant-object filtering
- Scene-description accuracy

### End-to-end tests

Example speech test:

```text
1. Start Flask.
2. Verify backend health.
3. Open the Flutter application.
4. Grant the required microphone permission.
5. Speak a test phrase.
6. Confirm that audio reaches Flask.
7. Confirm that STT returns recognized text.
8. Confirm that Flutter receives the response.
9. Confirm that the next application step works.
```

Example OCR test:

```text
1. Ask the assistant to read a document.
2. Capture an intentionally blurry image.
3. Verify that unsuitable quality is detected.
4. Verify that relevant audio guidance is given.
5. Adjust the camera.
6. Capture a clearer image.
7. Verify that OCR runs.
8. Verify that the extracted text is returned.
9. Verify that TTS reads the result.
```

### Reporting test status

Use explicit labels:

- **PASS:** verified by a reproducible test.
- **FAIL:** test executed and failed.
- **BLOCKED:** test cannot proceed because a dependency is unavailable.
- **NOT TESTED:** implementation or verification has not been confirmed.
- **PLANNED:** feature has not yet been implemented.

Do not mark a feature complete solely because its files exist.

---

## 29. Limitations

The current scope has several important limitations.

1. Speech recognition quality depends on the audio, language, model, and hardware.
2. Local AI models may require significant memory and storage.
3. OCR accuracy depends on image quality, text layout, language, and the selected engine.
4. Currency recognition may fail for unclear or unfamiliar images.
5. YOLO object detection alone cannot establish exact real-world distance.
6. Scene descriptions can contain errors and must not be treated as guaranteed facts.
7. Reliable collision avoidance requires additional sensing and safety logic.
8. Navigation depends on location accuracy and the selected mapping service.
9. GPS may be inaccurate or unavailable indoors.
10. Online translation and navigation can fail without connectivity.
11. Browser microphone and audio behavior is subject to permissions and platform restrictions.
12. Emergency-contact storage alone does not provide an operational emergency-alert service.
13. Battery consumption and model performance must be measured on the target device.

The system is intended to provide assistance, not to guarantee personal safety or replace established mobility aids.

---

## 30. Future Scope

### 30.1 Smart-glasses integration

A future version could connect the application to wearable hardware containing a camera, microphone, audio output, and suitable sensors.

### 30.2 Activation and low-power mode

Possible commands include:

- "Activate Glasses"
- "Deactivate Glasses"

When inactive, heavy camera and AI processing could stop while a suitable low-power activation mechanism remains available.

### 30.3 Proactive obstacle assistance

Future work could combine activity recognition, periodic camera sampling, object detection, depth estimation, risk assessment, and suitable audio warnings.

### 30.4 Improved spatial understanding

Potential additions include:

- Depth estimation
- Free-space detection
- Better obstacle-distance estimation
- Stereo/depth sensors
- More reliable path planning

### 30.5 Battery management

A future wearable could monitor battery status, provide low-battery warnings, and estimate remaining operation time after suitable hardware testing.

### 30.6 Expanded language support

Future improvements could include additional STT/TTS languages, more capable translation, and better offline language processing.

### 30.7 Better personalization

Future versions could provide improved user preferences, configurable audio guidance, and more flexible interaction settings.

All these capabilities should remain labelled as future scope until implemented and verified.

---

## 31. Expected Outcome

The expected outcome is a modular, accessible AI Companion that brings speech processing, computer vision, OCR, currency recognition, conversational AI, multilingual support, location, and navigation assistance together in one system.

The intended benefits include:

- Easier access to printed information
- Audio guidance during camera-based reading
- Access to information about detected objects
- Currency-identification assistance
- Spoken answers to general questions
- Multilingual interaction
- Location and route information
- A shared platform for visually impaired users and caregivers

The quality of the final outcome should be demonstrated through functional tests, integration tests, usability feedback, and measured performance rather than assumed from the proposed architecture.

---

## 32. Getting Started

The commands below are illustrative setup instructions. Run them from the appropriate project directory and adapt them to the actual repository structure.

### Prerequisites

- Git
- Python
- Flutter SDK
- MySQL
- A compatible Python environment
- Required model files and dependencies for the features being tested

### Clone the repository

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
cd <YOUR_PROJECT_DIRECTORY>
```

Replace the placeholders with the actual repository URL and directory name.

### Backend setup

Create and activate a virtual environment:

```bash
cd backend
python -m venv .venv
```

macOS/Linux:

```bash
source .venv/bin/activate
```

Windows PowerShell:

```powershell
.\.venv\Scripts\Activate.ps1
```

Install dependencies if `requirements.txt` is present and up to date:

```bash
pip install -r requirements.txt
```

Configure the database credentials and other required variables using the project's environment configuration.

Create the database and tables using the actual schema or migration scripts provided by the repository.

Start the backend using the project's configured Flask entry point. For example, if `app.py` exposes the Flask application:

```bash
python app.py
```

Confirm the actual backend address and port from the application output or configuration.

### Frontend setup

From the Flutter project directory:

```bash
flutter pub get
flutter analyze
flutter test
```

Run the application using the appropriate target device or browser configuration:

```bash
flutter run
```

The exact run command depends on the project's Flutter targets and configuration.

### Verify the integration

1. Start MySQL.
2. Start Flask.
3. Verify the backend is reachable.
4. Confirm the configured API base URL.
5. Run Flutter.
6. Test the speech-to-text endpoint.
7. Test onboarding and text input.
8. Verify error handling when the backend is unavailable.

Do not place real database passwords or API keys in the README or source control.

---

## 33. Team Development and GitHub Workflow

The project can be developed collaboratively by dividing responsibilities into logical modules.

Suggested responsibilities:

| Workstream | Responsibilities |
|---|---|
| Frontend | Flutter screens, accessibility, audio recording, TTS, API integration |
| Backend | Flask application, routes, validation, service integration |
| Database | MySQL schema, queries, relationships, migrations |
| Speech | Whisper integration and speech tests |
| Computer vision | OCR, OpenCV, image-quality assessment, YOLO, currency recognition |
| AI and online services | Local LLM, translation, navigation integration |
| Integration and QA | API contracts, end-to-end tests, documentation |

Responsibilities can overlap according to team size and availability.

### Collaboration guidelines

- Agree on API contracts before integrating modules.
- Use feature branches for independent changes.
- Keep generated model files and large datasets out of Git when appropriate.
- Never commit secrets, credentials, or private user data.
- Add tests when changing existing functionality.
- Review and merge changes through GitHub.
- Keep the README aligned with the actual implementation.
- Record known issues and reproduction steps.
- Verify features on the relevant device before marking them complete.

---

## 34. Viva Explanation

### What is your project?

Our project is an AI-based accessibility assistant designed primarily for blind and visually impaired users. It combines voice interaction, speech recognition, OCR, automatic image-quality assessment, currency recognition, object detection, scene understanding, conversational AI, multilingual support, and navigation-related services in one application.

The frontend is developed using Flutter, while Flask provides the backend API and MySQL stores persistent user information.

### What is the main technical highlight?

One of our main technical highlights is automatic image-quality assessment before OCR. The user does not need to visually inspect the camera preview. The system evaluates image properties such as blur, brightness, sharpness, and text visibility. If the image is unsuitable, it provides audio guidance so the user can adjust the camera and capture another image. When the image is suitable, OCR extracts the text and TTS reads it aloud.

### Why use YOLO?

YOLO can identify and locate supported object classes in an image. We use object detection as one component of environmental assistance. We do not treat YOLO alone as a reliable distance-measurement or complete path-planning system.

### Why use Flask?

Flask provides an API layer that connects the Flutter frontend with speech processing, AI and computer-vision modules, external services, and MySQL.

### Why use MySQL?

MySQL stores persistent information such as user accounts, preferences, location records, emergency contacts, and saved information. Temporary image-processing results do not need to be permanently stored by default.

### Does the system work offline?

The system follows a hybrid online/offline approach. Features whose models and dependencies are installed locally may work offline. External services such as online maps or a cloud translation API require connectivity.

### What is the future scope?

Future work includes smart-glasses integration, low-power activation, battery monitoring, better depth estimation, improved obstacle assistance, additional language support, and more advanced navigation capabilities.

---

## Project Summary

**AI Companion for Visually Impaired People: Intelligent Navigation and Assistance System**

The project aims to provide an accessible, voice-first platform that combines speech processing, automatic OCR image-quality assessment, text reading, currency recognition, object detection, scene understanding, conversational AI, translation, location, and navigation-related assistance.

Its architecture uses Flutter for the frontend, Flask for the backend, and MySQL for persistent data. The system is designed to use local processing wherever practical while supporting online services when required.

The project prioritizes accessibility, modular development, privacy, realistic safety boundaries, and verification through testing.

**Core principle: Assist, Don't Overwhelm.**
