import Foundation
import RxSwift
import RxCocoa

final class EmailFieldUseCase {
    
    enum Result {
        case valid(String)
        case invalid(String?)
    }
    
    let result = BehaviorRelay<Result>(value: .invalid(nil))
    
    init() {
        self.placeholder = "email"
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
    
    private let email = BehaviorRelay<String?>(value: nil)
    private let emailSubject = PublishSubject<String?>()
    
    private let disposeBag = DisposeBag()

}

extension EmailFieldUseCase: Presentable {
    
    var present: (EmailFieldPresenters) -> Disposable {
        return { [weak self] presenters in
            guard let someSelf = self else {
                return Disposables.create()
            }
            
            let placeholderDisposable = presenters.placeholder.present(someSelf.placeholder)
            let sinkDisposable = presenters.sink.present(someSelf.emailSink)
            
            return CompositeDisposable(placeholderDisposable, sinkDisposable)
        }
    }
    
}

private func makeResult(email: String?) -> EmailFieldUseCase.Result {
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
