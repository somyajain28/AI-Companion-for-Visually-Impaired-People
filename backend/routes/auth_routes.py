import secrets
from flask import Blueprint, request, jsonify
from werkzeug.security import generate_password_hash, check_password_hash
from database import query_db, modify_db

auth_routes = Blueprint("auth_routes", __name__)


@auth_routes.route("/api/register", methods=["POST"])
def register():
    data = request.get_json() or {}

    user_name = data.get("user_name", "").strip()
    user_email = data.get("user_email", "").strip().lower()
    password = data.get("password", "")
    phone_number = data.get("phone_number", "").strip() or None
    date_of_birth = data.get("date_of_birth") or None
    preferred_language = data.get("preferred_language", "en")

    if not user_name or not user_email or not password:
        return jsonify({
            "success": False,
            "message": "Name, email, and password are required."
        }), 400

    if len(password) < 6:
        return jsonify({
            "success": False,
            "message": "Password must be at least 6 characters long."
        }), 400

    # Check if email is already registered
    existing_user = query_db(
        "SELECT user_id FROM `USER` WHERE user_email = %s;",
        (user_email,),
        one=True
    )
    if existing_user:
        return jsonify({
            "success": False,
            "message": "An account with this email already exists."
        }), 409

    # Hash the password securely
    password_hash = generate_password_hash(password)

    try:
        # Create user record
        insert_result = modify_db(
            """
            INSERT INTO `USER` (user_name, user_email, password_hash, phone_number, date_of_birth)
            VALUES (%s, %s, %s, %s, %s);
            """,
            (user_name, user_email, password_hash, phone_number, date_of_birth)
        )
        user_id = insert_result["last_id"]

        # Automatically provision 1-to-1 default preferences
        voice_lang = "hi-IN" if preferred_language.lower().startswith("hi") else "en-US"
        modify_db(
            """
            INSERT INTO `USER_PREFERENCES` (user_id, preferred_language, voice_language, speech_rate)
            VALUES (%s, %s, %s, %s);
            """,
            (user_id, preferred_language, voice_lang, "1.0")
        )

        return jsonify({
            "success": True,
            "message": "User registered successfully.",
            "user": {
                "user_id": user_id,
                "user_name": user_name,
                "user_email": user_email,
                "phone_number": phone_number,
                "preferred_language": preferred_language
            }
        }), 201

    except Exception as e:
        return jsonify({
            "success": False,
            "message": "Registration failed.",
            "error": str(e)
        }), 500


@auth_routes.route("/api/login", methods=["POST"])
def login():
    data = request.get_json() or {}

    user_email = data.get("user_email", "").strip().lower()
    password = data.get("password", "")

    if not user_email or not password:
        return jsonify({
            "success": False,
            "message": "Email and password are required."
        }), 400

    # Retrieve user by email
    user = query_db(
        """
        SELECT user_id, user_name, user_email, password_hash, phone_number, date_of_birth, created_at
        FROM `USER`
        WHERE user_email = %s;
        """,
        (user_email,),
        one=True
    )

    if not user or not check_password_hash(user["password_hash"], password):
        return jsonify({
            "success": False,
            "message": "Invalid email or password."
        }), 401

    # Retrieve associated preferences
    preferences = query_db(
        """
        SELECT preference_id, preferred_language, voice_language, speech_rate, audio_guidance, theme
        FROM `USER_PREFERENCES`
        WHERE user_id = %s;
        """,
        (user["user_id"],),
        one=True
    )

    # Simple session token for API authorization
    session_token = secrets.token_hex(24)

    # Sanitize password hash from response
    user_payload = {
        "user_id": user["user_id"],
        "user_name": user["user_name"],
        "user_email": user["user_email"],
        "phone_number": user["phone_number"],
        "date_of_birth": str(user["date_of_birth"]) if user["date_of_birth"] else None,
    }

    return jsonify({
        "success": True,
        "message": "Login successful.",
        "token": session_token,
        "user": user_payload,
        "preferences": preferences or {}
    }), 200


@auth_routes.route("/api/profile/<int:user_id>", methods=["GET"])
def get_profile(user_id):
    user = query_db(
        """
        SELECT user_id, user_name, user_email, phone_number, date_of_birth, created_at
        FROM `USER`
        WHERE user_id = %s;
        """,
        (user_id,),
        one=True
    )

    if not user:
        return jsonify({
            "success": False,
            "message": "User not found."
        }), 404

    preferences = query_db(
        "SELECT * FROM `USER_PREFERENCES` WHERE user_id = %s;",
        (user_id,),
        one=True
    )

    user["date_of_birth"] = str(user["date_of_birth"]) if user["date_of_birth"] else None
    user["created_at"] = str(user["created_at"]) if user["created_at"] else None

    return jsonify({
        "success": True,
        "user": user,
        "preferences": preferences or {}
    }), 200


@auth_routes.route("/api/profile/<int:user_id>", methods=["PUT"])
def update_profile(user_id):
    data = request.get_json() or {}

    user_name = data.get("user_name")
    phone_number = data.get("phone_number")
    date_of_birth = data.get("date_of_birth")

    updates = []
    values = []

    if user_name is not None:
        updates.append("user_name = %s")
        values.append(user_name.strip())
    if phone_number is not None:
        updates.append("phone_number = %s")
        values.append(phone_number.strip())
    if date_of_birth is not None:
        updates.append("date_of_birth = %s")
        values.append(date_of_birth)

    if not updates:
        return jsonify({
            "success": False,
            "message": "No profile fields to update."
        }), 400

    values.append(user_id)
    query = f"UPDATE `USER` SET {', '.join(updates)} WHERE user_id = %s;"

    result = modify_db(query, tuple(values))

    if result["row_count"] == 0:
        return jsonify({
            "success": False,
            "message": "User not found or no changes made."
        }), 404

    return jsonify({
        "success": True,
        "message": "Profile updated successfully."
    }), 200
