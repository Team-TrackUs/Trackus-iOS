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
    
    private let postImageView: UIImageView = {
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
        self.contentView.addSubview(postImageView)
        postImageView.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor).isActive = true
        postImageView.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        postImageView.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        postImageView.widthAnchor.constraint(equalToConstant: 87).isActive = true
        postImageView.heightAnchor.constraint(equalToConstant: 87).isActive = true
        
        postImageView.addSubview(closingLabel)
        closingLabel.translatesAutoresizingMaskIntoConstraints = false
        closingLabel.centerXAnchor.constraint(equalTo: postImageView.centerXAnchor).isActive = true
        closingLabel.centerYAnchor.constraint(equalTo: postImageView.centerYAnchor).isActive = true
        closingLabel.isHidden = true
        
        self.contentView.addSubview(runningStyleLabel)
        runningStyleLabel.translatesAutoresizingMaskIntoConstraints = false
        runningStyleLabel.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor).isActive = true
        runningStyleLabel.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 9).isActive = true
        runningStyleLabel.widthAnchor.constraint(equalToConstant: 54).isActive = true
        runningStyleLabel.heightAnchor.constraint(equalToConstant: 19).isActive = true
        
        self.contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: runningStyleLabel.bottomAnchor, constant: 3).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 9).isActive = true
        
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
        locationStack.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 9).isActive = true
        
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
        peopleStack.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 9).isActive = true
        
        self.contentView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor).isActive = true
    }
    
    public func configure(post: Post) {
        
        postImageView.loadImage(url: post.routeImageUrl)
        
        self.runningStyleLabel.text = runningStyleString(for: post.runningStyle)
        
        if post.title.count > 15 {
            self.titleLabel.text = "\(post.title.prefix(15))..."
        } else {
            self.titleLabel.text = post.title
        }
        
        self.locationLabel.text = post.address
        self.timeLabel.text = post.startDate.toString(format: "h:mm a")
        self.distanceLabel.text = "\(String(format: "%.2f", post.distance))km"
        self.peopleLabel.text = "\(post.members.count) / \(post.numberOfPeoples)"
        self.dateLabel.text = post.startDate.toString(format: "yyyy년 MM월 dd일")
        
        switch runningStyleString(for: post.runningStyle) {
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
        
        if post.members.count >= post.numberOfPeoples {
            closingLabel.isHidden = false
        } else {
            closingLabel.isHidden = true
        }
    }
    
    func runningStyleString(for runningStyle: Int) -> String {
        switch runningStyle {
        case 0:
            return "걷기"
        case 1:
            return "조깅"
        case 2:
            return "달리기"
        case 3:
            return "인터벌"
        default:
            return "걷기"
        }
    }

}
