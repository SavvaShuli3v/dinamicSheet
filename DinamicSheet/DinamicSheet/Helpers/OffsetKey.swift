//
//  OffsetKey.swift
//  NavigationSheetApp
//
//  Created by Savva Shuliatev on 05.12.2023.
//

import SwiftUI

struct OffsetKey: PreferenceKey {
  static var defaultValue: CGFloat = .zero
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}
