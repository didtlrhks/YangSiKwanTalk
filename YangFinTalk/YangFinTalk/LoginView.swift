

import SwiftUI
import Firebase
import FirebaseStorage
//import FirebaseStorageUI


class FirebaseManager: NSObject {
    
    let auth: Auth
    let storage : Storage
    
    
    static let shared = FirebaseManager()
    
    override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        
        super.init()
    }
    
}

struct LoginView: View {
    
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""
    
    @State var shouldShowImagePicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                VStack(spacing: 16) {
                    Picker(selection: $isLoginMode, label: Text("Picker here")) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    if !isLoginMode {
                        Button {
                            shouldShowImagePicker
                                .toggle()
                        } label: {
                            
                            VStack{
                                if let image = self.image{
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 128,height: 128)
                                        .cornerRadius(64)
                                }else{
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                        .foregroundColor(Color(.label))
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64)
                                .stroke(Color.black, lineWidth:3)
                                     
                            )
                        }
                    }
                    
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password)
                    }
                    .padding(12)
                    .background(Color.white)
                    
                    Button {
                        handleAction()
                    } label: {
                        HStack {
                            Spacer()
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }.background(Color.blue)
                        
                    }
                    Text(self.loginStatusMessage)
                        .foregroundColor(.red)
                }
                .padding()
                
            }
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05))
                .ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $shouldShowImagePicker,onDismiss: nil){
            ImagePicker(image : $image )
        }
    }
    
    @State var image : UIImage?
    
    private func handleAction() {
        if isLoginMode {
          //  print("Should log into Firebase with existing credentials")
            loginUser()
        } else {
            createNewAccount()
//            print("Register a new account inside of Firebase Auth and then store image in Storage somehow....")
        }
    }
    
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password){
            result , err in
            
            if let err = err {
                print("error",err)
                self.loginStatusMessage = "Failed to login user : \(err)"
                return
            }
            print("Successfully login user : \(result?.user.uid ?? "")")
            
            self.loginStatusMessage = "Successfully login user : \(result?.user.uid ?? "")"
            
           
        }
    }
    
    @State var loginStatusMessage = ""
    
    
    private func createNewAccount(){
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password){
            result, err in
            if let err = err {
                print("error",err)
                self.loginStatusMessage = "Failed to create user : \(err)"
                return
            }
            print("Successfully created user : \(result?.user.uid ?? "")")
            
            self.loginStatusMessage = "Successfully created user : \(result?.user.uid ?? "")"
            
            self.persistImageToStorage()
           
        }
    }
    
    private func persistImageToStorage(){
       // let filename = UUID().uuidString
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
        else{return}
        let ref = FirebaseManager.shared.storage.reference(withPath:uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else {return}
        ref.putData(imageData,metadata:nil){
            metadata, err in
            if let err = err{
                self.loginStatusMessage = "Failed to push image to Storage : \(err)"
                print(err)
                return
            }
            
            ref.downloadURL { url, err in
                if let err = err{
                    self.loginStatusMessage = "Failed to retrieve downloadURL : \(err)"
                   
                    return
                }
                
                self.loginStatusMessage = "Successfully sored image with url : \(url?.absoluteString ?? "")"
               
            }
        }
    }
    
}



struct ContentView_previews1: PreviewProvider{
    static var previews: some View{
        LoginView()
    }
}
