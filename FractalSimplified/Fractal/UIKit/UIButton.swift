import UIKit
import RxSwift
import RxCocoa

extension UIButton {
    
    var simpleActionPresenter: Presenter<() -> Void> {
        return Presenter.UI { [weak self] (action) -> Disposable in
            guard let someSelf = self else {
                return Disposables.create()
            }
            
            return someSelf.rx.tap.subscribe { (event) in
                action()
            }
        }
    }
    
    var actionViewModelPresenter: Presenter<AnyPresentable<ActionViewModelPresenters>> {
        return Presenter.UI { [weak self] (presentable) -> Disposable in
            guard let someSelf = self else {
                return Disposables.create()
            }
            
            return presentable.present(ActionViewModelPresenters(
                simpleAction: someSelf.simpleActionPresenter,
                executing: Presenter.UI { _ in Disposables.create() },
                enabled: someSelf.enabledPresenter
                )
            )
        }
    }
    
    var titlePresenter: Presenter<String> {
        return Presenter.UI { [weak self] in
            self?.setTitle($0, for: .normal)
            return Disposables.create()
        }
    }
    
    var enabledPresenter: Presenter<Bool> {
        return Presenter.UI { [weak self] in
            self?.isEnabled = $0
            return Disposables.create()
        }
    }
    
}

struct ActionViewModelPresenters {
    let simpleAction: Presenter<() -> Void>
    let executing: Presenter<Bool>
    let enabled: Presenter<Bool>
}
