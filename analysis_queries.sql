-- ============================================================
-- QUERY SQL - hotel_reviews
-- Eseguibili da phpMyAdmin
-- ============================================================


-- ============================================================
-- SEZIONE 1 - VERIFICHE POST-POPOLAMENTO (punto 4.2.3 delle istruzioni)
-- Da eseguire subito dopo insert_data.py, prima di procedere con l'analisi
-- ============================================================

-- 1.1 Conteggi righe per tabella
--
-- RISULTATO:
-- tabella       | n_righe
-- --------------|--------
-- hotels        | 1494
-- reviewers     | 227
-- reviews       | 515212
-- hotel_stats   | 1494
--
-- NOTA: delle 227 righe in reviewers, 226 sono nazionalità realmente dichiarate;
-- 1 riga è l'etichetta esplicita 'Not specified', assegnata alle 522 recensioni
-- (0.10% del totale) prive di nazionalità dichiarata nel file originale
-- (codificata come stringa vuota dopo la pulizia, non come NaN; 
-- vedi Notebook 01, sezione "Gestione missing values Reviewer_Nationality").
--
SELECT 'hotels' AS tabella, COUNT(*) AS n_righe FROM hotels
UNION ALL
SELECT 'reviewers', COUNT(*) FROM reviewers
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'hotel_stats', COUNT(*) FROM hotel_stats;

-- 1.2 join hotel reviews (controllo che la relazione funzioni, campione)
--
-- RISULTATO (prime righe):
-- hotel_name  | city      | reviewer_score | review_date
-- ------------|-----------|----------------|------------
-- Hotel Arena | Amsterdam | 2.9            | 2017-08-03
-- Hotel Arena | Amsterdam | 7.5            | 2017-08-03
-- Hotel Arena | Amsterdam | 7.1            | 2017-07-31
-- Hotel Arena | Amsterdam | 3.8            | 2017-07-31
-- Hotel Arena | Amsterdam | 6.7            | 2017-07-24
--
SELECT h.hotel_name, h.city, r.reviewer_score, r.review_date
FROM reviews r
JOIN hotels h ON r.hotel_id = h.hotel_id
LIMIT 10;

-- 1.3 Distribuzione score per nazionalità (controllo che il join reviewers funzioni)
--
-- RISULTATO (top 10):
-- nationality               | n_reviews | avg_score
-- --------------------------|-----------|----------
-- United Kingdom            | 245110    | 8.48654
-- United States of America  | 35349     | 8.78693
-- Australia                 | 21648     | 8.59251
-- Ireland                   | 14814     | 8.46395
-- United Arab Emirates      | 10229     | 7.87969
-- Saudi Arabia              | 8940      | 7.88414
-- Netherlands               | 8757      | 8.12657
-- Switzerland               | 8669      | 8.16198
-- Germany                   | 7929      | 8.13438
-- Canada                    | 7883      | 8.54823
--
SELECT rv.nationality, COUNT(*) AS n_reviews, AVG(r.reviewer_score) AS avg_score
FROM reviews r
JOIN reviewers rv ON r.reviewer_id = rv.reviewer_id
GROUP BY rv.nationality
ORDER BY n_reviews DESC
LIMIT 10;


-- ============================================================
-- SEZIONE 2 - QUERY DI ANALISI (punto 4.3 delle istruzioni)
-- ============================================================

-- 4.3.1 Recensioni nel Tempo
--
-- 4.3.1.1 Andamento recensioni mese e anno
--
-- RISULTATO:
-- Copre da agosto 2015 ad agosto 2017.
-- Volume oscilla tra ~18K e ~27K recensioni/mese, con picco a luglio-agosto
-- 2016 (25.865 e 27.252) - probabile stagionalità estiva del turismo europeo.
-- Agosto 2017 più basso (4.076) perché il dataset si interrompe a metà mese.
--
-- review_month | review_year | n_reviews
-- -------------|-------------|----------
-- 8            | 2015        | 19287
-- 9            | 2015        | 19689
-- 10           | 2015        | 19449
-- 11           | 2015        | 18039
-- 12           | 2015        | 17914
-- 1            | 2016        | 19496
-- 2            | 2016        | 18836
-- 3            | 2016        | 20722
-- 4            | 2016        | 21471
-- 5            | 2016        | 23055
-- 6            | 2016        | 20920
-- 7            | 2016        | 25865
-- 8            | 2016        | 27252
-- 9            | 2016        | 22652
-- 10           | 2016        | 24324
-- 11           | 2016        | 17900
-- 12           | 2016        | 21660
-- 1            | 2017        | 22625
-- 2            | 2017        | 19501
-- 3            | 2017        | 20353
-- 4            | 2017        | 21386
-- 5            | 2017        | 23402
-- 6            | 2017        | 21936
-- 7            | 2017        | 23402
-- 8            | 2017        | 4076
--
SELECT review_month, review_year, COUNT(*) AS n_reviews
FROM reviews
GROUP BY review_year, review_month
ORDER BY review_year, review_month;

