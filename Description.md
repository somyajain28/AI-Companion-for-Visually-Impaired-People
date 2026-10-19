====================================================================
          AI-BASED ACCESSIBILITY ASSISTANT FOR VISUALLY
                         IMPAIRED USERS
====================================================================


1. PROJECT OVERVIEW
====================================================================

The proposed project is an AI-based accessibility assistant
designed primarily for blind and visually impaired users.

The main purpose of the system is to help users understand,
interact with, and navigate their surroundings using voice,
computer vision, artificial intelligence, speech processing,
OCR, translation, and navigation technologies.

Instead of requiring the user to operate a conventional
graphical interface or visually inspect information on the
screen, the system allows the user to interact primarily
through voice and camera input.

The system can perform tasks such as:

    • Voice-based interaction
    • Speech-to-Text
    • Text-to-Speech
    • OCR / Text Reading
    • Automatic Image Quality Checking
    • Currency Note Recognition
    • Object Detection
    • Scene Understanding
    • AI Conversational Assistance
    • Multilingual Speech Support
    • Language Translation
    • Navigation Assistance
    • User and Session Management
    • Location / Last Known Location Management

The system follows a hybrid online/offline approach. Core
assistance features can operate locally when the required
models and components are installed, while services that
depend on external APIs or real-time information can use
the Internet.


====================================================================
2. MAIN OBJECTIVE
====================================================================

The main objective of the project is to provide a single
intelligent accessibility assistant that combines multiple
AI capabilities into one application.

The system aims to reduce the need for visually impaired
users to depend on multiple separate applications for
different tasks.

The system follows the principle:

                "ASSIST, DON'T OVERWHELM."

This means that the assistant should provide useful and
relevant information according to the user's request or
current situation instead of continuously announcing every
object detected by the camera.

For example, if the camera detects:

    • Chair
    • Table
    • Bottle
    • Window
    • Wall
    • Fan
    • Door
    • Person

the system should not automatically announce all of them.

Instead, it should determine which information is useful
for the user's current request or situation.

For example:

    User is walking
          |
          v
    Object detected ahead
          |
          v
    Object may affect user's movement
          |
          v
    System provides an audio warning


====================================================================
3. TARGET USERS
====================================================================

The primary users of the system are:

    • Blind users
    • Visually impaired users
    • Users with severe visual limitations

Possible secondary users include:

    • Elderly users with reading difficulties
    • Users with temporary visual limitations
    • Users who prefer voice-based accessibility assistance


====================================================================
4. MAIN FEATURES
====================================================================

The system contains the following major features:

    1. Voice-Based Interaction
    2. Multilingual Speech Support
    3. Currency Note Recognition
    4. OCR / Text Reading
    5. Automatic Image Quality Assessment
    6. Object Detection
    7. Scene Understanding
    8. Navigation Assistance
    9. AI Conversational Assistance
   10. Text-to-Speech Response
   11. User / Session Management
   12. Google Language Translation
   13. Location / Last Known Location Management


====================================================================
5. OVERALL SYSTEM FLOW
====================================================================

                         +-------------+
                         |    USER     |
                         +------+------+
                                |
                                |
                     Voice / Camera Input
                                |
                                v
                    +----------------------+
                    |   Input Processing   |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    | Request Understanding|
                    +----------+-----------+
                               |
          +--------------------+--------------------+
          |                    |                    |
          v                    v                    v
       VOICE                 VISION                AI
       MODULE                MODULE              MODULE
          |                    |                    |
          v              +-----+-----+              v
         STT             |     |     |          Local AI
                         v     v     v
                        OCR   YOLO Currency
                              Detection
                         |
                         v
                    Scene Understanding

          |                    |                    |
          +--------------------+--------------------+
                               |
                               v
                    +----------------------+
                    | Result / Context     |
                    | Processing            |
                    +----------+-----------+
                               |
               +---------------+---------------+
               |                               |
               v                               v
        Local Processing                 Online Services
               |                               |
        • OCR                              • Translation
        • YOLOv8                           • Maps
        • Currency                         • Navigation
        • Local AI                         • Real-time APIs
        • STT/TTS                          • Cloud Services
               |                               |
               +---------------+---------------+
                               |
                               v
                    +----------------------+
                    |   Final Response     |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    |   Text-to-Speech      |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    |    Voice Response     |
                    +----------+-----------+
                               |
                               v
                             USER
====================================================================
6. USER INPUT
====================================================================

The user can interact with the system mainly through voice.

The user can also provide camera input when visual
information needs to be analyzed.

