# QUESTION 3.1 AND 3.2
url <- "https://en.wikipedia.org/wiki/Natural_language_processing?printable=yes"

html_file <- tempfile(fileext = ".html")
download.file(url, html_file, method = "libcurl", quiet = TRUE)

html <- paste(
  readLines(html_file, warn = FALSE, encoding = "UTF-8"),
  collapse = " "
)

#main article area 
article <- sub(
  ".*<div[^>]+class=\"[^\"]*mw-parser-output[^\"]*\"[^>]*>",
  "",
  html,
  perl = TRUE
)

#remove references/footer content
article <- sub(
  "<div[^>]+class=\"[^\"]*printfooter[^\"]*\".*",
  "",
  article,
  perl = TRUE
)

#remove scripts, styles and HTML tags
article <- gsub("<script[^>]*>.*?</script>", " ", article,
                ignore.case = TRUE, perl = TRUE)
article <- gsub("<style[^>]*>.*?</style>", " ", article,
                ignore.case = TRUE, perl = TRUE)
article <- gsub("<[^>]+>", " ", article)

#decode common HTML entities
article <- gsub("&nbsp;|&#160;", " ", article)
article <- gsub("&amp;", " and ", article)
article <- gsub("&quot;|&#34;", "\"", article)
article <- gsub("&#39;|&apos;", "'", article)

#basic cleaning
clean_text <- tolower(article)
clean_text <- gsub("https?://\\S+|www\\.\\S+", " ", clean_text)
clean_text <- gsub("[^a-z[:space:]]", " ", clean_text)
clean_text <- gsub("\\s+", " ", clean_text)
clean_text <- trimws(clean_text)

#R data structure
web_data <- data.frame(
  url = url,
  content = article,
  clean_content = clean_text,
  stringsAsFactors = FALSE
)

#remove Wikipedia maintenance text before the actual article begins
start_pos <- regexpr(
  "natural language processing \\(nlp\\)|natural language processing is",
  clean_text,
  ignore.case = TRUE
)

if (start_pos > 0) {
  clean_text <- substr(
    clean_text,
    start_pos,
    nchar(clean_text)
  )
}

#analysis noise
noise <- c(
  "citation needed",
  "edit source",
  "references",
  "external links",
  "see also"
)

for (x in noise) {
  clean_text <- gsub(
    paste0("\\b", x, "\\b"),
    " ",
    clean_text
  )
}

clean_text <- gsub("\\s+", " ", clean_text)
clean_text <- trimws(clean_text)

web_data$clean_content <- clean_text

cat(
  "Final cleaned characters:",
  nchar(web_data$clean_content),
  "\n\n"
)

cat(substr(web_data$clean_content, 1, 700))

#output
cat("Rows:", nrow(web_data), "\n")
cat("Clean characters:", nchar(web_data$clean_content), "\n\n")
cat(substr(web_data$clean_content, 1, 800))



# QUESTION 3.3 - SUMMARISATION 1

#divide original article into sentences
sentences <- unlist(strsplit(
  web_data$content,
  "(?<=[.!?])\\s+",
  perl = TRUE
))

sentences <- trimws(sentences)
sentences <- sentences[nchar(sentences) > 50]

#word frequencies from cleaned text
words <- unlist(strsplit(web_data$clean_content, "\\s+"))

stop_words <- c(
  "the","and","for","that","with","this","from","are","was",
  "were","have","has","had","not","but","can","into","its",
  "also","such","which","their","they","been","being","about"
)

words <- words[
  nchar(words) > 2 &
  !(words %in% stop_words)
]

word_freq <- sort(table(words), decreasing = TRUE)

#score per sentence
score_sentence <- function(sentence) {
  sent_words <- unlist(strsplit(
    tolower(gsub("[^a-z ]", " ", sentence)),
    "\\s+"
  ))

  sum(word_freq[sent_words], na.rm = TRUE)
}

scores <- sapply(sentences, score_sentence)

#top five sentences
top_indices <- order(scores, decreasing = TRUE)[1:5]
summary_frequency <- sentences[sort(top_indices)]

cat("\n\n--- FREQUENCY-BASED SUMMARY ---\n")
cat(paste(summary_frequency, collapse = "\n\n"))


# QUESTION 3.3 - Summarisation 2 

#substantive sentences
lead_sentences <- sentences[nchar(sentences) > 80]

#first 5 substantive sentences
summary_lead <- head(lead_sentences, 5)

cat("\n\n--- LEAD-BASED SUMMARY ---\n")
cat(paste(summary_lead, collapse = "\n\n"))



#text files for ducumentation
writeLines(
  c(
    "TECHNIQUE 1: FREQUENCY-BASED EXTRACTIVE SUMMARY",
    "===============================================",
    "",
    summary_frequency
  ),
  "frequency_summary.txt"
)

writeLines(
  c(
    "TECHNIQUE 2: LEAD-BASED EXTRACTIVE SUMMARY",
    "==========================================",
    "",
    summary_lead
  ),
  "lead_summary.txt"
)

cat("\nSummary files successfully saved.\n")


# VISUALISATION 1
top_words <- head(word_freq, 15)

png(
  "top_word_frequencies.png",
  width = 1200,
  height = 750
)

par(mar = c(10, 5, 4, 2))

barplot(
  top_words,
  las = 2,
  col = "steelblue",
  main = "Top 15 Words in Natural Language Processing Web Content",
  xlab = "",
  ylab = "Word Frequency"
)

dev.off()

cat("\nSaved: top_word_frequencies.png\n")


# VISUALISATION 2
top_score_indices <- order(scores, decreasing = TRUE)[1:10]
top_scores <- scores[top_score_indices]

png(
  "summary_sentence_scores.png",
  width = 1200,
  height = 750
)

barplot(
  top_scores,
  names.arg = paste("Sentence", top_score_indices),
  las = 2,
  col = "darkseagreen3",
  main = "Top 10 Sentences by Frequency-Based Summary Score",
  xlab = "",
  ylab = "Sentence Importance Score"
)

dev.off()

cat("Saved: summary_sentence_scores.png\n")