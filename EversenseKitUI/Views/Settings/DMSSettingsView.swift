import LoopKitUI
import SwiftUI

struct DMSSettingsView: View {
    @ObservedObject var viewModel: DMSSettingsViewModel
    @State var edittingBatchSize: Bool = false

    var confirmationSheet: ActionSheet {
        ActionSheet(
            title: Text(String(
                format: String(localized: "Remove follower %@", comment: "title for removing EversenseNow follower"),
                viewModel.followerToBeRemoved?.ReferenceName ?? ""
            )),
            message: Text(
                "Are you sure you want to remove this follower from your Eversense NOW sharing?",
                comment: "description for removing EversenseNow follower"
            ),
            buttons: [
                .destructive(
                    Text("Confirm", comment: "Confirmation label")
                ) {
                    viewModel.removeFollower()
                },
                .cancel()
            ]
        )
    }

    var body: some View {
        VStack {
            List {
                Section {
                    Toggle(isOn: $viewModel.enabled) {
                        Text("Allow upload to Eversense DMS", comment: "toggle enable DMS")
                    }

                    if viewModel.enabled {
                        HStack {
                            Text("Email Address", comment: "Label for email address")
                            TextField(String(""), text: $viewModel.username)
                                .textContentType(.emailAddress)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.trailing)
                        }

                        HStack {
                            Text("Password", comment: "Label for password")
                            SecureField(String(""), text: $viewModel.password)
                                .textContentType(.password)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.trailing)
                        }

                        HStack {
                            Text("Upload Delay", comment: "DMS batching label")
                                .foregroundStyle(edittingBatchSize ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
                            Spacer()
                            Text(formatBatchSize(viewModel.batchSize))
                                .foregroundStyle(edittingBatchSize ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                        }
                        .onTapGesture {
                            withAnimation {
                                edittingBatchSize.toggle()
                            }
                        }

                        if edittingBatchSize {
                            Picker(selection: $viewModel.batchSize) {
                                ForEach(viewModel.batchSizeOptions, id: \.self) { item in
                                    Text(formatBatchSize(item))
                                }
                            } label: { EmptyView() }
                            .pickerStyle(.wheel)
                        }
                    }

                    Button { viewModel.save() } label: {
                        Text("Save", comment: "label save")
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!viewModel.isDirty)
                } footer: {
                    Text(
                        "Increasing the Upload Delay will lower the Internet usage, but gives the Eversense DMS a small delay",
                        comment: "batch size hint"
                    )
                }

                if viewModel.enabled {
                    Section {
                        if viewModel.isLoading {
                            ActivityIndicator(isAnimating: .constant(true), style: .medium)
                        } else {
                            ForEach(viewModel.eversenseNowUsers) { user in
                                HStack {
                                    Text(
                                        user
                                            .ReferenceName +
                                            (user.isPending ? String(localized: " (Pending)", comment: "pending") : "")
                                    )

                                    if !user.isPending {
                                        Spacer()
                                        Button(action: { viewModel.confirmRemoveFollower(follower: user) }) {
                                            Image(systemName: "trash")
                                                .foregroundStyle(.red)
                                        }
                                    }
                                }
                            }

                            HStack {
                                Label("Invite follower", systemImage: "plus")
                                    .foregroundStyle(.tint)
                            }
                            .onTapGesture {
                                viewModel.inviteNowSheet.toggle()
                            }
                        }

                    } header: {
                        Text("Eversense NOW", comment: "Eversense NOW section")
                    }
                }
            }
        }
        .navigationTitle(String(localized: "DMS Settings", comment: "DMS header"))
        .actionSheet(isPresented: $viewModel.removeConfirmationSheet) {
            confirmationSheet
        }
        .sheet(isPresented: $viewModel.inviteNowSheet) {
            NowInviteSheet(viewModel: viewModel.inviteNowViewModel)
        }
    }

    func formatBatchSize(_ size: Int) -> String {
        switch size {
        case 1: return String(localized: "None", comment: "Batch size - directly")
        case 3: return String(localized: "15 minutes", comment: "Batch size - 15min")
        case 6: return String(localized: "30 minutes", comment: "Batch size - 30min")
        case 12: return String(localized: "1 hour", comment: "Batch size - 1 hour")
        default: return ""
        }
    }
}
