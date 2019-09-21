//
//  CityRepositoryFake.swift
//  WeatherTests
//
//  Created by Oskar on 13/09/2019.
//  Copyright © 2019 Codezavod. All rights reserved.
//

import Foundation
@testable import Weather
import RxRelay

class CityRepositoryFake: CityRepositoryProtocol{
    var city = BehaviorRelay<String?>(value: nil)
}
