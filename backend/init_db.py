"""
Database Initialization and Migration Script.
Reads schema.sql and creates the database and all 5 tables in MySQL.
"""
import argparse
import os
import sys
import mysql.connector
from dotenv import load_dotenv

# Load .env file if present
load_dotenv()

def init_database(host, port, user, password, db_name, seed=False):
    print("=" * 60)
    print("AI COMPANION: Initializing MySQL Database Schema")
    print("=" * 60)

    # 1. Connect to MySQL server (without selecting database first)
    try:
        print(f"Connecting to MySQL server at {host}:{port} as '{user}'...")
        conn = mysql.connector.connect(
            host=host,
            port=port,
            user=user,
            password=password
        )
        cursor = conn.cursor()
        print("-> Connected to MySQL server successfully! [OK]")
    except mysql.connector.Error as err:
        print(f"\n[ERROR] Connection failed: {err}")
        print("Please verify that your MySQL server is running and credentials are correct.")
        print("You can set DB_PASSWORD in a .env file or pass --password <your_password>.")
        sys.exit(1)

    # 2. Ensure database exists
    print(f"\nEnsuring database '{db_name}' exists...")
    cursor.execute(f"CREATE DATABASE IF NOT EXISTS `{db_name}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;")
    cursor.execute(f"USE `{db_name}`;")
    print(f"-> Using database '{db_name}' [OK]")

    # 3. Read and execute schema.sql
    schema_path = os.path.join(os.path.dirname(__file__), "schema.sql")
    if not os.path.exists(schema_path):
        print(f"[ERROR] schema.sql not found at {schema_path}")
        sys.exit(1)

    print(f"\nApplying schema from {os.path.basename(schema_path)}...")
    with open(schema_path, "r", encoding="utf-8") as f:
        sql_commands = f.read()

    # Split and execute individual statements
    statements = [stmt.strip() for stmt in sql_commands.split(";") if stmt.strip()]
    for stmt in statements:
        if stmt.startswith("--") or not stmt:
            continue
        try:
            cursor.execute(stmt)
        except mysql.connector.Error as err:
            print(f"Error executing statement: {err}\nQuery: {stmt[:100]}...")

    conn.commit()
    print("-> Schema applied successfully! [OK]")

    # 4. Verify created tables
    cursor.execute("SHOW TABLES;")
    tables = [row[0] for row in cursor.fetchall()]
    print("\nVerified Database Tables:")
    for t in tables:
        print(f"  - {t}")

    # 5. Optional sample data seeding
    if seed:
        print("\nSeeding demo user and preferences...")
        try:
            # Check if demo user already exists
            cursor.execute("SELECT user_id FROM `USER` WHERE user_email = 'demo@example.com';")
            existing = cursor.fetchone()
            if not existing:
                cursor.execute("""
                    INSERT INTO `USER` (user_name, user_email, password_hash, phone_number)
                    VALUES ('Demo User', 'demo@example.com', 'demo_hash_placeholder', '9876543210');
                """)
                user_id = cursor.lastrowid
                cursor.execute("""
                    INSERT INTO `USER_PREFERENCES` (user_id, preferred_language, voice_language, speech_rate)
                    VALUES (%s, 'Hindi', 'hi-IN', '1.0');
                """, (user_id,))
                cursor.execute("""
                    INSERT INTO `EMERGENCY_CONTACT` (user_id, name, phone_number, relationship)
                    VALUES (%s, 'Guardian', '9123456789', 'Family');
                """, (user_id,))
                conn.commit()
                print("-> Seed data added successfully! [OK]")
            else:
                print("-> Demo user already exists, skipping seed.")
        except mysql.connector.Error as err:
            print(f"Notice while seeding: {err}")

    cursor.close()
    conn.close()
    print("\n" + "=" * 60)
    print("Database initialization finished successfully!")
    print("=" * 60)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Initialize AI Companion MySQL Database")
    parser.add_argument("--host", default=os.getenv("DB_HOST", "localhost"), help="MySQL host")
    parser.add_argument("--port", type=int, default=int(os.getenv("DB_PORT", "3306")), help="MySQL port")
    parser.add_argument("--user", default=os.getenv("DB_USER", "root"), help="MySQL user")
    parser.add_argument("--password", default=os.getenv("DB_PASSWORD", ""), help="MySQL password")
    parser.add_argument("--database", default=os.getenv("DB_NAME", "ai_companion"), help="Database name")
    parser.add_argument("--seed", action="store_true", help="Insert demo test data")

    args = parser.parse_args()
    init_database(args.host, args.port, args.user, args.password, args.database, args.seed)
