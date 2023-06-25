//
//  ScheduleMonitor.swift
//  test
//
//  Created by Kenneth Stott on 6/24/23.
//

import SwiftUI
import UserNotifications

struct ScheduledContent {
    
    var content: Content
    var date: Date
    var fired = false
    let id = UUID()
}

class ScheduleMonitor: ObservableObject {
    
    private var scheduled = [ScheduledContent]()
    private let center = UNUserNotificationCenter.current()
    @Published var boardId: UInt? = 0
    
    init() {
//        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] timer in
//            let now = Date()
//            for index in 0..<scheduled.count {
//                let schedule = scheduled[index]
//                if !schedule.fired && schedule.date < now && schedule.content.link != 0 {
//                    scheduled[index].fired = true
//                    boardId = schedule.content.link
//                }
//            }
//        }
    }
    
    func createSchedule() {
        let identifiers = scheduled.map { $0.id.uuidString }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        scheduled.removeAll()
        let scheduleCells = Board.getScheduleBoards()
        if scheduleCells.count > 0 {
            let now = Date()
            for content in scheduleCells {
                let calendar = Calendar.current
                let items = content.externalUrl.split(separator: "/")
                if content.externalUrl.starts(with: "mtschedule:/v0") {
                    let targetDate = calendar.date(from: DateComponents(year: Int(items[3]), month: Int(items[4]), day: Int(items[5]), hour: Int(items[7]), minute: Int(items[9])))!
                    if targetDate > Date() {
                        scheduled.append(ScheduledContent(content: content, date: targetDate))
                    }
                } else if content.externalUrl.starts(with: "mtschedule:/v1") {
                    var targetDate = calendar.date(from: DateComponents(year: Int(items[3]), month: Int(items[4]), day: Int(items[5]), hour: Int(items[7]), minute: Int(items[9])))!
                    let untilDate = calendar.date(from: DateComponents(year: Int(items[13]), month: Int(items[14]), day: Int(items[15])))!
                    var dateComponent = DateComponents()
                    dateComponent.day = 7
                    while targetDate < untilDate {
                        if targetDate > now {
                            scheduled.append(ScheduledContent(content: content, date: targetDate))
                        }
                        targetDate = Calendar.current.date(byAdding: dateComponent, to: targetDate)!
                    }
                } else if content.externalUrl.starts(with: "mtschedule:/v2") {
                    var targetDate: Date = calendar.date(from: DateComponents(year: Int(items[3]), month: Int(items[4]), day: Int(items[5]), hour: Int(items[7]), minute: Int(items[9])))!
                    var components = calendar.dateComponents([.year, .month, .hour, .minute, .weekday, .weekdayOrdinal], from: targetDate)
                    let untilDate = calendar.date(from: DateComponents(year: Int(items[12]), month: Int(items[13]), day: Int(items[14])))!
                    while targetDate < untilDate {
                        if targetDate > now {
                            scheduled.append(ScheduledContent(content: content, date: targetDate))
                        }
                        if components.month == 12 {
                            components.year! += 1
                            components.month = 1
                        } else {
                            components.month! += 1
                        }
                        targetDate = calendar.date(from: components)!
                    }
                    
                } else if content.externalUrl.starts(with: "mtschedule:/v3") {
                    var targetDate: Date = calendar.date(from: DateComponents(year: Int(items[6]), month: Int(items[7]), day: Int(items[8]), hour: Int(items[10]), minute: Int(items[12])))!
                    var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: targetDate)
                    let day = components.day
                    var checkDay = day
                    var month = components.month
                    var year = components.year
                    let untilDate = calendar.date(from: DateComponents(year: Int(items[14]), month: Int(items[15]), day: Int(items[16])))!
                    while targetDate < untilDate {
                        if day == checkDay && targetDate > now {
                            scheduled.append(ScheduledContent(content: content, date: targetDate))
                        }
                        if month == 12 {
                            year! += 1
                            month = 1
                        } else {
                            month! += 1
                        }
                        components.day = day
                        components.year = year
                        components.month = month
                        targetDate = calendar.date(from: components)!
                        checkDay = calendar.component(.day, from: targetDate)
                    }
                } else if content.externalUrl.starts(with: "mtschedule:/v4") {
                    var targetDate: Date = calendar.date(from: DateComponents(year: Int(items[3]), month: Int(items[4]), day: Int(items[5]), hour: Int(items[7]), minute: Int(items[9])))!
                    var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: targetDate)
                    let day = components.day
                    var checkDay = day
                    let month = components.month
                    var year = components.year!
                    let untilDate = calendar.date(from: DateComponents(year: Int(items[16]), month: Int(items[17]), day: Int(items[18])))!
                    while targetDate < untilDate {
                        if day == checkDay && targetDate > now {
                            scheduled.append(ScheduledContent(content: content, date: targetDate))
                        }
                        year += 1
                        components.day = day
                        components.year = year
                        components.month = month
                        targetDate = calendar.date(from: components)!
                        checkDay = calendar.component(.day, from: targetDate)
                    }
                } else if content.externalUrl.starts(with: "mtschedule:/v5") {
                    var targetDate = calendar.date(from: DateComponents(year: Int(items[3]), month: Int(items[4]), day: Int(items[5]), hour: Int(items[7]), minute: Int(items[9])))!
                    let untilDate = calendar.date(from: DateComponents(year: Int(items[12]), month: Int(items[13]), day: Int(items[14])))!
                    var dateComponent = DateComponents()
                    dateComponent.day = 1
                    while targetDate < untilDate {
                        if targetDate > now {
                            scheduled.append(ScheduledContent(content: content, date: targetDate))
                        }
                        targetDate = Calendar.current.date(byAdding: dateComponent, to: targetDate)!
                    }
                } else if content.externalUrl.starts(with: "mtschedule:/v6") {
                    var targetDate = calendar.date(from: DateComponents(year: Int(items[3]), month: Int(items[4]), day: Int(items[5]), hour: Int(items[7]), minute: Int(items[9])))!
                    let untilDate = calendar.date(from: DateComponents(year: Int(items[12]), month: Int(items[13]), day: Int(items[14])))!
                    var dateComponent = DateComponents()
                    dateComponent.day = 1
                    while targetDate < untilDate {
                        let weekday = calendar.component(.weekday, from: targetDate)
                        if targetDate > now && (weekday == 1 || weekday == 7) {
                            scheduled.append(ScheduledContent(content: content, date: targetDate))
                        }
                        targetDate = Calendar.current.date(byAdding: dateComponent, to: targetDate)!
                    }
                } else if content.externalUrl.starts(with: "mtschedule:/v7") {
                    var targetDate = calendar.date(from: DateComponents(year: Int(items[3]), month: Int(items[4]), day: Int(items[5]), hour: Int(items[7]), minute: Int(items[9])))!
                    let untilDate = calendar.date(from: DateComponents(year: Int(items[12]), month: Int(items[13]), day: Int(items[14])))!
                    var dateComponent = DateComponents()
                    dateComponent.day = 1
                    while targetDate < untilDate {
                        let weekday = calendar.component(.weekday, from: targetDate)
                        if targetDate > now && weekday > 1 && weekday < 7 {
                            scheduled.append(ScheduledContent(content: content, date: targetDate))
                        }
                        targetDate = Calendar.current.date(byAdding: dateComponent, to: targetDate)!
                    }
                }
            }
        }
        for schedule in scheduled {
            let content = UNMutableNotificationContent()
            content.title = "MyTalkTools"
            content.body = "Reminder: \(schedule.content.name)"
            content.sound = UNNotificationSound.default
            content.userInfo = ["boardId":schedule.content.link]
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: schedule.date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: schedule.id.uuidString, content: content, trigger: trigger)
            center.add(request)
        }
    }
}

