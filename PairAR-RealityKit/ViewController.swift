//
//  ViewController.swift
//  PairAR-RealityKit
//
//  Created by sun on 2/4/2563 BE.
//  Copyright © 2563 sun. All rights reserved.
//

import UIKit
import RealityKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // to use AnchorEntity(plane: ,minimunBounds: ) please select device to iphone real device, or generic device
        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.2, 0.2]) // 20 * 20 cm
        
        arView.scene.addAnchor(anchor)
        
        var cards: [Entity] = []
        for _ in 1...4 {
            //create box
            let box = MeshResource.generateBox(width: 0.04, height: 0.002, depth: 0.04)
            //create material
            let metalMaterial = SimpleMaterial(color: .gray, isMetallic: true)
            
            let model = ModelEntity(mesh: box, materials: [metalMaterial])
            //generateCollisionShapes to can touch model
            model.generateCollisionShapes(recursive: true)
            
            //add modelEntity to cards array
            cards.append(model)
        }
        
        for (index, card) in cards.enumerated() {
            let x = Float(index % 2)
            let z = Float(index % 2)
            
            card.position = [x * 0.1, 0, z * 0.1]
            // add card
            anchor.addChild(card)
        }
        
    }
}
