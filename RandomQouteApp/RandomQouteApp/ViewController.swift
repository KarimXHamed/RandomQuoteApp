//
//  ViewController.swift
//  RandomQouteApp
//
//  Created by karim hamed ashour on 7/23/24.
//

import UIKit
class ViewController: UIViewController {
    var todaysQyoute=QouteModel(q: "press refresh button first", a: "the Developer")
    var currentQoute=[QouteModel]()
    @IBOutlet weak var qouteLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var quoteVCButton: UIButton!
    @IBOutlet weak var buttonBG: UIImageView!
    @IBOutlet weak var quoteBG: UILabel!
    @IBOutlet weak var authorBG: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchQuote()
        quoteVCButton.layer.cornerRadius = quoteVCButton.frame.width / 2
        quoteVCButton.clipsToBounds = true
        
        
        quoteBG.layer.cornerRadius = quoteBG.frame.width / 2
        quoteBG.clipsToBounds = true
        
        
        buttonBG.image=UIImage(named: "7.jpeg")
        buttonBG.contentMode = .scaleAspectFill
        buttonBG.layer.cornerRadius = buttonBG.frame.width / 2
        buttonBG.clipsToBounds = true
        
        authorBG.image=UIImage(named: "7.jpeg")
        authorBG.contentMode = .scaleAspectFill
        authorBG.layer.cornerRadius = 20
        authorBG.clipsToBounds = true
        
        navigationItem.title="Daily Quote"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonTapped))
        
        
        
    }
    @objc func shareButtonTapped(sender:AnyObject){
        let sharableQuote = "Today's Quote is: \(todaysQyoute.q)\n said by: \(todaysQyoute.a)"
        let activityViewController : UIActivityViewController = UIActivityViewController(
                activityItems: [sharableQuote], applicationActivities: nil)
            
            // This lines is for the popover you need to show in iPad
            activityViewController.popoverPresentationController?.sourceView = (sender as! UIButton)
            
            // This line remove the arrow of the popover to show in iPad
            activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
            
            // Pre-configuring activity items
            activityViewController.activityItemsConfiguration = [
            UIActivity.ActivityType.message
            ] as? UIActivityItemsConfigurationReading
            
            // Anything you want to exclude
            activityViewController.excludedActivityTypes = [
                UIActivity.ActivityType.postToWeibo,
                UIActivity.ActivityType.print,
                UIActivity.ActivityType.assignToContact,
                UIActivity.ActivityType.saveToCameraRoll,
                UIActivity.ActivityType.addToReadingList,
                UIActivity.ActivityType.postToFlickr,
                UIActivity.ActivityType.postToVimeo,
                UIActivity.ActivityType.postToTencentWeibo,
                UIActivity.ActivityType.postToFacebook
            ]
            
            activityViewController.isModalInPresentation = true
            self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    func fetchQuote() {
        // Define the URL for the GitHub API
        let token = //your personal access token here
        let url = URL(string: "https://zenquotes.io/api/quotes")!

        // Define the headers for the request
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Make the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making request: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data returned")
                return
            }
            //remove the BOM
            guard let jsonString = String(data:data , encoding: .utf8)else{
                print("unable to convert data to string")
                return
            }
            let bomRemovedString = jsonString.replacingOccurrences(of: "\u{FEFF}", with: "")
            print("\(bomRemovedString)")
            
            // Parse the JSON data
            do {
                let quotes = try JSONDecoder().decode([QouteModel].self, from: bomRemovedString.data(using: .utf8)!)
                self.currentQoute=quotes
                
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        
        // Handle the response
        task.resume()
    }
    func typeWriterEffect(_ text: String, on label: UILabel, completion: @escaping () -> Void) {
        label.text = ""
        var charIndex = 0.0
        for letter in text {
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { timer in
                label.text?.append(letter)
                if charIndex == Double(text.count) - 1 {
                    completion()
                }
            }
            charIndex += 1
        }
    }
    @IBAction func qouteVCButtonAction(_ sender: Any) {
        let quote = currentQoute.randomElement()
        todaysQyoute=quote!
        UIView.animate(withDuration: 0.5, animations: {
            self.qouteLabel.transform = CGAffineTransform(translationX: -self.view.bounds.width, y: 0)
            self.authorLabel.transform = CGAffineTransform(translationX: -self.view.bounds.width, y: 0)
        }) { _ in
            self.qouteLabel.text = ""
            self.authorLabel.text = ""
            self.qouteLabel.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
            self.authorLabel.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
            UIView.animate(withDuration: 0.5) {
                self.qouteLabel.transform = .identity
                self.authorLabel.transform = .identity
            } completion: { _ in
                self.typeWriterEffect(quote?.q ?? "", on: self.qouteLabel) {
                    self.qouteLabel.transform = .identity
                    UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10.0, options: .curveEaseInOut, animations: {
                        self.qouteLabel.transform = CGAffineTransform(a: 0.8, b: 0, c: 0, d: 0.8, tx: 0, ty: 0)
                    }, completion: nil)
                }
                self.typeWriterEffect(" said by: \(quote?.a ?? "")" , on: self.authorLabel) {
                    self.authorLabel.transform = .identity
                    UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10.0, options: .curveEaseInOut, animations: {
                        self.authorLabel.transform = CGAffineTransform(a: 0.8, b: 0, c: 0, d: 0.8, tx: 0, ty: 0)
                    }, completion: nil)
                }
            }
        }
    }}

