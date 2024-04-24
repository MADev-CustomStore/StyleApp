//
//  ItemCell.swift
//  StyleSense Assistant
//
//  Created by Michael Obi on 4/3/24.
//

import UIKit

class ItemCell: UITableViewCell {

  @IBOutlet weak var itemNameLabel: UILabel!
  @IBOutlet weak var itemCategoriesLabel: UILabel!
  var closetItem: ClosetItem!
  static let reusableId = "ItemCell"

  // MARK: Overrides

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

  }

}
