from flask import Blueprint, request, jsonify
from database import query_db, modify_db

location_routes = Blueprint("location_routes", __name__)


@location_routes.route("/api/locations/<int:user_id>", methods=["GET"])
def get_locations(user_id):
    locations = query_db(
        """
        SELECT location_id, user_id, location_name, location_type, address,
               latitude, longitude, timestamp
        FROM `LOCATION`
        WHERE user_id = %s
        ORDER BY timestamp DESC;
        """,
        (user_id,)
    )

    for loc in locations:
        loc["latitude"] = float(loc["latitude"]) if loc.get("latitude") is not None else None
        loc["longitude"] = float(loc["longitude"]) if loc.get("longitude") is not None else None
        loc["timestamp"] = str(loc["timestamp"]) if loc.get("timestamp") else None

    return jsonify({
        "success": True,
        "locations": locations
    }), 200


@location_routes.route("/api/locations", methods=["POST"])
def add_location():
    data = request.get_json() or {}

    user_id = data.get("user_id")
    location_name = data.get("location_name", "").strip() or "Saved Place"
    location_type = data.get("location_type", "home").strip()
    address = data.get("address", "").strip() or None
    latitude = data.get("latitude")
    longitude = data.get("longitude")

    if not user_id:
        return jsonify({
            "success": False,
            "message": "user_id is required."
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
        INSERT INTO `LOCATION` (user_id, location_name, location_type, address, latitude, longitude)
        VALUES (%s, %s, %s, %s, %s, %s);
        """,
        (user_id, location_name, location_type, address, latitude, longitude)
    )

    location_id = result["last_id"]

    return jsonify({
        "success": True,
        "message": "Location saved successfully.",
        "location": {
            "location_id": location_id,
            "user_id": user_id,
            "location_name": location_name,
            "location_type": location_type,
            "address": address,
            "latitude": latitude,
            "longitude": longitude
        }
    }), 201


@location_routes.route("/api/locations/<int:location_id>", methods=["DELETE"])
def delete_location(location_id):
    result = modify_db(
        "DELETE FROM `LOCATION` WHERE location_id = %s;",
        (location_id,)
    )

    if result["row_count"] == 0:
        return jsonify({
            "success": False,
            "message": "Location record not found."
        }), 404

    return jsonify({
        "success": True,
        "message": "Location deleted successfully."
    }), 200
