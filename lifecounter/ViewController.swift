import UIKit

class ViewController: UIViewController {
    
    class Player {
        var name: String
        var lives: Int
        var nameLabel: UILabel
        var livesLabel: UILabel
        init(name: String, lives: Int, nameLabel: UILabel, livesLabel: UILabel) {
            self.name = name
            self.lives = lives
            self.nameLabel = nameLabel
            self.livesLabel = livesLabel
        }
    }
    
    struct Button {
        var delta: Int
        var playerIndex: Int
    }
    
    var players: [Player] = []
    var buttons: [UIButton] = []
    var addPlayerButton: UIButton!
    var recordedEvents:[String] = []
    
    @IBOutlet weak var test: UIButton!
    
    @IBOutlet weak var remove: UIButton!
    
    
    
    var gameStarted = false
    
    override func viewDidLoad() {
          super.viewDidLoad()
        view.bringSubviewToFront(test)
        view.bringSubviewToFront(remove)
          createPlayers(numberOfPlayers: 4)
      }
      
      @IBAction func addPlayer() {
          guard players.count < 8 else { return }
          
          let newPlayer = Player(name: "Player \(players.count + 1)", lives: 20, nameLabel: UILabel(), livesLabel: UILabel())
          players.append(newPlayer)
          recordedEvents.append("Added new player.")
          updatePlayerViews()
      }
    @IBAction func removePlayer() {
        guard players.count > 2 else { return }
        
        players.removeLast() // Remove the last added player
        recordedEvents.append("Removed player.")
        updatePlayerViews() // Update the player views after removing the player
    }
    
    @IBAction func resetGame() {
        players.removeAll()
 
        for index in 1...4 {
            let newPlayer = Player(name: "Player \(index)", lives: 20, nameLabel: UILabel(), livesLabel: UILabel())
            players.append(newPlayer)
        }
        gameStarted = false
        recordedEvents = []
        updatePlayerViews()
    }

    
    func createPlayers(numberOfPlayers: Int) {
        guard numberOfPlayers >= 2 && numberOfPlayers <= 8 else {
            fatalError("Number of players must be between 2 and 8")
        }
        
        for i in 1...numberOfPlayers {
            let player = Player(name: "Player \(i)", lives: 20, nameLabel: UILabel(), livesLabel: UILabel())
            players.append(player)
        }
        updatePlayerViews()
    }
    
    func updatePlayerViews() {
        view.subviews.filter { $0 is UIStackView}.forEach { $0.removeFromSuperview() }
        
        let numRows = Int(sqrt(Double(players.count)))
        let numCols = (players.count + numRows - 1) / numRows
        
        let playerViewWidth = (view.bounds.width - 0) / CGFloat(numCols)
        let playerViewHeight = (view.bounds.height + 0) / CGFloat(numRows)
        
        let outerStackView = UIStackView()
        outerStackView.axis = .vertical
        outerStackView.alignment = .center
        outerStackView.spacing = 10
        view.addSubview(outerStackView)
        outerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            outerStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            outerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            outerStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        var innerStackViews = [UIStackView]()
            for row in 0..<numRows {
                let innerStackView = UIStackView()
                innerStackView.axis = .horizontal
                innerStackView.spacing = 5
                outerStackView.addArrangedSubview(innerStackView)
                innerStackViews.append(innerStackView)
            
            for col in 0..<numCols {
                let playerIndex = row * numCols + col
                guard playerIndex < players.count else { return }
                
                let player = players[playerIndex]
                
                let playerView = UIView()
                playerView.widthAnchor.constraint(equalToConstant: playerViewWidth).isActive = true
                playerView.heightAnchor.constraint(equalToConstant: playerViewHeight).isActive = true
                innerStackView.addArrangedSubview(playerView)
                
                setUpNewPlayer(player, containerView: playerView)
                view.bringSubviewToFront(test)
                view.bringSubviewToFront(remove)
            }
                
                for player in players {
                    if player.lives <= 0 {
                        let lostAlertController = UIAlertController(title: "Game Over", message: "\(player.name) has lost the game.", preferredStyle: .alert)
                        lostAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(lostAlertController, animated: true, completion: nil)
                        recordedEvents.append("\(player.name) has lost the game.")
                        break
                    }
                    if player.lives > 999 {
                        player.lives = 999
                    }
                }
        }
        
        // Equalize heights of inner stack views
        for stackView in innerStackViews {
            stackView.heightAnchor.constraint(equalTo: innerStackViews.first!.heightAnchor).isActive = true
        }
        
        test.isEnabled = !gameStarted
        remove.isEnabled = !gameStarted
    }

