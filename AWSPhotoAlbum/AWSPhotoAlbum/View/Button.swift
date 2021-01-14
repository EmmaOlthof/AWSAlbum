//
//  Button.swift
//  AWSPhotoAlbum
//
//  Created by Emma Olthof on 14/01/2021.
//

import Foundation
import UIKit

/****************************************************************************************************************************//**
** \brief      Class to customize the button within the first view: CameraView.swift file.
** \return    The button how it looks like.
*********************************************************************************************************************************/
@objc class CustomButton: NSObject {
    let button: UIButton = {
        let customButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        customButton.backgroundColor = .purple
        customButton.layer.cornerRadius = 30
        customButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        customButton.adjustsImageWhenHighlighted = true
        customButton.addTarget(self, action: #selector(CameraView().buttonPressed(_:)), for: .touchUpInside)
        return customButton
    }()
}
