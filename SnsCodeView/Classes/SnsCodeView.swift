//
// Created by JLM on 2019/9/4.
// Copyright (c) 2019 MarcoLi. All rights reserved.
//

import UIKit
import SnapKit

class SnsCodeView: UIView {
    private var maxNum: CGFloat = 4.0
    private var complete: ((String) -> Void)?
    private var textView: UITextView?
    private var labels: [UILabel] = [UILabel]()
    private var lines: [CAShapeLayer] = [CAShapeLayer]()
    private var lineViews: [UIView] = [UIView]()
    private var itemWidth: CGFloat = 42.0
    private var itemHeight: CGFloat = 40.0
    private var cursorColor: UIColor?
    private var emptylLineColor: UIColor?
    private var fillLineColor: UIColor?
    private var font: UIFont?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(maxNum: CGFloat, cursorColor: UIColor? = UIColor(red: 255.0 / 255.0, green: 204.0 / 255.0, blue: 79.0 / 255.0, alpha: 1), emptylLineColor: UIColor? = UIColor(red: 239.0 / 255.0, green: 239.0 / 255.0, blue: 239.0 / 255.0, alpha: 1), fillLineColor: UIColor? = UIColor(red: 74.0 / 255.0, green: 74.0 / 255.0, blue: 74.0 / 255.0, alpha: 1), font: UIFont? = UIFont.systemFont(ofSize: 20.0), estimatedItemWidth: CGFloat? = 42.0, estimatedHeight: CGFloat? = 40.0, complete: @escaping ((String) -> Void)) {
        self.init(frame: .zero)
        self.maxNum = maxNum
        self.cursorColor = cursorColor
        self.emptylLineColor = emptylLineColor
        self.fillLineColor = fillLineColor
        self.itemWidth = estimatedItemWidth ?? 42.0
        self.itemHeight = estimatedHeight ?? 40.0
        self.font = font
        self.complete = complete
        configureUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        guard let cursorColor = cursorColor, let emptylLineColor = emptylLineColor, let fillLineColor = fillLineColor, let font = font else { return }
        textView = UITextView()
        textView?.delegate = self
        textView?.textColor = .clear
        textView?.tintColor = .clear
        textView?.isHidden = true
        textView?.becomeFirstResponder()
        if let textView = textView {
            addSubview(textView)
            textView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        let margin = (UIScreen.main.bounds.size.width - itemWidth * maxNum) / CGFloat(maxNum + 1)
        for item in 0..<Int(maxNum) {
            let itemView = UIView()
            itemView.isUserInteractionEnabled = false
            addSubview(itemView)
            itemView.snp.makeConstraints { maker in
                maker.top.bottom.equalToSuperview()
                maker.left.equalToSuperview().offset(margin * CGFloat(item + 1) + self.itemWidth * CGFloat(item))
                maker.width.equalTo(self.itemWidth)
            }

            let label = UILabel()
            label.textAlignment = .center
            label.textColor = fillLineColor
            label.font = font
            itemView.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            let path = UIBezierPath(rect: CGRect(x: itemWidth / 2, y: 5, width: 2, height: itemHeight - 10))
            let line = CAShapeLayer()
            line.path = path.cgPath
            line.fillColor = cursorColor.cgColor
            itemView.layer.addSublayer(line)
            
            let lineView = UIView()
            itemView.addSubview(lineView)
            lineView.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(1)
            }
            
            if item == 0 {
                line.add(opacityAnimation(), forKey: "kOpacityAnimation")
                lineView.backgroundColor = cursorColor
                line.isHidden = false
            } else {
                lineView.backgroundColor = emptylLineColor
                line.isHidden = true
            }
            labels.append(label)
            lines.append(line)
            lineViews.append(lineView)
        }
    }
    
    func opacityAnimation() -> CABasicAnimation {
        let opacityAnimation = CABasicAnimation()
        opacityAnimation.keyPath = "opacity"
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.0
        opacityAnimation.duration = 0.8
        opacityAnimation.repeatCount = MAXFLOAT
        opacityAnimation.isRemovedOnCompletion = true
        opacityAnimation.fillMode = .forwards
        opacityAnimation.timingFunction = CAMediaTimingFunction.init(name: .easeIn)
        return opacityAnimation
    }
    
    func changeViewLayer(index: Int, isHidden: Bool) {
        let line = lines[index]
        if isHidden {
            line.removeAnimation(forKey: "kOpacityAnimation")
        } else {
            line.add(opacityAnimation(), forKey: "kOpacityAnimation")
        }
        UIView.animate(withDuration: 0.25) {
            line.isHidden = isHidden
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textView?.becomeFirstResponder()
    }
}

extension SnsCodeView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let textString = textView.text ?? ""
        if textString.count > Int(maxNum) {
            let index = textString.index(textString.startIndex, offsetBy: Int(maxNum))
            textView.text = String(textString[..<index])
        }
        
        if textString.count >= Int(maxNum) {
            endEditing(true)
            complete?(textView.text)
        }
        
        for (index,value) in labels.enumerated() {
            if index < textString.count {
                changeViewLayer(index: index, isHidden: true)
                value.text = textString.subString(start: index, length: 1)
                lineViews[index].backgroundColor = fillLineColor
            } else {
                changeViewLayer(index: index, isHidden: index == textString.count ? false : true)
                if textString.count == 0 {
                    changeViewLayer(index: 0, isHidden: false)
                    lineViews[0].backgroundColor = cursorColor
                }
                value.text = ""
                if index == textString.count {
                    lineViews[index].backgroundColor = cursorColor
                } else {
                    lineViews[index].backgroundColor = emptylLineColor
                }
            }
        }
        
    }
}
