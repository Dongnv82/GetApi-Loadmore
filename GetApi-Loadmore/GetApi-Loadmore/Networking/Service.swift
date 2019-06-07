//
//  Service.swift
//  GetApi-Loadmore
//
//  Created by Van Dong on 05/06/2019.
//  Copyright © 2019 VanDong. All rights reserved.
//

import Foundation
class DataService{
    static var share = DataService()
    var data = [Model]()
    var nextPagePath = ""
    func getDataApi(completedHandle: @escaping([Model]) -> Void) {
        guard let url = URL(string: "https://api.github.com/repositories") else {return}
        var urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 1000)
        URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data,response, error) in
            guard error == nil else {return}
            guard let data = data else {return}
            let response = response as! HTTPURLResponse
            guard response.statusCode == 200 else {return}
            //truy cap lay Link trong Header
            if let linkHeader = response.allHeaderFields["Link"] as? String{
                //tach linkHeader lam cac phan ngan cach boi dau ","
                let links = linkHeader.components(separatedBy: ",")
                var dictionary: [String:String] = [:]
                links.forEach({
                    //truy cap $0 làm 2 phan ngan cach boi dau ";"
                    let components = $0.components(separatedBy: ";")
                    //tach lay link can lay bao boc boi dau ngoac <>
                    let link = components[0].trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
                    dictionary[components[1]] = link
                })
                if let nextPagePath = dictionary[" rel=\"next\""]{
                    print("nextPagePath: \(nextPagePath)")
                    self.nextPagePath = nextPagePath
                }
            }
            do{
                let dataResutl = try JSONDecoder().decode([Model].self, from: data)
                self.data = dataResutl
                DispatchQueue.main.async {
                    completedHandle(self.data)
                }
            }catch{
                print(error.localizedDescription)
            }
            
        }).resume()
    }
    
    func loadMore(completedHandle: @escaping([Model]) -> Void) {
        guard let url = URL(string: nextPagePath) else {return}
        var urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 1000)
        URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data,response, error) in
            guard error == nil else {return}
            guard let data = data else {return}
            let response = response as! HTTPURLResponse
            guard response.statusCode == 200 else {return}
            if let linkHeader = response.allHeaderFields["Link"] as? String{
                let links = linkHeader.components(separatedBy: ",")
                var dictionary: [String:String] = [:]
                links.forEach({
                    let components = $0.components(separatedBy: ";")
                    let link = components[0].trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
                    dictionary[components[1]] = link
                })
                if let nextPagePath = dictionary[" rel=\"next\""]{
                    print("nextPagePath: \(nextPagePath)")
                    self.nextPagePath = nextPagePath
                } else {
                    self.nextPagePath = ""
                }
            }
            do{
                let dataResutl = try JSONDecoder().decode([Model].self, from: data)
                self.data += dataResutl
                DispatchQueue.main.async {
                    completedHandle(self.data)
                }
            }catch{
                print(error.localizedDescription)
            }
            
        }).resume()
    }

}
