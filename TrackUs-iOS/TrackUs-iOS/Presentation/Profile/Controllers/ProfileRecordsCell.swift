//
//  ProfileRecordsCell.swift
//  TrackUs-iOS
//
//  Created by 박소희 on 6/17/24.
//

import UIKit

class ProfileRecordsCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "ProfileRecordsCell"
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 87).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 87).isActive = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .gray
        return imageView
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let paceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let secondsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let startTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .gray2
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .gray2
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier reuseIndentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIndentifier)
        self.configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
        
    func configureUI() {
        backgroundColor = .white
        
        self.contentView.addSubview(postImageView)
        postImageView.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor).isActive = true
        postImageView.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        postImageView.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        postImageView.widthAnchor.constraint(equalToConstant: 87).isActive = true
        postImageView.heightAnchor.constraint(equalToConstant: 87).isActive = true
        
        let horizontalStackView = UIStackView(arrangedSubviews: [distanceLabel, paceLabel, secondsLabel])
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 8
        horizontalStackView.alignment = .center
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let verticalStackView = UIStackView(arrangedSubviews: [horizontalStackView, startTimeLabel, addressLabel])
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 8
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            verticalStackView.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 16),
            verticalStackView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor)
        ])
    }

        func configure(running: Running) {
            postImageView.loadImage(url: running.routeImageUrl)
            
            distanceLabel.text = "\(String(format: "%.2f", running.distance)) km"
            
            let minutes = Int(running.pace / 60)
            let seconds = Int(running.pace) % 60
            paceLabel.text = "\(Int(running.pace / 60))\"\(Int(running.pace) % 60)\""
            
            let totalSeconds = Int(running.seconds)
            let formattedSeconds = String(format: "%02d:%02d", totalSeconds / 60, totalSeconds % 60)
            secondsLabel.text = formattedSeconds
            
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            startTimeLabel.text = formatter.string(from: running.startTime)
            
            addressLabel.text = running.address
        }
    }
