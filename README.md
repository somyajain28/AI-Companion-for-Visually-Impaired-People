# AI COMPANION FOR VISUALLY IMPAIRED PEOPLE : Intelligent Navigation And Assistance System


## Opening

Visual impairment is a significant global public health and social challenge that affects millions of people, limiting their ability to navigate independently, access information, and perform daily activities safely. Despite advancements in assistive technologies, independent mobility remains a major concern for many visually impaired individuals.

---

## India Statistics

According to the National Institute for the Empowerment of Persons with Visual Disabilities (NIEPVD), India has approximately **4.95 million blind people** and **70 million visually impaired people**, including around **0.24 million blind children**. These figures highlight the growing need for affordable and accessible assistive technologies.

---

## Safety Statistics

A study published in the National Library of Medicine (NLM) reported that **68% of visually impaired individuals experienced at least one serious life event**, compared to **60% of the general population**. The study also found a significantly higher prevalence of serious accidents, life-threatening injuries, and other hazardous events among people with visual impairment, emphasizing the need for preventive and assistive solutions.

---

## Problem

People with visual impairment face numerous daily challenges, including:

- Detecting obstacles
- Crossing roads safely
- Identifying traffic signals
- Reading signboards
- Recognizing currency
- Locating entrances
- Navigating unfamiliar environments

These challenges reduce independence and increase reliance on others for everyday activities.

---

## Existing Solutions

Several assistive technologies such as **OrCam MyEye, Envision Glasses, Meta Smart Glasses, Seeing AI, and Google Lookout** are available. However, many of these solutions are either expensive, require specialized hardware, have limited hands-free functionality, or are inaccessible to a large section of the population, especially in developing countries.

---

## Research Gap

There is a clear need for an affordable, intelligent, and wearable assistive system that provides real-time environmental awareness while utilizing commonly available devices. Existing solutions either focus on specific tasks or remain financially out of reach for many users.

---

## Proposed Solution

This project proposes a **low-cost AI-powered wearable assistant** that integrates:

- Smart camera mounted on glasses
- Smartphone for AI processing
- Bluetooth earphones for voice feedback

The system is designed to provide real-time assistance without requiring expensive standalone hardware.

---

## Key Features

The proposed system aims to provide:

- Real-time obstacle detection
- Traffic light recognition
- Navigation assistance
- OCR-based text and signboard reading
- Currency recognition
- Context-aware voice guidance
- Hands-free operation for improved accessibility

---

## Affordability

Unlike existing commercial smart glasses that rely on dedicated processing hardware, the proposed system leverages the user's existing smartphone for AI computation. This significantly reduces hardware costs while maintaining intelligent real-time assistance, making the solution more practical and affordable.

---

## Expected Benefits

The proposed system aims to:

- Improve independent mobility
- Enhance situational awareness
- Support safer navigation
- Reduce dependence on caregivers
- Improve the overall quality of life for visually impaired users

---

## Expected Impact

Considering the large visually impaired population in India, even limited adoption of an affordable AI-based wearable assistant could positively impact thousands of users. The project also demonstrates how modern AI and computer vision technologies can be applied to create practical, cost-effective, and socially impactful assistive solutions.

---

## Conclusion

By addressing the limitations of existing assistive technologies and focusing on affordability, accessibility, and real-time AI assistance, this project aims to bridge the gap between advanced technology and the everyday needs of visually impaired individuals. The proposed system has the potential to make independent navigation safer, more accessible, and economically feasible for a wider population.

---

# Technology Stack

The proposed system combines Artificial Intelligence, Computer Vision, Embedded Systems, and Mobile Computing to deliver a practical assistive solution.

### Software

- Programming Language: Python
- Computer Vision: OpenCV
- Object Detection: YOLOv8
- OCR: EasyOCR / Tesseract OCR
- Speech Output: gTTS / Android Text-to-Speech
- Speech Recognition: Whisper / Android Speech Recognition
- Navigation: Google Maps API
- Mobile Application: Flutter

### Hardware

- Smart Camera
- ESP32 / ESP32-CAM
- Bluetooth Module
- Rechargeable Battery
- Bluetooth Earphones
- Spectacle Frame

### AI Processing

- Android Smartphone (On-device AI)

---

# Proposed System Architecture

To make the solution affordable and practical, AI processing will **not** be performed inside the smart glasses.

Instead:

Smart Camera (Mounted on Glasses)
        ↓
Bluetooth / Wi-Fi Transmission
        ↓
Android Smartphone
        ↓
AI Processing
• YOLO Object Detection
• OCR
• Navigation
• Traffic Signal Recognition
• Currency Recognition
• Voice Generation
        ↓
Bluetooth Earphones
        ↓
Real-Time Voice Guidance

This architecture minimizes hardware complexity, reduces power consumption, and significantly lowers the overall system cost.

---

# Cost Effectiveness

One of the primary objectives of this project is affordability.

Existing commercial AI-powered smart glasses often cost **tens of thousands to several lakhs of rupees**, making them inaccessible for many users.

Our proposed architecture leverages the user's existing smartphone as the AI processing unit, eliminating the need for expensive onboard processors.

The additional wearable hardware consists only of:

- Camera
- ESP32 / Microcontroller
- Bluetooth Module
- Battery
- Spectacle Frame

### Estimated Prototype Cost

**Less than ₹5,000 (excluding the smartphone).**

This makes the proposed solution practical, scalable, and affordable.

---

# Innovation

The novelty of this project lies not only in integrating multiple AI features into a single wearable system but also in designing an affordable architecture.

By shifting computationally intensive AI tasks to the smartphone while keeping the wearable hardware lightweight, the proposed solution delivers advanced functionality at a fraction of the cost of existing commercial devices.

---

# Why Our Approach?

- Uses the user's existing smartphone instead of expensive onboard processors.
- Lightweight wearable design for improved comfort.
- Real-time AI assistance through voice feedback.
- Low-cost prototype with an estimated hardware cost below ₹5,000.
- Scalable architecture that can be enhanced with additional AI features in the future.
- Designed specifically to improve accessibility while remaining affordable for a wider population.