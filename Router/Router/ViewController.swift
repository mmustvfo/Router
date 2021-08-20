//
//  ViewController.swift
//  Router
//
//  Created by Mustafo on 17/08/21.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    private let mapView: MKMapView = {
       let mapView = MKMapView()
       mapView.translatesAutoresizingMaskIntoConstraints = false
       
       return mapView
    }()
    
    private var transportType =  MKDirectionsTransportType.any
    
    let transportTypeSegment: UISegmentedControl = {
       let transportTypeSegment = UISegmentedControl(items: [UIImage(systemName: "figure.walk"),UIImage(systemName: "car")])
       transportTypeSegment.addTarget(self, action: #selector(chooseSegmentItem), for: .valueChanged)
        transportTypeSegment.translatesAutoresizingMaskIntoConstraints = false
        transportTypeSegment.backgroundColor = .systemGray4
        
       return transportTypeSegment
    }()
    
    private let addAddressButton: UIButton = {
       let button = UIButton()
        button.setTitle("Add Address", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1), for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.3875100017, green: 0.4744768143, blue: 0.6534321904, alpha: 0.81)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(didTapAddAddress), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
       return button
    }()
    
    private let resetButton: UIButton = {
       let button = UIButton()
        button.setTitle("Reset", for: .normal)
        button.backgroundColor = .systemIndigo
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.addTarget(self, action: #selector(didTapReset), for: .touchUpInside)
        
       return button
    }()
    
    private let routeButton: UIButton = {
       let button = UIButton()
        button.setTitle("Route", for: .normal)
        button.backgroundColor = .systemIndigo
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.addTarget(self, action: #selector(didTapRoute), for: .touchUpInside)
        
       return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        
        setConstarints()
    }

    
    @objc private func didTapAddAddress(){
        let alertVC = UIAlertController(title: "Add Address", message: nil, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Add", style: .default, handler: { action in
            guard let text = alertVC.textFields?.first?.text else { return }
            self.addPlaceMark(addressString: text)
        }))
        alertVC.addTextField { [self] textField in
            textField.placeholder = "Type Address"
        }
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertVC, animated: true,completion: nil)
          
    }
    
    @objc private func didTapRoute(){
        for index in 0...mapAnnotations.count-2 {
            let origin = mapAnnotations[index].coordinate
            let destination = mapAnnotations[index+1].coordinate
            createRoute(origin: origin, destination: destination)
        }
    }
    @objc private func didTapReset(){
        mapAnnotations = []
        routeButton.isHidden = true
        resetButton.isHidden = true
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
    }
    
    @objc private func chooseSegmentItem() {
        switch transportTypeSegment.selectedSegmentIndex {
        case 0:
            transportType = .walking
        case 1:
            transportType = .automobile
        default:
            break
        }
    }
    
    private var mapAnnotations = [MKPointAnnotation]()
    
    private func addPlaceMark(addressString: String) {
      
      let geCoder = CLGeocoder()
        geCoder.geocodeAddressString(addressString) { placemarks, error in
            guard let placemarks = placemarks, error == nil else {
                self.errorAlert(title: "Error!", message: "Server is not available")
                return
            }
            
            let annotation = MKPointAnnotation()
            annotation.title = addressString
            guard let coordinate = placemarks.first?.location?.coordinate else {
                self.errorAlert(title: "Error", message: "Server is not available")
                return
            }
            annotation.coordinate = coordinate
            
            self.mapAnnotations.append(annotation)
            
            self.mapView.showAnnotations(self.mapAnnotations, animated: true)
            
        }
        
        if mapAnnotations.count > 1 {
            routeButton.isHidden = false
            resetButton.isHidden = false
        }
    }
    
    private func createRoute(origin: CLLocationCoordinate2D,destination: CLLocationCoordinate2D) {
        
        let request = MKDirections.Request()
        request.transportType = transportType
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.requestsAlternateRoutes = true
        
        let direction = MKDirections(request: request)
        direction.calculate { response, error in
            guard let routes = response?.routes, error == nil else {
                self.errorAlert(title: "Error", message: nil)
                return
            }
            
            var shortestRoute = routes[0]
            
            for route in routes {
                shortestRoute = (shortestRoute.distance < route.distance) ? shortestRoute : route
            }
            
    
            self.mapView.addOverlay(shortestRoute.polyline)

        }
        
    }
    
    private func errorAlert(title: String?,message: String?) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    private func setConstarints() {
        
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0)
        ])

        
    mapView.addSubview(addAddressButton)
        NSLayoutConstraint.activate([
            addAddressButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50),
            addAddressButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            addAddressButton.heightAnchor.constraint(equalToConstant: 70),
            addAddressButton.widthAnchor.constraint(equalToConstant: 110)
        ])
      
        mapView.addSubview(routeButton)
        NSLayoutConstraint.activate([
            routeButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20),
            routeButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            routeButton.heightAnchor.constraint(equalToConstant: 70),
            routeButton.widthAnchor.constraint(equalToConstant: 70)
        ])
        
        mapView.addSubview(resetButton)
        NSLayoutConstraint.activate([
            resetButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20),
            resetButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
            resetButton.heightAnchor.constraint(equalToConstant: 70),
            resetButton.widthAnchor.constraint(equalToConstant: 70)
        ])
        
        mapView.addSubview(transportTypeSegment)
        NSLayoutConstraint.activate([
            transportTypeSegment.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 70),
            transportTypeSegment.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
            transportTypeSegment.heightAnchor.constraint(equalToConstant: 50),
            transportTypeSegment.widthAnchor.constraint(equalToConstant: 100)
        ])

    }

}


extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.systemIndigo
        renderer.lineWidth = 3
        
        return renderer
    }
}
