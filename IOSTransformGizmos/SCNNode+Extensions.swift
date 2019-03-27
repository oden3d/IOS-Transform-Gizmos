//
//  Transform+Extensions.swift
//  TransformGizmos
//
//  Created by Andrey Zubko on 3/4/19.
//  Copyright © 2019 Andrey Zubko. All rights reserved.
//

import SceneKit

extension SCNNode{
    
    public var forward: SCNVector3{
        let rotation = self.worldOrientation
        return rotation * SCNVector3.forward
    }
    
    public var back: SCNVector3{
        let rotation = self.worldOrientation
        return rotation * SCNVector3.back
    }
    
    public var up: SCNVector3{
        let rotation = self.worldOrientation
        return rotation * SCNVector3.up
    }
    
    public var down: SCNVector3{
        let rotation = self.worldOrientation
        return rotation * SCNVector3.down
    }
    
    public var right: SCNVector3{
        let rotation = self.worldOrientation
        return rotation * SCNVector3.right
    }
    
    public var left: SCNVector3{
        let rotation = self.worldOrientation
        return rotation * SCNVector3.left
    }
}
