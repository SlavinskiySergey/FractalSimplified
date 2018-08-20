import Foundation
import Quick
import Nimble

@testable import FractalSimplified

final class WelcomeScreenSpec: QuickSpec {
    
    override func spec() {
        
        describe("WelcomeScreen") {
            
            typealias SUT = WelcomeScreenUseCase
            
            var sut: SUT!
            var view: SUT.TestView!
            
            beforeEach {
                sut = SUT()
                view = SUT.TestView(AnyPresentable(sut))
            }
            
            afterEach {
                sut = nil
                view = nil
            }
            
            it("presents correct titles") {
                expect(view.title) == "Welcome"
                expect(view.signUpTitle) == "Sign Up"
            }
            
            it("does not show the Sign Up screen") {
                expect(view.signUpScreen).to(beNil())
            }
            
            describe("when a user taps the 'Sign Up' button") {
                
                beforeEach {
                    view.signUpAction.simpleAction()
                }
                
                it("shows the Sign Up screen") {
                    expect(view.signUpScreen).toNot(beNil())
                }
                
                describe("when a user goes back") {
                    
                    beforeEach {
                        view.signUpScreen.backSink()
                    }
                    
                    it("does not show the Sign Up screen") {
                        expect(view.signUpScreen).to(beNil())
                    }
                }
            }
        }
    }
}
