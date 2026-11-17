import os
from flask import Flask, jsonify
from flask_cors import CORS

from database import get_db_connection
from routes.speech_routes import speech_routes
from routes.auth_routes import auth_routes
from routes.preference_routes import preference_routes
from routes.emergency_routes import emergency_routes
from routes.saved_info_routes import saved_info_routes
from routes.location_routes import location_routes

app = Flask(__name__)
CORS(app)

# Register modular blueprints
app.register_blueprint(speech_routes)
app.register_blueprint(auth_routes)
app.register_blueprint(preference_routes)
app.register_blueprint(emergency_routes)
app.register_blueprint(saved_info_routes)
app.register_blueprint(location_routes)


@app.route("/")
def home():
    return jsonify({
        "success": True,
        "message": "AI Companion Backend is running",
        "version": "1.0.0",
        "endpoints": [
            "/api/health",
            "/api/db-test",
            "/api/speech-to-text",
            "/api/register",
            "/api/login",
            "/api/profile/<user_id>",
            "/api/preferences/<user_id>",
            "/api/emergency-contacts/<user_id>",
            "/api/saved-information/<user_id>",
            "/api/locations/<user_id>"
        ]
    })


@app.route("/api/health")
def health_check():
    return jsonify({
        "success": True,
        "message": "Backend is healthy"
    })


@app.route("/api/db-test")
def database_test():
    try:
        connection = get_db_connection()
        if connection.is_connected():
            connection.close()
            return jsonify({
                "success": True,
                "message": "MySQL database connected successfully"
            })
    except Exception as e:
        return jsonify({
            "success": False,
            "message": "Database connection failed",
            "error": str(e)
        }), 500


if __name__ == "__main__":
    port = int(os.getenv("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=True)