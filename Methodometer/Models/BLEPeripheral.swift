//
//  BLEPeripheral.swift
//  Methodometer
//
//  Created by Alex on 2020-02-18.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import Foundation
import CoreBluetooth
import Combine

extension CBPeripheralState {
    var stringRepresentation: String {
        switch self {
        case .disconnected: return "disconnected"
        case .connected: return "connected"
        case .connecting: return "connecting"
        case .disconnecting: return "disconnecting"
        @unknown default:
            return "disconnected"
        }
    }
}

extension CBPeripheral {
    public func asPeripheral(advertisementData: [String: Any],rssi: Int) -> BLEPeripheral {
        return BLEPeripheral(self, advertisementData: advertisementData, rssi: rssi)
    }
}

open class BLEPeripheral: NSObject, Identifiable, ObservableObject {
    
    var advertisedName: String? { return peripheral.name }
    var _advertisementData: [String: Any]

    @Published var state: CBPeripheralState
    var uuid: String { return peripheral.identifier.uuidString }
    public var id: String { return peripheral.identifier.uuidString }
    
    let rssi: String
    let peripheral: CBPeripheral
    
    internal static var CBPeripheralStateKVOContext = UInt8()
        
    init(_ peripheral: CBPeripheral, advertisementData: [String: Any], rssi: Int) {
        self._advertisementData = advertisementData
        self.peripheral = peripheral
        self.rssi = "\(rssi)"
        self.state = peripheral.state
        super.init()
        self.startObserving()
    }
    
    public static func == (lhs: BLEPeripheral, rhs: BLEPeripheral) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    var services: [CBService] {
        guard let __services = self.peripheral.services else {
            return []
        }
        return __services
    }
    
    var characteristics: [String] {
        var __characteristics = [String]()
        for __service in self.services {
            for __characteristic in __service.characteristics ?? [] {
                __characteristics.append("\(BLEServiceName(__service)) - \(BLECharacteristicName(__characteristic))")
            }
        }
        return __characteristics
    }
    
    var advertisementData: [String] {
        var __advertisementData = [String]()
        for (k, v) in self._advertisementData {
            __advertisementData.append("\(k) - \(v)")
        }
        return __advertisementData
    }
    
    internal func startObserving() {
        let options = NSKeyValueObservingOptions([.new, .old])
        self.peripheral.addObserver(self, forKeyPath: "state", options: options, context: &BLEPeripheral.CBPeripheralStateKVOContext)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        self.state = peripheral.state
    }
}
