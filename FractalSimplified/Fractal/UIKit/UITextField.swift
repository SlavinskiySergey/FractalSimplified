import UIKit
import RxSwift

extension UITextField {
    
    var textSinkPresenter: Presenter<(String?) -> Void> {
        return Presenter.UI { [weak self] (sink) -> Disposable? in
            guard let someSelf = self else {
                return nil
            }
            let didChangeObserver = someSelf.createDidChangeObserver(with: sink)
            return Disposables.create {
                NotificationCenter.default.removeObserver(didChangeObserver)
            }
        }
    }
    
    var placeholderPresenter: Presenter<String> {
        return Presenter.UI { [weak self] string in
            self?.placeholder = string
            return nil
        }
    }
    
    private func createDidChangeObserver(with handler: @escaping (String?) -> Void) -> NSObjectProtocol {
        return NotificationCenter.default
            .addObserver(
                forName: NSNotification.Name.UITextFieldTextDidChange,
                object: self,
                queue: nil,
                using: { [weak self] _ in
                    handler(self?.text)
                }
        )
    }
    
}
