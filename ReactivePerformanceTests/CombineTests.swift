//
//  CombineTests.swift
//  ReactivePerformanceTests
//
//  Created by Jonas Dahmen on 20.12.23.
//

import XCTest
import Combine

class CombineTests: XCTestCase {

    func testPassthroughSubjectPumping() {
        measure {
            var sum = 0
            let subject = PassthroughSubject<Int, Never>()

            let cancellable = subject
                .sink(receiveValue: { x in
                    sum += x
                })

            for _ in 0 ..< iterations {
                subject.send(1)
            }

            cancellable.cancel()

            XCTAssertEqual(sum, iterations)
        }
    }

    func testPassthroughSubjectPumpingMultipleSubscriptions() {
        measure {
            let subscriptionsAmount = 10

            let subject = PassthroughSubject<Int, Never>()
            var cancellables = Set<AnyCancellable>()
            var sum = 0

            for _ in 0 ..< subscriptionsAmount {
                subject
                    .sink(receiveValue: { x in
                        sum += x
                    })
                    .store(in: &cancellables)
            }

            for _ in 0 ..< iterations {
                subject.send(1)
            }

            for cancellable in cancellables {
                cancellable.cancel()
            }

            XCTAssertEqual(sum, iterations * subscriptionsAmount)
        }
    }

    func testPassthroughSubjectCreating() {
        measure {
            var sum = 0

            for _ in 0 ..< iterations {
                let subject = PassthroughSubject<Int, Never>()

                let cancellable = subject
                    .sink(receiveValue: { x in
                        sum += x
                    })

                for _ in 0 ..< 1 {
                    subject.send(1)
                }

                cancellable.cancel()
            }

            XCTAssertEqual(sum, iterations)
        }
    }

    func testSequencePumping() {
        measure {
            var sum = 0

            let cancellable = Publishers.Sequence(sequence: sequenceToPump)
                .sink(receiveValue: { x in
                    sum += x
                })

            cancellable.cancel()

            XCTAssertEqual(sum, iterations)
        }
    }

    func testMapFilterPumping() {
        measure {
            var sum = 0
            
            let cancellable = Publishers.ClosureBased<Int, Never> { subscriber in
                    for _ in 0 ..< iterations {
                        _ = subscriber.receive(1)
                    }
                }
                .map { $0 }.filter { _ in true }
                .map { $0 }.filter { _ in true }
                .map { $0 }.filter { _ in true }
                .map { $0 }.filter { _ in true }
                .map { $0 }.filter { _ in true }
                .map { $0 }.filter { _ in true }
                .sink(receiveValue: { x in
                    sum += x
                })

            cancellable.cancel()

            XCTAssertEqual(sum, iterations)
        }
    }

    func testMapFilterCreating() {
        measure {
            var sum = 0

            for _ in 0 ..< iterations {
                let cancellable = Publishers.ClosureBased<Int, Never> { subscriber in
                        for _ in 0 ..< 1 {
                            _ = subscriber.receive(1)
                        }
                    }
                    .map { $0 }.filter { _ in true }
                    .map { $0 }.filter { _ in true }
                    .map { $0 }.filter { _ in true }
                    .map { $0 }.filter { _ in true }
                    .map { $0 }.filter { _ in true }
                    .map { $0 }.filter { _ in true }
                    .sink(receiveValue: { x in
                        sum += x
                    })

                cancellable.cancel()
            }

            XCTAssertEqual(sum, iterations)
        }
    }

    func testFlatMapsPumping() {
        measure {
            var sum = 0
            let cancellable = Publishers.ClosureBased<Int, Never> { subscriber in
                    for _ in 0 ..< iterations {
                        _ = subscriber.receive(1)
                    }
                }
                .flatMap { x in Just(x) }
                .flatMap { x in Just(x) }
                .flatMap { x in Just(x) }
                .flatMap { x in Just(x) }
                .flatMap { x in Just(x) }
                .sink(receiveValue: { x in
                    sum += x
                })

            cancellable.cancel()

            XCTAssertEqual(sum, iterations)
        }
    }


    func testFlatMapsCreating() {
        measure {
            var sum = 0
            for _ in 0 ..< iterations {
                let cancellable = Publishers.ClosureBased<Int, Never> { subscriber in
                        for _ in 0 ..< 1 {
                            _ = subscriber.receive(1)
                        }
                    }
                    .flatMap { x in Just(x) }
                    .flatMap { x in Just(x) }
                    .flatMap { x in Just(x) }
                    .flatMap { x in Just(x) }
                    .flatMap { x in Just(x) }
                    .sink(receiveValue: { x in
                        sum += x
                    })

                cancellable.cancel()
            }

            XCTAssertEqual(sum, iterations)
        }
    }

    func testFlatMapLatestPumping() {
        measure {
            var sum = 0
            let cancellable = Publishers.ClosureBased<Int, Never> { subscriber in
                    for _ in 0 ..< iterations {
                        _ = subscriber.receive(1)
                    }
                }
                .map { x in Just(x) }
                .switchToLatest()
                .map { x in Just(x) }
                .switchToLatest()
                .map { x in Just(x) }
                .switchToLatest()
                .map { x in Just(x) }
                .switchToLatest()
                .map { x in Just(x) }
                .switchToLatest()
                .sink(receiveValue: { x in
                    sum += x
                })

            cancellable.cancel()

            XCTAssertEqual(sum, iterations)
        }
    }

    func testFlatMapLatestCreating() {
        measure {
            var sum = 0
            for _ in 0 ..< iterations {
                let cancellable = Publishers.ClosureBased<Int, Never> { subscriber in
                        for _ in 0 ..< 1 {
                            _ = subscriber.receive(1)
                        }
                    }
                    .map { x in Just(x) }
                    .switchToLatest()
                    .map { x in Just(x) }
                    .switchToLatest()
                    .map { x in Just(x) }
                    .switchToLatest()
                    .map { x in Just(x) }
                    .switchToLatest()
                    .map { x in Just(x) }
                    .switchToLatest()
                    .sink(receiveValue: { x in
                        sum += x
                    })

                cancellable.cancel()
            }

            XCTAssertEqual(sum, iterations)
        }
    }

    func testCombineLatestPumping() {
        measure {
            var sum = 0

            let publisher = (0 ..< iterations)
                .map { _ in 1 }
                .publisher

            var last = Just(1).combineLatest(Just(1), Just(1), publisher) { x, _, _ ,_ in x }.eraseToAnyPublisher()

            for _ in 0 ..< 6 {
                last = Just(1).combineLatest(Just(1), Just(1), last) { x, _, _ ,_ in x }.eraseToAnyPublisher()
            }

            let cancellable = last
                .sink(receiveValue: { x in
                    sum += x
                })

            cancellable.cancel()

            XCTAssertEqual(sum, iterations)
        }
    }

    func testCombineLatestCreating() {
        measure {
            var sum = 0
            for _ in 0 ..< iterations {
                var last = Publishers.ClosureBased<Int, Never> { subscriber in
                        for _ in 0 ..< 1 {
                            _ = subscriber.receive(1)
                        }
                    }
                    .combineLatest(Just(1), Just(1), Just(1)) { x, _, _ ,_ in x }.eraseToAnyPublisher()

                for _ in 0 ..< 6 {
                    last = Just(1).combineLatest(Just(1), Just(1), last) { x, _, _ ,_ in x }.eraseToAnyPublisher()
                }

                let cancellable = last
                    .sink(receiveValue: { x in
                        sum += x
                    })

                cancellable.cancel()
            }

            XCTAssertEqual(sum, iterations)
        }
    }
}

