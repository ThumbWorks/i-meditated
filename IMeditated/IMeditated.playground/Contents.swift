//: Playground - noun: a place where people can play

import UIKit
import RxSwift

var str = "Hello, playground"


let x = PublishSubject<String?>()


let y = x.flatMapLatest { value -> Observable<String?> in
    guard value != nil else {
        return Observable.never()
            .timeout(1, scheduler: MainScheduler.instance)
            .catchErrorJustReturn(nil)
    }
    return Observable.just(value)
}

y.subscribe(onNext: { value in
    print(value)
})

x.onNext(nil)
sleep(2)
x.onNext(nil)

x.onNext(nil)
sleep(1)
x.onNext("Yay")

