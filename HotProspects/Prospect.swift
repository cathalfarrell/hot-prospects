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
        if let data = UserDefaults.standard.data(forKey: Self.saveKey) {
            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
                self.people = decoded
                return
            }
        }

        self.people = []
    }

    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(people) {
            UserDefaults.standard.set(encoded, forKey: Self.saveKey)
        }
    }

    func toggle(_ prospect: Prospect) {
        objectWillChange.send() //sends notification that an item will changed - so UI updates
        prospect.isContacted.toggle()
        save()
    }
}
