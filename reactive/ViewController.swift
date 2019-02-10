//
//  ViewController.swift
//  reactive
//
//  Created by Vasiliy Fedotov
//  Copyright © 2019 Vasiliy Fedotov. All rights reserved.
//

// статья: https://habr.com/ru/post/423603/
// шпаргалка по операторам: https://habr.com/ru/post/281292/#single


import UIKit
import RxSwift

@inline(__always) func printF(_ item: Any, fun: String = #function) {
    print("__\(fun): ", terminator: "")
    print(item)
}

class ViewController: UIViewController {
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
/*
 Observable
*/
        
//        simpleObservable()
//        scheduleObservers()
        
        
/*
 Subjects
*/
        
//        simpleSubject()
//        replaySubject()
//        behaviorSubject()

/*
 Variables
*/
//        simpleVariable()
//        arrayVariable()
        dictionaryVariable()

        
        
    }
    
    func simpleObservable() {
        
        let observable = Observable<Int>.from([1, 2, 3])
        
        _ = observable.subscribe(onNext: { (event) in
            printF("next: \(event)")
        }, onError: { (error) in
            printF("error: \(error)")
        }, onCompleted: {
            printF("completed")
        }) {
            printF("disposed")

        }
    }
    
    func scheduleObservers() {
        let observable = Observable<Int>.create { (observer) -> Disposable in
            printF("thread observable -> \(Thread.current.isMainThread ? "main" : "background")")
            for i in 1...5 { observer.onNext(i) }
            return Disposables.create()
        }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        
        _ = observable
            .observeOn(MainScheduler.instance)
            .subscribe({ (e) in
                printF("thread subscribe -> \(Thread.current.isMainThread ? "main" : "background")")
                printF(e.element)
            })
    }
    
    func simpleSubject() {
        let subject = PublishSubject<Int>()
        
        _ = subject.subscribe { (event) in
            printF("A: \(event)")
        }
        
        subject.onNext(1)
        
        _ = subject.subscribe { (event) in
            printF("B: \(event)")
        }
        
        subject.onNext(2)
        subject.onNext(3)
        subject.onNext(4)
    }
    
    
    func replaySubject() {
        let subject = ReplaySubject<Int>.create(bufferSize: 3)
        
        _ = subject.subscribe { (event) in
            printF("A: \(event)")
        }
        
        subject.onNext(1)
        
        _ = subject.subscribe { (event) in
            printF("B: \(event)")
        }
        
        subject.onNext(2)
        subject.onNext(3)
        
        _ = subject.subscribe { (event) in
            printF("C: \(event)")
        }
        
        subject.onNext(4)
    }
    
    func behaviorSubject() {
        let subject = BehaviorSubject<Int>(value: 0)
        
        _ = subject.subscribe { (event) in
            printF("A: \(event)")
        }
        
        subject.onNext(1)
        
        _ = subject.subscribe { (event) in
            printF("B: \(event)")
        }
        
        subject.onNext(2)
        subject.onNext(3)
        
        _ = subject.subscribe { (event) in
            printF("C: \(event)")
        }
        
        subject.onNext(4)
    }
    
    func simpleVariable() {
        let variable = Variable<String>("StartValue")
        
        variable.asObservable().subscribe {
            //asObservable() returns the BehaviorSubject which is held as a property. Sequence replays "starting value" to Sub A
            printF("A: \($0)")
        }.disposed(by: bag)
        
        variable.value = "Next1"
        // gets and sets to a privately stored property. Additionally, creates a next() event on the privately stored BehaviorSubject
        variable.asObservable().subscribe {
            printF("B: \($0)")
        }.disposed(by: bag)
        
        variable.value = "Next2"
    }
    
    func arrayVariable() {
        let variable = Variable<[Int]>([])
        variable.asObservable().subscribe {
            printF("A: \($0)")
        }.disposed(by: bag)
        
        variable.value.append(1)
        variable.value.append(2)

        variable.asObservable().subscribe {
            printF("B: \($0)")
        }.disposed(by: bag)
        
        variable.value.append(3)
        variable.value.append(4)
        
        variable.value.remove(at: 0)
        
        variable.value.insert(0, at: 0)
        
        variable.value = [100]
        
        variable.value.removeAll()
    }
    
    func dictionaryVariable() {
        typealias TYPE = [String: [Int]]
        
        let variable = Variable<TYPE>([:])
        
        variable.asObservable().subscribe {
            printF("A: \($0)")
        }.disposed(by: bag)

        variable.value["one"] = []
        variable.value["one"]?.append(1)
        variable.value["one"]?.append(2)
        variable.value["one"]?.append(3)
        
        variable.value["two"] = [5,6,7]
        
        printF(variable.value)
        
        variable.value.removeValue(forKey: "one")
        
        variable.value.removeAll()
    }

}

