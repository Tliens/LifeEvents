import SwiftUI
 
struct Event: Identifiable, Hashable, Codable {
    var id:String = UUID().uuidString
    var symbol: String = EventSymbols.randomName()
    var color: RGBAColor = ColorOptions.random().rgbaColor
    var title = ""
    var tasks = [EventTask(text: "")]
    var date = Date.now

    var period: Period {
        if date < Date.now{
            return .past
            
        } else if date < Date.now.oneYearsOut {
            return .next1Years
            
        } else if date < Date.now.fiveYearsOut {
            return .next5Years
            
        } else if date < Date.now.tenYearsOut {
            return .next10Years
            
        } else if date < Date.now.twentyYearsOut {
            return .next20Years
            
        } else if date < Date.now.thirtyYearsOut {
            return .next30Years
            
        } else {
            return .future
        }
    }
    
    var remainingTaskCount: Int {
        tasks.filter { !$0.isCompleted && !$0.text.isEmpty }.count
    }
    
    var isComplete: Bool {
        tasks.allSatisfy { $0.isCompleted || $0.text.isEmpty }
    }

    static var example = Event(
        symbol: "case.fill",
        title: "Sayulita Trip",
        tasks: [
            EventTask(text: "Buy plane tickets"),
            EventTask(text: "Get a new bathing suit"),
            EventTask(text: "Find an airbnb"),
        ],
        date: Date(timeIntervalSinceNow: 60 * 60 * 24 * 365 * 1.5))
    
    static var delete = Event(symbol: "trash")
}

extension Date {

    var oneYearsOut: Date {
        Calendar.autoupdatingCurrent.date(byAdding: .year, value: 1, to: self) ?? self
    }
    
    var fiveYearsOut: Date {
        Calendar.autoupdatingCurrent.date(byAdding: .year, value: 5, to: self) ?? self
    }
    
    var tenYearsOut: Date {
        Calendar.autoupdatingCurrent.date(byAdding: .year, value: 10, to: self) ?? self
    }
    
    var twentyYearsOut: Date {
        Calendar.autoupdatingCurrent.date(byAdding: .year, value: 20, to: self) ?? self
    }
    
    var thirtyYearsOut: Date {
        Calendar.autoupdatingCurrent.date(byAdding: .year, value: 30, to: self) ?? self
    }
    
}
