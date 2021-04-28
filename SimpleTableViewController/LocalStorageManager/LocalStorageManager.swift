//
//  LocalStorageManager.swift
//  BrainBank
//
//  Created by zerry on 2021/4/14.
//  Copyright © 2021 yoao. All rights reserved.
//

import UIKit
import HandyJSON

class LocalStorageModel: NSObject, HandyJSON {
    fileprivate
    var _timestamp = String.init(format: "%.0f", Date().timeIntervalSince1970)
    
    override required init() {
        
    }
}

struct LocalStorageManager<Element: LocalStorageModel> {
    
    fileprivate
    var singleClassName : String{
        return NSStringFromClass(Element.self)
    }
    
    fileprivate
    var arrayClassName : String{
        return NSStringFromClass(Element.self) + "Array"
    }
    
    var single: Element?{
        let string = UserDefaults.standard.object(forKey: singleClassName) as? String
        return Element.deserialize(from: string)
    }
    
    var array: [Element]?{
        guard let jsonArray = UserDefaults.standard.array(forKey: arrayClassName) as? [[String: Any]] else { return nil }
        return [Element].deserialize(from: jsonArray) as? [Element]
    }
    
    func save(_ element: Element) {
        guard let jsonString = element.toJSONString() else { return }
        UserDefaults.standard.set(jsonString, forKey: singleClassName)
    }
    
    fileprivate
    func saveArray(_ elements: [Element]){
        let jsonArray = elements.toJSON()
        UserDefaults.standard.set(jsonArray, forKey: arrayClassName)
    }
    
    func add(_ element: Element){
        var array = self.array ?? []
        array.append(element)
        saveArray(array)
    }
    
    @discardableResult
    func remove(_ element: Element) -> [Element]{
        guard var array = self.array else { return [] }
        array = array.filter({ (oldElement) -> Bool in
            return element._timestamp != oldElement._timestamp
        })
        saveArray(array)
        return array
    }
    
    func removeAll() {
        saveArray([])
    }
}
