//
//  ProductsViewController.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/11.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import UIKit
import Apollo

enum Section: CaseIterable {
    case list
}

enum Row: Hashable {
    case item(ProductListFragment)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .item(let product):
            hasher.combine(product.id)
        }
    }
}

extension Row: Equatable {
    static func == (lhs: Row, rhs: Row) -> Bool {
        switch (lhs, rhs) {
        case (.item(let leftProductListFragment), .item(let rightProductListFragment)):
            return leftProductListFragment.id == rightProductListFragment.id
        }
    }
}

class ProductsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private lazy var dataSource = setupDataSource()
    
    private var products: [ProductListQuery.Data.ProductList.ItemList]? {
        didSet {
            if let products = products {
                updateDataSource(with: products)
            }
        }
    }
    
    override func viewDidLoad() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
        
        tableView.dataSource = dataSource
        fetchProducts()
    }
}

extension ProductsViewController {
    private func setupDataSource() -> UITableViewDiffableDataSource<Section, Row> {
        return UITableViewDiffableDataSource(tableView: self.tableView) { (tableView, indexPath, row) -> UITableViewCell? in
            switch row{
            case .item(let product):
                let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
                cell.textLabel?.text = product.nameKo
                return cell
            }
        }
    }
}

extension ProductsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

extension ProductsViewController {
    private func fetchProducts() {
        let _ = Apollo.shared.client.fetch(query: ProductListQuery(id_list: nil)) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let graphQLResult):
                self.products = graphQLResult.data?.productList.itemList
                print(self.products)
            case .failure(let error):
                NSLog("Error while fetching query: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateDataSource(with products: [ProductListQuery.Data.ProductList.ItemList]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections(Section.allCases)
        
        var rows: [Row] = []
        products.forEach { rows.append(.item($0.fragments.productListFragment)) }
        snapshot.appendItems(rows, toSection: .list)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
