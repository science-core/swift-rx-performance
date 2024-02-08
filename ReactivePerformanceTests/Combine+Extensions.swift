//
//  Combine+Extensions.swift
//  ReactivePerformanceTests
//
//  Created by Jonas Dahmen on 20.12.23.
//

import Foundation
import Combine

extension Publishers {
    public struct ClosureBased<Output, Failure: Swift.Error>: Publisher {
        var closure: (AnySubscriber<Output, Failure>) -> Void

        public func receive<S>(subscriber: S) where S : Subscriber, ClosureBased.Failure == S.Failure, ClosureBased.Output == S.Input {
            let subscription = Subscriptions.ClosureBased(subscriber: subscriber)
            subscriber.receive(subscription: subscription)
            subscription.start(closure)
        }
    }

}

extension Subscriptions {
    final class ClosureBased<S: Subscriber, Output, Failure>: Subscription where S.Input == Output, Failure == S.Failure {

        private var subscriber: S?

        init(subscriber: S) {
            self.subscriber = subscriber
        }

        func start(_ closure: @escaping (AnySubscriber<Output, Failure>) -> Void) {
            if let subscriber = subscriber {
                closure(AnySubscriber(subscriber))
            }
        }

        func request(_ demand: Subscribers.Demand) {}

        func cancel() {
            self.subscriber = nil
        }
    }
}
