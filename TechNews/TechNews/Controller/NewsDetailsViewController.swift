//
//  NewsDetailsViewController.swift
//  TechNews
//
//  Created by Guilherme Mello on 18/02/24.
//

import UIKit
import WebKit
import CoreData

class NewsDetailsViewController: UIViewController {
    
    @IBOutlet weak var webKitView: WKWebView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var url: String?
    var newsTitle: String?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - Class LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if let safeUrlString = url {
            if let safeUrl = URL(string: safeUrlString) {
                webKitView.load(URLRequest(url: safeUrl))
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.saveButton.isHidden = false
    }
    
    //MARK: - IBAction methods
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        let newSavedNews = NewsItem(context: context)
        newSavedNews.title = self.newsTitle
        newSavedNews.url = self.url
        newSavedNews.isRead = false
        self.saveNew()
    }
    
    //MARK: - CoreData helper methods
    func saveNew() {
        do {
            try context.save()
            let alert = UIAlertController(title: "Saved", message: "This news item has been saved.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
        } catch {
            let alert = UIAlertController(title: "Error", message: "Could not save the news item. \(error)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
        }
    }
}
