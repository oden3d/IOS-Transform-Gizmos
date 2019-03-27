//
//  TransformGizmos.swift
//  TransformGizmos
//
//  Created by Andrey Zubko on 2/27/19.
//  Copyright © 2019 Andrey Zubko. All rights reserved.
//

import SceneKit

public class TransformGizmos : NSObject {
    
    private var sceneView: SCNView!
    private var node: SCNNode!
    
    private var selectedAxis: SCNNode!
    private var lastTouchPosition: SCNVector3!
    private var lastTouch2DPosition: CGPoint!
    private var nodeStartScale: SCNVector3!
    
    private var xAxis: SCNNode!
    private var yAxis: SCNNode!
    private var zAxis: SCNNode!
    
    public var scaleMultiplier: Float!
    public var gizmoSize: Float!
    
    public var editingSpace: Space!{
        willSet{
            UpdateAxesRotation(editingSpace: newValue)
            NotificationCenter.default.post(name: TGNotifications.editingSpaceChanged, object: nil, userInfo: ["newValue" : newValue!])
        }
    }
    
    public var currentTransformType: TransformType!{
        willSet{
            NotificationCenter.default.post(name: TGNotifications.transformTypeChanged, object: nil, userInfo: ["newValue" : newValue!])
        }
        didSet{
            guard sceneView != nil && node != nil else {return}
            drawGizmo(sceneView: sceneView, targetNode: node)
        }
    }
    
    public enum Axis {
        case x
        case y
        case z
    }
    
    public enum Space : String{
        case local
        case world
    }
    
    public enum TransformType{
        case translate
        case rotate
        case scale
    }
    
    public override init() {
        editingSpace = Space.local
        currentTransformType = TransformType.translate
        NotificationCenter.default.post(name: TGNotifications.transformTypeChanged, object: nil, userInfo: ["newValue" : currentTransformType!])
        NotificationCenter.default.post(name: TGNotifications.editingSpaceChanged, object: nil, userInfo: ["newValue" : editingSpace!])
        scaleMultiplier = 1
        gizmoSize = 1
    }
    
    private func createGizmoAxis(axis: Axis, transformType: TransformType) -> SCNNode{
        var returnNode = SCNNode()
        var nodeName: String!
        let material = SCNMaterial()
        
        material.readsFromDepthBuffer = false
        
        switch axis{
        case .x:
            material.diffuse.contents = UIColor(red: 1.0, green: 0.149, blue: 0.0, alpha: 1.0)
            nodeName = "xAxis"
        case .y:
            material.diffuse.contents = UIColor(red: 0.0, green: 0.977, blue: 0.0, alpha: 1.0)
            nodeName = "yAxis"
        case .z:
            material.diffuse.contents = UIColor(red: 0.017, green: 0.198, blue: 1.0, alpha: 1.0)
            nodeName = "zAxis"
        }
        
        switch transformType {
        case .translate:
            let cylinder = SCNCylinder(radius: 0.02, height: 1)
            cylinder.firstMaterial = material
            let cylinderNode = SCNNode(geometry: cylinder)
            
            let cone = SCNCone(topRadius: 0, bottomRadius: 0.1, height: 0.3)
            cone.firstMaterial = material
            let coneNode = SCNNode(geometry: cone)
            
            returnNode.addChildNode(cylinderNode)
            returnNode.addChildNode(coneNode)
            
            cylinderNode.position = SCNVector3(x: 0, y: 0, z: 0.5)
            cylinderNode.eulerAngles = SCNVector3(x: Constants.RadianRightAngle, y: 0, z: 0)
            coneNode.position = SCNVector3(x: 0, y: 0, z: 1.1)
            coneNode.eulerAngles = SCNVector3(x: Constants.RadianRightAngle, y: 0, z: 0)
        case .rotate:
            let torus = SCNTorus(ringRadius: 1.25, pipeRadius: 0.035)
            torus.firstMaterial = material
            returnNode = SCNNode(geometry: torus)
        case .scale:
            let cylinder = SCNCylinder(radius: 0.02, height: 1)
            cylinder.firstMaterial = material
            let cylinderNode = SCNNode(geometry: cylinder)
            
            let box = SCNBox(width: 0.15, height: 0.15, length: 0.15, chamferRadius: 0)
            box.firstMaterial = material
            let boxNode = SCNNode(geometry: box)
            
            returnNode.addChildNode(cylinderNode)
            returnNode.addChildNode(boxNode)
            
            cylinderNode.position = SCNVector3(x: 0, y: 0, z: 0.5)
            cylinderNode.eulerAngles = SCNVector3(x: Constants.RadianRightAngle, y: 0, z: 0)
            boxNode.position = SCNVector3(x: 0, y: 0, z: 1)
        }
        
        returnNode.name = nodeName
        return returnNode
    }
    
