//
//  Utility.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 2/16/23.
//

import Foundation
import CloudKit

extension CKRecord.RecordType {
    static let anime = "Anime"
    static let user = "User"
    static let friendship = "Friendship"
}

extension CKRecord {
    subscript(key: AnimeRecord.RecordKey) -> Any? {
        get { return self[key.rawValue] }
        set { self[key.rawValue] = newValue as? CKRecordValue }
    }
    
//    subscript<T>(field: User.RecordKey) -> T? {
//        get {
//            return self[field.rawValue] as? T
//        }
//        set {
//            if let value = newValue as? CKRecordValue {
//                self[field.rawValue] = value
//            }
//        }
//    }
    
    subscript(key: User.RecordKey) -> Any? {
        get { return self[key.rawValue] }
        set { self[key.rawValue] = newValue as? CKRecordValue }
    }
    
    subscript(key: Friendship.RecordKey) -> Any? {
        get { return self[key.rawValue] }
        set { self[key.rawValue] = newValue as? CKRecordValue }
    }
}

extension Double {
    func reduceScale(to places: Int) -> Double {
        let multiplier = pow(10, Double(places))
        let newDecimal = multiplier * self // move the decimal right
        let truncated = Double(Int(newDecimal)) // drop the fraction
        let originalDecimal = truncated / multiplier // move the decimal back
        return originalDecimal
    }
}

func formatNumber(_ n: Int) -> String {
    let num = abs(Double(n))
    let sign = (n < 0) ? "-" : ""
    
    switch num {
    case 1_000_000_000...:
        var formatted = num / 1_000_000_000
        formatted = formatted.reduceScale(to: 1)
        return "\(sign)\(formatted)B"
        
    case 1_000_000...:
        var formatted = num / 1_000_000
        formatted = formatted.reduceScale(to: 1)
        return "\(sign)\(formatted)M"
        
    case 1_000...:
        var formatted = num / 1_000
        formatted = formatted.reduceScale(to: 1)
        return "\(sign)\(formatted)K"
        
    case 0...:
        return "\(n)"
        
    default:
        return "\(sign)\(n)"
    }
}
