# Zhihu-webpage-crawling-and-analysis
1.Zhihu webpage crawling--2.text analysis--3.LDA topic model

I used R's rvest package to extract 140 hottest answers and the sex of each respondent . Then I applied the LDA model of the answer corpus of each gender respectively and find some interesting conbinations .

Before web crawling , I'm used to saving the webpage on the desktop  firstly cause it brings much more convenience to the further work !

Note that there is no space between words as in English when using Chinese word segmentation , but Java has solved this problem. We only need to load rJava and rwordseg in R-console.
