//
//  HiddenMarkovModel.swift
//  Xling
//
//  Created by Richard Wei on 1/25/16.
//  Copyright © 2016 xinranmsn. All rights reserved.
//

import Foundation

public class HiddenMarkovModel<StateType: Hashable, ObservationType: Hashable>
{
    private(set) var states: Set<StateType>
    private(set) var observations: Set<ObservationType>
    private(set) var transition: [StateType: [StateType: Float]]
    private(set) var emission: [StateType: [ObservationType: Float]]
    private(set) var initial: [ObservationType: Float]
    
    init (states: Set<StateType>, observations: [ObservationType], initial: [StateType: Float], transition: [StateType: [StateType: Float]], emission: [StateType: [ObservationType: Float]]) {
        // TODO
    }
    
    
}