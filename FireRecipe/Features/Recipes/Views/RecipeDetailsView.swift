//
//  RecipeDetailsView2.swift
//  FireRecipe
//
//  Created by Peter Friese on 06.10.22.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import FirebaseRemoteConfig
import FirebaseRemoteConfigSwift
import NukeUI

struct RecipeDetailsView: View {
  var recipe: Recipe
  @EnvironmentObject var router: NavigationRouter

  var body: some View {
    VStack {
      LazyImage(url: recipe.imageURL, resizingMode: .aspectFill)
        .frame(height: 300)
        .overlay(alignment: .topLeading) {
          Button(action: { router.path.removeLast() }) {
            Image(systemName: "xmark")
              .font(.title)
              .foregroundColor(Color(UIColor.systemGray))
              .padding(8)
              .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
          }
          .padding(.top, 40)
          .padding(.leading, 20)
        }
      Spacer()
    }
    .overlay {
      VStack {
        Spacer()
          .frame(height: 250)
        RecipeView(recipe: recipe)
          .background(Color(UIColor.systemBackground))
          .cornerRadius(16)
      }
    }
    .ignoresSafeArea()
    .navigationBarBackButtonHidden()
  }
}

enum RecipeSection : String, CaseIterable {
    case ingredients = "Ingredients"
    case instructions = "Instructions"
}

struct RecipeView: View {
  var recipe: Recipe
  @State private var sectionSelection = RecipeSection.ingredients

  var body: some View {
    VStack {
      RecipeTitleView(recipe: recipe)
        .padding(20)
      Picker("", selection: $sectionSelection) {
        ForEach(RecipeSection.allCases, id: \.self) { option in
          Text(option.rawValue)
        }
      }
      .pickerStyle(.segmented)
      .padding(.horizontal, 20)
      switch sectionSelection {
      case .ingredients:
        IngredientsView(recipe: recipe)
      case .instructions:
        InstructionsView(recipe: recipe)
      }
    }
  }
}

struct IngredientsView: View {
  var recipe: Recipe
  var body: some View {
    List {
      Section {
        ForEach(recipe.ingredients, id: \.self) { ingredient in
          Text(["\(ingredient.quantity)", ingredient.unit, ingredient.name].joined(separator: " "))
        }
      } header: {
        HStack {
          Text("Ingredients")
            .font(.title3)
          Spacer()
          Text("\(recipe.ingredients.count) items")
        }
      }
    }
    .listRowSeparator(.hidden)
    .listStyle(.plain)
  }
}

struct InstructionsView: View {
  @RemoteConfigProperty(key: "stepsStyle", fallback: "square") var stepsStyle: String
  var recipe: Recipe
  var body: some View {
    List {
      Section {
        ForEach(recipe.steps.indices, id: \.self) { index in
          Label(recipe.steps[index], systemImage: "\(index + 1).\(stepsStyle)")
        }
      } header: {
        HStack {
          Text("Instructions")
            .font(.title3)
          Spacer()
          Text("\(recipe.steps.count) steps")
        }
      }
    }
    .listRowSeparator(.hidden)
    .listStyle(.plain)
    .onAppear {
      RemoteConfig.remoteConfig().fetchAndActivate()
    }
  }
}

struct RecipeTitleView: View {
  var recipe: Recipe
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text(recipe.name)
          .font(.title)
          .bold()
        Spacer()
        Label("\(recipe.time) Min", systemImage: "clock")
      }
      if let description = recipe.description {
        Text(description)
      }
    }
  }
}

struct RecipeDetailsView2_Previews: PreviewProvider {
  static var previews: some View {
    RecipeDetailsView(recipe: Recipe.samples[0])
    RecipeView(recipe: Recipe.samples[0])
  }
}