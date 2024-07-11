//
//  ViewController.swift
//  NotificationCenterProject
//
//  Created by Omer Keskin on 5.07.2024.
//

import UIKit
import Foundation



class ViewController: UIViewController {
    
    let decryptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Decrypt", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(decryptButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let codeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Code"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let randomCodeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.isHidden = true
        return label
    }()
    
    var randomCode: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        generateAndShowRandomCode()
    }
    
    private func setupLayout() {
        view.addSubview(decryptButton)
        view.addSubview(codeTextField)
        view.addSubview(randomCodeLabel)
        
        NSLayoutConstraint.activate([
            decryptButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            decryptButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            codeTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            codeTextField.bottomAnchor.constraint(equalTo: decryptButton.topAnchor, constant: -20),
            codeTextField.widthAnchor.constraint(equalToConstant: 200),
            
            randomCodeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            randomCodeLabel.bottomAnchor.constraint(equalTo: codeTextField.topAnchor, constant: -80)
        ])
    }
    
    private func generateAndShowRandomCode() {
        randomCode = String(format: "%04d", arc4random_uniform(10000))
        randomCodeLabel.text = randomCode
        randomCodeLabel.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.randomCodeLabel.isHidden = true
        }
    }
    
    @objc func decryptButtonTapped() {
        guard let enteredCode = codeTextField.text, enteredCode == randomCode else {
            let alert = UIAlertController(title: "Error", message: "Incorrect code", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
            return
        }
        
        startDecryptionProcess()
    }
    
    func startDecryptionProcess() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) { [weak self] in
            self?.activateDecryptionSoftware()
        }
        
   
        let waitingVC = WaitingViewController()
        present(waitingVC, animated: true, completion: nil)
    }
    
    func activateDecryptionSoftware() {

        let decryptedMessage = "I may be slightly autistic"
        

        NotificationCenter.default.post(name: .decryptionComplete, object: nil, userInfo: ["message": decryptedMessage])
    }
}




class WaitingViewController: UIViewController {
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let countdownLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 36)
        return label
    }()
    
    var countdownTimer: Timer?
    var countdownSeconds = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        startCountdown()
        NotificationCenter.default.addObserver(self, selector: #selector(handleDecryptionComplete(_:)), name: .decryptionComplete, object: nil)
    }
    
    private func setupLayout() {
        view.addSubview(messageLabel)
        view.addSubview(countdownLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            countdownLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70),
            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func startCountdown() {
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.countdownSeconds > 0 {
                self.countdownLabel.text = "\(self.countdownSeconds)"
                self.countdownSeconds -= 1
            } else {
                timer.invalidate()
              
            }
        }
    }
    
    @objc func handleDecryptionComplete(_ notification: Notification) {
        countdownTimer?.invalidate()
        self.countdownLabel.isHidden = true
        
        if let userInfo = notification.userInfo, let message = userInfo["message"] as? String {
            messageLabel.text = message
            

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.messageLabel.text = nil
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .decryptionComplete, object: nil)
    }
}




extension Notification.Name {
    static let decryptionComplete = Notification.Name("decryptionComplete")
}
