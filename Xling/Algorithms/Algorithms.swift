//
//  Algorithms.swift
//  Xling
//
//  Created by Richard Wei on 1/9/16.
//  Copyright © 2016 xinranmsn. All rights reserved.
//

import Cocoa

public class Algorithms {
    // Uninitializable
    init?() {
        return nil
    }
}

extension Algorithms {
    /**
     * Viterbi Algorithm - Finding the most likely sequence of states
     * @param observationSequence obs - observation sequence
     * @param hmm - hidden Markov model
     * @return (probability, sequence)
     */
    public static func viterbi<StateType: Hashable, ObservationType: Hashable>(observationSequence obs: [ObservationType], hmm: HiddenMarkovModel<StateType, ObservationType>) -> (Float, [StateType]) {
        typealias CellType = [StateType: Float]
        typealias PathType = [StateType: [StateType]]
        
        var trellis = [[StateType: Float]()]
        var path = PathType()
        
        for y in hmm.states {
            trellis[0][y] = -logf(hmm.initial[y]!) - logf(hmm.emission[y]![obs[0]]!)
            path[y] = [y]
        }
        for i in 1..<obs.count {
            trellis.append(CellType())
            var newPath = PathType()
            for y in hmm.states {
                var bestArg: StateType? // state
                var bestProb: Float = FLT_MAX // log prob
                for y0 in hmm.states {
                    let prob = trellis[i-1][y0]! - logf(hmm.transition[y0]![y]!) - logf(hmm.emission[y]![obs[i]]!)
                    if prob < bestProb {
                        bestArg = y0
                        bestProb = prob
                    }
                }
                if let _ = bestArg {
                    trellis[i][y] = bestProb
                    newPath[y] = path[bestArg!]! + [y]
                }
            }
            path = newPath
        }
        
        let n = obs.count - 1
        var bestArg: StateType?
        var bestProb: Float = FLT_MAX
        for y in hmm.states {
            if trellis[n][y] < bestProb {
                bestProb = trellis[n][y]!
                bestArg = y
            }
        }
        
        return (bestProb, path[bestArg!]!)
    }
}

