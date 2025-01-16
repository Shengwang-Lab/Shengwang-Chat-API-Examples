//
//  AgoraChatSendVoiceViewController.swift
//  ShengwangChatApiExample
//
//  Created by 朱继超 on 1/16/25.
//

import UIKit
import AVFoundation
import AgoraChat
import ZSwiftBaseLib

class AgoraChatSendVoiceViewController: UIViewController {
    
    // MARK: - Properties
    private var isRecording = false
    private var recordingStartTime: Date?
    private let audioTools = AudioTools.shared
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.register(AudioMessageCell.self, forCellReuseIdentifier: "AudioMessageCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var recordButton: UIButton = {
        let button = UIButton()
        button.setTitle("按住录音", for: .normal)
        button.setTitle("松开发送", for: .highlighted)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var recordingTimer: Timer?
    
    private var messages: [AgoraChatMessage] = [AgoraChatMessage]()
    
    private var conversation: AgoraChatConversation?
    
    convenience init(_ conversationId: String) {
        self.init()
        self.conversation = AgoraChatClient.shared().chatManager?.getConversationWithConvId(conversationId)
        let messages = self.conversation?.loadMessagesStart(fromId: "", count: 50, searchDirection: AgoraChatMessageSearchDirection.init(rawValue: 0)!) ?? []
        for message in messages {
            if message.body.type == .voice {
                self.messages.append(message)
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        audioTools.playRecording {
            <#code#>
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        view.addSubview(recordButton)
        view.addSubview(timerLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.widthAnchor.constraint(equalToConstant: 100),
            recordButton.heightAnchor.constraint(equalToConstant: 50),
            
            tableView.bottomAnchor.constraint(equalTo: recordButton.topAnchor, constant: -20),
            
            timerLabel.bottomAnchor.constraint(equalTo: recordButton.topAnchor, constant: -8),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupGestures() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        recordButton.addGestureRecognizer(longPress)
    }
    
    // MARK: - Recording Handlers
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            startRecording()
        case .ended, .cancelled:
            stopRecording()
        default:
            break
        }
    }
    
    private func startRecording() {
        isRecording = true
        recordingStartTime = Date()
        audioTools.startRecording()
        startTimer()
    }
    
    private func stopRecording() {
        isRecording = false
        audioTools.stopRecording()
        stopTimer()
        
        if let url = audioTools.audioFileURL {
            let duration = Date().timeIntervalSince(recordingStartTime ?? Date())
            let body = AgoraChatVoiceMessageBody(localPath: url.path, displayName: "voice")
            body.duration = Int32(duration)
            let voiceMessage = AgoraChatMessage(conversationID: conversation?.conversationId ?? "", body: body, ext: nil)
            AgoraChatClient.shared().chatManager?.send(voiceMessage, progress: nil,completion: { [weak self] message, error in
                if error == nil,let message = message {
                    self?.messages.append(message)
                    self?.tableView.reloadData()
                } else {
                    print("\(error?.errorDescription ?? "")")
                }
            })
            
        }
    }
    
    private func startTimer() {
        timerLabel.text = "00:00"
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self,
                  let startTime = self.recordingStartTime else { return }
            let duration = Date().timeIntervalSince(startTime)
            self.updateTimerLabel(duration: duration)
        }
    }
    
    private func stopTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        timerLabel.text = "00:00"
    }
    
    private func updateTimerLabel(duration: TimeInterval) {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - UITableView DataSource & Delegate
extension AgoraChatSendVoiceViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioMessageCell", for: indexPath) as! AudioMessageCell
        let message = messages[indexPath.row]
        cell.configure(message: message)
        cell.delegate = self
        cell.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - AudioMessageCellDelegate
extension AgoraChatSendVoiceViewController: AudioMessageCellDelegate {
    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let index = tableView.indexPath(for: cell)?.row else { return }
        let message = messages[index]
        
        audioTools.playRecording {
            cell.updatePlayButtonState(isPlaying: false)
        }
    }
}
