//
//  ReportsViewController.swift
//  Stock
//
//  Created by Dilmurod Rakhmonov on 13/05/2025.
//
import UIKit
import Foundation

// MARK: - TimeInterval Formatting
extension TimeInterval {
    /// Formats a TimeInterval into "Xm Ys" (or "Ys" if under a minute)
    func formattedDuration() -> String {
        let totalSeconds = Int(self)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

// MARK: - Report Metric Model & Cell
struct ReportMetric {
    let title: String
    let valueText: String
}

class ReportMetricCell: UITableViewCell {
    static let reuseID = "ReportMetricCell"
    let valueLabel = UILabel()
    let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        valueLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)

        let stack = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - ReportsViewController
class ReportsViewController: UIViewController {
    private let periodControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Daily","Weekly","Monthly"])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private var reportMetrics: [ReportMetric] = []
    private var currentInterval: DateInterval = DateInterval(start: Date(), end: Date())

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reports"
        view.backgroundColor = .systemBackground
        setupUI()
        loadAndDisplayData()
    }

    private func setupUI() {
        periodControl.addTarget(self, action: #selector(periodChanged), for: .valueChanged)
        view.addSubview(periodControl)
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate   = self
        tableView.register(ReportMetricCell.self, forCellReuseIdentifier: ReportMetricCell.reuseID)

        NSLayoutConstraint.activate([
            periodControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            periodControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            periodControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: periodControl.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func periodChanged() {
        loadAndDisplayData()
    }

    private func loadAndDisplayData() {
        let now = Date()
        let cal = Calendar.current
        let interval: DateInterval
        switch periodControl.selectedSegmentIndex {
        case 0:
            let start = cal.startOfDay(for: now)
            let end   = cal.date(byAdding: .day, value: 1, to: start)!
            interval = DateInterval(start: start, end: end)
        case 1:
            let comps     = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
            let weekStart = cal.date(from: comps)!
            let weekEnd   = cal.date(byAdding: .day, value: 7, to: weekStart)!
            interval = DateInterval(start: weekStart, end: weekEnd)
        default:
            let comps      = cal.dateComponents([.year, .month], from: now)
            let monthStart = cal.date(from: comps)!
            let monthEnd   = cal.date(byAdding: .month, value: 1, to: monthStart)!
            interval = DateInterval(start: monthStart, end: monthEnd)
        }
        currentInterval = interval

        let om = OrderManager.shared
        let total       = om.totalOrders(in: interval)
        let prepared    = om.preparedOrders(in: interval)
        let collected   = om.collectedOrders(in: interval)
        let delivered   = om.deliveredOrders(in: interval)
        let avgPrepSec  = om.averagePrepTime(in: interval)
        let avgDelivSec = om.averageDeliveryTime(in: interval)

        reportMetrics = [
            ReportMetric(title: "Total Orders",       valueText: "\(total)"),
            ReportMetric(title: "Prepared Orders",    valueText: "\(prepared)"),
            ReportMetric(title: "Collected Orders",   valueText: "\(collected)"),
            ReportMetric(title: "Delivered Orders",   valueText: "\(delivered)"),
            ReportMetric(title: "Avg. Prep Time",     valueText: avgPrepSec.formattedDuration()),
            ReportMetric(title: "Avg. Delivery Time", valueText: avgDelivSec.formattedDuration()),
            ReportMetric(title: "Branch Consumption", valueText: "Tap to view")
        ]
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension ReportsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportMetrics.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell   = tableView.dequeueReusableCell(withIdentifier: ReportMetricCell.reuseID, for: indexPath) as! ReportMetricCell
        let metric = reportMetrics[indexPath.row]
        cell.titleLabel.text = metric.title
        cell.valueLabel.text = metric.valueText
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ReportsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let om = OrderManager.shared
        let title = reportMetrics[indexPath.row].title
        var detailVC: UIViewController? = nil

        switch indexPath.row {
        case 0:
            let orders = om.orders(placedIn: currentInterval)
            detailVC = ReportDetailViewController(metricTitle: title, orders: orders)
        case 1:
            let orders = om.orders(placedIn: currentInterval)
                .filter { $0.isPrepared && ($0.preparedAt.map(currentInterval.contains) ?? false) }
            detailVC = ReportDetailViewController(metricTitle: title, orders: orders)
        case 2:
            let orders = om.orders(placedIn: currentInterval)
                .filter { $0.isCollected && ($0.collectedAt.map(currentInterval.contains) ?? false) }
            detailVC = ReportDetailViewController(metricTitle: title, orders: orders)
        case 3:
            let orders = om.orders(placedIn: currentInterval)
                .filter { $0.isDelivered && ($0.deliveredAt.map(currentInterval.contains) ?? false) }
            detailVC = ReportDetailViewController(metricTitle: title, orders: orders)
        case 4:
            let orders = om.orders(placedIn: currentInterval)
                .filter { o in
                    if let prep = o.preparedAt {
                        return currentInterval.contains(prep)
                    }
                    return false
                }
            detailVC = ReportDetailViewController(metricTitle: title, orders: orders)
        case 5:
            let orders = om.orders(placedIn: currentInterval)
                .filter { o in
                    if let del = o.deliveredAt {
                        return currentInterval.contains(del)
                    }
                    return false
                }
            detailVC = ReportDetailViewController(metricTitle: title, orders: orders)
        case 6:
            // Branch Consumption drill-down (Ordered vs Delivered)
            // 1) Get the raw “[branch: [itemName: qty]]” maps
            let orderedDict   = om.itemUsagePerBranch(in: currentInterval)
            let deliveredDict = om.deliveredItemUsagePerBranch(in: currentInterval)
            
            // 2) Instantiate with the two raw dictionaries
            detailVC = BranchUsageViewController(
                ordered:   orderedDict,
                delivered: deliveredDict
            )
        default:
            break
        }
        if let vc = detailVC {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
