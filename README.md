# Zhihu-webpage-crawling-and-analysis

I used R's **rvest package** to extract 141 hottest answers of feminism topic on Zhihu webpage , which is Chinese version of Quora . Along with the answers , I extracted the sex of each respondent , then I applied the LDA model of the answer corpus of each gender respectively and find some interesting conbinations .

You can see the web page through this link https://www.zhihu.com/topic/19817175 . The feminism topic of Zhihu is updated almost everyday , so before web crawling , I'm used to **saving the webpage on the desktop firstly** cause it brings much more convenience to the further work !

Note that there is **no space between Chinese words** as in English when using Chinese word segmentation , but Java has solved this problem. We only need to **load rJava and rwordseg** in R-console.

This is the first time for me to try text analysis , and I'm open to all suggestion , thank you !
