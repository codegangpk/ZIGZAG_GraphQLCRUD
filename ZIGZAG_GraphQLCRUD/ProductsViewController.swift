//
//  ProductsViewController.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/11.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import UIKit

enum Section: CaseIterable {
    case list
}

enum Row: Hashable {
    case item
}

class ProductsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var dataSource = setupDataSource()
    
    override func viewDidLoad() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
        
        tableView.dataSource = dataSource
        update()
    }
}

extension ProductsViewController {
    private func setupDataSource() -> UITableViewDiffableDataSource<Section, Row> {
        return UITableViewDiffableDataSource(tableView: self.tableView) { (tableView, indexPath, row) -> UITableViewCell? in
            switch row{
            case .item:
                let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "Hi"
                return cell
            }
        }
    }
    
    private func update() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections(Section.allCases)
        
        snapshot.appendItems([.item], toSection: .list)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension ProductsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}
