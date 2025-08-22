from fastapi import FastAPI

# Create a new FastAPI app
debug_app = FastAPI()

@debug_app.get("/")
def read_root():
    return {"message": "Debug app works"}

@debug_app.get("/test")
def test_endpoint():
    return {"message": "Test endpoint works"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(debug_app, host="0.0.0.0", port=8002)
