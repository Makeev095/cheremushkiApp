//
//  MeterReadingsViewController.swift
//  cheremushkiApp
//
//  Created by GPT on 25.12.2025.
//

import UIKit

final class MeterReadingsViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStack = UIStackView()

    private let logoView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "CheremushkiLogo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        return imageView
    }()

    private let submitButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(named: "PrimaryGreen") ?? UIColor(red: 0.18, green: 0.50, blue: 0.33, alpha: 1.0)
        config.baseForegroundColor = .white
        config.cornerStyle = .large
        config.image = UIImage(systemName: "paperplane.fill")
        config.imagePadding = 10
        config.title = "Отправить показания"
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var attrs = attrs
            attrs.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            return attrs
        }
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground") ?? UIColor.systemGroupedBackground

        setupLayout()
        buildContent()
    }
}

private extension MeterReadingsViewController {

    func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.alignment = .fill

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStack)
        contentView.addSubview(logoView)
        contentView.addSubview(submitButton)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            logoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            logoView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoView.heightAnchor.constraint(equalToConstant: 120),
            logoView.widthAnchor.constraint(lessThanOrEqualToConstant: 260),

            contentStack.topAnchor.constraint(equalTo: logoView.bottomAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            submitButton.topAnchor.constraint(equalTo: contentStack.bottomAnchor, constant: 28),
            submitButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            submitButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            submitButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    func buildContent() {
        let header = HeaderView(
            title: "Показания счётчиков",
            subtitle: "Введите текущие показания приборов учёта"
        )

        contentStack.addArrangedSubview(header)

        let homeSection = FormSectionView(
            icon: UIImage(systemName: "doc.text.magnifyingglass"),
            iconTint: UIColor(red: 0.15, green: 0.50, blue: 0.31, alpha: 1),
            iconBackground: UIColor(red: 0.90, green: 0.95, blue: 0.92, alpha: 1),
            title: "Выберите дом",
            field: SelectionFieldView(title: "Выберите адрес дома")
        )

        let flatSection = FormSectionView(
            icon: UIImage(systemName: "house"),
            iconTint: UIColor(red: 0.15, green: 0.50, blue: 0.31, alpha: 1),
            iconBackground: UIColor(red: 0.90, green: 0.95, blue: 0.92, alpha: 1),
            title: "Номер квартиры",
            field: InputFieldView(placeholder: "Например: 42", unitText: nil)
        )

        contentStack.addArrangedSubview(homeSection)
        contentStack.addArrangedSubview(flatSection)

        let readingsTitle = SectionHeaderLabel(text: "ПОКАЗАНИЯ")
        contentStack.addArrangedSubview(readingsTitle)

        let meters: [MeterRowView.Model] = [
            .init(
                icon: UIImage(systemName: "drop.fill"),
                iconTint: UIColor(red: 0.10, green: 0.54, blue: 0.95, alpha: 1),
                iconBackground: UIColor(red: 0.90, green: 0.95, blue: 1.00, alpha: 1),
                title: "Холодная вода",
                unitText: "м³"
            ),
            .init(
                icon: UIImage(systemName: "drop.fill"),
                iconTint: UIColor(red: 0.98, green: 0.27, blue: 0.16, alpha: 1),
                iconBackground: UIColor(red: 1.00, green: 0.92, blue: 0.90, alpha: 1),
                title: "Горячая вода",
                unitText: "м³"
            ),
            .init(
                icon: UIImage(systemName: "flame.fill"),
                iconTint: UIColor(red: 1.00, green: 0.58, blue: 0.12, alpha: 1),
                iconBackground: UIColor(red: 1.00, green: 0.95, blue: 0.90, alpha: 1),
                title: "Газ",
                unitText: "м³"
            ),
            .init(
                icon: UIImage(systemName: "thermometer"),
                iconTint: UIColor(red: 0.98, green: 0.27, blue: 0.16, alpha: 1),
                iconBackground: UIColor(red: 1.00, green: 0.92, blue: 0.90, alpha: 1),
                title: "Отопление",
                unitText: "Гкал"
            )
        ]

        meters.forEach { model in
            let row = MeterRowView(model: model)
            contentStack.addArrangedSubview(row)
        }
    }
}

// MARK: - Small UI Pieces

private final class HeaderView: UIView {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    init(title: String, subtitle: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = UIColor.label
        titleLabel.numberOfLines = 0

        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        subtitleLabel.textColor = UIColor.secondaryLabel
        subtitleLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { nil }
}

private final class SectionHeaderLabel: UILabel {
    init(text: String) {
        super.init(frame: .zero)
        self.text = text
        font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        textColor = UIColor.secondaryLabel
        setContentHuggingPriority(.required, for: .vertical)
    }

