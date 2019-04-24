//
//  Endpoint+Helpers.swift
//  FractalSimplified
//
//  Created by Siarhei Slavinski on 4/24/19.
//  Copyright © 2019 Sergey Slavinskiy. All rights reserved.
//

import RxSwift

enum APIError: Error {
    case noInternet
    case service
    case notAllowed
}

extension ObservableType {
    
    static func request(element: E) -> Observable<E> {
        return Observable.just(element)
            .delay(1, scheduler: SerialDispatchQueueScheduler(qos: .background))
    }
    
    static func request(error: Error) -> Observable<E> {
        return Observable<Void>.just(Void())
            .delay(1.5, scheduler: SerialDispatchQueueScheduler(qos: .background))
            .flatMapLatest { Observable.error(error) }
    }
}
