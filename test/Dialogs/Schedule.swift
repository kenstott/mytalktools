//
//  Schedule.swift
//  test
//
//  Created by Kenneth Stott on 6/24/23.
//

import SwiftUI

struct Schedule: View {
    
    @Binding var urlResult: String
    @State private var selectedDate = Date()
    @State private var untilDate = Calendar.current.date(byAdding: DateComponents(year: 10), to: Date())!
    @State private var selectedRepeat = 0
    @State private var foreverUntil = false
    @State private var repeats = Array(repeating: "", count: 8)
    @Environment(\.dismiss) var dismiss
    
    var ordinals = ["", "first", "second", "third", "fourth", "fifth"]
    
    func nthDay() -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekdayOrdinal], from: selectedDate)
        return "\(ordinals[components.weekdayOrdinal ?? 0]) \(dayOfWeek()) of the month"
    }
    
    func dayOfWeek() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: selectedDate)
    }
    
    func dayOfMonth() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: selectedDate)
        return components.day ?? 0
    }
    
    func monthDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd"
        return dateFormatter.string(from: selectedDate)
    }
    
    func initSchedule() {
        let calendar = Calendar.current
        let items = urlResult.split(separator: "/")
        if urlResult.starts(with: "mtschedule:/v0") {
            selectedRepeat = 0
            selectedDate = calendar.date(from: DateComponents(year: Int(items[3]), month: Int(items[4]), day: Int(items[5]), hour: Int(items[7]), minute: Int(items[9])))!
        } else if urlResult.starts(with: "mtschedule:/v1") {
            selectedRepeat = 1
            selectedDate = calendar.date(from: DateComponents(year: Int(items[3]), month: Int(items[4]), day: Int(items[5]), hour: Int(items[7]), minute: Int(items[9])))!
            foreverUntil = true
            untilDate = calendar.date(from: DateComponents(year: Int(items[13]), month: Int(items[14]), day: Int(items[15])))!
        } else if urlResult.starts(with: "mtschedule:/v2") {
            selectedRepeat = 2
            selectedDate = calendar.date(from: DateComponents(year: Int(items[3]), month: Int(items[4]), day: Int(items[5]), hour: Int(items[7]), minute: Int(items[9])))!
            foreverUntil = true
            untilDate = calendar.date(from: DateComponents(year: Int(items[12]), month: Int(items[13]), day: Int(items[14])))!
        } else if urlResult.starts(with: "mtschedule:/v3") {
            selectedRepeat = 3
            selectedDate = calendar.date(from: DateComponents(year: Int(items[6]), month: Int(items[7]), day: Int(items[8]), hour: Int(items[10]), minute: Int(items[12])))!
            foreverUntil = true
            untilDate = calendar.date(from: DateComponents(year: Int(items[14]), month: Int(items[15]), day: Int(items[16])))!
        } else if urlResult.starts(with: "mtschedule:/v4") {
            selectedRepeat = 4
            selectedDate = calendar.date(from: DateComponents(year: Int(items[3]), month: Int(items[4]), day: Int(items[5]), hour: Int(items[7]), minute: Int(items[9])))!
            foreverUntil = true
            untilDate = calendar.date(from: DateComponents(year: Int(items[16]), month: Int(items[17]), day: Int(items[18])))!
        } else if urlResult.starts(with: "mtschedule:/v5") {
            selectedRepeat = 5
            selectedDate = calendar.date(from: DateComponents(year: Int(items[3]), month: Int(items[4]), day: Int(items[5]), hour: Int(items[7]), minute: Int(items[9])))!
            foreverUntil = true
            untilDate = calendar.date(from: DateComponents(year: Int(items[12]), month: Int(items[13]), day: Int(items[14])))!
        } else if urlResult.starts(with: "mtschedule:/v6") {
            selectedRepeat = 6
            selectedDate = calendar.date(from: DateComponents(year: Int(items[3]), month: Int(items[4]), day: Int(items[5]), hour: Int(items[7]), minute: Int(items[9])))!
            foreverUntil = true
            untilDate = calendar.date(from: DateComponents(year: Int(items[12]), month: Int(items[13]), day: Int(items[14])))!
        } else if urlResult.starts(with: "mtschedule:/v7") {
            selectedRepeat = 7
            selectedDate = calendar.date(from: DateComponents(year: Int(items[3]), month: Int(items[4]), day: Int(items[5]), hour: Int(items[7]), minute: Int(items[9])))!
            foreverUntil = true
            untilDate = calendar.date(from: DateComponents(year: Int(items[12]), month: Int(items[13]), day: Int(items[14])))!
        } else {
            selectedDate = Date()
        }
        setRepeats()
    }
    
    func setRepeats() {
        repeats = [
            "Just once",
            "Every \(dayOfWeek())",
            "Every \(nthDay())",
            "Day \(dayOfMonth()) of every month",
            "Every \(monthDay())",
            "Every Day",
            "Every Weekend",
            "Every Weekday"
        ]
    }
    
    func setUrl() -> String {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .weekday, .weekdayOrdinal], from: selectedDate)
        let nthDay = components.weekdayOrdinal ?? 0
        let command = "mtschedule:/v\(selectedRepeat)"
        let start = "/start/\(components.year ?? 0)/\(components.month ?? 0)/\(components.day ?? 0)/hour/\(components.hour ?? 0)/min/\(components.minute ?? 0)"
        let date = "/date/\(components.year ?? 0)/\(components.month ?? 0)/\(components.day ?? 0)/hour/\(components.hour ?? 0)/min/\(components.minute ?? 0)"
        var dayOfWeek = ""
        switch (components.weekday) {
        case 1: dayOfWeek = "/sun"
        case 2: dayOfWeek = "/mon"
        case 3: dayOfWeek = "/tue"
        case 4: dayOfWeek = "/wed"
        case 5: dayOfWeek = "/thu"
        case 6: dayOfWeek = "/fri"
        case 7: dayOfWeek = "/sat"
        default:dayOfWeek = ""
        }
        components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .weekday], from: untilDate)
        let stop = "/stop/\(components.year ?? 0)/\(components.month ?? 0)/\(components.day ?? 0)"
        switch selectedRepeat {
        case 0:
            return "\(command)\(date)"
        case 1: return "\(command)\(start)/and\(dayOfWeek)\(stop)"
        case 2: return "\(command)\(start)/and\(stop)/weekof/\(nthDay)\(dayOfWeek)"
        case 3: return "\(command)/day/\(components.day ?? 0)/and\(start)\(stop)"
        case 4: return "\(command)\(start)/and/monthday/\(components.month ?? 0)/\(components.day ?? 0)/and/\(stop)"
        case 5: return "\(command)\(start)/and\(stop)"
        case 6: return "\(command)\(start)/and\(stop)/-/sat/sun"
        case 7: return "\(command)\(start)/and\(stop)/-/mon/tue/wed/thu/fri"
        default: return ""
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Beginning on...")) {
                    DatePicker("", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.graphical)
                        .frame(maxHeight: 400)
                }
                Section(header: Text("Repeating...")) {
                    Picker("", selection: $selectedRepeat) {
                        ForEach(0 ..< 8) {
                            Text(repeats[$0]).tag($0)
                        }
                    }.onAppear() {
                        setRepeats()
                    }
                    
                    if selectedRepeat != 0 {
                        HStack {
                            Toggle("", isOn: $foreverUntil)
                                .labelsHidden()
                            HStack {
                                Text("Forever")
                                    .foregroundColor(foreverUntil ? .secondary : .primary)
                                Spacer()
                                Text("Until")
                                    .foregroundColor(foreverUntil ? .primary : .secondary)
                            }
                        }
                        if foreverUntil {
                            DatePicker("", selection: $untilDate, displayedComponents: [.date])
                                .datePickerStyle(.compact)
                                .frame(maxHeight: 400)
                        }
                    }
                }
            }
            .onAppear {
//                print("form appeared")
                initSchedule()
            }
        }
        .onChange(of: selectedDate) {
            newValue in
            setRepeats()
        }
        .navigationTitle("Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    urlResult = ""
                    dismiss()
                } label: {
                    Text("Cancel")
                }
            }
            ToolbarItem {
                Button {
                    urlResult = setUrl()
//                    print("result=\(setUrl())")
//                    print("result=\(urlResult)")
                    dismiss()
                } label: {
                    Text("Save")
                }
            }
        }
    }
}

struct Schedule_Previews: PreviewProvider {
    static var previews: some View {
        @State var x = ""
        NavigationView {
            Schedule(urlResult: $x).onChange(of: x) {
                newValue in
//                print("x=\(x)")
            }
        }
    }
}
