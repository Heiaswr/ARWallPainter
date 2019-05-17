//
//  ViewController.swift
//  ARckathon001
//
//  Created by student5307 on 16/05/2019.
//  Copyright © 2019 student5307. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    
    @IBOutlet weak var textureButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var myCustomizeView: UIView!
    @IBOutlet weak var myButton: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    var grids = [Grid]()
    var numberOfTaps = 0
    var startPoint: SCNVector3!
    var endPoint: SCNVector3!
    var form = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        
        //Enable feature points
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        
        
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        
        // Add Gesture recognizer
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(gestureRecognizer)
        sceneView.debugOptions = .showWorldOrigin
    }
    
    
    func setupData(){
        myButton.setImage(UIImage(named: "plus-sign"), for: .normal)
        redButton.setTitle("Red", for: .normal)
        blueButton.setTitle("Blue", for: .normal)
        greenButton.setTitle("Green", for: .normal)
        textureButton.setTitle("Texture", for: .normal)
        
        myCustomizeView.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        // Turn on vertical plane detection
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical else { return }
        let grid = Grid(anchor: planeAnchor)
        self.grids.append(grid)
        node.addChildNode(grid)
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical else { return }
        let grid = self.grids.filter { grid in
            return grid.anchor.identifier == planeAnchor.identifier
            }.first
        
        guard let foundGrid = grid else {
            return
        }
        
        foundGrid.update(anchor: planeAnchor)
        
    }
    
    @objc func tapped(gesture: UITapGestureRecognizer) {
        numberOfTaps += 1
        // Get 2D position of touch event on screen
        let touchPosition = gesture.location(in: sceneView)
        
        // Translate those 2D points to 3D points using hitTest (existing plane)
        let hitTestResults = sceneView.hitTest(touchPosition, types: .existingPlane)
        
        // If first tap, add red marker. If second tap, add green marker and reset to 0
        
        
        guard let hitTest = hitTestResults.first else {
            
            return
        }
        
        if numberOfTaps == 1 {
            startPoint = SCNVector3(hitTest.worldTransform.columns.3.x, hitTest.worldTransform.columns.3.y, hitTest.worldTransform.columns.3.z)
            
        }
        else {
            // After 2nd tap, reset taps to 0
            numberOfTaps = 0
            endPoint = SCNVector3(hitTest.worldTransform.columns.3.x, hitTest.worldTransform.columns.3.y, hitTest.worldTransform.columns.3.z)
            
            addLineBetween(start: startPoint, end: endPoint)
            
            
            
        }
    }
    
    
    
    
    
    func addLineBetween(start: SCNVector3, end: SCNVector3) {
        let lineGeometry = SCNGeometry.quad(vector: start, toVector: end)
        
        let lineNode = SCNNode(geometry: lineGeometry)
        
        for scene in sceneView.scene.rootNode.childNodes{
            scene.removeFromParentNode()
        }
        
        
        sceneView.scene.rootNode.addChildNode(lineNode)
        
        form = lineNode
    }
    
    func rotateImage(image:UIImage) -> UIImage
    {
        UIGraphicsBeginImageContext(image.size)
        image.draw(at: .zero)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? image
    }
    
    
    @IBAction func modifyTexture(_ sender: Any) {
        
        
        if (myCustomizeView.isHidden){
            myCustomizeView.isHidden = false
            myButton.setImage(UIImage(named: "minus-symbol"), for: .normal)
            
        }
        else {
            myCustomizeView.isHidden = true
            myButton.setImage(UIImage(named: "plus-sign"), for: .normal)
        }
        
        //form.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        
        
    }
    
    @IBAction func redAction(_ sender: Any) {
        form.geometry?.firstMaterial?.diffuse.contents = UIColor.red
    }
    
    @IBAction func blueAction(_ sender: Any) {
        form.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
    }
    
    @IBAction func greenAction(_ sender: Any) {
        form.geometry?.firstMaterial?.diffuse.contents = UIColor.green
    }
    
    @IBAction func textureAction(_ sender: Any) {
        let myImage = UIImage(named: "zeldaPoster")
        var myImageView = UIImageView(image: myImage)
        
        if let img = myImage{
            myImageView.image = rotateImage(image: img)
            print("If let")
        }
        myImageView.frame.size = CGSize(width: form.frame.size.width, height: form.frame.size.height)
        
        let translation = SCNMatrix4MakeTranslation(0, -1, 0)
        let rotation = SCNMatrix4MakeRotation(Float.pi / 2, 0, 0, 1)
        let transform = SCNMatrix4Mult(translation, rotation)
      
        
        form.geometry?.firstMaterial?.diffuse.contentsTransform = transform
        
        form.geometry?.firstMaterial?.diffuse.contents = myImageView.image
        
        
       
        

        
        
        print("STOP")
    }
    
    
}


extension SCNGeometry {
    class func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        return SCNGeometry(sources: [source], elements: [element])
    }
    
    
    
    class func quad(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        
        
        /*
         let verticesPosition = [
         SCNVector3(x: -0.242548823, y: -0.188490361, z: -0.0887458622),
         SCNVector3(x: -0.129298389, y: -0.188490361, z: -0.0820985138),
         SCNVector3(x: -0.129298389, y: 0.2, z: -0.0820985138),
         SCNVector3(x: -0.242548823, y: 0.2, z: -0.0887458622)
         ]
         */
        let verticesPosition = [vector1, SCNVector3(x: vector1.x, y: vector2.y, z: vector1.z), vector2, SCNVector3(x: vector2.x, y: vector1.y, z: vector2.z)]
        let verticesPosition2 = [vector1, vector2, SCNVector3(x: vector1.x, y: vector2.y, z: vector1.z)
            , SCNVector3(x: vector2.x, y: vector1.y, z: vector2.z)]
        print(verticesPosition)
        
        let textureCord = [
            CGPoint(x: 1, y: 1),
            CGPoint(x: 0, y: 1),
            CGPoint(x: 0, y: 0),
            CGPoint(x: 1, y: 0),
        ]
        
        let indices: [CInt] = [
            0, 2, 3,
            0, 1, 2
        ]
        var vertexSource = SCNGeometrySource()
        if (vector1.y>vector2.y && vector1.x<vector2.x || vector1.y<vector2.y && vector1.x>vector2.x){
            vertexSource = SCNGeometrySource(vertices: verticesPosition)
        }
        else {
            vertexSource = SCNGeometrySource(vertices: verticesPosition)
        }
        let srcTex = SCNGeometrySource(textureCoordinates: textureCord)
        let date = NSData(bytes: indices, length: MemoryLayout<CInt>.size * indices.count)
        
        let scngeometry = SCNGeometryElement(data: date as Data,
                                             primitiveType: SCNGeometryPrimitiveType.triangles, primitiveCount: 2,
                                             bytesPerIndex: MemoryLayout<CInt>.size)
        
        let geometry = SCNPlane(sources: [vertexSource,srcTex],
                                elements: [scngeometry])
        
        
        return geometry
        
        
    }
    
}

extension SCNVector3 {
    static func distanceFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> Float {
        let x0 = vector1.x
        let x1 = vector2.x
        let y0 = vector1.y
        let y1 = vector2.y
        let z0 = vector1.z
        let z1 = vector2.z
        
        return sqrtf(powf(x1-x0, 2) + powf(y1-y0, 2) + powf(z1-z0, 2))
    }
}

extension Float {
    func metersToInches() -> Float {
        return self * 39.3701
    }
}

