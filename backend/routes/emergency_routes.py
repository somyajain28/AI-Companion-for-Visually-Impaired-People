from flask import Blueprint, request, jsonify
from database import query_db, modify_db

emergency_routes = Blueprint("emergency_routes", __name__)


@emergency_routes.route("/api/emergency-contacts/<int:user_id>", methods=["GET"])
def get_emergency_contacts(user_id):
    contacts = query_db(
        """
        SELECT contact_id, user_id, name, phone_number, relationship, created_at
        FROM `EMERGENCY_CONTACT`
        WHERE user_id = %s
        ORDER BY created_at DESC;
        """,
        (user_id,)
    )

    for c in contacts:
        c["created_at"] = str(c["created_at"]) if c.get("created_at") else None

    return jsonify({
        "success": True,
        "contacts": contacts
    }), 200


@emergency_routes.route("/api/emergency-contacts", methods=["POST"])
def add_emergency_contact():
    data = request.get_json() or {}

    user_id = data.get("user_id")
    name = data.get("name", "").strip()
    phone_number = data.get("phone_number", "").strip()
    relationship = data.get("relationship", "").strip() or "Caregiver"

    if not user_id or not name or not phone_number:
        return jsonify({
            "success": False,
            "message": "user_id, name, and phone_number are required."
        }), 400

    # Ensure user exists
    user = query_db("SELECT user_id FROM `USER` WHERE user_id = %s;", (user_id,), one=True)
    if not user:
        return jsonify({
            "success": False,
            "message": "User not found."
        }), 404

    result = modify_db(
        """
        INSERT INTO `EMERGENCY_CONTACT` (user_id, name, phone_number, relationship)
        VALUES (%s, %s, %s, %s);
        """,
        (user_id, name, phone_number, relationship)
    )

    contact_id = result["last_id"]

    return jsonify({
        "success": True,
        "message": "Emergency contact added successfully.",
        "contact": {
            "contact_id": contact_id,
            "user_id": user_id,
            "name": name,
            "phone_number": phone_number,
            "relationship": relationship
        }
    }), 201


@emergency_routes.route("/api/emergency-contacts/<int:contact_id>", methods=["DELETE"])
def delete_emergency_contact(contact_id):
    result = modify_db(
        "DELETE FROM `EMERGENCY_CONTACT` WHERE contact_id = %s;",
        (contact_id,)
    )

    if result["row_count"] == 0:
        return jsonify({
            "success": False,
            "message": "Contact not found."
        }), 404

    return jsonify({
        "success": True,
        "message": "Emergency contact deleted successfully."
    }), 200


@emergency_routes.route("/api/emergency/trigger", methods=["POST"])
def trigger_emergency():
    """Simulates sending SOS alerts to all registered emergency contacts."""
    data = request.get_json() or {}
    user_id = data.get("user_id")
    latitude = data.get("latitude")
    longitude = data.get("longitude")

    if not user_id:
        return jsonify({"success": False, "message": "user_id is required."}), 400

    user = query_db("SELECT user_name FROM `USER` WHERE user_id = %s;", (user_id,), one=True)
    contacts = query_db("SELECT name, phone_number, relationship FROM `EMERGENCY_CONTACT` WHERE user_id = %s;", (user_id,))

    user_name = user["user_name"] if user else "The user"
    maps_link = f"https://maps.google.com/?q={latitude},{longitude}" if latitude and longitude else "Unknown location"

    sos_message = (
        f"EMERGENCY ALERT: {user_name} has triggered an SOS signal. "
        f"Location: {maps_link}."
    )

    return jsonify({
        "success": True,
        "message": f"SOS alert dispatched to {len(contacts)} emergency contacts.",
        "alert_text": sos_message,
        "notified_contacts": contacts
    }), 200
