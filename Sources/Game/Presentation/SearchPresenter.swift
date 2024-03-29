//
//  SearchPresenter.swift
//
//
//  Created by Naufal Abiyyu on 22/12/23.
//

import SwiftUI
import Combine
import Core

public class SearchPresenter<Response, Interactor: UseCase>: ObservableObject
where Interactor.Request == String, Interactor.Response == [Response] {
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let _useCase: Interactor
    
    @Published public var list: [Response] = []
    @Published public var errorMessage: String = ""
    @Published public var isLoading: Bool = false
    @Published public var isError: Bool = false

    @Published public var searchText = ""
    
    public init(useCase: Interactor) {
        _useCase = useCase
    }
    
    public func search() {
        isLoading = true
        _useCase.execute(request: searchText)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.isLoading = false
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isError = true
                    self.isLoading = false
                }
            }, receiveValue: { list in
                self.list = list
                debugPrint(list)
            })
            .store(in: &cancellables)
    }
}
