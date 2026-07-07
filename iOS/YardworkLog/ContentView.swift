import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager

    @State private var showAddSheet = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingEntry: Entry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.entries.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundColor(Theme.secondaryText)
                        Text("No entries yet")
                            .font(Theme.headlineFont)
                            .foregroundColor(Theme.primaryText)
                        Text("Tap + to log your first one.")
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.secondaryText)
                    }
                } else {
                    List {
                        ForEach(store.entries) { entry in
                            Button {
                                editingEntry = entry
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.taskName)
                                        .font(Theme.headlineFont)
                                        .foregroundColor(Theme.primaryText)
                                    Text(entry.date, style: .date)
                                        .font(Theme.captionFont)
                                        .foregroundColor(Theme.secondaryText)
                                    if !entry.note.isEmpty {
                                        Text(entry.note)
                                            .font(Theme.captionFont)
                                            .foregroundColor(Theme.secondaryText)
                                    }
                                }
                            }
                            .listRowBackground(Theme.card)
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Yardwork Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore(isPro: purchases.isPro) {
                            showAddSheet = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                EntryFormView(entry: nil) { newEntry in
                    _ = store.add(newEntry, isPro: purchases.isPro)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryFormView(entry: entry) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
        .tint(Theme.accent)
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) var dismiss
    @State var fieldValue: String
    @State var date: Date
    @State var note: String

    let entryID: UUID?
    let onSave: (Entry) -> Void

    init(entry: Entry?, onSave: @escaping (Entry) -> Void) {
        _fieldValue = State(initialValue: entry?.taskName ?? "")
        _date = State(initialValue: entry?.date ?? Date())
        _note = State(initialValue: entry?.note ?? "")
        self.entryID = entry?.id
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                Form {
                    Section("Task name") {
                        TextField("Task name", text: $fieldValue)
                            .accessibilityIdentifier("entryFieldInput")
                    }
                    Section("Completed") {
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                    }
                    Section("Task Notes") {
                        TextField("Notes", text: $note, axis: .vertical)
                            .accessibilityIdentifier("entryNoteInput")
                    }
                }
                .scrollContentBackground(.hidden)
                .onTapGesture {
                    hideKeyboard()
                }
            }
            .navigationTitle(entryID == nil ? "New Entry" : "Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("entryCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let entry = Entry(
                            id: entryID ?? UUID(),
                            taskName: fieldValue.isEmpty ? "Untitled" : fieldValue,
                            date: date,
                            note: note
                        )
                        onSave(entry)
                        dismiss()
                    }
                    .accessibilityIdentifier("entrySaveButton")
                }
            }
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
