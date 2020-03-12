import Foundation
import CoreGraphics

enum KeiserBikeError: Error {
    case runtimeError(String)
}

open class KeiserBike: NSObject, Identifiable, ObservableObject {

    public let id: Int
    
    public var valid = false
    @Published public var name: String?
    
    @Published public var ordinalId: Int = 0
    static private let ordinalIdRange = 0...200
    
    @Published public var buildMajor: Int?
    @Published public var buildMinor: Int?
    
    @Published public var cadence: Int?
    static private let cadenceRange = 0...200
    
    @Published public var heartRate: Int?
    static private let heartRateRange = 0...200

    @Published public var power: Int?
    static private let powerRange = 0...400

    @Published public var caloricBurn: Int?
    static private let caloricBurnRange = 0...999

    @Published public var duration: TimeInterval?
    static private let durationStartRange = 0.0...10.0

    @Published public var tripDistance: Double?
    static private let tripStartDistanceRange = 0.0...5.0

    @Published public var gear: Int?
    static private let gearRange = 6...24
    
    init(_ data: Data) {
        self.id = 0
        super.init()
        self.updateWithData(bikeData: data)
    }
    
    init(
        name: String, ordinalId: Int, buildMajor: Int, buildMinor: Int, cadence: Int,
        heartRate: Int, power: Int, caloricBurn: Int, duration: TimeInterval,
        tripDistance: Double, gear: Int
    ) {
        self.id = ordinalId
        super.init()
        
        self.name = name
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
    
    override open func isEqual(_ object: Any?) -> Bool {
        if let otherBike = object as? KeiserBike {
            return self.id == otherBike.id
        }
        return false
    }
    
    public func updateWithData(bikeData _data: Data) {
        
        // a lot of shit could go wrong - invalidate before attempting
        valid = false
        
        // If it includes the Prefix Bits - Ignore these two
        if (_data.count < 17) {
            print("[ERROR] [updateWithData] Incorrectly formed data - found less than 17 Bits (Found \(_data.count) bits)!")
            return
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
                
                // Cadence in RPM (broadcast with decimal precision)
                case 4: cadence = Int(byte)
                case 5: cadence = Int(UInt16(byte) << 8 | UInt16(cadence!))
                
                // Heart Rate in BPM (broadcast with decimal precision)
                case 6: heartRate = Int(byte)
                case 7: heartRate = Int(UInt16(byte) << 8 | UInt16(heartRate!))
                
                // Power in Watts
                case 8: power = Int(byte)
                case 9: power = Int(UInt16(byte) << 8 | UInt16(power!))
                
                // Energy as KCal ("energy burned")
                case 10: caloricBurn = Int(byte)
                case 11: caloricBurn = Int(UInt16(byte) << 8 | UInt16(caloricBurn!))
                
                // Time in Seconds (broadcast as minutes and seconds)
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
        
        // sick...
        valid = true
    }
    
    func simulate() {
        // Add the idea of bikes not updating to simulate them dropping out - will need same mechanism
        // in real life to cull bikes not updated in X seconds...
        //

        if (Int.random(in: 0...1) == 1) {
            self.gear! = min(KeiserBike.gearRange.upperBound, self.gear! + 1)

            if(self.cadence! < KeiserBike.cadenceRange.upperBound) {
                self.cadence! += Int.random(in: 0...100)
            }
            self.heartRate! += Int.random(in: 0...20)
            
            // hack to avoid macking this a float - don't burn 1 calorie a second in real life...
            // only update it some of the time.
            self.caloricBurn! += Int.random(in: 0...1)
        } else {
            self.gear! = max(KeiserBike.gearRange.lowerBound, self.gear! - 1)
            
            if(self.cadence! > KeiserBike.cadenceRange.lowerBound) {
                self.cadence! = max(KeiserBike.cadenceRange.lowerBound, self.cadence! - Int.random(in: 0...100))
            }
            self.heartRate! -= Int.random(in: 0...20)
        }

        self.power = Int(Float(self.gear!) / 64.0 * Float(self.cadence!))

        self.duration = self.duration! + TimeInterval(1)
        self.tripDistance = self.tripDistance! + Double.random(in: 0.001...0.009)
    }
    
    static func fakeRandomBike() -> KeiserBike {
        return KeiserBike.fakeRandomBike(ordinalID: Int.random(in: KeiserBike.ordinalIdRange))
    }
    
    static func fakeRandomBike(ordinalID: Int) -> KeiserBike {
        return KeiserBike(
            name: "M4",
            ordinalId: ordinalID,
            buildMajor: 6,
            buildMinor: 30,
            cadence: Int.random(in: KeiserBike.cadenceRange),
            heartRate: Int.random(in: KeiserBike.heartRateRange),
            power: Int.random(in: KeiserBike.powerRange),
            caloricBurn: Int.random(in: KeiserBike.caloricBurnRange),
            duration: TimeInterval(Double.random(in: KeiserBike.durationStartRange)),
            tripDistance: Double.random(in: KeiserBike.tripStartDistanceRange),
            gear: Int.random(in: 8...12)
        )
    }
    
    static func makeWorkout() {
        // warmup
        
    }
}
