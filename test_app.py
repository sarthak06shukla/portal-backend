# Import the app from main
from main2 import app

# Print all registered routes
print("Registered routes:")
for route in app.routes:
    print(f"  {route.methods} {route.path}")

# Test if the app has the expected routes
root_routes = [route for route in app.routes if route.path == "/"]
print(f"\nRoot routes found: {len(root_routes)}")

report_types_routes = [route for route in app.routes if route.path == "/report-types"]
print(f"Report-types routes found: {len(report_types_routes)}")

api_routes = [route for route in app.routes if route.path.startswith("/api/")]
print(f"API routes found: {len(api_routes)}")
