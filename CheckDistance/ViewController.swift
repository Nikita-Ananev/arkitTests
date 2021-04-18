//
//  ViewController.swift
//  CheckDistance
//
//  Created by Никита Ананьев on 18.04.2021.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    @IBAction func addSphereButtonPressed(_ sender: UIButton) {
        
        let tapLocation = self.arView.center
        let hitTestResults = arView.hitTest(tapLocation, types:.featurePoint)
        
        guard let x = hitTestResults.first?.worldTransform.columns.3.x,let y = hitTestResults.first?.worldTransform.columns.3.y, let z = hitTestResults.first?.worldTransform.columns.3.z  else {return}
        
        let radius = 0.005

        let entity = ModelEntity(mesh: .generateSphere(radius: Float(radius)))

        let anchor = AnchorEntity(world: [x, y, z])
        
        anchor.addChild(entity)
        arView.scene.anchors.append(anchor)
    }

    @IBAction func clearSceneButtonPressed(_ sender: UIButton) {
        arView.scene.anchors.removeAll()
    }
}
