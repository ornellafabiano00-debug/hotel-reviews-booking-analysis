-- ============================================================
-- INSERT_DATA.SQL - Esempio dimostrativo della struttura di popolamento
-- ============================================================
-- NOTA IMPORTANTE: questo file mostra la SINTASSI degli INSERT con alcune
-- righe di esempio reali tratte dal dataset, NON è usato per il popolamento
-- effettivo del database.
--
-- Con 515.212 recensioni, un file .sql con un INSERT per ogni riga
-- peserebbe circa 1 GB (verificato: 2154 caratteri medi per riga x 515.212
-- righe), superando i limiti di upload di phpMyAdmin, impraticabile da
-- eseguire riga per riga e troppo pesante per essere versionato su GitHub.
--
-- Il popolamento reale del database è eseguito da INSERT_DATA.PY, che usa
-- pandas.to_sql() per caricare i dati in batch da dataset.csv in modo
-- efficiente. Questo file serve solo a documentare la struttura attesa
-- degli inserimenti.
-- ============================================================


-- Esempio: popolamento HOTELS (3 hotel reali dal dataset)
INSERT INTO hotels (hotel_name, hotel_address, city, lat, lng, average_score, total_number_of_reviews)
VALUES
    ('Hotel Arena', 's Gravesandestraat 55 Oost 1092 AA Amsterdam Netherlands', 'Amsterdam', 52.360576, 4.915968, 7.7, 1403),
    ('The Grand at Trafalgar Square', '8 Northumberland Avenue Westminster Borough London WC2N 5BY United Kingdom', 'London', 51.506935, -0.126012, 8.3, 1592),
    ('Club Quarters Hotel Trafalgar Square', '8 Northumberland Avenue Westminster Borough London WC2N 5BY United Kingdom', 'London', 51.506935, -0.126012, 8.5, 2494);


-- Esempio: popolamento REVIEWERS (nazionalità uniche)
INSERT INTO reviewers (nationality)
VALUES
    ('Russia'),
    ('Ireland'),
    ('Australia'),
    ('United Kingdom');


-- Esempio: popolamento REVIEWS (recensioni collegate agli hotel/reviewer sopra)
-- Nota: hotel_id e reviewer_id fanno riferimento agli AUTO_INCREMENT generati
-- dalle INSERT precedenti (1, 2, 3 per hotels; 1, 2, 3, 4 per reviewers)
INSERT INTO reviews (
    hotel_id, reviewer_id, total_number_of_reviews_reviewer_has_given,
    review_date, review_year, review_month, reviewer_score,
    negative_review, review_total_negative_word_counts,
    positive_review, review_total_positive_word_counts,
    total_review_length, days_since_review, tags
)
VALUES
    (1, 1, 7, '2017-08-03', 2017, 8, 2.9,
     'I am so angry that i made this post available via all possible channels...', 397,
     'Only the park outside of the hotel was beautiful', 11,
     408, 0, ' Leisure trip , Couple , Duplex Double Room '),
    (1, 2, 105, '2017-08-03', 2017, 8, 7.5,
     'No Negative', 0,
     'No real complaints the hotel was great great location surroundings', 105,
     105, 0, ' Leisure trip , Couple , Duplex Double Room ');


-- Esempio: popolamento HOTEL_STATS (in produzione generato da query di
-- aggregazione su reviews, vedi INSERT_DATA.PY)
INSERT INTO hotel_stats (hotel_id, computed_avg_reviewer_score, computed_review_count)
VALUES
    (1, 5.20, 2);