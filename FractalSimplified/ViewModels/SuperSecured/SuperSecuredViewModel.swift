//
//  SuperSecuredViewModel.swift
//  FractalSimplified
//
//  Created by Siarhei Slavinski on 4/24/19.
//  Copyright © 2019 Sergey Slavinskiy. All rights reserved.
//

import Foundation
import RxSwift
import Action

final class SuperSecuredScreen {
    
    init() {
        let authorizationEndpoint = AuthorizationEndpoint()
        let biographyEndpoint = SuperSecuredEndpoint()
        
        let authorizationAction = Action<Void, Token> { _ in
            return authorizationEndpoint.apply()
        }
        
        let biographyAction = Action<Token, SuperSecuredData> {
            return biographyEndpoint.apply($0)
        }
        
        let enabledIf = authorizationAction.enabled
            .flatMapLatest { authorizationEnabled -> Observable<Bool> in
                switch authorizationEnabled {
                case false:
                    return BehaviorSubject<Bool>(value: authorizationEnabled)
                case true:
                    return biographyAction.enabled
                }
            }
            .distinctUntilChanged()
        
        let action = Action<Void, SuperSecuredData>(enabledIf: enabledIf) { _ -> Observable<SuperSecuredData> in
            authorizationAction.execute()
                .flatMapLatest { token -> Observable<SuperSecuredData> in
                    biographyAction.execute(token)
                }
            }
    
        let retryableAction = RetryableAction(original: action)
    
        let state = retryableAction.makeOneShotStateStream(input: ())
        self.child = state.map(SuperSecuredScreenChild.init)
    }

    private let child: Observable<SuperSecuredScreenChild>
}

enum SuperSecuredScreenChild {
    case content(SuperSecuredData)
    case alert(Alert)
    case error(String)
    case loading
}

extension SuperSecuredScreen: Presentable {
    
    var present: (SuperSecuredScreenPresenters) -> Disposable? {
        return { [weak self] presenters in
            guard let sself = self else {
                return nil
            }
            
            return CompositeDisposable(disposables: [
                presenters.child.present(sself.child.map { SuperSecuredScreenChildAnyPresentable($0) })
                ]
                .compactMap { $0 }
            )
        }
    }
}

extension SuperSecuredScreenChildAnyPresentable {
    
    init(_ value: SuperSecuredScreenChild) {
        switch value {
        case .content(let item):
            self = .content(item)
        case .alert(let item):
            self = .alert(item)
        case .error(let item):
            self = .error(item)
        case .loading:
            self = .loading
        }
    }
}

private extension SuperSecuredScreenChild {
    
    init(_ state: LoadingState<SuperSecuredData>) {
        switch state {
        case let .error(retryable):
            guard let error = retryable.error as? APIError else {
                self = .error("unknown error")
                return
            }
            let alert = makeAlert(
                error: error,
                retry: error.isRetryable ? retryable.retry : nil,
                ignore: retryable.ignore
            )
            self = .alert(alert)
        case let .ignored(error):
            self = .error(error.reason)
        case let .loaded(value):
            self = .content(value)
        case .loading:
            self = .loading
        }
    }
}

private extension LoadingState {
    
    var alert: Alert? {
        switch self {
        case let .error(retryable):
            guard let error = retryable.error as? APIError else {
                return nil
            }
            return makeAlert(
                error: error,
                retry: error.isRetryable ? retryable.retry : nil,
                ignore: retryable.ignore
            )
        case .ignored, .loading, .loaded:
            return nil
        }
    }
}

private func makeAlert(
    error: APIError,
    retry: (() -> Void)? = nil,
    ignore: (() -> Void)? = nil
    ) -> Alert {
    return Alert(
        title: "Error",
        message: error.reason,
        primary: retry.map {
            AlertAction(title: "Retry", style: .highlighted, action: $0)
        },
        cancel: ignore.map {
            AlertAction(title: "Ignore", style: .destructive, action: $0)
        }
    )
}

private extension APIError {
    
    var isRetryable: Bool {
        switch self {
        case .noInternet, .service: return true
        case .notAllowed: return false
        }
    }
    
    var reason: String {
        switch self {
        case .noInternet: return "Connectivity issue, please check your internet connection."
        case .service: return "Service error, sometimes even the best let us down."
        case .notAllowed: return "Request is not allowed, are you a cool-hacker?"
        }
    }
}
