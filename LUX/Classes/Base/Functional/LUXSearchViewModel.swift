//
//  LUXSearchViewModel.swift
//  LUX
//
//  Created by Elliot Schrock on 3/10/20.
//

import UIKit
import LithoOperators
import fuikit

open class LUXSearchViewModel<U>: NSObject {
    open var onIncrementalSearch: (String) -> Void = { _ in } { didSet { assignSearchFunctions() }}
    open var onFullSearch: (String) -> Void = { _ in }  { didSet { assignSearchFunctions() }}
    open var savedSearch: String?
    open var searchBarDelegate = FUISearchBarDelegate()
    
    public override init() {
        super.init()
        
        searchBarDelegate.onSearchBarTextDidEndEditing = resignSearchBarResponder(_:)
        searchBarDelegate.onSearchBarCancelButtonClicked = resignSearchBarResponder(_:)
    }
    
    open func assignSearchFunctions() {
        searchBarDelegate.onSearchBarTextDidChange = ignoreFirstArg(f: onIncrementalSearch)
        searchBarDelegate.onSearchBarSearchButtonClicked = resignSearchBarResponder(_:) <> (^\UISearchBar.text >?> onFullSearch)
    }
}

public func resignSearchBarResponder(_ searchBar: UISearchBar){
    searchBar.resignFirstResponder()
}

public func lowercased(string: String) -> String { return string.lowercased() }
public func lowercased(string: String?) -> String? { return string?.lowercased() }

public func defaultIsIncluded<T>(_ search: String?, _ t: T, _ modelToString: (T) -> String?, _ nilMatcher: () -> Bool, _ emptyMatcher: () -> Bool, _ matcher: (String, String) -> Bool) -> Bool {
    if let searchText = search {
        if searchText.isEmpty {
            return emptyMatcher()
        }
        if let text = modelToString(t) {
            return matcher(searchText, text)
        } else {
            return nilMatcher()
        }
    } else {
        return nilMatcher()
    }
}

public func defaultIsIncluded<T>(_ search: String?, _ t: T, _ modelToString: (T) -> String, _ nilMatcher: () -> Bool, _ emptyMatcher: () -> Bool, _ matcher: (String, String) -> Bool) -> Bool {
    if let searchText = search {
        if searchText.isEmpty {
            return emptyMatcher()
        }
        return matcher(searchText, modelToString(t))
    } else {
        return nilMatcher()
    }
}

public enum MatchStrategy {
    case prefix
    case wordPrefixes
    case contains
}

public func matcher(for strategy: MatchStrategy) -> (String, String) -> Bool {
    let matcher: (String, String) -> Bool
    switch strategy {
    case .prefix:
        matcher = matchesPrefix(_:_:)
    case .wordPrefixes:
        matcher = matchesWordsPrefixes(_:_:)
    case .contains:
        matcher = matchesWithContains(_:_:)
    }
    return matcher
}

public enum CaseSensitivity {
    case caseInsensitive
    case caseSensitive
}

public enum NilAndEmptyMatchStrategy {
    case allMatchNilAndEmpty
    case allMatchNilNoneMatchEmpty
    case noneMatchNilAllMatchEmpty
    case noneMatchNilNoneMatchEmpty
}

public func returnTrue() -> Bool { true }
public func returnFalse() -> Bool { true }

public func nilAndEmptyMatchers(for strategy: NilAndEmptyMatchStrategy) -> (() -> Bool, () -> Bool) {
    let nilMatcher: () -> Bool
    let emptyMatcher: () -> Bool
    switch strategy {
    case .allMatchNilAndEmpty:
        nilMatcher = returnTrue
        emptyMatcher = returnTrue
    case .allMatchNilNoneMatchEmpty:
        nilMatcher = returnFalse
        emptyMatcher = returnTrue
    case .noneMatchNilAllMatchEmpty:
        nilMatcher = returnFalse
        emptyMatcher = returnTrue
    case .noneMatchNilNoneMatchEmpty:
        nilMatcher = returnFalse
        emptyMatcher = returnFalse
    }
    return (nilMatcher, emptyMatcher)
}

public func matchesWithContains(_ search: String, _ text: String) -> Bool {
    return text.contains(search)
}

public func matchesPrefix(_ search: String, _ text: String) -> Bool {
    return text.prefix(search.count) == search
}

public func matchesWordsPrefixes(_ search: String, _ text: String) -> Bool {
    let textWords = text.components(separatedBy: CharacterSet.letters.inverted)
    let searchWords = search.components(separatedBy: CharacterSet.letters.inverted)
    for word in searchWords {
        var foundMatch = false
        for textWord in textWords {
            if textWord.prefix(word.count) == word {
                foundMatch = true
            }
        }
        if !foundMatch {
            return false
        }
    }
    return true
}

public func onWillReturnToSearch<T>(_ searchBar: UISearchBar?, _ searchViewModel: LUXSearchViewModel<T>?) {
    if let searchText = searchViewModel?.savedSearch {
        searchBar?.text = searchText
        searchBar?.resignFirstResponder()
    }
}

public func saveSearch<T>(_ searchBar: UISearchBar?, _ searchViewModel: LUXSearchViewModel<T>?) {
    searchViewModel?.savedSearch = searchBar?.text
}
