//
//  HiddenMarkovModel.swift
//  Xling
//
//  Created by Richard Wei on 1/25/16.
//  Copyright © 2016 xinranmsn. All rights reserved.
//

import Foundation

public struct HiddenMarkovModel<StateType: Hashable, ObservationType: Hashable> {
    public var states: Set<StateType>
    public var observations: Set<ObservationType>
    public var transition: [StateType: [StateType: Float]]
    public var emission: [StateType: [ObservationType: Float]]
    public var initial: [StateType: Float]
    
    init() {
        states = Set<StateType>()
        observations = Set<ObservationType>()
        transition = [StateType: [StateType: Float]]()
        emission = [StateType: [ObservationType: Float]]()
        initial = [StateType: Float]()
    }
    
    init(states: Set<StateType>, observations: Set<ObservationType>, initial: [StateType: Float], transition: [StateType: [StateType: Float]], emission: [StateType: [ObservationType: Float]]) {
        // TODO
        self.states = states
        self.observations = observations
        self.transition = transition
        self.emission = emission
        self.initial = initial
    }
    
    
}