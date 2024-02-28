//
//  NewsViewController.swift
//  TechNews
//
//  Created by Guilherme Mello on 18/02/24.
//

import UIKit

class NewsViewController: UITableViewController, UISearchBarDelegate {
    
    var news = [NewModel]()
    var savedNews = [NewsItem]()
    let networkManager = NetworkManager()
    var urlToSend: String?
    var titleToSend: String?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.register(UINib(nibName: K.newsCellNibName, bundle: nil), forCellReuseIdentifier: K.newsCellIdentifier)
        navigationItem.rightBarButtonItem = editButtonItem
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    //MARK: - Refresh IBAction
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        loadData(isFromRefreshButton: true)
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }

    //MARK: - tableView Data Source Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.newsCellIdentifier, for: indexPath) as! NewsCell
        
        cell.cellLabel.text = self.news[indexPath.row].title

        return cell
    }

    //MARK: - tableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        urlToSend = news[indexPath.row].url
        titleToSend = news[indexPath.row].title
        news[indexPath.row].isRead = true
        performSegue(withIdentifier: K.Segues.fromNewsToDetails, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .insert {
            let newSavedNews = NewsItem(context: context)
            newSavedNews.title = news[indexPath.row].title
            newSavedNews.url = news[indexPath.row].url
            newSavedNews.isRead = false
            self.saveNew()
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .insert
    }
    
    //MARK: - Navigation Helper method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.fromNewsToDetails {
            if let destinationVC = segue.destination as? NewsDetailsViewController {
                destinationVC.url = urlToSend
                destinationVC.newsTitle = titleToSend
            }
        }
    }
    
    //MARK: - Core Data Helper Method | Save New
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
    
    
    //MARK: - Search Bar Delegate Methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadData(isFromSearchBar: true, searchText: searchBar.text)
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadData()
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    //MARK: - Load Data Helper Function
    func loadData(isFromSearchBar: Bool = false, isFromRefreshButton: Bool = false, searchText: String? = nil) {
        news = []
        if isFromRefreshButton {
            networkManager.fetchData(withSearchParam: .normal) { [weak self] (fetchedNews) in
                guard let self = self, let news = fetchedNews else { return }
                self.news = news
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    DispatchQueue.main.async { //in rare cases it's better to chain main queues calls, this is one!!!
                        self.scrollToFirstRow()
                    }
                }
            }
        } else if isFromSearchBar {
            if let searchText = searchText {
                if searchText.count > 0 {
                    networkManager.fetchData(withSearchParam: .param(searchText)) { [weak self] (fetchedNews) in
                        guard let self = self, let news = fetchedNews else { return }
                        self.news = news
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        } else { //Call loadData without any parameter
            networkManager.fetchData(withSearchParam: .normal) { [weak self] (fetchedNews) in
                guard let self = self, let news = fetchedNews else { return }
                self.news = news
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //MARK: - Scroll Function
    func scrollToFirstRow(animated: Bool = true) {
        let indexPath = IndexPath(row: 0, section: 0)
        if self.tableView.numberOfRows(inSection: 0) > 0 {
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
        }
    }
}

