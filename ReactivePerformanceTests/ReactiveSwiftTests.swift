//
//  ReactiveSwiftTests.swift
//  ReactivePerformanceTests
//
//  Created by Jonas Dahmen on 20.12.23.
//

import XCTest
import ReactiveSwift

class ReactiveSwiftTests: XCTestCase {

    // In ReactiveSwift, Signal is similar to PublishSubject in RxSwift.
    // The pipe() function creates a Signal and an observer that can send events to the Signal.
    // The observeValues function is used to subscribe to the Signal and perform an action for each value it emits.
    func testSignalPumping() {
        measure {
            var sum = 0
            let (signal, observer) = Signal<Int, Never>.pipe()
            
            let disposable = signal.observeValues { x in
                sum += x
            }
            
            for _ in 0 ..< iterations {
                observer.send(value: 1)
            }
            
            disposable?.dispose()
            
            XCTAssertEqual(sum, iterations)
        }
    }

    func testSignalPumpingMultipleSubscriptions() {
        measure {
            let subscriptionsAmount = 10


            let (signal, observer) = Signal<Int, Never>.pipe()
            let disposables = CompositeDisposable()
            var sum = 0

            for _ in 0 ..< subscriptionsAmount {
                disposables += signal.observeValues { x in
                    sum += x
                }
            }

            for _ in 0 ..< iterations {
                observer.send(value: 1)
            }

            disposables.dispose()

            XCTAssertEqual(sum, iterations * subscriptionsAmount)
        }
    }

    func testSignalCreating() {
        measure {
            var sum = 0

            for _ in 0 ..< iterations {
                let (signal, observer) = Signal<Int, Never>.pipe()

                let disposable = signal.observeValues { x in
                    sum += x
                }

                for _ in 0 ..< 1 {
                    observer.send(value: 1)
                }

                disposable?.dispose()
            }

            XCTAssertEqual(sum, iterations)
        }
    }

    func testSequencePumping() {
        measure {
            var sum = 0

            let disposable = SignalProducer(sequenceToPump)
            .startWithValues { x in
                    sum += x
                }

            disposable.dispose()

            XCTAssertEqual(sum, iterations)
        }
    }

    func testMapFilterPumping() {
        measure {
            var sum = 0

            let disposable = SignalProducer<Int, Never> { observer, _ in
                for _ in 0 ..< iterations {
                    observer.send(value: 1)
                }
            }
            .map { $0 }.filter { _ in true }
            .map { $0 }.filter { _ in true }
            .map { $0 }.filter { _ in true }
            .map { $0 }.filter { _ in true }
            .map { $0 }.filter { _ in true }
            .map { $0 }.filter { _ in true }
            .startWithValues { x in
                    sum += x
                }

            disposable.dispose()

            XCTAssertEqual(sum, iterations)
        }
    }

    func testMapFilterCreating() {
        measure {
            var sum = 0

            for _ in 0 ..< iterations {
                let disposable = SignalProducer<Int, Never> { observer, _ in
                    for _ in 0 ..< 1 {
                        observer.send(value: 1)
                    }
                }
                .map { $0 }.filter { _ in true }
                .map { $0 }.filter { _ in true }
                .map { $0 }.filter { _ in true }
                .map { $0 }.filter { _ in true }
                .map { $0 }.filter { _ in true }
                .map { $0 }.filter { _ in true }
                .startWithValues { x in
                    sum += x
                }

                disposable.dispose()
            }

            XCTAssertEqual(sum, iterations)
        }
    }

    func testFlatMapsPumping() {
        measure {
            var sum = 0

            let initialProducer = SignalProducer<Int, Never> { observer, _ in
                for _ in 0 ..< iterations {
                    observer.send(value: 1)
                }
            }

            let producer1 = initialProducer.flatMap(.merge) { SignalProducer(value: $0) }
            let producer2 = producer1.flatMap(.merge) { SignalProducer(value: $0) }
            let producer3 = producer2.flatMap(.merge) { SignalProducer(value: $0) }
            let producer4 = producer3.flatMap(.merge) { SignalProducer(value: $0) }
            let finalProducer = producer4.flatMap(.merge) { SignalProducer(value: $0) }

            let disposable = finalProducer.startWithValues { x in
                sum += x
            }

            disposable.dispose()

            XCTAssertEqual(sum, iterations)
        }
    }

    func testFlatMapsCreating() {
        measure {
            var sum = 0

            for _ in 0 ..< iterations {
                let initialProducer = SignalProducer<Int, Never> { observer, _ in
                    for _ in 0 ..< 1 {
                        observer.send(value: 1)
                    }
                }

                let producer1 = initialProducer.flatMap(.merge) { x in SignalProducer(value: x) }
                let producer2 = producer1.flatMap(.merge) { x in SignalProducer(value: x) }
                let producer3 = producer2.flatMap(.merge) { x in SignalProducer(value: x) }
                let producer4 = producer3.flatMap(.merge) { x in SignalProducer(value: x) }
                let finalProducer = producer4.flatMap(.merge) { x in SignalProducer(value: x) }

                let disposable = finalProducer.startWithValues { x in
                    sum += x
                }

                disposable.dispose()
            }

            XCTAssertEqual(sum, iterations)
        }
    }

