import Foundation

struct EventTask: Identifiable, Hashable, Codable {
    var id = UUID()
    var text: String
    var isCompleted = false
    var isNew = false
}