Examples of voice commands include:

    "Read this document."
    "What is written here?"
    "What currency is this?"
    "What is in front of me?"
    "Describe my surroundings."
    "How do I reach the railway station?"
    "Translate this."
    "Explain this word."
    "What is this object?"

The application captures the user's voice and/or camera
input depending on the requested functionality.


====================================================================
7. SPEECH-TO-TEXT
====================================================================

Speech-to-Text (STT) converts the user's spoken command
into text.

Example:

    User speaks:

        "What is written on this paper?"

                    |
                    v

             Speech-to-Text

                    |
                    v

        "What is written on this paper?"

The converted text is then sent to the request-processing
component.

Possible technology:

    • Whisper / suitable Speech-to-Text model


====================================================================
8. REQUEST / INTENT UNDERSTANDING
====================================================================

After converting the voice input into text, the system
determines what the user wants.

Examples:

    USER REQUEST                         MODULE
    ----------------------------------------------------------
    "Read this."                         OCR

    "What is written here?"              OCR

    "What currency is this?"             Currency Recognition

    "What is in front of me?"            Object Detection

    "Describe my surroundings."          Scene Understanding

    "How do I reach the station?"        Navigation

    "Translate this."                    Translation

    "Explain machine learning."          AI Assistant

    "Where am I?"                        Location

The system should activate the required functionality
instead of processing every request through every module.


====================================================================
9. VISION MODULE
====================================================================

The vision module processes images obtained from the camera.

The vision module can contain several components:

                       CAMERA
                          |
                          v
                   Image Processing
                          |
             +------------+------------+
             |            |            |
             v            v            v
            OCR         YOLO        Currency
                        Detection   Recognition
             |            |            |
             v            v            v
           Text        Objects      Currency
                          |
                          v
                  Scene Understanding


The vision module is responsible for processing visual
information required by the user.


====================================================================
10. OCR / TEXT READING
====================================================================

OCR stands for Optical Character Recognition.

The OCR module allows the visually impaired user to read
printed or displayed text using the device camera.

The user may point the camera toward:

    • Documents
    • Books
    • Signs
    • Menus
    • Labels
    • Notices
    • Printed text
    • Product packaging

An important accessibility requirement is that the system
should NOT depend on the user visually checking the camera
preview.

A visually impaired user may not be able to determine whether
the camera is properly focused, whether the image is blurry,
whether there is sufficient lighting, or whether the text is
visible.

Therefore, the system automatically evaluates the captured
image before performing OCR.


====================================================================
10.1 AUTOMATIC IMAGE QUALITY ASSESSMENT
====================================================================

When the user points the camera toward text, the system
captures an image and automatically evaluates whether the
image is suitable for OCR.

The system can evaluate factors such as:

    • Blur
    • Brightness
    • Focus / sharpness
    • Text presence
    • Overall image quality
    • Text visibility

Basic flow:

                       Camera
                          |
                          v
                    Capture Image
                          |
                          v
              +-----------------------+
              | Image Quality Check   |
              +-----------+-----------+
                          |
            +-------------+-------------+
            |             |             |
            v             v             v
          Blur        Brightness      Text
          Check          Check       Presence
            |             |             |
            +-------------+-------------+
                          |
                          v
                  Is Image Suitable?
                          |
                    +-----+-----+
                    |           |
                   NO          YES
                    |           |
                    v           v
            Audio Guidance     OCR
                    |           |
                    |           v
                    |       Extract Text
                    |           |
                    |           v
                    |     Text-to-Speech
                    |           |
                    v           v
              User adjusts   User hears
              camera         the text


====================================================================
10.2 AUDIO GUIDANCE FOR CAMERA POSITION
====================================================================

If the captured image is not suitable for OCR, the system
should provide audio instructions to help the user correct
the camera position.

Examples:

    If the image is too blurry:

        "Hold the camera steady."

    If the text is too far away:

        "Move closer."

    If the text is too small:

        "Move closer to the text."

    If the image is too dark:

        "Increase the lighting."

    If text is not detected:

        "Point the camera toward the text."

    If only part of the text is visible:

        "Move the camera slightly."

The user can then adjust the camera and capture another
image.

This process can continue until the image is suitable for
OCR.


====================================================================
10.3 OCR PROCESSING AFTER IMAGE VALIDATION
====================================================================

Once the image is determined to be suitable, it is sent
to the OCR module.

Flow:

    Camera
       |
       v
    Capture Image
       |
       v
    Automatic Image Quality Assessment
       |
       v
    Image Suitable
       |
       v
    OpenCV Preprocessing
       |
       v
    OCR
       |
       v
    Extracted Text
       |
       v
    Text Processing
       |
       v
    Text-to-Speech
       |
       v
    User hears the text


