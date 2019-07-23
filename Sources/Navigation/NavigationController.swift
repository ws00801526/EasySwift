//  NavigationController.swift
//  EasySwift
//
//  Created by  XMFraker on 2019/7/9
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      NavigationController

import UIKit


public typealias Attributes = [NSAttributedString.Key : Any]
public protocol ConfigureProtocol {
    var style: UINavigationBar.Style        { get }
    var tintColor: UIColor                  { get }
    
    var textAttributes: Attributes?         { get }
    var shadowImage: UIImage?               { get }
    var backgroundColor: UIColor?           { get }
    var backgroundImage: UIImage?           { get }
}

public protocol InteractiveFullScreenPopProtocol {
    
    var isInteractivePopDisabled: Bool              { get }
    var interactivePopMaxAllowedDistance: CGFloat   { get }
}

public extension ConfigureProtocol {
    
    var textAttributes: Attributes?             { return UINavigationBar.appearance().titleTextAttributes }
    var shadowImage: UIImage?                   { return UINavigationBar.appearance().shadowImage }
    var backgroundColor: UIColor?               { return UINavigationBar.appearance().backgroundColor }
    var backgroundImage: UIImage?               { return UINavigationBar.appearance().backgroundImage(for: .default) }
}

public extension InteractiveFullScreenPopProtocol {
    
    var isInteractivePopDisabled: Bool              { return false }
    var interactivePopMaxAllowedDistance: CGFloat   { return .zero }
}

public extension UINavigationBar {
    
    struct Configure: ConfigureProtocol {
        
        public var style: UINavigationBar.Style
        public var tintColor: UIColor
        public var backgroundColor: UIColor?
        public var backgroundImage: UIImage?
        public var shadowImage: UIImage?
        public var textAttributes: Attributes?
        
        var isHidden: Bool                  { return style.contains(.hidden) }
        var barStyle: UIBarStyle            { return style.contains(.lightContent) ? .black : .default }
        var isTranslucent: Bool             { return style.contains(.translucent) }
        var isTransparent: Bool             { return style.contains(.transparent) }
        var isShadowHidden: Bool            { return style.contains(.shadowHidden) || isTransparent }
        
        var isVisiable: Bool                { return !isHidden && !isTransparent }
        var usingSystemBarStyle: Bool       { return backgroundColor == nil && backgroundImage == nil }
        
        public init(style: UINavigationBar.Style = .default, tintColor: UIColor? = nil, backgroundColor: UIColor? = nil, backgroundImage: UIImage? = nil) {
            
            self.style = style
            self.backgroundColor = backgroundColor
            self.backgroundImage = backgroundImage
            
            if let color = tintColor { self.tintColor = color }
            else { self.tintColor = style.contains(.lightContent) ? .white : .black }
        }
        
        public init(configure: ConfigureProtocol) {
            
            self.style = configure.style
            self.tintColor = configure.tintColor
            self.shadowImage = configure.shadowImage
            self.backgroundColor = configure.backgroundColor
            self.backgroundImage = configure.backgroundImage
            self.textAttributes = configure.textAttributes
        }
    }
    
    struct Style: OptionSet {
        public let rawValue: UInt
        public typealias RawValue = UInt
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        
        public static let show                 = Style(rawValue: 1 << 1)
        public static let hidden               = Style(rawValue: 1 << 2)
        
        public static let lightContent         = Style(rawValue: 1 << 3)
        public static let darkContent          = Style(rawValue: 1 << 4)
        
        /// half
        public static let translucent          = Style(rawValue: 1 << 5)
        /// all
        public static let transparent          = Style(rawValue: 1 << 6)

        /// hide shadow image
        public static let shadowHidden         = Style(rawValue: 1 << 7)
        
        /// default style. value is [.show, .darkContent, .translucent]
        public static let `default`: Style     = [.show, .darkContent, .translucent]
    }
}

fileprivate class FakeBar: NSObject, UIToolbarDelegate {

    lazy var from: UIToolbar = UIToolbar(frame: .zero)
    lazy var to: UIToolbar = UIToolbar(frame: .zero)


    override init() {
        super.init()
        from.delegate = self
        to.delegate = self
    }

    fileprivate func removeFromSuperView() {
        to.removeFromSuperview()
        from.removeFromSuperview()
    }

    func position(for bar: UIBarPositioning) -> UIBarPosition { return .top }
}

