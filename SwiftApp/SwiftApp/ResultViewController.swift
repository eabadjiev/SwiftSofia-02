//
//  ResultViewController.swift
//  SwiftApp
//
//  Created by Emo Abadjiev on 9/28/16.
//  Copyright © 2016 Tumba Solutions. All rights reserved.
//

import UIKit

class ResultViewController: UITableViewController {
    
    var items: [[String: Any]] = []

//#pragma mark Table Data Source/Delegate
    
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
        return items.count
    }

}
