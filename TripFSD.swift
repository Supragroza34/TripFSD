import SpriteKit
import UIKit




class GameViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SpriteKit view
        let skView = SKView(frame: self.view.bounds)
        self.view.addSubview(skView)
        
        //Configuring Game scene
        let scene = GameScene(size: skView.bounds.size)
        skView.presentScene(scene)
        
        //configure SKView
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
    }
}



class GameScene: SKScene, SKPhysicsContactDelegate {
    private var car: SKSpriteNode
    private var waypoints: [CGPoint] = []
    private var wayPointIndex = 0
    
    override func didMove(to view: SKView) {
        
        // Set up Scene
        backgroundColor = .white
        physicsWorld.contactDelegate = self
        
        //add road
        setupRoad()
        
        // add car
        setupCar()
        
        // Define Waypoints
        setWayPoints()
        
        //Start car autonous movement
        moveToNextWaypoint()
    }
    
    
    private func setupRoad(){
        let road = SKSpriteNode(color: .gray, size: CGSize(width: size.width, height:200))
        road.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(road)
    }
    
    private func setupCar(){
        car = SKSpriteNode(color: .blue, size: CGSize(width: 50, height: 100))
        car.position = CGPoint(x: size.width / 4, y: size.width / 2)
        car.physicsBody = SKPhysicsBody(rectangleOf: car.size)
        car.physicsBody?.affectedByGravity = false
        car.physicsBody?.isDynamic = true
        car.physicsBody?.categoryBitMask = PhysicsCategory.car
        car.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle
        car.physicsBody?.collisionBitMask = PhysicsCategory.none
        addChild(car)
        
    }
    
    private func setWayPoints(){
        waypoints = [
            CGPoint(x: size.width / 2, y: size.height / 2 + 150),
            CGPoint(x: size.width / 2 + 200, y: size.height / 2 + 150),
            CGPoint(x: size.width / 2 + 200, y: size.height / 2 - 150),
            CGPoint(x: size.width / 2 - 200, y: size.height / 2 - 150)
        ]
        //Visual Markers for waypoints
        for waypoint in waypoints{
            let marker = SKShapeNode(circleOfRadius: 10)
            marker.position = waypoint
            marker.fillColor = .red
            addChild(marker)
        }
    }
    
    private func moveToNextWaypoint(){
        guard wayPointIndex < waypoints.count else{
            print(" All Way points reached")
            return
        }
        
        let target = waypoints[wayPointIndex]
        
        //calculate movement action
        let movesAction = SKAction.move(to: target, duration: 2.0)
        let rotateAction = SKAction.rotate(toAngle: atan2(target.y - car.position.y, target.x - car.position.x), duration: 0.5, shortestUnitArc: true)
        
        let sequence  = SKAction.sequence([
            rotateAction,
            movesAction,
            SKAction.run {
                self.wayPointIndex += 1
                self.moveToNextWaypoint()
            }
        ])
        
        car.run(sequence)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == PhysicsCategory.car | PhysicsCategory.obstacle {
            print("Collsion detected! STOPPING THE CAR")
            car.removeAllActions()
        }
    }
    
    // MARK: - Add Obstacles
    private func addObstacle(at position: CGPoint) {
        let obstacle = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
        obstacle.position = position
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.affectedByGravity = false
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        addChild(obstacle)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Example: Add obstacle where the user touches
        if let touch = touches.first {
            let location = touch.location(in: self)
            addObstacle(at: location)
        }
    }
}

// MARK: - PhysicsCategory
struct PhysicsCategory {
    static let none: UInt32 = 0
    static let car: UInt32 = 0b1
    static let obstacle: UInt32 = 0b10
}

    


let road = SKSpriteNode(color: .gray, size: CGSize(width: 500, height: 500))
road.position = CGPoint(x: 0, y: 0)
addChild(road)


let car = SKSpriteNode(color: .blue, size: CGSize(width: 50, height: 100))
car.position = CGPoint(x: 0, y: 0)
car.zRotation = 0
addChild(car)


car.physicsBody = SKPhysicsBody(rectangleOf: car.size)
car.physicsBody?.affectedByGravity = false
car.physicsBody?.allowsRotation = true

let ray = SKPhysicsBody(edgeFrom: car.position, to: CGPoint(x: car.position.x + 100, y: car.position.y))

