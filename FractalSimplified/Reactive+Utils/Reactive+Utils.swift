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
    
    func filterNil<Type>() -> Observable<Type> where E == Optional<Type> {
        return flatMap { Observable.from(optional: $0) }
    }
}

func nilCoalescingFlatMap<T>(_ observables: [Observable<T?>]) -> Observable<T?> {
    guard let first = observables.first else { return BehaviorSubject(value: nil) }
    
    
    return first
        .filterNil()
        .flatMapLatest { (value: T?) -> Observable<T?> in
            switch value {
            case let some?:
                return BehaviorSubject(value: some).map(Optional.init)
            case nil:
                return nilCoalescingFlatMap(Array(observables.suffix(from: 1)))
            }
    }
}

func nilCoalescingFlatMap<T>(_ observables: Observable<T?>...) -> Observable<T?> {
    return nilCoalescingFlatMap(observables)
}
