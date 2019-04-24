import UIKit
import RxSwift
import RxCocoa

extension UIButton {
    
    var simpleActionPresenter: Presenter<() -> Void> {
        return Presenter.UI { [weak self] (action) -> Disposable? in
            guard let someSelf = self else {
                return nil
            }
            
            return someSelf.rx.tap.subscribe { (event) in
                action()
            }
        }
    }
    
    var actionViewModelPresenter: Presenter<AnyPresentable<ActionViewModelPresenters>> {
        return Presenter.UI { [weak self] (presentable) -> Disposable? in
            guard let someSelf = self else {
                return nil
            }
            
            return presentable.present(ActionViewModelPresenters(
                simpleAction: someSelf.simpleActionPresenter,
                executing: Presenter.UI { _ in nil },
                enabled: someSelf.enabledPresenter
                )
            )
        }
    }
    
    var titlePresenter: Presenter<String> {
        return Presenter.UI { [weak self] in
            self?.setTitle($0, for: .normal)
            return nil
        }
    }
    
    var enabledPresenter: Presenter<Bool> {
        return Presenter.UI { [weak self] in
            self?.isEnabled = $0
            return nil
        }
    }
    
}

struct ActionViewModelPresenters {
    let simpleAction: Presenter<() -> Void>
    let executing: Presenter<Bool>
    let enabled: Presenter<Bool>
}
