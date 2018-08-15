import Foundation
import RxSwift
import Action

final class SignUpScreenUseCase {
    
    enum Result {
        case back
    }
    
    let result = PublishSubject<Result>()
    
    init() {
        self.title = "Sign Up"
        self.backTitle = "Back"
        self.backSink = self.backSubject.onNext
        self.passwordPlaceholder = "Password"
        self.passwordSink = self.passwordSubject.onNext
        self.email = EmailFieldUseCase()
        self.backSubject.asObserver()
            .map { Result.back }
            .bind(to: self.result)
            .disposed(by: self.disposeBag)
        self.signUpTitle = "Sign Up"
        let validatedPassword = self.passwordSubject.asObserver()
            .map { $0.flatMap { $0.count > 5 ? $0 : nil } }
        let validatedEmail = self.email.result.asObservable()
            .map { (result) -> String? in
                switch result {
                case .valid(let email): return email
                case .invalid: return nil
                }
        }
        let credentials = Observable
            .combineLatest(validatedEmail, validatedPassword)
            .map { (email, password) -> Credentials? in
                guard let email = email, let password = password else {
                    return nil
                }
                return Credentials(email: email, password: password)
        }
        let signUpAction = Action<Void, Void>(
            enabledIf: credentials.map { $0 != nil },
            workFactory: { _ -> Observable<Void> in
                return credentials.flatMapLatest { (creds) -> Observable<Void> in
                    switch creds {
                    case .some(let value): return makeSignUpTask(credentials: value)
                    case .none: return Observable.empty()
                    }
                }
        })
        self.signUpAction = ActionViewModel(action: signUpAction)
    }
    
    private let title: String
    private let backTitle: String
    private let backSink: (Void) -> ()
    private let passwordPlaceholder: String
    private let passwordSink: (String?) -> Void
    private let email: EmailFieldUseCase
    private let signUpTitle: String
    private let signUpAction: ActionViewModel
    
    private let backSubject = PublishSubject<Void>()
    private let passwordSubject = PublishSubject<String?>()
    
    private let disposeBag = DisposeBag()
    
}

extension SignUpScreenUseCase: Presentable {
    
    var present: (SignUpScreenPresenters) -> Disposable {
        return { [weak self] presenters in
            guard let someSelf = self else {
                return Disposables.create()
            }
            let titleDisposable = presenters.title.present(someSelf.title)
            let backTitleDisposable = presenters.backTitle.present(someSelf.backTitle)
            let backSinkDisposable = presenters.backSink.present(someSelf.backSink)
            let passwordPlaceholderDisposable = presenters.passwordPlaceholder.present(someSelf.passwordPlaceholder)
            let passwordSinkDisposable = presenters.passwordSink.present(someSelf.passwordSink)
            let emailDisposable = presenters.email.present(someSelf.email)
            let signUpTitleDisposable = presenters.signUpTitle.present(someSelf.signUpTitle)
            let signUpActionDisposable = presenters.signUpAction.present(someSelf.signUpAction)
            
            return CompositeDisposable(disposables: [titleDisposable, backTitleDisposable, backSinkDisposable, passwordPlaceholderDisposable, passwordSinkDisposable, emailDisposable, signUpTitleDisposable, signUpActionDisposable])
        }
    }
}


private typealias Credentials = (email: String, password: String)

private func makeSignUpTask(credentials: Credentials) -> Observable<Void> {
    print("🚨 Singned Up! Email: \(credentials.email), Password: \(credentials.password)")
    return Observable.empty()
}
