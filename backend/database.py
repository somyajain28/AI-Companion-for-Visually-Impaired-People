import mysql.connector
from config import DB_CONFIG


def get_db_connection():
    """Create and return a raw MySQL connection."""
    return mysql.connector.connect(**DB_CONFIG)


def query_db(query, args=(), one=False):
    """
    Executes a SELECT query and returns dictionary rows.
    Automatically manages connection and cursor lifecycle.
    """
    conn = get_db_connection()
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(query, args)
        result = cursor.fetchall()
        cursor.close()
        return (result[0] if result else None) if one else result
    finally:
        conn.close()


def modify_db(query, args=()):
    """
    Executes an INSERT, UPDATE, or DELETE statement.
    Automatically commits transaction and closes connection.
    Returns dict with last_id and row_count.
    """
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute(query, args)
        conn.commit()
        last_id = cursor.lastrowid
        row_count = cursor.rowcount
        cursor.close()
        return {"last_id": last_id, "row_count": row_count}
    finally:
        conn.close()