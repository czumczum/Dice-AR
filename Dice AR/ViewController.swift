//
//  ViewController.swift
//  Dice AR
//
//  Created by Ula Kuczynska on 7/6/18.
//  Copyright © 2018 Ula Kuczynska. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var diceArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            let result = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            if let hitResult = result.first {
                // Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                    diceNode.position = SCNVector3 (x: hitResult.worldTransform.columns.3.x,
                                                y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                                                z: hitResult.worldTransform.columns.3.z)
                    
                    diceArray.append(diceNode)
        
                    sceneView.scene.rootNode.addChildNode(diceNode)
                
                }
            }
        }
    }
    
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    @IBAction func rollButtonClicked(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    func roll(dice: SCNNode) {
        let randomXrad = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZrad = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomX = Float(arc4random_uniform(10) + 1)
        let randomZ = Float(arc4random_uniform(10) + 1)
        
        dice.runAction(
            SCNAction.rotateBy(
                x: CGFloat(randomXrad * 5),
                y: 0,
                z: CGFloat(randomZrad * 5),
                duration: Double((randomZ + randomX)/40)
                )
            )
        dice.runAction(
            SCNAction.moveBy(x: -CGFloat(randomX/50),
                             y: 0,
                             z: -CGFloat(randomZ/50),
                             duration: Double((randomZ + randomX)/40)
            )
        )
    
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            let planeNode = SCNNode()
            
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
            
        } else {
            return
        }
    }
  
}
