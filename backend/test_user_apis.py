"""
Automated test suite for all Backend User Management & Database APIs.
Exercises Registration, Login, Preferences, Emergency Contacts, Locations, and Saved Info.
"""
import time
from app import app

def main():
    print("=" * 65)
    print("AI COMPANION: Testing User APIs & MySQL Database Integration")
    print("=" * 65)

    client = app.test_client()
    timestamp = int(time.time())
    test_email = f"test_{timestamp}@example.com"
    test_password = "SecurePassword123!"

    # 1. TEST REGISTRATION
    print(f"\n1. Testing POST /api/register for {test_email}...")
    reg_res = client.post("/api/register", json={
        "user_name": "Test Explorer",
        "user_email": test_email,
        "password": test_password,
        "phone_number": "9876543210",
        "preferred_language": "en"
    })
    print(f"   Status: {reg_res.status_code}")
    reg_data = reg_res.get_json()
    print(f"   Response: {reg_data}")
    assert reg_res.status_code == 201, f"Expected 201, got {reg_res.status_code}"
    assert reg_data.get("success") is True
    user_id = reg_data["user"]["user_id"]
    print(f"   -> Registration & Auto-Preferences: PASSED [OK] (User ID: {user_id})")

    # 2. TEST DUPLICATE EMAIL REJECTION
    print("\n2. Testing duplicate email prevention...")
    dup_res = client.post("/api/register", json={
        "user_name": "Duplicate User",
        "user_email": test_email,
        "password": "anotherpassword"
    })
    print(f"   Status: {dup_res.status_code} (Expected 409 Conflict)")
    assert dup_res.status_code == 409, f"Expected 409, got {dup_res.status_code}"
    print("   -> Duplicate Email Rejection: PASSED [OK]")

    # 3. TEST LOGIN
    print(f"\n3. Testing POST /api/login...")
    login_res = client.post("/api/login", json={
        "user_email": test_email,
        "password": test_password
    })
    print(f"   Status: {login_res.status_code}")
    login_data = login_res.get_json()
    assert login_res.status_code == 200, f"Expected 200, got {login_res.status_code}"
    assert login_data.get("success") is True
    assert "token" in login_data
    print(f"   -> Password Hashing & Login: PASSED [OK] (Session Token: {login_data['token'][:8]}...)")

    # 4. TEST PREFERENCES UPDATE
    print(f"\n4. Testing PUT /api/preferences/{user_id} (Switching to Hindi)...")
    pref_update_res = client.put(f"/api/preferences/{user_id}", json={
        "preferred_language": "Hindi",
        "voice_language": "hi-IN",
        "speech_rate": "1.2"
    })
    assert pref_update_res.status_code == 200
    pref_data = pref_update_res.get_json()["preferences"]
    assert pref_data["preferred_language"] == "Hindi"
    assert pref_data["voice_language"] == "hi-IN"
    print(f"   -> Preferences Update: PASSED [OK]")

    # 5. TEST EMERGENCY CONTACTS
    print(f"\n5. Testing POST /api/emergency-contacts...")
    contact_res = client.post("/api/emergency-contacts", json={
        "user_id": user_id,
        "name": "Mother",
        "phone_number": "9123456780",
        "relationship": "Parent"
    })
    assert contact_res.status_code == 201
    contact_id = contact_res.get_json()["contact"]["contact_id"]

    get_contacts = client.get(f"/api/emergency-contacts/{user_id}")
    assert get_contacts.status_code == 200
    assert len(get_contacts.get_json()["contacts"]) >= 1
    print(f"   -> Emergency Contacts (Add & List): PASSED [OK] (Contact ID: {contact_id})")

    # 6. TEST SAVED INFORMATION (Memory Vault)
    print(f"\n6. Testing POST /api/saved-information...")
    save_info_res = client.post("/api/saved-information", json={
        "user_id": user_id,
        "title": "Front Door Key",
        "content": "Placed on the top hook next to the coat hanger.",
        "information_type": "voice_note"
    })
    assert save_info_res.status_code == 201
    saved_info_id = save_info_res.get_json()["saved_info_id"]

    get_saved = client.get(f"/api/saved-information/{user_id}")
    assert get_saved.status_code == 200
    assert len(get_saved.get_json()["saved_information"]) >= 1
    print(f"   -> Memory Vault / Saved Info: PASSED [OK] (Saved Info ID: {saved_info_id})")

    # 7. TEST LOCATION SAVING
    print(f"\n7. Testing POST /api/locations...")
    loc_res = client.post("/api/locations", json={
        "user_id": user_id,
        "location_name": "Home",
        "location_type": "residential",
        "address": "Sector 62, Noida",
        "latitude": 28.6280,
        "longitude": 77.3649
    })
    assert loc_res.status_code == 201
    get_locs = client.get(f"/api/locations/{user_id}")
    assert get_locs.status_code == 200
    assert len(get_locs.get_json()["locations"]) >= 1
    print(f"   -> Location Assistance: PASSED [OK]")

    # 8. TEST SOS DISPATCH TRIGGER
    print(f"\n8. Testing POST /api/emergency/trigger (SOS)...")
    sos_res = client.post("/api/emergency/trigger", json={
        "user_id": user_id,
        "latitude": 28.6280,
        "longitude": 77.3649
    })
    assert sos_res.status_code == 200
    sos_data = sos_res.get_json()
    print(f"   SOS Alert: {sos_data['alert_text']}")
    print(f"   -> Emergency Dispatch Trigger: PASSED [OK]")

    print("\n" + "=" * 65)
    print("ALL 8 USER & DATABASE API INTEGRATION TESTS PASSED SUCCESSFULLY! [100%]")
    print("=" * 65)

if __name__ == "__main__":
    main()
