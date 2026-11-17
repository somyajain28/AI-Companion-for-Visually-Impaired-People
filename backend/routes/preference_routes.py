from flask import Blueprint, request, jsonify
from database import query_db, modify_db

preference_routes = Blueprint("preference_routes", __name__)


@preference_routes.route("/api/preferences/<int:user_id>", methods=["GET"])
def get_preferences(user_id):
    prefs = query_db(
        """
        SELECT preference_id, user_id, preferred_language, voice_language,
               speech_rate, audio_guidance, theme, updated_at
        FROM `USER_PREFERENCES`
        WHERE user_id = %s;
        """,
        (user_id,),
        one=True
    )

    if not prefs:
        return jsonify({
            "success": False,
            "message": "Preferences not found for this user."
        }), 404

    prefs["updated_at"] = str(prefs["updated_at"]) if prefs.get("updated_at") else None

    return jsonify({
        "success": True,
        "preferences": prefs
    }), 200


@preference_routes.route("/api/preferences/<int:user_id>", methods=["PUT"])
def update_preferences(user_id):
    data = request.get_json() or {}

    preferred_language = data.get("preferred_language")
    voice_language = data.get("voice_language")
    speech_rate = data.get("speech_rate")
    audio_guidance = data.get("audio_guidance")
    theme = data.get("theme")

    updates = []
    values = []

    if preferred_language is not None:
        updates.append("preferred_language = %s")
        values.append(preferred_language)
    if voice_language is not None:
        updates.append("voice_language = %s")
        values.append(voice_language)
    if speech_rate is not None:
        updates.append("speech_rate = %s")
        values.append(str(speech_rate))
    if audio_guidance is not None:
        updates.append("audio_guidance = %s")
        values.append(bool(audio_guidance))
    if theme is not None:
        updates.append("theme = %s")
        values.append(theme)

    if not updates:
        return jsonify({
            "success": False,
            "message": "No preference fields provided to update."
        }), 400

    values.append(user_id)
    query = f"UPDATE `USER_PREFERENCES` SET {', '.join(updates)} WHERE user_id = %s;"

    result = modify_db(query, tuple(values))

    # Fetch updated preferences
    updated = query_db(
        "SELECT * FROM `USER_PREFERENCES` WHERE user_id = %s;",
        (user_id,),
        one=True
    )

    if updated:
        updated["updated_at"] = str(updated["updated_at"]) if updated.get("updated_at") else None

    return jsonify({
        "success": True,
        "message": "Preferences updated successfully.",
        "preferences": updated
    }), 200
