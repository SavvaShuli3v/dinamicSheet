//
//  SizeKey.swift
//  NavigationSheetApp
//
//  Created by Savva Shuliatev on 05.12.2023.
//

import SwiftUI

struct SizeKey: PreferenceKey {
  static var defaultValue: CGFloat = .zero
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}