-- 4.3.1.2 Hotel con picco di recensioni
--
-- RISULTATO (top 10):
-- hotel_name                                 | mese | anno | n_reviews
-- -------------------------------------------|------|------|----------
-- Strand Palace Hotel                        | 2    | 2016 | 304
-- Intercontinental London The O2             | 4    | 2016 | 278
-- Strand Palace Hotel                        | 3    | 2016 | 267
-- Britannia International Hotel Canary Wharf | 11   | 2015 | 258
-- Park Plaza Westminster Bridge London       | 8    | 2016 | 257
-- Britannia International Hotel Canary Wharf | 5    | 2017 | 248
-- Strand Palace Hotel                        | 1    | 2016 | 242
-- Britannia International Hotel Canary Wharf | 3    | 2017 | 241
-- Britannia International Hotel Canary Wharf | 6    | 2017 | 239
-- Britannia International Hotel Canary Wharf | 5    | 2016 | 239
--
-- Nota: tutti i 10 hotel con picco sono a Londra 
-- (coerente con il volume complessivo più alto).
--
SELECT h.hotel_name, r.review_month, r.review_year, COUNT(*) AS n_reviews
FROM reviews r JOIN hotels h ON r.hotel_id = h.hotel_id
GROUP BY h.hotel_name, r.review_year, r.review_month
ORDER BY n_reviews DESC
LIMIT 10;

-- 4.3.2 Nazionalità Recensori
-- 4.3.2.1 Top 10 nazionalità per numero recensioni e score medio
--
-- RISULTATO: identico alla verifica 1.3 (stessa query)
-- UK in testa con 245.110 recensioni (8.49 medio).
--
-- nationality               | n_reviews | avg_score
-- --------------------------|-----------|----------
-- United Kingdom            | 245110    | 8.48654
-- United States of America  | 35349     | 8.78693
-- Australia                 | 21648     | 8.59251
-- Ireland                   | 14814     | 8.46395
-- United Arab Emirates      | 10229     | 7.87969
-- Saudi Arabia              | 8940      | 7.88414
-- Netherlands               | 8757      | 8.12657
-- Switzerland               | 8669      | 8.16198
-- Germany                   | 7929      | 8.13438
-- Canada                    | 7883      | 8.54823
--
SELECT rv.nationality, COUNT(*) AS n_reviews, AVG(r.reviewer_score) AS avg_score
FROM reviews r JOIN reviewers rv ON r.reviewer_id = rv.reviewer_id
GROUP BY rv.nationality
ORDER BY n_reviews DESC
LIMIT 10;

-- 4.3.2.2 % contributo delle top nazionalità sul totale recensioni
--
-- RISULTATO:
-- nationality               | n_reviews | pct_of_total
-- --------------------------|-----------|-------------
-- United Kingdom            | 245110    | 47.57459
-- United States of America  | 35349     | 6.86106
-- Australia                 | 21648     | 4.20177
-- Ireland                   | 14814     | 2.87532
-- United Arab Emirates      | 10229     | 1.98540
-- Saudi Arabia              | 8940      | 1.73521
-- Netherlands               | 8757      | 1.69969
-- Switzerland               | 8669      | 1.68261
-- Germany                   | 7929      | 1.53898
-- Canada                    | 7883      | 1.53005
--
-- Insight chiave per il report: il Regno Unito da solo genera quasi la metà
-- (47.6%) di tutte le recensioni del dataset - le altre 9 nazionalità top
-- sommate insieme (24.1%) non arrivano al peso di UK da sola. 
--
SELECT rv.nationality,
       COUNT(*) AS n_reviews,
       100.0 * COUNT(*) / (SELECT COUNT(*) FROM reviews) AS pct_of_total
