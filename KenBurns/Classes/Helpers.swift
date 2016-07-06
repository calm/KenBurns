import UIKit

extension UIView {    
    var x: CGFloat {
        get {
            return self.frame.origin.x
        } set {
            self.frame = CGRect (x: newValue, y: self.y, width: self.w, height: self.h)
        }
    }
    
    var y: CGFloat {
        get {
            return self.frame.origin.y
        } set {
            self.frame = CGRect (x: self.x, y: newValue, width: self.w, height: self.h)
        }
    }
    
    var w: CGFloat {
        get {
            return self.frame.size.width
        } set {
            self.frame = CGRect (x: self.x, y: self.y, width: newValue, height: self.h)
        }
    }
    
    var h: CGFloat {
        get {
            return self.frame.size.height
        } set {
            self.frame = CGRect (x: self.x, y: self.y, width: self.w, height: newValue)
        }
    }
    
    
    var left: CGFloat {
        get {
            return self.x
        } set {
            self.x = newValue
        }
    }
    
    var right: CGFloat {
        get {
            return self.x + self.w
        } set {
            self.x = newValue - self.w
        }
    }
    
    var top: CGFloat {
        get {
            return self.y
        } set {
            self.y = newValue
        }
    }
    
    var bottom: CGFloat {
        get {
            return self.y + self.h
        } set {
            self.y = newValue - self.h
        }
    }
    
    var position: CGPoint {
        get {
            return self.frame.origin
        } set {
            self.frame = CGRect (origin: newValue, size: self.frame.size)
        }
    }
    
    var size: CGSize {
        get {
            return self.frame.size
        } set {
            self.frame = CGRect (origin: self.frame.origin, size: newValue)
        }
    }
}

extension Array where Element : Equatable {
    mutating func remove(_ object : Element) {
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }
}

class Random {
    class func probability(_ p: Float) -> Bool {
        return floatNorm() < p
    }

    class func floatNorm() -> Float {
        return Float(arc4random()) / Float(UINT32_MAX)
    }

    class func float(_ min: Float, _ max: Float) -> Float {
        return floatNorm() * (max - min) + min
    }

    class func double(_ min: Double, _ max: Double) -> Double {
        return Double(float(Float(min), Float(max)))
    }

    class func int(_ min: Int, _ max: Int) -> Int {
        let range: UInt32 = UInt32(max - min)
        return Int(arc4random_uniform(range)) + min
    }
}
