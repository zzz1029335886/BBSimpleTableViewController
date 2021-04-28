//
//  ViewController.swift
//  SimpleTableViewController
//
//  Created by zerry on 2021/4/28.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let rightBarButtonItem0 = UIBarButtonItem.init(title: "Simple", style: .done, target: self, action: #selector(nextPage))
        let rightBarButtonItem1 = UIBarButtonItem.init(title: "AddOne", style: .done, target: self, action: #selector(addOne))
        self.navigationItem.rightBarButtonItems = [rightBarButtonItem1,rightBarButtonItem0]
    }
    
    @objc
    func addOne() {
        let model = TestModel.init()
        LocalStorageManager<TestModel>().add(model)
    }

    @objc
    func nextPage() {
        let array = LocalStorageManager<TestModel>().array ?? []
        let config = SimpleTableViewConfig(rows: array, cellType: TestTableViewCell.self)
        
        let simpleTableViewController = SimpleTableViewController(config, modelType: TestModel.self, cellType: TestTableViewCell.self) { (con) in
            con.tableView.separatorStyle = .none
            con.tableView.backgroundColor = .white
            con.reload()
        } setCell: { (model, cell, _) in
            cell.model = model
        } clickCell: { (model, cell, _) in
            
        }
        
        self.navigationController?.pushViewController(simpleTableViewController, animated: true)
    }
    
}

