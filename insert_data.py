import pandas as pd
from sqlalchemy import create_engine, text

DB_USER = "root"
DB_PASSWORD = ""        
DB_HOST = "127.0.0.1"
DB_PORT = "3306"
DB_NAME = "hotel_reviews"
# ---------------------------------------------------------

engine = create_engine(
    f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

print("Caricamento dataset.csv...")
df = pd.read_csv("dataset.csv", parse_dates=["Review_Date"])
print(f"Righe caricate: {len(df)}")

# =========================================================================
# 1. HOTELS
# Chiave univoca: hotel_name + hotel_address (verificato sul dataset reale
# che né l'uno né l'altro, presi singolarmente, sono garantiti unici)
# =========================================================================
hotels = df.drop_duplicates(subset=["Hotel_Name", "Hotel_Address"])[
    ["Hotel_Name", "Hotel_Address", "City", "lat", "lng", "Average_Score", "Total_Number_of_Reviews"]
].copy()
hotels.columns = ["hotel_name", "hotel_address", "city", "lat", "lng", "average_score", "total_number_of_reviews"]
hotels.to_sql("hotels", engine, if_exists="append", index=False, chunksize=1000)
print(f"Inserted {len(hotels)} hotels")

# Recupero della mappa (nome, indirizzo) -> hotel_id appena assegnato da MySQL
hotel_map = pd.read_sql("SELECT hotel_id, hotel_name, hotel_address FROM hotels", engine)
df = df.merge(
    hotel_map,
    left_on=["Hotel_Name", "Hotel_Address"],
    right_on=["hotel_name", "hotel_address"]
)

# =========================================================================
# 2. REVIEWERS
# Solo nazionalità uniche 
# =========================================================================
reviewers = df.drop_duplicates(subset=["Reviewer_Nationality"])[["Reviewer_Nationality"]].copy()
reviewers.columns = ["nationality"]
reviewers.to_sql("reviewers", engine, if_exists="append", index=False, chunksize=1000)
print(f"Inserted {len(reviewers)} reviewers")

reviewer_map = pd.read_sql("SELECT reviewer_id, nationality FROM reviewers", engine)
df = df.merge(reviewer_map, left_on="Reviewer_Nationality", right_on="nationality")

# =========================================================================
# 3. REVIEWS (515K righe, chunked)
# Nota: total_number_of_reviews_reviewer_has_given resta qui, non in
# reviewers, perché è specifica della singola recensione
# =========================================================================
reviews = df[[
    "hotel_id", "reviewer_id", "Total_Number_of_Reviews_Reviewer_Has_Given",
    "Review_Date", "Review_Year", "Review_Month",
    "Reviewer_Score", "Negative_Review", "Review_Total_Negative_Word_Counts",
    "Positive_Review", "Review_Total_Positive_Word_Counts", "Total_Review_Length",
    "days_since_review", "Tags"
]].copy()
reviews.columns = [
    "hotel_id", "reviewer_id", "total_number_of_reviews_reviewer_has_given",
    "review_date", "review_year", "review_month",
    "reviewer_score", "negative_review", "review_total_negative_word_counts",
    "positive_review", "review_total_positive_word_counts", "total_review_length",
    "days_since_review", "tags"
]
reviews.to_sql("reviews", engine, if_exists="append", index=False, chunksize=2000)
print(f"Inserted {len(reviews)} reviews")

# =========================================================================
# 4. HOTEL_STATS con una query di aggregazione lato SQL
# =========================================================================
with engine.begin() as conn:
    conn.execute(text("""
        INSERT INTO hotel_stats (hotel_id, computed_avg_reviewer_score, computed_review_count)
        SELECT hotel_id, AVG(reviewer_score), COUNT(*)
        FROM reviews
        GROUP BY hotel_id
    """))
print("hotel_stats populated")

print("\nPopolamento completato. Eseguite le verifiche in ANALYSIS_QUERIES.SQL (sezione iniziale).")