    func setUpNewPlayer(_ player: Player, containerView: UIView) {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        containerView.addSubview(stackView)
        
        player.nameLabel.text = player.name
        player.nameLabel.textAlignment = .center
        player.nameLabel.numberOfLines = 0
        player.nameLabel.lineBreakMode = .byWordWrapping
        stackView.addArrangedSubview(player.nameLabel)
        
        player.livesLabel.text = "Lives: \(player.lives)"
        player.livesLabel.textAlignment = .center
        player.livesLabel.numberOfLines = 0
        player.livesLabel.lineBreakMode = .byWordWrapping
        stackView.addArrangedSubview(player.livesLabel)
        
        let addCustomButton = UIButton()
           addCustomButton.configuration = .filled()
           addCustomButton.setTitle("+ ___", for: .normal)
           addCustomButton.addTarget(self, action: #selector(addCustomButtonPressed(_:)), for: .touchUpInside)
           addCustomButton.tag = players.firstIndex(where: { $0 === player })!
           stackView.addArrangedSubview(addCustomButton)
           
        let subtractCustomButton = UIButton()
           subtractCustomButton.configuration = .filled()
           subtractCustomButton.setTitle("- ___", for: .normal)
           subtractCustomButton.addTarget(self, action: #selector(subtractCustomButtonPressed(_:)), for: .touchUpInside)
           subtractCustomButton.tag = players.firstIndex(where: { $0 === player })!
           stackView.addArrangedSubview(subtractCustomButton)
           
        
        let buttons = [Button(delta: 1, playerIndex: players.firstIndex(where: { $0 === player })!), Button(delta: -1, playerIndex: players.firstIndex(where: { $0 === player })!)]
        for buttonInfo in buttons {
            let button = setUpButton(buttonInfo)
            stackView.addArrangedSubview(button)
        }
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }

    @objc func addCustomButtonPressed(_ sender: UIButton) {
        showCustomAlert(sender, delta: 1, action: "gained")
    }

    @objc func subtractCustomButtonPressed(_ sender: UIButton) {
        showCustomAlert(sender, delta: -1, action: "lost")
    }

    func showCustomAlert(_ sender: UIButton, delta: Int, action: String) {
        let playerIndex = sender.tag
        guard playerIndex >= 0 && playerIndex < players.count else { return }
        let player = players[playerIndex]
        
        let alertController = UIAlertController(title: "Enter Change", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Change"
            textField.keyboardType = .numberPad
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Apply", style: .default, handler: { (_) in
            if let textField = alertController.textFields?.first,
               let text = textField.text,
               let change = Int(text) {
                player.lives += (change * delta)
                player.livesLabel.text = "Lives: \(player.lives)"
                self.players[playerIndex] = player
                
                let eventDescription = "\(player.name) \(action) \(abs(change)) life"
                self.recordedEvents.append(eventDescription)
                print("Success")
                
                self.gameStarted = true
                self.updatePlayerViews()
            }
        }))
        
        present(alertController, animated: true, completion: nil)
    }

    
    func setUpButton(_ buttonInfo: Button) -> UIButton {
        let button = UIButton()
        button.configuration = .filled()
        button.setTitle(buttonInfo.delta > 0 ? "+\(buttonInfo.delta)" : "\(buttonInfo.delta)", for: .normal)
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        button.tag = buttonInfo.playerIndex
        return button
    }
    
    @objc func buttonPressed(_ sender: UIButton) {
        let playerIndex = sender.tag
        guard playerIndex >= 0 && playerIndex < players.count else { return }
        let player = players[playerIndex]
        
        guard let deltaString = sender.titleLabel?.text, let delta = Int(deltaString) else { return }
        player.lives += delta
        player.livesLabel.text = "Lives: \(player.lives)"
        players[playerIndex] = player
        
        let eventDescription = "\(player.name) \(delta >= 0 ? "gained" : "lost") \(abs(delta)) life"
        recordedEvents.append(eventDescription)
        gameStarted = true
        updatePlayerViews()
    }
    
    
    @IBAction func showHistory() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let historyVC = storyboard.instantiateViewController(withIdentifier: "HistoryViewController") as? HistoryViewController {

            historyVC.recordedEvents = recordedEvents
            present(historyVC, animated: true, completion: nil)
        }
    }

    
    }

