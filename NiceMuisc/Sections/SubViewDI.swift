//
//  SubViewDI.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/14.
//

import RxRelay
import RxSwift

protocol SubViewDI: AnyObject {
    
    // MARK: - Input/Output
    /// View -> ViewModel
    var inputRelay: PublishRelay<Any> { get }
    
    /// ViewModel ->  View
    var outputRelay: PublishRelay<Any> { get }
    
    // MARK: - Properties
    var subViews: [UIView] { get set }
    
    func applySubviewTags()
}

extension SubViewDI {
    func setupLayout() { }
    func setupSubviews() { }
}

extension SubViewDI {
    // for optional
    var subViews: [UIView] {
        get {
            return []
        }
        set {
        }
    }
}
extension SubViewDI {
    func applySubViewTags() {
        subViews.enumerated().forEach { index, view in
            view.tag = index + 1
        }
    }
}

extension SubViewDI {
    @discardableResult
    func setupDI(relay: PublishRelay<Any>) -> Self {
        return self
    }

    @discardableResult
    func setupDI<T>(generic: PublishRelay<T>) -> Self {
        return self
    }

    @discardableResult
    func setupDI<T>(generic: BehaviorRelay<T>) -> Self {
        return self
    }

    @discardableResult
    func setupDI<T>(observable: Observable<[T]>) -> Self {
        return self
    }

    @discardableResult
    func setupDI<T>(observable: Observable<T>) -> Self {
        return self
    }

    @discardableResult
    func setupDI<T>(observer: AnyObserver<T>) -> Self {
        return self
    }
}

class DescendantView: UIView {
    weak var delegate: SubViewDI? {
        didSet {
            setupDI()
        }
    }

    var hiddenFlag: Any? {
        willSet {
            if let unwrapNewValue = newValue {
                self.isHidden = (unwrapNewValue is Bool) ? (unwrapNewValue as! Bool) : false
            } else {
                self.isHidden = true
            }
        }
    }

    func setupDI() { }

    /// Any 또는 [Any] 타입의 element에서 특정 단일 오브젝트만을 원하는 경우 사용하는 타입캐스팅 메서드
    func mappingElement<T>(_ element: Any, to: T.Type) -> T? {
        if let element = (element as? T) {
            return element
        } else if let anyArray = (element as? [Any]) {
            return anyArray.compactMap { $0 as? T }.first
        }
        return nil
    }

    /// [Any] 타입의 element에서 특정 오브젝트를 모두 원하는 경우 사용하는 타입캐스팅 메서드
    func mappingArrayElement<T>(_ element: Any, to: T.Type) -> [T?] {
        if let anyArray = (element as? [Any]) {
            return anyArray.compactMap { $0 as? T }
        }
        return []
    }
}
