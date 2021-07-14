//
//  LUXSearcher.swift
//  LUX
//
//  Created by Elliot Schrock on 4/9/20.
//

import Combine
import Prelude
import LithoOperators
import Slippers
import FunNet

open class LUXSearcher<T>: LUXSearchable {
    @Published public var incrementalSearchText: String?
    @Published public var searchText: String?
    open var isIncluded: (String?, T) -> Bool
    
    public init(isIncluded: @escaping (String?, T) -> Bool) {
        self.isIncluded = isIncluded
    }
    
    public init(_ modelToString: @escaping (T) -> String?, _ nilAndEmptyStrategy: NilAndEmptyMatchStrategy, _ matchStrategy: MatchStrategy, _ isCaseSensitive: Bool = false) {
        let (nilMatcher, emptyMatcher) = nilAndEmptyMatchers(for: nilAndEmptyStrategy)
        let match = matcher(for: matchStrategy)
        
        if isCaseSensitive {
            isIncluded = { search, t in defaultIsIncluded(search, t, modelToString, nilMatcher, emptyMatcher, match)}
        } else {
            isIncluded = { search, t in
                defaultIsIncluded(search?.lowercased(), t, modelToString >>> lowercased(string:), nilMatcher, emptyMatcher, match)
            }
        }
    }
    
    public init(_ modelToString: @escaping (T) -> String, _ nilAndEmptyStrategy: NilAndEmptyMatchStrategy, _ matchStrategy: MatchStrategy, _ isCaseSensitive: Bool = false) {
        let (nilMatcher, emptyMatcher) = nilAndEmptyMatchers(for: nilAndEmptyStrategy)
        let match = matcher(for: matchStrategy)
        
        if isCaseSensitive {
            isIncluded = { search, t in defaultIsIncluded(search, t, modelToString, nilMatcher, emptyMatcher, match)}
        } else {
            isIncluded = { search, t in
                defaultIsIncluded(search?.lowercased(), t, modelToString >>> lowercased(string:), nilMatcher, emptyMatcher, match)
            }
        }
    }
    
    open func updateIncrementalSearch(text: String?) {
        incrementalSearchText = text
    }
    
    open func updateSearch(text: String?) {
        searchText = text
    }
    
    open func filter(_ t: T) -> Bool {
        guard let text = searchText, text != "" else {
            return true
        }
        return isIncluded(text, t)
    }
    
    open func filter(text: String?, array: [T]) -> [T] {
        guard let t = text, t != "" else {
            return array
        }
        return array.filter(t *-> isIncluded)
    }
    
    open func filter(tuple: (String?, [T])) -> [T] {
        return tuple |> ~filter(text:array:)
    }
}

extension LUXSearcher {
    open func filteredPublisher(from modelsPublisher: AnyPublisher<[T], Never>) -> AnyPublisher<[T], Never> {
        return $searchText.combineLatest(modelsPublisher).map(filter(tuple:)).eraseToAnyPublisher()
    }
    open func filteredIncrementalPublisher(from modelsPublisher: AnyPublisher<[T], Never>) -> AnyPublisher<[T], Never> {
        return $incrementalSearchText.combineLatest(modelsPublisher).map(filter(tuple:)).eraseToAnyPublisher()
    }
}
