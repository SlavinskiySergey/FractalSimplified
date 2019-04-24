//
//  SuperSecuredEndpoint.swift
//  FractalSimplified
//
//  Created by Siarhei Slavinski on 4/24/19.
//  Copyright © 2019 Sergey Slavinskiy. All rights reserved.
//

import RxSwift

typealias SuperSecuredData = String

final class SuperSecuredEndpoint {
    
    let apply: ((Token) -> Observable<SuperSecuredData>)
    
    init() {
        var runCount = 0
        self.apply = { token in
            print("Super secured request fired \(runCount) with token \(token)")
            runCount += 1
            
            if runCount > 1 {
                return Observable.request(element: "Attention, super secured data, mum's the word!!!")
            } else if runCount % 2 == 0 {
                return Observable.request(error: APIError.notAllowed)
            } else {
                return Observable.request(error: APIError.service)
            }
        }
    }
}

