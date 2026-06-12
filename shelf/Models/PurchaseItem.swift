import Foundation

// MARK: - Models

struct PurchaseItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var dateAdded: Date = Date()
    var status: PurchaseStatus = .waiting
    var notes: String = ""
    var links: [String] = []
    var questions: [ReflectionQuestion]

    init(name: String, questions: [ReflectionQuestion] = ReflectionQuestion.defaults) {
        self.name = name
        self.questions = questions
    }

    var daysSinceAdded: Int {
        Calendar.current.dateComponents([.day], from: dateAdded, to: Date()).day ?? 0
    }

    var answeredQuestionCount: Int {
        questions.filter { !$0.answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
    }
}

enum PurchaseStatus: String, Codable, CaseIterable {
    case waiting = "waiting"
    case approved = "approved"

    var label: String {
        switch self {
        case .waiting:  return "Waiting"
        case .approved: return "Approved"
        }
    }
}

struct ReflectionQuestion: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var question: String
    var answer: String = ""

    static let defaults: [ReflectionQuestion] = [
        ReflectionQuestion(question: "Do I need this, or do I want it?"),
        ReflectionQuestion(question: "Will I still want this in 30 days?"),
        ReflectionQuestion(question: "Does it serve more than one purpose?"),
        ReflectionQuestion(question: "Do I already own something that does this job?"),
        ReflectionQuestion(question: "Where will it live in my home?"),
    ]
}
