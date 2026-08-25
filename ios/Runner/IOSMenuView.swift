import UIKit

/// Native iOS UIKit implementation of the Free Fire Mod Menu UI
class IOSMenuView: UIView {

    // Properties
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let stackView = UIStackView()
    
    // Callbacks / State
    var aimbotEnabled = true
    var targetPart = "ĐẦU"
    var aimRadius: Float = 66.47
    var espLineEnabled = true
    var espBoxEnabled = true
    var espHpEnabled = true
    var espNameEnabled = true
    
    private let radiusValueLabel = UILabel()
    private let radiusSlider = UISlider()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1) // Pure Blue
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 10

        // 1. Header (RED)
        headerView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(headerView)

        titleLabel.text = "FREE FIRE"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .black)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)

        // 2. Stack View for items
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 1
        stackView.backgroundColor = .white
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)

        // Constraints for Header
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: self.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 46),

            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            stackView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

        // Add Menu Items
        addItemButton(title: "AIMBOT")
        addItemButton(title: "ĐẦU")
        addItemButton(title: "CỔ")
        addRadiusSliderItem()
        addItemButton(title: "ESP LINE")
        addItemButton(title: "ESP Box")
        addItemButton(title: "ESP HP")
        addItemButton(title: "ESP TÊN")
    }

    private func addItemButton(title: String) {
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .black)
        btn.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
        btn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        btn.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(btn)
    }

    private func addRadiusSliderItem() {
        let container = UIView()
        container.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
        container.heightAnchor.constraint(equalToConstant: 65).isActive = true

        radiusValueLabel.text = String(format: "AIM RADIUS %.2f", aimRadius)
        radiusValueLabel.textColor = .white
        radiusValueLabel.font = UIFont.systemFont(ofSize: 16, weight: .black)
        radiusValueLabel.textAlignment = .center
        radiusValueLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(radiusValueLabel)

        let minusBtn = UIButton(type: .custom)
        minusBtn.setTitle("-", for: .normal)
        minusBtn.backgroundColor = .red
        minusBtn.setTitleColor(.white, for: .normal)
        minusBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        minusBtn.translatesAutoresizingMaskIntoConstraints = false
        minusBtn.addTarget(self, action: #selector(minusTapped), for: .touchUpInside)
        container.addSubview(minusBtn)

        let plusBtn = UIButton(type: .custom)
        plusBtn.setTitle("+", for: .normal)
        plusBtn.backgroundColor = .red
        plusBtn.setTitleColor(.white, for: .normal)
        plusBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        plusBtn.translatesAutoresizingMaskIntoConstraints = false
        plusBtn.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)
        container.addSubview(plusBtn)

        radiusSlider.minimumValue = 0
        radiusSlider.maximumValue = 200
        radiusSlider.value = aimRadius
        radiusSlider.minimumTrackTintColor = .white
        radiusSlider.maximumTrackTintColor = .white
        radiusSlider.thumbTintColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1) // Green knob
        radiusSlider.translatesAutoresizingMaskIntoConstraints = false
        radiusSlider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        container.addSubview(radiusSlider)

        NSLayoutConstraint.activate([
            radiusValueLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            radiusValueLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            minusBtn.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            minusBtn.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            minusBtn.widthAnchor.constraint(equalToConstant: 30),
            minusBtn.heightAnchor.constraint(equalToConstant: 30),

            plusBtn.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            plusBtn.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            plusBtn.widthAnchor.constraint(equalToConstant: 30),
            plusBtn.heightAnchor.constraint(equalToConstant: 30),

            radiusSlider.leadingAnchor.constraint(equalTo: minusBtn.trailingAnchor, constant: 8),
            radiusSlider.trailingAnchor.constraint(equalTo: plusBtn.leadingAnchor, constant: -8),
            radiusSlider.centerYAnchor.constraint(equalTo: minusBtn.centerYAnchor)
        ])

        stackView.addArrangedSubview(container)
    }

    @objc private func minusTapped() {
        aimRadius = max(0, aimRadius - 1.0)
        radiusSlider.value = aimRadius
        updateSliderLabel()
    }

    @objc private func plusTapped() {
        aimRadius = min(200, aimRadius + 1.0)
        radiusSlider.value = aimRadius
        updateSliderLabel()
    }

    @objc private func sliderChanged(_ sender: UISlider) {
        aimRadius = sender.value
        updateSliderLabel()
    }

    private func updateSliderLabel() {
        radiusValueLabel.text = String(format: "AIM RADIUS %.2f", aimRadius)
    }

    @objc private func itemTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        print("Menu item tapped: \(title)")
    }
}
