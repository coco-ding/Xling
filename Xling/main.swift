//
//  main.swift
//  Xling
//
//  Created by Richard Wei on 1/9/16.
//  Copyright © 2016 xinranmsn. All rights reserved.
//

import Foundation

//let tagger = HMMTagger(training: "train.txt")
//tagger.test("test.txt", outFile: "out.txt")

let states = Set(["Healthy", "Fever"])

let observations = ["normal", "cold", "dizzy"]

let start_probability: [String: Float] = ["Healthy": 0.6, "Fever": 0.4]

let transition_probability: [String: [String: Float]] = [
    "Healthy" : ["Healthy": 0.7, "Fever": 0.3],
    "Fever" : ["Healthy": 0.4, "Fever": 0.6]
]

let emission_probability: [String: [String: Float]] = [
    "Healthy" : ["normal": 0.5, "cold": 0.4, "dizzy": 0.1],
    "Fever" : ["normal": 0.1, "cold": 0.3, "dizzy": 0.6]
]

let hmm: HiddenMarkovModel<String, String> = HiddenMarkovModel(states: states, observations: Set(observations), initial: start_probability, transition: transition_probability, emission: emission_probability)
let result = Algorithms.viterbi(observationSequence: observations, hmm: hmm)
print(result)
