import os
import logging
import pandas as pd
from datetime import datetime
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
import os
print("Current working directory:", os.getcwd())

# ---------------------------------------------------
# Load environment variables
# ---------------------------------------------------
load_dotenv()

DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")

# ---------------------------------------------------
# Setup logging
# ---------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

# ---------------------------------------------------
# Create PostgreSQL connection string
# ---------------------------------------------------
DATABASE_URL = (
    f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}"
    f"@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

engine = create_engine(DATABASE_URL)

# ---------------------------------------------------
# Test connection
# ---------------------------------------------------
def test_connection():
    try:
        with engine.connect() as connection:
            result = connection.execute(text("SELECT 1"))
            logging.info("Database connection successful.")
    except Exception as e:
        logging.error(f"Database connection failed: {e}")

def load_single_csv(file_path, table_name):
    try:
        logging.info(f"Loading file: {file_path}")

        df = pd.read_csv(file_path)

        # Optional but recommended
        df["load_timestamp"] = datetime.now()

        row_count = len(df)

        df.to_sql(
            name=table_name,
            con=engine,
            schema="bronze_layer",
            if_exists="append",
            index=False
        )

        logging.info(f"Loaded {row_count} rows into bronze_layer.{table_name}")

    except Exception as e:
        logging.error(f"Failed to load {file_path}: {e}")

if __name__ == "__main__":
    test_connection()

    file_path = "data/raw/olist_customers_dataset.csv"
    table_name = "olist_customers_dataset"

    load_single_csv(file_path, table_name)