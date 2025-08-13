//
//  String+Ext.swift
//  Netflix_Clone
//
//  Created by Melih Bey on 11.08.2025.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        return self.prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}
