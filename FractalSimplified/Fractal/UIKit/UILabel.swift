import UIKit
import RxSwift

extension UILabel {
    
    var textPresenter: Presenter<String> {
        return Presenter.UI { [weak self] (value) -> Disposable in
            self?.text = value
            return Disposables.create()
        }
    }
    
    var optionalTextPresenter: Presenter<String?> {
        return Presenter.UI { [weak self] (value) -> Disposable in
            self?.text = value
            return Disposables.create()
        }
    }
    
}
