import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var items: [GutterGuardItem] = []
    @Published var isPro: Bool = false

    /// Free tier limit. Kept comfortably above seed count so a fresh install
    /// never immediately hits the paywall.
    static let freeLimit = 6

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("gutterguard_items.json")
        load()
    }

    var canAddMore: Bool {
        isPro || items.count < Store.freeLimit
    }

    func add(_ item: GutterGuardItem) {
        items.append(item)
        save()
    }

    func update(_ item: GutterGuardItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: GutterGuardItem) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func seedIfNeeded() -> [GutterGuardItem] {
        [
            GutterGuardItem(name: "Front Gutter", detail: "Clear", extra: "No debris found", date: Date()),
            GutterGuardItem(name: "Back Gutter", detail: "Minor Leaves", extra: "Some leaves cleared", date: Date()),
            GutterGuardItem(name: "Side Gutter", detail: "Clear", extra: "Checked downspout", date: Date())
        ]
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([GutterGuardItem].self, from: data) else {
            items = seedIfNeeded()
            save()
            return
        }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
