//
//  GameViewController.swift
//  Technique-iOS
//
//  Created by Simon Rodriguez on 17/07/2015.
//  Copyright (c) 2015 Simon Rodriguez. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit

class GameViewController: UIViewController {

     let cameraSphere = SCNNode()
    let cameraNode1 : SCNNode = SCNNode()
     let cameraNode2 : SCNNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        //
        
        let scnView = self.view as! SCNView
        
        if let path = NSBundle.mainBundle().pathForResource("Technique", ofType: "plist") {
            if let dico1 = NSDictionary(contentsOfFile: path)  {
                let dico = dico1 as! [String : AnyObject]
                println(dico)
                let technique = SCNTechnique(dictionary:dico)
                
                technique?.setValue(NSValue(CGSize: CGSizeApplyAffineTransform(self.view.frame.size, CGAffineTransformMakeScale(2.0, 2.0))), forKeyPath: "size_screen")
                scnView.technique = technique
            }
        }
        
        let scene = SCNScene()
        let back = UIImage(named: "art.scnassets/grid_texture.png")

       // scene.background.contents = back      // create and add a camera to the scene
      
        let fakeCameraNode = SCNNode()
        fakeCameraNode.name = "cam0"
        fakeCameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        cameraSphere.addChildNode(fakeCameraNode)
        scene.rootNode.addChildNode(cameraSphere)
        
        let targetNode = SCNNode()
        targetNode.position = SCNVector3Make(0.0,0.0,0.0)
        scene.rootNode.addChildNode(targetNode)
        
        cameraNode1.camera = SCNCamera()
        cameraNode1.name = "cam1"
      
    
        cameraNode2.camera = SCNCamera()
        cameraNode2.name = "cam2"
       
       
        cameraNode1.constraints = [SCNLookAtConstraint(target: targetNode)]
        cameraNode2.constraints = [SCNLookAtConstraint(target: targetNode)]
        
        
        cameraNode1.position = cameraSphere.convertPosition(fakeCameraNode.position, toNode: nil)
        cameraNode2.position = cameraNode1.position
        
        cameraNode2.position.y = -cameraNode2.position.y
        scene.rootNode.addChildNode(cameraNode1)
        scene.rootNode.addChildNode(cameraNode2)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
    
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
        
