//
//  ProductViewController.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/13.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import UIKit
import Apollo

private enum Section: CaseIterable {
    case basicInfo
    case descriptionInfo
    case deleteProduct
    
    var title: String? {
        switch self {
        case .descriptionInfo:  return "%L%: 상세 설명"
        default:                return nil
        }
    }
}

private enum Row: Hashable {
    case nameKorean
    case nameEnglish
    case price
    case supplier
    
    case descriptionKorean
    
    case delete
}

private class TableViewDiffableDataSource: UITableViewDiffableDataSource<Section, Row> {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.snapshot().sectionIdentifiers[section].title
    }
}

class ProductViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private lazy var dataSource = setupDataSource()
    
    private var productId: String
    private var product: Product? {
        didSet {
            if let product = product {
                updateDataSource(with: product)
            }
        }
    }
    
    init(productId: String) {
        self.productId = productId
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupNavigationItem()
        
        tableView.register(BasicTableViewCell.nib, forCellReuseIdentifier: BasicTableViewCell.reuseIdentifier)
        tableView.register(TextViewTableViewCell.nib, forCellReuseIdentifier: TextViewTableViewCell.reuseIdentifier)
        tableView.dataSource = dataSource
        
        let refreshControl = UIRefreshControl()
        refreshControl.layer.zPosition = -1
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidProductRequestUpdated(_:)), notification: .didProductRequestUpdated)
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidUpdateProductRequestUpdated(_:)), notification: .didUpdateProductRequestUpdated)
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidDeleteProductRequestUpdated(_:)), notification: .didDeleteProductRequestUpdated)
        
        updateDataSource(with: product)
        fetchProduct(with: productId)
    }
}

extension ProductViewController {
    private func setupDataSource() -> TableViewDiffableDataSource {
        return TableViewDiffableDataSource(tableView: self.tableView) { [weak self] (tableView, indexPath, row) -> UITableViewCell? in
            guard let self = self else { return nil }
            
            switch row {
            case .descriptionKorean:
                let cell = tableView.dequeueReusableCell(withIdentifier: TextViewTableViewCell.reuseIdentifier, for: indexPath) as! TextViewTableViewCell
                cell.textView.text = self.product?.descriptionKo ?? "%L%: (상세 설명 미제공)"
                cell.textViewHeightLayoutConstraint.constant = ceil(cell.textView.sizeThatFits(CGSize(width: cell.textView.frame.width, height: .infinity)).height)
                cell.isUserInteractionEnabled = false
                return cell
            case .delete:
                let cell = tableView.dequeueReusableCell(withIdentifier: BasicTableViewCell.reuseIdentifier, for: indexPath) as! BasicTableViewCell
                cell.label?.text = "%L%: 제품 삭제하기"
                cell.label?.textColor = .red
                cell.label?.textAlignment = .center
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: BasicTableViewCell.reuseIdentifier, for: indexPath) as! BasicTableViewCell
                
                cell.isUserInteractionEnabled = false
                
                if case .nameKorean = row {
                    cell.label.text = self.product?.nameKo
                } else if case .nameEnglish = row {
                    cell.label.text = self.product?.nameEn?.isEmpty == false ? self.product?.nameEn : "%L%: (영어 상품명 미제공)"
                } else if case .price = row {
                    cell.label.text = self.product?.price?.priceKRW ?? "%L%: (가격 미제공)"
                } else if case .supplier = row {
                    cell.label.text = self.product?.supplier?.name
                }
                return cell
            }
        }
    }
}

extension ProductViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let row = dataSource.itemIdentifier(for: indexPath) else { return }
        
        if case .delete = row {
            let deleteProductInput = DeleteProductInput(id: productId)
            ZAPINotificationCenter.post(notification: .didDeleteProductRequested, userInfo: [.deleteProductInput: deleteProductInput])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

extension ProductViewController {
    private func fetchProduct(with productId: String) {
        ZAPINotificationCenter.post(notification: .didProductRequested, object: self, userInfo: [.productId: productId])
    }
    
    private func updateDataSource(with product: Product?) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.deleteAllItems()

        if product != nil {
            snapshot.appendSections(Section.allCases)
            
            snapshot.appendItems([.nameKorean, .nameEnglish, .price, .supplier], toSection: .basicInfo)
            snapshot.appendItems([.descriptionKorean], toSection: .descriptionInfo)
            snapshot.appendItems([.delete], toSection: .deleteProduct)
        }
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func setupNavigationItem() {
        navigationItem.title = "%L%: 상품 상세"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(onEdit))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
    }
}

extension ProductViewController {
    @objc private func onEdit() {
        guard let product = product else { return }
        
        let productViewController = ProductFormViewController(mode: .edit(product))
        let productNavigationController = UINavigationController(rootViewController: productViewController)
        navigationController?.present(productNavigationController, animated: true, completion: nil)
    }
    
    @objc private func refreshData(_ refreshControl: UIRefreshControl) {
        fetchProduct(with: productId)
    }
}

extension ProductViewController {
    @objc private func onDidProductRequestUpdated(_ notification: Notification) {
        guard let state = notification.zAPIState else { return }
        
        switch state {
        case .loading:
            tableView.tableFooterView = TableFooterLoadingView()
        case .success(let product):
            guard let product = product as? Product else { return }
            
            tableView.tableFooterView = nil
            tableView.refreshControl?.endRefreshing()
            
            self.product = product
        case .failed:
            tableView.tableFooterView = nil
            tableView.refreshControl?.endRefreshing()
            showNetworkErrorAlert()
        default:
            break
        }
    }
    
    @objc private func onDidUpdateProductRequestUpdated(_ notification: Notification) {
        guard let state = notification.zAPIState else { return }
        
        if case .success(let product) = state {
            guard let product = product as? Product else { return }
            
            self.product = product
        }
    }
    
    @objc private func onDidDeleteProductRequestUpdated(_ notification: Notification) {
        guard let state = notification.zAPIState else { return }
            
        switch state {
        case .loading:
            showLoader()
        case .success:
            hideLoader()
            if let navigationView = navigationController?.view {
                HudView.hud(inView: navigationView, text: "삭제 완료", animated: true) { [weak self] in
                    guard let self = self else { return }
                    
                    self.navigationController?.popViewController(animated: true)
                }
            }
        case .failed:
            hideLoader()
            showNetworkErrorAlert()
        default:
            break
        }
    }
}
