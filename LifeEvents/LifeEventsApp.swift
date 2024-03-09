//
//  LifeEventsApp.swift
//  LifeEvents
//
//  Created by Quinn Von on 2024/3/8.
//

import SwiftUI
import SwiftData

@main
struct LifeEventsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @StateObject private var eventData = EventData()
    
    var body: some Scene {
        WindowGroup {
            EventList(eventData: eventData)
        }
        .modelContainer(sharedModelContainer)
    }
}