    private func drawGizmo(sceneView:SCNView, targetNode: SCNNode){
        clearGizmos()
        
        node = targetNode
        self.sceneView = sceneView
    
        drawGizmoAxes(sceneView: sceneView, transformType: currentTransformType)
    }
    
    public func drawCurrentGizmo(sceneView:SCNView, targetNode: SCNNode){
        if ((node != nil && targetNode == node) || (targetNode == xAxis || targetNode == yAxis || targetNode == zAxis) || (targetNode.parent != nil && (targetNode.parent == xAxis || targetNode.parent == yAxis || targetNode.parent == zAxis))){
            return
        }
        
        drawGizmo(sceneView: sceneView, targetNode: targetNode)
    }
    
    private func drawGizmoAxes(sceneView: SCNView, transformType: TransformType){
        xAxis = createGizmoAxis(axis: Axis.x, transformType: transformType)
        yAxis = createGizmoAxis(axis: Axis.y, transformType: transformType)
        zAxis = createGizmoAxis(axis: Axis.z, transformType: transformType)
        
        let nodePosition = node.worldPosition
        
        xAxis.position = nodePosition
        yAxis.position = nodePosition
        zAxis.position = nodePosition
        
        UpdateAxesRotation(editingSpace: editingSpace)
        
        sceneView.scene!.rootNode.addChildNode(xAxis)
        sceneView.scene!.rootNode.addChildNode(yAxis)
        sceneView.scene!.rootNode.addChildNode(zAxis)
    }
    
    public func clearGizmos(){
        if (xAxis != nil && yAxis != nil && zAxis != nil){
            xAxis.removeFromParentNode()
            yAxis.removeFromParentNode()
            zAxis.removeFromParentNode()
            xAxis = nil
            yAxis = nil
            zAxis = nil
        }
        sceneView = nil
        node = nil
        selectedAxis = nil
        lastTouchPosition = nil
        lastTouch2DPosition = nil
        nodeStartScale = nil
    }
    
    public func switchEditingSpace(){
        switch editingSpace!{
        case .local:
            editingSpace = Space.world
        case .world:
            editingSpace = Space.local
        }
    }
    
    public func hitTest(sceneView: SCNView, touch: UITouch) -> SCNNode?{
        let hitResult = sceneView.hitTest(touch.location(in: sceneView), options: [SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue])
        guard hitResult.count != 0 else {return nil}
        switch currentTransformType! {
        case .translate:
            if let hit = hitResult.first(where: {$0.node.parent == xAxis || $0.node.parent == yAxis || $0.node.parent == zAxis}){
                return hit.node.parent
            }
            else {
                return hitResult.first?.node
            }
        case .rotate:
            if let hit = hitResult.first(where: {$0.node == xAxis || $0.node == yAxis || $0.node == zAxis}){
                return hit.node
            }
            else {
                return hitResult.first?.node
            }
        case .scale:
            if let hit = hitResult.first(where: {$0.node.parent == xAxis || $0.node.parent == yAxis || $0.node.parent == zAxis}){
                return hit.node.parent
            }
            else {
                return hitResult.first?.node
            }
        }
    }
    