Example:

    User points camera at a document
                 |
                 v
           Image captured
                 |
                 v
        Image is too blurry
                 |
                 v
    System says:

        "Hold the camera steady."
                 |
                 v
        User adjusts camera
                 |
                 v
           Image captured
                 |
                 v
        Image is suitable
                 |
                 v
               OCR
                 |
                 v
       "Platform Number 3"
                 |
                 v
          Text-to-Speech
                 |
                 v
    User hears:

        "Platform Number 3"


====================================================================
10.4 COMPLETE OCR FLOW
====================================================================

                    USER
                      |
                      v
              Camera Activated
                      |
                      v
               Capture Image
                      |
                      v
          Automatic Quality Check
                      |
       +--------------+--------------+
       |              |              |
       v              v              v
     Blur         Brightness       Text
     Check           Check        Presence
       |              |              |
       +--------------+--------------+
                      |
                      v
              Is Image Suitable?
                      |
                +-----+-----+
                |           |
               NO          YES
                |           |
                v           v
        Audio Guidance     OCR
                |           |
                v           v
        User adjusts      Extract Text
        camera position       |
                |              v
                |        Text-to-Speech
                |              |
                +------------->|
                               v
                         User hears text


====================================================================
10.5 ACCESSIBILITY BENEFIT OF AUTOMATIC IMAGE CHECKING
====================================================================

The user should not need to visually inspect:

    • Camera preview
    • Focus
    • Blur
    • Brightness
    • Text position
    • Text visibility

Instead, the system communicates the required correction
through audio.

This changes the OCR experience from:

    User
      |
      v
    Camera
      |
      v
    Visually check preview
      |
      v
    Adjust camera
      |
      v
    OCR

to:

    User
      |
      v
    Camera
      |
      v
    Automatic Image Quality Check
      |
      +-----------------------------+
      |                             |
      v                             v
    Not Suitable                  Suitable
      |                             |
      v                             v
    Audio Guidance                  OCR
      |                             |
      v                             v
    User adjusts               Text extracted
    camera position                 |
      |                             v
      +----------------------> Text-to-Speech
                                    |
                                    v
                                  USER

====================================================================
10.6 POSSIBLE OCR TECHNOLOGIES
====================================================================

The OCR component can use:

    • EasyOCR
    • Tesseract OCR
    • OpenCV for image preprocessing

OpenCV can be used before OCR for image-processing
operations that improve the input image where appropriate.


====================================================================
11. CURRENCY RECOGNITION
====================================================================

Currency recognition identifies the denomination of a
currency note using the camera.

Example:

    User:

        "What note is this?"

                |
                v

          Camera Input
                |
                v

       Currency Recognition
                |
                v

              ₹500
                |
                v

         Text-to-Speech
                |
                v

       "Five hundred rupees"


Currency recognition can operate locally if the required
currency-recognition model is installed on the device.


====================================================================
12. OBJECT DETECTION
====================================================================

Object detection identifies objects present in the camera
view.

YOLOv8 is planned for object detection.

Example:

    Camera
       |
       v
     YOLOv8
       |
       v
    Detected Objects:

       • Person
       • Chair
       • Table
       • Door
       • Bottle

Object detection is one part of the larger accessibility
system.

The system should not automatically announce every object
that is detected.


====================================================================
13. RELEVANT OBJECT / OBSTACLE ASSISTANCE
====================================================================

The system should attempt to provide information about
objects that are relevant to the user's current request
or movement.

Basic concept:

    Camera Frame
         |
         v
    Object Detection
         |
         v
    Object Detected
         |
         v
    Is the object relevant?
         |
       +---+---+
       |       |
      YES      NO
       |       |
       v       v
    Inform    Ignore


Example:

    User is walking
          |
          v
    Chair detected on side
          |
          v
    Not relevant to immediate path
          |
          v
       No alert


Another example:

    User is walking
          |
          v
    Object detected directly ahead
          |
          v
    Potential obstacle
          |
          v
    System provides warning


IMPORTANT:

YOLOv8 alone does not know the complete path of the user.

The final system may use factors such as:

    • Object position in the image
    • Camera geometry
    • Distance estimation
    • Depth estimation
    • Motion information
    • Smartphone sensors
    • Future depth hardware

For the current B.Tech implementation, this should be
described as basic relevant-object / obstacle assistance,
not complete autonomous navigation.


====================================================================
14. SCENE UNDERSTANDING
====================================================================

