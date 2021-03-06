//
//  LocationPresenter.swift
//  Weather
//
//  Created by Blind Joe Death on 21/03/2019.
//  Copyright © 2019 Codezavod. All rights reserved.
//

import Foundation

protocol LocationPresenterProtocol: class {
    
    var view: LocationViewProtocol! {get set}
    var interactor: LocationInteractorProtocol! {get set}
    var router: LocationRouterProtocol! {get set}
    
    func cityNameChanged(on: String)
    
    // or button clicked
    func nextNavigationRequired()
    func geolocationRequired()
    func load()
}

class LocationPresenter: LocationPresenterProtocol{
    
    weak var view: LocationViewProtocol!
    var router: LocationRouterProtocol!
    var interactor: LocationInteractorProtocol!
    var repository = CitiesBaseRepository.instance
    
    var city = ""

    func cityNameChanged(on city: String) {
        self.city = city
        if city == ""{
            view?.isNextNavigationEnabled = false
        } else{
            view?.isNextNavigationEnabled = true
        }
    }
    
    func nextNavigationRequired() {
        view.isDataLoadingIndicatorEnabled = true
        interactor.getWeather(for: city)
    }
    
    func geolocationRequired() {
        view.isDataLoadingIndicatorEnabled = true
        view.isNextNavigationEnabled = false
        interactor.getLocation()
    }
    
    func load() {
        let date = Date()
        view.setDay(date.day)
        view.setDate(date.formatted(by: "d MMMM yyyy"))
        view.setCities(repository.cities)
        view.isNextNavigationEnabled = false
        if !interactor.isLocationAccessDetermined{
            view.isLocalityButtonEnabled = true
            view.isPermissionNotificationEnabled = true
        }

        if let city = self.interactor.getCity(),
            !city.isEmpty{
            view.setCity(city)
            DispatchQueue.main.async {[weak self] in
                if let self = self{
                    self.router.route(with: nil)
                }
            }
        }
    }
}

extension LocationPresenter: LocationInteractorOutput{
    
    func geolocationAccessDetermined(state: Bool) {
        if !state{
            view.isDataLoadingIndicatorEnabled = false
        }
        view.isPermissionNotificationEnabled = !state
        view.isLocalityButtonEnabled = state
    }
    
    func geolocationTimeOut() {
        view.showAlert(title: "Exception", message: "Timeout")
        view.isDataLoadingIndicatorEnabled = false
    }
    
    func geolocationError(error: String) {
        view.showAlert(title: "Exception", message: error)
        view.isDataLoadingIndicatorEnabled = false
    }
    
    func foundLocality(locality: String) {
        self.city = locality
        view.setCity(locality)
        view.isDataLoadingIndicatorEnabled = false
        view.isNextNavigationEnabled = true
    }
    
    func weatherRequestTimeOut() {
        view.showAlert(title: "Exception", message: "Timeout")
        view.isNextNavigationEnabled = false
        view.isDataLoadingIndicatorEnabled = false
    }
    
    func noNetwork() {
        view.showAlert(title: "Exception", message: "No network")
        view.isNextNavigationEnabled = false
        view.isDataLoadingIndicatorEnabled = false
    }
    
    func noLocation() {
        view.showAlert(title: "Exception", message: "No location")
        view.isNextNavigationEnabled = false
        view.isDataLoadingIndicatorEnabled = false
    }
    
    func foundWeather() {
        view.isDataLoadingIndicatorEnabled = false
        router.route(with: nil)
    }
}
