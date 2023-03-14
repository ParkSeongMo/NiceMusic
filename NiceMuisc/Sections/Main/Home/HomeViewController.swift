//
//  HomeViewController.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/02.
//

import RxCocoa
import RxSwift
import UIKit
import SnapKit
import Moya

class HomeViewController: UIViewController {
            
    let disposeBag = DisposeBag()
    
    private let viewModel:HomeViewModel
    
    private lazy var homeView = HomeView()
    
    private lazy var artistDetailApiButton = UIButton().then {
        $0.setTitle("artist Detail", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .gray
    }
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("HomeViewController viewDidLoad()")
        setupLayout()
    }
    
    private func setupLayout() {
        self.view.backgroundColor = .brown
        
        self.view.addSubview(homeView)
        homeView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()            
        }
        
        
        
        self.view.addSubview(artistDetailApiButton)
        artistDetailApiButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-50)
            make.top.equalToSuperview().offset(100)
        }
        

        artistDetailApiButton.rx.tap
            .bind {
//                ServiceApi.Artist.top().subscribe { event in
//                ServiceApi.Artist.detail(artist: "BTS").subscribe { event in
//                ServiceApi.Artist.search(artist: "BTS").subscribe { event in
//                ServiceApi.Artist.top().subscribe { event in
//                ServiceApi.Artist.topLocal().subscribe { event in
//                ServiceApi.Album.detail(artist: "BTS", album: "Dynamite").subscribe { event in
//                ServiceApi.Album.search(album: "Dynamite").subscribe { event in
//                ServiceApi.Track.detail(artist: "Imagine Dragons", track: "Believer").subscribe { event in
//                ServiceApi.Track.search(track: "Believe").subscribe { event in
//                ServiceApi.Track.search(track: "Believe").subscribe { event in
                ServiceApi.Track.topLocal().subscribe { event in
                    switch event {
                    case .success(let json):
                        let name = self.paringName(data: json)
                        print("HomeViewController - success \(String(describing: name))")
                    case .failure(_):
                        print("HomeViewController - error")
                    }
                }.disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
    }
    
    private func paringName<T>(data: T) -> String? {
        switch data {
        case let someData as ArtistDetailModel:
            return someData.artist?.name
        case let someData as ArtistSearchModel:
            return someData.results?.artistmatches?.artist?[0].name
        case let someData as ArtistListModel:
            return someData.artists?.artist?[0].name
        case let someData as ArtistLocalTopListModel:
            return someData.topartists?.artist?[0].name
        case let someData as AlbumDetailModel:
            return someData.album?.name
        case let someData as AlbumSearchModel:
            return someData.results?.albummatches?.album?[0].name
        case let someData as TrackDetailModel:
            return someData.track?.name
        case let someData as TrackSearchModel:
            return someData.results?.trackmatches?.track?[0].name
        case let someData as TrackTopListModel:
            return someData.tracks?.track?[0].name
            
        default:
            return "none"
        }
    }
}