Scene understanding provides a higher-level interpretation
of the user's surroundings.

Object detection answers:

    "What objects are present?"

Scene understanding attempts to answer:

    "What type of environment is this?"
    "What is happening in the scene?"

Example:

    Camera
       |
       v
    Scene Understanding
       |
       v
    "Indoor office environment"


Another example:

    Camera
       |
       v
    Scene Understanding
       |
       v
    "Road with vehicles and pedestrians"


Scene understanding allows the assistant to provide a
meaningful description rather than simply listing objects.


====================================================================
15. AI CONVERSATIONAL ASSISTANCE
====================================================================

The system provides AI-based conversational assistance.

The user can ask general questions such as:

    "What is machine learning?"
    "Explain this word."
    "What is photosynthesis?"
    "Tell me about this topic."

Flow:

    User Voice
        |
        v
    Speech-to-Text
        |
        v
    User Query
        |
        v
    AI Model
        |
        v
    Generated Response
        |
        v
    Text-to-Speech
        |
        v
    User hears response


A locally deployed AI model can be used through a compatible
local AI runtime such as Ollama.

This allows conversational assistance to potentially work
without Internet connectivity when the required model is
installed locally.


====================================================================
16. TEXT-TO-SPEECH
====================================================================

Text-to-Speech converts the system's textual result into
spoken audio.

Example:

    OCR Result:

        "Gate 2"

             |
             v

       Text-to-Speech

             |
             v

       Audio Response

             |
             v

        "Gate 2"


Text-to-Speech is a critical component because the primary
users may not be able to depend on visual output.

Audio feedback is also used for:

    • OCR guidance
    • Object information
    • Currency results
    • AI responses
    • Navigation instructions
    • Translation results
    • System notifications


====================================================================
17. MULTILINGUAL SPEECH SUPPORT
====================================================================

The system supports interaction in multiple languages.

General flow:

    User speaks in selected language
              |
              v
        Speech-to-Text
              |
              v
        Text Processing
              |
              v
       AI / Vision Module
              |
              v
        Result Generated
              |
              v
       Translation if required
              |
              v
        Text-to-Speech
              |
              v
    User hears response in
       selected language


====================================================================
18. LANGUAGE TRANSLATION
====================================================================

The project includes Google Language Translation for
translation-related functionality.

Example:

    Input text
        |
        v
    Translation Service
        |
        v
    Target Language
        |
        v
    Text-to-Speech
        |
        v
    User hears translated response


Internet connectivity may be required when using the
online translation service.


====================================================================
19. NAVIGATION ASSISTANCE
====================================================================

Navigation assistance helps the user obtain directions to
a requested destination.

Example:

    User:

        "How do I reach the railway station?"

                     |
                     v

              Speech-to-Text
                     |
                     v

            Navigation Intent
                     |
                     v

          Destination Identification
                     |
                     v

              Maps / API
                     |
                     v

             Route Calculation
                     |
                     v

          Navigation Instructions
                     |
                     v

              Text-to-Speech
                     |
                     v

              User hears:

        "Turn left after 100 metres."


Navigation may depend on:

    • Online maps
    • Route APIs
    • Location services
    • Real-time traffic
    • Crowd information
    • External APIs

====================================================================
20. LOCATION AND LAST KNOWN LOCATION
====================================================================

Location information is important for navigation and can
also provide useful last-known-location information in
safety-related situations.

The system should not claim that location history guarantees
that a user can be found.

GPS/location information can be:

    • Inaccurate
    • Unavailable
    • Outdated
    • Disabled
    • Affected by environmental conditions

Therefore, the system should refer to this information as
"Last Known Location" or "Location History".

Possible stored information may include:

    • Latitude
    • Longitude
    • Date and time
    • Location accuracy
    • Destination / route information where required


Basic flow:

    User Location
         |
         v
    GPS / Location Service
         |
         v
    Current Location
         |
         v
    Store Last Known Location
         |
         v
    Location History
         |
         v
    Secure Database


Location information should only be collected and stored
with the appropriate user permission.

Because location is sensitive information, access to stored
location information should be restricted to authorized
functionality and users.


====================================================================
21. USER REGISTRATION AND LOGIN
====================================================================

The system contains user and session management.

Basic flow:

                    APPLICATION
                         |
                +--------+--------+
                |                 |
           Registered?        Not Registered
                |                 |
               YES                NO
                |                 |
                v                 v
              Login        Public Homepage
                |
                v
          Authentication
                |
                v
           User Session
                |
                v
      Personalized Application


Users are required to register and log in to access
protected and personalized features.

