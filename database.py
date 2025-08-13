import sqlite3
from typing import List, Dict, Any
import os

def dict_factory(cursor: sqlite3.Cursor, row: tuple) -> Dict[str, Any]:
    """Convert database row to dictionary with column names as keys"""
    fields = [column[0] for column in cursor.description]
    return {key: value for key, value in zip(fields, row)}

# Global connection variable for in-memory database to maintain a single instance
_connection = None

def init_db():
    """Initialize the in-memory database with schema"""
    global _connection
    _connection = sqlite3.connect(':memory:', check_same_thread=False)
    _connection.row_factory = dict_factory
    
    # Always load schema for in-memory database
    schema_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "schema.sql")
    with open(schema_path, "r") as f:
        _connection.executescript(f.read())

    # Seed all data after schema is loaded
    from seed_data import seed_all_data
    seed_all_data()

def get_db():
    """Get the global database connection"""
    global _connection
    if _connection is None:
        init_db()
    _connection.row_factory = dict_factory  # Ensure row_factory is always set
    return _connection

def execute_query(conn: sqlite3.Connection, query: str, params: tuple = ()) -> List[Dict[str, Any]]:
    """Execute a SELECT query and return results as a list of dictionaries"""
    cursor = conn.cursor()
    cursor.execute(query, params)
    results = cursor.fetchall()
    cursor.close()
    return results

def execute_write(conn: sqlite3.Connection, query: str, params: tuple = ()) -> None:
    """Execute a write query (INSERT, UPDATE, DELETE, etc.)"""
    cursor = conn.cursor()
    cursor.execute(query, params)
    conn.commit()
    cursor.close()

# Initialize database on module import
init_db() 