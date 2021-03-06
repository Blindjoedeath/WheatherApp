//
//  LocationInteractorSpy.swift
//  WeatherTests
//
//  Created by Oskar on 11/09/2019.
//  Copyright © 2019 Codezavod. All rights reserved.
//

import Foundation
@testable import Weather


class LocationInteractorSpy: LocationInteractorProtocol {
    
    
    var invokedPresenterSetter = false
    var invokedPresenterSetterCount = 0
    var invokedPresenter: LocationInteractorOutput?
    var invokedPresenterList = [LocationInteractorOutput?]()
    var invokedPresenterGetter = false
    var invokedPresenterGetterCount = 0
    var stubbedPresenter: LocationInteractorOutput!
    var presenter: LocationInteractorOutput! {
        set {
            invokedPresenterSetter = true
            invokedPresenterSetterCount += 1
            invokedPresenter = newValue
            invokedPresenterList.append(newValue)
        }
        get {
            invokedPresenterGetter = true
            invokedPresenterGetterCount += 1
            return stubbedPresenter
        }
    }
    
    
    var invokedIsLocationAccessDeterminedGetter = false
    var invokedIsLocationAccessDeterminedGetterCount = 0
    var stubbedIsLocationAccessDetermined: Bool! = false
    var isLocationAccessDetermined: Bool {
        invokedIsLocationAccessDeterminedGetter = true
        invokedIsLocationAccessDeterminedGetterCount += 1
        return stubbedIsLocationAccessDetermined
    }
    
    
    var invokedGetLocation = false
    var invokedGetLocationCount = 0
    func getLocation() {
        invokedGetLocation = true
        invokedGetLocationCount += 1
    }
    
    
    var invokedGetWeather = false
    var invokedGetWeatherCount = 0
    var invokedGetWeatherParameters: (for: String, Void)?
    var invokedGetWeatherParametersList = [(for: String, Void)]()
    func getWeather(for: String) {
        invokedGetWeather = true
        invokedGetWeatherCount += 1
        invokedGetWeatherParameters = (`for`, ())
        invokedGetWeatherParametersList.append((`for`, ()))
    }
    
    
    var invokedGetCity = false
    var invokedGetCityCount = 0
    var stubbedGetCityResult: String!
    func getCity() -> String? {
        invokedGetCity = true
        invokedGetCityCount += 1
        return stubbedGetCityResult
    }
    
    var invokedLoad = false
    var invokedLoadCount = 0
    func load() {
        invokedLoad = true
        invokedLoadCount += 1
    }
}
