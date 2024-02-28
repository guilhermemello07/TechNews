//
//  SavedNewsViewController.swift
//  TechNews
//
//  Created by Guilherme Mello on 18/02/24.
//

import UIKit
import CoreData

class SavedNewsViewController: UITableViewController {
    
    var urlToSend: String?
    var titleToSend: String?
    var news = [NewsItem]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: K.newsCellNibName, bundle: nil), forCellReuseIdentifier: K.newsCellIdentifier)
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNews()
    }
    
    //MARK: - tableView Data Source Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.savedNewsCellIdentifier, for: indexPath) as! NewsCell
        let newsItem = news[indexPath.row]
        cell.cellLabel.text = newsItem.title
        return cell
    }

    //MARK: - tableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        urlToSend = news[indexPath.row].url
        titleToSend = news[indexPath.row].title
        news[indexPath.row].isRead = true
        performSegue(withIdentifier: K.Segues.fromSavedToDetails, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let newToDelete = news[indexPath.row]
            news.remove(at: indexPath.row)
            context.delete(newToDelete)
            saveNews()
            DispatchQueue.main.async {
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    //MARK: - Navigation helper method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.fromSavedToDetails {
            if let destinationVC = segue.destination as? NewsDetailsViewController {
                destinationVC.url = urlToSend
                destinationVC.newsTitle = titleToSend
                destinationVC.saveButton.isHidden = true
            }
        }
    }
    
    //MARK: - Core Data Helper Methods
    func saveNews() {
        do {
            try context.save()
        } catch {
            print("Error saving data to CoreData with: \(error)")
        }
    }
    
    func loadNews() {
        let request: NSFetchRequest<NewsItem> = NewsItem.fetchRequest()
        do {
            news = try context.fetch(request)
        } catch {
            print("Error fetching data from CoreData with: \(error)")
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
