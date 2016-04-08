Presenting Word-Pred App
========================================================
author: Lima, Fabiano Andrade
date: April 8th, 2016

Introduction
========================================================

The maing goal here is to present this proof of concept
of a app capable of predicting what the user is going 
to type.

In the next few slides, the data, thecnics to processing
and creating a model, and the algorithms used to put
this app to work.

The Data
========================================================

The database used to create a model that a algorithm could
use was created from about 3.5 million texts obtained from
twitter, blogs and news web sites. 

The main challange was to

The Processing Steps
========================================================

To process the texts, the words were converted to numbers,
and only about 7k words were used. This amount of words
corresponds to more then 90% of all words occorrences in 
the entire database.

So this represents the scope of words that the algorithm
is capable of predict. The processing system was made entirely
in R and this can be extended if better precision is required.


The Model
=========================================================

The model used by the algorithms to make predictions is
based on the markov matrixes combined with n-grams models. 

N-Grams is a technic of grouping the words of a text in 
sequencial groups of N words.

Markov matrix is a data structre were one dimension represents
a state, and the other dimension represents a consequence.
The value for a given x,y element represents the probability of y given x.

The structure that the Word-Pred app uses resemble a markov matrix, but
with some differences.

For each n-Gram model, we have a matrix with the first n-1 columns 
holding the correspondent words, and the next three columns holding
the top three words 
words etimated by a given n
Thus, The words where grouped in 4,3 and 2-Grams and for each group, 
the first n-1 words were held and the  maximum likelihood estimation 
were calculated for all N words for a given n-1 and the top tree words were then selected.