open class NavigationController: UINavigationController {
    
    fileprivate let fakeBar = FakeBar()
    fileprivate var inTransition: Bool = false

    fileprivate var navigationControllerDelegate: UINavigationControllerDelegate?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        // reset delegate to self
        if let delegate = self.delegate { navigationControllerDelegate = delegate }
        super.delegate = self
        
        fakeBar.to.apply(navigationBar.bounds, config: defaultConfigure)
        fakeBar.from.apply(navigationBar.bounds, config: defaultConfigure)
        navigationBar.apply(defaultConfigure)
    }

    open override var delegate: UINavigationControllerDelegate? {
        set {
            navigationControllerDelegate = newValue
            super.delegate = self
        }
        get { return super.delegate }
    }
    
    // override this to set full screen
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if !(interactivePopGestureRecognizer?.view?.gestureRecognizers?.contains(interactivePopGesture) ?? false) {
            
            interactivePopGestureRecognizer?.view?.addGestureRecognizer(interactivePopGesture)
            if let targets = interactivePopGestureRecognizer?.value(forKey: "targets") as? [NSObject] {
                if let target = targets.first?.value(forKey: "target") {
                    interactivePopGesture.addTarget(target, action: NSSelectorFromString("handleNavigationTransition:"))
                }
            }
            interactivePopGestureRecognizer?.isEnabled = false
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    
    fileprivate var interactivePopGesture = UIPanGestureRecognizer() {
        didSet {
            self.interactivePopGesture.minimumNumberOfTouches = 1
            self.interactivePopGesture.maximumNumberOfTouches = 1
            self.interactivePopGesture.delegate = self
        }
    }
    
    public var defaultConfigure: UINavigationBar.Configure = .init(style: .default)
}

extension NavigationController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        // Ignore when the gestureRecognizer is not an pan gesture
        guard let gesture = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        
        // Ignore when the viewControllers.count <= 1
        guard viewControllers.count >= 2 else { return false }
        
        if let controller = viewControllers.last as? InteractiveFullScreenPopProtocol {
        
            // Ignore when the active controller doesn's allow full screen pop
            if controller.isInteractivePopDisabled { return false }
            
            // Ignore when the transition.x over than the active controller max allowed initial distance
            let location = gesture.location(in: gesture.view)
            let maxAllowedInitialDistance = controller.interactivePopMaxAllowedDistance
            if maxAllowedInitialDistance > .zero, location.x > maxAllowedInitialDistance { return false }
        }

        // Ignore when the controller is in transition
        if let value = value(forKey: "_isTransitioning") as? Bool, value { return false }
        
        // Prevent calling the handler when the pan gesture begins in wrong direction
        let transition = gesture.translation(in: gesture.view)
        let isLeftToRight = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight
        let multiplier = CGFloat(isLeftToRight ? 1.0 : -1.0)
        if transition.x * multiplier <= 0 { return false }
        
        return true
    }
}

extension NavigationController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {

        willShow(viewController: viewController, animated: animated)
        
