import Foundation

enum KeiserBikeError: Error {
    case runtimeError(String)
}

open class KeiserBike: NSObject, Identifiable, ObservableObject {

    @Published public var ordinalId: Int = 0
    @Published public var buildMajor: Int?
    @Published public var buildMinor: Int?
    @Published public var cadence: Int?
    @Published public var heartRate: Int?
    @Published public var power: Int?
    @Published public var caloricBurn: Int?
    @Published public var duration: TimeInterval?
    @Published public var tripDistance: Double?
    @Published public var gear: Int?
    
    init(_ data: Data) {
        super.init()
        self.updateWithData(bikeData: data)
    }
    
    init(
        ordinalId: Int, buildMajor: Int, buildMinor: Int, cadence: Int,
        heartRate: Int, power: Int, caloricBurn: Int, duration: TimeInterval,
        tripDistance: Double, gear: Int
    ) {
        super.init()
        self.ordinalId = ordinalId
        self.buildMajor = buildMajor
        self.buildMinor = buildMinor
        self.cadence = cadence
        self.heartRate = heartRate
        self.power = power
        self.caloricBurn = caloricBurn
        self.duration = duration
        self.tripDistance = tripDistance
        self.gear = gear
    }
    
    public func updateWithData(bikeData _data: Data) {
        
        // If it includes the Prefix Bits - Ignore these two
        if (_data.count < 17) {
            print("[ERROR] [updateWithData] Incorrectly formed data - found less than 17 Bits (Found \(_data.count) bits)!")
        }
        
        var data = _data
        if (data.count > 17){
            data = data.subdata(in: Range(uncheckedBounds: (lower: 2, upper: data.count)))
        }

        var tempDistance: Int32?
        for (index, byte) in data.enumerated(){
            switch index {
                case 0: buildMajor = Int(byte)
                case 1: buildMinor = Int(byte)
                //case 2: dataType = Int(byte);
                case 3: ordinalId = Int(byte)
                case 4: cadence = Int(byte)
                case 5: cadence = Int(UInt16(byte) << 8 | UInt16(cadence!))
                case 6: heartRate = Int(byte)
                case 7: heartRate = Int(UInt16(byte) << 8 | UInt16(heartRate!))
                case 8: power = Int(byte)
                case 9: power = Int(UInt16(byte) << 8 | UInt16(power!))
                case 10: caloricBurn = Int(byte)
                case 11: caloricBurn = Int(UInt16(byte) << 8 | UInt16(caloricBurn!))
                case 12: duration = Double(byte) * 60
                case 13: duration = duration! + Double(byte)
                case 14: tempDistance = Int32(byte)
                case 15: tempDistance = Int32(UInt16(byte) << 8 | UInt16(tempDistance!))
                case 16: gear = Int(byte)
                default: break
            }
        }

        cadence = cadence!/10
        heartRate = heartRate!/10
        
        // Converts tripDistance to miles -
        //
        // The distance value corresponds to the calculated distance for the current interval in units dependent
        // upon the unites identifier bit (MSB) with decimal precision transmitted as one order of magnitude larger (x10).
        // The 15 lowest bits contain the distance with the value range from 0 to 999.
        // The highest bit (MSB) indicates the units used. A 1 indicates the units are metric (kilometers), while a 0 indicates
        // the units are imperial (Miles).
        //
        // Not really sure how this works TBH... Something to do with working out if the MSB is a 1/0
        //
        if tempDistance! & 32768 != 0 {
            tripDistance = (Double(tempDistance! & 32767) * 0.62137119) / 10.0
        }
        else {
            tripDistance = Double(tempDistance!) / 10.0
        }
    }
}
