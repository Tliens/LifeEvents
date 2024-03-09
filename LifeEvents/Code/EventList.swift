import SwiftUI
import SwiftData

struct EventList: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @ObservedObject var eventData: EventData
    
    @State private var isAddingNewEvent = false
    @State private var newEvent = Event()
    
    @State private var selection: Event?
    
    @State private var syncing = false

    @AppStorage("isFirstInstallApp") private var isFirstInstallApp = true

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(Period.allCases) { period in
                    Section(content: {
                        ForEach(eventData.sortedEvents(period: period)) { $event in
                            EventRow(event: event)
                                .tag(event)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        selection = nil
                                        remove(event)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }, header: {
                        Text(period.name)
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                    })
                    .disabled(eventData.sortedEvents(period: period).isEmpty)
                }
            }
            .navigationTitle("Life Events")
            .toolbar {
                ToolbarItem {
                    Button {
                        self.syncing.toggle()
                        load()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            self.syncing.toggle()
                        }
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                                        .rotationEffect(Angle.degrees(syncing ? 360 : 0))
                                        .animation(syncing ? Animation.linear(duration: 2).repeatForever(autoreverses: false) : .default)
                    }
                }
                ToolbarItem {
                    Button {
                        newEvent = Event()
                        isAddingNewEvent = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingNewEvent) {
                NavigationStack {
                    EventEditor(event: $newEvent, isNew: true)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") {
                                    isAddingNewEvent = false
                                }
                            }

                            ToolbarItem {
                                Button {
                                    add(newEvent)
                                    isAddingNewEvent = false
                                } label: {
                                    Text("Add" )
                                }
                                .disabled(newEvent.title.isEmpty)
                            }
                            
                            
                        }
                }
            }
        } detail: {
            ZStack {
                if let event = selection, let eventBinding = eventData.getBindingToEvent(event) {
                    EventEditor(event: eventBinding)
                } else {
                    Text("Select an Event")
                        .foregroundStyle(.secondary)
                }
            }
        }.onAppear {
            firstInstallApp()
            load()
        }
    }
    
    
    func add(_ event: Event) {
        do {
            let data = try JSONEncoder().encode(event)
            let item = Item(timestamp: event.date, data: data)
            modelContext.insert(item)
            load()
            print("Events saved")
        } catch {
            print("Unable to save")
        }
    }
    
    func remove(_ event: Event) {
        do {
            let data = try JSONEncoder().encode(event)
            let item = Item(timestamp: event.date, data: data)
            modelContext.delete(item)
            load()
            print("Events saved")
        } catch {
            print("Unable to save")
        }
    }
    
    func load() {
        do {
            let descriptor = FetchDescriptor<Item>()
            let items = try modelContext.fetch(descriptor)
            var events = [Event]()
            for item in items {
                if let data = item.data{
                    let event = try JSONDecoder().decode(Event.self, from: data)
                    events.append(event)
                }
            }
            eventData.events = events

            print("Events loaded: \(eventData.events.count)")
        } catch {
            print("Failed to load from file. Backup data used")
        }
    }
    
    func firstInstallApp(){
        if isFirstInstallApp{
            isFirstInstallApp = false
            eventData.events.forEach { event in
                add(event)
            }
        }
    }
}

