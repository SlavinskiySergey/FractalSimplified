import Foundation
import RxSwift
import Quick
import Nimble

@testable import FractalSimplified

final class SignUpScreenViewModelSpec: QuickSpec {
    
    override func spec() {
        
        describe("SignUpScreen") {
            
            typealias SUT = SignUpScreenViewModel
            
            var sut: SUT!
            var view: SUT.TestView!
            var resultHistory: Observable<SUT.Result>.History!
            var disposable: Disposable!
            
            beforeEach {
                sut = SUT()
                view = SUT.TestView((AnyPresentable(sut)))
                resultHistory = Observable<SUT.Result>.History()
                disposable = sut.result.saveHistoryTo(resultHistory).subscribe()
            }
            
            afterEach {
                disposable.dispose()
                disposable = nil
                resultHistory = nil
                sut = nil
                view = nil
            }
            
            it("presents correct titles") {
                expect(view.title) == "Sign Up"
                expect(view.backTitle) == "Back"
                expect(view.passwordPlaceholder) == "Password"
                expect(view.signUpTitle) == "Sign Up"
            }
            
            it("does not have any result") {
                expect(resultHistory.elements.count) == 0
            }
            
            describe("when a user taps the back button") {
                
                beforeEach {
                    view.backSink()
                }
                
                it("has 'back' result") {
                    expect(resultHistory.elements) == [.back]
                }
            }
            
            it("disables the sign up action") {
                expect(view.signUpAction.enabled) == false
            }
            
            describe("when a user enters valid email") {
                
                beforeEach {
                    view.email.sink("some@email.com")
                }
                
                it("disables the sign up action") {
                    expect(view.signUpAction.enabled) == false
                }
                
                describe("when a user enters a short password") {

                    beforeEach {
                        view.passwordSink("12345")
                    }

                    it("disables the sign up action") {
                        expect(view.signUpAction._enabled.presented.map { $0.value.value }) == [false, false]
                    }
                }
                
                describe("when a user enters a long password") {
                    
                    beforeEach {
                        view.passwordSink("123456")
                    }
                    
                    it("enables the sign up action") {
                        expect(view.signUpAction.enabled) == true
                    }
                }
            }
        }
    }
}

