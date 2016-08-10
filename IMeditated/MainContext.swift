//
//  MainContext.swift
//  IMeditated
//
//  Created by Bob Spryn on 8/12/16.
//  Copyright © 2016 Thumbworks. All rights reserved.
//

import UIKit
import HealthKit
import RxSwift

protocol MainContextStateType {
    // sorted by start date, descending
    var allMeditationSamples: Observable<[MeditationSample]> { get }
}

protocol MainContextActionsType {
    func saveMeditation(minutes:UInt)
    func saveMeditation(endDate:Date, minutes:UInt)
    func moveMeditation(originalStart: Date, originalEnd: Date, end:Date, duration: UInt)
    func fetchMeditations()
    func delete(meditation: MeditationSample)
}

enum MainContextError : Error {
    case authorizationError
    case noTimesAvailableToday
    case apiError(HealthAPIError)
    case unknownError(Error)
}

class MainContext : MainContextStateType, MainContextActionsType {
    fileprivate let healthAPI: HealthAPIType
    
    // The context never goes away, so this is unnecessary, but can't hurt
    fileprivate let disposables = DisposeBag()
    
    fileprivate let _minutesListSubject = ReplaySubject<[MeditationSample]>.create(bufferSize: 1)
    // sorted by start date, descending
    var allMeditationSamples: Observable<[MeditationSample]> {
        return self._minutesListSubject
            .asObservable()
            .startWith([])
    }
    
    // an observable of observables, so we can observe when a save starts and finishes if we want
    // TODO: replace with rx Action as final version
    fileprivate let _saveObservables = PublishSubject<Observable<()>>()
    var saveActions: Observable<Observable<()>> {
        return self._saveObservables
            .asObservable()
    }
    
    // an observable of observables, so we can observe when a delete starts and finishes if we want
    // TODO: replace with rx Action as final version
    fileprivate let _deleteObservables = PublishSubject<Observable<()>>()
    var deleteActions: Observable<Observable<()>> {
        return self._deleteObservables
            .asObservable()
    }

    // an observable of observables, so we can observe when a move starts and finishes if we want
    // TODO: replace with rx Action as final version
    fileprivate let _moveObservables = PublishSubject<Observable<()>>()
    var moveActions: Observable<Observable<()>> {
        return self._moveObservables
            .asObservable()
    }
    
    fileprivate let _errorsSubject = PublishSubject<MainContextError>()
    var errors: Observable<MainContextError> {
        return self._errorsSubject
            .asObservable()
    }
    
    
    // use a default param, but using protocol for testability
    init(healthAPI: HealthAPIType = HealthAPI()) {
        self.healthAPI = healthAPI
        
        // authorize when the context is created
        // don't really need to do anything with the success case, but we want to communicate if there's an error
        self.healthAPI.authorize()
            .subscribe(onError: { [unowned self] error in
                // this could be made cleaner by materialize/dematerialize or just using Rx Action
                self._errorsSubject.onNext(.authorizationError)
            })
            .addDisposableTo(self.disposables)
        
        // on delete or save, reload the meditations
        Observable.of(self.saveActions.switchLatest(), self.deleteActions.switchLatest()).merge()
            .subscribe(onNext: { [unowned self] _ in
                self.fetchMeditations()
            }).addDisposableTo(self.disposables)
    }
}

extension MainContext {

    func saveMeditation(minutes: UInt) {
        // strip the seconds, nanoseconds
        let now = Calendar.current.date(from:Calendar.current.dateComponents([.year,.month,.day, .hour, .minute], from: Date()))!
        self.saveMeditation(endDate: now, minutes: minutes)
    }
    
