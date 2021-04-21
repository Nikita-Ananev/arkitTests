//
//  ViewController.swift
//  CheckDistance
//
//  Created by Никита Ананьев on 18.04.2021.
//

import UIKit
import RealityKit
import ARKit

struct Coord {
    let id: UInt64
    
    var x:Float
    var y:Float
    var z:Float
}

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    @IBOutlet weak var label: UILabel!
    var isSceneClear = true
    var coordArray: [Coord] = []
    var tapLocation = CGPoint()
    
    
    override func viewDidLoad() { 
        super.viewDidLoad()
        var points = createAroundSphere(numberOfPoints: 100)

        
        for point in points {
            let sphere = MeshResource.generateSphere(radius: 0.02)
            let material = SimpleMaterial(color: .cyan, roughness: 0, isMetallic: true)
            let entity = ModelEntity(mesh: sphere, materials: [material])
            let anchor = AnchorEntity(world: [point.x, point.y, point.z])
            coordArray.append(Coord(id: entity.id, x: point.x, y: point.y, z: point.z))
            anchor.addChild(entity)
            arView.scene.anchors.append(anchor)
            entity.generateCollisionShapes(recursive: true)
            
        }
        
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
        
        coordArray.append(Coord(id: entity.id,
                                x: x,
                                y: y,
                                z: z))
        anchor.addChild(entity)
        arView.scene.anchors.append(anchor)
        entity.generateCollisionShapes(recursive: true)
        arView.installGestures([.all], for: entity)
        
        searchClosestAnchor()
        isSceneClear = false
        
    }

    @IBAction func clearSceneButtonPressed(_ sender: UIButton) {
        arView.scene.anchors.removeAll()
        isSceneClear = true
    }
    
    func searchClosestAnchor() {
        DispatchQueue.global().async { [self] in

            while isSceneClear == false {
                    let anchors = arView.scene.anchors
                    print("\(anchors.count) adasdasdas")
                
                DispatchQueue.main.async {
                    tapLocation = self.arView.center
                }
                    if let entityClosest = arView.entity(at: tapLocation) {
                        guard let camera = arView.session.currentFrame?.camera else { continue }
                                        
                        
                        let xCam = (camera.transform.columns.3.x)
                        let yCam = (camera.transform.columns.3.y)
                        let zCam = (camera.transform.columns.3.z)
                        
                      //  calculateDistanceToEntity(entity: tapEntity)
                        
                        for coord in coordArray  {
                            if coord.id == entityClosest.id {
                                let distance = sqrt(pow((coord.x - xCam), 2)  + pow((coord.y - yCam), 2) + pow((coord.z - zCam), 2))
                                DispatchQueue.main.async {
                                    label.text = String(format: "%.2f", distance)
                                }
                            }
                        }
 
                    } else {
                        DispatchQueue.main.async {
                            label.text = "Не вижу фигуру"
                        }
                        
                    }
                sleep(1)

                    
                }
            }
    }
    
    
    func createAroundSphere(numberOfPoints: Int) -> [SIMD3<Float>] {
        let dlong = Double.pi * (3.0 - sqrt(5.0))
        let dz = 2.0 / Double(numberOfPoints)
        var long = 0.0
        var z = 1.0 - dz / 2.0
        var points: [SIMD3<Float>] = []
        for _ in 0...numberOfPoints - 1 {
            let r = sqrt(1.0 - z * z)
            let pointX = cos(long) * r
            let pointY = sin(long) * r
            points.append([Float(pointX), Float(pointY), Float(z)])

            z = z - dz
            long = long + dlong
        }
        return points
    }
        
    }

//def GetPointsEquiAngularlyDistancedOnSphere(numberOfPoints=45):
//    """ each point you get will be of form 'x, y, z'; in cartesian coordinates
//        eg. the 'l2 distance' from the origion [0., 0., 0.] for each point will be 1.0
//        ------------
//        converted from:  http://web.archive.org/web/20120421191837/http://www.cgafaq.info/wiki/Evenly_distributed_points_on_sphere )
//    """
//    dlong = pi*(3.0-sqrt(5.0))  # ~2.39996323
//    dz   =  2.0/numberOfPoints
//    long =  0.0
//    z    =  1.0 - dz/2.0
//    ptsOnSphere =[]
//    for k in range( 0, numberOfPoints):
//        r    = sqrt(1.0-z*z)
//        ptNew = (cos(long)*r, sin(long)*r, z)
//        ptsOnSphere.append( ptNew )
//        z    = z - dz
//        long = long + dlong
//    return ptsOnSphere
    
  
    
