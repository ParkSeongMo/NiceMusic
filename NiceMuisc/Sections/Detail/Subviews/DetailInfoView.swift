//
//  DetailInfoView.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/22.
//

import UIKit
import RxSwift
import SnapKit
import Then

final class DetailInfoView: DescendantView {
        
    private let disposeBag = DisposeBag()

    private lazy var titleLabel = UILabel().then {
        $0.text = NSLocalizedString("detail.basicInfo", comment: "")
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        addSubviews(titleLabel, descLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
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
    
    override func setupDI() {
        delegate?.outputRelay
            .compactMap { $0 as? DetailModel }
            .subscribe(onNext: { [weak self] detailModel in
                guard let `self` = self else { return }
                self.descLabel.text = self.makeInfoText(detail: detailModel)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func makeInfoText(detail: DetailModel) -> String {
        switch detail.detailType {
        case .artist:
            return makeArtistInfo(detail: detail)
        case .track:
            return makeTrackInfo(detail: detail)
        case .album:
            return makeAlbumInfo(detail: detail)
        default:
            return ""
        }
    }
    
    private func makeArtistInfo(detail: DetailModel) -> String {
        return
                """
                \(makeArtistName(detail: detail))
                \(makeTagNames(detail: detail))
                """
    }
    
    private func makeTrackInfo(detail: DetailModel) -> String {
        return
                """
                \(makeTrackName(detail: detail))
                \(makeArtistName(detail: detail))
                \(makeDuration(detail: detail))
                \(makeListener(detail: detail))
                \(makePlayCount(detail: detail))
                \(makeTagNames(detail: detail))
                """
    }
    
    private func makeAlbumInfo(detail: DetailModel) -> String {
        return
                """
                \(makeAlbumName(detail: detail))
                \(makeArtistName(detail: detail))
                \(makeListener(detail: detail))
                \(makePlayCount(detail: detail))
                \(makeTagNames(detail: detail))
                """
    }
    
    private func makeArtistName(detail: DetailModel) -> String {
        return "- 가수 : \(String(describing: detail.artistName ?? ""))"
    }
    
    private func makeTagNames(detail: DetailModel) -> String {
        
        var tags = "- 태그 : "
        
        guard let tag = detail.tags?.tag else {
            return ""
        }
        
        tag.forEach { tag in
            tags.append("#\(String(describing: tag.name ?? "")) ")
        }
        
        return tags
    }
    
    private func makeAlbumName(detail: DetailModel) -> String {
        return "- 앨범 이름 : \(String(describing: detail.name ?? ""))"
    }
    
    private func makeTrackName(detail: DetailModel) -> String {
        return "- 음원 이름 : \(String(describing: detail.name ?? ""))"
    }
    
    private func makeListener(detail: DetailModel) -> String {
        return "- 이용자 : \(String(describing: detail.listeners ?? ""))"
    }
    
    private func makePlayCount(detail: DetailModel) -> String {
        return "- 재생 횟수 : \(String(describing: detail.playcount ?? ""))"
    }
    
    private func makeDuration(detail: DetailModel) -> String {
        var time = ""
        if let sec = detail.duration {
            time = "\(sec)초"
        }
        return "- 시간 : \(time)"
    }
}