        guard let delegate = navigationControllerDelegate else { return }
        guard delegate.responds(to: #selector(navigationController(_:willShow:animated:))) else { return }
        delegate.navigationController?(navigationController, willShow: viewController, animated: animated)
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {

        didShow(viewController: viewController, animated: animated)

        guard let delegate = navigationControllerDelegate else { return }
        guard delegate.responds(to: #selector(navigationController(_:didShow:animated:))) else { return }
        delegate.navigationController?(navigationController, didShow: viewController, animated: animated)
    }

    public func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        
        guard let delegate = navigationControllerDelegate else { return .all }
        guard delegate.responds(to: #selector(navigationControllerSupportedInterfaceOrientations(_:))) else { return .all }
        return delegate.navigationControllerSupportedInterfaceOrientations?(navigationController) ?? .all
    }
    
    public func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
        
        guard let delegate = navigationControllerDelegate else { return .portrait }
        guard delegate.responds(to: #selector(navigationControllerPreferredInterfaceOrientationForPresentation(_:))) else { return .portrait }
        return delegate.navigationControllerPreferredInterfaceOrientationForPresentation?(navigationController) ?? .portrait
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        guard let delegate = navigationControllerDelegate else { return nil }
        guard delegate.responds(to: #selector(navigationController(_:interactionControllerFor:))) else { return nil }
        return delegate.navigationController?(navigationController, interactionControllerFor: animationController)
    }
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard let delegate = navigationControllerDelegate else { return nil }
        guard delegate.responds(to: #selector(navigationController(_:animationControllerFor:from:to:))) else { return nil }
        return delegate.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
    }
}

fileprivate extension NavigationController {
    func willShow(viewController: UIViewController, animated: Bool) {

        let navigationBar = self.navigationBar
        
        let from: UINavigationBar.Configure = navigationBar.configure ?? defaultConfigure
        var to: UINavigationBar.Configure = from
        if let configure = viewController as? ConfigureProtocol { to = UINavigationBar.Configure(configure: configure) }
        
        if to.isHidden != isNavigationBarHidden { setNavigationBarHidden(to.isHidden, animated: animated) }
        
        guard animated else { return navigationBar.apply(to) }
        
        // if animated, set navigation bar transparent first
        navigationBar.apply(to, isTransparent: true)
        self.inTransition = true
        transitionCoordinator?.animate(alongsideTransition: { [unowned self] context in
            
            UIView.setAnimationsEnabled(false)
            let fromVC = context.viewController(forKey: .from)
            let toVC = context.viewController(forKey: .to)
            
            if let fromVC = fromVC, from.isVisiable {
                let frame = fromVC.convertFrameOnView(of: navigationBar)
                if !frame.isEmpty {
                    self.fakeBar.from.apply(frame, config: from)
                    fromVC.view.addSubview(self.fakeBar.from)
                }
            }
            
            if let toVC = toVC, to.isVisiable {
                var frame = toVC.convertFrameOnView(of: navigationBar)
                if !frame.isEmpty {
                    if toVC.extendedLayoutIncludesOpaqueBars || to.isTranslucent { frame.origin.y = toVC.view.bounds.origin.y }
                    self.fakeBar.to.apply(frame, config: to)
                    toVC.view.addSubview(self.fakeBar.to)
                }
            }
            
            toVC?.view.addObserver(self, forKeyPath: KeyPaths.frame, options: [.new, .old], context: &TransitionContext)
            toVC?.view.addObserver(self, forKeyPath: KeyPaths.bounds, options: [.new, .old], context: &TransitionContext)
            
            UIView.setAnimationsEnabled(true)
            }, completion: { [unowned self] context in
                if context.isCancelled {
                    self.fakeBar.removeFromSuperView()
                    
                    navigationBar.apply(from)
                    
                    if from.isHidden != self.isNavigationBarHidden {
                        self.setNavigationBarHidden(from.isHidden, animated: animated)
                    }
                }
                
                if let view = context.viewController(forKey: .to)?.view {
                    view.removeObserver(self, forKeyPath: KeyPaths.frame, context: &TransitionContext)
                    view.removeObserver(self, forKeyPath: KeyPaths.bounds, context: &TransitionContext)
                }
                self.inTransition = false
        })
        
        let handler: ((UIViewControllerTransitionCoordinatorContext) -> Void) = {
            if $0.isCancelled { navigationBar.apply(from.barStyle, tintColor: from.tintColor) }
        }
        
        // called when using pop gesture
        if #available(iOS 10, *) { transitionCoordinator?.notifyWhenInteractionChanges(handler) }
        else { transitionCoordinator?.notifyWhenInteractionEnds(handler) }
    }
    
    func didShow(viewController: UIViewController, animated: Bool) {
        
        // update bar style after finished
        if let customConfigure = viewController as? ConfigureProtocol {
            navigationBar.apply(.init(configure: customConfigure))
        } else {
            navigationBar.apply(navigationBar.configure ?? defaultConfigure)
        }
        
        // remove fake bars
        fakeBar.removeFromSuperView()
        
        // transition over
        inTransition = false
    }
}

extension NavigationController {
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let controller = context?.load(as: UIViewController.self), controller == TransitionContext {
            if let superView = fakeBar.to.superview, superView == controller.view, let bar = controller.navigationController?.navigationBar {
                let frame = controller.convertFrameOnView(of: bar)
                if !frame.isEmpty { fakeBar.to.frame = frame }
            }
        }
    }
}

fileprivate extension UINavigationBar {
    var backgroundView: UIView? { return value(forKey: "_backgroundView") as? UIView  }
}

fileprivate extension UIViewController {
    
    func convertFrameOnView(of bar: UINavigationBar) -> CGRect {
        
        guard let backgroundView = bar.backgroundView else { return .zero }
        guard var frame = backgroundView.superview?.convert(backgroundView.frame, to: view) else { return .zero }
        frame.origin.x = view.bounds.origin.x
        return frame
    }
}

fileprivate var TransitionContext: UIViewController?

fileprivate struct KeyPaths {
    static let frame: String = "frame"
    static let bounds: String = "bounds"
}

fileprivate extension UINavigationBar {
    
    private struct AssociateKeys {
        private static var Key: Int = 3
        static let configure: UnsafePointer = withUnsafePointer(to: AssociateKeys.Key) { return $0 }
    }
    
    var configure: Configure? {
        set { objc_setAssociatedObject(self, AssociateKeys.configure, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
        get { return objc_getAssociatedObject(self, AssociateKeys.configure) as? Configure }
    }
    
    func apply(_ barStyle: UIBarStyle, tintColor: UIColor) {
        self.barStyle = barStyle
        self.tintColor = tintColor
        self.setNeedsDisplay()
    }
    
    func apply(_ configure: Configure, isTransparent: Bool = false) {
        
        apply(configure.barStyle, tintColor: configure.tintColor)
        backgroundView?.alpha = isTransparent ? 0.0 : 1.0

        if let attributes = configure.textAttributes {
            if let existsAttributes = titleTextAttributes {
                titleTextAttributes = attributes.merging(existsAttributes) {  a, _ in return a }
            } else {
                titleTextAttributes = attributes
            }
        }

        // preferred using backgroundView size
        let size = backgroundView?.bounds.size ?? bounds.size
        var image = (configure.isVisiable && !isTransparent) ? configure.backgroundImage : .init()
        if image == nil, let color = configure.backgroundColor { image = .init(color: color, size: size) }
        else if image == nil { image = .init(color: self.barStyle == .black ? .darkGray : .white, size: size) }
        setBackgroundImage(image, for: .default)

        shadowImage = (isTransparent || configure.isShadowHidden || !configure.isVisiable) ? .init() : configure.shadowImage
        // set this later, set barTintColor、backgroundImage with alpha will set isTranslucent = true
        isTranslucent = isTransparent || configure.isTranslucent || !configure.isVisiable
        self.configure = configure
    }
}

fileprivate extension UIToolbar {
    
    func apply(_ frame: CGRect, config: UINavigationBar.Configure) {
        
        // reset frame & bar style
        self.frame = frame
        tintColor = config.tintColor
        barStyle = config.barStyle
        isTranslucent = config.isTranslucent || !config.isVisiable
        
        // update shadow image
        let shadowImage = (config.isShadowHidden || !config.isVisiable) ? .init() : config.shadowImage
        setShadowImage(shadowImage, forToolbarPosition: .any)
        
        // uddate background image
        var image = config.isVisiable ? config.backgroundImage : .init()
        if image == nil, let color = config.backgroundColor { image = .init(color: color, size: frame.size) }
        else if image == nil { image = .init(color: self.barStyle == .black ? .darkGray : .white, size: frame.size) }
        setBackgroundImage(image, forToolbarPosition: .any, barMetrics: .default)
    }
}

fileprivate extension UIImage {
    
    /// SwifterSwift: Create UIImage from color and size.
    ///
    /// from : https://github.com/SwifterSwift/SwifterSwift/blob/master/Sources/SwifterSwift/UIKit/UIImageExtensions.swift
    ///
    /// - Parameters:
    ///   - color: image fill color.
    ///   - size: image size.
    convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        guard let aCgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            self.init()
            return
        }
        
        self.init(cgImage: aCgImage)
    }
}
