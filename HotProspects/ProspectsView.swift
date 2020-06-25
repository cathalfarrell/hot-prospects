//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Cathal Farrell on 23/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import SwiftUI
import CodeScanner
import UserNotifications

struct ProspectsView: View {

    let filter: FilterType

    enum FilterType {
        case none, contacted, uncontacted
    }

    @EnvironmentObject var prospects: Prospects

    @State private var isShowingScanner = false
    @State private var isShowingFilters = false

    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted people"
        case .uncontacted:
            return "Uncontacted people"
        }
    }

    var filteredProspects: [Prospect] {
        switch filter {
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter { $0.isContacted }
        case .uncontacted:
            return prospects.people.filter { !$0.isContacted }
        }
    }

    var simulatedData: String {
        let arrayOfSamples = ["Paul Hudson\npaul@hackingwithswift.com",
                              "Cathal Farrell\ncathal@home.com",
                              "Taylor Swift\nswifty@taylorshouse.com",
                              "Lady Gaga\nladygaga@monsters.com",
                              "Dua Lipa\ndualipa@capitalmusic.com"
        ]
        let randomIndex = Int.random(in: 0...4)
        return arrayOfSamples[randomIndex]
    }

    let systemImageContacted = "person.crop.circle.fill.badge.checkmark"
    let systemImageUncontacted = "person.crop.circle.badge.xmark"

    var body: some View {
            NavigationView {
                List {
                    ForEach(filteredProspects) { prospect in
                        VStack(alignment: .leading) {
                            HStack{
                                Text(prospect.name)
                                    .font(.headline)
                                // Challenge 1 - Add an icon to the “Everyone” screen showing
                                // whether a prospect was contacted or not.
                                Spacer()
                                Image(systemName: prospect.isContacted ?
                                    self.systemImageContacted : self.systemImageUncontacted)
                            }
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                        }
                        .contextMenu {
                            Button(prospect.isContacted ? "Mark Uncontacted" : "Mark Contacted" ) {
                                self.prospects.toggle(prospect)
                            }
                            if !prospect.isContacted {
                                Button("Remind Me") {
                                    self.addNotification(for: prospect)
                                }
                            }
                        }
                    }
                }
                .navigationBarTitle(title)
                .navigationBarItems(leading: Button(action: {
                    self.isShowingFilters = true
                }) {
                    Image(systemName: "arrow.up.arrow.down.square")
                    Text("Sort")
                },
                trailing: Button(action: {
                    self.isShowingScanner = true
                }) {
                    Image(systemName: "qrcode.viewfinder")
                    Text("Scan")
                })
            }
            .navigationBarTitle(title)
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: self.simulatedData, completion: self.handleScan)
            }
                /*
                 Challenge 3 - Use an action sheet to customize the way users are sorted in each screen – by name
                */
            .actionSheet(isPresented: $isShowingFilters) {
                ActionSheet(title: Text("Sort Contacts By"), buttons: [ .default(Text("Name"), action: {
                    self.prospects.sortByUserName()
                }),
                .cancel()])
            }

        }

    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
       self.isShowingScanner = false
       switch result {
       case .success(let code):
           let details = code.components(separatedBy: "\n")
           guard details.count == 2 else { return }

           let person = Prospect()
           person.name = details[0]
           person.emailAddress = details[1]

           self.prospects.add(person)
        
       case .failure(let error):
        print("Scanning failed: \(error.localizedDescription)")
       }
    }

    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()

        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default

            /*
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            */

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)


            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }

        // Request settings to check if permission
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print("D'oh")
                    }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
    }
}
