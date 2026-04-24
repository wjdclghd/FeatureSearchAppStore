//
//  SearchAppStoreCoordinatorProtocol.swift
//  FeatureSearchAppStore
//
//  Created by jch on 4/22/26.
//

import Foundation

/*
 SearchAppStore 목록 화면에서 사용하는 라우팅 계약입니다.

 이 프로토콜은 목록 화면이 상세 화면으로 이동할 때 필요한 최소 기능만 정의합니다.
 Feature 모듈은 이 계약만 알고,
 실제 화면 전환 구현과 다른 Feature 또는 App 레이어로의 이동 결정은
 App 레이어의 coordinator가 담당합니다.

 담당 역할
 - 목록 항목 선택 시 상세 화면 이동 요청 전달

 담당하지 않는 역할
 - NavigationStack, UINavigationController 직접 제어
 - 다른 Feature와의 조립
 - AppData, Networking 의존성 생성
 */
@MainActor
public protocol SearchAppStoreCoordinatorProtocol: AnyObject {
    func showSearchAppStoreDetail(trackId: Int)
}
