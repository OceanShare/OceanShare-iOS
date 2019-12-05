//
//  SubscribtionViewController.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 28/11/2019.
//  Copyright © 2019 Joseph Pereniguez. All rights reserved.
//

import Foundation
import UIKit

class SubscribtionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
}
