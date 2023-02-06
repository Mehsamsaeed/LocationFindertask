//
//  LocaitonItem.swift
//  LocationManger
//
//  Created by Mehsam Saeed on 04/02/2023.
//

import SwiftUI
import CoreLocation
struct LocationView: View {
    var model: LocationInfo

    var body: some View {
        
        ZStack{
            HStack{
                VStack(alignment: .leading){
                    Text("lat: \(model.current.coordinate.latitude)")
                    
                    Text("lng: \(model.current.coordinate.longitude)")
                }
                Spacer()
                VStack(alignment: .leading){
                    Text("Time: \(model.time ,format: Date.FormatStyle(date: .numeric, time:.standard))")
                    Text("speed \(model.last.distance(from: model.current) / (model.current.timestamp.timeIntervalSince(model.last.timestamp))) ")
                    
                }
            }
        }
        
    }
}


