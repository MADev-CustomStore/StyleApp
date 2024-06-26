//
//  ResultsView.swift
//  StyleSense Assistant
//
//  Created by Michael Obi on 4/3/24.
//

import ParseSwift
import UIKit

class ResultsView: UIViewController {

  @IBOutlet weak var itemsTableView: UITableView!
  @IBOutlet weak var navigationBar: UINavigationItem!
  var items: [ClosetItem]!

  // MARK: Overrides

  override func viewDidLoad() {
    super.viewDidLoad()
    itemsTableView.dataSource = self
    itemsTableView.reloadData()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let cell = sender as? UITableViewCell,
       let indexPath = itemsTableView.indexPath(for: cell),
       let detailViewController = segue.destination as? DetailViewController
    {
      detailViewController.thisItem = items[indexPath.row]
    }
  }
}

// MARK: Conform ResultsView to UITableViewDataSource

extension ResultsView: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items?.count ?? .zero
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell =
      itemsTableView.dequeueReusableCell(withIdentifier: ItemCell.reusableId, for: indexPath)
      as! ItemCell
    let item = items[indexPath.item]
    cell.itemNameLabel.text = item.name
    cell.itemCategoriesLabel.text =
      item.categories == nil ? "No categories" : item.categories!.joined(separator: ", ")
    cell.closetItem = item
    return cell
  }

}
