//
//  ContentView.swift
//  LocationManger
//
//  Created by Mehsam Saeed on 04/02/2023.
//

import SwiftUI
import Combine
import CoreLocation
struct ContentView: View {
    @StateObject var locationManger = LocationManger.shared
    @State var store: Set<AnyCancellable> = []
    @State var list:[LocationInfo] = []
    @State var lastLocation: CLLocation?
    @State var startTime:Date = Date()
    @State var time:String = ""
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ZStack{
                ScrollView{
                    VStack(spacing: 16){
                        ForEach(0..<list.count, id: \.self) {index in
                            LocationView(model: list[index])
                                .padding([.leading,.trailing],15)
                        }
                    }
                    
                    
                }
            }
            .navigationTitle(time)
            .toolbar {
                if !list.isEmpty{
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Create file") {
                            if let path = createCSV(){
                                self.share(items: [path])
                            }
                           
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Start Observing") {
                        startTime = Date()
                        locationManger.requestLocationUpdates()
                        self.startTimer()
                    }
                }
            }
        }
        
        
        
        .onAppear {
            observeCoordinateUpdates()
            observeAuthorizationStatus()
            self.stopTimer()
            
        }
        .onReceive(timer) { _ in
            let elapsed = Date().timeIntervalSince(startTime)
            let calculatedTime = secondsToHoursMinutesSeconds(Int(elapsed))
            time = "\(calculatedTime.0) : \(calculatedTime.1) : \(calculatedTime.2)"
        }
    }
    
    func observeCoordinateUpdates() {
        locationManger.locationCoordinates
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("Handle \(completion) for error and finished subscription.")
            } receiveValue: { location in
                if let last = lastLocation{
                    let location = LocationInfo(current: location, last: last, time: last.timestamp)
                    self.list.append(location)
                }
                lastLocation = location
                
            }
            .store(in: &store)
    }
    
    func observeAuthorizationStatus() {
        locationManger.userPermissionStatus
            .receive(on: DispatchQueue.main)
            .sink {_ in
                print("Handle access denied event, possibly with an alert.")
            }
            .store(in: &store)
    }
    
    func stopTimer() {
        self.timer.upstream.connect().cancel()
    }
    
    func startTimer() {
        self.timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    
    
    // MARK: CSV file creating
    func createCSV() -> URL? {
        let fileName = "Tasks.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        var csvText = "Location info\n"
        
        
        
        for location in list {
            let coordinate = location.current.coordinate
            let newLine = "latitude: \(coordinate.latitude),\("longitude: ")\(coordinate.longitude),\("Speed: ")\(location.current.speed)\n"
            csvText.append(newLine)
        }
        
        do {
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
        print(path ?? "not found")
        return path
    }
    
    @discardableResult
    func share(
        items: [Any],
        excludedActivityTypes: [UIActivity.ActivityType]? = nil
    ) -> Bool {
        guard let source = UIApplication.shared.windows.last?.rootViewController else {
            return false
        }
        let vc = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        vc.excludedActivityTypes = excludedActivityTypes
        vc.popoverPresentationController?.sourceView = source.view
        source.present(vc, animated: true)
        return true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
