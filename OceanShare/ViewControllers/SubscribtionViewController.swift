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
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseCore
import Alamofire

class SubscribtionViewController: UIViewController {
    var userRef: DatabaseReference!
    let registry = Registry()
    var offerType: Int?
    var offerEnd: Date?
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
        button.layer.cornerRadius = 8
        button.backgroundColor = UIColor(rgb: 0x57A1FF)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        button.setTitle(NSLocalizedString("pay", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(pay), for: .touchUpInside)
        return button
        
    }()
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 8
        button.backgroundColor = UIColor(rgb: 0xFB6060)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        button.setTitle(NSLocalizedString("cancelPayment", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(hidePayment), for: .touchUpInside)
        return button
        
    }()
    lazy var payStackView: UIStackView = {
        let stackview = UIStackView(arrangedSubviews: [cardTextField, payButton, cancelButton])
        stackview.axis = .vertical
        stackview.spacing = 20
        stackview.translatesAutoresizingMaskIntoConstraints = false
        return stackview
            
    }()

    // MARK: - Outlets
    
    @IBOutlet weak var subscribtionViewTitle: UITextView!
    @IBOutlet weak var firstPointLabel: UILabel!
    @IBOutlet weak var secondPointLabel: UILabel!
    @IBOutlet weak var thirdPointLabel: UILabel!
    @IBOutlet weak var fourthPointLabel: UILabel!
    @IBOutlet weak var offerDescription: UITextView!
    
