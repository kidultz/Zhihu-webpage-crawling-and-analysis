#install.packages("rtweet")
library(rvest)
library(quanteda)

# Read in the raw html code of the quora page
quora_answer_page <- read_html("C:/Users/DELL/Desktop/知乎.html")

## Find all the answerers on the page
answerers <- html_nodes(quora_answer_page, "a[class = 'UserLink-link']") # Find answerer entries
answerers_names <- html_nodes(answerers, "img") # answerers' names are stored within the <img> tag
answerers_names <- html_attr(answerers_names, "alt") # answerers' names are stored as the "alt" attribute

# Find all answerers' pages on quora
answerers_urls <- html_attr(answerers, "href") # Urls are stored as the "href" attribute
answerers_urls <- answerers_urls[-seq(1,length(answerers_urls),2)]

# Find all answers'urls on quora
answers_urls <- html_nodes(quora_answer_page, "a[data-za-detail-view-element_name='Title']") # Find answerer entries
answers_urls <- html_attr(answers_urls, "href")  # Urls are stored as the "href" attribute

#classify different types of answers

Columnists_answer <- rep(NA,141)
Users_answer <- rep(NA,141)

for (i in 1:141) {
   Columnists_answer[i] <- ifelse("zhuanlan.zhihu.com"%in%strsplit(answers_urls[i],"/")[[1]],i,NA)
   Users_answer[i] <- ifelse("zhuanlan.zhihu.com"%in%strsplit(answers_urls[i],"/")[[1]],NA,i)
}

Columnists_answer<- as.vector(na.omit(Columnists_answer))
Users_answer <- as.vector(na.omit(Users_answer))

#creat new variables
answerer_gender <- rep(NA,141)
answers <- rep(NA,141)

## Loop over all answerers_urls 
for(i in 1:141){
   Sys.sleep(1)
   cat(".")
   tmp_answerer_page <- read_html(answerers_urls[i])
   tmp_answerer_gender <- html_node(tmp_answerer_page, "button[class='Button FollowButton Button--primary Button--blue']")
   tmp_answerer_gender <- html_text(tmp_answerer_gender)
   answerer_gender[i] <- tmp_answerer_gender
 }

gender <- as.numeric(as.factor(answerer_gender))
answerers_gender <- rep(NA,141)
answerers_gender[gender==2] <- "M"
answerers_gender[gender==3] <- "F"
answerers_gender <- as.factor(answerers_gender)

## Loop over all answers_urls 
for(i in Columnists_answer){
   Sys.sleep(1)
   cat(".")
   tmp_answer_page <- read_html(answers_urls[i])
   tmp_answer <- html_node(tmp_answer_page, "div[class='RichText ztext Post-RichText']")
   tmp_answer <- html_text(tmp_answer)
   answers[i] <- gsub("\\n| ","",tmp_answer)
}


for(i in Users_answer){
   Sys.sleep(1)
   cat(".")
   tmp_answer_page <- read_html(answers_urls[i])
   tmp_answer <- html_node(tmp_answer_page, "span[class='RichText ztext CopyrightRichText-richText']")
   tmp_answer <- html_text(tmp_answer)
   answers[i] <- gsub("\\n| ","",tmp_answer)
}

quora_data <- data.frame(answers,answerers_names,answerers_gender)
quora_data$answers <- as.character(quora_data$answers)
quora_data <- na.omit(quora_data)
save(quora_data, file = "quora_data.Rdata")
load("quora_data.Rdata")
head(quora_data)
