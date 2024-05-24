//
//  ViewController.swift
//  UIScrollViewInspector
//
//  Created by JH on 2024/5/16.
//

import UIKit
import DMScrollBar

class ViewController: UIViewController {
    @IBOutlet var scrollView: UIScrollView!

    @IBOutlet var inspectorTableView: UITableView!

    @IBOutlet var zoomSlider: UISlider!

    let imageView = UIImageView()

    var propertyValues: [InspectorProperty: String] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = UIImage(named: "IMG_0003")
        imageView.sizeToFit()
        scrollView.delegate = self
        scrollView.addSubview(imageView)
        scrollView.contentSize = imageView.image?.size ?? .zero
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 4.0
        zoomSlider.addTarget(self, action: #selector(zoomSliderAction(_:)), for: .valueChanged)
        inspectorTableView.dataSource = self
        reloadPropertyValues()
        
        scrollView.configureScrollBar(with: .horizontal)
        scrollView.configureScrollBar(with: .vertical)
    }

    @objc func zoomSliderAction(_ sender: UISlider) {
        scrollView.zoomScale = CGFloat(sender.value)
    }
    
    @IBAction func resetZoomAction(_ sender: UIButton) {
        scrollView.zoomScale = 1
        zoomSlider.value = 1
        reloadPropertyValues()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        InspectorProperty.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let property = InspectorProperty.allCases[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: InspectorTableViewCell.self), for: indexPath) as! InspectorTableViewCell
        cell.nameLabel.text = property.rawValue
        cell.valueLabel.text = propertyValues[property]
        return cell
    }
}

extension ViewController: UIScrollViewDelegate {
    func reloadPropertyValues() {
        propertyValues[.zoomScale] = scrollView.zoomScale.description
        propertyValues[.contentOffset] = scrollView.contentOffset.propertyValue
        propertyValues[.contentSize] = scrollView.contentSize.propertyValue
        propertyValues[.frame] = scrollView.frame.propertyValue
        propertyValues[.bounds] = scrollView.bounds.propertyValue
        propertyValues[.visibleRect] = scrollView.visibleRect.propertyValue
        propertyValues[.visibleSize] = scrollView.visibleSize.propertyValue
        inspectorTableView.reloadData()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        reloadPropertyValues()
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 0
    formatter.locale = Locale(identifier: "en_US")
    return formatter
}()

func numberFormat(_ value: Double) -> String {
    numberFormatter.string(for: NSNumber(value: value)) ?? "0"
}

extension CGSize {
    var propertyValue: String {
        "(\(numberFormat(width)), \(numberFormat(height)))"
    }
}

extension CGPoint {
    var propertyValue: String {
        "(\(numberFormat(x)), \(numberFormat(y)))"
    }
}

extension CGRect {
    var propertyValue: String {
        "(\(numberFormat(origin.x)), \(numberFormat(origin.y)), \(numberFormat(size.width)), \(numberFormat(size.height)))"
    }
}

extension UIScrollView {
    var visibleRect: CGRect {
        visibleRect(inset: .zero)
    }

    func visibleRect(inset: UIEdgeInsets) -> CGRect {
        var visibleRect = CGRect()
        visibleRect.origin = contentOffset
        visibleRect.size = bounds.size
        visibleRect = visibleRect.inset(by: inset)
        let scale = 1.0 / zoomScale
        visibleRect.origin.x *= scale
        visibleRect.origin.y *= scale
        visibleRect.size.width *= scale
        visibleRect.size.height *= scale
        return visibleRect
    }
}

enum InspectorProperty: String, Hashable, CaseIterable {
    case zoomScale = "ZoomScale"
    case contentOffset = "ContentOffset"
    case contentSize = "ContentSize"
    case frame = "Frame"
    case bounds = "Bounds"
    case visibleRect = "VisibleRect"
    case visibleSize = "VisibleSize"
}

struct InspectorInfo: Hashable {
    let property: InspectorProperty
    let value: String
}

class InspectorTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!

    @IBOutlet var valueLabel: UILabel!
}


extension DMScrollBar.Configuration {
    public typealias Configuration = DMScrollBar.Configuration
    /// iOS native scroll bar style configuration
    public static let vertical = Configuration(
        indicator: .init(
            normalState: .iosStyleVertical(width: 8),
            activeState: .custom(config: .iosStyleVertical(width: 8)),
            animation: .defaultTiming(with: .fade)
        ),
        direction: .vertical
    )
    
    public static let horizontal = Configuration(
        indicator: .init(
            normalState: .iosStyleHorizontal(height: 8),
            activeState: .custom(config: .iosStyleHorizontal(height: 8)),
            animation: .defaultTiming(with: .fade)
        ),
        direction: .horizontal
    )
}