    public func touchBegan(touch: UITouch) {
        guard sceneView != nil else {return}

        switch currentTransformType!{
        case .translate:
            if let hit = sceneView.hitTest(touch.location(in: sceneView), options:[SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue]).first(where: {$0.node.parent == xAxis || $0.node.parent == yAxis || $0.node.parent == zAxis}) {
                selectedAxis = hit.node.parent
                let zDepth = sceneView.projectPoint(selectedAxis.position).z
                let touch2D = touch.location(in: sceneView)
                let touch3D = SCNVector3(Float(touch2D.x), Float(touch2D.y), zDepth)
                lastTouchPosition = sceneView.unprojectPoint(touch3D)
            }
            
        case .rotate:
            if let hit = sceneView.hitTest(touch.location(in: sceneView), options:[SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue]).first(where: {$0.node == xAxis || $0.node == yAxis || $0.node == zAxis}) {
                selectedAxis = hit.node
                lastTouch2DPosition = touch.location(in: sceneView)
            }
            
        case .scale:
            if let hit = sceneView.hitTest(touch.location(in: sceneView), options:[SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue]).first(where: {$0.node.parent == xAxis || $0.node.parent == yAxis || $0.node.parent == zAxis}) {
                selectedAxis = hit.node.parent
                let zDepth = sceneView.projectPoint(selectedAxis.position).z
                let touch2D = touch.location(in: sceneView)
                let touch3D = SCNVector3(Float(touch2D.x), Float(touch2D.y), zDepth)
                lastTouchPosition = sceneView.unprojectPoint(touch3D)
                nodeStartScale = node.scale
            }
        }
        
        if selectedAxis != nil {
            if selectedAxis == xAxis{
                yAxis.opacity = 0.1
                zAxis.opacity = 0.1
            }
            else if selectedAxis == yAxis{
                xAxis.opacity = 0.1
                zAxis.opacity = 0.1
            }
            else if selectedAxis == zAxis{
                xAxis.opacity = 0.1
                yAxis.opacity = 0.1
            }
        }
    }
    
    public func touchMoved(touch: UITouch) {
        guard selectedAxis != nil && sceneView != nil else {return}

        let touch2D = touch.location(in: sceneView)
        
        switch currentTransformType! {
        case .translate:
            let zDepth = sceneView.projectPoint(selectedAxis.position).z
            let touch3D = SCNVector3(Float(touch2D.x), Float(touch2D.y), zDepth)
            let touchPosition = sceneView.unprojectPoint(touch3D)
            
            let touchDelta = touchPosition - lastTouchPosition
            let distance = touchDelta.magnitude
            let direction = touchDelta.normalized
            let zTranslation = distance * SCNVector3.dot(a: selectedAxis.forward, b: direction) 
            
            selectedAxis.localTranslate(by: SCNVector3(0, 0, zTranslation))
            
            if selectedAxis == xAxis{
                yAxis.position = selectedAxis.position
                zAxis.position = selectedAxis.position
            }
            else if selectedAxis == yAxis{
                xAxis.position = selectedAxis.position
                zAxis.position = selectedAxis.position
                
            }
            else if selectedAxis == zAxis{
                xAxis.position = selectedAxis.position
                yAxis.position = selectedAxis.position
                
            }
            
            node.worldPosition = selectedAxis.position
            lastTouchPosition = touchPosition
            
        case .rotate:
            let rotationAngle = Float(touch2D.y - lastTouch2DPosition.y)
            
            let nodeScale = node.scale
            node.scale = SCNVector3.one
            
            switch editingSpace!{
            case .local:
                if selectedAxis == xAxis{
                    node.worldOrientation = SCNQuaternion.angleAxis(angle: rotationAngle, axis: node.right) * node.worldOrientation
                }
                else if selectedAxis == yAxis{
                    node.worldOrientation = SCNQuaternion.angleAxis(angle: rotationAngle, axis: node.up) * node.worldOrientation
                }
                else if selectedAxis == zAxis{
                    node.worldOrientation = SCNQuaternion.angleAxis(angle: rotationAngle, axis: node.forward) * node.worldOrientation
                }
                
                xAxis.worldOrientation = SCNQuaternion.angleAxis(angle: 90, axis: node.forward) * node.worldOrientation
                yAxis.worldOrientation = node.worldOrientation
                zAxis.worldOrientation = SCNQuaternion.angleAxis(angle: 90, axis: node.left) * node.worldOrientation
                
            case .world:
                if selectedAxis == xAxis{
                    node.worldOrientation = SCNQuaternion.angleAxis(angle: rotationAngle, axis: SCNVector3.right) * node.worldOrientation
                }
                else if selectedAxis == yAxis{
                    node.worldOrientation = SCNQuaternion.angleAxis(angle: rotationAngle, axis: SCNVector3.up) * node.worldOrientation
                }
                else if selectedAxis == zAxis{
                    node.worldOrientation = SCNQuaternion.angleAxis(angle: rotationAngle, axis: SCNVector3.forward) * node.worldOrientation
                }
            }
            
            node.scale = nodeScale
            
            lastTouch2DPosition = touch2D
            
        case .scale:
            let nodeScale = node.scale
            let zDepth = sceneView.projectPoint(selectedAxis.position).z
            let touch3D = SCNVector3(Float(touch2D.x), Float(touch2D.y), zDepth)
            let touchPosition = sceneView.unprojectPoint(touch3D)
            
            let touchDelta = touchPosition - lastTouchPosition
            let distance = touchDelta.magnitude
            let direction = touchDelta.normalized
            let scale = distance * SCNVector3.dot(a: selectedAxis.forward, b: direction) * scaleMultiplier
            
            if selectedAxis == xAxis{
                node.scale = SCNVector3(nodeScale.x + nodeStartScale.x * scale, nodeScale.y, nodeScale.z)
            }
            else if selectedAxis == yAxis{
                node.scale = SCNVector3(nodeScale.x, nodeScale.y + abs(nodeStartScale.y) * scale, nodeScale.z)
            }
            else if selectedAxis == zAxis{
                node.scale = SCNVector3(nodeScale.x, nodeScale.y, nodeScale.z + nodeStartScale.z * scale)
            }
            lastTouchPosition = touchPosition
        }
    }
    
