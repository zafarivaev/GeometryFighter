import UIKit
import SceneKit

class GameViewController: UIViewController {
    
    var scnView: SCNView!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    var spawnTime: TimeInterval = 0
    var game = GameHelper.sharedInstance
    var splashNodes: [String: SCNNode] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScene()
        setupCamera()
        setupHUD()
        setupSplash()
        setupSounds()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setupView() {
        scnView = self.view as? SCNView
        scnView.autoenablesDefaultLighting = true
        scnView.delegate = self
        scnView.isPlaying = true
    }
    
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        scnScene.background.contents = "GeometryFighter.scnassets/Textures/Background_Diffuse.jpg"
    }
    
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 5, 10)
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    func spawnShape() {
        var geometry: SCNGeometry
        
        switch ShapeType.random() {
        case .box:
            geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        case .sphere:
            geometry = SCNSphere(radius: 0.5)
        case .pyramid:
            geometry = SCNPyramid(width: 1.0, height: 1.0, length: 1.0)
        case .torus:
            geometry = SCNTorus(ringRadius: 0.5, pipeRadius: 0.25)
        case .capsule:
            geometry = SCNCapsule(capRadius: 0.3, height: 2.5)
        case .cylinder:
            geometry = SCNCylinder(radius: 0.3, height: 2.5)
        case .cone:
            geometry = SCNCone(topRadius: 0.25, bottomRadius: 0.5, height: 1.0)
        case .tube:
            geometry = SCNTube(innerRadius: 0.25, outerRadius: 0.5, height: 1.0)
        }
        
        let color = UIColor.random()
        geometry.materials.first?.diffuse.contents = color
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        let randomX = Float.random(min: -2, max: 2)
        let randomY = Float.random(min: 10, max: 18)
        
        let force = SCNVector3(x: randomX, y: randomY, z: 0)
        let position = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
        geometryNode.physicsBody?.applyForce(force, at: position, asImpulse: true)
        
        let trailEmitter = createTrail(color: color, geometry: geometry)
        geometryNode.addParticleSystem(trailEmitter)
        
        if color == .black {
            geometryNode.name = "BAD"
            game.playSound(scnScene.rootNode, name: "SpawnBad")
        } else {
            geometryNode.name = "GOOD"
            game.playSound(scnScene.rootNode, name: "SpawnGood")
        }
        
        scnScene.rootNode.addChildNode(geometryNode)
    }
    
    func cleanScene() {
        for node in scnScene.rootNode.childNodes {
            if node.presentation.position.y < -2 {
                node.removeFromParentNode()
            }
        }
    }
    
    func createTrail(color: UIColor, geometry: SCNGeometry) -> SCNParticleSystem {
        let trail = SCNParticleSystem(named: "Trail.scnp", inDirectory: nil)!
        trail.particleColor = color
        trail.emitterShape = geometry
        return trail
    }
    
    func setupHUD() {
        game.hudNode.position = SCNVector3(0.0, 10.0, 0.0)
        scnScene.rootNode.addChildNode(game.hudNode)
    }
    
    func createSplash(name: String, imageFileName: String) -> SCNNode {
        let plane = SCNPlane(width: 5, height: 5)
        let splashNode = SCNNode(geometry: plane)
        splashNode.position = SCNVector3(x: 0, y: 5, z: 0)
        splashNode.name = name
        splashNode.geometry?.materials.first?.diffuse.contents = imageFileName
        scnScene.rootNode.addChildNode(splashNode)
        return splashNode
    }
    
    func showSplash(splashName: String) {
        for (name, node) in splashNodes {
            node.isHidden = name != splashName
        }
    }
    
    func setupSplash() {
        splashNodes["TapToPlay"] = createSplash(name: "TAPTOPLAY", imageFileName: "GeometryFighter.scnassets/Textures/TapToPlay_Diffuse.png")
        splashNodes["GameOver"] = createSplash(name: "GAMEOVER", imageFileName: "GeometryFighter.scnassets/Textures/GameOver_Diffuse.png")
        showSplash(splashName: "TapToPlay")
    }
    
    func setupSounds() {
      game.loadSound("ExplodeGood",
        fileNamed: "GeometryFighter.scnassets/Sounds/ExplodeGood.wav")
      game.loadSound("SpawnGood",
        fileNamed: "GeometryFighter.scnassets/Sounds/SpawnGood.wav")
      game.loadSound("ExplodeBad",
        fileNamed: "GeometryFighter.scnassets/Sounds/ExplodeBad.wav")
      game.loadSound("SpawnBad",
        fileNamed: "GeometryFighter.scnassets/Sounds/SpawnBad.wav")
      game.loadSound("GameOver",
        fileNamed: "GeometryFighter.scnassets/Sounds/GameOver.wav")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if game.state == .GameOver {
            return
        }
        
        if game.state == .TapToPlay {
            game.reset()
            game.state = .Playing
            showSplash(splashName: "")
            return
        }
        
        let touch = touches.first!
        let location = touch.location(in: scnView)
        let hitResults = scnView.hitTest(location, options: nil)
        
        if let result = hitResults.first {
            switch result.node.name {
            case "HUD", "GAMEOVER", "TAPTOPLAY":
                return
            case "GOOD":
                handleGoodCollision()
            case "BAD":
                handleBadCollision()
            default:
                break
            }
            
            createExplosion(geometry: result.node.geometry!, position: result.node.presentation.position, rotation: result.node.presentation.rotation)
            
            result.node.removeFromParentNode()
        }
    }
    
    func handleGoodCollision() {
        game.score += 1
        game.playSound(scnScene.rootNode, name: "ExplodeGood")
    }
    
    func handleBadCollision() {
        game.lives -= 1
        game.playSound(scnScene.rootNode, name: "ExplodeBad")
        game.shakeNode(cameraNode)
        
        if game.lives <= 0 {
            game.saveState()
            showSplash(splashName: "GameOver")
            game.playSound(scnScene.rootNode, name: "GameOver")
            game.state = .GameOver
            
            scnScene.rootNode.runAction(SCNAction.waitForDurationThenRunBlock(5) { (node) in
                
                self.showSplash(splashName: "TapToPlay")
                self.game.state = .TapToPlay
            })
        }
    }
    
    func createExplosion(geometry: SCNGeometry, position: SCNVector3, rotation: SCNVector4) {
        let explosion = SCNParticleSystem(named: "Explode.scnp", inDirectory: nil)!
        explosion.emitterShape = geometry
        explosion.birthLocation = .surface
        
        let rotationMatrix = SCNMatrix4MakeRotation(rotation.w, rotation.x, rotation.y, rotation.z)
        let translationMatrix = SCNMatrix4MakeTranslation(position.x, position.y, position.z)
        let transformMatrix = SCNMatrix4Mult(rotationMatrix, translationMatrix)
        scnScene.addParticleSystem(explosion, transform: transformMatrix)
    }
    
}

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if time > spawnTime {
            spawnShape()
            
            spawnTime = time + TimeInterval(Float.random(min: 0.2, max: 1.5))
        }
        cleanScene()
        game.updateHUD()
    }
}
