//
//  KeiserBikeManager.swift
//  Methodometer
//
//  Created by Alex on 2020-02-18.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import Foundation
import CoreBluetooth
import os

enum KeiserBikeManagerType {
    case demo, live, none
}

class KeiserBikeManager: NSObject, Identifiable, ObservableObject, CBCentralManagerDelegate {
    @Published var foundBikes = [Int: KeiserBike]()

    var centralManager: CBCentralManager!
    var peripheralName: String?
        
    public init(simulated: Bool = false) {
        super.init()
        
        if (!simulated) {
            centralManager = CBCentralManager(delegate: self, queue: DispatchQueue(label: "CentralManager"))
        } else {
            self.startFakeSession()
        }
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
        
        // The blacklist idea would just early exit this - mainly so logging is usable
        os_log("[DEBUG] [centralManager:didDiscover] Found: %@", log: .default, type: .debug, pName)
        
        // We only care about the M3
        if (peripheralName != nil && pName != peripheralName) {
            // what we could do here is blacklist the peripheral if it doesn't match our name... but we don't
            // know the name for sure yet - when we confirm we can turn on... maybe even one day we can
            // use scanForPeripherals with the maching UUID or something when we figure that out
            //
            os_log("[DEBUG] [centralManager:didDiscover] Peripheral '%@' doesn't match required name: '%@'", log: .default, type: .debug, pName, peripheralName!)
            return
        }
        
        if let data = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
            // now val is not nil and the Optional has been unwrapped, so use it
            let kb = KeiserBike(data)
            if (kb.valid) {
                DispatchQueue.main.async {
                    if let _ = self.foundBikes[kb.id] {
                        os_log("[DEBUG] Updating Bike %@ with new data!", log: .default, type: .debug, kb.id)
                        self.foundBikes[kb.id]!.updateWithData(bikeData: data)
                    } else {
                        os_log("[DEBUG] Adding Bike %@ to the session!", log: .default, type: .debug, kb.id)
                        self.foundBikes[kb.id] = kb
                    }
                }
            } else {
                // again using a black list if this is invalid - question is - is a valid bike invalid for one broadcast???
                // 3 strikes and you're out rule?
                os_log("[ERROR] [centralManager:didDiscover] Peripheral '%@' is not a valid bike!", log: .default, type: .error, pName)
            }
        } else {
            // what we could do here is blacklist the peripheral if it doesn't contain the meta data - but perhaps
            // that's sometimes missing on a legit peripheral - not sure...
            os_log("[DEBUG] [centralManager:didDiscover] Peripheral '%@' doesn't contain '%@' in Advertisement Data", log: .default, type: .debug, pName, CBAdvertisementDataManufacturerDataKey)
        }
    }
    
    public func startFakeSession() {
        
        let bikeRange = 1...32
        let initialBikeCount = 5...20
        let interval = 30
        
        // Start with around 5-15 bikes between bikes 1 and 32
        for _ in 1...Int.random(in: initialBikeCount) {
            let kb = KeiserBike.fakeRandomBike(ordinalID: Int.random(in: bikeRange))
            self.foundBikes[kb.id] = kb
        }
        
        var x = 0
        let t = Timer.scheduledTimer(withTimeInterval: TimeInterval(1), repeats: true) { timer in
            x += 1
           
            // Give a 70% chance of new bikes showing up for first % of session...
            if x < Int((Float(interval) / 100.0) * 15) {
                if (Int.random(in: 0...10) > 3) {
                    let kb = KeiserBike.fakeRandomBike(ordinalID: Int.random(in: bikeRange))
                    if let _ = self.foundBikes[kb.id] {
                        os_log("[DEBUG] Bike %d already in the session!", log: .default, type: .debug, kb.id)
                    } else {
                        os_log("[DEBUG] Adding Bike %d to the session!", log: .default, type: .debug, kb.id)
                        self.foundBikes[kb.id] = kb
                    }
                }
            } else if x > interval {
                for i in self.foundBikes.keys {
                    if (Int.random(in: 0...10) > 6) {
                        os_log("[DEBUG] Session over - Bike %d stopping now!", log: .default, type: .debug, i)
                        self.foundBikes.removeValue(forKey: i)
                    }
                }
                
                if (self.foundBikes.isEmpty) {
                    os_log("[DEBUG] All bikes have finished simulating - ending session!", log: .default, type: .debug)
                    timer.invalidate()
                }
            }
            
            for (_, kb) in self.foundBikes {
                kb.simulate()
            }
        }
        RunLoop.main.add(t, forMode: .common)
    }
}
