import re
import secrets
from datetime import datetime
from flask import Blueprint, request, jsonify
from werkzeug.security import check_password_hash
from database import query_db, modify_db

auth_routes = Blueprint("auth_routes", __name__)


def robust_parse_dob(text):
    """
    Robustly parses spoken and typed dates into YYYY-MM-DD for MySQL DATE columns.
    Handles words ('fifteenth of august two thousand', 'twenty third march 1999'),
    spoken dates ('15th August 2000', '15th of August, 2000', 'August 15th 2000'),
    and numeric dates ('15-08-2000', '15/08/2000', '15 08 2000', '2000-08-15', '15/08/00').
    """
    if not text:
        return None
    s = str(text).lower().strip()

    # Remove common spoken prefixes
    for prefix in [
        'my date of birth should be', 'my date of birth is', 'date of birth is',
        'my dob is', 'dob is', 'i was born on', 'it is', "it's", 'date of birth'
    ]:
        if s.startswith(prefix) and len(s) > len(prefix):
            s = s[len(prefix):].strip()

    # Common spoken years (convert before word days so words like 'two' in 'two thousand' don't get eaten)
    s = re.sub(r'\btwo thousand and one\b', '2001', s)
    s = re.sub(r'\btwo thousand and two\b', '2002', s)
    s = re.sub(r'\btwo thousand and three\b', '2003', s)
    s = re.sub(r'\btwo thousand and four\b', '2004', s)
    s = re.sub(r'\btwo thousand and five\b', '2005', s)
    s = re.sub(r'\btwo thousand and six\b', '2006', s)
    s = re.sub(r'\btwo thousand and seven\b', '2007', s)
    s = re.sub(r'\btwo thousand and eight\b', '2008', s)
    s = re.sub(r'\btwo thousand and nine\b', '2009', s)
    s = re.sub(r'\btwo thousand and ten\b', '2010', s)
    s = re.sub(r'\btwo thousand\b', '2000', s)
    s = re.sub(r'\b2 thousand\b', '2000', s)

    tens = {
        'ninety': 90, 'eighty': 80, 'seventy': 70, 'sixty': 60,
        'fifty': 50, 'forty': 40, 'thirty': 30, 'twenty': 20
    }
    ones = {
        'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5,
        'six': 6, 'seven': 7, 'eight': 8, 'nine': 9
    }
    teens = {
        'ten': 10, 'eleven': 11, 'twelve': 12, 'thirteen': 13,
        'fourteen': 14, 'fifteen': 15, 'sixteen': 16, 'seventeen': 17,
        'eighteen': 18, 'nineteen': 19
    }
    for t_word, t_val in tens.items():
        for o_word, o_val in ones.items():
            s = re.sub(r'\bnineteen ' + t_word + ' ' + o_word + r'\b', str(1900 + t_val + o_val), s)
            s = re.sub(r'\btwenty ' + t_word + ' ' + o_word + r'\b', str(2000 + t_val + o_val), s)
        s = re.sub(r'\bnineteen ' + t_word + r'\b', str(1900 + t_val), s)
        s = re.sub(r'\btwenty ' + t_word + r'\b', str(2000 + t_val), s)
    for teen_word, teen_val in teens.items():
        s = re.sub(r'\bnineteen ' + teen_word + r'\b', str(1900 + teen_val), s)
        s = re.sub(r'\btwenty ' + teen_word + r'\b', str(2000 + teen_val), s)
    s = re.sub(r'\bnineteen hundred\b', '1900', s)

    word_to_day = {
        'first': 1, '1st': 1, 'one': 1,
        'second': 2, '2nd': 2, 'two': 2,
        'third': 3, '3rd': 3, 'three': 3,
        'fourth': 4, '4th': 4, 'four': 4,
        'fifth': 5, '5th': 5, 'five': 5,
        'sixth': 6, '6th': 6, 'six': 6,
        'seventh': 7, '7th': 7, 'seven': 7,
        'eighth': 8, '8th': 8, 'eight': 8,
        'ninth': 9, '9th': 9, 'nine': 9,
        'tenth': 10, '10th': 10, 'ten': 10,
        'eleventh': 11, '11th': 11, 'eleven': 11,
        'twelfth': 12, '12th': 12, 'twelve': 12,
        'thirteenth': 13, '13th': 13, 'thirteen': 13,
        'fourteenth': 14, '14th': 14, 'fourteen': 14,
        'fifteenth': 15, '15th': 15, 'fifteen': 15,
        'sixteenth': 16, '16th': 16, 'sixteen': 16,
        'seventeenth': 17, '17th': 17, 'seventeen': 17,
        'eighteenth': 18, '18th': 18, 'eighteen': 18,
        'nineteenth': 19, '19th': 19, 'nineteen': 19,
        'twentieth': 20, '20th': 20, 'twenty': 20,
        'twenty first': 21, '21st': 21, 'twenty-first': 21, 'twenty one': 21,
        'twenty second': 22, '22nd': 22, 'twenty-second': 22, 'twenty two': 22,
        'twenty third': 23, '23rd': 23, 'twenty-third': 23, 'twenty three': 23,
        'twenty fourth': 24, '24th': 24, 'twenty-fourth': 24, 'twenty four': 24,
        'twenty fifth': 25, '25th': 25, 'twenty-fifth': 25, 'twenty five': 25,
        'twenty sixth': 26, '26th': 26, 'twenty-sixth': 26, 'twenty six': 26,
        'twenty seventh': 27, '27th': 27, 'twenty-seventh': 27, 'twenty seven': 27,
        'twenty eighth': 28, '28th': 28, 'twenty-eighth': 28, 'twenty eight': 28,
        'twenty ninth': 29, '29th': 29, 'twenty-ninth': 29, 'twenty nine': 29,
        'thirtieth': 30, '30th': 30, 'thirty': 30,
        'thirty first': 31, '31st': 31, 'thirty-first': 31, 'thirty one': 31,
    }

    # Replace words for days
    for word, num in sorted(word_to_day.items(), key=lambda x: -len(x[0])):
        s = re.sub(r'\b' + re.escape(word) + r'\b', str(num), s)

    # Remove ordinal suffixes: 1st, 2nd, 3rd, 4th -> 1, 2, 3, 4
    s = re.sub(r'(\d+)(st|nd|rd|th)\b', r'\1', s)
    # Remove 'of' as in '15 of august'
    s = re.sub(r'\bof\b', '', s)
    s = re.sub(r'[^\w\s\-\/\.]', '', s)
    s = re.sub(r'\s+', ' ', s).strip()

    month_map = {
        'january': 1, 'jan': 1, 'february': 2, 'feb': 2, 'march': 3, 'mar': 3,
        'april': 4, 'apr': 4, 'may': 5, 'june': 6, 'jun': 6, 'july': 7, 'jul': 7,
        'august': 8, 'aug': 8, 'september': 9, 'sep': 9, 'sept': 9, 'october': 10,
        'oct': 10, 'november': 11, 'nov': 11, 'december': 12, 'dec': 12
    }

    # Pattern: Day Month Year (e.g. '15 august 2000' or '15 aug 00')
    m = re.search(r'(\d{1,2})\s+([a-zA-Z]+)\s+(\d{2,4})', s)
    if m:
        day, mon_name, year = int(m.group(1)), m.group(2).lower(), int(m.group(3))
        if year < 100:
            year = 1900 + year if year >= 30 else 2000 + year
        if mon_name in month_map:
            return f"{year:04d}-{month_map[mon_name]:02d}-{day:02d}"

    # Pattern: Month Day Year (e.g. 'august 15 2000' or 'aug 15 00')
    m = re.search(r'([a-zA-Z]+)\s+(\d{1,2})\s+(\d{2,4})', s)
    if m:
        mon_name, day, year = m.group(1).lower(), int(m.group(2)), int(m.group(3))
        if year < 100:
            year = 1900 + year if year >= 30 else 2000 + year
        if mon_name in month_map:
            return f"{year:04d}-{month_map[mon_name]:02d}-{day:02d}"

    # Pattern: DD-MM-YYYY or DD/MM/YYYY or DD.MM.YYYY or DD MM YYYY
    m = re.search(r'(\d{1,2})[\s\-\/\.](\d{1,2})[\s\-\/\.](\d{2,4})', s)
    if m:
        day, month, year = int(m.group(1)), int(m.group(2)), int(m.group(3))
        if year < 100:
            year = 1900 + year if year >= 30 else 2000 + year
        if 1 <= month <= 12 and 1 <= day <= 31:
            return f"{year:04d}-{month:02d}-{day:02d}"

    # Pattern: YYYY-MM-DD
    m = re.search(r'(\d{4})[\s\-\/\.](\d{1,2})[\s\-\/\.](\d{1,2})', s)
    if m:
        year, month, day = int(m.group(1)), int(m.group(2)), int(m.group(3))
        return f"{year:04d}-{month:02d}-{day:02d}"

    return None


