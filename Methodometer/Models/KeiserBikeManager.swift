//
//  KeiserBikeManager.swift
//  Methodometer
//
//  Created by Alex on 2020-02-18.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import Foundation
import CoreBluetooth

class KeiserBikeManager: NSObject, Identifiable, ObservableObject, CBCentralManagerDelegate {
    @Published var foundBikes = [KeiserBike]()
    
    var centralManager: CBCentralManager!
    var peripheralName: String?
    
    public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue(label: "CentralManager"))
    }
    
    // You implement this required method to ensure that the central device supports Bluetooth low energy and
    // that it’s available to use. You should issue commands to the central manager only when the central manager’s
    // state indicates it’s powered on. A state with a value lower than CBCentralManagerState.poweredOn implies
    // that scanning has stopped, which in turn disconnects any previously-connected peripherals.
    //
    open func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case .poweredOn:
            centralManager.scanForPeripherals(
                withServices: nil,
                options: [CBCentralManagerScanOptionAllowDuplicatesKey : true]
            )
        default:
            print(central.state)
        }
    }
    
    // Tells the delegate the central manager discovered a peripheral while scanning for devices
    public func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        let pName = peripheral.name ?? peripheral.identifier.uuidString
        // print("[DEBUG] [centralManager:didDiscover] Found: \(pName)")
        
        // We only care about the M3
        if (peripheralName != nil && pName != peripheralName) {
            print("[DEBUG] [centralManager:didDiscover] Peripheral '\(pName)' doesn't match required name: \(String(describing: peripheralName))")
            return
        }
        
        if let data = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
            // now val is not nil and the Optional has been unwrapped, so use it
            let kb = KeiserBike(data)
            kb.name = pName
            DispatchQueue.main.async {
                if let i = self.foundBikes.lastIndex(where: { $0.ordinalId == kb.ordinalId }) {
                    self.foundBikes[i] = kb
                } else {
                    self.foundBikes.append(kb)
                }
            }
        } else {
            // print("[DEBUG] [centralManager:didDiscover] Peripheral '\(pName)' Doesn't contain \(CBAdvertisementDataManufacturerDataKey) in Advertisement Data")
            return
        }
    }
    
    public static func fakeSession(bikes: Int, duration: Int) -> KeiserBikeManager {
        let kbm = KeiserBikeManager()
        for _ in 1...bikes {
            kbm.foundBikes.append(KeiserBike.fakeRandomBike(duration: duration))
        }
        return kbm
    }
}
