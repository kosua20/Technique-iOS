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
import OpenGLES

class GameViewController: UIViewController, SCNSceneRendererDelegate {

    @IBOutlet weak var scnView: SCNView!
    @IBOutlet weak var segControl: UISegmentedControl!
    private let cameraSphere = SCNNode()
    private let cameraNode1 : SCNNode = SCNNode()
    private let cameraNode2 : SCNNode = SCNNode()
    private var techniques : [String : SCNTechnique] = [:]
    private var cube : SCNNode = SCNNode()
    private var scene1 = SCNNode()
    private var scene2 = SCNNode()
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
        
		cameraNode1.position = cameraSphere.convertPosition(fakeCameraNode.position, to: nil)
        cameraNode2.position = cameraNode1.position
        cameraNode2.position.y = -cameraNode2.position.y
        
        scene.rootNode.addChildNode(cameraNode1)
        scene.rootNode.addChildNode(cameraNode2)
        
        //Adjustments
        cameraSphere.eulerAngles.x = -0.1
		cameraNode1.position = cameraSphere.convertPosition(fakeCameraNode.position, to: nil)
        cameraNode2.position = cameraNode1.position
        cameraNode2.position.y = -cameraNode2.position.y
        
        
        //-------------------------------------------
        // MARK: Lights
        //-------------------------------------------
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
		lightNode.light!.type = SCNLight.LightType.omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene1.addChildNode(lightNode)
    
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
		ambientLightNode.light!.type = SCNLight.LightType.ambient
		ambientLightNode.light!.color = UIColor.darkGray
        scene1.addChildNode(ambientLightNode)
        
        
        
        //-------------------------------------------
        // MARK: Nodes
        //-------------------------------------------
        
