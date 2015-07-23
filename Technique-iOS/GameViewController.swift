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

    @IBOutlet weak var scnView: SCNView!
    @IBOutlet weak var segControl: UISegmentedControl!
    private let cameraSphere = SCNNode()
    private let cameraNode1 : SCNNode = SCNNode()
    private let cameraNode2 : SCNNode = SCNNode()
    private var techniques : [String : SCNTechnique] = [:]
    private var cube : SCNNode = SCNNode()
    private var lightNode = SCNNode()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let scene = SCNScene()
        segControl.removeAllSegments()
        
        //-------------------------------------------
        // MARK: Cameras
        //-------------------------------------------
        //We use a fake camera attached to a sphere for circular movement around the object
        let fakeCameraNode = SCNNode()
        fakeCameraNode.name = "cam0"
        fakeCameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        cameraSphere.addChildNode(fakeCameraNode)
        scene.rootNode.addChildNode(cameraSphere)
        
        let targetNode = SCNNode()
        targetNode.position = SCNVector3Make(0.0,0.0,0.0)
        scene.rootNode.addChildNode(targetNode)
        
        //Camera above the water
        cameraNode1.camera = SCNCamera()
        cameraNode1.name = "cam1"
      
        //Camera under the water
        cameraNode2.camera = SCNCamera()
        cameraNode2.name = "cam2"
       
        cameraNode1.constraints = [SCNLookAtConstraint(target: targetNode)]
        cameraNode2.constraints = [SCNLookAtConstraint(target: targetNode)]
        
        cameraNode1.position = cameraSphere.convertPosition(fakeCameraNode.position, toNode: nil)
        cameraNode2.position = cameraNode1.position
        cameraNode2.position.y = -cameraNode2.position.y
        
        scene.rootNode.addChildNode(cameraNode1)
        scene.rootNode.addChildNode(cameraNode2)
        
        //Adjustments
        cameraSphere.eulerAngles.x = -0.1
        cameraNode1.position = cameraSphere.convertPosition(fakeCameraNode.position, toNode: nil)
        cameraNode2.position = cameraNode1.position
        cameraNode2.position.y = -cameraNode2.position.y
        
        
        //-------------------------------------------
        // MARK: Lights
        //-------------------------------------------
        // create and add a light to the scene
        
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
        
        
        //-------------------------------------------
        // MARK: Nodes
        //-------------------------------------------
        // Ship
        // retrieve the ship node
        let scene2 = SCNScene(named: "art.scnassets/ship.dae")!
        let ship = scene2.rootNode.childNodeWithName("ship", recursively: true)!
        ship.position.y += 1.5
        ship.scale = SCNVector3(x: 0.8, y: 0.8, z: 0.8)
        ship.name = "ship"
        scene.rootNode.addChildNode(ship)
        // animate the 3d object
        ship.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 10)))
        
        //Skybox (for reflection case)
        cube = generateReversedBox(true)
        cube.position = SCNVector3Make(0.0, 0.0, 0.0)
        cube.name = "Cube"
        cube.categoryBitMask = 0b100 //3
        cube.scale = SCNVector3(x: 40.0, y: 40.0, z: 40.0)
        //Material
        let mat = SCNMaterial()
        mat.diffuse.contents = "art.scnassets/skymap.png"
        cube.geometry?.materials = [mat]
        cube.hidden = true
        scene.rootNode.addChildNode(cube)
        
        //Floor
        let floor = SCNNode(geometry: SCNPlane(width: 80.0, height: 80.0))
        floor.eulerAngles.x = -3.14159*0.5
        let material2 = SCNMaterial()
        material2.doubleSided = !true
        material2.diffuse.contents = UIImage(named: "art.scnassets/grid_texture")
        floor.geometry?.materials = [material2]
        floor.categoryBitMask = 0b10 //2
        scene.rootNode.addChildNode(floor)
        floor.position = SCNVector3Make(0.0, 0.0, 0.0)

        
        
        //-------------------------------------------
        //MARK: View
        //-------------------------------------------
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        //scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        scnView.pointOfView = cameraNode1
        scene.background.contents = ["art.scnassets/3.png","art.scnassets/art.scnassets/1.png","art.scnassets/5.png","art.scnassets/6.png","art.scnassets/2.png","art.scnassets/4.png"]
        // configure the view
        scnView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1.0)
        let cube1 = SCNNode(geometry: SCNBox(width: 0.5, height: 1.0, length: 0.5, chamferRadius: 0.0))
        scene.rootNode.addChildNode(cube1)
        cube1.position = SCNVector3(x: 0.0, y: 0.5, z: 0.0)
        let sphere1 = SCNNode(geometry: SCNSphere(radius: 0.5))
        sphere1.position = SCNVector3(x: 0.0, y: 0.5, z: 0.5)
        scene.rootNode.addChildNode(sphere1)
        
        //-------------------------------------------
        // MARK: Techniques
        //-------------------------------------------
        //Load techniques
        
        
        segControl.insertSegmentWithTitle("None", atIndex: 0, animated: false)
        //Sobel filter
        if let path = NSBundle.mainBundle().pathForResource("sobel_technique", ofType: "plist") {
            if let dico1 = NSDictionary(contentsOfFile: path)  {
                let dico = dico1 as! [String : AnyObject]
                println(dico)
                let technique = SCNTechnique(dictionary:dico)
                //Need the screen size
                technique?.setValue(NSValue(CGSize: CGSizeApplyAffineTransform(self.view.frame.size, CGAffineTransformMakeScale(2.0, 2.0))), forKeyPath: "size_screen")
                techniques["Sobel"] = technique
                segControl.insertSegmentWithTitle("Sobel", atIndex: segControl.numberOfSegments, animated: false)
            }
        }
        
        //Mirror
        if let path = NSBundle.mainBundle().pathForResource("mirror_technique", ofType: "plist") {
            if let dico1 = NSDictionary(contentsOfFile: path)  {
                let dico = dico1 as! [String : AnyObject]
                println(dico)
                let technique = SCNTechnique(dictionary:dico)
                //Need the screen size
                technique?.setValue(NSValue(CGSize: CGSizeApplyAffineTransform(self.view.frame.size, CGAffineTransformMakeScale(2.0, 2.0))), forKeyPath: "size_screen")
                techniques["Mirror"] = technique
                segControl.insertSegmentWithTitle("Mirror", atIndex: segControl.numberOfSegments, animated: false)
            }
        }
        
        //SSAO
        if let path = NSBundle.mainBundle().pathForResource("ssao_technique", ofType: "plist") {
            if let dico1 = NSDictionary(contentsOfFile: path)  {
                let dico = dico1 as! [String : AnyObject]
                println(dico)
                let technique = SCNTechnique(dictionary:dico)
                //Need the screen size
                technique?.setValue(NSValue(CGSize: CGSizeApplyAffineTransform(self.view.frame.size, CGAffineTransformMakeScale(2.0, 2.0))), forKeyPath: "size_screen")
                techniques["SSAO"] = technique
                segControl.insertSegmentWithTitle("SSAO", atIndex: segControl.numberOfSegments, animated: false)
            }
        }
        
        //Drops
        if let path = NSBundle.mainBundle().pathForResource("drops_technique", ofType: "plist") {
            if let dico1 = NSDictionary(contentsOfFile: path)  {
                let dico = dico1 as! [String : AnyObject]
                println(dico)
                let technique = SCNTechnique(dictionary:dico)
                //Need the screen size
                technique?.setValue(NSValue(CGSize: CGSizeApplyAffineTransform(self.view.frame.size, CGAffineTransformMakeScale(2.0, 2.0))), forKeyPath: "size_screen")
                techniques["Drops"] = technique
                segControl.insertSegmentWithTitle("Drops", atIndex: segControl.numberOfSegments, animated: false)
            }
        }
        
        segControl.selectedSegmentIndex = 0
        
        //-------------------------------------------
        // MARK: Gestures
        //-------------------------------------------
        let gesture = UIPanGestureRecognizer(target: self, action: "panDetected:");
        scnView.addGestureRecognizer(gesture);
        let gesture2 = UIPinchGestureRecognizer(target: self, action: "pinchDetected:")
        scnView.addGestureRecognizer(gesture2)
        
       
    }
    
    //-------GESTURES AND CAMERA MOVES--------
    
    @IBAction func selectedTechnique(sender: UISegmentedControl) {
        let name = sender.titleForSegmentAtIndex(sender.selectedSegmentIndex)!
        switch name{
        case "Mirror","SSAO","Sobel","Drops":
            scnView.technique = techniques[name]
            cube.hidden = name != "Mirror"
           // lightNode.hidden = name == "SSAO"
        default:
            cube.hidden = true
            //lightNode.hidden = false
            scnView.technique = nil
        }
    }
    
    var previousScreenPoint = CGPoint(x: 0,y: 0)
    var previousPosition = SCNVector3(x: 0,y: 0,z: 0)
    
    func panDetected(gesture:UIPanGestureRecognizer){
        let camera : SCNNode = cameraSphere.childNodeWithName("cam0", recursively: true)!
        let point = gesture.translationInView(scnView)
        
        if(gesture.state == .Began){
            previousPosition =  camera.position
            previousScreenPoint = point
        }
        
        cameraSphere.eulerAngles.y -= Float(point.x-previousScreenPoint.x)/180.0 * 3.14159 * 0.4
        
        let newAngleX = cameraSphere.eulerAngles.x-Float(point.y-previousScreenPoint.y)/180.0 * 3.14159 * 0.4
        cameraSphere.eulerAngles.x = clamp(newAngleX,mini: -1.33,maxi: 1.33)
        
        previousScreenPoint = point
        previousPosition = camera.position
        cameraNode1.position = cameraSphere.convertPosition(camera.position, toNode: nil)
        cameraNode2.position = cameraNode1.position
        cameraNode2.position.y = -cameraNode2.position.y
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
        }
        
        //UNUSED, not working
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
