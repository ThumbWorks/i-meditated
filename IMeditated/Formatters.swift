//
//  Formatters.swift
//  IMeditated
//
//  Created by Bob Spryn on 10/5/16.
//  Copyright © 2016 Thumbworks. All rights reserved.
//

import Foundation

struct Formatters {
    static let durationFormatter:DateComponentsFormatter = {
        let dcf = DateComponentsFormatter()
        dcf.allowedUnits = [.hour, .minute]
        dcf.unitsStyle = .short
        return dcf
    }()
    
    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .full
        df.timeStyle = .none
        return df
    }()
    
    static let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .short
        return df
    }()
}
