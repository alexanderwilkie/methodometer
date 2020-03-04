//
//  BLECharacteristic.swift
//  Methodometer
//
//  Created by Alex on 2020-02-15.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import Foundation
import CoreBluetooth

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

struct BLEService: Codable {
    var name: String
    var assignedNumber: String
}

private let BLEServicesArr: [BLEService] = load("BLEServices.json")
let BLEServices = BLEServicesArr.reduce(into: [String: String]()) {
    $0[$1.assignedNumber] = $1.name
}

public func BLEServiceName(_ service: CBService) -> String {
    return BLEServices[service.uuid.uuidString] ?? service.uuid.uuidString
}

struct BLECharacteristic: Codable {
    var name: String
    var assignedNumber: String
}

private let BLECharacteristicsArr: [BLECharacteristic] = load("BLECharacteristics.json")
let BLECharacteristics = BLECharacteristicsArr.reduce(into: [String: String]()) {
    $0[$1.assignedNumber] = $1.name
}

public func BLECharacteristicName(_ characteristic: CBCharacteristic) -> String {
    return BLECharacteristics[characteristic.uuid.uuidString] ?? characteristic.uuid.uuidString
}
