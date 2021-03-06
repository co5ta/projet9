//
//  WeatherViewController.swift
//  LeBaluchon
//
//  Created by co5ta on 31/07/2018.
//  Copyright © 2018 Co5ta. All rights reserved.
//

import UIKit

/// Controller that manages the Weather scene
class WeatherViewController: UIViewController {
    // MARK: Outlets
    
    @IBOutlet weak var activityContainer: UIView!
    
    /// Collection view listing weather for each city
    @IBOutlet weak var collectionView: UICollectionView!
    
    /// Indicates current page and number of pages
    @IBOutlet weak var pageController: UIPageControl!
}

// MARK: - Setup

extension WeatherViewController {
    /// Update data before view appear
    override func viewWillAppear(_ animated: Bool) {
        if WeatherCondition.needsUpdate { getConditions() }
    }
    
    /// Fetch currents weather conditions
    func getConditions() {
        toggleLoader(show: true, duration: 0)
        WeatherService.shared.getConditions { [weak self] (result) in
            switch result {
            case .failure(let error):
                self?.present(UIAlertController.alert(error), animated: true)
            case .success(let weatherConditions):
                WeatherCondition.list = weatherConditions
                self?.reloadCollectionView()
            }
            self?.toggleLoader(show: false)
        }
    }
    
    private func toggleLoader(show: Bool, duration: TimeInterval = 0.2) {
        collectionView.isHidden = show
        activityContainer.isHidden = !show
    }
    
    private func reloadCollectionView() {
        collectionView.reloadData()
        pageController.numberOfPages = WeatherCondition.list.count
    }
}

// MARK: - UICollectionViewDataSource

extension WeatherViewController: UICollectionViewDataSource {
    /// Give the number of items in the collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return WeatherCondition.list.count
    }
    
    /// Give the content of an item
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCell", for: indexPath) as? WeatherCollectionViewCell else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCell", for: indexPath)
        }
        
        let weatherCondition = WeatherCondition.list[indexPath.row]
        cell.configure(weatherCondition)
        
        return cell
    }
}

// MARK: - PAGINATION

extension WeatherViewController: UICollectionViewDelegateFlowLayout {
    /// Give the size of items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    /// Give the size of space between items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    /// Select current page in the UIPageControler
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = targetContentOffset.pointee.x
        pageController.currentPage = Int(x / collectionView.frame.width)
    }
}