Users without an account may access the public information
and options available on the homepage.


====================================================================
22. DATABASE
====================================================================

The database stores persistent user and application-related
information.

Possible database information includes:


    USERS
    ------------------------------------------------------------
    • User ID
    • Name
    • Email / Username
    • Password Hash
    • Account Information


    PREFERENCES
    ------------------------------------------------------------
    • Preferred Language
    • Voice Preferences
    • Accessibility Preferences
    • Application Preferences


    SESSIONS
    ------------------------------------------------------------
    • Session Information
    • Login State
    • Relevant Application State


    LOCATION
    ------------------------------------------------------------
    • Last Known Location
    • Location History where required
    • Latitude
    • Longitude
    • Timestamp
    • Accuracy


    SAVED INFORMATION
    ------------------------------------------------------------
    • User-specific saved information
    • Required application data


The system does not need to continuously store every camera
frame.

Images should only be stored when a particular feature
actually requires storage.


====================================================================
23. HYBRID ONLINE / OFFLINE ARCHITECTURE
====================================================================

The system follows a HYBRID ONLINE/OFFLINE approach.

                         SYSTEM
                            |
                +-----------+-----------+
                |                       |
             OFFLINE                  ONLINE
                |                       |
                v                       v
        Local Processing         External Services
                |                       |
        • OCR                    • Google Translation
        • YOLOv8                 • Maps
        • Currency               • Navigation
        • Local AI               • Real-time APIs
        • Local STT              • Cloud Services
        • Local TTS              • Online AI if used


The complete application should NOT depend continuously on
the Internet.


====================================================================
24. OFFLINE FUNCTIONALITY
====================================================================

Depending on the final implementation and installed models,
the following features can operate locally:

    • Currency Recognition
    • OCR / Text Reading
    • Automatic Image Quality Assessment
    • Basic Object Detection
    • Basic Scene Understanding
    • Local AI Conversation
    • Local Speech Processing
    • Text-to-Speech

Therefore:

             NO INTERNET
                  |
                  v
          Core local features
                  |
                  v
               Continue


====================================================================
25. ONLINE FUNCTIONALITY
====================================================================

Internet connectivity may be required for:

    • Google Language Translation
    • Online Maps
    • Navigation
    • Real-time Traffic
    • Real-time Crowd Information
    • External APIs
    • Cloud-based AI services
    • Online synchronization where applicable

Therefore:

             NO INTERNET
                  |
                  v
          Check requested feature
                  |
             +----+----+
             |         |
           LOCAL      ONLINE
             |         |
             v         v
          Continue   Inform user
                    Internet is
                     required


====================================================================
26. INTERNET REQUIREMENT
====================================================================

The system does not require continuous Internet connectivity
for locally supported functions.

A stable Internet connection is required when accessing
online services such as:

    • Language translation
    • Online navigation
    • Real-time information
    • External APIs
    • Cloud-based processing

The required bandwidth depends on the specific service
being used.

If a numerical value is required for the SRS, approximately
2–5 Mbps can be considered a basic requirement for normal
online operations. However, this should be treated as an
approximate project specification unless the system has been
tested with a measured minimum bandwidth.

Large amounts of data may be required occasionally when:

    • Downloading AI models
    • Updating models
    • Installing dependencies
    • Updating application resources

Normal local AI/vision processing does not require continuous
Internet data transfer.


====================================================================
27. COMPLETE ONLINE/OFFLINE DECISION FLOW
====================================================================

                     USER REQUEST
                          |
                          v
                 Request Processing
                          |
                          v
                 Identify Feature
                          |
             +------------+------------+
             |                         |
        Local Feature              Online Feature
             |                         |
             v                         v
      Check Local Model          Check Internet
             |                         |
             v                    +----+----+
       Process Locally            |         |
                                 YES        NO
                                  |         |
                                  v         v
                            Online API   Inform User
                                  |       Internet
                                  |       Required
                                  |
                                  +----+
                                       |
                                       v
                                 Result Generated
                                       |
                                       v
                                Text-to-Speech
                                       |
                                       v
                                  User hears
                                  response


====================================================================
28. EXAMPLE 1 — DOCUMENT READING
====================================================================

User says:

    "Read this document."

Flow:

    Voice Input
         |
         v
    Speech-to-Text
         |
         v
    OCR Intent
         |
         v
    Camera
         |
         v
    Image Capture
         |
         v
    Image Quality Check
         |
       +---+---+
       |       |
      BAD     GOOD
       |       |
       v       v
    Audio     OCR
    Guidance   |
       |       v
       |    Extract Text
       |       |
       |       v
       |   Text-to-Speech
       |       |
       +-------+
               |
               v
         User hears text


