#QUESTION 4.1 
#source: https://quotes.toscrape.com/

all_records <- data.frame()

for (page in 1:3) {

  url <- paste0("https://quotes.toscrape.com/page/", page, "/")

  html_file <- tempfile(fileext = ".html")
  download.file(url, html_file, method = "libcurl", quiet = TRUE)

  html <- paste(
    readLines(html_file, warn = FALSE, encoding = "UTF-8"),
    collapse = " "
  )

  # extact individual quote blocks
  blocks <- regmatches(
    html,
    gregexpr(
      '<div class="quote".*?</div>\\s*</div>',
      html,
      perl = TRUE
    )
  )[[1]]

  for (block in blocks) {

    #quote text
    quote <- sub(
      '.*<span class="text" itemprop="text">(.*?)</span>.*',
      "\\1",
      block,
      perl = TRUE
    )

    #author
    author <- sub(
      '.*<small class="author" itemprop="author">(.*?)</small>.*',
      "\\1",
      block,
      perl = TRUE
    )

    #tags
    tags <- regmatches(
      block,
      gregexpr(
        '<a class="tag"[^>]*>(.*?)</a>',
        block,
        perl = TRUE
      )
    )[[1]]

    tags <- gsub("<[^>]+>", "", tags)
    tags <- paste(tags, collapse = ", ")

    #add deliberately raw/incomplete fields for ETL demonstration
    record <- data.frame(
      quote = quote,
      author = author,
      tags = ifelse(tags == "", NA, tags),
      quote_length = nchar(quote),
      word_count = length(strsplit(quote, "\\s+")[[1]]),
      stringsAsFactors = FALSE
    )

    all_records <- rbind(all_records, record)
  }
}

#insert some realistic missing/inconsistent values
if (nrow(all_records) >= 20) {
  all_records$tags[c(4, 12)] <- NA
  all_records$author[20] <- paste0(" ", all_records$author[20], " ")
}

cat("Records scraped:", nrow(all_records), "\n\n")

print(
  head(all_records, 10),
  row.names = FALSE
)


# QUESTION 4.2 

clean_data <- all_records

#remove extra whitespace
clean_data$quote <- trimws(gsub("\\s+", " ", clean_data$quote))
clean_data$author <- trimws(gsub("\\s+", " ", clean_data$author))
clean_data$tags <- trimws(gsub("\\s+", " ", clean_data$tags))

#replace missing tags
clean_data$tags[
  is.na(clean_data$tags) | clean_data$tags == ""
] <- "No tags"

#remove duplicate records
clean_data <- clean_data[!duplicated(clean_data$quote), ]

#recalculate numerical variables after cleaning
clean_data$quote_length <- nchar(clean_data$quote)

clean_data$word_count <- sapply(
  strsplit(clean_data$quote, "\\s+"),
  length
)

#export cleaned dataset
write.csv(
  clean_data,
  "clean_quotes.csv",
  row.names = FALSE
)

cat("\nClean records:", nrow(clean_data), "\n")
cat("Missing values:", sum(is.na(clean_data)), "\n")
cat("CSV exported: clean_quotes.csv\n")