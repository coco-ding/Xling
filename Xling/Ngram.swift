//
//  Ngram.swift
//  Xling
//
//  Models in unigram, bigram, trigram, etc
//  Please be sure to preprocess the corpus (e.g. replacing UNKs, adding start
//  and end symbols before training the model
//
//  Created by Richard Wei on 1/14/16.
//  Copyright © 2016 xinranmsn. All rights reserved.
//

import Foundation

public class UnigramModel<WordType: Hashable> {
    private(set) var counts: [WordType: Float]
    private(set) var total: Float
    
    private var laplace: Float
    private var smoothedTotal: Float
    
    public init(corpus: [[WordType]], smoothing laplace: Float = 0.0) {
        
        self.counts = [WordType: Float]()
        self.total = 0.0
        self.laplace = laplace
        
        for sen in corpus {
            for word in sen {
                self.counts[word] = (self.counts[word] ?? 0.0) + 1.0
            }
            self.total += Float(sen.count)
        }
        
        self.smoothedTotal = self.total + Float(self.counts.count) * laplace
    }
    
    public subscript(word: WordType) -> Float {
        return getWordProbability(word)
    }
    
    public func getWordProbability(word: WordType) -> Float {
        guard let count = counts[word] else {
            // Not found
            return 0.0
        }
        
        return (count + laplace) / smoothedTotal
    }
}

public class BigramModel<WordType: Hashable> {
    private(set) var bicounts: [WordType: [WordType: Float]]
    private(set) var unicounts: [WordType: Float]
    private(set) var total: Float
    private var laplace: Float
    private var smoothedTotal: Float
    
    public init(corpus: [[WordType]], smoothing laplace: Float = 1.0) {
        self.bicounts = [WordType: [WordType: Float]]()
        self.unicounts = [WordType: Float]()
        self.total = 0.0
        self.laplace = laplace
        
        for sen in corpus {
            for i in 0..<sen.count-1 {
                let preword = sen[i], word = sen[i+1]
                guard let _ = bicounts[preword] else {
                    bicounts[preword] = [WordType: Float]()
                    bicounts[preword]![word] = 0.0
                    break
                }
                bicounts[preword]![word] = (bicounts[preword]![word] ?? 0.0) + 1.0
            }
        }
        
        let typeCount = self.bicounts.reduce(1, combine: { return $0 * $1.1.count })
        self.smoothedTotal = self.total + self.laplace * Float(typeCount)
    }
    
    public subscript(bigram: (WordType, WordType)) -> Float {
        return getBigramProbability(preword: bigram.0, word: bigram.1)
    }
    
    public func getBigramProbability(preword preword: WordType, word: WordType) -> Float {
        guard let _ = self.bicounts[preword], _ = self.bicounts[preword]![word] else {
            return 0.0
        }
        
        return (self.bicounts[preword]![word]! + laplace) / smoothedTotal
    }
}
