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
    
    var timer: Timer?
    var simulationCount = 0
    let bikeRange = 1...32
    
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
    
    var bikes: [KeiserBike] {
        return foundBikes.values.sorted(by: { $0.ordinalId < $1.ordinalId })
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
    
    private func startFakeSession() {
        
        for x in uniqueRandoms(numberOfRandoms: Int.random(in: 12...30), range: 1...32) {
            self.foundBikes[x] = KeiserBike.fakeRandomBike(ordinalID: x)
            os_log("[DEBUG] Adding Bike %d to the session taking total bikes to %d!", log: .default, type: .debug, x, self.foundBikes.count)
        }
        
        os_log("[DEBUG] Added %d to the initial session!", log: .default, type: .debug, self.foundBikes.count)
        
        self.timer = Timer(timeInterval: 1.0, target: self, selector: #selector(fireFakeBikeUpdate), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer!, forMode: .common)
    }
        
    @objc func fireFakeBikeUpdate(interval: TimeInterval = 7200) {
        simulationCount += 1
        for (_, kb) in self.foundBikes {
            kb.simulate()
        }
    }
    
    func stopFakeSession() {
        if let _  = self.timer?.isValid {
            self.timer?.invalidate()
        }
    }
}
