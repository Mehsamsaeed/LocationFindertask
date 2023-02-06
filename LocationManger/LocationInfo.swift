//
//  Coordinates.swift
//  LocationManger
//
//  Created by Mehsam Saeed on 04/02/2023.
//

import Foundation
import CoreLocation
struct LocationInfo:Identifiable{
    var id:String = UUID().description
    var current:CLLocation
    var last:CLLocation
    var time:Date
    var isCollected:Bool = false
}
