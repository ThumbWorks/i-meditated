    //
//  HealthAPI.swift
//  IMeditated
//
//  Created by Bob Spryn on 8/19/16.
//  Copyright © 2016 Thumbworks. All rights reserved.
//

import Foundation
import RxSwift
import HealthKit

protocol HealthAPIType {
    // Any value returned means things went smoothly, otherwise, going to throw a HealthAPIError
    func authorize() -> Observable<Void>
    // Any value returned means things went smoothly, otherwise, going to throw a HealthAPIError
    func saveMeditation(sample:MeditationSample) -> Observable<Void>
    // retrieve meditations. a nil value for start or end date swaps in the min/max time in that direction
    func getMeditations(startDate: Date?, endDate: Date?, ascending: Bool) -> Observable<[MeditationSample]>
    // Any value returned means things went smoothly, otherwise, going to throw a HealthAPIError
    func delete(meditationSample: MeditationSample) -> Observable<Void>
}

enum HealthAPIError: Error {
    case apiFailure(Error?)
    case authorizationFailure(Error?)
    case notFound
}

struct HealthAPI {
    fileprivate let healthStore = HKHealthStore()
    fileprivate let disposables = DisposeBag()
}


extension HealthAPI: HealthAPIType {
    
    fileprivate static let dateFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    func authorize() -> Observable<Void> {

        let hkTypesToRead = Set([HKObjectType.categoryType(forIdentifier: .mindfulSession)!])
        let hkTypesToWrite = Set([HKSampleType.categoryType(forIdentifier: .mindfulSession)!])
        
        if !HKHealthStore.isHealthDataAvailable()
        {
            return Observable.error(HealthAPIError.authorizationFailure(nil))
        }
        
        let authorize: ConnectableObservable<Void> = Observable.create { subscriber in
            self.healthStore.requestAuthorization(toShare: hkTypesToWrite, read: hkTypesToRead) { (success, error) in
                if error == nil {
                    let writeStatus = self.healthStore.authorizationStatus(for: HKSampleType.categoryType(forIdentifier: .mindfulSession)!)
                    if (writeStatus != .sharingAuthorized) {
                        subscriber.onError(HealthAPIError.authorizationFailure(nil))
                    } else {
                        subscriber.onNext()
                        subscriber.onCompleted()
                    }
                } else {
                    subscriber.onError(HealthAPIError.authorizationFailure(error))
                }
            }
            return Disposables.create()
        }.publish()
        authorize.connect().addDisposableTo(self.disposables)
        return authorize
    }
    
    internal func getMeditations(startDate: Date?, endDate: Date?, ascending: Bool) -> Observable<[MeditationSample]> {
        
        // For fastlane snapshots only
        if(UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") && startDate == Date.distantPast && endDate == Date.distantFuture) {
            // runtime check that we are in snapshot mode
            return Observable.just(HealthAPI.snapshotData())
        }
        
        let startDate = startDate ?? Date.distantPast
        let endDate = endDate ?? Date.distantFuture
        
        // 1. Predicate
        let predicate =  HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        // 2. Order the samples by date
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: ascending)
        // 3. Create the query
        
        let queryObservable: ConnectableObservable<[MeditationSample]>  = Observable.create { subscriber in
            let sampleQuery = HKSampleQuery(sampleType: HKCategoryType.categoryType(forIdentifier: .mindfulSession)!, predicate: predicate, limit: 0, sortDescriptors: [sortDescriptor]) { (sampleQuery, results, error ) -> Void in
                guard error == nil else {
                    subscriber.onError(HealthAPIError.apiFailure(error))
                    return
                }
                // I believe results can be nil if no results are found. There's no definitive way to check if we have read access (security concerns)
                // so instead we just assume no results if it's nil
                subscriber.onNext(results?.map(MeditationSample.init) ?? [])
                subscriber.onCompleted()
            }

            // 4. Execute the query
            self.healthStore.execute(sampleQuery)
            return Disposables.create()
        }.publish()
        