Example:

    Image too dark
         |
         v
    System says:

        "Increase the lighting."

         |
         v
    User adjusts camera / lighting

         |
         v
    Image suitable

         |
         v
    OCR

         |
         v
    "Platform Number 3"

         |
         v
    TTS

         |
         v
    User hears:

        "Platform Number 3"


Internet:
    Not necessarily required.


====================================================================
29. EXAMPLE 2 — CURRENCY RECOGNITION
====================================================================

User says:

    "What note is this?"

Flow:

    Voice
      |
      v
    Speech-to-Text
      |
      v
    Currency Intent
      |
      v
    Camera
      |
      v
    Currency Recognition
      |
      v
    ₹500
      |
      v
    Text-to-Speech
      |
      v
    "Five hundred rupees"


Internet:
    Not necessarily required.


====================================================================
30. EXAMPLE 3 — OBJECT ASSISTANCE
====================================================================

User says:

    "What is in front of me?"

Flow:

    Voice
      |
      v
    Speech-to-Text
      |
      v
    Object / Scene Intent
      |
      v
    Camera
      |
      v
    YOLOv8
      |
      v
    Detected Objects
      |
      v
    Relevance / Context Processing
      |
      v
    Useful Information
      |
      v
    Text-to-Speech
      |
      v
    User hears response


====================================================================
31. EXAMPLE 4 — AI CONVERSATION
====================================================================

User says:

    "What is Artificial Intelligence?"

Flow:

    Voice
      |
      v
    Speech-to-Text
      |
      v
    AI Query
      |
      v
    Local AI Model
      |
      v
    Generated Answer
      |
      v
    Text-to-Speech
      |
      v
    User hears answer


Internet:
    Not necessarily required when using a local AI model.


====================================================================
32. EXAMPLE 5 — NAVIGATION
====================================================================

User says:

    "How do I reach the railway station?"

Flow:

    Voice
      |
      v
    Speech-to-Text
      |
      v
    Navigation Intent
      |
      v
    Destination Identification
      |
      v
    Maps / Navigation API
      |
      v
    Route
      |
      v
    Navigation Instructions
      |
      v
    Text-to-Speech
      |
      v
    User hears instructions


Internet:
    Required when using online maps/navigation services.


====================================================================
33. EXAMPLE 6 — MULTILINGUAL INTERACTION
====================================================================

User speaks in Hindi:

    "Yeh kya likha hai?"

              |
              v

       Speech-to-Text
              |
              v

       Request Processing
              |
              v

             OCR
              |
              v

        Extracted Text
              |
              v

       Translation if needed
              |
              v

       Hindi Text Response
              |
              v

       Text-to-Speech
              |
              v

       Hindi Audio Response


====================================================================
34. EXAMPLE 7 — AUTOMATIC OCR CAMERA GUIDANCE
====================================================================

The user wants to read a sign.

The user does not need to visually check the camera preview.

Flow:

    User points camera at sign
                |
                v
          Image captured
                |
                v
       Automatic quality check
                |
       +--------+--------+
       |        |        |
       v        v        v
      Blur   Brightness  Text
       |        |        |
       +--------+--------+
                |
                v
        Image not suitable
                |
                v
       Audio instruction:
       "Move closer."
                |
                v
        User adjusts camera
                |
                v
          Image captured
                |
                v
       Automatic quality check
                |
                v
        Image is suitable
                |
                v
               OCR
                |
                v
       Text extracted
                |
                v
         Text-to-Speech
                |
                v
       User hears the text


====================================================================
35. TECHNOLOGY STACK
====================================================================

BACKEND:
    • Python
    • Flask

FRONTEND:
    • Flutter
    • HTML as applicable to the final architecture

COMPUTER VISION:
    • OpenCV

OBJECT DETECTION:
    • YOLOv8

OCR:
    • EasyOCR
    • Tesseract OCR

IMAGE QUALITY ASSESSMENT:
    • OpenCV-based image analysis
    • Blur detection
    • Brightness analysis
    • Sharpness/focus analysis
    • Text presence detection

SPEECH-TO-TEXT:
    • Whisper / suitable STT model

TEXT-TO-SPEECH:
    • Suitable local TTS engine

AI CONVERSATION:
    • Local LLM
    • Ollama / compatible local AI runtime

TRANSLATION:
    • Google Language Translate

NAVIGATION:
    • Maps / Navigation APIs

LOCATION:
    • Device GPS / Location Services