FROM reviews r JOIN reviewers rv ON r.reviewer_id = rv.reviewer_id
GROUP BY rv.nationality
ORDER BY n_reviews DESC
LIMIT 10;

-- 4.3.2.3 Confronto score medio UK vs altri
--
-- Aggiornamento:
-- NOTA STORICA: nella prima versione del caricamento, la
-- colonna reviewers.nationality conteneva spazi bianchi extra intorno ai
-- valori (es. " United Kingdom " invece di "United Kingdom", 16 caratteri
-- anziché i 14 attesi - verificato con LENGTH()). Il problema causava il
-- fallimento dei confronti esatti di stringa (la CASE di questa query
-- restituiva una sola riga "Altri" per tutte le 515K recensioni).
--
-- Soluzione tampone applicata all'epoca: UPDATE reviewers SET nationality = TRIM(nationality);
-- Soluzione definitiva: pulizia con .str.strip() spostata alla fonte, nella
-- fase di cleaning del notebook 01 (prima del salvataggio di dataset.csv),
-- così il database viene popolato con dati già puliti e nessun TRIM
-- correttivo è più necessario.
--
-- RISULTATO:
-- gruppo | avg_score | n_reviews
-- -------|-----------|----------
-- Altri  | 8.31294   | 270102
-- UK     | 8.48654   | 245110
--
-- Insight: i recensori UK danno voti leggermente piu generosi della media
-- (8.49 vs 8.31)
--
SELECT
    CASE WHEN rv.nationality = 'United Kingdom' THEN 'UK' ELSE 'Altri' END AS gruppo,
    AVG(r.reviewer_score) AS avg_score,
    COUNT(*) AS n_reviews
FROM reviews r JOIN reviewers rv ON r.reviewer_id = rv.reviewer_id
GROUP BY gruppo;

-- 4.3.3 Hotel e Performance
-- 4.3.3.1 Hotel con maggior Average_Score e numero recensioni
--
-- RISULTATO (top 10):
-- hotel_name                        | average_score  | total_number_of_reviews
-- ----------------------------------|----------------|------------------------
-- Ritz Paris                        | 9.8            | 122
-- Hotel Casa Camper                 | 9.6            | 732
-- Hotel The Serras                  | 9.6            | 604
-- H10 Casa Mimosa 4 Sup             | 9.6            | 454
-- Haymarket Hotel                   | 9.6            | 255
-- 41                                | 9.6            | 244
-- Hotel de la Tamise Esprit de France | 9.6          | 166
-- Hotel Sacher Wien                 | 9.5            | 632
-- Waldorf Astoria Amsterdam         | 9.5            | 443
-- The Soho Hotel                    | 9.5            | 385
--
-- Nota qualità dati: nessun hotel in classifica ha una base recensioni
-- statisticamente fragile (minimo 122, la maggior parte 200+)
--
SELECT hotel_name, average_score, total_number_of_reviews
FROM hotels
ORDER BY average_score DESC, total_number_of_reviews DESC
LIMIT 10;

-- 4.3.3.2 Analisi gap tra Reviewer_Score medio calcolato e Average_Score dichiarato
--
-- RISULTATO (top 10 per gap assoluto):
-- hotel_name                                | average_score  | computed_avg | gap
-- ------------------------------------------|----------------|--------------|------
-- Kube Hotel Ice Bar                        | 7.2            | 5.85         | -1.35
-- Villa Eugenie                             | 6.8            | 5.86         | -0.94
-- MARQUIS Faubourg St Honore Relais Chateaux| 8.6            | 7.73         | -0.87
-- Holiday Inn Paris Montparnasse Pasteur    | 7.1            | 6.33         | -0.77
-- Best Western Hotel Astoria                | 7.7            | 8.46         | +0.76
-- Best Western Allegro Nation               | 7.8            | 7.06         | -0.74
-- Hotel Gallitzinberg                       | 8.6            | 7.88         | -0.72
-- Hotel La Spezia Gruppo MiniHotel          | 8.4            | 7.71         | -0.69
-- Renaissance Paris Vendome Hotel           | 7.9            | 8.58         | +0.68
-- Mercure Paris Porte d Orleans             | 7.5            | 8.18         | +0.68
--
-- Interpretazione: quasi tutti gli hotel in classifica hanno un punteggio
-- reale dei recensori più basso di quello mostrato da Booking come
-- "Average_Score". Possibile spiegazione: Booking calcola l'Average_Score
-- solo sulle recensioni dell'ultimo anno, mentre il nostro dato copre 2-3
-- anni (2015-2017). Se un hotel è peggiorato nel tempo, le recensioni più
-- vecchie nel nostro dataset alzano la media rispetto al dato più recente
-- di Booking - o viceversa, se è migliorato.
--
SELECT h.hotel_name, h.average_score,
       hs.computed_avg_reviewer_score,
       hs.computed_avg_reviewer_score - h.average_score AS gap
