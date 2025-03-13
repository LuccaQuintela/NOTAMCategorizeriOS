//
//  ViewsAndModifiers.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 11/19/24.
//

import Foundation
import SwiftUICore
import SwiftUI

struct SectionHeader: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .font(.headline)
    }
}

struct SimpleNavigationLink: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .font(.title2)
            .padding()
    }
}

struct AddNavBar: ViewModifier {
    let title: String
    
    func body(content: Content) -> some View {
        return content
            .toolbarColorScheme(.dark)
            .navigationTitle(title)
            .toolbarBackground(.accent, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

struct NotamNavLink: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .font(.title3)
    }
}

struct NotamDisplay: ViewModifier {
    let isList: Bool
    
    func body(content: Content) -> some View {
        return content
            .font(isList ? .title3 : .title)
            .bold()
            .padding()
    }
}

struct CustomButtonStyle: ViewModifier {
    let isLarge: Bool
    
    func body(content: Content) -> some View {
        return content
            .bold()
            .font(.title)
            .padding(.vertical, isLarge ? 25 : 10)
            .padding(.horizontal, isLarge ? 40 : 15)
            .background(.accent)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .foregroundStyle(.white)
    }
}

struct CustomTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.accent, lineWidth: 4)
                    .padding(.horizontal, 8)
                    
            )
            .foregroundStyle(.themeAccent)
    }
}

extension View {
    func sectionHeaderStyle() -> some View {
        return modifier(SectionHeader())
    }
    
    func simpleLinkStyle() -> some View {
        return modifier(SimpleNavigationLink())
    }
    
    func addNavBar(_ title: String) -> some View {
        return modifier(AddNavBar(title: title))
    }
    
    func notamLinkStyle() -> some View {
        return modifier(NotamNavLink())
    }
    
    func displayNotam(isList: Bool) -> some View {
        return modifier(NotamDisplay(isList: isList))
    }
    
    func defaultButtonStyle(large: Bool = false) -> some View {
        return modifier(CustomButtonStyle(isLarge: large))
    }
    
    func textFieldStyle() -> some View {
        return modifier(CustomTextFieldStyle())
    }
}

struct ExecuteCode: View {
    init(_ codeToExec: () -> ()) {
        codeToExec()
    }
    
    var body: some View {
        EmptyView()
    }
}

struct logoListFooter: View {
    var body: some View {
        Section {
            EmptyView()
        } footer: {
            HStack{
                Spacer()
                Image("LogoWithBoeingName")
                Spacer()
            }
        }
    }
}

struct DropDownMenu: View {
    @State private var selectedOption: String = "Single Output DistilBERT"
    let options = ["Single Output DistilBERT", "Multi Output DistilBERT", "MiniLM", "Evan Model"]
    
    var model: Model {
        switch selectedOption {
        case "Single Output DistilBERT": return Model.SingleOutputDistilBERT
        case "Multi Output DistilBERT": return Model.MultiOutputDistilBERT
        case "MiniLM": return Model.MiniLM
        case "Evan Model": return Model.EvanModel
        default: return Model.EvanModel
        }
    }
    
    var body: some View {
        Picker("Select a Model", selection:  $selectedOption) {
            ForEach(options, id: \.self) { option in
                Text(option).tag(option)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .onChange(of: selectedOption) {
            ChosenModel.shared.switchModel(to: model)
            DecodedNotamViewModel.shared.updateModelSelection()
        }
    }
}
