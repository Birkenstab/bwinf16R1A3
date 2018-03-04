// Copyright (c) 2016, Moritz Beck (Birkenstab.de)

library aufgabe3;

import "dart:collection";
import 'dart:html';
import 'dart:async';
import "dart:isolate";

part "situation.dart";
part "stein.dart";
part "solutionFinder.dart";
part "situationParser.dart";
part 'puzzleViewController.dart';

// TODO durch von Anfang an gedrehte Puzzles prüfen ob die fertig detection auch wirklich funktioniert in jede Richtung

List<String> puzzles = [
    "rotation1_03.txt",
    "rotation2_03.txt",
    "rotation3_03.txt",
    "test1.txt",
    "test2.txt",
    "test3.txt"
];

List<Situation> solutionPath = [];
int pos = 0;

init() async {
    SelectElement $puzzleSelector = querySelector( "#puzzleSelector" );
    var first = true;
    for ( String puzzle in puzzles ) {
        $puzzleSelector.append( new OptionElement( data: puzzle, value: puzzle, selected: first ) );
        first = false;
    }

    querySelector( "#ladeButton" ).onClick.listen( (event) {
        selectSituation( $puzzleSelector.selectedOptions.first.value );
    } );

    querySelector( "#weiterButton" ).onClick.listen( next );
    querySelector( "#zurueckButton" ).onClick.listen( previous );
    updateVorZurueckKnopf();

    querySelector( "#ladeVonDateiKnopf" ).onClick.listen( ladeVonDatei );

    querySelector( "#infoText" ).text = "Wähle ein Puzzle aus und drücke auf „Laden“ oder drücke auf „Lade von Datei“ um ein eigenes Puzzle zu laden";

}

selectSituation( String filename ) async {
    querySelector( "#infoText" ).text = "Lade Puzzle…";
    solutionPath = [];
    pos = 0;
    updateVorZurueckKnopf();

    querySelector( "#puzzleSelector" ).disabled = true;
    querySelector( "#ladeButton" ).disabled = true;
    querySelector( "#ladeVonDateiKnopf" ).disabled = true;

    Situation situation = await loadSituation( filename );
    findSolution( situation );
}

void findSolution( Situation situation ) {
    PuzzleViewController.show( situation );

    querySelector( "#infoText" ).text = "Finde Lösung…";
    querySelector( "#infoText2" ).text = "";
    querySelector( "#infoText3" ).text = "";
    querySelector( "#drehfolge" ).text = "";

    Stopwatch stopwatch = new Stopwatch()..start();

    var sPort = new ReceivePort();
    SendPort rPort;
    sPort.listen((msg) {
        if (msg is SendPort) {
            rPort = msg;
            rPort.send( situation );
        } else if ( msg is SolutionFinderStatus ) {
            querySelector("#infoText2").text = "Bisher verfolgte Pfade: ${msg.paths}; Schritte: ${msg.steps}; Bisher gefundene einzigartige Situationen: ${msg.uniqueSituations}";
        } else if ( msg is SolutionFinderResult ) {
            if ( msg.path == null ) {
                querySelector( "#infoText" ).text = "Keine Lösung gefunden!";
                querySelector("#infoText2").text = "";
            } else {
                querySelector( "#infoText" ).text = "Lösung gefunden!";
                querySelector("#infoText2").text = "Habe Lösung mit ${msg.path.length} Schritten gefunden! Dauerte ${stopwatch.elapsedMilliseconds.toDouble()/1000.0} Sekunden";
                querySelector( "#infoText3" ).text = "Lösung anschauen durch Klicken auf „Weiter“ oder unten Drehfolge im Kasten anschauen";
                solutionPath = msg.path;
                pos = 0;
                showSolution();

                String text = "Drehfolge:\n";
                bool first = true;
                Orientation last = Orientation.north;
                for ( Situation situation in msg.path ) {
                    if ( first ) {
                        first = false;
                        last = situation.orientation;
                        continue;
                    }

                    if ( ( last.index + 1 ) % 4 == situation.orientation.index ) {
                        text += "Nach rechts drehen\n";
                    } else if ( ( last.index - 1 + 4 ) % 4 == situation.orientation.index ) {
                        text += "Nach links drehen\n";
                    } else {
                        text += "So drehen, dass die Oberseite in Richtung ${situation.orientation} zeigt\n";
                    }
                    last = situation.orientation;
                }
                text += "Fertig";
                querySelector( "#drehfolge" ).value = text;
            }
            querySelector( "#puzzleSelector" ).disabled = false;
            querySelector( "#ladeButton" ).disabled = false;
            querySelector( "#ladeVonDateiKnopf" ).disabled = false;
        }
        else print("Host got $msg");
    });

    Isolate.spawn( startIsolate, sPort.sendPort);
}

void startIsolate( sender ) {
    SolutionFinder solutionFinder = new SolutionFinder();
    solutionFinder.startIsolate( sender );
}

Future<Situation> loadSituation( String filename ) async {
    String string = await HttpRequest.getString( "puzzles/$filename" );
    try {
        return SituationParser.parse( string );
    } catch ( e ) {
        window.alert( "Ungültiges Format: $e" );
        return null;
    }
}

void next(_) {
    pos++;
    showSolution();
}

void previous(_) {
    pos--;
    showSolution( true );
}

void updateVorZurueckKnopf() {
    if ( pos == 0 ) {
        querySelector( "#zurueckButton" ).disabled = true;
    } else {
        querySelector( "#zurueckButton" ).disabled = false;
    }

    if ( pos >= solutionPath.length - 1 ) {
        querySelector( "#weiterButton" ).disabled = true;
    } else {
        querySelector( "#weiterButton" ).disabled = false;
    }

    if ( solutionPath.length > 0 )
        querySelector( "#navInfoText" ).text = "Schritt ${pos+1} von ${solutionPath.length}";
    else
        querySelector( "#navInfoText" ).text = "";
}

void showSolution( [ bool reverse = false ] ) {
    PuzzleViewController.show( solutionPath[ pos ], reverse );
    updateVorZurueckKnopf();
}

void ladeVonDatei( _ ) {
    var overlay = new DivElement();
    overlay.classes.add( "overlay" );
    overlay.style.lineHeight = "${window.innerHeight}px";
    querySelector( "body" ).append( overlay );

    var popup = new DivElement();
    popup.classes.add( "popup" );

    popup.append( new ParagraphElement()..text = "Fügen sie hier den Inhalt der Datei ein die eingelesen werden soll" );

    var textarea = new TextAreaElement();

    popup.append( textarea );

    popup.append( new BRElement() );

    var button = new ButtonElement();
    button.text = "Laden";
    button.onClick.listen( ( event ) {
        try {
            Situation situation = SituationParser.parse( textarea.value );
            solutionPath = [];
            pos = 0;
            updateVorZurueckKnopf();

            querySelector( "#puzzleSelector" ).disabled = true;
            querySelector( "#ladeButton" ).disabled = true;
            querySelector( "#ladeVonDateiKnopf" ).disabled = true;
            findSolution( situation );
            overlay.remove();
            popup.remove();
        } on FormatException catch(e) {
            window.alert( "Ungültiges Format: $e" );
        }
    } );
    popup.append( button );

    overlay.append( popup );


}