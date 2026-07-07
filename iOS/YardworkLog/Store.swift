import Foundation
import Combine

final class Store: ObservableObject {
    static let freeLimit = 12

    @Published private(set) var entries: [Entry] = []
    @Published var categoryFilterEnabled: Bool = true

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("YardworkLog", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("entries.json")
        load()
    }

    func add(_ entry: Entry, isPro: Bool) -> Bool {
        if !isPro && entries.count >= Store.freeLimit {
            return false
        }
        entries.insert(entry, at: 0)
        save()
        return true
    }

    func update(_ entry: Entry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: Entry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    func canAddMore(isPro: Bool) -> Bool {
        isPro || entries.count < Store.freeLimit
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([Entry].self, from: data) {
            entries = decoded
        } else {
            entries = Store.seedData()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: fileURL)
        }
    }

    static func seedData() -> [Entry] {
        let cal = Calendar.current
        return (0..<3).map { i in
            Entry(
                taskName: "Sample {i + 1}",
                date: cal.date(byAdding: .day, value: -(i * 3 + 1), to: Date()) ?? Date(),
                note: "Sample note {i + 1}"
            )
        }
    }
}