@auth_routes.route("/api/register", methods=["POST"])
def register():
    data = request.get_json() or {}

    user_name = data.get("user_name", "").strip()
    user_email = data.get("user_email", "").strip().lower()
    password = str(data.get("password", "")).strip()
    phone_number = data.get("phone_number", "").strip() or None
    raw_dob = data.get("date_of_birth")
    date_of_birth = robust_parse_dob(raw_dob)
    preferred_language = data.get("preferred_language", "en")

    print(f"\n[REGISTER REQUEST] user_name='{user_name}', email='{user_email}', raw_dob='{raw_dob}' -> parsed_dob='{date_of_birth}', password='{password}'")

    if not user_name or not user_email or not password:
        return jsonify({
            "success": False,
            "message": "Name, email, and password are required."
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

    try:
        # Save exact password in password_hash column so it matches the user's spoken password
        insert_result = modify_db(
            """
            INSERT INTO `USER` (user_name, user_email, password_hash, phone_number, date_of_birth)
            VALUES (%s, %s, %s, %s, %s);
            """,
            (user_name, user_email, password, phone_number, date_of_birth)
        )
        user_id = insert_result["last_id"]

        # Default voice language is Indian English (en-IN)
        voice_lang = "en-IN" if not preferred_language.lower().startswith("hi") else "hi-IN"
        modify_db(
            """
            INSERT INTO `USER_PREFERENCES` (user_id, preferred_language, voice_language, speech_rate)
            VALUES (%s, %s, %s, %s);
            """,
            (user_id, preferred_language, voice_lang, "1.0")
        )

        print(f"[REGISTER SUCCESS] Created user_id={user_id} with exact password='{password}' and dob='{date_of_birth}'")

        return jsonify({
            "success": True,
            "message": "User registered successfully.",
            "user": {
                "user_id": user_id,
                "user_name": user_name,
                "user_email": user_email,
                "phone_number": phone_number,
                "date_of_birth": str(date_of_birth) if date_of_birth else None,
                "preferred_language": preferred_language
            }
        }), 201

    except Exception as e:
        print(f"[REGISTER ERROR] {e}")
        return jsonify({
            "success": False,
            "message": "Registration failed.",
            "error": str(e)
        }), 500


@auth_routes.route("/api/login", methods=["POST"])
def login():
    data = request.get_json() or {}

    user_identifier = data.get("user_name") or data.get("user_email") or data.get("identifier") or ""
    user_identifier = str(user_identifier).strip()
    password = str(data.get("password", "")).strip()

    print(f"\n[LOGIN REQUEST] identifier='{user_identifier}', password='{password}'")

    if not user_identifier or not password:
        return jsonify({
            "success": False,
            "error_type": "missing_fields",
            "message": "User name and password are required."
        }), 400

    # Look up user by user_name OR user_email (case-insensitive)
    user = query_db(
        """
        SELECT user_id, user_name, user_email, password_hash, phone_number, date_of_birth, created_at
        FROM `USER`
        WHERE LOWER(user_name) = LOWER(%s) OR LOWER(user_email) = LOWER(%s);
        """,
        (user_identifier, user_identifier),
        one=True
    )

    if not user:
        return jsonify({
            "success": False,
            "error_type": "user_not_found",
            "message": "No user registered. Please register."
        }), 404

    stored_pass = user["password_hash"]
    # Check exact match OR hashed match for maximum compatibility
    is_password_valid = (stored_pass == password)
    if not is_password_valid:
        try:
            is_password_valid = check_password_hash(stored_pass, password)
        except Exception:
            pass

    if not is_password_valid:
        return jsonify({
            "success": False,
            "error_type": "incorrect_password",
            "message": "Incorrect password. Please try again."
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

    session_token = secrets.token_hex(24)

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
    raw_dob = data.get("date_of_birth")
    date_of_birth = robust_parse_dob(raw_dob) if raw_dob else None

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
