//
//  HMMTagger.swift
//  Xling
//
//  Created by Richard Wei on 1/9/16.
//  Copyright © 2016 xinranmsn. All rights reserved.
//

import Cocoa

public class HMMTagger {
    struct TaggedWord {
        var word: String
        var tag: String
        
        init?(taggedString: String) {
            let parts = taggedString.componentsSeparatedByString("_")
            if parts == [""] { return nil }
            word = parts[0]
            tag = parts[1]
        }
    }
    
    private var laplace: Float = 0.0
    private var minFreq: Int = 0
    
    private var states = Set<String>() // States
    private var observations = Set<String>() // Observations
    private var transition = [String: [String: Float]]()
    private var emission = [String: [String: Float]]()
    private var initial = [String: Float]()
    
//    private var trainingFile: String
//    private var testingFile: String
    
// In Algorithms.swift
//    static func viterbi(observedSequence: [String], states: Set<String>,
    
    public init(training: String, smoothing laplace: Float = 1.0, unknownWordThreshold minFreq: Int = 5) {
        self.laplace = laplace
        self.minFreq = minFreq
        train(training)
    }
    
    public init(states: Set<String>, observations: Set<String>, transition: [String: [String: Float]], emission: [String: [String: Float]], initial: [String: Float]) {
        self.states = states
        self.observations = observations
        self.transition = transition
        self.emission = emission
        self.initial = initial
    }
}

extension HMMTagger {
    private func readLabeledData(filePath: String) throws -> [[TaggedWord]] {
        let data = try String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
        let sentences = data.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()).filter({$0 != ""})
        let corpus = sentences.map({(sen) -> [TaggedWord] in
            let tokens = sen.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).filter({$0 != ""})
            return tokens.map({ TaggedWord(taggedString: $0)! })
        })
        return corpus.filter{!$0.isEmpty}
    }
    
    private func readUnlabeledData(filePath: String) throws -> [[String]] {
        let data = try String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
        let sentences = data.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()).filter({$0 != ""})
        let corpus = sentences.map({$0.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).filter({$0 != ""})})
        return corpus
    }
    
    private func preprocessLabeledCorpus(inout corpus: [[TaggedWord]]) {
        var freqDict = [String: Int]()
        for sen in corpus {
            for token in sen {
                freqDict[token.word] = (freqDict[token.word] ?? 0) + 1
            }
        }
        for (i, sen) in corpus.enumerate() {
            for (j, token) in sen.enumerate() {
                if freqDict[token.word] < minFreq {
                    corpus[i][j].word = UNK
                }
            }
        }
    }
    
    private func preprocessUnlabeledCorpus(inout corpus: [[String]]) {
        for (i, sen) in corpus.enumerate() {
            for (j, word) in sen.enumerate() where !self.observations.contains(word) {
                corpus[i][j] = UNK
            }
        }
    }
}

extension HMMTagger {
    private func train(trainingFile: String) {
        do {
            var corpus = try readLabeledData(trainingFile)
            
            preprocessLabeledCorpus(&corpus)
            
            for sen in corpus {
                for token in sen {
                    states.insert(token.tag)
                    observations.insert(token.word)
                }
            }
            
            // calculate initial probabilities
            print("Computing initial probabilities...")
            let smoothedSenCount = Float(corpus.count) + Float(states.count) * laplace
            for sen in corpus {
                let first = sen[0]
                initial[first.tag] = (initial[first.tag] ?? laplace) + 1.0
            }
            for (k, v) in initial {
                initial[k] = v / smoothedSenCount
            }
            
            // transition probabilities
            print("Computing transition probabilities...")
            var transCount = [String: Float]()
            for sen in corpus {
                for i in 0 ..< sen.count-1 {
                    let state = sen[i].tag, tostate = sen[i+1].tag
                    guard let _ = transition[state] else {
                        transition[state] = [String: Float]()
                        break
                    }
                    transition[state]![tostate] = (transition[state]![tostate] ?? laplace) + 1.0
                    transCount[state] = (transCount[state] ?? laplace * Float(states.count)) + 1.0
                }
            }
            for (state, toDict) in transition {
                for (toState, count) in toDict {
                    transition[state]![toState] = count / transCount[state]!
                }
            }
            
            print("Computing emission probabilities...")
            for tag in states {
                emission[tag] = [String: Float]()
            }
            // avoid zerop
            for word in observations {
                for tag in states {
                    emission[tag]![word] = laplace
                }
            }
            for sen in corpus {
                for token in sen {
                    let word = token.word, tag = token.tag
                    emission[tag]![word]! += 1.0
                }
            }
            let smoothedComplement = laplace * Float(observations.count)
            for (tag, wordMap) in emission {
                // compute prob
                let emitCount = Float(wordMap.count) + smoothedComplement
                for (word, count) in wordMap {
                    emission[tag]![word] = count / emitCount
                }
            }
        }
        catch {
            print("Training file parsing error!")
        }
    }
    
    public func test(testingFile: String, outFile: String? = nil) {
        // load testing data
        guard NSFileManager.defaultManager().fileExistsAtPath(testingFile) else {
            print("Testing file does not exist!")
            return
        }
        do {
            var corpus = try readUnlabeledData(testingFile)
            preprocessUnlabeledCorpus(&corpus)
            
            
            var out: NSOutputStream?
            if let outFile = outFile {
                out = NSOutputStream(toFileAtPath: outFile, append: true)
                out?.open()
                defer {
                    out?.close()
                }
            }
            
            for sen in corpus {
                let vitTags = Algorithms.viterbi(sen, states: states, initial: initial, transition: transition, emission: emission)
                var senString = ""
                for (i, word) in sen.enumerate() {
                    senString += word + "_" + vitTags[i] + " "
                }
                print(senString)
            }
        } catch {
            print("Testing file parsing error!")
        }
    }
    
}
