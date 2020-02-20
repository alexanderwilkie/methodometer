import Foundation
import CoreBluetooth

open class BLEManagerDelegate: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject {
    
    var centralManager: CBCentralManager!
    
    var peripheralName: String?
    
    @Published var remotePeripherals = [BLEPeripheral]()
    private    var activePeripheral: CBPeripheral!
    
    public override convenience init() {
        self.init(peripheralName: "")
    }
    
    public init(peripheralName: String) {
        super.init()
        self.peripheralName = peripheralName
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    var filterNamedPeripherals: [BLEPeripheral] {
        return self.remotePeripherals.filter { ($0.advertisedName != nil) }
    }
    
    @objc private func scanTimeout() {
        print("[DEBUG] Scanning stopped")
        self.centralManager.stopScan()
    }
    
    // You implement this required method to ensure that the central device supports Bluetooth low energy and
    // that it’s available to use. You should issue commands to the central manager only when the central manager’s
    // state indicates it’s powered on. A state with a value lower than CBCentralManagerState.poweredOn implies
    // that scanning has stopped, which in turn disconnects any previously-connected peripherals.
    //
    open func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case .poweredOn:
            Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(BLEManagerDelegate.scanTimeout), userInfo: nil, repeats: false)
            centralManager.scanForPeripherals(
                withServices: nil,
                options: [CBCentralManagerScanOptionAllowDuplicatesKey : false]
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
        print("[DEBUG] [centralManager:didDiscover] Found: \(pName)")
        
        // We only care about the M3
        if (peripheralName != nil && pName != peripheralName) {
            print("[DEBUG] [centralManager:didDiscover] Peripheral '\(pName)' doesn't match required name: \(String(describing: peripheralName))")
            return
        }
        
        if let data = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
            // now val is not nil and the Optional has been unwrapped, so use it                
            var kb = KeiserBike(data)
        } else {
            print("[DEBUG] [centralManager:didDiscover] Peripheral '\(pName)' Doesn't contain \(CBAdvertisementDataManufacturerDataKey) in Advertisement Data")
            return
        }
    }
    
    public func centralManager(
        _ central: CBCentralManager,
        connectionEventDidOccur event: CBConnectionEvent,
        for peripheral: CBPeripheral
    ) {
        print("[DEBUG] connectionEventDidOccur to peripheral \(peripheral.name ?? peripheral.identifier.uuidString)")
    }
    
    public func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        print("[DEBUG] Connected to peripheral \(peripheral.name ?? peripheral.identifier.uuidString)")
        peripheral.discoverServices(nil)
    }
    
    public func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
       error: Error?
    ) {
        print("[ERROR] Could not connect to peripheral \(peripheral.name ?? peripheral.identifier.uuidString) error: \(error!.localizedDescription)")
    }
    
    public func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        var text = "[DEBUG] Disconnected from peripheral \(peripheral.name ?? peripheral.identifier.uuidString)"
        if error != nil {
            text += ". Error: \(error!.localizedDescription)"
        }
        print(text)
    }
    
    public func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?
    ) {
        if error != nil {
            print("[ERROR] Error discovering services. \(error!.localizedDescription)")
            return
        }
        
        print("[DEBUG] Found services for peripheral: \(peripheral.name ?? peripheral.identifier.uuidString)")
        
        for service in peripheral.services ?? [] {
            print("Discovered service: \(BLEServiceName(service))")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    public func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        if error != nil {
            print("[ERROR] Error discovering characteristics. \(error!.localizedDescription)")
            return
        }
        
        print("[DEBUG] Found characteristics for peripheral: \(peripheral.name ?? peripheral.identifier.uuidString)")
        
        for char in service.characteristics ?? [] {
            print("[DEBUG] Found characteristic: \(BLECharacteristicName(char)) on service: \(BLEServiceName(service))")
        }
    }
}
