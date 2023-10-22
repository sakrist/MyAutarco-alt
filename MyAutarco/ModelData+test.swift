//
//  ModelData+test.swift
//  MyAutarco
//
//  Created by Volodymyr Boichentsov on 30/10/2023.
//

import Foundation

extension ModelData {
    
    static func todayTimelineMock() -> [DataPoint]  {
        let inverter = ModelData.getPower(jsonData: ModelData.inverterTimelineMock)
        let grid = ModelData.getPower(jsonData: ModelData.gridTimelineMock)
        let battery = ModelData.getPower(jsonData: ModelData.batteryTimelineMock)
        return ModelData.convertTimeline(inverter, grid, battery)
    }
    
    static let gridTimelineMock = """
{
"power": {
    "2023-10-29 00:00:00": 194,
    "2023-10-29 00:15:00": 271,
    "2023-10-29 00:30:00": 257,
    "2023-10-29 00:45:00": 220,
    "2023-10-29 01:00:00": 160,
    "2023-10-29 01:15:00": 151,
    "2023-10-29 01:30:00": 154,
    "2023-10-29 01:45:00": 199,
    "2023-10-29 02:00:00": 175,
    "2023-10-29 02:15:00": 145,
    "2023-10-29 02:30:00": 149,
    "2023-10-29 02:45:00": 139,
    "2023-10-29 03:00:00": 166,
    "2023-10-29 03:15:00": 1594,
    "2023-10-29 03:30:00": 2422,
    "2023-10-29 03:45:00": 1446,
    "2023-10-29 04:00:00": 1392,
    "2023-10-29 04:15:00": 1117,
    "2023-10-29 04:30:00": 212,
    "2023-10-29 04:45:00": 201,
    "2023-10-29 05:00:00": 142,
    "2023-10-29 05:15:00": 147,
    "2023-10-29 05:30:00": 141,
    "2023-10-29 05:45:00": 1875,
    "2023-10-29 06:00:00": 231,
    "2023-10-29 06:15:00": 208,
    "2023-10-29 06:30:00": 255,
    "2023-10-29 06:45:00": 208,
    "2023-10-29 07:00:00": 1661,
    "2023-10-29 07:15:00": 2430,
    "2023-10-29 07:30:00": 1663,
    "2023-10-29 07:45:00": 1560,
    "2023-10-29 08:00:00": 617,
    "2023-10-29 08:15:00": 125,
    "2023-10-29 08:30:00": 1009,
    "2023-10-29 08:45:00": 70,
    "2023-10-29 09:00:00": 0,
    "2023-10-29 09:15:00": 11,
    "2023-10-29 09:30:00": -27,
    "2023-10-29 09:45:00": 754,
    "2023-10-29 10:00:00": 480,
    "2023-10-29 10:15:00": 84,
    "2023-10-29 10:30:00": 1445,
    "2023-10-29 10:45:00": 2935,
    "2023-10-29 11:00:00": 915,
    "2023-10-29 11:15:00": 0,
    "2023-10-29 11:30:00": -476,
    "2023-10-29 11:45:00": -2785,
    "2023-10-29 12:00:00": 0,
    "2023-10-29 12:15:00": 0,
    "2023-10-29 12:30:00": -14,
    "2023-10-29 12:45:00": -754,
    "2023-10-29 13:00:00": -81,
    "2023-10-29 13:15:00": -400,
    "2023-10-29 13:30:00": 476,
    "2023-10-29 13:45:00": -19,
    "2023-10-29 14:00:00": 0,
    "2023-10-29 14:15:00": 0,
    "2023-10-29 14:30:00": 0,
    "2023-10-29 14:45:00": -236,
    "2023-10-29 15:00:00": 0,
    "2023-10-29 15:15:00": 0,
    "2023-10-29 15:30:00": 0,
    "2023-10-29 15:45:00": 0,
    "2023-10-29 16:00:00": 0,
    "2023-10-29 16:15:00": 0,
    "2023-10-29 16:30:00": 0,
    "2023-10-29 16:45:00": 0,
    "2023-10-29 17:00:00": 0,
    "2023-10-29 17:15:00": 0,
    "2023-10-29 17:30:00": 17,
    "2023-10-29 17:45:00": 0,
    "2023-10-29 18:00:00": 1234,
    "2023-10-29 18:15:00": 1345,
    "2023-10-29 18:30:00": 1102,
    "2023-10-29 18:45:00": 2718,
    "2023-10-29 19:00:00": 3979,
    "2023-10-29 19:15:00": 2263,
    "2023-10-29 19:30:00": 2033,
    "2023-10-29 19:45:00": 2400,
    "2023-10-29 20:00:00": 982,
    "2023-10-29 20:15:00": 561,
    "2023-10-29 20:30:00": 510,
    "2023-10-29 20:45:00": 497,
    "2023-10-29 21:00:00": 350,
    "2023-10-29 21:15:00": 261,
    "2023-10-29 21:30:00": 320,
    "2023-10-29 21:45:00": 221,
    "2023-10-29 22:00:00": 224,
    "2023-10-29 22:15:00": 554
}
}
""".data(using: .utf8)!
    
