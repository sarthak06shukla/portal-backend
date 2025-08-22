from fastapi import FastAPI, HTTPException, Query, Depends, Body
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Optional, Dict, Any
from datetime import datetime
import sqlite3
from dateutil.parser import parse
from enum import Enum
from pydantic import BaseModel

from database import get_db, execute_query, execute_write

class CustomQuery(BaseModel):
    report: str
    columns: List[str]
    orderBy: Optional[str] = None
    orderDirection: Optional[str] = 'ASC'
    operation: Optional[str] = None

class ReportType(str, Enum):
    STOCK_PRICE = "stock_prices"
    FINANCIAL_METRICS = "financial_metrics"
    PERFORMANCE = "performance"
    DIVIDEND = "dividend"
    TECHNICAL_INDICATORS = "technical_indicators"
    PROFIT_REPORT = "profit_report"

# Initialize FastAPI app
app = FastAPI(
    title="NSE Stock Data API",
    description="""
    API for accessing NSE stock data including daily stock prices, financial metrics,
    performance metrics, and dividend information.
    
    Available endpoints:
    - `/`: This documentation
    - `/docs`: Swagger UI documentation
    - `/companies`: List of all companies
    - `/report-types`: List all available report types
    - `/reports/search`: Search reports with filters
    """,
    version="1.0.0"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:4200",
        "http://localhost:62644",
        "http://127.0.0.1:4200",
        "https://sarthak06shukla.github.io"
    ],
    allow_credentials=False,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
    expose_headers=["*"],
    max_age=86400,  # Cache preflight requests for 24 hours
)

class DeveloperQueryCreate(BaseModel):
    name: str
    variation_name: Optional[str] = None
    query: str
    # Always approved by default
    status: str = 'approved'

class DeveloperQueryUpdate(BaseModel):
    name: Optional[str] = None
    status: Optional[str] = None
    variation_name: Optional[str] = None

@app.post("/api/developer-queries", status_code=201)
def create_developer_query(query_data: DeveloperQueryCreate, db: sqlite3.Connection = Depends(get_db)):
    """
    Saves a new developer query to the database. All new queries are approved by default.
    """
    try:
        cursor = db.cursor()
        cursor.execute(
            "INSERT INTO developer_queries (name, variation_name, query, status) VALUES (?, ?, ?, ?)",
            (query_data.name, query_data.variation_name, query_data.query, query_data.status)
        )
        last_id = cursor.lastrowid
        db.commit()
        
        created_query = execute_query(
            db,
            "SELECT * FROM developer_queries WHERE id = ?",
            (last_id,)
        )
        if not created_query:
            raise HTTPException(status_code=500, detail="Failed to create and retrieve query.")
        return created_query[0]
    except sqlite3.Error as e:
        raise HTTPException(status_code=400, detail=f"Database error: {e}")

@app.get("/api/developer-queries/{query_id}")
def get_developer_query(query_id: int, db: sqlite3.Connection = Depends(get_db)):
    """
    Retrieves a single developer query by its ID.
    """
    query = execute_query(
        db,
        "SELECT id, name, variation_name, query, status, created_at FROM developer_queries WHERE id = ?",
        (query_id,)
    )
    if not query:
        raise HTTPException(status_code=404, detail="Query not found.")
    return query[0]

@app.put("/api/developer-queries/{query_id}")
def update_developer_query(query_id: int, query_data: DeveloperQueryUpdate, db: sqlite3.Connection = Depends(get_db)):
    """
    Updates a query's name, variation_name, and/or status. Used by developers to approve queries.
    """
    fields_to_update = []
    params = []

    if query_data.name:
        fields_to_update.append("name = ?")
        params.append(query_data.name)
    
    if query_data.status:
        fields_to_update.append("status = ?")
        params.append(query_data.status)

    if query_data.variation_name is not None:
        fields_to_update.append("variation_name = ?")
        params.append(query_data.variation_name)

    if not fields_to_update:
        raise HTTPException(status_code=400, detail="No fields to update.")

    params.append(query_id)

    try:
        execute_write(
            db,
            f"UPDATE developer_queries SET {', '.join(fields_to_update)} WHERE id = ?",
            tuple(params)
        )
        return get_developer_query(query_id, db)
    except sqlite3.Error as e:
        raise HTTPException(status_code=400, detail=f"Database error: {e}")

