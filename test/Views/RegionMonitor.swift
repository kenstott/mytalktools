import UIKit
import CoreLocation
import MapKit
import UIKit
import SwiftUI

private var regionMonitor =  RegionMonitorController()
struct RegionMonitor: UIViewControllerRepresentable {
    
    @Binding var enteredRegion: UInt
    @State private var regionCells = [Content]()
    @Environment(\.presentationMode) private var presentationMode
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<RegionMonitor>) -> RegionMonitorController {
        regionMonitor.parentMonitor = self
        context.coordinator.setDelegate()
        return regionMonitor
    }
    
    func updateUIViewController(_ uiViewController: RegionMonitorController, context: UIViewControllerRepresentableContext<RegionMonitor>) {
        
    }
    
    func startMonitor() {
        regionMonitor.startMonitor()
    }
    
    final class Coordinator: NSObject, UINavigationControllerDelegate, CLLocationManagerDelegate {
        
        var parent: RegionMonitor
        
        init(_ parent: RegionMonitor) {
            self.parent = parent
        }
        
        func setDelegate() {
            regionMonitor.locationManager.delegate = self
        }
        
        func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
            self.parent.enteredRegion = UInt(region.identifier) ?? 0
            let content = UNMutableNotificationContent()
            content.title = "Entered Monitored Area"
            content.subtitle = "There is a communication board you can use."
            content.sound = UNNotificationSound.default
            content.userInfo = ["boardId": UInt(region.identifier) ?? 0]
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request)
        }
        func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
            self.parent.enteredRegion = 0
        }
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
                print("Location update failed with error: \(error.localizedDescription)")
            }
    }
}

class RegionMonitorController: UIViewController {
    
    let locationManager = CLLocationManager()
    var regionCells = [Content]()
    var parentMonitor: RegionMonitor? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.stopMonitoringVisits()
    }
    
    func startMonitor() {
        let regionCells = Board.getGeoMonitorBoards()
        if regionCells.count > 0 {
            locationManager.requestAlwaysAuthorization()
            for content in regionCells {
                let regionVars = content.externalUrl.split(separator: "/")
                guard let latitude = Double(regionVars[1]) else { return }
                guard let longitude = Double(regionVars[2]) else { return }
                var radius = 500.0
                if (regionVars.count == 5) {
                    guard let deltaLatitude = Double(regionVars[3]) else { return }
                    guard let deltaLongitude = Double(regionVars[4]) else { return }
                    let metersPerMapPoint = MKMetersPerMapPointAtLatitude(latitude)
                    let deltaMetersLatitude = deltaLatitude * metersPerMapPoint
                    let deltaMetersLongitude = deltaLongitude * metersPerMapPoint
                    radius = Double.maximum(deltaMetersLatitude, deltaMetersLongitude) * 1000 * 1000
                }
                let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), radius: radius, identifier: "\(content.link)")
                locationManager.startMonitoring(for: region)
            }
        }
    }
}
