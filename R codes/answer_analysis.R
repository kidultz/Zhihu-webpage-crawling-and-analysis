library(quanteda)
library(topicmodels)
library(ggplot2)
library(wordcloud2)
library(stm)
library(tm)
library(lda)
library(LDAvis)
library(servr)
set.seed(221186)

#Use topic modelling to understand how answers in "Zhihu"(Chinese quora) varies by the gender of the answerers. 
#Working with a corpus of answers scraped in the website of Zhihu currently. 
load("C:\\Users\\DELL\\Desktop\\quora_data.Rdata")
quora_data$ntoken <- ntoken(quora_data$answers)
ggplot(quora_data,aes(ntoken,fill=answerers_gender))+
  labs(title = "token_num_distribution")+geom_histogram()
  
ggplot(quora_data,aes(answerers_gender,ntoken,fill=answerers_gender),
       labs(title = "answer_num difference"),
       xlab="Gender",ylab="Num. of token")+geom_boxplot()
##We can see that the length of male users' answers are quite longer than females'.
##Also,the number of male answerers is much more than the number of female answerers,even though this is a topic about female.

#When using Chinese word segmentation, there is no space between words as in English.
#but Java has solved this problem. We only need to load rJava and rwordseg in R-console.
library(rJava)
library(Rwordseg)
answerCorpus <- segmentCN(quora_data$answers)
answerCorpus <- as.character(unlist(answerCorpus))
testterm<-as.data.frame(table(answerCorpus),stringsAsFactors=F)
##清洗停用词
stopword<-read.csv("C:\\Users\\DELL\\Desktop\\stopwords.csv",sep=",",stringsAsFactors=FALSE)#stopword.txt
stopword<-as.vector(stopword$X.)#需要为向量格式
testterm<-testterm[-which(testterm[,1] %in% intersect(stopword,testterm$answerCorpus)),]
testterm<-testterm[-which(nchar(testterm[,1])<2),]
#排序
wordsFreq<-testterm[order(testterm[,2],decreasing = T),]
head(wordsFreq,50)
#画词云图
wordcloud2(wordsFreq)



##男性
Maleanswer <- quora_data$answers[quora_data$answerers_gender=="M"]
maleCorpus <- segmentCN(Maleanswer)
maleCorpus <- as.character(unlist(maleCorpus))
maleterm<-as.data.frame(table(maleCorpus),stringsAsFactors=F)
##清洗停用词
maleterm<-maleterm[-which(maleterm[,1] %in% intersect(stopword,maleterm$maleCorpus)),]
maleterm<-maleterm[-which(nchar(maleterm[,1])<2),]
#排序
M_wordsFreq<-maleterm[order(maleterm[,2],decreasing = T),]
head(M_wordsFreq,50)
#画词云图
wordcloud2(M_wordsFreq)



##女性
FManswer <- quora_data$answers[quora_data$answerers_gender=="F"]
FMCorpus <- segmentCN(FManswer)
FMCorpus <- as.character(unlist(FMCorpus))
FMterm<-as.data.frame(table(FMCorpus),stringsAsFactors=F)
##清洗停用词
FMterm<-FMterm[-which(FMterm[,1] %in% intersect(stopword,FMterm$FMCorpus)),]
FMterm<-FMterm[-which(nchar(FMterm[,1])<2),]
#排序
FM_wordsFreq<-FMterm[order(FMterm[,2],decreasing = T),]
head(FM_wordsFreq,30)
#画词云图
wordcloud2(FM_wordsFreq,backgroundColor = 'lightgrey', color = 'random-dark')




#LDA
##1.预处理
term.table <- wordsFreq
vocab<-term.table$answerCorpus#创建词库
get.terms<-function(x){
  index<-match(x,vocab)#获取词的 ID
  index<-index[!is.na(index)]#去掉没有查到的，也就是去掉了的词
  rbind(as.integer(index-1),as.integer(rep(1,length(index))))#生成上图结构
} 
doc.list <- segmentCN(quora_data$answers)
documents<-lapply(doc.list,get.terms)


##2.LDA 建模（分词部分略去）
K<-5#主题数
G<-5000#迭代次数
alpha<-0.10
eta<-0.02
fit<-lda.collapsed.gibbs.sampler(documents=documents,K=K,
                                 vocab=vocab,num.iterations=G,alpha=alpha,eta=eta,
                                 initial=NULL,burnin=0,compute.log.likelihood=TRUE)

##3、LDAvis 可视化
theta<-t(apply(fit$document_sums+alpha,2,function(x)x/sum(x)))#文档—主题分布矩阵
phi<-t(apply(t(fit$topics)+eta,2,function(x)x/sum(x)))#主题-词语分布矩阵
term.frequency<-term.table$Freq#词频
doc.length<-sapply(documents,function(x)sum(x[2,]))#每篇文章的长度，即有多少个词

json<-createJSON(phi=phi,theta=theta,doc.length=doc.length,vocab=vocab,
                 term.frequency=term.frequency)


serVis(json,out.dir='C:\\Users\\DELL\\Desktop\\lda',open.browser=T)
###改成 UTF-8 格式以免出现乱码
writeLines(iconv(readLines("C:\\Users\\DELL\\Desktop\\lda\\lda.json"),from="GB23080",to="UTF8"),file("C:\\Users\\DELL\\Desktop\\lda\\ldavis.js",encoding="UTF-8"))
