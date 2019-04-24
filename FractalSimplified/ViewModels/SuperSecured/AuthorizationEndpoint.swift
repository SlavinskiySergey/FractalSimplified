//
//  AuthorizationEndpoint.swift
//  FractalSimplified
//
//  Created by Siarhei Slavinski on 4/24/19.
//  Copyright © 2019 Sergey Slavinskiy. All rights reserved.
//

import RxSwift

typealias Token = String

final class AuthorizationEndpoint {
    
    let apply: (() -> Observable<Token>)
    
    init() {
        var runCount = 0
        self.apply = {
            print("Authorization request fired \(runCount).")
            runCount += 1
            
            if runCount > 2 {
                return Observable<Token>.request(element: "Some Token")
            } else if runCount % 2 == 0 {
                return Observable.request(error: APIError.noInternet)
            } else {
                return Observable.request(error: APIError.service)
            }
        }
    }
}
