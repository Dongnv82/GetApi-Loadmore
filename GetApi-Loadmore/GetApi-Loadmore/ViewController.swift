//
//  ViewController.swift
//  GetApi-Loadmore
//
//  Created by Van Dong on 05/06/2019.
//  Copyright © 2019 VanDong. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        getDataService()
        // Do any additional setup after loading the view.
    }
    

    func getDataService() {
        DataService.share.getDataApi{(data) in
            self.myTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataService.share.data.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        cell.id.text = String(DataService.share.data[indexPath.row].id)
        cell.name.text = DataService.share.data[indexPath.row].name
        cell.url.text = DataService.share.data[indexPath.row].url
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //neu co next link thi thuc hien loadmore
        guard DataService.share.data.count != 0 else {return}
        // khi indexPath load duoc 9/10 du lieu thi thuc hien loadmore.tranh khi load het du lieu roi loadmore se lag
        if indexPath.row == Int(Double(DataService.share.data.count) * 0.9)  {
            
            DataService.share.loadMore { [unowned self] (_) in
                self.myTableView.reloadData()
            }
        }
    }

}

