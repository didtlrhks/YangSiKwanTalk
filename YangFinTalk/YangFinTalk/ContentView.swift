//
//  ContentView.swift
//  YangFinTalk
//
//  Created by 양시관 on 2023/12/25.
//

import SwiftUI

struct ContentView: View {
    
    @State var isLoginMode = false
    @State var Email = ""
    @State var password = ""
    var body: some View {
        NavigationView{
            ScrollView{
                
                VStack{
                    Picker(selection: $isLoginMode  , label: Text("Picker here")){
                        Text("Login")
                            .tag(true)
                        Text("create Account")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                        .padding()
                    
                    Button{
                        
                    } label: {
                        Image(systemName: "person.fill")
                            .font(.system(size:64))
                            .padding()
                    }
                    TextField("Email", text: $Email)
                    TextField("password", text: $password)
                    
                    Button{
                        
                    } label: {
                        HStack{
                            Spacer()
                            Text("Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical,10)
                            Spacer()
                        }.background(Color.blue)
                    }
                 
                    Text("로그인 페이지")
                
                }.padding()
        }
        .navigationTitle("Create Account")
        
    }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