FROM hotel_stats hs JOIN hotels h ON hs.hotel_id = h.hotel_id
ORDER BY ABS(gap) DESC
LIMIT 10;

-- 4.3.4 Geografia
-- 4.3.4.1 Distribuzione recensioni per città
--
-- RISULTATO:
-- city      | n_reviews
-- ----------|----------
-- London    | 262298
-- Barcelona | 60149
-- Paris     | 59413
-- Amsterdam | 57211
-- Vienna    | 38937
-- Milan     | 37204
--
-- Coerente al 100% con i conteggi ottenuti in pandas nel notebook 01
-- (colonna City)
--
SELECT h.city, COUNT(*) AS n_reviews
FROM reviews r JOIN hotels h ON r.hotel_id = h.hotel_id
GROUP BY h.city
ORDER BY n_reviews DESC;

-- 4.3.4.2 Score medio per nazione, top città
-- In pratica: Score medio per città (top per qualità percepita)
-- RISULTATO:
-- city      | avg_score | n_reviews
-- ----------|-----------|----------
-- Barcelona | 8.55409   | 60149
-- Vienna    | 8.54504   | 38937
-- Amsterdam | 8.45623   | 57211
-- Paris     | 8.42440   | 59413
-- Milan     | 8.34668   | 37204
-- London    | 8.32413   | 262298
--
-- Insight per il report: Barcelona e Vienna sono le città con la qualita
-- percepita piu alta, London è ultima nonostante il volume di recensioni
-- di gran lunga maggiore (262K vs 37-60K delle altre). 
--
SELECT h.city, AVG(r.reviewer_score) AS avg_score, COUNT(*) AS n_reviews
FROM reviews r JOIN hotels h ON r.hotel_id = h.hotel_id
GROUP BY h.city
ORDER BY avg_score DESC;

-- 4.3.5 Lunghezza Recensioni
-- 4.3.5.1 Distribuzione lunghezza recensione per categoria di score
--
-- RISULTATO:
-- score_category | avg_length | n_reviews
-- ----------------|------------|----------
-- Basso           | 55.5256    | 22232
-- Medio           | 47.4993    | 64485
-- Buono           | 36.3016    | 181668
-- Ottimo          | 31.6811    | 246827
--
-- Insight per il report: le recensioni negative sono in media più lunghe
-- di quelle positive (55.5 parole contro 31.7). Chi è insoddisfatto tende
-- a spiegare più nel dettaglio cosa non ha funzionato, mentre chi è
-- soddisfatto scrive commenti brevi tipo "tutto ok" o "bellissimo".
--
SELECT
    CASE
        WHEN reviewer_score < 5 THEN 'Basso'
        WHEN reviewer_score < 7 THEN 'Medio'
        WHEN reviewer_score < 9 THEN 'Buono'
        ELSE 'Ottimo'
    END AS score_category,
    AVG(total_review_length) AS avg_length,
    COUNT(*) AS n_reviews
FROM reviews
GROUP BY score_category;

-- 4.3.5.2 Correlazione lunghezza recensione vs Reviewer_Score
--
-- Nota: MySQL non offre una funzione CORR() nativa (a differenza di PostgreSQL/Oracle),
-- ma la correlazione di Pearson è calcolabile con la formula esplicita usando solo
-- SUM/COUNT. Risultato verificato identico a quello calcolato in pandas (-0,168362).
--
-- RISULTATO:
-- pearson_correlation
-- --------------------
-- -0.16836242961232345
--
SELECT
    (COUNT(*) * SUM(total_review_length * reviewer_score) - SUM(total_review_length) * SUM(reviewer_score))
    /
    SQRT(
        (COUNT(*) * SUM(total_review_length * total_review_length) - POW(SUM(total_review_length), 2))
        *
        (COUNT(*) * SUM(reviewer_score * reviewer_score) - POW(SUM(reviewer_score), 2))
    ) AS pearson_correlation
FROM reviews;