//
//  ChatViewModel.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 15.01.26.
//

import Combine
import Foundation

final class ChatViewModel {
    
    // MARK: - Callback Properties
    
    var onMessagesUpdated: (([ChatMessage]) -> Void)?
    var onSendingChanged: ((Bool) -> Void)?
    var onContextLoadingChanged: ((Bool) -> Void)?
    
    // MARK: - State Properties
    
    private(set) var messages: [ChatMessage] = [] {
        didSet { onMessagesUpdated?(messages) }
    }
    
    private(set) var isSending: Bool = false {
        didSet { onSendingChanged?(isSending) }
    }
    
    private(set) var isLoadingContext: Bool = false {
        didSet { onContextLoadingChanged?(isLoadingContext) }
    }
    
    // MARK: - Dependency Properties
    
    private let authService: AuthServiceProtocol
    private let userService: UserServiceProtocol
    private let petService: PetServiceProtocol
    private let healthService: HealthServiceProtocol
    private let aiService: AIChatServiceProtocol
    
    // MARK: - Combine Properties
    
    private var householdListener: AnyCancellable?
    
    // MARK: - Task Properties
    
    private var contextLoadTask: Task<Void, Never>?
    
    // MARK: - Current State Properties
    
    private var currentHouseholdId: String?
    private var didStart = false
    
    // MARK: - Initializer
    
    init(
        authService: AuthServiceProtocol,
        userService: UserServiceProtocol,
        petService: PetServiceProtocol,
        healthService: HealthServiceProtocol,
        aiService: AIChatServiceProtocol
    ) {
        self.authService = authService
        self.userService = userService
        self.petService = petService
        self.healthService = healthService
        self.aiService = aiService
    }
    
    // MARK: - Public Methods
    
    func onAppear() {
        if !didStart {
            didStart = true
            post(ChatMessageProvider.welcome())
            
            let context = AIChatContextBuilder.build(pets: [], logsByPetId: [:])
            aiService.startSession(context: context)
        }
        
        startHouseholdListening()
    }
    
    func send(text: String) {
        let trimmed = text.trimmed
        guard !trimmed.isEmpty, !isSending else { return }
        
        post(ChatMessageProvider.user(trimmed))
        setSending(true)
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let reply = try await self.aiService.send(text: trimmed)
                await MainActor.run {
                    self.post(
                        reply.isEmpty
                        ? ChatMessageProvider.emptyReplyFallback()
                        : ChatMessageProvider.assistant(reply)
                    )
                    self.setSending(false)
                }
            } catch {
                await MainActor.run {
                    self.post(ChatMessageProvider.genericError())
                    self.setSending(false)
                }
            }
        }
    }
    
    func refreshContext() {
        contextLoadTask?.cancel()
        contextLoadTask = nil
        
        Task { @MainActor in
            self.resetChatForRefresh()
        }
        
        contextLoadTask = Task { [weak self] in
            guard let self else { return }
            await self.loadContext(householdId: self.currentHouseholdId)
        }
    }
    
    // MARK: - Private Methods
    
    private func startHouseholdListening() {
        stopHouseholdListening()
        
        guard let userId = authService.currentUserId, !userId.isEmpty else {
            post(ChatMessageProvider.systemWithoutPets())
            return
        }
        
        householdListener = userService.householdIdPublisher(userId: userId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] householdId in
                self?.handleHouseholdChange(householdId)
            }
    }
    
    private func stopHouseholdListening() {
        householdListener?.cancel()
        householdListener = nil
    }
    
    private func handleHouseholdChange(_ householdId: String?) {
        guard householdId != currentHouseholdId else { return }
        
        currentHouseholdId = householdId
        
        contextLoadTask?.cancel()
        contextLoadTask = nil
        
        contextLoadTask = Task { [weak self] in
            guard let self else { return }
            await self.loadContext(householdId: householdId)
        }
    }
    
    @MainActor
    private func resetChatForRefresh() {
        setSending(false)
        
        messages.removeAll()
        post(ChatMessageProvider.welcome())
        
        let emptyContext = AIChatContextBuilder.build(pets: [], logsByPetId: [:])
        aiService.startSession(context: emptyContext)
    }
    
    private func loadContext(householdId: String?) async {
        await MainActor.run { setLoadingContext(true) }
        defer { Task { @MainActor in setLoadingContext(false) } }
        
        do {
            guard let householdId, !householdId.isEmpty else {
                let context = AIChatContextBuilder.build(pets: [], logsByPetId: [:])
                aiService.startSession(context: context)
                
                await MainActor.run {
                    self.post(ChatMessageProvider.systemWithoutPets())
                }
                return
            }
            
            let pets = try await petService.getPets(forHousehold: householdId)
            
            var logsByPetId: [String: [HealthLog]] = [:]
            logsByPetId.reserveCapacity(pets.count)
            
            try await withThrowingTaskGroup(of: (String, [HealthLog]).self) { group in
                for pet in pets {
                    guard let petId = pet.id, !petId.isEmpty else { continue }
                    group.addTask(priority: .utility) { [healthService] in
                        let logs = try await healthService.fetchLogs(petId: petId)
                        return (petId, logs)
                    }
                }
                
                for try await (petId, logs) in group {
                    logsByPetId[petId] = logs
                }
            }
            
            let context = AIChatContextBuilder.build(pets: pets, logsByPetId: logsByPetId)
            aiService.startSession(context: context)
            
            await MainActor.run {
                if pets.isEmpty {
                    self.post(ChatMessageProvider.systemWithoutPets())
                } else {
                    self.post(ChatMessageProvider.systemWithPets(petNames: pets.map(\.name)))
                }
            }
            
        } catch is CancellationError {
            
        } catch {
            let context = AIChatContextBuilder.build(pets: [], logsByPetId: [:])
            aiService.startSession(context: context)
            
            await MainActor.run {
                self.post(ChatMessageProvider.systemWithoutPets())
            }
        }
    }
    
    private func setSending(_ value: Bool) {
        isSending = value
    }
    
    private func setLoadingContext(_ value: Bool) {
        isLoadingContext = value
    }
    
    private func post(_ message: ChatMessage) {
        messages.append(message)
    }
}
