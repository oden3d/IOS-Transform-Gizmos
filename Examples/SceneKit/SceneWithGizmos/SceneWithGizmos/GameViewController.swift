//
//  GameViewController.swift
//  SceneWithGizmos
//
//  Created by Andrey Zubko on 3/27/19.
//  Copyright © 2019 Taqtile. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import IOSTransformGizmos

class GameViewController: UIViewController, SCNSceneRendererDelegate {

    @IBOutlet var sceneView: SCNView!
    
    @IBOutlet var rotateButton: UIButton!
    @IBOutlet var translateButton: UIButton!
    @IBOutlet var scaleButton: UIButton!
    @IBOutlet var switchSpaceButton: UIButton!
    
    private var transformGizmos: TransformGizmos!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView = self.view as? SCNView
        
        sceneView.delegate = self
        
        sceneView.allowsCameraControl = true
        
        sceneView.backgroundColor = UIColor.lightGray
        
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
 
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
  
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        sceneView.scene = scene
        
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        switchSpaceButton = UIButton(frame: CGRect(x: 0, y: 0, width: width / 2.5, height: height / 10))
        switchSpaceButton.layer.cornerRadius = 25
        switchSpaceButton.layer.masksToBounds = true
        switchSpaceButton.backgroundColor = UIColor.darkGray
        switchSpaceButton.addTarget(self, action: #selector(onSwitchSpaceButtonTapped), for: .touchUpInside)
        
        translateButton = UIButton(frame: CGRect(x: 0, y: height - height / 9, width: width / 3, height: height / 9))
        translateButton.layer.cornerRadius = 25
        translateButton.layer.masksToBounds = true
        translateButton.setTitle("Move", for: .normal)
        translateButton.addTarget(self, action: #selector(onMoveButtonTapped), for: .touchUpInside)
        
        rotateButton = UIButton(frame: CGRect(x: width / 3 , y: height - height / 9, width: width / 3, height: height / 9))
        rotateButton.layer.cornerRadius = 25
        rotateButton.layer.masksToBounds = true
        rotateButton.setTitle("Rotate", for: .normal)
        rotateButton.addTarget(self, action: #selector(onRotateButtonTapped), for: .touchUpInside)
        
        scaleButton = UIButton(frame: CGRect(x: width / 3 * 2 , y: height - height / 9, width: width / 3, height: height / 9))
        scaleButton.layer.cornerRadius = 25
        scaleButton.layer.masksToBounds = true
        scaleButton.setTitle("Scale", for: .normal)
        scaleButton.addTarget(self, action: #selector(onScaleButtonTapped), for: .touchUpInside)
        
        
        self.view.addSubview(translateButton)
        self.view.addSubview(rotateButton)
        self.view.addSubview(scaleButton)
        self.view.addSubview(switchSpaceButton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(transformTypeChanged), name: TGNotifications.transformTypeChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(editingSpaceChanged), name: TGNotifications.editingSpaceChanged, object: nil)
        transformGizmos = TransformGizmos()
        transformGizmos.scaleMultiplier = 0.5
    }
    
    @objc func editingSpaceChanged(notification: Notification){
        let data = notification.userInfo as! [String: TransformGizmos.Space]
        let space = data["newValue"]
        switchSpaceButton.setTitle("current: " + space!.rawValue, for: .normal)
    }
    
    @objc func transformTypeChanged(notification: Notification){
        let data = notification.userInfo as! [String : TransformGizmos.TransformType]
        let transformType = data["newValue"]
        switch transformType! {
        case .translate:
            translateButton.backgroundColor = UIColor.orange
            rotateButton.backgroundColor = UIColor.clear
            scaleButton.backgroundColor = UIColor.clear
        case .rotate:
            translateButton.backgroundColor = UIColor.clear
            rotateButton.backgroundColor = UIColor.orange
            scaleButton.backgroundColor = UIColor.clear
        case .scale:
            translateButton.backgroundColor = UIColor.clear
            rotateButton.backgroundColor = UIColor.clear
            scaleButton.backgroundColor = UIColor.orange
        }
    }
    
    @objc func onMoveButtonTapped(sender: UIButton!){
        guard transformGizmos.currentTransformType != TransformGizmos.TransformType.translate else {return}
        transformGizmos.currentTransformType = TransformGizmos.TransformType.translate
    }
    
    @objc func onRotateButtonTapped(sender: UIButton!){
        guard transformGizmos.currentTransformType != TransformGizmos.TransformType.rotate else {return}
        transformGizmos.currentTransformType = TransformGizmos.TransformType.rotate
    }
    
    @objc func onScaleButtonTapped(sender: UIButton!){
        guard transformGizmos.currentTransformType != TransformGizmos.TransformType.scale else {return}
        transformGizmos.currentTransformType = TransformGizmos.TransformType.scale
    }
    
    @objc func onSwitchSpaceButtonTapped(sender: UIButton!){
        transformGizmos.switchEditingSpace()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let node = transformGizmos.hitTest(sceneView: sceneView, touch: touches.first!){
            sceneView.allowsCameraControl = false
            transformGizmos.drawCurrentGizmo(sceneView: sceneView, targetNode: node)
        }
        else {
            transformGizmos.clearGizmos()
        }
        transformGizmos.touchBegan(touch: touches.first!)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        transformGizmos.touchMoved(touch: touches.first!)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        transformGizmos.touchEnded()
        sceneView.allowsCameraControl = true
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        transformGizmos.touchCancelled()
        sceneView.allowsCameraControl = true
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        transformGizmos.renderer()
    }
}
