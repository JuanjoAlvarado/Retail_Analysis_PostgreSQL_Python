import pandas as pd
from sqlalchemy import create_engine
import matplotlib.pyplot as plt

## Connection to PostgreSQL
engine = create_engine(
    "postgresql+psycopg2://postgres:YOUR_PASSWORD@localhost:5432/YOUR_DB_NAME"
)

## Lectures
df_monthly = pd.read_sql(
    """
    SELECT *
    FROM 
    rpt.mv_monthly_sales_country 
    ORDER BY month;
    """,
    engine
)

df_rfm = pd.read_sql(
    """
    SELECT
    customer_key, r_score, f_score, m_score
    FROM 
    rpt.mv_rfm;
    """,
    engine 
)

df_pairs = pd.read_sql(
    """
    SELECT
    product_a_desc, product_b_desc, co_occur
    FROM
    rpt.basket_pairs
    ORDER BY co_occur DESC
    LIMIT 15;
    """,
    engine
)


## Graph: monthly global sales
df_global = df_monthly.groupby("month", as_index=False)["net_sales"].sum()
df_global["month"] = pd.to_datetime(df_global["month"])

plt.figure()
plt.plot(df_global["month"], df_global["net_sales"], marker="o")
plt.title("Net Sales by month")
plt.xlabel("Month")
plt.ylabel("Sales")
plt.xticks(rotation = 45)
plt.tight_layout()
plt.show()


## RFM Distribution (monetary vs frequency by scores)
rfm_plot = df_rfm.copy()
plt.figure()
plt.scatter(rfm_plot["f_score"], rfm_plot["m_score"], alpha=0.6, c="blue")
plt.title("RFM Map (f vs m)")
plt.xlabel("f-score")
plt.ylabel("m-score")
plt.tight_layout()
plt.show()


## Top product pairs
print(df_pairs.to_string(index=False))
