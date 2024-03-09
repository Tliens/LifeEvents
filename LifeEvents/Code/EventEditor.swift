import SwiftUI
import SwiftData

struct EventEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var event: Event
    @Query private var items: [Item]
    
    @State var isNew = false
    
    @Environment(\.dismiss) private var dismiss
    @FocusState var focusedTask: EventTask?
    @State private var isPickingSymbol = false

    var body: some View {
        List {
            HStack {
                Button {
                    isPickingSymbol.toggle()
                } label: {
                    Image(systemName: event.symbol)
                        .imageScale(.large)
                        .foregroundColor(Color(event.color))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 5)

                TextField("New Event", text: $event.title)
                    .font(.title2)
            }
            .padding(.top, 5)
            
            DatePicker("Date", selection: $event.date)
                .labelsHidden()
                .listRowSeparator(.hidden)
            
            Text("Tasks")
                .fontWeight(.bold)
            
            ForEach($event.tasks) { $item in
                TaskRow(task: $item, focusedTask: $focusedTask)
            }
            .onDelete(perform: { indexSet in
                event.tasks.remove(atOffsets: indexSet)
            })

            Button {
                let newTask = EventTask(text: "", isNew: true)
                event.tasks.append(newTask)
                focusedTask = newTask
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Task")
                }
            }
            .buttonStyle(.borderless)
        }

        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: $isPickingSymbol) {
            SymbolPicker(event: $event)
        }.onDisappear(perform: {
            if !isNew{
                save(event)
            }
        })
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
}
