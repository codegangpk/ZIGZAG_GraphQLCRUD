//
//  ProductsViewController.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/11.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import UIKit
import Apollo

private enum Section: CaseIterable {
    case list
}

private enum Row: Hashable {
    case item(Product)
    
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
        case (.item(let leftProduct), .item(let rightProduct)):
            return leftProduct.id == rightProduct.id
        }
    }
}

class ProductsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var dataSource = setupDataSource()
    
    private var products: [Product] = [] {
        didSet {
            updateDataSource(with: products)
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        setupNavigationItem()
        
        tableView.register(ProductTableViewCell.nib, forCellReuseIdentifier: ProductTableViewCell.reuseIdentifier)
        tableView.dataSource = dataSource
        
        
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidProductListStateUpdated(_:)), notification: .didProductListRequestUpdated)
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidCreateProductRequestUpdated(_:)), notification: .didCreateProductRequestUpdated)
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidDeleteProductRequestUpdated(_:)), notification: .didDeleteProductRequestUpdated)
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidUpdateProductRequestUpdated(_:)), notification: .didUpdateProductRequestUpdated)
        
        updateDataSource(with: products)
        fetchProducts()
    }
}

extension ProductsViewController {
    private func setupDataSource() -> UITableViewDiffableDataSource<Section, Row> {
        return UITableViewDiffableDataSource(tableView: tableView) { (tableView, indexPath, row) -> UITableViewCell? in
            switch row {
            case .item(let product):
                let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.reuseIdentifier, for: indexPath) as! ProductTableViewCell
                cell.configure(with: product)
                return cell
            }
        }
    }
}

extension ProductsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let row = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch row {
        case .item(let product):
            let productViewController = ProductViewController(mode: .view(product))
            navigationController?.pushViewController(productViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

extension ProductsViewController {
    private func fetchProducts() {
        ZAPINotificationCenter.post(notification: .didProductListRequested)
    }

    private func updateDataSource(with products: [Product]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.deleteAllItems()
        
        snapshot.appendSections(Section.allCases)
        
        var rows: [Row] = []
        products.sorted(by: { $0.dateCreated?.compare($1.dateCreated ?? Date(timeIntervalSince1970: 0)) == .orderedDescending }).forEach { rows.append(.item($0)) }
        
        snapshot.appendItems(rows, toSection: .list)
        
        dataSource.defaultRowAnimation = .fade
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func setupNavigationItem() {
        navigationItem.title = "%L%: 상품 목록"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAdd))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
    }
}

extension ProductsViewController {
    @objc private func onAdd() {
        let productViewController = ProductViewController(mode: .add)
        let productNavigationController = UINavigationController(rootViewController: productViewController)
        navigationController?.present(productNavigationController, animated: true, completion: nil)
    }
}

extension ProductsViewController {
    @objc private func onDidProductListStateUpdated(_ notification: Notification) {
        guard let data = notification.userInfo else { return }
        guard let state = data[ZAPINotificationCenter.UserInfoKey.state] as? ZAPIManager.State else { return }
        guard let products = data[ZAPINotificationCenter.UserInfoKey.products] as? [Product] else { return }
        
        self.products = products
    }
    
    @objc private func onDidCreateProductRequestUpdated(_ notification: Notification) {
        guard let data = notification.userInfo else { return }
        guard let product = data[ZAPINotificationCenter.UserInfoKey.product] as? Product else { return }
        
        print("created Product: \(product)")
        fetchProducts()
    }
    
    @objc private func onDidUpdateProductRequestUpdated(_ notification: Notification) {
        guard let data = notification.userInfo else { return }
        guard let product = data[ZAPINotificationCenter.UserInfoKey.product] as? Product else { return }
        
        fetchProducts()
    }
    
    @objc private func onDidDeleteProductRequestUpdated(_ notification: Notification) {
        guard let data = notification.userInfo else { return }
        guard let product = data[ZAPINotificationCenter.UserInfoKey.product] as? Product else { return }
        
        fetchProducts()
    }
}
