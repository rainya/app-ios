import Foundation
import RxSwift
import os.log

protocol SymptomRepo {
    func symptoms() -> [Symptom]

    func submitSymptoms(symptoms: [Symptom]) -> Completable
}

class SymptomRepoImpl: SymptomRepo {
    private let coEpiRepo: CoEpiRepo

    init(coEpiRepo: CoEpiRepo) {
        self.coEpiRepo = coEpiRepo
    }

    private var symptomsData: [Symptom] = [
        Symptom(id: "1", name: NSLocalizedString("symptom.fever", value: "My Fever", comment: "Symptom")),
        Symptom(id: "2", name: NSLocalizedString("symptom.tiredness", value: "Tiredness", comment: "Symptom")),
        Symptom(id: "3", name: NSLocalizedString("symptom.dryCough", value: "Dry cough", comment: "Symptom")),
        Symptom(id: "4", name: NSLocalizedString("symptom.muscleAches", value: "Muscle aches", comment: "Symptom")),
        Symptom(id: "5", name: NSLocalizedString("symptom.nasalCongestion", value: "Nasal congestion", comment: "Symptom")),
        Symptom(id: "6", name: NSLocalizedString("symptom.runnyNose", value: "Runny nose", comment: "Symptom")),
        Symptom(id: "7", name: NSLocalizedString("symptom.soreThroat", value: "Sore throat", comment: "Symptom")),
        Symptom(id: "8", name: NSLocalizedString("symptom.diarrhea", value: "Diarrhea", comment: "Symptom")),
        Symptom(id: "9", name: NSLocalizedString("symptom.difficultyBreathing", value: "Difficulty breathing", comment: "Symptom")),
        Symptom(id: "10", name: NSLocalizedString("symptom.lossOfSmellTaste", value: "Loss of smell/taste", comment: "Symptom")),
        Symptom(id: "11", name: NSLocalizedString("symptom.none", value: "None of the Above", comment: "Symptom"))
    ]
    
    func symptoms() -> [Symptom] {
        symptomsData
    }

    func submitSymptoms(symptoms: [Symptom]) -> Completable {
        if let cenReport = symptoms.toCENReport() {
            return coEpiRepo.sendReport(report: cenReport)
        } else {
            os_log("Couldn't encode symptoms: %@ to Base64", log: servicesLog, type: .debug, "\(symptoms)")
            return Completable.error(RepoError.unknown)
        }
    }
}

private extension Sequence where Iterator.Element == Symptom {
    func toCENReport() -> CenReport? {
        let stringReport : String  = map { $0.name }.joined(separator: ", ")
        return CenReport(id: UUID().uuidString, report: stringReport, timestamp: Date().coEpiTimestamp)
    }
}
