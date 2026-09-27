import pandas as pd
import mysql.connector

# ==========================================
# CONFIGURATION
# ==========================================

CSV_FILE = r"F:\Final Year Engineering\Ecommerce_Customer_Sales_Intelligence\data\olist_order_payments_dataset.csv"

DB_CONFIG = {
    "host": "localhost",
    "port": 3306,
    "user": "root",
    "password": "Diveshu@2908",
    "database": "ecommerce_analytics"
}

# ==========================================
# CONNECT TO MYSQL
# ==========================================

connection = mysql.connector.connect(**DB_CONFIG)
cursor = connection.cursor()

print("Connected to MySQL successfully.")

# ==========================================
# LOAD CSV IN BATCHES
# ==========================================

chunk_size = 5000

for chunk in pd.read_csv(
    CSV_FILE,
    chunksize=chunk_size
):

    rows = []

    for _, row in chunk.iterrows():

        rows.append((
            row["order_id"],
            int(row["payment_sequential"]),
            row["payment_type"],
            int(row["payment_installments"]),
            float(row["payment_value"])
        ))

    cursor.executemany(
        """
        INSERT INTO order_payments (
            order_id,
            payment_sequential,
            payment_type,
            payment_installments,
            payment_value
        )
        VALUES (%s, %s, %s, %s, %s)
        """,
        rows
    )

    connection.commit()

    print(f"Loaded {len(rows)} rows...")

# ==========================================
# CLOSE CONNECTION
# ==========================================

cursor.close()
connection.close()

print("order_payments import completed successfully.")