@app.get("/api/developer-queries")
def get_developer_queries(
    name: Optional[str] = None,
    variation_name: Optional[str] = None,
    status: Optional[str] = None,
    db: sqlite3.Connection = Depends(get_db)
):
    """
    Retrieves all saved developer queries, optionally filtered by name or status.
    """
    base_query = "SELECT id, name, variation_name, query, status, created_at FROM developer_queries"
    conditions = []
    params = []

    if name:
        conditions.append("name = ?")
        params.append(name)
    
    if variation_name:
        conditions.append("variation_name = ?")
        params.append(variation_name)

    if status:
        conditions.append("status = ?")
        params.append(status)

    if conditions:
        base_query += " WHERE " + " AND ".join(conditions)
    
    base_query += " ORDER BY created_at DESC, id DESC"
    
    return execute_query(db, base_query, tuple(params))

@app.get("/report-types")
def get_report_types(db: sqlite3.Connection = Depends(get_db)):
    """Get list of all available report types with their details"""
    report_types = execute_query(db, """
        SELECT 
            name as type,
            display_name as name,
            description,
            query_name
        FROM report_types
        ORDER BY name
    """)
    
    # Add column information to each report type
    for report_type in report_types:
        # If there's a query_name, get the query details
        if report_type.get("query_name"):
            query_info = execute_query(db, """
                SELECT query 
                FROM developer_queries 
                WHERE name = ? AND status = 'approved'
                ORDER BY created_at DESC, id DESC LIMIT 1
            """, (report_type["query_name"],))
            if query_info:
                report_type["query"] = query_info[0]["query"]
        
        # Get the table name for this report type
        table_info = execute_query(db, """
            SELECT table_name 
            FROM report_types 
            WHERE name = ?
        """, (report_type["type"],))
        
        if table_info:
            table_name = table_info[0]["table_name"]
            # Get column information
            columns = execute_query(db, """
                SELECT 
                    column_name as "key",
                    display_name as label,
                    data_type as type,
                    is_visible,
                    sort_order
                FROM column_configs
                WHERE table_name = ?
                AND is_visible = true
                ORDER BY sort_order
            """, (table_name,))
            
            report_type["columns"] = columns
    
    return report_types

@app.get("/")
def read_root():
    """Root endpoint showing API information"""
    return {
        "title": "NSE Stock Data API",
        "version": "1.0.0",
        "endpoints": {
            "documentation": "/docs",
            "companies": "/companies",
            "report_types": "/report-types",
            "reports_search": "/reports/search"
        }
    }

@app.get("/test")
def test_endpoint():
    """Test endpoint without database dependency"""
    return {"message": "Test endpoint works"}

@app.get("/companies")
def get_companies():
    """Get list of all companies - temporary without database"""
    return ["TCS", "Infosys", "Wipro"]  # Temporary hardcoded response

