//
//  DateTools.swift
//  IMeditated
//
//  Created by Bob Spryn on 9/6/16.
//  Copyright © 2016 Thumbworks. All rights reserved.
//

import Foundation
import Result

enum DateToolsError: Error {
    case DateConversionError
    case NotEnoughMinutesRemaining(UInt)
}


extension Date {
    func hasNumberOfMinutesRemainingInDay(_ minutes: UInt) -> Result<Void, DateToolsError> {
        var components = Calendar.current.dateComponents([.year,.month,.day], from: self)
        components.day = components.day.map { day -> Int in
            day + 1
        }
        guard let nextDayDate = Calendar.current.date(from: components) else {
            return .failure(DateToolsError.DateConversionError)
        }
        
        let minutesRemaining = max(UInt(ceil((nextDayDate.timeIntervalSince1970 - self.timeIntervalSince1970)/60.0)), 0)
        
        return minutesRemaining > minutes ? .success() : .failure(DateToolsError.NotEnoughMinutesRemaining(minutes - minutesRemaining))
    }
    
    func hasNumberOfMinutesInDayBefore(_ minutes: UInt) -> Result<Void, DateToolsError> {
        let components = Calendar.current.dateComponents([.year,.month,.day], from: self)
        guard let startDayDate = Calendar.current.date(from: components) else {
            return .failure(DateToolsError.DateConversionError)
        }
        
        let minutesRemaining = max(UInt(ceil((self.timeIntervalSince1970 - startDayDate.timeIntervalSince1970)/60.0)), 0)
        
        return minutesRemaining > minutes ? .success() : .failure(DateToolsError.NotEnoughMinutesRemaining(minutes - minutesRemaining))
    }
    
    func generateStartAndEndDateForDay() -> Result<(Date, Date), DateToolsError> {
        let components = Calendar.current.dateComponents([.year,.month,.day], from: self)
        let plusOne = DateComponents(day:1)
        guard let startDate = Calendar.current.date(from: components) else {
            return .failure(DateToolsError.DateConversionError)
        }
        guard let endDate = Calendar.current.date(byAdding: plusOne, to: startDate) else {
            return .failure(DateToolsError.DateConversionError)
        }
        
        return .success((startDate, endDate))
    }
    
    func shiftTimeToFitRangeInDay(withMinutes: UInt) -> Result<Date, DateToolsError> {
        let minutesRemainingResult = self.hasNumberOfMinutesRemainingInDay(withMinutes)
        
        switch minutesRemainingResult {
            case .success():
                return .success(self)
            case .failure(let error):
                switch error {
                    case .DateConversionError:
                        return .failure(error)
                    case .NotEnoughMinutesRemaining(let minutes):
                        return .success(self.addingTimeInterval(Double(minutes) * -60))
                }
        }
    }
}
