library(shiny)
library(RDRPOSTagger)
library(openNLP)
library(NLP)
library(qdapRegex)
library(dplyr)
library(stringr)


shinyServer(function(input,output){
  
  s <- reactive({
    input$sentences
  })
  
  tmp <- reactive({
    str_extract_all(s(), "#\\S+")
  })
  cleaned_sentences <- reactive ({
    rm_emoticon(s(), replacement = ".", trim = TRUE, clean = TRUE) %>%  # replace emoticons by '.' | qdapRegex package
  { gsub(tmp(), gsub("(?!^)(?=[[:upper:]])", " ", tmp(), perl=T), .) }  %>% # split words by Upper case letter but only from hashtag
  { gsub("#", "", .) } %>% # remove hashtags
  { gsub(' +',' ', .) } %>% # remove multiply spaces
  { gsub("([[:punct:]])\\1+", "\\1", .) } %>% # remove multiply `end marks`
  { as.String(.) } 
  })

 
   # openNLP package - sentence tokenize
   sent_token_annotator <- Maxent_Sent_Token_Annotator()
   annotated_sentences <- reactive ({
     annotate(cleaned_sentences(), list(sent_token_annotator))
   })
   

   # RDRPOSTagger package - POS (Part-Of-Speech Tagger) Tagger
   tagger <- rdr_model(language = "UD_Polish", annotation = "UniversalPOS")
   corpus <- reactive({
     rdr_pos(tagger, x = cleaned_sentences()[annotated_sentences()])
   })


  #### split compound sentences into simple ones ###

  #additional concjuctions needed to determine where we should split the sentences
  conjuctions <- c("i", "a", "ani", "ni", "tudzież", "albo", "lub", "czy", "bądź",
                   "ale", "lecz", "natomiast", "jednak", "więc", "toteż", "dlatego", "zatem",
                   "które", "która", "który", "które", "którym", "którego", "którymi", "że",
                   "gdzie", "kiedy", "jak", "ponieważ", "by", "aby", "mimo", "jaki", "ten", "jakich")



  modifed_corpus <- reactive({
    corpus() %>%
    mutate(if_conj = ifelse(tolower(token) %in% conjuctions | pos %in% c("PUNCT", "CCONJ"), 1, 0)) %>%
    mutate(if_verb = ifelse(pos %in% c("VERB", "AUX") & !(tolower(token) %in% conjuctions), 1, 0))
  })

  
  docs <- reactive ({
    unique(modifed_corpus()$doc_id)
  })

row_count <- 0
sentence <<- NULL
output$splitted_sentences <- renderUI({
 for (i in 1:length(docs()))
  {
    current_doc <- docs()[i]
    conj <- 0
    verb <- 0
    conjuction <- ''
    punc <- 0
    left_side <- 0
    right_side <- 0


    for (j in 1:sum(modifed_corpus()$doc_id == current_doc))
    {
      row_count <- row_count + 1
      if (modifed_corpus()$if_conj[row_count] == 1)
      {
        conj <- conj + 1
        conjuction <- modifed_corpus()$token[row_count]
        token_id <- modifed_corpus()$token_id[row_count]
      }
      if (modifed_corpus()$if_verb[row_count] == 1)
        verb <- verb + 1
      if (verb == 1 & conj == 0 & left_side == 0)
        left_side <- left_side + 1
      if (left_side == 1 & conj == 1 & verb == 1 & punc == 0)
        punc <- punc + 1
      if (verb == 2 & punc == 1 & right_side == 0)
        right_side <- right_side + 1
      if (left_side == 1 & punc == 1 & right_side == 1)
      {
     
        row_count <- row_count + (sum(modifed_corpus()$doc_id == current_doc) - j)

        final_statement <- as.list(cleaned_sentences()[annotated_sentences()])[as.numeric(substr(current_doc, 2, 3))]
        sentence <- c(sentence, gsub(conjuction, paste0(conjuction, "|"), final_statement))
        break

      }
    }
 }
  HTML(sentence)
})


})