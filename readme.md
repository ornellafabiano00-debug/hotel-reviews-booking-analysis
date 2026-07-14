Premi `Ctrl+Shift+V` per la visualizzazione del Markdown formattato

# Hotel Reviews: Booking.com

Analisi di 515.212 recensioni di 1.494 hotel in 6 città europee<br>
(Amsterdam, Barcelona, London, Milan, Paris, Vienna),<br>
estratte da Booking.com (2015-2017).<br>
L'obiettivo è di identificare pattern nel comportamento dei recensori,<br> 
differenze di performance tra hotel e città europee<br> 
e correlazioni utili a supportare decisioni di revenue management nel settore turistico.

## Struttura del progetto

```
PROJECT/
├── dataset.csv                      # dataset pulito per analisi (generato da 01_EDA_CLEANING.ipynb)
├── 01_eda_cleaning.ipynb            # pulizia dati + variabili derivate
├── 02_analysis_pandas_plots.ipynb   # analisi pandas + 8 grafici
├── create_tables.sql                # schema database (4 tabelle)
├── insert_data.py                   # popolamento reale del database (Python)
├── insert_data.sql                  # dati
├── analysis_queries.sql             # verifiche + 10 query di analisi
├── final_report.pdf                 # report finale
└── readme.md
```

## Setup

### Ambiente di sviluppo

- **VS Code** con Python 3 ed estensione Jupyter
- **MySQL** (Docker Desktop + Devilbox, phpMyAdmin su `localhost`)

- **Librerie Python**:<br>
**Pandas:** Manipolazione e analisi dei Dati<br>
**NumPy:** Calcolo scientifico e matematico<br>
**Matplotlib:** Creazione di grafici e visualizzazione dati<br>
**SQLAlchemy / PyMySQL:** Connessione Python-MySQL per il popolamento del database

### Dataset originale