        //-------- SCENE 1 --------
        // Ship
        // retrieve the ship node
        let sceneShip = SCNScene(named: "art.scnassets/ship.dae")!
		let ship = sceneShip.rootNode.childNode(withName: "ship", recursively: true)!
        ship.position.y += 1.5
        ship.scale = SCNVector3(x: 0.8, y: 0.8, z: 0.8)
        ship.name = "ship"
        scene1.addChildNode(ship)
        // animate the 3d object
		ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 10)))
        
        //Skybox (for reflection case)
		cube = generateReversedBox(blender: true)
        cube.position = SCNVector3Make(0.0, 0.0, 0.0)
        cube.name = "Cube"
        cube.categoryBitMask = 0b100 //3
        cube.scale = SCNVector3(x: 40.0, y: 40.0, z: 40.0)
        cube.eulerAngles.y = .pi/2;
        //Material
        let mat = SCNMaterial()
        mat.diffuse.contents = "art.scnassets/skymap.png"
        cube.geometry?.materials = [mat]
		cube.isHidden = true
        scene1.addChildNode(cube)
        
        //Floor
        let floor = SCNNode(geometry: SCNPlane(width: 80.0, height: 80.0))
        floor.eulerAngles.x = -3.14159*0.5
        let material2 = SCNMaterial()
		material2.isDoubleSided = !true
        material2.diffuse.contents = UIImage(named: "art.scnassets/grid_texture")
        floor.geometry?.materials = [material2]
        floor.categoryBitMask = 0b10 //2
        floor.position = SCNVector3Make(0.0, 0.0, 0.0)
        scene1.addChildNode(floor)
        
        scene.rootNode.addChildNode(scene1)
        
        
        //-------- SCENE 2 --------
        
        let redmat = SCNMaterial()
		redmat.diffuse.contents = UIColor.red
        
        let bluemat = SCNMaterial()
		bluemat.diffuse.contents = UIColor.blue
        
        let yellmat = SCNMaterial()
		yellmat.diffuse.contents = UIColor.yellow
        
        let greenmat = SCNMaterial()
		greenmat.diffuse.contents = UIColor.green
        
        let greymat = SCNMaterial()
        greymat.diffuse.contents = UIColor(white: 0.9, alpha: 1.0)

        
        let kPlaneSize : CGFloat = 4.0
        
        let plane1 = SCNNode(geometry: SCNPlane(width: kPlaneSize, height: kPlaneSize))
        let plane2 = SCNNode(geometry: SCNPlane(width: kPlaneSize, height: kPlaneSize))
        let plane3 = SCNNode(geometry: SCNPlane(width: kPlaneSize, height: kPlaneSize))
        let plane4 = SCNNode(geometry: SCNPlane(width: kPlaneSize, height: kPlaneSize))
        let plane5 = SCNNode(geometry: SCNPlane(width: kPlaneSize, height: kPlaneSize))
       
        plane1.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        plane3.position = SCNVector3(x: 0.0, y: 4.0, z: 0.0)
        plane2.position = SCNVector3(x: -2.0, y: 2.0, z: 0.0)
        plane4.position = SCNVector3(x: 2.0, y: 2.0, z: 0.0)
        plane5.position = SCNVector3(x: 0.0, y: 2.0, z: -2.0)
        plane1.eulerAngles.x = -3.14159*0.5
        plane3.eulerAngles.x = 3.14159*0.5
        
        plane2.eulerAngles.y = 3.14159*0.5
        plane4.eulerAngles.y = -3.14159*0.5
        
        plane1.geometry?.materials = [greymat]
        plane3.geometry?.materials = [greymat]
        plane5.geometry?.materials = [greymat]
        
        plane2.geometry?.materials = [bluemat]
        plane4.geometry?.materials = [redmat]
        
        
        scene2.addChildNode(plane1)
        scene2.addChildNode(plane2)
        scene2.addChildNode(plane3)
        scene2.addChildNode(plane4)
        scene2.addChildNode(plane5)
        
        let cube1 = SCNNode(geometry: SCNBox(width: 1.2, height: 1.2, length: 1.2, chamferRadius: 0.0))
        cube1.position = SCNVector3(x: 0.8, y: 0.6, z: 1.0)
        cube1.geometry?.materials = [yellmat]
        cube1.eulerAngles.y = 3.14159 / 3.0
        scene2.addChildNode(cube1)
        
        let cube2 = SCNNode(geometry: SCNBox(width: 1.2, height: 2.2, length: 1.2, chamferRadius: 0.0))
        cube2.position = SCNVector3(x: -0.8, y: 1.1, z: -0.8)
        cube2.geometry?.materials = [greenmat]
        cube2.eulerAngles.y = -3.14159 / 5.0
        scene2.addChildNode(cube2)
        
        
        
        
        let sphere1 = SCNNode(geometry: SCNSphere(radius: 0.8))
        sphere1.position = SCNVector3(x: -0.8, y: 0.7, z: 1.0)
        scene2.addChildNode(sphere1)
        
        
       
        
        let ambientLightNode2 = SCNNode()
        ambientLightNode2.light = SCNLight()
		ambientLightNode2.light!.type = SCNLight.LightType.ambient
		ambientLightNode2.light!.color = UIColor.darkGray
        scene2.addChildNode(ambientLightNode2)
        
        
        let omniLightNode2 = SCNNode()
        omniLightNode2.light = SCNLight()
		omniLightNode2.light!.type = SCNLight.LightType.omni
        omniLightNode2.position = SCNVector3(x: 1.0, y: 3.0, z: 3.0)
        //scene2.addChildNode(omniLightNode2)
        
        
     
        
        
        
		scene2.isHidden = false
		scene1.isHidden = true
        scene.rootNode.addChildNode(scene2)
        //-------------------------------------------
        //MARK: View
        //-------------------------------------------
        // set the scene to the view
        scnView.scene = scene
        scnView.delegate = self
        // allows the user to manipulate the camera
        //scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        scnView.pointOfView = cameraNode1
        //scene.background.contents = UIColor.whiteColor()
        scene.background.contents = ["art.scnassets/3.png","art.scnassets/1.png","art.scnassets/5.png","art.scnassets/6.png","art.scnassets/2.png","art.scnassets/4.png"]
        // configure the view
		scnView.backgroundColor = UIColor.white
        
        
        
        
        //-------------------------------------------
        // MARK: Techniques
        //-------------------------------------------
        //Load techniques
        
		segControl.insertSegment(withTitle: "None", at: 0, animated: false)
        
        //Drops
		if let path = Bundle.main.path(forResource: "drops_technique", ofType: "plist") {
            if let dico1 = NSDictionary(contentsOfFile: path)  {
                let dico = dico1 as! [String : AnyObject]
                //println(dico)
                let technique = SCNTechnique(dictionary:dico)
                //Need the screen size
				technique?.setValue(NSValue(cgSize: self.view.frame.size.applying(CGAffineTransform(scaleX: 2.0, y: 2.0))), forKeyPath: "size_screen")
                techniques["Drops"] = technique
				segControl.insertSegment(withTitle: "Drops", at: segControl.numberOfSegments, animated: false)
            }
        }
        
        //Sobel filter
		if let path = Bundle.main.path(forResource: "sobel_technique", ofType: "plist") {
            if let dico1 = NSDictionary(contentsOfFile: path)  {
                let dico = dico1 as! [String : AnyObject]
                //println(dico)
                let technique = SCNTechnique(dictionary:dico)
                //Need the screen size
				technique?.setValue(NSValue(cgSize: self.view.frame.size.applying(CGAffineTransform(scaleX: 2.0, y: 2.0))), forKeyPath: "size_screen")
                techniques["Sobel"] = technique
				segControl.insertSegment(withTitle: "Sobel", at: segControl.numberOfSegments, animated: false)
            }
        }
        
        //Mirror
		if let path = Bundle.main.path(forResource: "mirror_technique", ofType: "plist") {
            if let dico1 = NSDictionary(contentsOfFile: path)  {
                let dico = dico1 as! [String : AnyObject]
                //println(dico)
                let technique = SCNTechnique(dictionary:dico)
                //Need the screen size
				technique?.setValue(NSValue(cgSize: self.view.frame.size.applying(CGAffineTransform(scaleX: 2.0, y: 2.0))), forKeyPath: "size_screen")
                techniques["Mirror"] = technique
				segControl.insertSegment(withTitle: "Mirror", at: segControl.numberOfSegments, animated: false)
            }
        }
        
        //SSAO
		if let path = Bundle.main.path(forResource: "ssao_technique", ofType: "plist") {
            if let dico1 = NSDictionary(contentsOfFile: path)  {
                let dico = dico1 as! [String : AnyObject]
                //println(dico)
                let technique = SCNTechnique(dictionary:dico)
                //Need the screen size
				technique?.setValue(NSValue(cgSize: self.view.frame.size.applying(CGAffineTransform(scaleX: 2.0, y: 2.0))), forKeyPath: "size_screen")
                techniques["SSAO"] = technique
				segControl.insertSegment(withTitle: "SSAO", at: segControl.numberOfSegments, animated: false)
            }
        }
        
       
        
        segControl.selectedSegmentIndex = 0
        
        //-------------------------------------------
        // MARK: Gestures
        //-------------------------------------------
		let gesture = UIPanGestureRecognizer(target: self, action: #selector(panDetected(gesture:)))
        scnView.addGestureRecognizer(gesture)
		let gesture2 = UIPinchGestureRecognizer(target: self, action: #selector(pinchDetected(gesture:)))
        scnView.addGestureRecognizer(gesture2)
        
    
    }
    
    
    private var received = false
    func renderer( aRenderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        if(!received){
            received = true
            var point = glGetString(0x1F03) as UnsafePointer<UInt8>
            var array : [Int8] = []
            while (point[0] != UInt8(ascii:"\0")){
                array.append(Int8(point[0]))
				point = point.advanced(by: 1)
            }
            array.append(Int8(0))
			
			let point2 = String(cString: array)
			print("Available extensions :\n--------------------------")
			print(point2.replacingOccurrences(of: " ", with: "\n", options: .caseInsensitive, range: nil))
			
        }
       

    }

    //-------GESTURES AND CAMERA MOVES--------
    
    @IBAction func selectedTechnique(sender: UISegmentedControl) {
		let name = sender.titleForSegment(at: sender.selectedSegmentIndex)!
        switch name{
        case "Mirror","SSAO","Sobel","Drops":
            scnView.technique = techniques[name]
			cube.isHidden = name != "Mirror"
			scene2.isHidden = name != "SSAO"
            
            
        default:
			cube.isHidden = true
			scene2.isHidden = false
            scnView.technique = nil
        }
		scene1.isHidden = !scene2.isHidden
    }
    
    var previousScreenPoint = CGPoint(x: 0,y: 0)
    var previousPosition = SCNVector3(x: 0,y: 0,z: 0)
	
	
	@objc func panDetected(gesture:UIPanGestureRecognizer){
		let camera : SCNNode = cameraSphere.childNode(withName: "cam0", recursively: true)!
		let point = gesture.translation(in: scnView)
        
		if(gesture.state == .began){
            previousPosition =  camera.position
            previousScreenPoint = point
        }
        
        cameraSphere.eulerAngles.y -= Float(point.x-previousScreenPoint.x)/180.0 * 3.14159 * 0.4
        
        let newAngleX = cameraSphere.eulerAngles.x-Float(point.y-previousScreenPoint.y)/180.0 * 3.14159 * 0.4
		cameraSphere.eulerAngles.x = clamp(val: newAngleX,mini: -1.33,maxi: 1.33)
        
        previousScreenPoint = point
        previousPosition = camera.position
		cameraNode1.position = cameraSphere.convertPosition(camera.position, to: nil)
        cameraNode2.position = cameraNode1.position
        cameraNode2.position.y = -cameraNode2.position.y
    }
    
    let kZoomMin : Float = 2.0
    let kZoomMax : Float = 35.0
    let kMaxFactor : Float = 1.15
    
	@objc func pinchDetected(gesture:UIPinchGestureRecognizer){
        guard let camera: SCNNode = cameraSphere.childNodes.first else {return}
		if(gesture.state == .began){
            previousPosition =  camera.position
        }
        
        let scaling = Float(gesture.scale) == 0 ? 1.0 : Float(gesture.scale)
        
        let newPosition = previousPosition / scaling
		camera.position = newPosition.normalized() * clamp(val: newPosition.length(),mini: kZoomMin / kMaxFactor,maxi: kZoomMax * kMaxFactor)
        
		if ( (newPosition.length() > kZoomMax || newPosition.length() < kZoomMin) && gesture.state == UIGestureRecognizerState.ended){
            //move, then zoom in
            SCNTransaction.begin()
			SCNTransaction.animationDuration = 0.2
			SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
			camera.position = newPosition.normalized() * clamp(val: newPosition.length(),mini: kZoomMin,maxi: kZoomMax)
            SCNTransaction.commit()
            
        }
        
		cameraNode1.position = cameraSphere.convertPosition(camera.position, to: nil)
        cameraNode2.position = cameraNode1.position
        cameraNode2.position.y = -cameraNode2.position.y
    
        
    }
    
    //-------UTILITIES--------
    
    func generateReversedBox(blender : Bool) -> SCNNode{
        if (blender) {
            let scene3 = SCNScene(named: "art.scnassets/cube.dae")!
			let cube1 = scene3.rootNode.childNode(withName: "Cube", recursively: true)!
            return cube1
        }
        
        //UNUSED, not working
        let cube = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        
		let el = cube.element(at: 0)
        
		let chab = cube.sources(for: SCNGeometrySource.Semantic.vertex)
        guard let vec = chab.first else {return SCNNode()}
        
		let chab2 = cube.sources(for: SCNGeometrySource.Semantic.texcoord)
        guard let tex = chab2.first else {return SCNNode()}
        
        let norcoords : [SCNVector3] = [
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
		let nor = SCNGeometrySource(data: Data(bytes: norcoords, count: 12*24), semantic: SCNGeometrySource.Semantic.normal, vectorCount: 24, usesFloatComponents: true, componentsPerVector: 3, bytesPerComponent: 4, dataOffset: 0, dataStride: 0)
        
        let geom = SCNGeometry(sources: [vec,nor,tex], elements: [el])
        let cubeNode = SCNNode(geometry: geom)
        return cubeNode
        
    }
    
    func clamp<T: Comparable>(val:T, mini:T, maxi:T) -> T{
        return max(min(maxi,val),mini)
    }
    
	override var shouldAutorotate: Bool {
		return true
	}
	
	
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
