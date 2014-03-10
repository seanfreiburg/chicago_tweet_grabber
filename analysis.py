import collections, itertools
import re
import json
from datetime import datetime

import nltk.metrics
from nltk.classify import NaiveBayesClassifier
from nltk.corpus import movie_reviews
from nltk.collocations import BigramCollocationFinder
from nltk.metrics import BigramAssocMeasures
from nltk.probability import FreqDist, ConditionalFreqDist

bestwords = set()
STOPWORDS_FILE = "./files/stopwords.txt"
INPUT_FILE='out.txt'
OUTPUT = "./files/output.json"

def train(feature):
    negids = movie_reviews.fileids('neg')
    posids = movie_reviews.fileids('pos')

    negfeatures = [(feature(movie_reviews.words(fileids=[f])), 'neg') for f in negids]
    posfeatures = [(feature(movie_reviews.words(fileids=[f])), 'pos') for f in posids]

    trainfeatures = negfeatures + posfeatures
    classifier = NaiveBayesClassifier.train(trainfeatures)

    return classifier

def best_word_features(words):
    global bestwords

    return dict([(word, True) for word in words if word in bestwords])

def best_bigram_word_features(words, score_fn=BigramAssocMeasures.chi_sq, n=200):
    bigram_finder = BigramCollocationFinder.from_words(words)
    bigrams = bigram_finder.nbest(score_fn, n)
    d = dict([(bigram, True) for bigram in bigrams])
    d.update(best_word_features(words))

    return d

def setup():
    global bestwords

    word_fd = FreqDist()
    label_word_fd = ConditionalFreqDist()

    for word in movie_reviews.words(categories=['pos']):
        word_fd.inc(word.strip('\'"?,.').lower())
        label_word_fd['pos'].inc(word.lower())

    for word in movie_reviews.words(categories=['neg']):
        word_fd.inc(word.strip('\'"?,.').lower())
        label_word_fd['neg'].inc(word.lower())

    pos_word_count = label_word_fd['pos'].N()
    neg_word_count = label_word_fd['neg'].N()
    total_word_count = pos_word_count + neg_word_count

    word_scores = {}

    for word, freq in word_fd.iteritems():
        pos_score = BigramAssocMeasures.chi_sq(label_word_fd['pos'][word],
            (freq, pos_word_count), total_word_count)
        neg_score = BigramAssocMeasures.chi_sq(label_word_fd['neg'][word],
            (freq, neg_word_count), total_word_count)
        word_scores[word] = pos_score + neg_score

    best = sorted(word_scores.iteritems(), key=lambda (w,s): s, reverse=True)[:10000]
    bestwords = set([w for w, s in best])
    return train(best_bigram_word_features)

def get_stop_words():
    stop_words = []

    with open(STOPWORDS_FILE) as f:
        stop_words = [word.strip('\n') for word in f]

    return stop_words

def classify_tweets(classifier):
    f = open('out.txt', 'r')
    f_out = open('sentiment_out.txt', 'w+')
    stop_words = get_stop_words()
    result = {}

    for line in f:
        tweet_dict = dict()
        line_json = json.loads(line)
        text = line_json['text']
        hour = line_json['created_at']

        if hour not in result:
            result[hour] = []

        for word in text.split():
            word = word.lower()
            if word in stop_words:
                continue

            word = word.strip('\'"?,.')
            if len(word) == 0:
                continue

            tweet_dict[word] = True

        score = classifier.classify(tweet_dict)
        line_json['sentiment'] = score
        f_out.write(json.dumps(line_json)+ "\n")




def main():
    classifier = setup()
    classify_tweets(classifier)

if __name__ == '__main__':
    main()
