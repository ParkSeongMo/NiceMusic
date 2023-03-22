//
//  DetailDescView.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/22.
//

import UIKit
import RxSwift
import SnapKit
import Then

final class DetailDescView: DescendantView {
        
    private let disposeBag = DisposeBag()
    
    private lazy var titleLabel = UILabel().then {
        $0.text = "상세 정보"
        $0.font = .boldSystemFont(ofSize: 18)
        $0.numberOfLines = 1
        $0.textColor = .white
    }
    
    private lazy var descLabel = UILabel().then {
        $0.text = ""
        $0.font = .boldSystemFont(ofSize: 15)
        $0.numberOfLines = 0
        $0.textColor = .white
    }
    
    private lazy var logoutButton = UIButton().then {
        $0.titleLabel?.font = .systemFont(ofSize: 15)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle("Logout2", for: .normal)
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.cornerRadius = 10
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        bindRx()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        addSubviews(titleLabel, descLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(10)
            $0.width.equalToSuperview()
        }
        descLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview()
        }
        
    }
    
    
    private func bindRx() {
    }
    
    override func setupDI() {
        delegate?.outputRelay
            .compactMap { ($0 as? DetailModel)?.desc?.summary }
            .subscribe(onNext: { [weak self] desc in
                guard let `self` = self else { return }
                self.descLabel.text = desc
                
//                self.descLabel.attributedText = desc.htmlEscaped(font: .boldSystemFont(ofSize: 15),
//                                                                         colorHex: "#ffffff",
//                                                                         lineSpacing: 1.5)
            })
            .disposed(by: disposeBag)
    }
}
extension String {
    func htmlEscaped(font: UIFont, colorHex: String, lineSpacing: CGFloat) -> NSAttributedString {
        let style = """
                    <style>
                    p.normal {
                      line-height: \(lineSpacing);
                      font-size: \(font.pointSize)px;
                      font-family: \(font.familyName);
                      color: \(colorHex);
                    }
                    </style>
        """
        let modified = String(format:"\(style)<p class=normal>%@</p>", self)
        do {
            guard let data = modified.data(using: .unicode) else {
                return NSAttributedString(string: self)
            }
            let attributed = try NSAttributedString(data: data,
                                                    options: [.documentType: NSAttributedString.DocumentType.html],
                                                    documentAttributes: nil)
            return attributed
        } catch {
            return NSAttributedString(string: self)
        }
    }
}
