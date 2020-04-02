//
//  ViewController.swift
//  PairAR-RealityKit
//
//  Created by sun on 2/4/2563 BE.
//  Copyright © 2563 sun. All rights reserved.
//

import UIKit
import RealityKit
import Combine

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // to use AnchorEntity(plane: ,minimunBounds: ) please select device to iphone real device, or generic device
        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.2, 0.2]) // 20 * 20 cm
        
        arView.scene.addAnchor(anchor)
        
        var cards: [Entity] = []
        for _ in 1...16 {
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
            let x = Float(index % 4)
            let z = Float(index / 4)
            
            card.position = [x * 0.1, 0, z * 0.1]
            // add card
            anchor.addChild(card)
        }
        
        // box hide object usdz when card flipdown
        let boxSize: Float = 0.7
        let occlusionBoxMesh = MeshResource.generateBox(size: boxSize)
        
        let occlusionBox = ModelEntity(mesh: occlusionBoxMesh, materials: [OcclusionMaterial()])
        
        occlusionBox.position.y = -boxSize/2
        anchor.addChild(occlusionBox)
        
        //add usdz model to card
        var cancellable: AnyCancellable? = nil
        cancellable = ModelEntity.loadModelAsync(named: "01")
            .append(ModelEntity.loadModelAsync(named: "02"))
            .append(ModelEntity.loadModelAsync(named: "03"))
            .append(ModelEntity.loadModelAsync(named: "04"))
            .append(ModelEntity.loadModelAsync(named: "05"))
            .append(ModelEntity.loadModelAsync(named: "06"))
            .append(ModelEntity.loadModelAsync(named: "07"))
            .append(ModelEntity.loadModelAsync(named: "08"))
        .collect()
        .sink(receiveCompletion: { error in
            
            print("Error: \(error)")
            cancellable?.cancel()
            
        }, receiveValue: { entities in
            
            var objects: [ModelEntity] = []
            for entity in entities {
                
                entity.setScale(SIMD3<Float>(0.002, 0.002, 0.002), relativeTo: anchor)
                entity.generateCollisionShapes(recursive: true)
                for _ in 1...2 {
                    objects.append(entity.clone(recursive: true))
                }
                
            }
            objects.shuffle()
            for (index, object) in objects.enumerated() {
                cards[index].addChild(object)
                cards[index].transform.rotation = simd_quatf(angle: .pi, axis: [1, 0, 0])
            }
            
            cancellable?.cancel()
            
        })
        
    }
    
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: arView)
        //if tap at card position
        if let card = arView.entity(at: tapLocation) {
            if card.transform.rotation.angle == .pi {
                var flipDownTransform = card.transform
                flipDownTransform.rotation = simd_quatf(angle: 0, axis: [1, 0, 0])
                
                card.move(to: flipDownTransform, relativeTo: card.parent, duration: 0.25, timingFunction: .easeInOut)
            } else {
                var flipUpTransform = card.transform
                flipUpTransform.rotation = simd_quatf(angle: .pi, axis: [1, 0, 0])
                
                card.move(to: flipUpTransform, relativeTo: card.parent, duration: 0.25, timingFunction: .easeInOut)
            }
        }
        
    }
}