Il file `Hotel_Reviews.csv` (~238 MB) non è incluso nel repository per motivi di dimensione.<br>
Scaricare da [Kaggle](https://www.kaggle.com/datasets/jiashenliu/515k-hotel-reviews-data-in-europe/data) e posizionarlo nella root del progetto, insieme ai notebook.

> **Nota sul nome del file**:<br>
> le istruzioni del progetto citano al punto 4.1.4 il nome `hotel_reviews_clean.csv`,<br>
> ma la struttura file richiesta al punto 5 indica `dataset.csv`.<br>
> Si è seguita quest'ultima, essendo la struttura di consegna definitiva.
>
> **Nota su Git LFS**:<br>
> `dataset.csv` (~246 MB) supera il limite di 100 MB per singolo file di GitHub ed è gestito con [Git LFS](https://git-lfs.com/).<br>
> Per clonare il repository, installare Git LFS (`git lfs install`) **prima** di eseguire `git clone`

### Notebook 1 — Pulizia dati

Eseguire `01_EDA_CLEANING.ipynb` dall'inizio alla fine.<br>
Al termine genera, come da istruzioni, `dataset.csv`: 515.212 righe pulite, con variabili derivate<br>
(`City`, `Score_Category`, `Total_Review_Length`, ecc.),<br> 
pronte sia per il database sia per l'analisi pandas.

### Database MySQL

Il progetto usa MySQL (via Docker Desktop / Devilbox + phpMyAdmin nell'ambiente di sviluppo originale,<br>
ma funziona con qualunque installazione MySQL standard).

1. In phpMyAdmin (o client MySQL a scelta), creare un database vuoto chiamato `hotel_reviews` (charset `utf8mb4`)
2. Eseguire il contenuto di `create_tables.sql` su quel database<br>
e si creano le 4 tabelle (`hotels`, `reviewers`, `reviews`, `hotel_stats`) con i relativi vincoli e indici
3. Aprire `insert_data.py`<br>
e aggiornare le variabili di connessione all'inizio del file con le credenziali del **tuo** ambiente MySQL<br>
(i valori già presenti sono quelli usati nell'ambiente di sviluppo originale e vanno adattati se il tuo setup è diverso).

Esempio:
```python
DB_USER = "root"
DB_PASSWORD = ""
DB_HOST = "127.0.0.1"
DB_PORT = "3306"
DB_NAME = "hotel_reviews"
```

4. Eseguire lo script dal terminale integrato di VS Code:
```bash
py insert_data.py
```
(oppure `python insert_data.py`
varia a seconda del comando riconosciuto dal tuo sistema)


Questo comando popola le 4 tabelle a partire da `dataset.csv` (qualche minuto per 515K righe)<br>
e stampa i conteggi di verifica al termine (attesi: 1.494 hotels, 227 reviewers, 515.212 reviews, 1.494 hotel_stats).


> **Nota su `insert_data.sql`**: con 515K recensioni, un file `.sql` con un `INSERT` per riga peserebbe circa 1 GB,<br>
impraticabile da caricare in phpMyAdmin ed eccessivo per un repository Git.<br>
`insert_data.sql` contiene quindi solo alcune righe di esempio, a scopo dimostrativo della sintassi;<br>
il popolamento reale avviene sempre tramite `insert_data.py`.

### Query di analisi

Le query in `analysis_queries.sql` sono organizzate in due sezioni:
- **Sezione 1**: verifiche post-popolamento<br>
(conteggi righe, join hotel reviews, distribuzione score per nazionalità)
- **Sezione 2**: le 11 query di analisi richieste

Eseguibili una alla volta dalla tab SQL di phpMyAdmin.

### Notebook 2 — Analisi pandas e grafici

Eseguire `02_ANALYSIS_PANDAS_PLOTS.ipynb`<br>
(richiede `dataset.csv` generato/scaricato al passo precedente "Notebook 1).<br>
Riproduce le analisi SQL principali con pandas, le confronta con i risultati SQL,<br>
aggiunge feature engineering (sentiment base da word counts, cluster città per score)<br>
e genera gli 8 grafici obbligatori salvati in PNG.

### Report finale

`FINAL_REPORT.pdf` raccoglie metodologia, risultati e conclusioni, con i grafici generati nel Notebook 2

## 📐 Note metodologiche principali

- **Chiave univoca hotel**:<br>
la tabella `hotels` usa una chiave composta (`hotel_name` + `hotel_address`) invece del solo nome,<br>
perché verificato che né l'uno né l'altro singolarmente identificano un hotel in modo univoco<br>
(es. il nome "Hotel Regina" è condiviso da 3 hotel indipendenti in 3 città diverse;<br>
un indirizzo a Londra è condiviso da 2 hotel con nomi diversi).
- **Categorizzazione dello score**:<br>
`Score_Category` usa intervalli chiusi a sinistra (`right=False` in `pandas.cut`)<br>
per allinearsi esattamente alla logica delle query SQL (`WHEN score < 5...`).
- **Missing values geografici**:<br>
le coordinate mancanti (lat/lng) non erano distribuite a caso tra tutte le recensioni,<br>
ma concentrate esclusivamente su 17 hotel specifici (un pattern sistematico e non casuale).<br>
Per questo si è scelto di recuperare e imputare manualmente le coordinate reali di questi 17 hotel,<br>
invece di eliminare le righe con `.dropna()`, che avrebbe introdotto un bias geografico escludendo sistematicamente proprio<br> quegli hotel dalle analisi.<br>
- **Missing values nazionalità**:<br>
La colonna `Reviewer_Nationality` presenta 522 valori mancanti (0,10% del dataset), distribuiti in modo casuale su tutte le città (nessuna concentrazione su hotel specifici, a differenza del caso lat/lng).<br>
Nel file originale questi valori sono codificati come un singolo carattere spazio, non come `NaN`.<br>
Non essendo un dato ricostruibile da altre colonne (è auto-dichiarato dal recensore), si è scelto di etichettarlo esplicitamente come `'Not specified'` invece di lasciarlo vuoto o eliminarlo, per mantenere tracciabile il missing nelle analisi sulle nazionalità senza introdurre un valore non corretto.

## 💡 Sintesi dei Risultati
* **Volume vs Qualità:**<br>
Londra raccoglie il 50,9% delle recensioni, ma registra il punteggio medio più basso (8,32), mentre Barcellona e Vienna guidano la qualità percepita (8,55).
* **Lunghezza dei commenti:**<br>
Chi è insoddisfatto tende a motivare di più: le recensioni negative sono in media il 75% più lunghe di quelle ottime (55,5 vs 31,7 parole).
* **Voto vs Sentiment:**<br>
C'è un bias positivo nei voti numerici: l'analisi del sentiment testuale mostra che quasi la metà delle recensioni (44%) esprime testualmente più critiche che elogi.


## Autore
Ornella Fabiano
