//
//  Reactive+Utils.swift
//  FractalSimplified
//
//  Created by Siarhei Slavinski on 4/24/19.
//  Copyright © 2019 Sergey Slavinskiy. All rights reserved.
//

import RxSwift
import Action

extension Action {
    
    static func simple(
        enabledIf enabled: BehaviorSubject<Bool> = BehaviorSubject(value: true),
        f: @escaping () -> Void = {}
    ) -> Action {
        return Action(enabledIf: enabled) { _ in
            return Observable<Element>.create { observable -> Disposable in
                f()
                observable.onCompleted()
                return Disposables.create()
            }
        }
    }
}

extension ObservableType {
    
    func completeOnError() -> Observable<E> {
        return self.catchError { _ in .empty() }
    }
    
    func expectedToBeEnabled() -> Observable<E> {
        return self.catchError { error in
            guard let actionError = error as? ActionError else {
                return Observable.error(error)
            }
            
            switch actionError {
            case .notEnabled:
                assertionFailure()
                return .empty()
            case .underlyingError(let e):
                return Observable.error(e)
            }
        }
    }
}

protocol OptionalType {
    associatedtype Wrapped
    
    var optional: Wrapped? { get }
}

extension Optional: OptionalType {
    public var optional: Wrapped? {
        return self
    }
}

extension ObservableType where E: OptionalType {
    
    func filterNil() -> Observable<E.Wrapped> {
        return flatMap { Observable.from(optional: $0.optional) }
    }
    
    func skipNilRepeats() -> Observable<Self.E> {
        return self.distinctUntilChanged { $0.optional == nil && $1.optional == nil }
    }
}

func nilCoalescingFlatMap<T>(_ observables: [Observable<T?>]) -> Observable<T?> {
    guard let first = observables.first else {
        return Observable.just(nil)
    }
    
    return first
        .skipNilRepeats()
        .flatMapLatest { (value: T?) -> Observable<T?> in
            switch value {
            case let some?:
                return Observable.just(some).map(Optional.init)
            case nil:
                return nilCoalescingFlatMap(Array(observables.suffix(from: 1)))
            }
    }
}

func nilCoalescingFlatMap<T>(_ observables: Observable<T?>...) -> Observable<T?> {
    return nilCoalescingFlatMap(observables)
}
