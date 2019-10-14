//
//  SelectSupplierViewController.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/11.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import UIKit

private enum Section: CaseIterable {
    case list
}

private enum Row: Hashable {
    case item(Supplier)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .item(let supplier):
            hasher.combine(supplier.id)
        }
    }
}

extension Row: Equatable {
    static func == (lhs: Row, rhs: Row) -> Bool {
        switch (lhs, rhs) {
        case (.item(let leftSupplier), .item(let rightSupplier)):
            return leftSupplier.id == rightSupplier.id
        }
    }
}

class SelectSupplierViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private lazy var dataSource = setupDataSource()
    
    private let completion: ((SelectSupplierViewController, Supplier) -> Void)
    
    private var suppliers: [Supplier] = [] {
        didSet {
            updateDataSource(with: suppliers)
        }
    }
    
    private var selectedSupplier: Supplier?
    
    init(selectedSupplier: Supplier?, completion: @escaping (SelectSupplierViewController, Supplier) -> Void) {
        self.selectedSupplier = selectedSupplier
        self.completion = completion
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupNavigationItem()
        
        view.backgroundColor = tableView.backgroundColor
        
        tableView.register(BasicTableViewCell.nib, forCellReuseIdentifier: BasicTableViewCell.reuseIdentifier)
        tableView.dataSource = dataSource
        tableView.addRefreshControl(target: self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidSupplierListRequestUpdated(_:)), notification: .didSupplierListRequestUpdated)
        
        updateDataSource()
        fetchSuppliers()
    }
}

extension SelectSupplierViewController {
    private func setupDataSource() -> UITableViewDiffableDataSource<Section, Row> {
        return UITableViewDiffableDataSource(tableView: self.tableView) { [weak self] (tableView, indexPath, row) -> UITableViewCell? in
            guard let self = self else { return nil }
            
            switch row {
            case .item(let supplier):
                let cell = tableView.dequeueReusableCell(withIdentifier: BasicTableViewCell.reuseIdentifier, for: indexPath) as! BasicTableViewCell
                cell.label?.text = supplier.name
                if supplier.id == self.selectedSupplier?.id {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
                return cell
            }
        }
    }
}

extension SelectSupplierViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let row = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch row {
        case .item(let supplier):
            selectedSupplier = supplier
            updateDataSource(with: suppliers)
            completion(self, supplier)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

extension SelectSupplierViewController {
    private func fetchSuppliers() {
        ZAPINotificationCenter.post(notification: .didSupplierListRequested)
    }
    
    private func updateDataSource(with suppliers: [Supplier] = []) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.deleteAllItems()
        
        snapshot.appendSections(Section.allCases)
        
        var rows: [Row] = []
        suppliers.forEach { rows.append(.item($0)) }
        snapshot.appendItems(rows, toSection: .list)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func setupNavigationItem() {
        navigationItem.title = "%L%: 공급사 선택"
    }
    
    @objc private func refreshData(_ refreshControl: UIRefreshControl) {
        fetchSuppliers()
    }
}

extension SelectSupplierViewController {
    @objc private func onDidSupplierListRequestUpdated(_ notification: Notification) {
        guard let state = notification.zAPIState else { return }
        
        switch state {
        case .loading:
            tableView.isScrollEnabled = false
        case .success(let suppliers):
            guard let suppliers = suppliers as? [Supplier] else { return }
            
            tableView.isScrollEnabled = true
            tableView.refreshControl?.endRefreshing()
            self.suppliers = suppliers
        case .failed:
            tableView.isScrollEnabled = true
            tableView.refreshControl?.endRefreshing()
            showNetworkErrorAlert()
        default:
            break
        }
    }
}