DATABASE:
    • DBMS

VERSION CONTROL:
    • Git
    • GitHub


====================================================================
36. SYSTEM ARCHITECTURE
====================================================================

+-------------------------------------------------------------+
|                         USER LAYER                          |
|                                                             |
|    Voice Input     Camera Input     Accessible Interface    |
+-----------------------------+-------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|                     APPLICATION LAYER                      |
|                                                             |
|    Flask Backend                                             |
|    Request Handling                                          |
|    Authentication                                            |
|    Session Management                                        |
|    API Routing                                               |
+-----------------------------+-------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|                       AI SERVICE LAYER                      |
|                                                             |
| OCR | Image Quality | YOLOv8 | Currency | Scene | AI       |
| STT | TTS | Translation | Navigation | Location            |
+-----------------------------+-------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|                          DATA LAYER                         |
|                                                             |
| Users | Preferences | Sessions | Location | Saved Data     |
+-------------------------------------------------------------+


====================================================================
37. MODULE-LEVEL ARCHITECTURE
====================================================================

                         USER
                           |
                           v
                  +----------------+
                  | Voice / Camera |
                  +-------+--------+
                          |
                          v
                  +----------------+
                  | Input Handler  |
                  +-------+--------+
                          |
                          v
                  +----------------+
                  | Intent /       |
                  | Request        |
                  | Processing     |
                  +-------+--------+
                          |
       +------------------+------------------+
       |                  |                  |
       v                  v                  v
  Voice Module       Vision Module       AI Module
       |                  |                  |
       |          +-------+-------+          |
       |          |       |       |          |
       v          v       v       v          v
      STT        OCR     YOLO   Currency   Local AI
                  |
                  v
          Image Quality Check
                  |
                  v
          Audio Guidance if needed

       |                  |                  |
       +------------------+------------------+
                          |
                          v
                  +----------------+
                  | Result Handler |
                  +-------+--------+
                          |
             +------------+------------+
             |                         |
             v                         v
        Online Services          Local Services
             |                         |
        Translation                OCR
        Navigation                 YOLO
        Maps                       Currency
        APIs                       Local AI
             |                     TTS
             +------------+------------+
                          |
                          v
                  +----------------+
                  | Text-to-Speech |
                  +-------+--------+
                          |
                          v
                     Voice Output
                          |
                          v
                         USER


====================================================================
38. DATABASE / USER DATA FLOW
====================================================================

                         USER
                           |
                           v
                       Register
                           |
                           v
                     Authentication
                           |
                           v
                         Login
                           |
                           v
                     User Session
                           |
          +----------------+----------------+
          |                |                |
          v                v                v
     Preferences      Location Data     Saved Data
          |                |                |
          v                v                v
     Database         Database         Database


Important location information:

    Current Location
          |
          v
    Last Known Location
          |
          v
    Location History where required


The location information should be protected because it
is sensitive user information.

====================================================================
39. RELIABILITY
====================================================================

The system should maintain appropriate backup and recovery
mechanisms for important user data.

Important data can include:

    • User account information
    • User preferences
    • Session information
    • Last known location
    • Location history where applicable
    • Other important saved information

A backup mechanism should be maintained so that in case of
system failure or crash, important data is not unnecessarily
lost.

The system should also handle failures of individual
services gracefully.

For example:

    Online service unavailable
             |
             v
       Check whether the
       requested feature
       can operate locally
             |
        +----+----+
        |         |
       YES        NO
        |         |
        v         v
    Continue    Inform user
    locally     that service
                is unavailable


====================================================================
40. SECURITY AND PRIVACY
====================================================================

The system handles sensitive information such as:

    • User account information
    • Location information
    • Location history
    • User preferences
    • Session information

Therefore, the system should provide:

    • Secure authentication
    • Password protection / hashing
    • Session management
    • Access control
    • Protected database access
    • Restricted access to location information
    • Appropriate user permission for location services

Location information should not be collected or stored
without the appropriate user permission.


====================================================================
41. FUTURE HARDWARE INTEGRATION
====================================================================

The current project can be implemented primarily as a
software/application-based system.

In the future, the system can potentially be integrated
with dedicated hardware.

Possible future architecture:

    Camera
       |
       v
    Embedded Device
       |
       v
    AI Processing
       |
       v
    Voice Output


A Raspberry Pi or another suitable embedded device may be
considered in a future version.

The current software architecture should remain modular so
that hardware can be added later without requiring a
complete rewrite of the AI modules.


====================================================================
42. WHAT THE SYSTEM DOES NOT CLAIM
====================================================================

