//
//  ViewController.swift
//  ARKitScene
//
//  Created by Andrey Zubko on 3/27/19.
//  Copyright © 2019 Taqtile. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import IOSTransformGizmos

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet var rotateButton: UIButton!
    @IBOutlet var translateButton: UIButton!
    @IBOutlet var scaleButton: UIButton!
    @IBOutlet var switchSpaceButton: UIButton!
    
    private var transformGizmos: TransformGizmos!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        sceneView.scene = scene
        
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        switchSpaceButton = UIButton(frame: CGRect(x: 0, y: 0, width: width / 2.5, height: height / 10))
        switchSpaceButton.backgroundColor = .gray
        switchSpaceButton.addTarget(self, action: #selector(onSwitchSpaceButtonTapped), for: .touchUpInside)
        
        translateButton = UIButton(frame: CGRect(x: 0, y: height - height / 9, width: width / 3, height: height / 9))
        translateButton .backgroundColor = UIColor(red: 0.0, green: 0.977, blue: 0.0, alpha: 1.0)
        translateButton.setTitle("Move", for: .normal)
        translateButton.addTarget(self, action: #selector(onMoveButtonTapped), for: .touchUpInside)
        
        rotateButton = UIButton(frame: CGRect(x: width / 3 , y: height - height / 9, width: width / 3, height: height / 9))
        rotateButton.backgroundColor = UIColor(red: 1.0, green: 0.149, blue: 0.0, alpha: 1.0)
        rotateButton.setTitle("Rotate", for: .normal)
        rotateButton.addTarget(self, action: #selector(onRotateButtonTapped), for: .touchUpInside)
        
        scaleButton = UIButton(frame: CGRect(x: width / 3 * 2 , y: height - height / 9, width: width / 3, height: height / 9))
        scaleButton.backgroundColor = UIColor(red: 0.017, green: 0.198, blue: 1.0, alpha: 1.0)
        scaleButton.setTitle("Scale", for: .normal)
        scaleButton.addTarget(self, action: #selector(onScaleButtonTapped), for: .touchUpInside)
        
        
        self.view.addSubview(translateButton)
        self.view.addSubview(rotateButton)
        self.view.addSubview(scaleButton)
        self.view.addSubview(switchSpaceButton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(transformTypeChanged), name: TGNotifications.transformTypeChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(editingSpaceChanged), name: TGNotifications.editingSpaceChanged, object: nil)
        transformGizmos = TransformGizmos()
        transformGizmos.scaleMultiplier = 3
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
            translateButton.alpha = 0.4
            rotateButton.alpha = 1
            scaleButton.alpha = 1
        case .rotate:
            translateButton.alpha = 1
            rotateButton.alpha = 0.4
            scaleButton.alpha = 1
        case .scale:
            translateButton.alpha = 1
            rotateButton.alpha = 1
            scaleButton.alpha = 0.4
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()

        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let node = transformGizmos.hitTest(sceneView: sceneView, touch: touches.first!){
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
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        transformGizmos.touchCancelled()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        transformGizmos.renderer()
    }
}
