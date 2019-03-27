//
//  SCNVector3+Extensions.swift
//  TransformGizmos
//
//  Created by Andrey Zubko on 3/4/19.
//  Copyright © 2019 Andrey Zubko. All rights reserved.
//

import SceneKit

extension SCNVector3{
    
    public static var forward: SCNVector3 { return SCNVector3(0, 0, 1) }
    
    public static var back: SCNVector3 { return SCNVector3(0, 0, -1) }
    
    public static var right: SCNVector3 { return SCNVector3(1, 0, 0) }
    
    public static var left: SCNVector3 { return SCNVector3(-1, 0, 0) }
    
    public static var up: SCNVector3 { return SCNVector3(0, 1, 0) }
    
    public static var down: SCNVector3 { return SCNVector3(0, -1, 0) }
    
    public static var zero: SCNVector3 { return SCNVector3(0, 0, 0) }
    
    public static var one: SCNVector3 { return SCNVector3(1, 1, 1) }
    
    public static var positiveInfinity: SCNVector3 { return SCNVector3(Float.infinity, Float.infinity, Float.infinity) }
    
    public static var negativeInfinity: SCNVector3 { return SCNVector3(-Float.infinity, -Float.infinity, -Float.infinity) }
    
    public var magnitude: Float{
        return sqrt(x * x + y * y + z * z)
    }
    
    public var sqrMagnitude: Float{
        return x * x + y * y + z * z
    }
    
    public var normalized: SCNVector3{
        if self.magnitude == 0{
            return self
        }
        return self / self.magnitude
    }
    
    public mutating func normalize(){
        self = self.normalized
    }
    
    public static func dot(a: SCNVector3, b: SCNVector3) -> Float{
        return a.x * b.x + a.y * b.y + a.z * b.z
    }
    
    public static func angle(a: SCNVector3, b: SCNVector3) -> Float{
        let dp = dot(a: a, b: b)
        let magProduct = a.magnitude * b.magnitude
        return acos(dp/magProduct)
    }
    
    public static func / (left: SCNVector3, right: SCNVector3) -> SCNVector3{
        return SCNVector3Make(left.x / right.x, left.y / right.y, left.z / right.z)
    }
    
    public static func / (vector: SCNVector3, scalar: Float) -> SCNVector3{
        return SCNVector3Make(vector.x / scalar, vector.y / scalar, vector.z / scalar)
    }
    
    public static func * (vector: SCNVector3, scalar: Float) -> SCNVector3{
        return SCNVector3Make(vector.x * scalar, vector.y * scalar, vector.z * scalar)
    }
    
    public static func - (left: SCNVector3, right: SCNVector3) -> SCNVector3{
        return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
    }
}
