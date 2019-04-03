//
//  Currency.swift
//  LeBaluchon
//
//  Created by co5ta on 01/08/2018.
//  Copyright © 2018 Co5ta. All rights reserved.
//

import Foundation

/// Struct that represents a currency
struct Currency {
    /// Code name of the currency
    let code: String
    
    /// Full name of the currency
    let name: String
}

/// Struct that contains currencies taken from the API
struct CurrenciesList: Decodable {
    /// The list of currencies resulting from the json API
    let symbols: [String: String]
}

/// Struct that groups rates relative to a currency
struct LatestRates: Decodable {
    /// List of currencies with their rates
    let rates: [String: Float]
}