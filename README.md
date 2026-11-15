# ITBDA4-14 Big Data Analytics Project

This repository contains the functional scripts, datasets and outputs developed for Questions 1–4 of the project.

## Project Structure

### Question 1: Hadoop MapReduce Keyword Search

A Java-based Hadoop MapReduce application that searches news documents for a dynamically supplied keyword and returns the document, row and column of every occurrence.

**Main files:**
- `src/main/java/KeywordSearchMapper.java`
- `src/main/java/KeywordSearchReducer.java`
- `src/main/java/KeywordSearchDriver.java`
- `src/main/java/WholeFileInputFormat.java`
- `src/main/java/WholeFileRecordReader.java`
- `input/` news documents
- `pom.xml`

**Key features:**
- Dynamic keyword input
- Case-insensitive substring search
- Whole-document processing
- 1-based row and column reporting
- Hadoop local-mode execution

**Example:**

`mvn exec:java -Dexec.mainClass="KeywordSearchDriver" -Dexec.args="input output africa"`

---

### Question 2: LDA Topic Modelling

A Python Jupyter notebook that loads news documents into a dataframe, preprocesses the text and applies Latent Dirichlet Allocation.

**Main file:**
- `Question2_LDA/Question2_LDA.ipynb`

**Key features:**
- Dataframe containing file names and article content
- Text denoising and stop-word removal
- Three-topic LDA model
- Top-word weights and distributions
- Horizontal bar charts
- Topic word clouds

---

### Question 3: WebText API Proof of Concept

An R-based proof of concept that extracts web content, cleans it and applies two extractive summarisation methods.

**Main files:**
- `Question3_WebText_API/question3.R`
- `Question3_WebText_API/frequency_summary.txt`
- `Question3_WebText_API/lead_summary.txt`
- `Question3_WebText_API/top_word_frequencies.png`
- `Question3_WebText_API/summary_sentence_scores.png`

**Key features:**
- Web content extraction using base R
- HTML and web-noise removal
- Frequency-based extractive summarisation
- Lead-based extractive summarisation
- Word-frequency and sentence-score visualisations

---

### Question 4: Web Scraping, ETL and PostgreSQL

An R-based ETL process that scrapes quote records, converts the unstructured content into a dataframe, cleans the data and exports it for relational analysis.

**Main files:**
- `Question4_ETL/question4.R`
- `Question4_ETL/clean_quotes.csv`

**Key features:**
- Thirty records scraped from Quotes to Scrape
- Regex extraction of quotes, authors and tags
- Textual and numerical variables
- Missing-value treatment
- Duplicate removal
- CSV export
- PostgreSQL import and SQL analysis

## Technologies

- Java
- Apache Hadoop MapReduce
- Maven
- Python
- Jupyter Notebook
- pandas
- scikit-learn
- Matplotlib
- WordCloud
- R
- PostgreSQL
- GitHub Codespaces

## Author
Rendani Matumba
eduv4840155