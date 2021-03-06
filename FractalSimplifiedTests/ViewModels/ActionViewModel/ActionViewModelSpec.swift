import Foundation
import Quick
import Nimble
import RxSwift

@testable import FractalSimplified

final class ActionViewModelSpec: QuickSpec {
    
    override func spec() {
        
        describe("ActionViewModel") {
            
            typealias SUT = ActionViewModel
            
            var sut: SUT!
            var view: SUT.TestView!
            var mock: ActionMock<Void, Void>!
            
            beforeEach {
                mock = ActionMock()
                sut = SUT(action: mock.action)
                view = SUT.TestView(AnyPresentable(sut))
            }
            
            afterEach {
                sut = nil
                view = nil
                mock = nil
            }
            
            it("enables the action") {
                expect(view.enabled) == true
            }
            
            it("does not execute the action") {
                expect(view.executing) == false
            }
            
            describe("when the action is executed") {
                
                beforeEach {
                    view.simpleAction()
                }
                
                it("disables the action") {
                    expect(view.enabled) == false
                }
                
                it("executes the action") {
                    expect(view.executing) == true
                }
                
                describe("when a value is received") {
                    
                    beforeEach {
                        mock.receive(Void())
                    }
                    
                    it("enables action back") {
                        expect(view.enabled) == true
                    }
                    
                    it("does not execute the action") {
                        expect(view.executing) == false
                    }
                }
            }
        }
    }
}