    required init?(coder: NSCoder) { nil }
}

private final class IconBadgeView: UIView {
    private let imageView = UIImageView()

    init(image: UIImage?, tint: UIColor, background: UIColor) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        layer.cornerRadius = 18
        self.backgroundColor = background

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image
        imageView.tintColor = tint
        imageView.contentMode = .scaleAspectFit

        addSubview(imageView)
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 36),
            heightAnchor.constraint(equalToConstant: 36),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 18),
            imageView.heightAnchor.constraint(equalToConstant: 18)
        ])
    }

    required init?(coder: NSCoder) { nil }
}

private final class FormSectionView: UIView {
    private let titleLabel = UILabel()

    init(icon: UIImage?, iconTint: UIColor, iconBackground: UIColor, title: String, field: UIView) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = UIColor.label

        let badge = IconBadgeView(image: icon, tint: iconTint, background: iconBackground)

        let topRow = UIStackView(arrangedSubviews: [badge, titleLabel, UIView()])
        topRow.translatesAutoresizingMaskIntoConstraints = false
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = 12

        let stack = UIStackView(arrangedSubviews: [topRow, field])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { nil }
}

private final class FieldContainerView: UIView {
    let textField = UITextField()
    private let trailingLabel = UILabel()
    private let trailingImageView = UIImageView()

    init(placeholder: String, trailingText: String?, trailingImage: UIImage?) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = UIColor.secondarySystemGroupedBackground
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor.separator.withAlphaComponent(0.3).cgColor

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = placeholder
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        textField.textColor = UIColor.label
        textField.keyboardType = .decimalPad

        trailingLabel.translatesAutoresizingMaskIntoConstraints = false
        trailingLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        trailingLabel.textColor = UIColor.secondaryLabel
        trailingLabel.text = trailingText

        trailingImageView.translatesAutoresizingMaskIntoConstraints = false
        trailingImageView.image = trailingImage
        trailingImageView.tintColor = UIColor.tertiaryLabel
        trailingImageView.contentMode = .scaleAspectFit

        addSubview(textField)
        addSubview(trailingLabel)
        addSubview(trailingImageView)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 56),

            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            textField.centerYAnchor.constraint(equalTo: centerYAnchor),
            textField.trailingAnchor.constraint(lessThanOrEqualTo: trailingLabel.leadingAnchor, constant: -12),
            textField.trailingAnchor.constraint(lessThanOrEqualTo: trailingImageView.leadingAnchor, constant: -12),

            trailingLabel.trailingAnchor.constraint(equalTo: trailingImageView.leadingAnchor, constant: -10),
            trailingLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            trailingImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            trailingImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            trailingImageView.widthAnchor.constraint(equalToConstant: 16),
            trailingImageView.heightAnchor.constraint(equalToConstant: 16)
        ])

        trailingLabel.isHidden = trailingText == nil
        trailingImageView.isHidden = trailingImage == nil
    }

    required init?(coder: NSCoder) { nil }
}

private final class SelectionFieldView: UIView {
    init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let field = FieldContainerView(
            placeholder: title,
            trailingText: nil,
            trailingImage: UIImage(systemName: "chevron.down")
        )
        field.textField.isUserInteractionEnabled = false

        addSubview(field)
        NSLayoutConstraint.activate([
            field.topAnchor.constraint(equalTo: topAnchor),
            field.leadingAnchor.constraint(equalTo: leadingAnchor),
            field.trailingAnchor.constraint(equalTo: trailingAnchor),
            field.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { nil }
}

private final class InputFieldView: UIView {
    init(placeholder: String, unitText: String?) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let field = FieldContainerView(
            placeholder: placeholder,
            trailingText: unitText,
            trailingImage: nil
        )

        if unitText == nil {
            field.textField.keyboardType = .numberPad
        }

        addSubview(field)
        NSLayoutConstraint.activate([
            field.topAnchor.constraint(equalTo: topAnchor),
            field.leadingAnchor.constraint(equalTo: leadingAnchor),
            field.trailingAnchor.constraint(equalTo: trailingAnchor),
            field.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { nil }
}

private final class MeterRowView: UIView {

    struct Model {
        let icon: UIImage?
        let iconTint: UIColor
        let iconBackground: UIColor
        let title: String
        let unitText: String
    }

    init(model: Model) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let badge = IconBadgeView(image: model.icon, tint: model.iconTint, background: model.iconBackground)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = model.title
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = UIColor.label

        let topRow = UIStackView(arrangedSubviews: [badge, titleLabel, UIView()])
        topRow.translatesAutoresizingMaskIntoConstraints = false
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = 12

        let field = InputFieldView(placeholder: "0.000", unitText: model.unitText)

        let stack = UIStackView(arrangedSubviews: [topRow, field])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { nil }
}


