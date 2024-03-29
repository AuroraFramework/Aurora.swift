//
//  File.swift
//  
//
//  Created by Wesley de Groot on 27/05/2022.
//

#if canImport(CoreLocation)
import Foundation
import CoreLocation

public extension CLLocation {
    /// Get coordinate by location
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - completion: <#completion description#>
    static func getCoordinateByLocation(
        place name: String,
        completion: @escaping (CLLocation?, Error?) -> Void
    ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(name) { placemarks, error in

            guard error == nil else {
                completion(nil, error)
                return
            }

            guard let placemark = placemarks?[0] else {
                completion(nil, error)
                return
            }

            guard let location = placemark.location else {
                completion(nil, error)
                return
            }

            completion(location, nil)
        }
    }
}

public extension CLLocation {
    /// Get location by coordinate
    /// - Parameters:
    ///   - location: <#location description#>
    ///   - completion: <#completion description#>
    static func getLocationByCoordinate(
        location: CLLocation,
        completion: @escaping (CLPlacemark?, Error?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemark, error in

            guard error == nil else {
                completion(nil, error)
                return
            }

            if let placemark = placemark {
                completion(placemark.first, nil)
            }
        }
    }
}
#endif
