import Foundation
import RxSwift

final class EmailFieldViewModel {
    
    enum Result {
        case valid(String)
        case invalid(String?)
    }
    
    let result = BehaviorSubject<Result>(value: .invalid(nil))
    
    init() {
        self.placeholder = "Email"
        self.emailSink = emailSubject.onNext
        
        self.emailSubject
            .asObserver()
            .map(makeResult)
            .bind(to: self.result)
            .disposed(by: self.disposeBag)
        
        self.emailSubject
            .bind(to: self.email)
            .disposed(by: self.disposeBag)
    }
    
    private let placeholder: String
    private let emailSink: (String?) -> Void
    
    private let email = BehaviorSubject<String?>(value: nil)
    private let emailSubject = PublishSubject<String?>()
    
    private let disposeBag = DisposeBag()

}

extension EmailFieldViewModel: Presentable {
    
    var present: (EmailFieldPresenters) -> Disposable? {
        return { [weak self] presenters in
            guard let someSelf = self else {
                return nil
            }
            
            let disposables = [
                presenters.placeholder.present(someSelf.placeholder),
                presenters.sink.present(someSelf.emailSink)
                ]
                .compactMap { $0 }
            
            return CompositeDisposable(disposables: disposables)
        }
    }
    
}

extension EmailFieldViewModel.Result: Equatable {
    static func ==(lhs: EmailFieldViewModel.Result, rhs: EmailFieldViewModel.Result) -> Bool {
        switch (lhs, rhs) {
        case let (.valid(l), .valid(r)):
            return l == r
        case let (.invalid(l), .invalid(r)):
            return l == r
        case (.valid, _),
             (.invalid, _):
            return false
        }
    }
}

private func makeResult(email: String?) -> EmailFieldViewModel.Result {
    return email.map { $0.isValidEmail ? .valid($0) : .invalid($0) } ?? .invalid(email)
}

private extension String {
    var isValidEmail: Bool {
        let trimmed = self.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty && trimmed.rangeOfCharacter(from: .whitespaces) == nil else {
            return false
        }
        let emailRegEx = ".+@.+\\..+"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: trimmed)
    }
}
