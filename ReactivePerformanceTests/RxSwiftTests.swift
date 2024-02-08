//
//  RxSwiftTests.swift
//  ReactivePerformanceTests
//
//  Created by Jonas Dahmen on 20.12.23.
//

import XCTest
import RxSwift

class RxSwiftTests: XCTestCase {

    func testPublishSubjectPumping() {
        measure {
            var sum = 0
            let subject = PublishSubject<Int>()

            let subscription = subject
                .subscribe(onNext: { x in
                    sum += x
                })

            for _ in 0 ..< iterations {
                subject.on(.next(1))
            }

            subscription.dispose()

            XCTAssertEqual(sum, iterations)
        }
    }

    func testPublishSubjectPumpingMultipleSubscriptions() {
        measure {
            let subscriptionsAmount = 10

            let subject = PublishSubject<Int>()
            let disposables = CompositeDisposable()
            var sum = 0

            for _ in 0 ..< subscriptionsAmount {
                let disposable = subject
                    .subscribe(onNext: { x in
                        sum += x
                    })
                _ = disposables.insert(disposable)
            }

            for _ in 0 ..< iterations {
                subject.on(.next(1))
            }

            disposables.dispose()

            XCTAssertEqual(sum, iterations * subscriptionsAmount)
        }
    }

    func testPublishSubjectCreating() {
        measure {
            var sum = 0

            for _ in 0 ..< iterations {
                let subject = PublishSubject<Int>()

                let subscription = subject
                    .subscribe(onNext: { x in
                        sum += x
                    })

                for _ in 0 ..< 1 {
                    subject.on(.next(1))
                }

                subscription.dispose()
            }

            XCTAssertEqual(sum, iterations)
        }
    }

    func testSequencePumping() {
        measure {
            var sum = 0

            let disposable = Observable.from(sequenceToPump)
                .subscribe(onNext: { x in
                    sum += x
                })

            disposable.dispose()

            XCTAssertEqual(sum, iterations)
        }
    }

    func testMapFilterPumping() {
        measure {
            var sum = 0
                        
            let disposable = Observable<Int>
                .create { observer in
                    for _ in 0 ..< iterations {
                        observer.on(.next(1))
                    }
                    return Disposables.create()
                }
                .map { $0 }.filter { _ in true }
                .map { $0 }.filter { _ in true }
                .map { $0 }.filter { _ in true }
                .map { $0 }.filter { _ in true }
                .map { $0 }.filter { _ in true }
                .map { $0 }.filter { _ in true }
                .subscribe(onNext: { x in
                    sum += x
                })

            disposable.dispose()

            XCTAssertEqual(sum, iterations)
        }
    }

    func testMapFilterCreating() {
        measure {
            var sum = 0

            for _ in 0 ..< iterations {
                let subscription = Observable<Int>
                    .create { observer in
                        for _ in 0 ..< 1 {
                            observer.on(.next(1))
                        }
                        return Disposables.create()
                    }
                    .map { $0 }.filter { _ in true }
                    .map { $0 }.filter { _ in true }
                    .map { $0 }.filter { _ in true }
                    .map { $0 }.filter { _ in true }
                    .map { $0 }.filter { _ in true }
                    .map { $0 }.filter { _ in true }
                    .subscribe(onNext: { x in
                        sum += x
                    })

                subscription.dispose()
            }

            XCTAssertEqual(sum, iterations)
        }
    }

    func testFlatMapsPumping() {
        measure {
            var sum = 0
            let subscription = Observable<Int>
                .create { observer in
                    for _ in 0 ..< iterations {
                        observer.on(.next(1))
                    }
                    return Disposables.create()
                }
                .flatMap { x in Observable.just(x) }
                .flatMap { x in Observable.just(x) }
                .flatMap { x in Observable.just(x) }
                .flatMap { x in Observable.just(x) }
                .flatMap { x in Observable.just(x) }
                .subscribe(onNext: { x in
                    sum += x
                })

            subscription.dispose()

            XCTAssertEqual(sum, iterations)
        }
    }

    func testFlatMapsCreating() {
        measure {
            var sum = 0
            for _ in 0 ..< iterations {
                let subscription = Observable<Int>.create { observer in
                    for _ in 0 ..< 1 {
                        observer.on(.next(1))
                    }
                    return Disposables.create()
                }
                .flatMap { x in Observable.just(x) }
                .flatMap { x in Observable.just(x) }
                .flatMap { x in Observable.just(x) }
                .flatMap { x in Observable.just(x) }
                .flatMap { x in Observable.just(x) }
                .subscribe(onNext: { x in
                    sum += x
                })

                subscription.dispose()
            }

            XCTAssertEqual(sum, iterations)
        }
    }

    func testFlatMapLatestPumping() {
        measure {
            var sum = 0
            let subscription = Observable<Int>.create { observer in
                for _ in 0 ..< iterations {
                    observer.on(.next(1))
                }
                return Disposables.create()
            }
                .flatMapLatest { x in Observable.just(x) }
                .flatMapLatest { x in Observable.just(x) }
                .flatMapLatest { x in Observable.just(x) }
                .flatMapLatest { x in Observable.just(x) }
                .flatMapLatest { x in Observable.just(x) }
                .subscribe(onNext: { x in
                    sum += x
                })

            subscription.dispose()

            XCTAssertEqual(sum, iterations)
        }
    }

    func testFlatMapLatestCreating() {
        measure {
            var sum = 0
            for _ in 0 ..< iterations {
                let subscription = Observable<Int>.create { observer in
                    for _ in 0 ..< 1 {
                        observer.on(.next(1))
                    }
                    return Disposables.create()
                }
                    .flatMapLatest { x in Observable.just(x) }
                    .flatMapLatest { x in Observable.just(x) }
                    .flatMapLatest { x in Observable.just(x) }
                    .flatMapLatest { x in Observable.just(x) }
                    .flatMapLatest { x in Observable.just(x) }
                    .subscribe(onNext: { x in
                        sum += x
                    })

                subscription.dispose()
            }

            XCTAssertEqual(sum, iterations)
        }
    }

    func testCombineLatestPumping() {
        measure {
            var sum = 0
            var last = Observable.combineLatest(
                Observable.just(1), Observable.just(1), Observable.just(1),
                Observable<Int>.create { observer in
                    for _ in 0 ..< iterations {
                        observer.on(.next(1))
                    }
                    return Disposables.create()
                }) { x, _, _ ,_ in x }

            for _ in 0 ..< 6 {
                last = Observable.combineLatest(Observable.just(1), Observable.just(1), Observable.just(1), last) { x, _, _ ,_ in x }
            }

            let subscription = last
                .subscribe(onNext: { x in
                    sum += x
                })

            subscription.dispose()

            XCTAssertEqual(sum, iterations)
        }
    }

    func testCombineLatestCreating() {
        measure {
            var sum = 0
            for _ in 0 ..< iterations {
                var last = Observable.combineLatest(
                    Observable<Int>.create { observer in
                        for _ in 0 ..< 1 {
                            observer.on(.next(1))
                        }
                        return Disposables.create()
                    }, Observable.just(1), Observable.just(1), Observable.just(1)) { x, _, _ ,_ in x }

                for _ in 0 ..< 6 {
                    last = Observable.combineLatest(last, Observable.just(1), Observable.just(1), Observable.just(1)) { x, _, _ ,_ in x }
                }

                let subscription = last
                    .subscribe(onNext: { x in
                        sum += x
                    })

                subscription.dispose()
            }

            XCTAssertEqual(sum, iterations)
        }
    }
}
