//
//  Schedule.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 03.12.2025.
//
import Foundation

@objc
final class ScheduleTransformer: ValueTransformer {
    static func register() {
        ValueTransformer.setValueTransformer(
            ScheduleTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: ScheduleTransformer.self))
        )
    }
    
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let schedule = value as? [Int] else { return nil }
        return try? JSONEncoder().encode(schedule)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        return try? JSONDecoder().decode([Int].self, from: data as Data)
    }
}
