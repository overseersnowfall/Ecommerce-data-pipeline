import os
import logging
import pandas as pd
from datetime import datetime
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from pathlib import Path

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

# Base directory (project root)
BASE_DIR = Path(__file__).resolve().parent.parent # go two levels up to get to project root ecommerce-data-pipeline-project/
RAW_PATH = BASE_DIR / "data" / "raw" # redirect to ecommerce-data-pipeline-project/data/raw/

# ---------------------------------------------------
# Test connection
# ---------------------------------------------------
# def test_connection():
#     try:
#         with engine.connect() as connection:
#             result = connection.execute(text("SELECT 1"))
#             logging.info("Database connection successful.")
#     except Exception as e:
#         logging.error(f"Database connection failed: {e}")

def load_single_csv(file_path, table_name):
    try:
        starttime = datetime.now()
        logging.info(f"Loading file: {file_path}")

        df = pd.read_csv(file_path)

        # Optional but recommended
        df["load_timestamp"] = datetime.now()

        row_count = len(df)

        df.to_sql(
            name=table_name,
            con=engine,
            schema="bronze_layer",
            if_exists="replace",
            index=False
        )

        endtime = datetime.now()
        duration = (endtime - starttime).total_seconds()
        logging.info(f"Loaded {row_count} rows into bronze_layer.{table_name}")
        logging.info(f"Loading time: {duration:.2f} seconds")

    except Exception as e:
        logging.error(f"Failed to load {file_path}: {e}")

def main():
    logging.basicConfig(level=logging.INFO)

    #test_connection()

    for file in RAW_PATH.glob("*.csv"):
        # Extract clean table name
        table_name = file.stem
        table_name = table_name.replace("olist_", "")
        table_name = table_name.replace("_dataset", "")

        load_single_csv(file, table_name)


if __name__ == "__main__":
    main()