        let scene2 = SCNScene(named: "art.scnassets/ship.dae")!
        let ship = scene2.rootNode.childNodeWithName("ship", recursively: true)!
        ship.position.y += 1.5
        ship.scale = SCNVector3(x: 0.8, y: 0.8, z: 0.8)
        scene.rootNode.addChildNode(ship)
        // animate the 3d object
        ship.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 10)))
        
        //let cube = SCNNode(geometry: SCNBox(width: 80.0, height: 80.0, length: 80.0, chamferRadius: 0.0))
        let cube = generateReversedBox(true)
        cube.position = SCNVector3Make(0.0, 0.0, 0.0)
        cube.name = "Cube"
        cube.categoryBitMask = 0b100
        cube.scale = SCNVector3(x: 40.0, y: 40.0, z: 40.0)
       
                let mat = SCNMaterial()
        //mat.emission.contents = "art.scnassets/skymap.png"
        //mat.emission.intensity = 0.1
       mat.diffuse.contents = "art.scnassets/skymap.png"
        
        cube.geometry?.materials = [mat]
        scene.rootNode.addChildNode(cube)
        
        let floor = SCNNode(geometry: SCNPlane(width: 80.0, height: 80.0))
        floor.eulerAngles.x = -3.14159*0.5
        let material2 = SCNMaterial()
       
       // material2.diffuse.contents = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
       // let im_grid = UIImage(named: "art.scnassets/grid_texture.png")
        //material2.diffuse.contents = im_grid
        //material2.normal.contents =  SKTexture(image: im_grid!).textureByGeneratingNormalMap()
        //
        material2.doubleSided = true
        floor.geometry?.materials = [material2]
        floor.categoryBitMask = 0b10
        scene.rootNode.addChildNode(floor)
        
        floor.position = SCNVector3Make(0.0, 0.0, 0.0)
        // retrieve the SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        //scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        scnView.pointOfView = cameraNode1
        // configure the view
        //scnView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1.0)
        
       
        
        let gesture = UIPanGestureRecognizer(target: self, action: "panDetected:");
        scnView.addGestureRecognizer(gesture);
        let gesture2 = UIPinchGestureRecognizer(target: self, action: "pinchDetected:")
        scnView.addGestureRecognizer(gesture2)
        
        cameraSphere.eulerAngles.x = -0.1
        cameraNode1.position = cameraSphere.convertPosition(fakeCameraNode.position, toNode: nil)
        cameraNode2.position = cameraNode1.position
        cameraNode2.position.y = -cameraNode2.position.y

       
    }
    
    //-------GESTURES AND CAMERA MOVES--------
    
    var previousScreenPoint = CGPoint(x: 0,y: 0)
    var previousPosition = SCNVector3(x: 0,y: 0,z: 0)
    
    func panDetected(gesture:UIPanGestureRecognizer){
        let scnView = self.view as! SCNView
        let camera : SCNNode = cameraSphere.childNodeWithName("cam0", recursively: true)!
        let point = gesture.translationInView(scnView)
        
        if(gesture.state == .Began){
            previousPosition =  camera.position
            previousScreenPoint = point
        }
        
        cameraSphere.eulerAngles.y -= Float(point.x-previousScreenPoint.x)/180.0 * 3.14159 * 0.4
        
        let newAngleX = cameraSphere.eulerAngles.x-Float(point.y-previousScreenPoint.y)/180.0 * 3.14159 * 0.4
        cameraSphere.eulerAngles.x = clamp(newAngleX,mini: -1.33,maxi: 0.1)
        
        previousScreenPoint = point
        previousPosition = camera.position
        cameraNode1.position = cameraSphere.convertPosition(camera.position, toNode: nil)
        cameraNode2.position = cameraNode1.position
        cameraNode2.position.y = -cameraNode2.position.y
        
        //println("Camera 1 angles: \(camera.rotation.x), \(camera.rotation.y), \(camera.rotation.z), \(camera.rotation.w)")
        //println("Camera 2 angles: \(cameraNode2.eulerAngles.x), \(cameraNode2.eulerAngles.y), \(cameraNode2.eulerAngles.z)")
        
    }
    
    let kZoomMin : Float = 2.0
    let kZoomMax : Float = 35.0
    let kMaxFactor : Float = 1.15
    
    func pinchDetected(gesture:UIPinchGestureRecognizer){
        let camera: SCNNode = cameraSphere.childNodes.first as! SCNNode
        if(gesture.state == .Began){
            previousPosition =  camera.position
        }
        
        let scaling = Float(gesture.scale) == 0 ? 1.0 : Float(gesture.scale)
        
        let newPosition = previousPosition / scaling
        camera.position = newPosition.normalized() * clamp(newPosition.length(),mini: kZoomMin / kMaxFactor,maxi: kZoomMax * kMaxFactor)
        
        
        
        
        if ( (newPosition.length() > kZoomMax || newPosition.length() < kZoomMin) && gesture.state == UIGestureRecognizerState.Ended){
            //move, then zoom in
            SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(0.2)
            SCNTransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault))
            camera.position = newPosition.normalized() * clamp(newPosition.length(),mini: kZoomMin,maxi: kZoomMax)
            SCNTransaction.commit()
            
        }
        
        cameraNode1.position = cameraSphere.convertPosition(camera.position, toNode: nil)
        cameraNode2.position = cameraNode1.position
        cameraNode2.position.y = -cameraNode2.position.y
        
    }
    //-------UTILITIES--------
    func generateReversedBox(blender : Bool) -> SCNNode{
        if (blender) {
            let scene3 = SCNScene(named: "art.scnassets/cube.dae")!
            let cube1 = scene3.rootNode.childNodeWithName("Cube", recursively: true)!
            
            return cube1
            //return cube1
           /* let cube_geom = cube1.geometry!
            
            
            let chab = cube_geom.geometrySourcesForSemantic(SCNGeometrySourceSemanticVertex)
            var vec = chab!.first as! SCNGeometrySource
            
            let chab2 = cube_geom.geometrySourcesForSemantic(SCNGeometrySourceSemanticNormal)
            var nor = chab2!.first as! SCNGeometrySource
            
            let chab3 = cube_geom.geometrySourcesForSemantic(SCNGeometrySourceSemanticTexcoord)
            var tex = chab3!.first as! SCNGeometrySource
            
            let vec1 = [0,1,2,3,4,5]
            let f1 = SCNGeometryElement(data: NSData(bytes: vec1, length: 6), primitiveType: SCNGeometryPrimitiveType.Triangles, primitiveCount: 2, bytesPerIndex: 1)
            
            let vec2 = [6,7,8,9,10,11]
            let f2 = SCNGeometryElement(data: NSData(bytes: vec2, length: 6), primitiveType: SCNGeometryPrimitiveType.Triangles, primitiveCount: 2, bytesPerIndex: 1)
            
            let vec3 = [12,13,14,15,16,17]
            let f3 = SCNGeometryElement(data: NSData(bytes: vec3, length: 6), primitiveType: SCNGeometryPrimitiveType.Triangles, primitiveCount: 2, bytesPerIndex: 1)
            
            let vec4 = [18,19,20,21,22,23]
            let f4 = SCNGeometryElement(data: NSData(bytes: vec4, length: 6), primitiveType: SCNGeometryPrimitiveType.Triangles, primitiveCount: 2, bytesPerIndex: 1)
            
            let vec5 = [24,25,26,27,28,29]
            let f5 = SCNGeometryElement(data: NSData(bytes: vec5, length: 6), primitiveType: SCNGeometryPrimitiveType.Triangles, primitiveCount: 2, bytesPerIndex: 1)
            
            let vec6 = [30,31,32,33,34,35]
            let f6 = SCNGeometryElement(data: NSData(bytes: vec6, length: 6), primitiveType: SCNGeometryPrimitiveType.Triangles, primitiveCount: 2, bytesPerIndex: 1)
            
            let geom = SCNGeometry(sources: [vec,nor,tex], elements: [f1,f2,f3,f4,f5,f6])
            
            return SCNNode(geometry: geom)*/
        }
        let cube = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        
        var el = cube.geometryElementAtIndex(0)!
        
        let chab = cube.geometrySourcesForSemantic(SCNGeometrySourceSemanticVertex)
        var vec = chab!.first as! SCNGeometrySource
        
        let chab2 = cube.geometrySourcesForSemantic(SCNGeometrySourceSemanticTexcoord)
        var tex = chab2!.first as! SCNGeometrySource
        
        var norcoords : [SCNVector3] = [
            SCNVector3(x: -0.0, y: -0.0, z: -1.0),
            SCNVector3(x: -0.0, y: -0.0, z: -1.0),
            SCNVector3(x: -0.0, y: -0.0, z: -1.0),
            SCNVector3(x: -0.0, y: -0.0, z: -1.0),
            SCNVector3(x: -1.0, y: -0.0, z: 0.0),
            SCNVector3(x: -1.0, y: -0.0, z: 0.0),
            SCNVector3(x: -1.0, y: -0.0, z: 0.0),
            SCNVector3(x: -1.0, y: -0.0, z: 0.0),
            SCNVector3(x: 0.0, y: -0.0, z: 1.0),
            SCNVector3(x: 0.0, y: -0.0, z: 1.0),
            SCNVector3(x: 0.0, y: -0.0, z: 1.0),
            SCNVector3(x: 0.0, y: -0.0, z: 1.0),
            SCNVector3(x: 1.0, y: -0.0, z: -0.0),
            SCNVector3(x: 1.0, y: -0.0, z: -0.0),
            SCNVector3(x: 1.0, y: -0.0, z: -0.0),
            SCNVector3(x: 1.0, y: -0.0, z: -0.0),
            SCNVector3(x: -0.0, y: -1.0, z: 0.0),
            SCNVector3(x: -0.0, y: -1.0, z: 0.0),
            SCNVector3(x: -0.0, y: -1.0, z: 0.0),
            SCNVector3(x: -0.0, y: -1.0, z: 0.0),
            SCNVector3(x: -0.0, y: 1.0, z: 0.0),
            SCNVector3(x: -0.0, y: 1.0, z: 0.0),
            SCNVector3(x: -0.0, y: 1.0, z: 0.0),
            SCNVector3(x: -0.0, y: 1.0, z: 0.0)
        ]
        var nor = SCNGeometrySource(data: NSData(bytes: norcoords, length:12*24), semantic: SCNGeometrySourceSemanticNormal, vectorCount: 24, floatComponents: true, componentsPerVector: 3, bytesPerComponent: 4, dataOffset: 0, dataStride: 0)
        
        
        let geom = SCNGeometry(sources: [vec,nor,tex], elements: [el])
        let cubeNode = SCNNode(geometry: geom)
        return cubeNode
        
    }
    
    func clamp<T: Comparable>(val:T, mini:T, maxi:T) -> T{
        return max(min(maxi,val),mini)
    }
    
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
