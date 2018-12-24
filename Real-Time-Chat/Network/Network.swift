//
//  Network.swift
//  Real-Time-Chat
//
//  Created by Chittapon Thongchim on 22/12/2561 BE.
//  Copyright © 2561 Chittapon Thongchim. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

struct Network {
    
    private let bag = DisposeBag()
    
    func request(url: String) -> Observable<Data> {
        
        return Observable.create({ (observer) -> Disposable in
            
            let task = Alamofire.request(url).responseData(completionHandler: { (response) in
                
                switch response.result {
                    
                case .success(let data):
                    observer.onNext(data)
                    
                case .failure(let error):
                    observer.onError(error)
                    
                }
            })
            return Disposables.create {
                task.cancel()
            }
        })
    }
}
