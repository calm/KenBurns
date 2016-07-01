import Foundation

public class Random {
    public class func probability(_ p: Float) -> Bool {
        return floatNorm() < p
    }

    public class func floatNorm() -> Float {
        return Float(arc4random()) / Float(UINT32_MAX)
    }

    public class func cgFloatNorm() -> CGFloat {
        return CGFloat(floatNorm())
    }

    public class func float(_ min: Float, _ max: Float) -> Float {
        return floatNorm() * (max - min) + min
    }

    public class func double(_ min: Double, _ max: Double) -> Double {
        return Double(float(Float(min), Float(max)))
    }

    public class func int(_ min: Int, _ max: Int) -> Int {
        let range: UInt32 = UInt32(max - min)
        return Int(arc4random_uniform(range)) + min
    }
}
