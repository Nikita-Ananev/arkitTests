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
    @IBOutlet weak var label: UILabel!
    var isSceneClear = true

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func addSphereButtonPressed(_ sender: UIButton) {
        
        let tapLocation = self.arView.center
        let hitTestResults = arView.hitTest(tapLocation, types:.featurePoint)
        
        guard let x = hitTestResults.first?.worldTransform.columns.3.x,
              let y = hitTestResults.first?.worldTransform.columns.3.y,
              let z = hitTestResults.first?.worldTransform.columns.3.z  else {return}
        
        let sphere = MeshResource.generateSphere(radius: 0.005)
        let material = SimpleMaterial(color: .cyan, roughness: 0, isMetallic: true)
        let entity = ModelEntity(mesh: sphere, materials: [material])
        let anchor = AnchorEntity(world: [x, y, z])
        
        anchor.addChild(entity)
        arView.scene.anchors.append(anchor)
        entity.generateCollisionShapes(recursive: true)
        arView.installGestures([.all], for: entity)
        
        
        isSceneClear = false
        searchClosestAnchor()
        
    }

    @IBAction func clearSceneButtonPressed(_ sender: UIButton) {
        arView.scene.anchors.removeAll()
        isSceneClear = true
    }
    
    func searchClosestAnchor() {

        DispatchQueue.global(qos: .utility).async { [self] in
            
            while isSceneClear == false {
                let anchors = arView.scene.anchors
                for anchor in anchors  {
                    guard let camera = arView.session.currentFrame?.camera else{ return }
                    let xCam = (camera.transform.columns.3.x)
                    let yCam = (camera.transform.columns.3.y)
                    let zCam = (camera.transform.columns.3.z)
                    
                    let x = anchor.position.x
                    let y = anchor.position.y
                    let z = anchor.position.z
                    
                    let distance = sqrt(pow((xCam - x), 2)  + pow((yCam - y), 2) + pow((zCam - z), 2))
                    DispatchQueue.main.async {
                        label.text = String(distance)
                    }
                    sleep(1)


                }
            }
        }
        
        
    }
    
//    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
//
//            let query: CollisionCastQueryType = .nearest
//            let mask: CollisionGroup = .default
//
//            let camera = arView.session.currentFrame?.camera
//            let x = (camera?.transform.columns.3.x)!
//            let y = (camera?.transform.columns.3.y)!
//            let z = (camera?.transform.columns.3.z)!
//
//            let transform: SIMD3<Float> = [x, y, z]
//
//            let raycasts: [CollisionCastHit] = arView.scene.raycast(
//                                                               from: transform,
//                                                                 to: [0, 0, 0],
//                                                              query: query,
//                                                               mask: mask,
//                                                         relativeTo: nil)
//
//            guard let raycast: CollisionCastHit = raycasts.first
//            else { return }
//
//            print(raycast.distance)     // Distance from the ray origin to the hit
//            print(raycast.entity.name)  // The entity that was hit
//            print(raycast.position)     // The position of the hit
//        }
    
}
