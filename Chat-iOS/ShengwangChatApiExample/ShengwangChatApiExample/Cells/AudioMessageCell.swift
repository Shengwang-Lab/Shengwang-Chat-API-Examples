//
//  AudioMessageCell.swift
//  ShengwangChatApiExample
//
//  Created by 朱继超 on 1/16/25.
//
import UIKit
import AgoraChat

// MARK: - AudioMessageCell
protocol AudioMessageCellDelegate: AnyObject {
    func didTapPlayButton(in cell: AudioMessageCell)
}

class AudioMessageCell: UITableViewCell {
    
    weak var delegate: AudioMessageCellDelegate?
    
    private var isPlaying = false {
        didSet {
            updatePlayButtonState(isPlaying: isPlaying)
        }
    }
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(playButton)
        contentView.addSubview(durationLabel)
        
        NSLayoutConstraint.activate([
            playButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            playButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 30),
            playButton.heightAnchor.constraint(equalToConstant: 30),
            
            durationLabel.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 8),
            durationLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
    }
    
    func configure(message: AgoraChatMessage) {
        if let body = message.body as? AgoraChatVoiceMessageBody {
            let duration = body.duration
            let minutes = Int(duration) / 60
            let seconds = Int(duration) % 60
            durationLabel.text = String(format: "%02d:%02d", minutes, seconds)
        }
        
    }
    
    @objc private func playButtonTapped() {
        isPlaying.toggle()
        delegate?.didTapPlayButton(in: self)
    }
    
    func updatePlayButtonState(isPlaying: Bool) {
        let imageName = isPlaying ? "stop.fill" : "play.fill"
        playButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
}
