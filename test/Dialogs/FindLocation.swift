import SwiftUI
import CoreLocation
import MapKit

struct Location: Identifiable {
    let id = UUID()
    let item: MKMapItem
}

struct FindLocation: View {
    @Binding var urlResult: String
    @State private var address = ""
    @State private var phoneNumber = ""
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 0))
    @State private var places = [Location]()
    @State private var selectedPlace: MKMapItem?
    @Environment(\.dismiss) var dismiss

    func getCoordinates() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let placemarks = placemarks {
                if let location = placemarks.first?.location {
                    self.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                    fetchNearbyPlaces()
                }
            }
        }
    }
    
    func fetchNearbyPlaces() {
            let request = MKLocalPointsOfInterestRequest(center: CLLocationCoordinate2D(latitude: region.center.latitude, longitude: region.center.longitude), radius: 10000)
            let search = MKLocalSearch(request: request)
            
            search.start { response, error in
                
                print("searching")
                guard let response = response else { return }
                
                places = response.mapItems.map { Location(item: $0)}
                
                // Add a pin at the specified latitude and longitude
                let pin = MKPointAnnotation()
                pin.coordinate = CLLocationCoordinate2D(latitude: region.center.latitude, longitude: region.center.longitude)
                places.append(Location(item: MKMapItem(placemark: MKPlacemark(coordinate: pin.coordinate))))
                places.last?.item.name = address
                
                // Change the default zoom level for the map
                region.span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
            }
        }

    func getAddress() {
            if let selectedPlace = selectedPlace?.placemark {
                let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(CLLocation(latitude: selectedPlace.coordinate.latitude, longitude: selectedPlace.coordinate.longitude)) { placemarks, error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else if let placemark = placemarks?.first {
//                        print(placemark)
                        address = "\(placemark.subThoroughfare ?? "") \(placemark.thoroughfare ?? ""), \(placemark.locality ?? ""), \(placemark.administrativeArea ?? "") \(placemark.postalCode ?? ""), \(placemark.country ?? "")"
                    }
                }
            }
        }
    
    var body: some View {
        return NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    VStack {
                        HStack {
                            TextField("Enter address", text: $address)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.bottom, 10)
                            
                        }
                        HStack {
                            Button {
                                getCoordinates()
                            } label: {
                                Text("Find")
                            }
                            Spacer()
                            Button {
                                
                            } label: {
                                Text("Nearby")
                            }
                            Button {
                                
                            } label: {
                                Text("Current")
                            }
                        }
                    }
                }
                Map(coordinateRegion: $region, annotationItems: places) { place in
                    MapAnnotation(coordinate: place.item.placemark.coordinate) {
                        if place.id == places.last?.id {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.green)
                                .onTapGesture {
                                    selectedPlace = place.item
                                    getAddress()
                                }
                        } else {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                                .onTapGesture {
                                    selectedPlace = place.item
                                    getAddress()
                                }
                        }
                    }
                }
                
                if let selectedPlace = selectedPlace {
                    Text(address)
                }
            }
            .padding()
        }
        .navigationTitle("Location")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
            }
            ToolbarItem {
                Button {
                    urlResult = "mtgeo2:/\(region.center.latitude)/\(region.center.longitude)/\(region.span.latitudeDelta)/\(region.span.longitudeDelta)"
//                    print(urlResult)
                    dismiss()
                } label: {
                    Text("Save")
                }
                .disabled(region.center.latitude == 0.0 && region.center.longitude == 0.0)
            }
        }
    }
}

struct FindLocation_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FindLocation(urlResult: .constant(""))
        }
    }
}