The system should NOT be described as a fully autonomous
navigation system.

It should NOT claim that YOLOv8 alone can determine the
user's complete walking path.

It should NOT claim that object detection automatically
understands everything in the environment.

It should NOT claim that stored location history guarantees
that a user can be found during an emergency.

Instead, the system provides:

    • Object Detection
    • Basic Scene Understanding
    • Relevant Object / Obstacle Assistance
    • Navigation Assistance
    • Context-Aware Responses
    • Last Known Location / Location History where permitted
    • Voice-Based Accessibility Assistance


====================================================================
43. COMPLETE END-TO-END SYSTEM FLOW
====================================================================

                         +-------------+
                         |    USER     |
                         +------+------+
                                |
                     Voice / Camera Input
                                |
                                v
                    +----------------------+
                    |   Input Processing   |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    | Request / Intent      |
                    | Understanding         |
                    +----------+-----------+
                               |
          +--------------------+--------------------+
          |                    |                    |
          v                    v                    v
       VOICE                 VISION                AI
          |                    |                    |
          v              +-----+-----+              v
         STT             |     |     |          Local AI
                         v     v     v
                        OCR   YOLO Currency
                              Detection
                         |
                         v
                  Image Quality Check
                         |
                    +----+----+
                    |         |
                   BAD       GOOD
                    |         |
                    v         v
             Audio Guidance  OCR
                    |         |
                    |         v
                    |    Extract Text
                    |         |
                    |         v
                    |   Text-to-Speech
                    |         |
                    +---------+
                              |
                              v
                    Scene Understanding
                              |
                              v
                    Context Processing
                              |
          +-------------------+-------------------+
          |                                       |
          v                                       v
   Local Processing                         Online Services
          |                                       |
   • OCR                                      • Translation
   • YOLOv8                                   • Maps
   • Currency                                 • Navigation
   • Local AI                                 • Real-time APIs
   • STT/TTS                                  • External APIs
          |                                       |
          +-------------------+-------------------+
                              |
                              v
                    +----------------------+
                    |   Result Processing   |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    |   Text-to-Speech      |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    |    Voice Response     |
                    +----------+-----------+
                               |
                               v
                             USER


====================================================================
44. COMPLETE USER EXPERIENCE
====================================================================

The complete user experience is:

    1. User opens the application.

    2. User registers or logs in.

    3. User selects/configures required preferences such as
       language and accessibility settings.

    4. User gives a voice command or activates a camera-based
       feature.

    5. Speech input is converted to text when required.

    6. The system determines the user's intent.

    7. The appropriate module is activated.

    8. If the feature requires camera input, the camera
       captures the required image.

    9. For OCR, the system automatically evaluates image
       quality without requiring the user to visually check
       the camera preview.

   10. If the image is unsuitable, the system provides
       audio instructions such as:

           "Move closer."
           "Hold the camera steady."
           "Increase the lighting."
           "Point the camera toward the text."

   11. The user adjusts the camera and the system evaluates
       the image again.

   12. Once the image is suitable, OCR processes the image
       and extracts the text.

   13. For other vision requests, the appropriate vision
       model processes the image.

   14. For conversational requests, the AI model generates
       the response.

   15. For navigation or translation requests, the system
       accesses online services when required.

   16. The result is processed into an appropriate response.

   17. Text-to-Speech converts the response into audio.

   18. The user hears the final response.

   19. Important permitted information, such as preferences
       and last known location, can be stored securely.


====================================================================
45. PROJECT IN ONE SIMPLE FLOW
====================================================================

                         USER
                           |
                           v
                +-------------------+
                | Voice / Camera    |
                |      Input        |
                +---------+---------+
                          |
                          v
                +-------------------+
                | Request / Intent  |
                |   Understanding   |
                +---------+---------+
                          |
             +------------+------------+
             |            |            |
             v            v            v
            OCR         Vision         AI
             |            |            |
             |       YOLO / Scene      |
             |            |            |
             |       Currency          |
             |            |            |
             +------------+------------+
                          |
                          v
                +-------------------+
                | Context / Result  |
                |    Processing     |
                +---------+---------+
                          |
             +------------+------------+
             |                         |
             v                         v
        Local Result              Online Result
             |                         |
             |                    Translation
             |                    Navigation
             |                    Maps / APIs
             |                         |
             +------------+------------+
                          |
                          v
                +-------------------+
                | Text-to-Speech    |
                +---------+---------+
                          |
                          v
                +-------------------+
                |  Audio Response   |
                +---------+---------+
                          |
                          v
                         USER