    func testFlatMapLatestPumping() {
        measure {
            var sum = 0

            let initialProducer = SignalProducer<Int, Never> { observer, _ in
                for _ in 0 ..< iterations {
                    observer.send(value: 1)
                }
            }

            let producer1 = initialProducer.flatMap(.latest) { x in SignalProducer<Int, Never>(value: x) }
            let producer2 = producer1.flatMap(.latest) { x in SignalProducer<Int, Never>(value: x) }
            let producer3 = producer2.flatMap(.latest) { x in SignalProducer<Int, Never>(value: x) }
            let producer4 = producer3.flatMap(.latest) { x in SignalProducer<Int, Never>(value: x) }
            let finalProducer = producer4.flatMap(.latest) { x in SignalProducer<Int, Never>(value: x) }

            let disposable = finalProducer.startWithValues { x in
                sum += x
            }

            disposable.dispose()

            XCTAssertEqual(sum, iterations)
        }
    }

    func testFlatMapLatestCreating() {
        measure {
            var sum = 0
            for _ in 0 ..< iterations {
                let initialProducer = SignalProducer<Int, Never> { observer, _ in
                    for _ in 0 ..< 1 {
                        observer.send(value: 1)
                    }
                }

                let producer1 = initialProducer.flatMap(.latest) { x in SignalProducer<Int, Never>(value: x) }
                let producer2 = producer1.flatMap(.latest) { x in SignalProducer<Int, Never>(value: x) }
                let producer3 = producer2.flatMap(.latest) { x in SignalProducer<Int, Never>(value: x) }
                let producer4 = producer3.flatMap(.latest) { x in SignalProducer<Int, Never>(value: x) }
                let finalProducer = producer4.flatMap(.latest) { x in SignalProducer<Int, Never>(value: x) }

                let disposable = finalProducer.startWithValues { x in
                    sum += x
                }

                disposable.dispose()
            }

            XCTAssertEqual(sum, iterations)
        }
    }


    func testCombineLatestPumping() {
        measure {
            var sum = 0
            var last = SignalProducer.combineLatest(
                SignalProducer(value: 1),
                SignalProducer(value: 1),
                SignalProducer(value: 1),
                SignalProducer<Int, Never> { observer, _ in
                    for _ in 0 ..< iterations {
                        observer.send(value: 1)
                    }
                }
            ).map { x, _, _, _ in x }

            for _ in 0 ..< 6 {
                last = SignalProducer.combineLatest(
                    SignalProducer(value: 1),
                    SignalProducer(value: 1),
                    SignalProducer(value: 1),
                    last
                ).map { _, _, _, _ in 1 }
            }

            let disposable = last.startWithValues { x in
                sum += x
            }

            disposable.dispose()

            XCTAssertEqual(sum, iterations)
        }
    }

func testCombineLatestCreating() {
    measure {
        var sum = 0
        for _ in 0 ..< iterations {
            var last = SignalProducer.combineLatest(
                SignalProducer<Int, Never> { observer, _ in
                    for _ in 0 ..< 1 {
                        observer.send(value: 1)
                    }
                }, SignalProducer(value: 1), SignalProducer(value: 1), SignalProducer(value: 1)
            ).map { x, _, _, _ in x }

            for _ in 0 ..< 6 {
                last = SignalProducer.combineLatest(
                    last, SignalProducer(value: 1), SignalProducer(value: 1), SignalProducer(value: 1)
                ).map { x, _, _, _ in x }
            }

            let disposable = last.startWithValues { x in
                sum += x
            }

            disposable.dispose()
        }

        XCTAssertEqual(sum, iterations)
    }
}


//    func testFlatMapsCreatingCompilerIssue() {
//        measure {
//            var sum = 0
//
//            for _ in 0 ..< iterations {
//                let producer = SignalProducer<Int, Never> { observer, _ in
//                    for _ in 0 ..< 1 {
//                        observer.send(value: 1)
//                    }
//                }
//                    .flatMap(.merge) { x in SignalProducer<Int, Never>(value: x) }
//                    .flatMap(.merge) { x in SignalProducer<Int, Never>(value: x) }
//                    .flatMap(.merge) { x in SignalProducer<Int, Never>(value: x) }
//                    .flatMap(.merge) { x in SignalProducer<Int, Never>(value: x) }
//                    .flatMap(.merge) { x in SignalProducer<Int, Never>(value: x) }
//
//                let disposable = producer.startWithValues { x in
//                    sum += x
//                }
//
//                disposable.dispose()
//            }
//
//            XCTAssertEqual(sum, iterations)
//        }
//    }
}
