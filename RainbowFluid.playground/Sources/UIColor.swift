//
//  UIColor.swift
//  Paint The Sky
//
//  Created by Charles Ferreira on 02/04/17.
//  Copyright © 2017 Charles Ferreira. All rights reserved.
//

import SpriteKit

extension UIColor
{
    func getRGBAComponents() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)?
    {
        var (red, green, blue, alpha) = (CGFloat(0.0), CGFloat(0.0), CGFloat(0.0), CGFloat(0.0))
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        {
            return (red, green, blue, alpha)
        }
        else
        {
            return nil
        }
    }
}