    // TODO: Move to an #rxaction after everything is working with subjects to demo feature
    func saveMeditation(endDate:Date, minutes:UInt) {
        let initialStartDate = Date(timeInterval: Double(minutes) * -60, since: endDate)
        
        // 1. determine new start/end date, constraining it to the end of the day
        // TODO: Make shift return start and end date
        guard case let .success(startDate) = initialStartDate.shiftTimeToFitRangeInDay(withMinutes: minutes) else {
            // TODO send an error to the errors subject
            return
        }
        
        // 2. find all meditations on the same day as `startDate`
        guard case let .success(beginDayDate, endDayDate) = startDate.generateStartAndEndDateForDay() else {
            // TODO send an error to the errors subject
            return
        }
        
        self.healthAPI.getMeditations(startDate: beginDayDate, endDate: endDayDate, ascending: true)
            .subscribe(onNext: { samples in

                // 3. Determine if there's room after the last meditiation to slide this one in
                // TODO: Could turn this into a custom operator as an example
                guard let sample = samples.findAnyTimeRangeTodayWhereSampleFits(startDate: startDate, durationInMinutes: minutes) else {
                    self._errorsSubject.onNext(.noTimesAvailableToday)
                    return
                }
                
                let save = self.healthAPI.saveMeditation(sample: sample)
                
                // send the save operation to a publicly exposed observable so we can observe the save's start/stop/result
                self._saveObservables.onNext(save)
                save.subscribe(onError: { [unowned self] error in
                    // pipe errors into our error subject
                    self._errorsSubject.onNext(self.healthAPIErrorOrUnknown(error: error))
                }).addDisposableTo(self.disposables)

            }, onError: { error in
                self._errorsSubject.onNext(self.healthAPIErrorOrUnknown(error: error))
            })
            .addDisposableTo(self.disposables)
    }
    
    func moveMeditation(originalStart: Date, originalEnd: Date, end:Date, duration: UInt) {
        let oldSample = MeditationSample(start: originalStart, end: originalEnd)
        
        // watch for delete success, attempt to save
        let delete:Observable<()> = self.deleteActions.take(1)
            .switchLatest()
        
        // watch the save action triggered as result of the delete observable
        let move:Observable<()> = delete
            .flatMapLatest { [unowned self] _ -> Observable<()> in
                // create new meditation
                return self.saveActions.take(1)
                    .switchLatest()
        }
        
        // rig up the save action to trigger when the delete operation succeeds
        let _ = delete.subscribe(onNext: { [unowned self] value in
            self.saveMeditation(endDate: end, minutes: duration)
        }).addDisposableTo(self.disposables)

        // send the move operation to a publicly exposed observable so we can observe the move's start/stop/result
        self._moveObservables.onNext(move)
        
        // we don't need to specifically send an error here, as both delete and save already bubble up errors

        // kick off the process by deleting old meditation
        self.delete(meditation: oldSample)
        // TODO recreate old on failure?
    }

    // TODO: Move to an #rxaction after everything is working with subjects to demo feature
    func fetchMeditations() {
        // get the observable for a new fetch
        // right now we are just fetching ALL meditations ever, this won't scale at some point
        let fetch = self.healthAPI.getMeditations(startDate: Date.distantPast, endDate: Date.distantFuture, ascending: false)

        // subscribe the minutesListSubject to the result
        fetch.subscribe(onNext: { [unowned self] value in
            // TODO: to be consistent, send the observable instead of the value
                self._minutesListSubject.onNext(value)
            }, onError: { [unowned self] error in
                // pipe errors into our error subject
                self._errorsSubject.onNext(self.healthAPIErrorOrUnknown(error: error))
            })
        .addDisposableTo(self.disposables)
    }
    
    // TODO: Move to an #rxaction after everything is working with subjects to demo feature
    func delete(meditation: MeditationSample) {
        let delete = self.healthAPI.delete(meditationSample: meditation)
        self._deleteObservables.onNext(delete)
        delete.subscribe(onError: { [unowned self] error in
            // pipe errors into our error subject
            self._errorsSubject.onNext(self.healthAPIErrorOrUnknown(error: error))
        }).addDisposableTo(self.disposables)
    }
    
    // here's where it's unfortunate RxSwift doesn't have typed errors, though there is a reasonable explanation
    // as to why: https://github.com/ReactiveX/RxSwift/blob/master/Documentation/DesignRationale.md#design-rationale
    func healthAPIErrorOrUnknown(error: Error) -> MainContextError {
        if let error = error as? HealthAPIError {
            return .apiError(error)
        } else {
            return .unknownError(error)
        }
    }
}


