//
//  MinutesEntryViewModel.swift
//  IMeditated
//
//  Created by Bob Spryn on 8/25/16.
//  Copyright © 2016 Thumbworks. All rights reserved.
//

import Foundation

struct MinutesEntryViewModel {
    
    let duration: String
    let ended: String
    let day: String
    
    // TODO: I don't like exposing models on view models, but exposed to pass to delete action
    // perhaps use index instead
    let meditationSample: MeditationSample
    
    
    init(meditationSample: MeditationSample) {
        self.meditationSample = meditationSample
        self.duration = Formatters.durationFormatter.string(from: meditationSample.start, to: meditationSample.end) ?? ""
        self.day = Formatters.dateFormatter.string(from: meditationSample.start)
        self.ended = Formatters.timeFormatter.string(from: meditationSample.end)
    }
}
