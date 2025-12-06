//
//  WeekDays.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 26.11.2025.
//

enum WeekDay: String, CaseIterable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
    
    var shortName: String {
        switch self {
        case .monday: "Пн"
        case .tuesday: "Вт"
        case .wednesday: "Ср"
        case .thursday: "Чт"
        case .friday: "Пт"
        case .saturday: "Сб"
        case .sunday: "Вс"
        }
    }
    
    var number: Int {
        switch self {
        case .monday:  2
        case .tuesday:  3
        case .wednesday:  4
        case .thursday:  5
        case .friday:  6
        case .saturday:  7
        case .sunday:  1
        }
    }
        
    static func name(calendarWeekday int: Int) -> WeekDay? {
        switch int {
        case 2: .monday
        case 3: .tuesday
        case 4: .wednesday
        case 5: .thursday
        case 6: .friday
        case 7: .saturday
        case 1: .sunday
        default: nil
        }
    }
}
