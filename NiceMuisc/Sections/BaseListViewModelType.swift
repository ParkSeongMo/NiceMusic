//
//  ListViewModelType.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/27.
//

import RxFlow
import RxRelay
import RxSwift

class BaseListViewModelType {
          
    // MARK: - Stepper
    var steps = RxRelay.PublishRelay<RxFlow.Step>()
    
    let disposeBag = DisposeBag()
        
    func parsingTitleToArtist(type: DetailType, title: String?, subTitle: String?, task:(DetailType, String?, String?)->MainSteps) {
        
        var artist = title
        var name = subTitle
        let list = [DetailType.track, DetailType.album]
        if list.contains(type) {
            artist = subTitle
            name = title
        }
        
        steps.accept(task(type, artist, name))
    }
    
    
}
