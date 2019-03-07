//
//  CurrencyService.swift
//  LeBaluchon
//
//  Created by co5ta on 03/08/2018.
//  Copyright © 2018 Co5ta. All rights reserved.
//

import Foundation

/// Class that fetch data from the currency API
class CurrencyService: Service {
    // MARK: Singleton
    
    /// Property for singleton pattern
    static let shared = CurrencyService()
    
    /// Init for singleton pattern
    private init() {}
    
    // MARK: Dependency injection
    
    /// Inject custom session and apiUrl for tests
    init(session: URLSession, apiUrl: String? = nil) {
        self.session = session
        if let apiUrl = apiUrl {
            self.apiUrl = apiUrl
        }
    }
    
    // MARK: Properties
    
    /// Session configuration
    private var session = URLSession(configuration: .default)
    
    /// Task to request data
    private var task: URLSessionDataTask?
    
    /// Base URL of the currency API
    private var apiUrl = "http://data.fixer.io/api/"
    
    /// Key to access the API
    private let apiKey = "5f997405a289e163b37336eeed0c04bb"
    
    /// Arguments to request the API
    private var arguments: [String: String] {
        return [ "access_key": apiKey ]
    }
    
    /// Code of main currencies that must be on top of the list
    private let mainCurrenciesCode = ["EUR", "USD"]
    
    /// All currencies
    var currencies = [Currency]()
    
    // Exchange rates
    var rates = [String: Float]()
}

// MARK: - Data type

extension CurrencyService {
    /// Data type that can be asked
    enum Resource: String {
        /// Data type available in the API
        case Rates = "latest", Currencies = "symbols"
    }
}

// MARK: - Methods

extension CurrencyService {
    /**
     Fetch the list of all currencies
     
     - Parameters:
        - callback: closure to check if there is an error
     */
    func getCurrencies(callback: @escaping (Error?) -> ()) {
        guard let url = createRequestURL(url: apiUrl, arguments: arguments, path: Resource.Currencies.rawValue) else {
            callback(NetworkError.invalidRequestURL)
            return
        }
        
        task?.cancel()
        task = session.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let failure = self.getFailure(error, response, data) {
                    callback(failure)
                    return
                }
                
                guard let data = data, let currenciesList = try? JSONDecoder().decode(CurrenciesList.self, from: data) else {
                    callback(NetworkError.jsonDecodeFailed)
                    return
                }
                
                self.currencies = self.formatCurrencies(from: currenciesList)
                callback(nil)
            }
        }
        task?.resume()
    }
    
    /**
     Fetch curency rates relative to EUR as base
     
     - Parameters:
        - completionHandler: closure to check if there is an error
    */
    func getRates(callback: @escaping (Error?) -> ()) {
        guard let url = createRequestURL(url: apiUrl, arguments: arguments, path: Resource.Rates.rawValue) else {
            callback(NetworkError.invalidRequestURL)
            return
        }
        
        task?.cancel()
        task = session.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let failure = self.getFailure(error, response, data) {
                    callback(failure)
                    return
                }
                
                guard let data = data, let latestRates = try? JSONDecoder().decode(LatestRates.self, from: data) else {
                    callback(NetworkError.jsonDecodeFailed)
                    return
                }
                
                self.rates = latestRates.rates
                callback(nil)
            }
        }
        task?.resume()
    }
    
    /**
     Transform currencies list from API to array of Currency
     
     - Parameters:
        - currenciesList: The list of currencies decoded from json
     
     - Returns: An array of Currency ordered alphabetically
     */
    private func formatCurrencies(from currenciesList: CurrenciesList) -> [Currency] {
        var primaryCurrencies = [Currency]()
        var secondaryCurrencies = [Currency]()
        
        for (currencyCode, currencyName) in currenciesList.symbols {
            let newCurrency = Currency(code: currencyCode, name: currencyName)
            if self.mainCurrenciesCode.contains(currencyCode) {
                primaryCurrencies.append(newCurrency)
            } else {
                secondaryCurrencies.append(newCurrency)
            }
        }
        
        primaryCurrencies.sort(by: { (currencyA, currencyB) -> Bool in
        currencyA.name < currencyB.name
        })

        secondaryCurrencies.sort(by: { (currencyA, currencyB) -> Bool in
        currencyA.name < currencyB.name
        })

        return primaryCurrencies + secondaryCurrencies
    }
}
