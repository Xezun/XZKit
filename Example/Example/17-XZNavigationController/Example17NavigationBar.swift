//
//  Example17NavigationBar.swift
//  Example
//
//  Created by 徐臻 on 2024/6/16.
//

import XZNavigationController
import ObjectiveC

// 示例功能
// 1、如何自定义导航条
// 2、如何使用通过协议拓展的方法，让控制器遵循协议即可自动获得一个默认的自定义导航条。

extension XZNavigationBarCustomizable {
    
    // 在 extension 中实现协议，返回自定义的导航条，那么控制器在声明遵循协议时，就可以不用再实现这个方法。
    public var navigationBarIfLoaded: AnyNavigationBar? {
        // 这里也可以写
        // return objc_getAssociatedObject(self, &_navigationBar) as? Example17NavigationBar
        // 这样如果控制器声明遵循了协议，但是却没有使用自定义导航条，那么自定义导航条就不会被懒加载。
        // 但是，既然已经声明了，似乎没有必要如此考虑，因为不使用自定义导航条的话，可以不必声明遵循协议。
        return self.navigationBar
    }
    
    // 将自定义导航条提供给遵循协议的控制器使用。
    // 注意，控制拿到的是明确类型的自定义导航条，而不是协议中的 AnyNavigationBar 类型。
    // 这可以帮我们在使用自定义导航条时，省去类型转换的麻烦。
    public var navigationBar: Example17NavigationBar {
        if let navigationBar = objc_getAssociatedObject(self, &_navigationBar) as? Example17NavigationBar {
            return navigationBar
        }
        let navigationBar = Example17NavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0))
        objc_setAssociatedObject(self, &_navigationBar, navigationBar, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return navigationBar
    }
}

// 自定义导航条，只要是遵循 AnyNavigationBar 的 UIView 就行。
// 这里是为了展示，内置的 XZNavigationBar 是如何帮我们快速自定义导航条的。
// 比如，这里的自定义导航条，通过少量代码，就实现了几乎和原生一样的，展示标题和大标题的功能。
public class Example17NavigationBar: XZNavigationBar {
    
    public override var barTintColor: UIColor? {
        didSet {
            titleLabel.backgroundColor = barTintColor
        }
    }

    public var title: String? {
        get {
            return (self.titleView as? UILabel)?.text
        }
        set {
            if titleView == nil {
                let width = UIScreen.main.bounds.width
                
                titleLabel.frame = CGRect(x: 0, y: 0, width: width, height: 32)
                titleLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
                titleLabel.textAlignment = .center
                titleLabel.textColor = .white
                
                largeTitleLabel.frame = CGRect(x: 16.0, y: 3.0, width: width - 32.0, height: 41.0)
                largeTitleLabel.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
                largeTitleLabel.font = UIFont.boldSystemFont(ofSize: 34)
                largeTitleLabel.textAlignment = .natural
                largeTitleLabel.textColor = .white
                
                let largeTitleView = UIView.init(frame: CGRect(x: 0, y: 0, width: width, height: 52))
                largeTitleView.clipsToBounds = true
                largeTitleView.addSubview(largeTitleLabel)
                
                self.titleView = titleLabel
                self.largeTitleView = largeTitleView
            }
            titleLabel.text = newValue
            largeTitleLabel.text = newValue
        }
    }
    
    public var backTitle: String? {
        get {
            return self.backButton.title(for: .normal)
        }
        set {
            if backView == nil {
                backButton.titleLabel?.font = .systemFont(ofSize: 17.0)
                backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
                backButton.setTitleColor(.white, for: .normal)
                backButton.tintColor = .white
                self.backView = backButton
            }
            backButton.setTitle(newValue, for: .normal)
        }
    }
    
    func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        backButton.addTarget(target, action: action, for: controlEvents)
    }
    
    private let titleLabel      = TitleLabel.init()
    private let largeTitleLabel = LargeTitleLabel.init()
    private let backButton      = BackButton.init(type: .system)
    
    // 以下代码是为了方便调试。
    
    public override var isHidden: Bool {
        didSet {
            print("Example17NavigationBar(\(title ?? "<无标题>")).setHidden(\(isHidden))")
        }
    }
    
    public override var isTranslucent: Bool {
        didSet {
            print("Example17NavigationBar(\(title ?? "<无标题>")).setTranslucent(\(isTranslucent))")
        }
    }
    
    public override var prefersLargeTitles: Bool {
        didSet {
            print("Example17NavigationBar(\(title ?? "<无标题>")).setPrefersLargeTitles(\(prefersLargeTitles))")
        }
    }
    
    public override var frame: CGRect {
        didSet {
            print("Example17NavigationBar(\(title ?? "<无标题>")).setFrame(\(frame))")
        }
    }
    
    class TitleLabel: UILabel {
        
        override var text: String? {
            didSet {
                sizeToFit()
            }
        }
    }

    class LargeTitleLabel: UILabel {
        override var text: String? {
            didSet {
                sizeToFit()
            }
        }
    }

    class BackButton: UIButton {
        
        override func setTitle(_ title: String?, for state: UIControl.State) {
            super.setTitle(title, for: state)
            sizeToFit()
        }
        
        override func sizeThatFits(_ size: CGSize) -> CGSize {
            let size = super.sizeThatFits(size)
            return CGSize(width: 10 + size.width + 10, height: size.height)
        }
    }
}

@MainActor private var _navigationBar = 0


