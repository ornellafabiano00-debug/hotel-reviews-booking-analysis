-- =========================================================================
-- SCHEMA SQL PER IL DATABASE HOTEL REVIEWS (Booking.com)
-- Conforme ai punti 4.2.1, 4.2.2 e 4.2.3 delle Istruzioni del progetto
-- 4 tabelle richieste: hotels, reviewers, reviews, hotel_stats
-- =========================================================================

-- Rimozione preventiva delle tabelle se già esistenti (in ordine di dipendenza:
-- prima le tabelle "figlie" con foreign key verso altre tabelle, poi quelle "padri")
DROP TABLE IF EXISTS hotel_stats;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS reviewers;
DROP TABLE IF EXISTS hotels;

-- =========================================================================
-- 1. TABELLA HOTELS
-- Contiene una riga per ogni hotel unico (anagrafica), evitando di ripetere
-- indirizzo/coordinate/nome per ognuna delle 515K recensioni.
--
-- Vincolo di unicità: verificato sui dati reali che né hotel_name né
-- hotel_address, presi singolarmente, sono garantiti unici:
--   - 1.492 nomi unici (su 1.494 hotel reali) -> il nome "Hotel Regina"
--     è condiviso da 3 hotel indipendenti in 3 città diverse (Barcelona,
--     Vienna, Milan) - nome commerciale comune, non un duplicato dello
--     stesso hotel
--   - 1.493 indirizzi unici -> ma un indirizzo è condiviso da 2 nomi diversi
--     ("The Grand at Trafalgar Square" / "Club Quarters Hotel Trafalgar
--     Square", stesso edificio)
-- Per questo la chiave univoca è COMPOSTA su entrambi i campi insieme,
-- l'unica combinazione garantita unica dal dataset pulito nel notebook 01
-- (1.494 hotel realmente distinti).
CREATE TABLE hotels (
    hotel_id INT AUTO_INCREMENT PRIMARY KEY,
    hotel_name VARCHAR(255) NOT NULL,
    hotel_address VARCHAR(500) NOT NULL,
    city VARCHAR(100),
    lat DECIMAL(10, 6),
    lng DECIMAL(10, 6),
    average_score DECIMAL(3, 1),
    total_number_of_reviews INT,
    UNIQUE KEY uniq_hotel_name_address (hotel_name, hotel_address)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================================
-- 2. TABELLA REVIEWERS
-- Tabella anagrafica di sole nazionalità uniche (non del singolo utente:
-- il dataset Booking non fornisce un ID recensore reale, solo la nazionalità
-- dichiarata). Ogni nazionalità compare una sola volta -> UNIQUE corretto qui,
-- perché non contiene più nessun dato che varia da recensione a recensione.
-- =========================================================================
CREATE TABLE reviewers (
    reviewer_id INT AUTO_INCREMENT PRIMARY KEY,
    nationality VARCHAR(100),
    UNIQUE KEY uniq_nationality (nationality)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================================
-- 3. TABELLA REVIEWS
-- Una riga per ogni singola recensione (515.212 attese dopo il caricamento).
-- Collegata a hotels e reviewers tramite
-- foreign key. total_number_of_reviews_reviewer_has_given resta qui (non in
-- reviewers) perché è un dato specifico della singola recensione, non della
-- nazionalità in generale.
-- =========================================================================
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    hotel_id INT,
    reviewer_id INT,
    total_number_of_reviews_reviewer_has_given INT,
    review_date DATE,
    review_year INT,
    review_month INT,
    reviewer_score DECIMAL(3, 1),
    negative_review TEXT,
    review_total_negative_word_counts INT,
    positive_review TEXT,
    review_total_positive_word_counts INT,
    total_review_length INT,
    days_since_review INT,
    tags VARCHAR(500),
    CONSTRAINT fk_reviews_hotel FOREIGN KEY (hotel_id) REFERENCES hotels(hotel_id),
    CONSTRAINT fk_reviews_reviewer FOREIGN KEY (reviewer_id) REFERENCES reviewers(reviewer_id),
    -- Indici per velocizzare le query più frequenti richieste al punto 4.3
    INDEX idx_hotel (hotel_id),
    INDEX idx_reviewer (reviewer_id),
    INDEX idx_date (review_year, review_month)  -- query sui trend temporali (4.3.1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================================
-- 4. TABELLA HOTEL_STATS
-- Tabella derivata (non caricata dal CSV): verrà popolata con una query di
-- aggregazione su reviews, dopo aver inserito i dati. Evita di dover
-- ricalcolare AVG()/COUNT() su 515K righe ogni volta che serve la media
-- per hotel (es. per la query "gap tra Reviewer_Score e Average_Score",
-- punto 4.3.3).
-- =========================================================================
CREATE TABLE hotel_stats (
    hotel_id INT PRIMARY KEY,
    computed_avg_reviewer_score DECIMAL(4, 2),
    computed_review_count INT,
    CONSTRAINT fk_stats_hotel FOREIGN KEY (hotel_id) REFERENCES hotels(hotel_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;