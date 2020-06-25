//
//  Prospect.swift
//  HotProspects
//
//  Created by Cathal Farrell on 23/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Foundation

class Prospect: Identifiable, Codable {
    let id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    fileprivate(set) var isContacted = false
}

class Prospects: ObservableObject {
    @Published private(set) var people: [Prospect] //ensures it cannot be updated externally

    static let saveKey = "SavedData"

    init() {
        self.people = []
        //self.loadFromUserDefaults()
        loadData()
    }

    func add(_ prospect: Prospect) {
        people.append(prospect)
        //saveToUserDefaults()
        saveData()
    }

    // Challenge 2 - Use JSON and the documents directory for saving and loading our user data.

    // MARK:-  Persistence using Local Storage

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    private func saveData() {
        do {
            let filename = getDocumentsDirectory().appendingPathComponent(Self.saveKey)
            let data = try JSONEncoder().encode(self.people)
            // MARK: - Strong file encryption using .completeFileProtection
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
            print("✅ Data Saved to: \(filename)")
        } catch (let err) {
            print("🛑 Unable to save data: \(err.localizedDescription)")
        }
    }

    private func loadData() {
        do {
            let filename = getDocumentsDirectory().appendingPathComponent(Self.saveKey)
            let data = try Data(contentsOf: filename)
            self.people = try JSONDecoder().decode([Prospect].self, from: data)
            print("✅ Data Loaded from: \(filename):\n\(self.people.count) Contacts Loaded\n")
        } catch (let err) {
            print("🛑 Unable to load data: \(err.localizedDescription)")
        }
    }

    // MARK:-  Persistence using User Defaults

    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(people) {
            UserDefaults.standard.set(encoded, forKey: Self.saveKey)
        }
    }

    private func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: Self.saveKey) {
            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
                self.people = decoded
            }
        }
    }

    func toggle(_ prospect: Prospect) {
        objectWillChange.send() //sends notification that an item will changed - so UI updates
        prospect.isContacted.toggle()
        //saveToUserDefaults()
        saveData()
    }
}