@app.get("/reports/search")
def search_reports(
    report_type: ReportType,
    companies: Optional[List[str]] = Query(None),
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    search_term: Optional[str] = None,
    db: sqlite3.Connection = Depends(get_db)
):
    """Search reports with filters"""
    # First check if there's a saved query for this report type
    query_info = execute_query(db, """
        SELECT dq.query 
        FROM report_types rt
        JOIN developer_queries dq ON rt.query_name = dq.name
        WHERE rt.name = ? AND dq.status = 'approved'
        ORDER BY dq.created_at DESC, dq.id DESC LIMIT 1
    """, (report_type.value,))
    
    if query_info:
        # Use the saved query
        try:
            base_query = query_info[0]["query"]
            # Determine company and date columns based on report type
            company_col = "company"
            date_col = "date"
            if report_type.value == "profit_report":
                company_col = "company_name"
                date_col = "period_end_dt"
            # If companies filter is present, wrap the query
            if companies:
                placeholders = ",".join(["?" for _ in companies])
                wrapped_query = f"SELECT * FROM ( {base_query} ) WHERE {company_col} IN ({placeholders})"
                params = list(companies)
                cursor = db.cursor()
                cursor.execute(wrapped_query, params)
            else:
                cursor = db.cursor()
                cursor.execute(base_query)
            columns = [desc[0] for desc in cursor.description]
            rows = cursor.fetchall()
            results = list(rows)  # rows is already a list of dicts
            return results
        except Exception as e:
            raise HTTPException(status_code=400, detail=str(e))
    
    # If no saved query, try to find ANY approved query that references the correct table
    table_result = execute_query(db, """
        SELECT table_name 
        FROM report_types 
        WHERE name = ?
    """, (report_type.value,))
    
    if not table_result:
        raise HTTPException(status_code=404, detail=f"Report type '{report_type}' not found")
    
    table_name = table_result[0]["table_name"]
    
    # Look for any approved query that contains this table name
    all_approved_queries = execute_query(db, """
        SELECT query 
        FROM developer_queries 
        WHERE status = 'approved'
        ORDER BY created_at DESC, id DESC
    """)
    
    # Find the first query that references our target table
    for query_data in all_approved_queries:
        query_text = query_data["query"].lower()
        # Check if the query contains our table name (simple but effective)
        if f"from {table_name.lower()}" in query_text or f"from `{table_name.lower()}`" in query_text:
            print(f"Found compatible query for table {table_name}: {query_data['query'][:100]}...")
            try:
                base_query = query_data["query"]
                # If companies filter is present, wrap the query
                company_col = "company"
                date_col = "date"
                if report_type.value == "profit_report":
                    company_col = "company_name"
                    date_col = "period_end_dt"
                if companies:
                    placeholders = ",".join(["?" for _ in companies])
                    wrapped_query = f"SELECT * FROM ( {base_query} ) WHERE {company_col} IN ({placeholders})"
                    params = list(companies)
                    cursor = db.cursor()
                    cursor.execute(wrapped_query, params)
                else:
                    cursor = db.cursor()
                    cursor.execute(base_query)
                columns = [desc[0] for desc in cursor.description]
                rows = cursor.fetchall()
                results = list(rows)
                print(f"Successfully executed query, returned {len(results)} rows")
                return results
            except Exception as e:
                # If this query fails, continue to the next one
                print(f"Query failed: {e}")
                continue
    
    print(f"No compatible queries found for table {table_name}, using default query")
    
    # If no approved query found, use the default table-based query
    # Determine company and date columns based on report type
    company_col = "company"
    date_col = "date"
    if report_type.value == "profit_report":
        company_col = "company_name"
        date_col = "period_end_dt"

    # Build query
    query = f"SELECT * FROM {table_name} WHERE 1=1"
    params = []
    
    if companies:
        placeholders = ",".join("?" * len(companies))
        query += f" AND {company_col} IN ({placeholders})"
        params.extend(companies)
    
    if start_date:
        query += f" AND {date_col} >= ?"
        params.append(start_date)
    
    if end_date:
        query += f" AND {date_col} <= ?"
        params.append(end_date)
    
    if search_term:
        query += f" AND ({company_col} LIKE ? OR CAST({date_col} AS TEXT) LIKE ?)"
        search_pattern = f"%{search_term}%"
        params.extend([search_pattern, search_pattern])
    
    query += f" ORDER BY {date_col} DESC, {company_col}"
    
    return execute_query(db, query, tuple(params)) 

