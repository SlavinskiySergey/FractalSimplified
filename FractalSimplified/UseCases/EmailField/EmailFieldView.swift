import UIKit
import RxSwift

struct EmailFieldPresenters {
    let placeholder: Presenter<String>
    let sink: Presenter<(String?) -> Void>
}

extension UITextField {
    
    var emailPresenters: Presenter<AnyPresentable<EmailFieldPresenters>> {
        return Presenter.UI { [weak self] (presentable) -> Disposable in
            guard let someSelf = self else {
                return Disposables.create()
            }
            
            return presentable.present(EmailFieldPresenters(
                placeholder: someSelf.placeholderPresenter,
                sink: someSelf.textSinkPresenter
            ))
        }
    }
    
}
