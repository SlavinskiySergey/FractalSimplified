import UIKit
import RxSwift

struct WelcomeScreenPresenters {
    let title: Presenter<String>
    let signUpTitle: Presenter<String>
    let signUpAction: Presenter<AnyPresentable<ActionViewModelPresenters>>
    let signUpScreen: Presenter<AnyPresentable<SignUpScreenPresenters>?>
    let securedTitle: Presenter<String>
    let securedAction: Presenter<AnyPresentable<ActionViewModelPresenters>>
    let securedScreen: Presenter<AnyPresentable<SuperSecuredScreenPresenters>?>

}

final class WelcomeViewController: UIViewController {
    
    static func create() -> WelcomeViewController {
        let vc = WelcomeViewController()
        vc.loadViewIfNeeded()
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        [self.titleLabel, self.signUpButton, self.securedButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0)
        }
        NSLayoutConstraint.activate([
            self.titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 16),
            self.signUpButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.signUpButton.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 16),
            self.signUpButton.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.bottomAnchor, constant: -36),
            self.securedButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.securedButton.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 16),
            self.securedButton.bottomAnchor.constraint(equalTo: self.signUpButton.bottomAnchor, constant: -72)
            ])
    }
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        return label
    }()
    fileprivate let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title2)
        return button
    }()
    fileprivate let securedButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title2)
        return button
    }()
    
    private init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
}

extension WelcomeViewController {
    var presenter: Presenter<AnyPresentable<WelcomeScreenPresenters>> {
        return Presenter.UI { [weak self] presentable in
            guard let someSelf = self else {
                return nil
            }
            return presentable.present(WelcomeScreenPresenters(
                title: someSelf.titleLabel.textPresenter,
                signUpTitle: someSelf.signUpButton.titlePresenter,
                signUpAction: someSelf.signUpButton.actionViewModelPresenter,
                signUpScreen: someSelf.signUpScreenPresenter,
                securedTitle: someSelf.securedButton.titlePresenter,
                securedAction: someSelf.securedButton.actionViewModelPresenter,
                securedScreen: someSelf.superSecuredScreenPresenter
            ))
        }
    }
}

extension UIViewController {
    var signUpScreenPresenter: Presenter<AnyPresentable<SignUpScreenPresenters>?> {
        return Presenter.UI { [weak self] presentable in
            guard let someSelf = self else {
                return nil
            }
            switch presentable {
            case let .some(presentable):
                let vc = SignUpViewController.create()
                
                let disposables = [
                    vc.presenter.present(presentable),
                    Disposables.create(with: { someSelf.dismiss(animated: true, completion: nil) })
                    ]
                    .compactMap { $0 }
                
                someSelf.present(vc, animated: true, completion: nil)
                
                return CompositeDisposable(disposables: disposables)
            case .none:
                return nil
            }
        }
    }
    
    var superSecuredScreenPresenter: Presenter<AnyPresentable<SuperSecuredScreenPresenters>?> {
        return Presenter.UI { [weak self] presentable in
            guard let someSelf = self else {
                return nil
            }
            
            switch presentable {
            case let .some(presentable):
                let vc = SuperSecuredViewController.create()
                
                let disposables = [
                    vc.presenter.present(presentable),
                    Disposables.create(with: { someSelf.dismiss(animated: true, completion: nil) })
                    ]
                    .compactMap { $0 }
                
                someSelf.present(vc, animated: false, completion: nil)
                
                return CompositeDisposable(disposables: disposables)
            case .none:
                return nil
            }

        }
    }
}
