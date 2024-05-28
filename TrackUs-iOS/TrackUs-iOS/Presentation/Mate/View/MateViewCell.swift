//
//  MateViewCell.swift
//  TrackUs-iOS
//
//  Created by 박선구 on 5/19/24.
//

import UIKit

class MateViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "MateViewCell"
    
    
    let titleText: String = ""
    let locationText: String = ""
    let timeText: String = ""
    let distanceText: String = ""
    let dateText: String = ""
    let peopleLimit: Int = 0
    var peopleIn: Int = 0
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 87).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 87).isActive = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .gray
        return imageView
    }()
    
    private let runningStyleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.clipsToBounds = true
        label.layer.cornerRadius = 5
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private let peopleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()
    
    let locationIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "locationPin_icon"))
        imageView.layer.transform = CATransform3DMakeScale(1.2, 0.9, 0.9)
        return imageView
    }()
    
    let timeIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "time_icon"))
        imageView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        return imageView
    }()
    
    let distanceIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "arrowBoth_icon"))
        imageView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        return imageView
    }()
    
    let peopleIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "people_icon"))
        return imageView
    }()
    
    let closingLabel: UILabel = {
        let label = UILabel()
        label.text = "마감"
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .gray1
        label.textAlignment = .center
        return label
    }()
    
    let endLabel: UILabel = {
        let label = UILabel()
        label.text = "종료"
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .gray1
        label.textAlignment = .center
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
        self.contentView.addSubview(profileImageView)
        profileImageView.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 87).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 87).isActive = true
        
        profileImageView.addSubview(closingLabel)
        closingLabel.translatesAutoresizingMaskIntoConstraints = false
        closingLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
        closingLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        closingLabel.isHidden = true
        
        self.contentView.addSubview(runningStyleLabel)
        runningStyleLabel.translatesAutoresizingMaskIntoConstraints = false
        runningStyleLabel.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor).isActive = true
        runningStyleLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 9).isActive = true
        runningStyleLabel.widthAnchor.constraint(equalToConstant: 54).isActive = true
        runningStyleLabel.heightAnchor.constraint(equalToConstant: 19).isActive = true
        
        self.contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: runningStyleLabel.bottomAnchor, constant: 3).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 9).isActive = true
        
        let locationStack = UIStackView(arrangedSubviews: [locationIcon, locationLabel])
        locationStack.axis = .horizontal
        locationStack.spacing = 5
        
        let timeStack = UIStackView(arrangedSubviews: [timeIcon, timeLabel])
        timeStack.axis = .horizontal
        timeStack.spacing = 5
        
        let distanceStack = UIStackView(arrangedSubviews: [distanceIcon, distanceLabel])
        distanceStack.axis = .horizontal
        distanceStack.spacing = 5
        
        let peopleStack = UIStackView(arrangedSubviews: [peopleIcon, peopleLabel])
        peopleStack.axis = .horizontal
        peopleStack.spacing = 5
        
        self.contentView.addSubview(locationStack)
        locationStack.translatesAutoresizingMaskIntoConstraints = false
        locationStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3).isActive = true
        locationStack.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 9).isActive = true
        
        self.contentView.addSubview(timeStack)
        timeStack.translatesAutoresizingMaskIntoConstraints = false
        timeStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3).isActive = true
        timeStack.leadingAnchor.constraint(equalTo: locationStack.trailingAnchor, constant: 8).isActive = true
        
        self.contentView.addSubview(distanceStack)
        distanceStack.translatesAutoresizingMaskIntoConstraints = false
        distanceStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3).isActive = true
        distanceStack.leadingAnchor.constraint(equalTo: timeStack.trailingAnchor, constant: 8).isActive = true
        
        self.contentView.addSubview(peopleStack)
        peopleStack.translatesAutoresizingMaskIntoConstraints = false
        peopleStack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        peopleStack.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 9).isActive = true
        
        self.contentView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor).isActive = true
    }
    
    public func configure(image: String, runningStyleLabel: String, titleLabel: String, locationLabel: String, timeLabel: String, distanceLabel: String, peopleLimit: Int, peopleIn: Int, dateLabel: String) {
        
//        self.profileImageView.image = image
        // 이미지 추가
        PostService.downloadImage(urlString: image) { image in
//            guard let self = self else { return }
            DispatchQueue.main.async {
                self.profileImageView.image = image
            }
        }
        
        self.runningStyleLabel.text = runningStyleLabel
        
        if titleLabel.count > 15 {
            self.titleLabel.text = "\(titleLabel.prefix(15))..."
        } else {
            self.titleLabel.text = titleLabel
        }
        
        self.locationLabel.text = locationLabel
        self.timeLabel.text = timeLabel
        self.distanceLabel.text = distanceLabel
        self.peopleLabel.text = "\(peopleIn) / \(peopleLimit)"
        self.dateLabel.text = dateLabel
        
        switch runningStyleLabel {
        case "걷기":
            self.runningStyleLabel.backgroundColor = .walking
        case "조깅":
            self.runningStyleLabel.backgroundColor = .jogging
        case "달리기":
            self.runningStyleLabel.backgroundColor = .running
        case "인터벌":
            self.runningStyleLabel.backgroundColor = .interval
        default:
            self.runningStyleLabel.backgroundColor = .mainBlue
        }
        
        if peopleIn >= peopleLimit {
            closingLabel.isHidden = false
        } else {
            closingLabel.isHidden = true
        }
    }

}
