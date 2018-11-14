//
//  ViewController.swift
//  iossamples
//
//  Created by 石倉昇 on 2018/11/14.
//  Copyright © 2018 noboru-i. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func onClickSpeech(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "SpeechViewController", bundle: nil)
        if let next = storyboard.instantiateInitialViewController() {
            present(next, animated: true)
        }
    }
}
