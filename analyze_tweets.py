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
        result[hour].append([text, score])

    return result

def print_result(classified_tweets):
    stop_words = get_stop_words()

    with open(OUTPUT, 'w') as hour_file:
        for time, tweets in classified_tweets.items():
            score = 0
            word_counts = {}

            for tweet in tweets:
                for word in tweet[0].split():
                    word = word.lower()
                    if word in stop_words:
                        continue

                    word = word.strip('\'"?,.')
                    if len(word) == 0:
                        continue

                    if word not in word_counts:
                        word_counts[word] = 1
                    else:
                        word_counts[word] += 1

                if tweet[1] == "neg":
                    score -= 1
                else:
                    score += 1

            common_words = sorted(word_counts.iteritems(), key=lambda(k, v): v, reverse=True)[:5]
            print "common_words:", common_words

            line = json.dumps({"time": time, "score": score, "common words": [_[0] for _ in common_words]},
                indent=4, separators=(',', ': '))
            hour_file.write(line)

def main():
    classifier = setup()
    classified_tweets = classify_tweets(classifier)
    print_result(classified_tweets)

if __name__ == '__main__':
    main()