        queryObservable.connect().addDisposableTo(self.disposables)
        return queryObservable
    }

    internal func saveMeditation(sample:MeditationSample) -> Observable<Void> {
        let mindfulType = HKCategoryType.categoryType(forIdentifier: .mindfulSession)
        let mindfulSample = HKCategorySample(type: mindfulType!, value: 0, start: sample.start, end: sample.end)
        
        let save: ConnectableObservable<Void> = Observable.create { subscriber in
            self.healthStore.save(mindfulSample) { success, error in
                guard success && error == nil else {
                    let theError = HealthAPIError.apiFailure(error)
                    subscriber.onError(theError)
                    return
                }
                subscriber.onNext()
                subscriber.onCompleted()
            }
            return Disposables.create()
        }.publish()
        
        save.connect().addDisposableTo(self.disposables)
        return save
    }
    
    internal func delete(meditationSample: MeditationSample) -> Observable<Void> {
        // query for the sample so that we aren't worrying about storing a reference to HKSample in the non-HK model
        let predicate = HKQuery.predicateForSamples(withStart: meditationSample.start, end: meditationSample.end, options: [])
        let query: Observable<HKSample?> = Observable.create { subscriber in
            let sampleQuery = HKSampleQuery(sampleType: HKCategoryType.categoryType(forIdentifier: .mindfulSession)!, predicate: predicate, limit: 0, sortDescriptors: nil) { (sampleQuery, results, error ) -> Void in
                guard let results = results else {
                    subscriber.onError(HealthAPIError.notFound)
                    return
                }
                subscriber.onNext(results.first)
                subscriber.onCompleted()
            }
            // 4. Execute the query
            self.healthStore.execute(sampleQuery)
            return Disposables.create()
        }
        
        let delete: ConnectableObservable<Void> = query
            .flatMap { sample -> Observable<Void> in
                guard let sample = sample else {
                    return Observable.error(HealthAPIError.notFound)
                }
                return Observable<Void>.create { subscriber in
                    self.healthStore.delete(sample, withCompletion: { success, error in
                        guard success else {
                            subscriber.onError(HealthAPIError.apiFailure(error))
                            return
                        }
                        subscriber.onNext(())
                        subscriber.onCompleted()
                    })
                    return Disposables.create()
                }
        }.publish()
        delete.connect().addDisposableTo(self.disposables)
        return delete
    }
}
    
extension HealthAPI {
    fileprivate static func snapshotData() -> [MeditationSample] {
        let df = HealthAPI.dateFormatter
        return [
            MeditationSample(start: df.date(from: "2017-2-7 01:10:00")!, end: df.date(from: "2017-2-7 02:10:00")!),
            MeditationSample(start: df.date(from: "2017-2-6 07:13:00")!, end: df.date(from: "2017-2-6 07:23:00")!),
            MeditationSample(start: df.date(from: "2017-2-6 13:13:00")!, end: df.date(from: "2017-2-6 13:23:00")!),
            MeditationSample(start: df.date(from: "2017-2-5 08:34:00")!, end: df.date(from: "2017-2-5 08:54:00")!),
            MeditationSample(start: df.date(from: "2017-2-3 10:00:00")!, end: df.date(from: "2017-2-3 10:45:00")!),
            MeditationSample(start: df.date(from: "2017-2-3 14:23:00")!, end: df.date(from: "2017-2-3 14:43:00")!),
            MeditationSample(start: df.date(from: "2017-2-3 21:06:00")!, end: df.date(from: "2017-2-3 21:21:00")!),
            MeditationSample(start: df.date(from: "2017-2-2 20:03:00")!, end: df.date(from: "2017-2-2 21:03:00")!),
            MeditationSample(start: df.date(from: "2017-2-1 18:00:00")!, end: df.date(from: "2017-2-3 18:21:00")!),
            MeditationSample(start: df.date(from: "2017-1-28 22:15:00")!, end: df.date(from: "2017-1-28 22:45:00")!),
            MeditationSample(start: df.date(from: "2017-1-28 12:15:00")!, end: df.date(from: "2017-1-28 12:45:00")!),
            MeditationSample(start: df.date(from: "2017-1-27 00:02:00")!, end: df.date(from: "2017-1-27 00:32:00")!),
            MeditationSample(start: df.date(from: "2017-1-26 22:15:00")!, end: df.date(from: "2017-1-28 22:45:00")!),
        ]
    }
}
