//
//  RepoViewController.swift
//  SwiftApp
//
//  Created by Emo Abadjiev on 9/28/16.
//  Copyright © 2016 Tumba Solutions. All rights reserved.
//

import UIKit

class RepoViewController: UITableViewController, UISearchResultsUpdating {

    typealias JsonType = [String: Any]
    var items: [JsonType] = []
    var searchController: UISearchController!
    var resultViewController: ResultViewController!
    @IBOutlet weak var editButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        resultViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResultViewController") as! ResultViewController
        resultViewController.tableView.delegate = self
        searchController = UISearchController(searchResultsController: resultViewController)
        self.searchController.searchResultsUpdater = self;
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.title = "My Repos \(self.items.count)"
        self.editButton.isEnabled = self.items.count != 0;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier")!
        let item = self.items[indexPath.row]
        guard let name = item["name"] as? String,
            let description = item["description"] as? String else {
                cell.backgroundColor = UIColor.red
                return cell
        }
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = description
        cell.backgroundColor = UIColor.yellow
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.tableView != tableView {
            // search table selection
            let item = resultViewController.items[indexPath.row]
            self.items.append(item)
            self.tableView.reloadData()
            self.title = "My Repos \(self.items.count)"
            self.editButton.isEnabled = self.items.count != 0
            
            self.searchController.dismiss(animated: true, completion: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        self.items.remove(at: indexPath.row)
        self.title = "My Repos \(self.items.count)"
        self.editButton.isEnabled = self.items.count != 0
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {
            return
        }
        
        executeSearchQuery(query: searchText, handler: { json, error in
            guard let items = json else {
                return
            }
            self.resultViewController.items.removeAll()
            self.resultViewController.items.append(contentsOf: items)

            DispatchQueue.main.async {
                self.resultViewController.tableView.reloadData()
            }
        })
    }

    @IBAction func didTapEdit(_ sender: AnyObject) {
        let newTitle = self.tableView.isEditing ? "Edit" : "Done"
        editButton.title = newTitle
        self.tableView.setEditing(!self.tableView.isEditing, animated:true)
    }
    
    func executeSearchQuery(query: String, handler:@escaping ([[String: Any]]?, Error?) -> Void) {
        let param = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    //    NSString *encodedQuery = [query stringByAddingPercentEncodingForFormData:NO];
        let url = URL(string: "https://api.github.com/search/repositories?q=\(param)")!
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        let session = URLSession.shared
        session.dataTask(with: req, completionHandler: { data, res, err in
            guard let d = data,
                let json = try? JSONSerialization.jsonObject(with: d) as! [String: Any],
                let items = json["items"] as? [[String: Any]] else {
                handler(nil, err)
                return
            }

            handler(items, nil)
        }).resume()
    }
    
//    - (void)executeStatsQuery:(NSString*) fullName handler:(void (^)(NSDictionary *json, NSError * error)) handler {
//    NSString *requestToAPI = [NSString stringWithFormat:@"https://api.github.com/repos/%@/stats/participation", fullName];
//    NSURL *url = [NSURL URLWithString:requestToAPI];
//    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
//    req.HTTPMethod = @"GET";
//    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    NSURLSession* session = [NSURLSession sharedSession];
//    
//    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//    NSLog(@"Got response %@ with error %@.\n", response, error);
//    if (data) {
//    NSError *jsonError;
//    NSDictionary *json = [NSJSONSerialization
//    JSONObjectWithData:data
//    options:0
//    error:&jsonError];
//    
//    handler(json, nil);
//    } else {
//    handler(nil, error);
//    }
//    }] resume];
//    }


}

