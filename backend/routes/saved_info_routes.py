from flask import Blueprint, request, jsonify
from database import query_db, modify_db

saved_info_routes = Blueprint("saved_info_routes", __name__)


@saved_info_routes.route("/api/saved-information/<int:user_id>", methods=["GET"])
def get_saved_information(user_id):
    info_list = query_db(
        """
        SELECT saved_info_id, user_id, title, content, information_type, created_at
        FROM `SAVED_INFORMATION`
        WHERE user_id = %s
        ORDER BY created_at DESC;
        """,
        (user_id,)
    )

    for item in info_list:
        item["created_at"] = str(item["created_at"]) if item.get("created_at") else None

    return jsonify({
        "success": True,
        "saved_information": info_list
    }), 200


@saved_info_routes.route("/api/saved-information", methods=["POST"])
def add_saved_information():
    data = request.get_json() or {}

    user_id = data.get("user_id")
    content = data.get("content", "").strip()
    title = data.get("title", "").strip() or "Untitled Note"
    information_type = data.get("information_type", "voice_note").strip()

    if not user_id or not content:
        return jsonify({
            "success": False,
            "message": "user_id and content are required."
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
        INSERT INTO `SAVED_INFORMATION` (user_id, title, content, information_type)
        VALUES (%s, %s, %s, %s);
        """,
        (user_id, title, content, information_type)
    )

    saved_info_id = result["last_id"]

    return jsonify({
        "success": True,
        "message": "Information saved successfully.",
        "saved_info_id": saved_info_id,
        "item": {
            "saved_info_id": saved_info_id,
            "user_id": user_id,
            "title": title,
            "content": content,
            "information_type": information_type
        }
    }), 201


@saved_info_routes.route("/api/saved-information/<int:saved_info_id>", methods=["DELETE"])
def delete_saved_information(saved_info_id):
    result = modify_db(
        "DELETE FROM `SAVED_INFORMATION` WHERE saved_info_id = %s;",
        (saved_info_id,)
    )

    if result["row_count"] == 0:
        return jsonify({
            "success": False,
            "message": "Saved information record not found."
        }), 404

    return jsonify({
        "success": True,
        "message": "Saved information deleted successfully."
    }), 200
