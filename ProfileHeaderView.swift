import Kingfisher
import SwiftUI

struct ProfileHeaderView: View {
    @ObservedObject var viewModel: ProfileViewModel
    var body: some View {
        if viewModel.meJudge {
            HStack {
                //MARK: 自分のデータを表示する時
                Button {
                    viewModel.sceneHealthCharts()
                } label: {
                    Image(systemName: "waveform.path.ecg.rectangle")
                        .frame(width: 48, height: 48)
                        .background(Color(asset: Asset.Colors.white16))
                        .foregroundColor(Color(asset: Asset.Colors.white00))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .font(.system(size: 16, weight: .medium, design: .rounded))

                }
                .buttonStyle(.plain)

                Spacer()

                Button {
                    if #available(iOS 16.0, *) {
                        let renderer = ImageRenderer(content: ProfileCardView(viewModel: viewModel)
                            .padding()
                            .background(Asset.Assets.blue.swiftUIImage.resizable().scaledToFill())
                            .background(Asset.Colors.mainColor.swiftUIColor)
                            .foregroundColor(.white))
                        print(renderer.uiImage)
                        if let image = renderer.uiImage {
                            viewModel.renderedImage = image
                        }
                    }
                    //viewModel.shareSns()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .frame(width: 48, height: 48)
                        .background(Color(asset: Asset.Colors.white16))
                        .foregroundColor(Color(asset: Asset.Colors.white00))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                }
                .buttonStyle(.plain)
            }
            .listRowBackground(Color.clear)
        } else {
            //MARK: 友達のデータを表示する時
            HStack {
                Spacer()

                Button {
                    viewModel.alertType = .deleteFriendWarning
                    viewModel.showAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(Color.red)
                        .padding()
                        .background(Color(asset: Asset.Colors.white48))
                        .cornerRadius(20)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                }
                .alert(isPresented: $viewModel.showAlert) {
                    switch viewModel.alertType {
                    case .deleteFriendWarning:
                        return Alert(title: Text("警告"),
                                     message: Text("友達を削除しますか？"),
                                     primaryButton: .cancel(Text("キャンセル")),
                                     secondaryButton: .destructive(Text("削除"), action: { viewModel.friendDelete() }))
                    case .deletedFriend:
                        return Alert(title: Text("完了"), message: Text("友達を削除しました"),
                                     dismissButton: .default(Text("OK"), action: { viewModel.dismiss() }))
                    }
                }
            }
            .listRowBackground(Color.clear)
        }

        //MARK: - sharePointView
        ProfileCardView(viewModel: viewModel)
            .listRowBackground(Color.clear)

        //MARK: Buttons
        if viewModel.meJudge {
            HStack {
                Button {
                    viewModel.sceneChangeProfile()
                } label: {
                    HStack {
                        Image(systemName: "pencil")
                            .foregroundColor(.white)
                        Spacer()
                        Text("Edit Profile")
                            .foregroundColor(Color(asset: Asset.Colors.white00))
                        Spacer()
                    }
                    .padding()
                    .background(Color(asset: Asset.Colors.white16))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .frame(maxWidth: .infinity)
                }

                Button {
                    viewModel.sceneSetting()
                } label: {
                    HStack {
                        Image(systemName: "gearshape.2")
                            .foregroundColor(.white)
                        Spacer()
                        Text("Settings")
                            .foregroundColor(Color(asset: Asset.Colors.white00))
                        Spacer()
                    }
                    .padding()
                    .background(Color(asset: Asset.Colors.white16))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .frame(maxWidth: .infinity)
                }
            }
            .listRowBackground(Color.clear)

            if viewModel.renderedImage != nil {
                Image(uiImage: viewModel.renderedImage!)
                    .resizable()
                    .scaledToFill()
            }
        }
    }

    func DateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        return dateFormatter.string(from: date)
    }
}