    static let inverterTimelineMock = """
        {
            "power" : {
                "2023-10-29 00:00:00": 0,
                "2023-10-29 00:15:00": 0,
                "2023-10-29 00:30:00": 0,
                "2023-10-29 00:45:00": 1,
                "2023-10-29 01:00:00": 1,
                "2023-10-29 01:15:00": 0,
                "2023-10-29 01:30:00": 0,
                "2023-10-29 01:45:00": 0,
                "2023-10-29 02:00:00": 1,
                "2023-10-29 02:15:00": 1,
                "2023-10-29 02:30:00": 1,
                "2023-10-29 02:45:00": 1,
                "2023-10-29 03:00:00": 1,
                "2023-10-29 03:15:00": 1,
                "2023-10-29 03:30:00": 1,
                "2023-10-29 03:45:00": 1,
                "2023-10-29 04:00:00": 1,
                "2023-10-29 04:15:00": 1,
                "2023-10-29 04:30:00": 1,
                "2023-10-29 04:45:00": 1,
                "2023-10-29 05:00:00": 1,
                "2023-10-29 05:15:00": 0,
                "2023-10-29 05:30:00": 0,
                "2023-10-29 05:45:00": 0,
                "2023-10-29 06:00:00": 0,
                "2023-10-29 06:15:00": 0,
                "2023-10-29 06:30:00": 0,
                "2023-10-29 06:45:00": 0,
                "2023-10-29 07:00:00": 0,
                "2023-10-29 07:15:00": 1,
                "2023-10-29 07:30:00": 11,
                "2023-10-29 07:45:00": 29,
                "2023-10-29 08:00:00": 39,
                "2023-10-29 08:15:00": 40,
                "2023-10-29 08:30:00": 40,
                "2023-10-29 08:45:00": 49,
                "2023-10-29 09:00:00": 129,
                "2023-10-29 09:15:00": 185,
                "2023-10-29 09:30:00": 264,
                "2023-10-29 09:45:00": 153,
                "2023-10-29 10:00:00": 151,
                "2023-10-29 10:15:00": 54,
                "2023-10-29 10:30:00": 286,
                "2023-10-29 10:45:00": 1312,
                "2023-10-29 11:00:00": 543,
                "2023-10-29 11:15:00": 626,
                "2023-10-29 11:30:00": 2418,
                "2023-10-29 11:45:00": 4666,
                "2023-10-29 12:00:00": 530,
                "2023-10-29 12:15:00": 520,
                "2023-10-29 12:30:00": 821,
                "2023-10-29 12:45:00": 2173,
                "2023-10-29 13:00:00": 3954,
                "2023-10-29 13:15:00": 1222,
                "2023-10-29 13:30:00": 1818,
                "2023-10-29 13:45:00": 1681,
                "2023-10-29 14:00:00": 1028,
                "2023-10-29 14:15:00": 752,
                "2023-10-29 14:30:00": 477,
                "2023-10-29 14:45:00": 899,
                "2023-10-29 15:00:00": 799,
                "2023-10-29 15:15:00": 759,
                "2023-10-29 15:30:00": 1201,
                "2023-10-29 15:45:00": 300,
                "2023-10-29 16:00:00": 379,
                "2023-10-29 16:15:00": 324,
                "2023-10-29 16:30:00": 197,
                "2023-10-29 16:45:00": 148,
                "2023-10-29 17:00:00": 120,
                "2023-10-29 17:15:00": 53,
                "2023-10-29 17:30:00": 33,
                "2023-10-29 17:45:00": 38,
                "2023-10-29 18:00:00": 36,
                "2023-10-29 18:15:00": 26,
                "2023-10-29 18:30:00": 7,
                "2023-10-29 18:45:00": 1,
                "2023-10-29 19:00:00": 0,
                "2023-10-29 19:15:00": 0,
                "2023-10-29 19:30:00": 0,
                "2023-10-29 19:45:00": 0,
                "2023-10-29 20:00:00": 0,
                "2023-10-29 20:15:00": 0,
                "2023-10-29 20:30:00": 0,
                "2023-10-29 20:45:00": 0,
                "2023-10-29 21:00:00": 0,
                "2023-10-29 21:15:00": 0,
                "2023-10-29 21:30:00": null
            },
            "no_comms": []
        }
""".data(using: .utf8)!
    
    
    static let batteryTimelineMock = """
{
"power": {
    "2023-10-29 00:00:00": -124,
    "2023-10-29 00:15:00": -124,
    "2023-10-29 00:30:00": -124,
    "2023-10-29 00:45:00": -124,
    "2023-10-29 01:00:00": -124,
    "2023-10-29 01:15:00": -124,
    "2023-10-29 01:30:00": -124,
    "2023-10-29 01:45:00": -124,
    "2023-10-29 02:00:00": -124,
    "2023-10-29 02:15:00": -124,
    "2023-10-29 02:30:00": -124,
    "2023-10-29 02:45:00": -124,
    "2023-10-29 03:00:00": -124,
    "2023-10-29 03:15:00": -124,
    "2023-10-29 03:30:00": -124,
    "2023-10-29 03:45:00": -124,
    "2023-10-29 04:00:00": -124,
    "2023-10-29 04:15:00": -122,
    "2023-10-29 04:30:00": -122,
    "2023-10-29 04:45:00": -118,
    "2023-10-29 05:00:00": -118,
    "2023-10-29 05:15:00": -118,
    "2023-10-29 05:30:00": -118,
    "2023-10-29 05:45:00": 1430,
    "2023-10-29 06:00:00": -126,
    "2023-10-29 06:15:00": -126,
    "2023-10-29 06:30:00": -126,
    "2023-10-29 06:45:00": -122,
    "2023-10-29 07:00:00": -120,
    "2023-10-29 07:15:00": -123,
    "2023-10-29 07:30:00": -127,
    "2023-10-29 07:45:00": -132,
    "2023-10-29 08:00:00": -139,
    "2023-10-29 08:15:00": -135,
    "2023-10-29 08:30:00": -135,
    "2023-10-29 08:45:00": -135,
    "2023-10-29 09:00:00": -135,
    "2023-10-29 09:15:00": 40,
    "2023-10-29 09:30:00": 66,
    "2023-10-29 09:45:00": 0,
    "2023-10-29 10:00:00": 0,
    "2023-10-29 10:15:00": 0,
    "2023-10-29 10:30:00": 0,
    "2023-10-29 10:45:00": 0,
    "2023-10-29 11:00:00": 73,
    "2023-10-29 11:15:00": 387,
    "2023-10-29 11:30:00": 1615,
    "2023-10-29 11:45:00": 1621,
    "2023-10-29 12:00:00": 271,
    "2023-10-29 12:15:00": 398,
    "2023-10-29 12:30:00": -1506,
    "2023-10-29 12:45:00": 1350,
    "2023-10-29 13:00:00": 3074,
    "2023-10-29 13:15:00": -1666,
    "2023-10-29 13:30:00": 1451,
    "2023-10-29 13:45:00": 1370,
    "2023-10-29 14:00:00": 625,
    "2023-10-29 14:15:00": 345,
    "2023-10-29 14:30:00": -5,
    "2023-10-29 14:45:00": 199,
    "2023-10-29 15:00:00": 411,
    "2023-10-29 15:15:00": 458,
    "2023-10-29 15:30:00": 917,
    "2023-10-29 15:45:00": 70,
    "2023-10-29 16:00:00": 182,
    "2023-10-29 16:15:00": 37,
    "2023-10-29 16:30:00": -243,
    "2023-10-29 16:45:00": -219,
    "2023-10-29 17:00:00": -1220,
    "2023-10-29 17:15:00": -321,
    "2023-10-29 17:30:00": -2287,
    "2023-10-29 17:45:00": -2710,
    "2023-10-29 18:00:00": -849,
    "2023-10-29 18:15:00": -146,
    "2023-10-29 18:30:00": -132,
    "2023-10-29 18:45:00": -130,
    "2023-10-29 19:00:00": -130,
    "2023-10-29 19:15:00": -130,
    "2023-10-29 19:30:00": -125,
    "2023-10-29 19:45:00": -125,
    "2023-10-29 20:00:00": -125,
    "2023-10-29 20:15:00": -125,
    "2023-10-29 20:30:00": -124,
    "2023-10-29 20:45:00": -124,
    "2023-10-29 21:00:00": -124,
    "2023-10-29 21:15:00": -124,
    "2023-10-29 21:30:00": -122,
    "2023-10-29 21:45:00": -121,
    "2023-10-29 22:00:00": -122,
    "2023-10-29 22:15:00": -122
}
}
""".data(using: .utf8)!
    
}
