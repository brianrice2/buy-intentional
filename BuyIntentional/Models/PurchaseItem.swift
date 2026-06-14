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
    var price: Double? = nil

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
    case waiting  = "waiting"
    case approved = "approved"
    case rejected = "rejected"

    var label: String {
        switch self {
        case .waiting:  return "Waiting"
        case .approved: return "Approved"
        case .rejected: return "Rejected"
        }
    }
}

struct ReflectionQuestion: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var question: String
    var answer: String = ""
    
    /*
     - Are you ready for the time spent doing this? You have not purchased many items after answering all these questions. Is this item your contemplating so life changing that it is even worth the time to go through this checklist?
     - "If item X is so necessary/desirably how come I've been able to live without it for N years so far?" -jacob
     - Does this item remove a specific negative from your life?
     - Have you wanted this item for more than a month? Evidence?
     - Pick a random Tuesday next year and how are you using this item? 5 days, 5 months, 5 years- vivid narrative about how you will use/enjoy?
     - Where specifically will this item be kept?
     - Will this item bring joy into your life and in what form?
     - Will this item simplify my life? How? Will it continue to simplify my life equally into the future?
     - How will this item change your daily, weekly, or monthly activities? Reminder that anything not used every 6 months is not necessary for your life.
     - Does this item add to or help me directly achieve one of my goals?
     - What goals would this item subtract from in maintenance time?
     - How was this item advertised to me?
     - Will I still need this item in 5 years from now? Specific example.
     - Can something that I already own substitute for this? Can it substitute for this 80% or greater.
     - If you had to solve the problem within an hour without spending additional money how would you?
     - What is the environmental impact of this item?
     - How would you properly care for this item? What is the time estimate and when would this maintenance occur?
     - What accessories are typically associated with this item? Stuff begets more stuff.
     - What is the future value of the money that would be used for this?
     - What is the generated monthly income that can come from the money used to purchase this?
     - Calculate the opportunity cost in Python:
             ```python
             cost = 1000
             timeline = 12
             interest = 1.07 # per year
             oppCost = cost * interest ** timeline
             print(oppCost)
             # 2252.191588960825
            ```
        This then begs the question, is this item worth more to you now than more than double in 12 years?
     - Can you easily afford two of these items? If you cannot, you cannot really afford a single one.
     - What am I comparing this item to? What individual attributes of the comparison am I making this decision on? Did I even know about these attributes before doing research on this item? Am I comparing based on what I have now or the comparison layed out in the shop.
     - Do people in my immediate friend or family group have this item? Is that how I came to learn about it?
     - Is this replacing an item? Does the item you are replacing still work? Would it work better if you spent your hourly rate time towards maintaining it?
     - Spending new money actually costs 1.x per dollar because of the taxes that we paid on this. Obviously these tax dollars go towards infrastructure allowing you to enjoy this item, but still an earned dollar in your hands is actually worth more than the face value.
     - Time is much more important than money. Money is a renewable resource. Time is not.
     - Could this money be donated to charity instead and have a meaningful impact on someone's life?
     */

    static let defaults: [ReflectionQuestion] = [
        ReflectionQuestion(question: "Do I need this, or do I want it?"),
        ReflectionQuestion(question: "Does it serve more than one purpose?"),
        ReflectionQuestion(question: "Do I already own something that does this job? Even 80% as well?"),
        ReflectionQuestion(question: "Where will it live in my home?"),
        ReflectionQuestion(question: "If this item is so necessary or desirable, how come I've been able to live so far without it?"),
        ReflectionQuestion(question: "Does this item remove a specific negative from my life?"),
        ReflectionQuestion(question: "How did I come to learn about this item? Was it advertised to me online? Do my friends or family have it?"),
        ReflectionQuestion(question: "How does this item support one of my goals? Does it work against any of my goals, like through reduced savings or time spent on maintenance?"),
        ReflectionQuestion(question: ""),
    ]
}
