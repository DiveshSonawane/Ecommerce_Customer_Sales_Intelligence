import pandas as pd
import mysql.connector

# ==========================================
# CONFIGURATION
# ==========================================

CSV_FILE = r"F:\Final Year Engineering\Ecommerce_Customer_Sales_Intelligence\data\olist_order_items_dataset.csv"

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

cursor.execute("SET FOREIGN_KEY_CHECKS = 0")

# ==========================================
# LOAD CSV IN BATCHES
# ==========================================

chunk_size = 5000

for chunk in pd.read_csv(
    CSV_FILE,
    chunksize=chunk_size,
    parse_dates=["shipping_limit_date"]
):

    rows = []

    for _, row in chunk.iterrows():

        rows.append((
            row["order_id"],
            int(row["order_item_id"]),
            row["product_id"],
            row["seller_id"],
            None if pd.isna(row["shipping_limit_date"])
            else row["shipping_limit_date"].to_pydatetime(),
            float(row["price"]),
            float(row["freight_value"])
        ))

    cursor.executemany(
        """
        INSERT INTO order_items (
            order_id,
            order_item_id,
            product_id,
            seller_id,
            shipping_limit_date,
            price,
            freight_value
        )
        VALUES (%s,%s,%s,%s,%s,%s,%s)
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

print("order_items import completed successfully.")