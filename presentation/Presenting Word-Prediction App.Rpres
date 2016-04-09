Word-Pred App
========================================================
type: intro
font-import: http://fonts.googleapis.com/css?family=Slabo
font-family: 'Slabo'
author: Lima, Fabiano Andrade
date: April 8th, 2016


Introduction
========================================================

The maing goal here is to present this proof of concept
of the Word-Pred: A app capable of predicting what the user 
is going to type given what he has already typed.

In the next few slides, the data, thecnics to processing
and creating a model, and the algorithms used to put
this app to work will be presented with non-thecnical
language, so every audience can gat a sence of what is
behind the App.

The Data
========================================================

To create such a app, text data is necessary. In thi

The dataset used for build the model for use with the 
prediction algorithm in the Word-Pred app was the 
[HC Corpora](http://www.corpora.heliohost.org/).

The dataset gathers about 3.5 million of texts obtained from
twitter, blogs and news web sites.

The data is freely available to download and comes in
several languages.

For our purposes, the only language used was English.

The Processing Steps
========================================================

<<<<<<< HEAD
To process the texts, the words were converted to numbers,
and only about 12k words were used. This amount of words
corresponds to more then 95% of all words occorrences in 
the entire database.

So this represents the scope of words that the app
is capable of predicting. 

The processing system was made entirely in R and it can be 
extended for better precision.
=======
After some exploratory analysis, we have reached the understading
that to cover 90% of all words in our dataset, about 7k
single words would be necessary.

With this information in place, a list of words and a number
to identify each word was created, and the entire dataset
was "translated" in numbers according to the list.

After that, the model creation could be drawn to the scene.
>>>>>>> origin/master


The Model
=========================================================

The model used by the algorithms to make predictions is
based on the markov matrixes combined with n-grams models. 

N-Grams is a technic of grouping the words of a text in 
sequencial groups of N words.

Markov matrix is a data structre were one dimension represents
a state, and the other dimension represents a consequence.
The value for a given x,y element represents the probability of y given x,
and the probabilit of y given x is equal to the probability of y given x
and x-1.

The Model II
=========================================================

The structure that the Word-Pred app uses resembles a markov matrix, but
with some differences.

For each n-Gram model, the Word-Pred model has a matrix with the 
first n-1 columns holding a given combination of n-1 words, and the 
next three columns holding the top three probable words for that combination.

The Algorithm
=========================================================

The algorithm used to make the predicions is a implementation
of the backoff algorithm. 

The basic idea of this algorithm is:

Given n words, we search for the top 3 possible words for those.
If nothing comes up, we try to search the top three words for
the n words less the first of these, if nothing comes up, we 
try to search the top three for the n words less the two firsts and so on.

The App
=========================================================

The app was implementend using the Shiny plataform and
can be checkd out at the following address:


