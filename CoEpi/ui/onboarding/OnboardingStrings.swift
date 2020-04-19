import Foundation
import UIKit

struct OnboardingStrings {
    
    static let howYourDataIsUsed = NSLocalizedString("onboarding.howDataUsed", value: "How your data is used", comment: "Button")
    static let getStarted = NSLocalizedString("onboarding.getStarted", value: "Get Started", comment: "Button")
    static let collaborate = NSLocalizedString("onboarding.logo", value: "Collaborate. Inform. Protect.", comment: "Logo")
    
    static func makeAttributedTrack() -> NSMutableAttributedString {
        let newString = NSMutableAttributedString()
        newString.append(makeLight(NSLocalizedString("onboarding.track.pre", value: "", comment: "Before bold")))
        newString.append(makeBold(NSLocalizedString("onboarding.track.main", value: "Track", comment: "Bold part")))
        newString.append(makeLight(NSLocalizedString("onboarding.track.post", value: " where you've been", comment: "After bold")))
        return newString
    }
    
    static func makeAttributedMonitor() -> NSMutableAttributedString {
         let newString = NSMutableAttributedString()
        newString.append(makeLight(NSLocalizedString("onboarding.monitor.pre", value: "", comment: "Before bold")))
        newString.append(makeBold(NSLocalizedString("onboarding.monitor.main", value: "Monitor", comment: "Bold part")))
        newString.append(makeLight(NSLocalizedString("onboarding.monitor.post", value: " your health", comment: "After bold")))
         return newString
    }
    
    static func makeAttributedAlerts() -> NSMutableAttributedString {
       let newString = NSMutableAttributedString()
        newString.append(makeLight(NSLocalizedString("onboarding.alerts.pre", value: "Get ", comment: "Before bold")))
        newString.append(makeBold(NSLocalizedString("onboarding.alerts.main", value: "contextualized alerts", comment: "Bold part")))
        newString.append(makeLight(NSLocalizedString("onboarding.alerts.post", value: " about possible exposure to infectious illness", comment: "After bold")))
        return newString
    }
    
    static func makeBold(_ txt: String) -> NSAttributedString {
        NSAttributedString(string: txt, attributes: [NSAttributedString.Key.font: Fonts.robotoBold])
    }
    
    static func makeLight(_ txt: String) -> NSAttributedString {
        NSAttributedString(string: txt, attributes: [NSAttributedString.Key.font: Fonts.robotoLight])
    }
    
    
}
