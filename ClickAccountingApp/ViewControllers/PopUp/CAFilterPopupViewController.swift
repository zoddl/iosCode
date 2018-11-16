//
//  CAFilterPopupViewController.swift
//  ClickAccountingApp
//
//  Created by Deepak Kumar on 7/12/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

//MARK: - Custom Protocol for Filter
protocol FilterDelegate: class {
    
    func callFilter(filterType: String)
    
}


class CAFilterPopupViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate {
    
    weak var delegate: FilterDelegate?
    var hideAlphabetOption  = Bool()
    
    @IBOutlet var tableView: UITableView!
    var filterArray : [String] = []
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialMethod()
        filterArray = ["None","By Amount","By Count","By Uses","By Alphabet"]
        if(hideAlphabetOption){
            filterArray = ["None","By Amount","By Count","By Uses"]
        }
    }
    
    // MARK: - Helper methods
    func initialMethod(){

        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.layer.cornerRadius = 10
        self.tableView.clipsToBounds = true
        
        // For registereing nib
        self.tableView.register(UINib(nibName: "CAFilterTableViewCell", bundle: nil), forCellReuseIdentifier: "CAFilterTableViewCell")
        self.tableView.tableFooterView = UIView.init()
    }
    
    
    // MARK: - UITableViewDataSource and UITableViewDelegate Methods.
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return filterArray.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CAFilterTableViewCell") as! CAFilterTableViewCell
        cell.filterTitleLabel.text = filterArray[indexPath.row]
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return (CGFloat(Int(tableView.frame.size.height) / filterArray.count))
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.dismiss(animated: true, completion: nil)
        delegate?.callFilter(filterType: filterArray[indexPath.row])
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Memory management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
