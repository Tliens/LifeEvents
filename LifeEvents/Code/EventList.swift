import SwiftUI
import SwiftData

struct EventList: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @Query private var meanings: [Meaning]

    @ObservedObject var eventData: EventData
    
    @State private var isAddingNewEvent = false
    @State private var newEvent = Event()
    
    @State private var selection: Event?
    
    @State private var syncing = false

    @State var isNavPush = false
    
    @State var meaning = ""
    
    @AppStorage("isFirstInstallApp") private var isFirstInstallApp = true
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationSplitView {

            List(selection: $selection) {

                Section(content: {
                    NavigationLink {
                        MeaningofLife(meaning: $meaning)
                    } label: {
                        Text(meanings.first?.content ?? "")
                    }
                    .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
                }, header: {
                    Text("座右铭")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .fontWeight(.bold)
                })
                
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
            .navigationTitle("人生大事")
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
            meaning = meanings.first?.content ?? ""
        }
    }
    
    
    func add(_ event: Event) {
        do {
            let data = try JSONEncoder().encode(event)
            let item = Item(mid: event.id, data: data)
            modelContext.insert(item)
            load()
            print("Events add")
        } catch {
            print("Unable to add")
        }
    }
    
    func remove(_ event: Event) {
        for item in items {
            if item.mid == event.id{
                modelContext.delete(item)
                print("Events remove")
                break
            }
        }
        load()
    }
    
    func save(_ event: Event){
        for item in items {
            if item.mid == event.id{
                do {
                    let data = try JSONEncoder().encode(event)
                    item.data = data
                    print("Events saved")
                } catch {
                    print("Unable to save")
                }
                break
            }
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

