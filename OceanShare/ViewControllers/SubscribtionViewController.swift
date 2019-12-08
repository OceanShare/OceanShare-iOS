//
//  SubscribtionViewController.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 28/11/2019.
//  Copyright © 2019 Joseph Pereniguez. All rights reserved.
//

import Foundation
import UIKit
import Stripe
import Alamofire

class SubscribtionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    struct post: Codable {
        var token: String
        var amount: Int?
        var currency: String
    }

    lazy var cardTextField: STPPaymentCardTextField = {
        let cardTextField = STPPaymentCardTextField()
        return cardTextField
    }()
    lazy var payButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        button.setTitle("Pay", for: .normal)
        button.addTarget(self, action: #selector(pay), for: .touchUpInside)
        return button
    }()
    
    var offers: [Offer] = Offer.fetchOffer()
    
    // MARK: - Outlets
    
    @IBOutlet weak var offersTableView: UITableView!
    @IBOutlet weak var subscribtionViewTitle: UITextView!
    @IBOutlet weak var firstPointLabel: UILabel!
    @IBOutlet weak var secondPointLabel: UILabel!
    @IBOutlet weak var thirdPointLabel: UILabel!
    @IBOutlet weak var fourthPointLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        let stackView = UIStackView(arrangedSubviews: [cardTextField, payButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalToSystemSpacingAfter: view.leftAnchor, multiplier: 2),
            view.rightAnchor.constraint(equalToSystemSpacingAfter: stackView.rightAnchor, multiplier: 2),
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 2),
        ])
        
        setupView()
        overrideUserInterfaceStyle = .light
        self.offersTableView.delegate = self
        self.offersTableView.dataSource = self
        
    }
    
    // MARK: - Setup
    
    func setupView() {
        subscribtionViewTitle.text = NSLocalizedString("subViewTitle", comment: "")
        firstPointLabel.text = NSLocalizedString("subPointOne", comment: "")
        secondPointLabel.text = NSLocalizedString("subPointTwo", comment: "")
        thirdPointLabel.text = NSLocalizedString("subPointThree", comment: "")
        fourthPointLabel.text = NSLocalizedString("subPointFour", comment: "")
        
    }
    
    // MARK: - Protocol Stubs
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return offers.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "offerCell", for: indexPath) as! OffersTableViewCell
        let offer = offers[indexPath.row]
        cell.offer = offer
        return cell
        
    }
    
    // MARK: - Payment
    
    func displayAlert(title: String, message: String, restartDemo: Bool = false) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            if restartDemo {
                alert.addAction(UIAlertAction(title: "Continue", style: .cancel) { _ in
                    self.cardTextField.clear()
                })
            }
            else {
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func pay() {
            // Create an STPCardParams instance
            let cardParams = STPCardParams()
            cardParams.number = cardTextField.cardNumber
            cardParams.expMonth = cardTextField.expirationMonth
            cardParams.expYear = cardTextField.expirationYear
            cardParams.cvc = cardTextField.cvc

            // Pass it to STPAPIClient to create a Token
            STPAPIClient.shared().createToken(withCard: cardParams) { token, error in
                guard let token = token else {
                    // Handle the error
                    return
                }
                // Send the token identifier to your server
                let tokenID = token.tokenId
                print(tokenID)
                let url = URL(string: "https://us-central1-oceanshare-1519985626980.cloudfunctions.net/" + "charge/")!
                let dict = post(token: tokenID, amount: 3555, currency: "EUR")
                print(dict.token)
                print(dict.amount)
                print(dict.currency)
       /*          let dict: [String: Any] = [
                    "token": tokenID,
                    "charge": [
                        "amount": 35,
                        "currency": "EUR"
                    ]
                ]
            
                
               if let json = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                    if let content = String(data: json, encoding: String.Encoding.utf8) {
                        print(content)
                    }
                }
               
                 
    */
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                do {
                    let jsonData = try encoder.encode(dict)
                    print(String(data: jsonData, encoding: .utf8))
                    // ... and set our request's HTTP body
                    request.httpBody = jsonData
                    print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
                } catch {
                    
                    print("error")
                }
                
                
             //   let content = try? JSONSerialization.data(withJSONObject: dict)
             //   print(content)
             //   let finaljson = String(data: content!, encoding: String.Encoding.utf8)
              //  print(finaljson)
               // request.httpBody = content
              //  print(request)
              //  print(json)
                let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
                    guard let response = response as? HTTPURLResponse,
                        response.statusCode == 200,
                        let data = data,
                        let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
                            let message = error?.localizedDescription ?? "Failed to decode response from server."
                            self?.displayAlert(title: "Error creating Charge", message: message)
                            return
                    }
            
                    if let chargeError = json["error"] as? String {
                        self?.displayAlert(title: "Payment failed", message: chargeError)
                    } else {
                        self?.displayAlert(title: "Success", message: "Payment succeeded!", restartDemo: true)
                        print(json)
                    }
                    
                })
                task.resume()
            }
        }
    
}
