//
//  Home.swift
//  NavigationSheetApp
//
//  Created by Savva Shuliatev on 05.12.2023.
//

import SwiftUI

struct Home: View {
  /// View properties
  @State private var showSheet = false
  @State private var emailAddress = ""
  @State private var password = ""
  @State private var alreadyHavingAccount: Bool = false
  @State private var sheetHeight: CGFloat = .zero
  @State private var sheetFirstPageHeight: CGFloat = .zero
  @State private var sheetSecondPageHeight: CGFloat = .zero
  @State private var sheetScrollProgress: CGFloat = .zero

  @State private var isKeyboardShowing: Bool = false
  var body: some View {
    VStack {
      Spacer()

      Button("Show sheet") {
        showSheet.toggle()
      }
      .buttonStyle(.borderedProminent)
    }
    .sheet(isPresented: $showSheet, onDismiss: {
      /// Resetting Properties
      sheetHeight = .zero
      sheetFirstPageHeight = .zero
      sheetSecondPageHeight = .zero
      sheetScrollProgress = .zero
    }) {
      GeometryReader(content: { geometry in
        let size = geometry.size
        ScrollViewReader(content: { proxy in
          ScrollView(.horizontal) {
            HStack(alignment: .top , spacing: 0) {
              OnBoarding(size: size)
                .id("First page")
              LoginView(size: size)
                .id("Second page")
            }
            .scrollTargetLayout()
          }
          .scrollTargetBehavior(.paging)
          .scrollIndicators(.hidden)
          .scrollDisabled(isKeyboardShowing)
          .overlay(alignment: .topTrailing) {
            Button(action: {
              if sheetScrollProgress < 1 {
                /// Continue Button
                withAnimation(.snappy) {
                  proxy.scrollTo("Second page", anchor: .leading)
                }
              } else {
                /// Get started button
              }
            }, label: {
              Text("Continue")
                .fontWeight(.semibold)
                .opacity(1 - sheetScrollProgress)
                .frame(width: 120 + sheetScrollProgress * (alreadyHavingAccount ? 0 : 50))
                .overlay {
                  HStack(spacing: 8) {
                    Text(alreadyHavingAccount ? "Login" : "Get started")
                    Image(systemName: "arrow.right")
                  }
                  .fontWeight(.semibold)
                  .opacity(sheetScrollProgress)
                }
                .padding(.vertical, 12)
                .foregroundStyle(.white)
                .background(.linearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing), in: .capsule)
            })
            .padding(15)
            .offset(y: sheetHeight - 100)
            .offset(y: sheetScrollProgress * -120)
          }
        })
      })
      .presentationCornerRadius(30)
      .presentationDetents(sheetHeight == .zero ? [.medium] :  [.height(sheetHeight)])
      .interactiveDismissDisabled()
      .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification), perform: { _ in
        isKeyboardShowing = true
      })
      .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification), perform: { _ in
        isKeyboardShowing = false
      })
    }
  }

  @ViewBuilder
  func OnBoarding(size: CGSize) -> some View {
    VStack(alignment: .leading, spacing: 12, content: {
      Text("Know Everything\nabout the weather")
        .font(.largeTitle.bold())
        .lineLimit(2)

      Text(attributedSubTitle)
        .font(.callout)
        .foregroundStyle(.gray)
    })
     .padding(15)
    .padding(.horizontal, 10)
    .padding(.top, 15)
    .padding(.bottom, 130)
    .frame(width: size.width, alignment: .leading)
    .heightChangePreference { height in
      sheetFirstPageHeight = height
      sheetHeight = height
    }
  }

  var attributedSubTitle: AttributedString {
    let string = "Start now and learn more about local weather instantly"
    var attributedString = AttributedString(stringLiteral: string)
    if let range = attributedString.range(of: "local weather") {
      attributedString[range].foregroundColor = .black
      attributedString[range].font = .callout.bold()
    }

    return attributedString
  }

  @ViewBuilder
  func LoginView(size: CGSize) -> some View {
    VStack(alignment: .leading, spacing: 12) {
       Text("Create an Account")
        .font(.largeTitle.bold())

      CustomTF(hint: "Email Address", text: $emailAddress , icon: "envelope")
        .padding(.top, 20)

      CustomTF(hint: "*****", text: $password , icon: "lock", isPassword: true)
        .padding(.top, 20)
    }
    .padding(15)
    .padding(.horizontal, 10)
    .padding(.top, 15)
    .padding(.bottom, 220)
    .overlay(alignment: .bottom, content: {
      /// Other Login/Signup view
      VStack(spacing: 15) {
        Group {
          if alreadyHavingAccount {
            HStack(spacing: 4) {
              Text("Dont having account?")
                .foregroundStyle(.gray)

              Button("Create an account") {
                withAnimation(.snappy) {
                  alreadyHavingAccount.toggle()
                }
              }
              .tint(.red)
            }
            .transition(.push(from: .bottom))
          } else {
            HStack(spacing: 4) {
              Text(alreadyHavingAccount ? "Login" : "Already having account?")
                .foregroundStyle(.gray)

              Button("Login") {
                withAnimation(.snappy) {
                  alreadyHavingAccount.toggle()
                }
              }
              .tint(.red)
            }
            .transition(.push(from: .top))
          }
        }
        .font(.callout)
        .textScale(.secondary)
        .padding(.bottom, alreadyHavingAccount ? 0 : 15)

        if !alreadyHavingAccount {
          Text("By signing up, you are agreeing to out **[Terms & Condition](https://apple.com)** and **[Privacy Policy](https://apple.com)**")
            .font(.caption)
            .tint(.red)
            .foregroundStyle(.gray)
            .transition(.offset(y: 100))
        }
      }
      .padding(.bottom, 15)
      .padding(.horizontal, 20)
      .multilineTextAlignment(.center)
      .frame(width: size.width)
    })
    .frame(width: size.width)
    .heightChangePreference { height in
      sheetSecondPageHeight = height

      /// Just in case, if the Second page height is changed
      let diff = sheetSecondPageHeight - sheetFirstPageHeight
      sheetHeight = sheetFirstPageHeight + (diff * sheetScrollProgress)
    }
    .minXChangePreference { minX in
      let diff = sheetSecondPageHeight - sheetFirstPageHeight
      let truncatedMinX = min(size.width - minX, size.width)
      guard truncatedMinX > 0 else { return }

      let progress = truncatedMinX / size.width
      sheetScrollProgress = progress

      sheetHeight = sheetFirstPageHeight + (diff * progress)
    }
  }
}

#Preview {
  ContentView()
}

struct CustomTF: View {
  var hint: String
  @Binding var text: String
  var icon: String
  var isPassword: Bool = false
  var body: some View {
    VStack(alignment: .leading, spacing: 12, content: {
      if isPassword {
        SecureField(hint, text: $text)
      } else {
        TextField(hint, text: $text)
      }

      Divider()
    })
    .overlay(alignment: .trailing) {
      Image(systemName: icon)
        .foregroundStyle(.gray)
    }
  }
}
