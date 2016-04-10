WORD-PRED
========================================================
#type: intro
#font-import: http://fonts.googleapis.com/css?family=Slabo
#font-family: 'Slabo'
author: Lima, Fabiano Andrade
date: April 8th, 2016


Introduction
========================================================

What is WORD-PRED?

WORD-PRED is a proof of concept showing a app capable of 
predicting what the user is going to type given what he 
has already typed.

The data set used for build the model was the 
[HC Corpora](http://www.corpora.heliohost.org/) and it is composed of 
about 3.5 million of texts obtained from
twitter, blogs and news web sites. The data is freely available to 
download and comes in several languages.

For our purposes, the only language used was English.

The Processing Steps 
========================================================

After some exploratory analysis, we have reached the understanding
that to cover 95% of all words in our data set, about 12k
single words would be necessary.

With this information in place, a list of words and a number
to identify each word was created, and the entire data set
was "translated" in numbers according to the list.

Thus this collection of words represents the universe of words
the app is capable of predicting. 

After that, the model creation could be drawn to the scene.


The Model
=========================================================

The model used by the algorithms to make predictions is
based on the [Markov matrixes](https://en.wikipedia.org/wiki/Stochastic_matrix) combined
with [n-grams](https://en.wikipedia.org/wiki/N-gram) models. 

The most particular aspect of the model, is that it resembles a Markov matrix, but
with some differences.

For each *n-Gram* model, the Word-Pred model has a matrix with the 
first *n*-1 columns holding a given combination of *n*-1 words, and the 
next three columns holding the top three probable words for that combination.

The Algorithm and App
=========================================================

The algorithm used to make the predictions is a implementation
of the *backoff* algorithm. 

The basic idea behind the algorithm is as it follows.

Given *n* words, it searches for the three last words in the first 
matrix (the one with three words combinations). If something comes up,
the algorithm grabs the words of the tree columns that has the three
more likely next words. If not, it repeats the process in the
second matrix with the two last words and so on.

Finally, end-user app was built using [www.shinyapps.io] platform
and published at the following address:

[fabianoal.shinyapps.io/capstone-app](https://fabianoal.shinyapps.io/capstone-app/)

Check it out!



