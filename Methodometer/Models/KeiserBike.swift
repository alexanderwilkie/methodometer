import Foundation
import CoreGraphics

enum KeiserBikeError: Error {
    case runtimeError(String)
}

open class KeiserBike: NSObject, Identifiable, ObservableObject {

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
    static private let durationRange = 0.0...999.0

    @Published public var tripDistance: Double?
    static private let tripDistanceRange = 0.0...999.0

    @Published public var gear: Int?
    static private let gearRange = 0...24
    
    init(_ data: Data) {
        super.init()
        self.updateWithData(bikeData: data)
    }
    
    init(
        name: String, ordinalId: Int, buildMajor: Int, buildMinor: Int, cadence: Int,
        heartRate: Int, power: Int, caloricBurn: Int, duration: TimeInterval,
        tripDistance: Double, gear: Int
    ) {
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
    
    public func updateWithData(bikeData _data: Data) {
        
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
    }
    
    func simulate(seconds duration: Int, interval: Int = 1) {
        var effortPredictor: Int {
            let e = Int.random(in: 0...100) + 1
            if (e >= 60) {
                return 1
            } else if (e >= 40) {
                return 0
            } else {
                return -1
            }
        }
        var x = 0
        
        let t = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval), repeats: true) { timer in
            x += interval
            let ep = effortPredictor
            print(ep)
            
            if (ep == 1) {
                if (self.gear! < KeiserBike.gearRange.upperBound) {
                    self.gear! += 1
                }
                
                if(self.cadence! < KeiserBike.cadenceRange.upperBound) {
                    self.cadence! += Int.random(in: 0...100) + 1
                }
                
                self.heartRate! += Int.random(in: 0...20) + 1 + 11
            } else if (ep == -1) {
                 if (self.gear! > KeiserBike.gearRange.lowerBound) {
                    self.gear! -= 1
                }
                
                if(self.cadence! > KeiserBike.cadenceRange.lowerBound) {
                    self.cadence! -= Int.random(in: 0...100) + 1
                }
                
                self.heartRate! -= Int.random(in: 0...20) + 1 + 11
            }

            self.power = Int(Float(self.gear!) / 64.0 * Float(self.cadence!))

            self.caloricBurn! += Int.random(in: 0...10)
            
            self.duration = self.duration! + TimeInterval(x)
            self.tripDistance = Double(self.power! / 1000)
            
            print("[DEBUG] \(self.description) at interval \(x) \(self.cadence)")
            
            if x == duration {
                print("[DEBUG] Bike: \(self.ordinalId) has finished simulating!")
                timer.invalidate()
            }
        }
        RunLoop.main.add(t, forMode: .common)
     }
    
    public override var description: String {
        return "[Bike: \(self.ordinalId)] cdn: \(self.cadence). hr: \(heartRate). power: \(power). caloricBurn: \(caloricBurn). dur: \(duration). tripDistance: \(tripDistance). gear: \(gear)"
    }
    
    static func fakeRandomBike(duration: Int) -> KeiserBike {
        let kb = KeiserBike(
            name: "M4",
            ordinalId: Int.random(in: KeiserBike.ordinalIdRange),
            buildMajor: 6,
            buildMinor: 30,
            cadence: Int.random(in: KeiserBike.cadenceRange),
            heartRate: Int.random(in: KeiserBike.heartRateRange),
            power: Int.random(in: KeiserBike.powerRange),
            caloricBurn: Int.random(in: KeiserBike.caloricBurnRange),
            duration: TimeInterval(Double.random(in: KeiserBike.durationRange)),
            tripDistance: Double.random(in: KeiserBike.tripDistanceRange),
            gear: Int.random(in: KeiserBike.gearRange)
        )
        
        if (duration > 0) {
            kb.simulate(seconds: duration)
        }
        
        return kb
    }
}
