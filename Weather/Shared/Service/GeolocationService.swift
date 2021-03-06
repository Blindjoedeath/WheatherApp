//
//  GeolocationService.swift
//  Weather
//
//  Created by Blind Joe Death on 21/03/2019.
//  Copyright © 2019 Codezavod. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import RxCoreLocation

protocol GeolocationServiceProtocol: class{
    func getLocality() -> Observable<String?>
    var access: Observable<Bool> {get}
    var accessDetermined: Observable<Bool> {get}
    var timeLimit: Int {get set}
}

class GeolocationService: GeolocationServiceProtocol{
    
    private(set) lazy var locationManager = CLLocationManager()
    private lazy var geocoder = CLGeocoder()
    private lazy var accessBag = DisposeBag()
    
    var timeLimit = 10
    
    private(set) lazy var access = {
        locationManager.rx
            .didChangeAuthorization
            .map{ _, status in
                return status == .authorizedAlways || status == .authorizedWhenInUse
            }
            .share()
    }()
    
    lazy var accessDetermined = {
        locationManager.rx
            .didChangeAuthorization
            .map{ _, status in
                return status != .notDetermined
            }
            .share()
    }()
    
    func subscribeOnAccess(){
        accessBag = DisposeBag()
        access
            .bind(onNext: {[weak self] status in
                if status{
                    self?.startUpdatingLocations()
                } else{
                    self?.locationManager.requestWhenInUseAuthorization()
                }
            }).disposed(by: accessBag)
    }
    
    func getLocality() -> Observable<String?>{
        subscribeOnAccess()
        startUpdatingLocations()
        
        return locationManager.rx
            .didUpdateLocations
            .filter{ $1.count > 0 }
            .map{ $1.last! }
            .filter{ 0 < $0.horizontalAccuracy && $0.horizontalAccuracy < 70 && $0.timestamp.timeIntervalSinceNow >= -5}
            .take(1)
            .timeout(RxTimeInterval.seconds(timeLimit), scheduler: MainScheduler.instance)
            .do(onNext: {_ in self.locationManager.stopUpdatingLocation()})
            .flatMap{ return self.reverse(location: $0)}
    }
    
    private func startUpdatingLocations(){
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    private func reverse(location: CLLocation) -> Observable<String?>{
        return Observable.create{ observser in
            self.geocoder.reverseGeocodeLocation(location){placemarks, error in
                if let error = error{
                    observser.onError(error)
                } else {
                    if let placemarks = placemarks, !placemarks.isEmpty{
                        let locality = placemarks.last!.locality
                        observser.onNext(locality)
                        observser.onCompleted()
                    }
                }
            }
            
            return Disposables.create {
                self.geocoder.cancelGeocode()
            }
        }
    }
}