    @IBOutlet weak var offerOne: DesignableView!
    @IBOutlet weak var offerTwo: DesignableView!
    @IBOutlet weak var offerThree: DesignableView!
    @IBOutlet weak var offerOneTitle: UILabel!
    @IBOutlet weak var offerOnePrice: UILabel!
    @IBOutlet weak var offerTwoTitle: UILabel!
    @IBOutlet weak var offerTwoPrice: UILabel!
    @IBOutlet weak var offerThreeTitle: UILabel!
    @IBOutlet weak var offerThreePrice: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        userRef = Database.database().reference().child("users")
        setupView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchSubscribtion()
        
    }
    
    // MARK: - Setup
    
    /**
    - Description - Setup the design of the view.
    */
    func setupView() {
        observeKeyboardNotification()
        let color1 = registry.customClearBlue
        let color2 = registry.customWhiteBlue
        offerOne.applyGradient(colours:[color1, color2], corner:15)
        offerTwo.applyGradient(colours:[color1, color2], corner:15)
        offerThree.applyGradient(colours:[color1, color2], corner:15)
        /* Setup payment */
        view.backgroundColor = .white
        view.addSubview(payStackView)
        NSLayoutConstraint.activate([
            payStackView.leftAnchor.constraint(equalToSystemSpacingAfter: view.leftAnchor, multiplier: 2),
            view.rightAnchor.constraint(equalToSystemSpacingAfter: payStackView.rightAnchor, multiplier: 2),
            payStackView.topAnchor.constraint(equalToSystemSpacingBelow: offerOne.topAnchor, multiplier: 1),
        ])
        payStackView.isHidden = true
        offerDescription.isHidden = true
        setupLocalizedStrings()
        
    }
    
    /**
    - Description - Setup the translated labels.
    */
    func setupLocalizedStrings() {
        subscribtionViewTitle.text = NSLocalizedString("subViewTitle", comment: "")
        firstPointLabel.text = NSLocalizedString("subPointOne", comment: "")
        secondPointLabel.text = NSLocalizedString("subPointTwo", comment: "")
        thirdPointLabel.text = NSLocalizedString("subPointThree", comment: "")
        fourthPointLabel.text = NSLocalizedString("subPointFour", comment: "")
        offerOneTitle.text = NSLocalizedString("offerOneTitle", comment: "")
        offerOnePrice.text = NSLocalizedString("offerOnePrice", comment: "")
        offerTwoTitle.text = NSLocalizedString("offerTwoTitle", comment: "")
        offerTwoPrice.text = NSLocalizedString("offerTwoPrice", comment: "")
        offerThreeTitle.text = NSLocalizedString("offerThreeTitle", comment: "")
        offerThreePrice.text = NSLocalizedString("offerThreePrice", comment: "")
        
    }
    
    // MARK: - Actions

    /**
    - Description - Set one day of subscribtion.
    */
    @IBAction func buyOfferOne(_ sender: Any) {
        displayPayment(content: NSLocalizedString("gonnaSubOne", comment: ""))
        offerType = 1
        
    }
    
    /**
    - Description - Set two days of subscription.
    */
    @IBAction func buyOfferTwo(_ sender: Any) {
        displayPayment(content: NSLocalizedString("gonnaSubTwo", comment: ""))
        offerType = 2
        
    }
    
    /**
     - Description - Set one month of subscription.
     */
    @IBAction func buyOfferThree(_ sender: Any) {
        displayPayment(content: NSLocalizedString("gonnaSubThree", comment: ""))
        offerType = 3
        
    }
    
    /**
     - Description - Displays a message for premium users.
     - Inputs - content `String`
     */
    func displayPremium(content: String) {
        firstPointLabel.isHidden = true
        secondPointLabel.isHidden = true
        thirdPointLabel.isHidden = true
        fourthPointLabel.isHidden = true
        offerDescription.text = content
        offerDescription.isHidden = false
        payStackView.isHidden = true
        offerOne.isHidden = true
        offerTwo.isHidden = true
        offerThree.isHidden = true
        
    }
    
    /**
     - Description - Hide the payment field.
     */
    @objc func hidePayment() {
        self.view.endEditing(true)
        firstPointLabel.isHidden = false
        secondPointLabel.isHidden = false
        thirdPointLabel.isHidden = false
        fourthPointLabel.isHidden = false
        offerDescription.isHidden = true
        payStackView.isHidden = true
        offerOne.isHidden = false
        offerTwo.isHidden = false
        offerThree.isHidden = false
        
    }
    
    /**
     - Description - Displays the payment field.
     - Inputs - content `String`
     */
    func displayPayment(content: String) {
        firstPointLabel.isHidden = true
        secondPointLabel.isHidden = true
        thirdPointLabel.isHidden = true
        fourthPointLabel.isHidden = true
        offerDescription.text = content
        offerDescription.isHidden = false
        payStackView.isHidden = false
        offerOne.isHidden = true
        offerTwo.isHidden = true
        offerThree.isHidden = true
        
    }
    
    /**
     - Description - Check if the user is premium or not and displays or not the offers.
     */
    func fetchSubscribtion() {
        let currentDate = NSDate() as Date
        
        if Defaults.getUserDetails().subEnd.timeIntervalSince(currentDate).sign == FloatingPointSign.minus {
            print("-> not premium")
            
        } else {
            print("-> premium")
            displayPremium(content: NSLocalizedString("alreadyPremium", comment: ""))
            
        }
    }
    
    // MARK: - Payment
    
    /**
     - Description - Displays a custom alert.
     - Inputs - title `String` & message `String` & restartDemo `Bool`
     */
    func displayAlert(title: String, message: String, restartDemo: Bool = false) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            if restartDemo {
                alert.addAction(UIAlertAction(title: NSLocalizedString("subContinue", comment: ""), style: .cancel) { _ in
                    self.cardTextField.clear()
                    self.fetchSubscribtion()
                })
                
            }
            else {
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                
            }
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    /**
     - Description - Get the end of subscribtion that the user just did.
     - Inputs - subStart `Date`
     - Output - `Date` end of subscribtion
     */
    func calculateSubscribtion(subStart: Date) -> Date {
        var subEnd: Date?
        
        switch offerType {
        case 1:
            subEnd = subStart.addDay(n: 1)
            return subEnd ?? subStart
        case 2:
            subEnd = subStart.addDay(n: 2)
            return subEnd ?? subStart
        case 3:
            subEnd = subStart.addMonth(n: 1)
            return subEnd ?? subStart
        default:
            return subStart
            
        }
    }
    
    /**
     - Description - Sends the payment data to the database and in `userDefault`.
     */
    func updateSubscribtionData() {
        let userId = Defaults.getUserDetails().uid
        let datas: [String: Any] = [
            "type": offerType!,
            "start": NSDate().timeIntervalSince1970 as Any,
            "end": calculateSubscribtion(subStart: NSDate() as Date).timeIntervalSince1970 as Any
        ]
        let subData: [String: Any] = [
            "sub": datas
        ]
        
        Defaults.save(userId, name: Defaults.getUserDetails().name, email: Defaults.getUserDetails().email, picture: Defaults.getUserDetails().picture, shipName: Defaults.getUserDetails().shipName, boatId: Defaults.getUserDetails().boatId, ghostMode: Defaults.getUserDetails().ghostMode, showPicture: Defaults.getUserDetails().showPicture, isEmail: Defaults.getUserDetails().isEmail, isCelsius: Defaults.getUserDetails().isCelsius, subEnd: calculateSubscribtion(subStart: NSDate() as Date))
        userRef.child(userId).updateChildValues(subData)
        
    }
    
    /**
     - Description - Payment threw stripe.
     */
    @objc func pay() {
        let cardParams = STPCardParams()
        cardParams.number = cardTextField.cardNumber
        cardParams.expMonth = cardTextField.expirationMonth
        cardParams.expYear = cardTextField.expirationYear
        cardParams.cvc = cardTextField.cvc

        view.endEditing(true)
        hidePayment()
        STPAPIClient.shared().createToken(withCard: cardParams) { token, error in
            guard let token = token else {
                return
                
            }
            let tokenID = token.tokenId
            print(tokenID)
            let url = URL(string: "https://us-central1-oceanshare-1519985626980.cloudfunctions.net/" + "charge/")!
            let dict = post(token: tokenID, amount: 3555, currency: "EUR")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            do {
                let jsonData = try encoder.encode(dict)
                print(String(data: jsonData, encoding: .utf8) as Any)
                request.httpBody = jsonData
                print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
                
            } catch {
                print("error")
                
            }
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
                    self?.displayAlert(title: NSLocalizedString("subFailed", comment: ""), message: chargeError)
                    
                } else {
                    self?.updateSubscribtionData()
                    self?.displayAlert(title: "Success", message: NSLocalizedString("subSucceededDesc", comment: ""), restartDemo: true)
                    
                }
            })
            task.resume()
        }
    }
    
    // MARK: - Keyboard Handling
    
    /**
     - Description - Handle keyboard when user is typing on a textfield or outside a textfield.
     */
    fileprivate func observeKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    /**
     - Description - Show the keyboard when its needed.
     */
    @objc func keyboardShow() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.frame = CGRect(x: 0, y: -30, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
    }
    
    /**
     - Description - Hide the keyboard when the user is typing outside a textfield.
     */
    @objc func keyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
    }
    
}
