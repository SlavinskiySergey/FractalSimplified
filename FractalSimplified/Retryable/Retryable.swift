//
//  Retryable.swift
//  FractalSimplified
//
//  Created by Siarhei Slavinski on 4/24/19.
//  Copyright © 2019 Sergey Slavinskiy. All rights reserved.
//

import RxSwift
import Action

struct Retryable: Error {
    public let error: Error
    public let retry: () -> Void
    public let ignore: () -> Void
}

struct RetryableAction<Input, Element> {
    
    let action: Action<Input, Element>
    let error: BehaviorSubject<Retryable?> = BehaviorSubject(value: nil)
    
    private let bag = DisposeBag()
    
    init(original: Action<Input, Element>) {
        
        let retryable = original.retryable()
        
        self.action = retryable.action
        
        retryable.retryable
            .bind(to: error)
            .disposed(by: bag)
    }
}

extension Action {
    
    func retryable() -> (action: Action<Input, Element>, retryable: Observable<Retryable>) {
        
        let inner = Action<Input, RetryableNext<Element>>(enabledIf: self.enabled) {
            return self.execute($0).retryable()
        }
        
        let action = Action<Input, Element>(enabledIf: inner.enabled) {
            return inner.execute($0)
                .materialize()
                .concatMap { (event) -> Observable<Element> in
                    switch event {
                    case let .next(.some(element)):
                        return Observable.just(element)
                    case .error(let error):
                        return Observable.error(error)
                    case .completed, .next(.error), .next(.retrying):
                        return .empty()
                    }
            }
        }
        
        let retryable = inner.elements
            .map { $0.error }
            .filterNil()
        
        return (action, retryable)
    }
}

private enum RetryableNext<T> {
    
    case some(T)
    case error(Retryable)
    case retrying
    
    var value: T? {
        if case let .some(value) = self {
            return value
        } else {
            return nil
        }
    }
    
    var error: Retryable? {
        if case let .error(retryable) = self {
            return retryable
        } else {
            return nil
        }
    }
    
    var retrying: Bool {
        if case .retrying = self {
            return true
        } else {
            return false
        }
    }
}

private extension ObservableType {
    
    func retryable() -> Observable<RetryableNext<E>> {
        
        return Observable<RetryableNext<E>>.create { observer -> Disposable in
            
            let retryStream = PublishSubject<Void>()
            let valuesStream = PublishSubject<E>()
            
            typealias RetryableObservable = Observable<RetryableNext<E>>
            let processedErrorsStream = PublishSubject<RetryableObservable>()
            
            let queueStream = PublishSubject<RetryableNext<E>>()
            
            let selfWithSideEffects = self
                .do(onNext: valuesStream.onNext)
                .do(onCompleted: observer.onCompleted)
                .do(onError: { innerError in
                    let retryableError = RetryableNext<E>.error(
                        Retryable(
                            error: innerError,
                            retry: {
                                processedErrorsStream.onNext(RetryableObservable.just(.retrying))
                                retryStream.onNext(())
                        },
                            ignore: {
                                queueStream.onError(innerError)
                        }
                        )
                    )
                    processedErrorsStream
                        .onNext(RetryableObservable.just(retryableError)
                            .concat(queueStream.asObservable().take(1)))
                })
                .completeOnError()
            
            let mergeDisposable = Observable<RetryableNext<E>>.merge([
                processedErrorsStream.flatMapLatest { return $0 },
                valuesStream.map(RetryableNext<E>.some)
                ])
                .subscribe(observer)
            
            let retryDisposable = retryStream.flatMapLatest {
                selfWithSideEffects
                }
                .subscribe()
            
            retryStream.onNext(())
            
            return CompositeDisposable(mergeDisposable, retryDisposable)
        }
    }
}

enum LoadingState<Element> {
    case loading
    case loaded(Element)
    case error(Retryable)
    case ignored(APIError)
}

extension RetryableAction {
    
    func makeOneShotStateStream(input: Input) -> Observable<LoadingState<Element>> {
        let error: Observable<LoadingState<Element>?> = self.error.map { $0.map(LoadingState.error) }
        
         let loading: Observable<LoadingState<Element>?> = self.action.executing.map { $0 ? .loading : nil }
        
        let content: Observable<LoadingState<Element>?> = self.action.execute(input)
            .map(LoadingState.loaded)
            .catchError { Observable.just(($0 as? APIError).map(LoadingState.ignored)) }
            .startWith(nil)
        
        return nilCoalescingFlatMap(error, loading, content)
            .map { $0 ?? .loading }
    }
}

extension RetryableAction where Input == Void {
    
    func makeOneShotStateStream() -> Observable<LoadingState<Element>> {
        return makeOneShotStateStream(input: ())
    }
}
