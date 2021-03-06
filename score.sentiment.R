score.sentiment <- function(sentences, pos.words, neg.words, .progress='none'){
  
  scores <- laply(sentences,
                  function(sentence, pos.words, neg.words){
                    
                    #remove punctuation - using global substitute
                    sentence <- gsub("[[:punct:]]", "", sentence)
                    
                    #remove control characters
                    sentence <- gsub("[[:cntrl:]]", "", sentence)
                    
                    #remove digits
                    sentence <- gsub('\\d+', '', sentence)
                    
                    #define error handling function when trying tolower
                    tryTolower <- function(x){
                      
                      #create missing value
                      y <- NA
                      
                      #tryCatch error
                      try_error <- tryCatch(tolower(x), error=function(e) e)
                      
                      #if not an error
                      if (!inherits(try_error, "error"))
                        y <- tolower(x)
                      
                      #result
                      return(y)
                    }
                    
                    #use tryTolower with sapply
                    sentence <- sapply(sentence, tryTolower)
                    
                    #split sentence into words with str_split (stringr package)
                    word.list <- str_split(sentence, "\\s+")
                    #word.list <- str_replace_all(word.list,"[^[:graph:]]", " ")
                    words <- unlist(word.list)
                    
                    
                    #remove non-alphabetic characters
                    #alpha_num <- grep(words, pattern = "[a-z|0-9]", ignore.case = T)
                    #words <- paste(words[alpha_num], collapse = " ")
                    #words <- sapply(words,function(row) iconv(row, "latin1", "ASCII", sub=""))
                    
                    #compare words to the dictionaries of positive & negative terms
                    pos.matches <- match(words, pos.words)
                    neg.matches <- match(words, neg.words)
                    
                    #get the position of the matched term or NA
                    #we just want a TRUE/FALSE
                    pos.matches <- !is.na(pos.matches)
                    neg.matches <- !is.na(neg.matches)
                    
                    #final score
                    score <- sum(pos.matches) - sum(neg.matches)
                    return(score)
                  }, pos.words, neg.words, .progress=.progress )
  
  #data frame with scores for each sentence
  scores.df <- data.frame(text=sentences, score=scores)
  return(scores.df)
}