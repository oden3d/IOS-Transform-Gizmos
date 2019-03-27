//
//  SCNQuaternionExtensions.swift
//  TransformGizmos
//
//  Created by Andrey Zubko on 3/1/19.
//  Copyright © 2019 Andrey Zubko. All rights reserved.
//

import SceneKit

extension SCNQuaternion{
    
    public static var identity: SCNQuaternion { return SCNQuaternion(x: 0, y: 0, z: 0, w: 1) }
    
    public static func dot(a: SCNQuaternion, b: SCNQuaternion) -> Float{
        return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w
    }
    
    public var magnitude: Float{
        return sqrt(x * x + y * y + z * z + w * w)
    }
    
    public var normalized: SCNQuaternion{
        let mag = sqrt(SCNQuaternion.dot(a: self, b: self))
        if mag < .ulpOfOne {
            return SCNQuaternion.identity
        }
        return SCNQuaternion(x: x / mag, y: y / mag , z: z / mag, w: w / mag)
    }
    
    public mutating func normalize(){
        self = self.normalized
    }
    
    public static func angleAxis(angle: Float, axis: SCNVector3) -> SCNQuaternion{
        if axis.sqrMagnitude == 0 {
            return SCNQuaternion.identity
        }
        
        var radians = angle * .pi / 180
        radians *= 0.5
        var normalizedAxis = axis.normalized
        normalizedAxis = normalizedAxis * sin(radians)
        
        return SCNQuaternion(
            x: normalizedAxis.x,
            y: normalizedAxis.y,
            z: normalizedAxis.z,
            w: cos(radians)).normalized
    }
    
    public static func fromEuler(x: Float, y: Float, z: Float) -> SCNQuaternion{
        let cosX = cos(x * 0.5)
        let sinX = sin(x * 0.5)
        let cosY = cos(y * 0.5)
        let sinY = sin(y * 0.5)
        let cosZ = cos(z * 0.5)
        let sinZ = sin(z * 0.5)
        
        return SCNQuaternion(
            x: cosZ * cosY * sinX - sinZ * sinY * cosX,
            y: sinZ * cosY * sinX + cosZ * sinY * cosX,
            z: sinZ * cosY * cosX - cosZ * sinY * sinX,
            w: cosZ * cosY * cosX + sinZ * sinY * sinX)
    }
    
    public static func *(lhs: SCNQuaternion, rhs: SCNQuaternion) -> SCNQuaternion{
        return SCNQuaternion(
            x: lhs.w * rhs.x + lhs.x * rhs.w + lhs.y * rhs.z - lhs.z * rhs.y,
            y: lhs.w * rhs.y + lhs.y * rhs.w + lhs.z * rhs.x - lhs.x * rhs.z,
            z: lhs.w * rhs.z + lhs.z * rhs.w + lhs.x * rhs.y - lhs.y * rhs.x,
            w: lhs.w * rhs.w - lhs.x * rhs.x - lhs.y * rhs.y - lhs.z * rhs.z)
    }
    
    public static func *(rotation:SCNQuaternion, point: SCNVector3)-> SCNVector3{
        let x = rotation.x * 2
        let y = rotation.y * 2
        let z = rotation.z * 2
        let xx = rotation.x * x
        let yy = rotation.y * y
        let zz = rotation.z * z
        let xy = rotation.x * y
        let xz = rotation.x * z
        let yz = rotation.y * z
        let wx = rotation.w * x
        let wy = rotation.w * y
        let wz = rotation.w * z
        
        return SCNVector3(
            x: (1 - (yy + zz)) * point.x + (xy - wz) * point.y + (xz + wy) * point.z,
            y: (xy + wz) * point.x + (1 - (xx + zz)) * point.y + (yz - wx) * point.z,
            z: (xz - wy) * point.x + (yz + wx) * point.y + (1 - (xx + yy)) * point.z)
    }
}
