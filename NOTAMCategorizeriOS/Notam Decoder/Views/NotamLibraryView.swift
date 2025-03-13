//
//  NotamLibrary.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 11/19/24.
//

import SwiftUI

struct NotamLibraryView: View {
    var body: some View {
        List {
            Section {
                ForEach(sampleNotamsICAO, id: \.id) { notam in
                    NavigationLink {
                        DecodedNotamView(notam)
                    } label: {
                        Text(notam.content)
                            .displayNotam(isList: true)
                    }
                }
            } header: {
                Text("ICAO")
                    .sectionHeaderStyle()
            }
            
            Section {
                ForEach(sampleNotamsFAA, id: \.id) { notam in
                    NavigationLink {
                        DecodedNotamView(notam)
                    } label: {
                        Text(notam.content)
                            .displayNotam(isList: true)
                    }
                }
            } header: {
                Text("FAA")
                    .sectionHeaderStyle()
            }
            
            logoListFooter()
            
        }
        .addNavBar("Select a NOTAM Below")
    }
    
    private let sampleNotamsICAO: [Notam] = [
        Notam("""
              A1747/24 NOTAMN
              Q) LMMM/QMRAP/IV/NBO/A /000/999/3551N01429E005
              A) LMML 
              B) 2709070400 
              C) 2709070630
              E) RUNWAY 05/23 CLOSED FOR LANDING AND TAKE-OFF.
              RUNWAY 05/23 NOT AVAILABLE IN CASE OF AN EMERGENCY.
              """),
        Notam("""
              C1012/24 NOTAMN
              Q) EPWW/QNMAS/IV/BO /E /000/999/5208N01643E025
              A) EPWW 
              B) 2411290900 
              C) 2411291600
              E) DVOR/DME CMP FREQ 114.500MHZ/CH92X U/S DUE TO MAINT.
              """),
        Notam("""
              A1470/24 NOTAMN
              Q) LJLA/QAFTT/IV/BO /E /000/999/4611N01452E999
              A) LJLA 
              B) 2411280000 
              C) 2412112359
              E) TRIGGER NOTAM - PERM AIRAC AMDT 138/2024 
              EFFECTIVE 28 NOV 2024 
              - CDR ROUTES
              - SECSI FRA CHANGES
              """),
        Notam("""
              N0059/24 NOTAMN
              Q) SBAO/QWELW/IV/BO /W /000/450/0400S03141W070
              A) SBAO 
              B) 2409031105 
              C) 2410101945
              E) EXER (GERMAN AEROSPACE CENTER ATMOSPHERIC RESEARCH) WILL TAKE PLACE COORD 042655N0303631W THEN, A LONG THE CLOCKWISE ARC OF A CIRCLE OF 70NM RADIUS CENTRED ON 040000N0314100W TO 050856N0313309W
              F) GND 
              G) FL450
              """)
    ]
    
    private let sampleNotamsFAA: [Notam] = [
        Notam("""
              !LAL 12/039 LAL OBST CRANE (ASN UNKNOWN) 275939N0815944W (1NM E APCH
              END RWY 23)
              UNKNOWN (140FT AGL) FLAGGED AND LGTD 2312112207-2312252200
              """),
        Notam("""
              !MIA 08/323 VKZ AIRSPACE UAS WI AN AREA DEFINED AS .25NM RADIUS OF 255322N0801126W (5.4NM E OPF) SFC-400FT AGL 2408201000-2408201200
              """),
        Notam("""
              !GLV 10/010 GLV RWY 03 FICON 100 PCT COMPACTED SN OBS AT 2410311606. 2410311606-2411011606
              """),
        Notam("""
              !ABY 09/031 ABY COM REMOTE COM OUTLET 122.6 U/S 2409190501-2409191000
              """),
    ]
}

#Preview {
    NotamLibraryView()
}
