import UIKit

extension Stylable where Self == UILabel {

    init(
        text: String = String.blank,
        textColor: UIColor = .black,
        style: ViewStyle<Self>
    ) {
        self.init()
        self.text = text
        self.textColor = textColor
        self.apply(style)
    }
}

extension ViewStyle where T: UILabel {

    static var smallFontNormalStyle: ViewStyle<T> {
        ViewStyle<T> {
            $0.font = .systemFont(ofSize: 12)
        }
    }

    static var fontNormalStyle: ViewStyle<T> {
        ViewStyle<T> {
            $0.font = .systemFont(ofSize: 16)
        }
    }

    static var smallFontBoldStyle: ViewStyle<T> {
        ViewStyle<T> {
            $0.font = .boldSystemFont(ofSize: 12)
        }
    }

    static var fontBoldStyle: ViewStyle<T> {
        ViewStyle<T> {
            $0.font = .boldSystemFont(ofSize: 16)
        }
    }

    static var largeFontBoldStyle: ViewStyle<T> {
        ViewStyle<T> {
            $0.font = .boldSystemFont(ofSize: 20)
        }
    }

    static var validationStyle: ViewStyle<T> {
        ViewStyle<T> {
            $0.font = .boldSystemFont(ofSize: 10)
            $0.textColor = .systemRed
        }
    }
}
