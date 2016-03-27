//
//  Horodateur.swift
//  parky
//
//  Created by Alexis Suard on 06/03/2016.
//  Copyright © 2016 Alexis Suard. All rights reserved.
//

import ModelRocket

class Horodateur: Model {
    private let _name  = Property<String>(key: "name")
    var name: String {
        set { _name.value = newValue }
        get { return _name.value ?? "coucou" }
    }
}
