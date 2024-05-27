//
//  RunInfoCell.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/27/24.
//

import UIKit

 class RunInfoCell: UITableViewCell {
    static let identifier = "RunInfoCell"
     var runInfo: RunInfoModel? {
         didSet {
             setupUI()
         }
     }
     
    private let title: UILabel = {
        let label = UILabel()
        label.text = "칼로리"
        label.textColor = .gray1
        return label
    }()
    
    private let result: UILabel = {
        let label = UILabel()
        label.text = "123 kcal"
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let st = UIStackView()
        st.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(st)
        st.axis = .horizontal
        st.distribution = .equalSpacing
        return st
    }()
     
     // 인터페이스빌더를 사용하지 않는경우 init구현 필수
     override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
         super.init(style: style, reuseIdentifier: reuseIdentifier)
         setupCell()
         setupViews()
     }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
      
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
     
     private func setupCell() {
         selectionStyle = .none
         separatorInset = .zero
     }
    
    private func setupViews() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(title)
        stackView.addArrangedSubview(result)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
     
     private func setupUI() {
         title.text = runInfo?.title
         result.text = runInfo?.result
     }
}

