class DMSSettingsViewModel: ObservableObject {
    @Published var enabled: Bool = false {
        didSet { checkDirtyState() }
    }

    @Published var username: String = "" {
        didSet { checkDirtyState() }
    }

    @Published var password: String = "" {
        didSet { checkDirtyState() }
    }

    @Published var batchSize: Int = 1 {
        didSet { checkDirtyState() }
    }

    @Published var apiZone: EversenseApiZone = .US {
        didSet { checkDirtyState() }
    }

    @Published var eversenseNowUsers: [NowFollowerUI] = []

    @Published var isDirty: Bool = false
    @Published var error: String = ""
    @Published var isLoading: Bool = false
    @Published var removeConfirmationSheet: Bool = false
    @Published var inviteNowSheet: Bool = false {
        didSet { updateFollowers() }
    }

    @Published var followerToBeRemoved: NowFollowerUI? = nil

    let batchSizeOptions: [Int] = [1, 3, 6, 12]

    let inviteNowViewModel: InviteNowViewModel
    private let cgmManager: EversenseCGMManager
    init(cgmManager: EversenseCGMManager, inviteNowViewModel: InviteNowViewModel) {
        self.cgmManager = cgmManager
        self.inviteNowViewModel = inviteNowViewModel

        stateDidUpdate(cgmManager.state)
        updateFollowers()
        cgmManager.addStateObserver(state: self, queue: DispatchQueue.main)
    }

    deinit {
        cgmManager.removeStateObserver(state: self)
    }

    func updateFollowers() {
        Task {
            let result = await DMSApi.updateFollowers(cgmManager: cgmManager)
            await MainActor.run {
                self.eversenseNowUsers = result
            }
        }
    }

    func confirmRemoveFollower(follower: NowFollowerUI) {
        followerToBeRemoved = follower
        removeConfirmationSheet = true
    }

    func testCredentials() {
        isLoading = true

        Task {
            do {
                _ = try await AuthenticationApi.login(cgmManager: cgmManager, username: username, password: password)
                await MainActor.run {
                    self.error = ""
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    func removeFollower() {
        guard let follower = followerToBeRemoved else {
            return
        }

        Task {
            await DMSApi.removeFollower(cgmManager: cgmManager, email: follower.FollowerEmail)
            let result = await DMSApi.updateFollowers(cgmManager: cgmManager)

            await MainActor.run {
                self.eversenseNowUsers = result
            }
        }
    }

    func save() {
        cgmManager.keychain.setEversenseCredentials(credentials: Credentials(username: username, password: password))
        cgmManager.updateState {
            $0.shouldUploadToEversenseDMS = enabled
            $0.apiZone = apiZone
            $0.uploadBatchSize = batchSize
            $0.accessToken = nil
            $0.accessTokenExpiration = nil
        }

        updateFollowers()
    }

    private func checkDirtyState() {
        let credentials = cgmManager.keychain.getEversenseCredentials()
        DispatchQueue.main.async {
            self.isDirty = (
                self.cgmManager.state.shouldUploadToEversenseDMS != self.enabled ||
                    credentials?.username != self.username ||
                    credentials?.password != self.password ||
                    self.cgmManager.state.uploadBatchSize != self.batchSize ||
                    self.cgmManager.state.apiZone != self.apiZone
            )
        }
    }
}

extension DMSSettingsViewModel: StateObserver {
    func stateDidUpdate(_ state: EversenseCGMState) {
        let credentials = cgmManager.keychain.getEversenseCredentials()
        DispatchQueue.main.async {
            self.enabled = state.shouldUploadToEversenseDMS
            self.username = credentials?.username ?? ""
            self.password = credentials?.password ?? ""
            self.batchSize = state.uploadBatchSize
            self.apiZone = state.apiZone
            self.checkDirtyState()
        }
    }
}
