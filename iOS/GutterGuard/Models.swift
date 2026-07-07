import Foundation

struct GutterGuardItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var detail: String
    var extra: String
    var date: Date
    var photoData: Data? = nil
}
