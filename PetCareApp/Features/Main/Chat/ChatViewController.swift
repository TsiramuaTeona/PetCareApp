//
//  ChatViewController.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 15.01.26.
//


import UIKit

final class ChatViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: ChatViewModel
    private var messages: [ChatMessage] = []
    
    private var isTyping: Bool = false
    
    private var inputBottomConstraint: NSLayoutConstraint!
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        return tableView
    }()
    
    private let inputBar = ChatInputBar()
    
    // MARK: - Initializer
    
    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        title = "Pet Assistant"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Deinitializer
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        bindViewModel()
        setupKeyboardHandling()
        setupActions()
        setupNavBar()
        
        viewModel.onAppear()
    }
    
    // MARK: - Methods
    
    private func setupView() {
        view.backgroundColor = .mainBackground
        setupTableView()
        setupInputBar()
    }
    
    private func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(refreshTapped)
        )
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        
        appearance.shadowColor = UIColor.label.withAlphaComponent(0.15)
        appearance.shadowImage = UIImage()
        appearance.backgroundColor = .mainBackground
        
        navigationController?.navigationBar.standardAppearance = appearance
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.reuseId)
        tableView.register(TypingIndicatorCell.self, forCellReuseIdentifier: TypingIndicatorCell.reuseId)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    private func setupInputBar() {
        view.addSubview(inputBar)
        
        inputBottomConstraint = inputBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputBottomConstraint,
            
            tableView.bottomAnchor.constraint(equalTo: inputBar.topAnchor)
        ])
    }
    
    private func setupActions() {
        inputBar.onSend = { [weak self] text in
            self?.viewModel.send(text: text)
        }
    }
    
    private func bindViewModel() {
        viewModel.onMessagesUpdated = { [weak self] messages in
            guard let self else { return }
            self.messages = messages
            
            self.setTyping(false)
            
            self.tableView.reloadData()
            self.scrollToBottom(animated: true)
        }
        
        viewModel.onSendingChanged = { [weak self] sending in
            guard let self else { return }
            
            self.inputBar.sendButton.isEnabled = !sending
            self.inputBar.sendButton.alpha = sending ? 0.5 : 1.0
            self.setTyping(sending)
        }
        
        viewModel.onContextLoadingChanged = { [weak self] loading in
            guard let self else { return }
            self.setTyping(loading || self.isTyping)
            _ = loading
        }
    }
    
    private func setTyping(_ value: Bool) {
        guard isTyping != value else { return }
        isTyping = value
        
        tableView.reloadData()
        scrollToBottom(animated: true)
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    // MARK: - Actions
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }
        
        let endFrameInView = view.convert(endFrame, from: nil)
        let overlap = max(0, view.bounds.maxY - endFrameInView.minY)
        
        inputBottomConstraint.constant = -overlap
        
        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.view.layoutIfNeeded()
        }
        
        scrollToBottom(animated: true)
    }
    
    @objc private func refreshTapped() {
        viewModel.refreshContext()
    }
    
    // MARK: - Helpers
    
    private func scrollToBottom(animated: Bool) {
        let totalRows = messages.count + (isTyping ? 1 : 0)
        guard totalRows > 0 else { return }
        
        let indexPath = IndexPath(row: totalRows - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }
}

// MARK: - UITableViewDataSource

extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count + (isTyping ? 1 : 0)
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        if isTyping, indexPath.row == messages.count {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TypingIndicatorCell.reuseId,
                for: indexPath
            ) as! TypingIndicatorCell
            
            cell.startAnimating()
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ChatMessageCell.reuseId,
            for: indexPath
        ) as! ChatMessageCell
        
        cell.configure(with: messages[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ChatViewController: UITableViewDelegate { }