@app.post("/api/run-query")
def run_query(
    query: str = Body(..., embed=True),
    db: sqlite3.Connection = Depends(get_db)
):
    """
    Execute a developer-provided SELECT query and return the results.
    Only SELECT queries are allowed for safety.
    """
    # Basic security: only allow SELECT queries
    if not query.strip().lower().startswith("select"):
        raise HTTPException(status_code=400, detail="Only SELECT queries are allowed.")
    try:
        cursor = db.cursor()
        cursor.execute(query)
        columns = [desc[0] for desc in cursor.description]
        rows = cursor.fetchall()
        results = list(rows)  # rows is already a list of dicts
        return {"columns": columns, "rows": results}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/api/custom-query")
def execute_custom_query(query_data: CustomQuery, db: sqlite3.Connection = Depends(get_db)):
    """
    Builds and executes a SQL query from a structured request.
    """
    # Basic validation
    if not query_data.columns:
        raise HTTPException(status_code=400, detail="At least one column must be selected.")

    # Sanitize table and column names to prevent SQL injection
    # For now, we assume the report name is a valid table name.
    # A better implementation would be to check against a whitelist of tables.
    table_name = query_data.report
    
    # Whitelist of allowed columns (can be fetched from db schema)
    # For now, this is a simple check
    c = db.execute(f"PRAGMA table_info({table_name})")
    allowed_columns = [row[1] for row in c.fetchall()]
    
    for col in query_data.columns:
        if col not in allowed_columns:
            raise HTTPException(status_code=400, detail=f"Invalid column name: {col}")

    columns_str = ", ".join(query_data.columns)
    
    sql = f"SELECT {columns_str} FROM {table_name}"

    if query_data.orderBy:
        if query_data.orderBy not in query_data.columns:
             raise HTTPException(status_code=400, detail="Order by column must be in selected columns.")
        direction = 'DESC' if query_data.orderDirection and query_data.orderDirection.upper() == 'DESC' else 'ASC'
        sql += f" ORDER BY {query_data.orderBy} {direction}"

    if query_data.operation:
        # Simple sanitization for operations like "LIMIT 10"
        if query_data.operation.upper().startswith("LIMIT"):
            try:
                limit = int(query_data.operation.split()[1])
                if limit > 0 and limit <= 1000: # set a max limit
                    sql += f" LIMIT {limit}"
                else:
                    raise HTTPException(status_code=400, detail="Invalid LIMIT value.")
            except (ValueError, IndexError):
                raise HTTPException(status_code=400, detail="Invalid LIMIT format.")
        else:
            raise HTTPException(status_code=400, detail="Unsupported operation.")
            
    try:
        results = execute_query(db, sql)
        return results
    except sqlite3.Error as e:
        raise HTTPException(status_code=400, detail=f"Database error: {e}")

@app.get("/api/run-saved-query")
def run_saved_query(
    name: Optional[str] = None, 
    id: Optional[int] = None, 
    db: sqlite3.Connection = Depends(get_db)
):
    """
    Executes a saved query, either by the latest approved query name or by a specific query ID.
    """
    query_info = None
    if id:
        query_info = execute_query(
            db,
            "SELECT query FROM developer_queries WHERE id = ? AND status = 'approved'",
            (id,)
        )
    elif name:
        query_info = execute_query(
            db,
            "SELECT query FROM developer_queries WHERE name = ? AND status = 'approved' ORDER BY created_at DESC, id DESC LIMIT 1",
            (name,)
        )
    
    if not query_info:
        if id:
            detail = f"No approved query found for id '{id}'"
        elif name:
            detail = f"No approved query found for name '{name}'"
        else:
            detail = "Query name or ID must be provided."
        raise HTTPException(status_code=404, detail=detail)

    query = query_info[0]["query"]
    if not query.strip().lower().startswith("select"):
        raise HTTPException(status_code=400, detail="Only SELECT queries are allowed.")
    try:
        cursor = db.cursor()
        cursor.execute(query)
        columns = [desc[0] for desc in cursor.description]
        rows = cursor.fetchall()
        results = list(rows)  # rows is already a list of dicts
        return {"columns": columns, "rows": results}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

class LinkQueryToReportRequest(BaseModel):
    report_type_name: str
    developer_query_name: str

