//
//  CollectionCell.swift
//  AWSPhotoAlbum
//
//  Created by Emma Olthof on 14/01/2021.
//

import Foundation
import UIKit

class CollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var awsImage: UIImageView!
    
    /****************************************************************************************************************************//**
    ** \brief      Function for ReusableCell and displaying the right image to it.
    ** \param   The function takes a parameter given by the collectionView method.
    ********************************************************************************************************************************/
    func setImage(collectionImage: UIImage?) {
        if let image = collectionImage {
            awsImage.image = image
        }
    }
}
