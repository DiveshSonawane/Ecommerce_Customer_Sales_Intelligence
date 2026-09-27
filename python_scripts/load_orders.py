import pandas as pd
import mysql.connector

# ==========================================
# CONFIGURATION
# ==========================================

CSV_FILE = r"F:\Final Year Engineering\Ecommerce_Customer_Sales_Intelligence\data\olist_orders_dataset.csv"

DB_CONFIG = {
    "host": "localhost",
    "port": 3306,
    "user": "root",
    "password": "Diveshu@2908",
    "database": "ecommerce_analytics"
}

# ==========================================
# DATABASE CONNECTION
# ==========================================

connection = mysql.connector.connect(**DB_CONFIG)

cursor = connection.cursor()

print("Connected to MySQL successfully.")

# ==========================================
# CLEAR PARTIAL DATA
# ==========================================

#cursor.execute("TRUNCATE TABLE orders")
#connection.commit()

#print("Orders table cleared.")

# ==========================================
# LOAD CSV IN BATCHES
# ==========================================

chunk_size = 5000

for chunk in pd.read_csv(
    CSV_FILE,
    chunksize=chunk_size,
    parse_dates=[
        "order_purchase_timestamp",
        "order_approved_at",
        "order_delivered_carrier_date",
        "order_delivered_customer_date",
        "order_estimated_delivery_date"
    ]
):

    rows = []

    for _, row in chunk.iterrows():

        rows.append((
            row["order_id"],
            row["customer_id"],
            row["order_status"],
            None if pd.isna(row["order_purchase_timestamp"]) else row["order_purchase_timestamp"].to_pydatetime(),
            None if pd.isna(row["order_approved_at"]) else row["order_approved_at"].to_pydatetime(),
            None if pd.isna(row["order_delivered_carrier_date"]) else row["order_delivered_carrier_date"].to_pydatetime(),
            None if pd.isna(row["order_delivered_customer_date"]) else row["order_delivered_customer_date"].to_pydatetime(),
            None if pd.isna(row["order_estimated_delivery_date"]) else row["order_estimated_delivery_date"].to_pydatetime()
        ))

    cursor.executemany(
        """
        INSERT INTO orders (
            order_id,
            customer_id,
            order_status,
            order_purchase_timestamp,
            order_approved_at,
            order_delivered_carrier_date,
            order_delivered_customer_date,
            order_estimated_delivery_date
        )
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
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

print("Orders import completed successfully.")