    private func UpdateAxesRotation(editingSpace: Space){
        guard xAxis != nil && yAxis != nil && zAxis != nil else {return}
        
        let nodeScale = node.scale
        node.scale = SCNVector3.one
        
        let nodeOrientation = node.worldOrientation
        
        switch currentTransformType!{
        case .translate:
            switch editingSpace{
            case .local:
                xAxis.worldOrientation = SCNQuaternion.angleAxis(angle: 90, axis: node.up) * nodeOrientation
                yAxis.worldOrientation = SCNQuaternion.angleAxis(angle: 90, axis: node.left) * nodeOrientation
                zAxis.worldOrientation = nodeOrientation
                
            case .world:
                xAxis.eulerAngles = SCNVector3(0, Constants.RadianRightAngle, 0)
                yAxis.eulerAngles = SCNVector3(-Constants.RadianRightAngle, 0, 0)
                zAxis.eulerAngles = SCNVector3.zero
            }
            
        case .rotate:
            switch editingSpace{
            case .local:
                xAxis.worldOrientation = SCNQuaternion.angleAxis(angle: 90, axis: node.forward) * nodeOrientation
                yAxis.worldOrientation = nodeOrientation
                zAxis.worldOrientation = SCNQuaternion.angleAxis(angle: 90, axis: node.left) * nodeOrientation
                
            case .world:
                xAxis.eulerAngles = SCNVector3(0, 0, Constants.RadianRightAngle)
                yAxis.eulerAngles = SCNVector3.zero
                zAxis.eulerAngles = SCNVector3(Constants.RadianRightAngle, 0, 0)
            }
            
        case .scale:
            xAxis.worldOrientation = SCNQuaternion.angleAxis(angle: 90, axis: node.up) * nodeOrientation
            yAxis.worldOrientation = SCNQuaternion.angleAxis(angle: 90, axis: node.left) * nodeOrientation
            zAxis.worldOrientation = nodeOrientation
        }
        
        node.scale = nodeScale
    }
    
    private func resetSelectedAxis(){
        guard xAxis != nil && yAxis != nil && zAxis != nil else {return}
        xAxis.opacity = 1
        yAxis.opacity = 1
        zAxis.opacity = 1
        selectedAxis = nil
    }
    
    public func touchEnded() {
        resetSelectedAxis()
    }
    
    public func touchCancelled() {
        resetSelectedAxis()
    }
    
    public func renderer() {
        guard sceneView != nil && node != nil && xAxis != nil && yAxis != nil && zAxis != nil else {return}
        let distance = simd_distance((sceneView.pointOfView?.simdPosition)!, node.simdWorldPosition)
        let scale = distance * 0.2 * gizmoSize
        let scaleVector = SCNVector3(scale, scale, scale)
        xAxis.scale = scaleVector
        yAxis.scale = scaleVector
        zAxis.scale = scaleVector
    }
}

