//
//  OEXCheckBox.swift
//  edX
//
//  Created by Michael Katz on 8/27/15.
//  Copyright (c) 2015 edX. All rights reserved.
//

import UIKit

public class OEXCheckBox: UIButton {
    
    @IBInspectable public var checked: Bool = false {
        didSet {
            updateState()
        }
    }
    
    private func _setup() {
        imageView?.contentMode = .ScaleAspectFit
        
        addTarget(self, action: #selector(OEXCheckBox.tapped), forControlEvents: .TouchUpInside)
        updateState()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateState()
    }
    
    private func updateState() {
        let newIcon = checked ? Icon.CheckCircleO : Icon.CircleO
        let size = min(bounds.width, bounds.height)
        let image = newIcon.imageWithFontSize(size)
        setImage(image, forState: .Normal)
        accessibilityLabel = checked ? TDLocalizeSelectSwift("ACCESSIBILITY_CHECKBOX_CHECKED") : TDLocalizeSelectSwift("ACCESSIBILITY_CHECKBOX_UNCHECKED")
        accessibilityHint = checked ? TDLocalizeSelectSwift("ACCESSIBILITY_CHECKBOX_HINT_CHECKED") : TDLocalizeSelectSwift("ACCESSIBILITY_CHECKBOX_HINT_UNCHECKED")
    }
    
    func tapped() {
        checked = !checked
        sendActionsForControlEvents(.ValueChanged)
    }
}
