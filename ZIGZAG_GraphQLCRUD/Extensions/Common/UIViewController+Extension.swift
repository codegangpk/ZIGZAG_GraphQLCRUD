//
//  UIViewController+Extension.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/13.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import UIKit

extension UIViewController {
    func showDeleteConfirm(completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "%L%: 이 상품을 삭제하시겠습니까?",
            message: "%L%: 삭제한 상품은 복구할 수 없습니다.",
            preferredStyle: .actionSheet
        )
        
        let noAction = UIAlertAction(title: "%L%: 취소", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "%L%: 삭제하기", style: .default, handler: { (_) in
            completion()
        })
        alert.addAction(noAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func showEndEditAlert(title: String) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        let discardAction = UIAlertAction(title: "%L%: 변경사항 폐기", style: .default) { [weak self] (_) in
            guard let self = self else { return }
            
            self.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "%L%: 계속 편집하기", style: .cancel)
        alertController.addAction(discardAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showNetworkErrorAlert() {
        let alert = UIAlertController(
            title: "%L%: 이런...",
            message: "%L%: 네트워크에 접근하는 중 에러가 발생했습니다. 다시 시도해주세요.",
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}

extension UIViewController {
    func showLoader() {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.startAnimating()
        view.addSubview(activityIndicatorView)
        navigationController?.view.isUserInteractionEnabled = false
        
        activityIndicatorView.center = view.center
    }
    
    func hideLoader() {
        view.subviews.forEach {
            if $0 is UIActivityIndicatorView {
                $0.removeFromSuperview()
            }
        }
        navigationController?.view.isUserInteractionEnabled = true
    }
}