@app.post("/api/link-query-to-report", status_code=200)
def link_query_to_report(
    link_request: LinkQueryToReportRequest, 
    db: sqlite3.Connection = Depends(get_db)
):
    """
    Links a developer query to a user-facing report type.
    """
    try:
        # Check if developer query exists
        dev_query = execute_query(db, "SELECT id FROM developer_queries WHERE name = ?", (link_request.developer_query_name,))
        if not dev_query:
            raise HTTPException(status_code=404, detail=f"Developer query '{link_request.developer_query_name}' not found.")

        # Check if report type exists
        report_type = execute_query(db, "SELECT name FROM report_types WHERE display_name = ?", (link_request.report_type_name,))
        if not report_type:
            raise HTTPException(status_code=404, detail=f"Report type '{link_request.report_type_name}' not found.")

        # Update the report_types table
        execute_write(
            db,
            "UPDATE report_types SET query_name = ? WHERE display_name = ?",
            (link_request.developer_query_name, link_request.report_type_name)
        )
        return {"message": f"Successfully linked '{link_request.developer_query_name}' to '{link_request.report_type_name}'."}
    except sqlite3.Error as e:
        raise HTTPException(status_code=400, detail=f"Database error: {e}")

@app.delete("/api/developer-queries/{query_id}")
def delete_developer_query(query_id: int, db: sqlite3.Connection = Depends(get_db)):
    """
    Deletes a developer query by its ID.
    """
    try:
        execute_write(db, "DELETE FROM developer_queries WHERE id = ?", (query_id,))
        return {"success": True}
    except sqlite3.Error as e:
        raise HTTPException(status_code=400, detail=f"Database error: {e}") 

@app.get("/api/queries-for-report/{report_type}")
def get_queries_for_report(
    report_type: str,
    db: sqlite3.Connection = Depends(get_db)
):
    """
    Get all approved queries that work with a specific report type by checking table references.
    """
    # Get the table name for this report type
    table_result = execute_query(db, """
        SELECT table_name 
        FROM report_types 
        WHERE name = ?
    """, (report_type,))
    
    if not table_result:
        raise HTTPException(status_code=404, detail=f"Report type '{report_type}' not found")
    
    table_name = table_result[0]["table_name"]
    
    # Get all approved queries
    all_approved_queries = execute_query(db, """
        SELECT id, name, variation_name, query, status, created_at
        FROM developer_queries 
        WHERE status = 'approved'
        ORDER BY created_at DESC, id DESC
    """)
    
    # Filter queries that reference our target table
    compatible_queries = []
    for query_data in all_approved_queries:
        query_text = query_data["query"].lower()
        # Check if the query contains our table name
        if f"from {table_name.lower()}" in query_text or f"from `{table_name.lower()}`" in query_text:
            compatible_queries.append(query_data)
    
    return compatible_queries

@app.get("/api/report-type-for-query/{query_name}")
def get_report_type_for_query(
    query_name: str,
    db: sqlite3.Connection = Depends(get_db)
):
    """
    Find the report type that corresponds to a given query name by analyzing the query's table references.
    """
    # Get the query by name
    query_info = execute_query(db, """
        SELECT query 
        FROM developer_queries 
        WHERE name = ? AND status = 'approved'
        ORDER BY created_at DESC, id DESC LIMIT 1
    """, (query_name,))
    
    if not query_info:
        raise HTTPException(status_code=404, detail=f"No approved query found with name '{query_name}'")
    
    query_text = query_info[0]["query"].lower()
    
    # Get all report types and their table names
    report_types = execute_query(db, """
        SELECT name, display_name, table_name
        FROM report_types
    """)
    
    # Find which report type's table is referenced in the query
    for report_type in report_types:
        table_name = report_type["table_name"].lower()
        if f"from {table_name}" in query_text or f"from `{table_name}`" in query_text:
            return {
                "report_type": report_type["name"],
                "display_name": report_type["display_name"],
                "table_name": report_type["table_name"],
                "query_name": query_name
            }
    
    raise HTTPException(status_code=404, detail=f"Could not determine report type for query '{query_name}'")  