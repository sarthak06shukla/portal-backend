from init_db import init_db
from seed_data import seed_data

def setup():
    print("Initializing database...")
    init_db()
    
    print("Seeding sample data...")
    seed_data()
    
    print("Setup completed successfully!")

if __name__ == "__main__":
    setup() 