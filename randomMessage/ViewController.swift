//
//  ViewController.swift
//  randomMessage
//
//  Created by Paulo Silva on 24/09/2018.
//  Copyright © 2018 Paulo Silva. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var displayCounter: Int = 0
    let rndMessage = randomMessage()
    
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var labelCounter: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    @IBAction func getMessageAction(_ sender: Any) {
        
        let stringKey = rndMessage.getMessageForSubject("abc")
        
        // Display Message Key
        self.labelMessage.text = "Key: \(String(describing: stringKey))"
        
        // Set Counter and display
        self.displayCounter = self.displayCounter+1
        self.labelCounter.text = "Counter: \(self.displayCounter)"
        
    }
    
}

